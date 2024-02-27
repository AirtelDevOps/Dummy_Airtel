/**
* Class to Convert the Lead: ARTL_LeadConversion 
*
* @Author  Trishank Chaddha, Rishab Kalra
* @Company Salesforce (SFI)
* @Date    06/10/2023
* @Test Class: ARTL_LeadConversionTest
* @Description  Lead Conversion
*/
global without sharing class ARTL_LeadConversion implements vlocity_cmt.VlocityOpenInterface {
    public static Boolean isLeadConversion = false;
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
        try {
            if (methodName.equals('convertLead')) {
                convertLead(input, outMap, options);
                return true;
            }
        } catch (Exception ex) {
            System.debug('DEBUGG ' + ex.getMessage() + ' ' + ex.getLineNumber());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_LeadConversion:convertLead', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
        }
        return false;
    }
    
    // Method to convert a lead and perform custom logic
    public static void convertLead(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
        System.debug('DEBUGG ARTL_LeadConversion convertLead '+ input);
        // Retrieve the lead ID from the input map
        Savepoint sp = Database.setSavepoint();
        try {
            Id leadId = (Id)input.get('leadId');
            if (leadId != null) {
                isLeadConversion = true;
                // Retrieve the lead record
                Lead leadRecord = [SELECT Id, FirstName, LastName, Related_Account__c, Related_Contact__c, OwnerId, Email,
                                   Salutation, MobilePhone, Phone, Product_Interest__c, Related_Account__r.OwnerId, ARC__c,
                                   Title
                                   FROM Lead WHERE Id = :leadId LIMIT 1];
                
                // Check if the lead record is not null
                if (leadRecord != null) {
                    // Define a list to hold the leads to be converted
                    List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
                    
                    // Create a LeadConvert object and set the required fields
                    Database.LeadConvert leadConvert = new Database.LeadConvert();
                    leadConvert.setLeadId(leadId);
                    leadConvert.setConvertedStatus('Converted');
                    leadConvert.setDoNotCreateOpportunity(false);
                    leadConvert.setOwnerId(leadRecord.OwnerId);
                    
                    leadConvert.setAccountId(leadRecord.Related_Account__c);
                    
                    // Check if there's a Contact with the same email under the same Account
                    List<Contact> existingContact = new List<Contact>();
                    Boolean contactAlreadyExists = false;
                    existingContact = [SELECT Id, AccountId FROM Contact 
                                       WHERE Email = :leadRecord.Email 
                                       ORDER BY CreatedDate DESC LIMIT 1];
                    Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_Party_Contact')?.getRecordTypeId();

                    if (!existingContact.isEmpty()) {
                        contactAlreadyExists = true;
                        leadConvert.setContactId(existingContact[0].Id);
                    }
                    
                    // Add the LeadConvert object to the list
                    leadConverts.add(leadConvert);
                    Date quarterEndDate = [SELECT EndDate FROM Period 
                                           WHERE type = 'Quarter' 
                                           AND StartDate = THIS_FISCAL_QUARTER].EndDate;
                    System.debug('DEBUGG leadRecord '+ leadRecord);
                    System.debug('DEBUGG leadRecord.Product_Interest__c '+ leadRecord.Product_Interest__c);
                    Opportunity opportunityRecord = new Opportunity(Name 				= (String)input.get('opportunityName'),
                                                                    AccountId 			= leadRecord.Related_Account__c,
                                                                    Amount 				= leadRecord.ARC__c,
                                                                    Product_Interest__c = leadRecord.Product_Interest__c,
                                                                    StageName 			= 'Qualified',
                                                                    OwnerId 			= leadRecord.Related_Account__r.OwnerId,
                                                                    CloseDate 			= quarterEndDate);
                    
                    List<Opportunity> oppRecordList = new List<Opportunity>();
                    oppRecordList.add(opportunityRecord);
                    if(!oppRecordList.isEmpty()){
                        for(Database.SaveResult sr: Database.insert(oppRecordList)){
                            if (sr.isSuccess()) {
                                System.debug('Successfully inserted contact - ' + sr.getId());
                            }
                            else {
                                // Operation failed, so get all errors                
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('DEBUGG The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('DEBUGG ' + err.getFields());
                                    Database.rollback(sp);
                                }
                            }
                        }
                    }
                    System.debug('DEBUGG new opportunityRecord '+ oppRecordList[0]);
                    System.debug('DEBUGG new opportunityRecord Product_Interest__c '+ oppRecordList[0]?.Product_Interest__c);
                    
                    leadConvert.setOpportunityId(oppRecordList[0].Id); 
                    Database.LeadConvertResult[] convertResults = Database.convertLead(leadConverts);
                    
                    System.debug('DEBUGG convertResults ' + convertResults);
                    System.debug('DEBUGG contactAlreadyExists1 '+contactAlreadyExists);

                    // Check the conversion results if needed
                    if (convertResults[0].isSuccess()) {
                        if (opportunityRecord != null) {
                            Id contactId = convertResults[0].getContactId();
                            if(contactAlreadyExists == false){
                                System.debug('DEBUGG contactAlreadyExists = false ');
                                Contact convertedContact = new Contact(Id 					= convertResults[0].getContactId(),
                                                                       ARTL_Contact_Role__c = 'Sales Contact',
                                                                       ARTL_Designation__c 	= leadRecord.Title,
                                                                       RecordTypeId 		= contactRecordTypeId);
                                Database.SaveResult sr = Database.update(convertedContact);
                                if(sr.isSuccess()){
                                    System.debug('DEBUGG contact updated ');
                                } 
                                else {
                                    System.debug('DEBUGG contact update error ');
                                    Database.rollback(sp);
                                }
                            }
                            Opportunity convertedOpportunity = new Opportunity(Id 					= convertResults[0].getOpportunityId(), 
                                                                               Customer_Contact__c 	= convertResults[0].getContactId());
                            Database.SaveResult srOpp = Database.update(convertedOpportunity);
                            if(srOpp.isSuccess()){
                                System.debug('DEBUGG convertedOpportunity updated ');
                            } 
                            else {
                                System.debug('DEBUGG convertedOpportunity update error ');
                                Database.rollback(sp);
                            }
                            outMap.put('opportunityRecordId', opportunityRecord.Id);
                        }
                    } 
                    else {
                        System.debug('Lead conversion failed: ' + convertResults[0].getErrors()[0].getMessage());
                        Database.rollback(sp);
                    }
                }
            }
        }
        catch(Exception ex){
            System.debug('DEBUGG ' + ex.getMessage() + ' ' + ex.getLineNumber());
            outMap.put('errorMessage',ex.getMessage());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_LeadConversion:convertLead', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
            Database.rollback(sp);
        }
    }
}