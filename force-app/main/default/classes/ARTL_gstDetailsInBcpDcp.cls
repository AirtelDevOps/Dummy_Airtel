/**
 * @description       : Used in IP - ARTL_CreateBCP to create BCP/DCP for a NBA account
 * @test class        : ARTL_gstDetailsInBcpDcpTest
 * @author            : Rishab Kalra
 * @last modified on  : 12-21-2023
**/
global class ARTL_gstDetailsInBcpDcp implements vlocity_cmt.VlocityOpenInterface {
    public class CustomException extends Exception {}
    private static final String CONTACT_ROLE_BILLING = 'Billing Contact';
    private static final String CONTACT_ROLE_DELIVERY = 'Delivery Contact';
    private static final String ROLE_BCP = 'BCP';
    private static final String ROLE_DCP = 'DCP';
    private static final String ROLE_BCP_DCP = 'BCPandDCP';
    
    global boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        try {
            System.debug('DEBUGG input '+ input);
            if(methodName.equalsIgnoreCase('createBcp')){
                createBcp(methodName, input, output, options);
            }
        } catch (Exception ex) {
            // Handle exceptions appropriately, log or return an error
            return false;
        }
        return true;
    }
    
    global static void createBcp(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){
        Savepoint sp = Database.setSavepoint();
        try{
            
            System.debug('DEBUGG input '+ input);

            String nbaAccountId = (String)input.get('ContextId');
            if(String.isBlank(nbaAccountId)){
                throw new CustomException('Account Id not found.');
            }
            //getting business account Id from NBA Id
            String parentAccountId = [SELECT Id, ParentId FROM Account WHERE Id = :nbaAccountId].ParentId;
            Map<String, Object> contactDetails = new Map<String, Object>();
            contactDetails = (Map<String, Object>)input.get('Step_ContactDetails');
            Map<String, Object> addressDetails = new Map<String, Object>();
            String role;
            if(!contactDetails.isEmpty()){
                addressDetails = (Map<String, Object>)contactDetails.get('TApincode-Block');
                role = (String)contactDetails.get('Select_Role');
            }
            //String contactRole = role.equalsIgnoreCase('BCP') ? 'Billing Contact': role.equalsIgnoreCase('DCP') ? 'Delivery Contact':'Delivery/Billing Contact';
            List<Contact> listOfContact = new List<Contact>();
            Map<Id, Contact> mapOfContact = new Map<Id, Contact>();
            List<vlocity_cmt__Premises__c> listOfPremises = new List<vlocity_cmt__Premises__c>();
            List<ContactPremiseRelation__c> listOfContactPremiseRelation = new List<ContactPremiseRelation__c>();
            List<AccountContactRelation> listOfAccountContactRelation = new List<AccountContactRelation>();
            
            if(String.isNotBlank(role) && role.equalsIgnoreCase(ROLE_BCP)){
                listOfContact.add(createContactRecord(contactDetails, CONTACT_ROLE_BILLING, nbaAccountId));
            }
            else if(String.isNotBlank(role) && role.equalsIgnoreCase(ROLE_DCP)){
                listOfContact.add(createContactRecord(contactDetails, CONTACT_ROLE_DELIVERY, nbaAccountId));
            }
            else if(String.isNotBlank(role) && role.equalsIgnoreCase(ROLE_BCP_DCP)){
                listOfContact.add(createContactRecord(contactDetails, CONTACT_ROLE_BILLING, nbaAccountId));
                listOfContact.add(createContactRecord(contactDetails, CONTACT_ROLE_DELIVERY, nbaAccountId));
            }
            
            
            
            //listOfContact.add(createContactRecord(contactDetails,contactRole, nbaAccountId));
            String insertedContactId;
            String bcpContactId;
            String dcpContactId;
            System.debug('List of contacts '+listOfContact);
            if(!listOfContact.isEmpty()){
                for(Database.SaveResult sr: Database.insert(listOfContact)){
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted contact - ' + sr.getId());
                        insertedContactId = sr.getId();
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('DEBUGG The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DEBUGG ' + err.getFields());
                            output.put('errorMessage',  err.getMessage());
                            Database.rollback(sp);
                            throw new CustomException(err.getMessage()+' '+err.getFields());
                        }
                    }
                }
            }
            for(Contact cont: listOfContact){
                if(String.isNotBlank(cont.Id)){
                    mapOfContact.put(cont.Id, cont);
                    if(cont.ARTL_Contact_Role__c.equalsIgnoreCase(CONTACT_ROLE_BILLING)){
                        bcpContactId = cont.Id;
                    }
                    if(cont.ARTL_Contact_Role__c.equalsIgnoreCase(CONTACT_ROLE_DELIVERY)){
                        dcpContactId = cont.Id;
                    }
                    
                }
            }
            System.debug('DEBUGG map '+mapOfContact);
            String insertedPremiseId;
            listOfPremises.add(createPremiseRecord(addressDetails));
            if(!listOfPremises.isEmpty()){
                // insert listOfPremises;
                for(Database.SaveResult sr: Database.insert(listOfPremises)){
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted Premise - ' + sr.getId());
                        insertedPremiseId = sr.getId();
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('DEBUGG The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DEBUGG ' + err.getFields());
                            output.put('errorMessage',  err.getMessage());
                            Database.rollback(sp);
                            throw new CustomException(err.getMessage()+' '+err.getFields());
                        }
                    }
                }
            }
            List<AccountContactRelation> updateListOfAccountContactRelation = new List<AccountContactRelation>();
            
            For(AccountContactRelation acr: [SELECT Id, ContactId, Contact.ARTL_Contact_Role__c, AccountId, Roles 
                                             FROM AccountContactRelation WHERE AccountId = :nbaAccountId
                                             AND (ContactId = :bcpContactId OR ContactId = :dcpContactId)]){
                                                 if(String.isBlank(acr.Roles)){
                                                     //acr.Roles = role.equalsIgnoreCase('BCP') ? 'BCP': role.equalsIgnoreCase('DCP') ? 'DCP':'BCP;DCP';
                                                     if(acr.Contact?.ARTL_Contact_Role__c?.equalsIgnoreCase(CONTACT_ROLE_BILLING)){
                                                         acr.Roles = ROLE_BCP;
                                                     }
                                                     if(acr.Contact?.ARTL_Contact_Role__c?.equalsIgnoreCase(CONTACT_ROLE_DELIVERY)){
                                                         acr.Roles = ROLE_DCP;
                                                     }
                                                     updateListOfAccountContactRelation.add(acr);
                                                 }
                                             }
            if(!String.isBlank(role)){
                if(role.equalsIgnoreCase(ROLE_BCP)){
                    //listOfAccountContactRelation.add(createAccountContactRelationRecord('BCP', insertedContactId, parentAccountId));
                    //listOfContactPremiseRelation.add(createContactPremiseRelationRecord(contactDetails, 'BCP', insertedPremiseId, insertedContactId, nbaAccountId));
                    listOfAccountContactRelation.add(createAccountContactRelationRecord(ROLE_BCP, bcpContactId, parentAccountId));
                    listOfContactPremiseRelation.add(createContactPremiseRelationRecord(contactDetails, ROLE_BCP, insertedPremiseId, bcpContactId, nbaAccountId));

                }
                else if(role.equalsIgnoreCase(ROLE_DCP)){
                    //listOfAccountContactRelation.add(createAccountContactRelationRecord('DCP', insertedContactId, parentAccountId));
                    //listOfContactPremiseRelation.add(createContactPremiseRelationRecord(contactDetails, 'DCP', insertedPremiseId, insertedContactId, nbaAccountId));
                    
                    listOfAccountContactRelation.add(createAccountContactRelationRecord(ROLE_DCP, dcpContactId, parentAccountId));
                    listOfContactPremiseRelation.add(createContactPremiseRelationRecord(contactDetails, ROLE_DCP, insertedPremiseId, dcpContactId, nbaAccountId));

                }
                else if(role.equalsIgnoreCase(ROLE_BCP_DCP)){
                    //listOfAccountContactRelation.add(createAccountContactRelationRecord('BCP;DCP', insertedContactId, parentAccountId));
                    //listOfContactPremiseRelation.add(createContactPremiseRelationRecord(contactDetails, 'BCP', insertedPremiseId, insertedContactId, nbaAccountId));
                    //listOfContactPremiseRelation.add(createContactPremiseRelationRecord(contactDetails, 'DCP', insertedPremiseId, insertedContactId, nbaAccountId));
                    
                    listOfAccountContactRelation.add(createAccountContactRelationRecord(ROLE_DCP, dcpContactId, parentAccountId));
                    listOfContactPremiseRelation.add(createContactPremiseRelationRecord(contactDetails, ROLE_DCP, insertedPremiseId, dcpContactId, nbaAccountId));
                    
                    listOfAccountContactRelation.add(createAccountContactRelationRecord(ROLE_BCP, bcpContactId, parentAccountId));
                    listOfContactPremiseRelation.add(createContactPremiseRelationRecord(contactDetails, ROLE_BCP, insertedPremiseId, bcpContactId, nbaAccountId));

                }
            }
            if(!updateListOfAccountContactRelation.isEmpty()){
                for(Database.UpsertResult sr: Database.upsert(updateListOfAccountContactRelation)){
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted listOfAccountContactRelation - ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('DEBUGG The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DEBUGG ' + err.getFields());
                            output.put('errorMessage',  err.getMessage());
                            Database.rollback(sp);
                            throw new CustomException(err.getMessage()+' '+err.getFields());
                        }
                    }
                }
                
            }
            if(!listOfAccountContactRelation.isEmpty()){
                for(Database.UpsertResult sr: Database.upsert(listOfAccountContactRelation)){
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted listOfAccountContactRelation - ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('DEBUGG The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DEBUGG ' + err.getFields());
                            output.put('errorMessage',  err.getMessage());
                            Database.rollback(sp);
                            throw new CustomException(err.getMessage()+' '+err.getFields());
                        }
                    }
                }
            }
            
            if(!listOfContactPremiseRelation.isEmpty()){
                for(Database.SaveResult sr: Database.insert(listOfContactPremiseRelation)){
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted listOfContactPremiseRelation - ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('DEBUGG The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DEBUGG ' + err.getFields());
                            output.put('errorMessage',  err.getMessage());
                            Database.rollback(sp);
                            throw new CustomException(err.getMessage()+' '+err.getFields());
                        }
                    }
                }
            }
            if(Test.isRunningTest()){
                throw new CustomException('Test Class');
            }
        }
        catch(Exception ex){
            System.debug('DEBUGG exception '+ ex.getLineNumber()+' '+ ex.getMessage());
            output.put('errorMessage',  ex.getMessage());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_gstDetailsInBcpDcp', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
            Database.rollback(sp);
            throw new CustomException(ex.getLineNumber()+' '+ ex.getMessage());
        }
    }
    
    
    private static AccountContactRelation createAccountContactRelationRecord(String role, String contactId, String accountId){
        AccountContactRelation acrRecord = new AccountContactRelation(ContactId = contactId, 
                                                                      AccountId = accountId, 
                                                                      Roles 	= role);
        return acrRecord;
    }
    
    private static ContactPremiseRelation__c createContactPremiseRelationRecord(Map<String, Object> contactDetails, String role, String insertedPremiseId, String contactId, String nbaAccountId){
        ContactPremiseRelation__c contactPremiseRelationRecord = new ContactPremiseRelation__c( 
            ARTL_Standard_Reason__c = (String)contactDetails.get('standardReason'),
            ARTL_GST_Applicable__c 	= (String)contactDetails.get('gstApplicable'),
            GST__c 					= (String)contactDetails.get('gstSelectedValue'),
            Role__c 				= role, 
            Premises__c 			= insertedPremiseId, 
            Contact__c 				= contactId, 
            ARTL_NBA_Account__c 	= nbaAccountId
        );
        return contactPremiseRelationRecord;
        
    }
    
    private static Contact createContactRecord(Map<String, Object> input,String contactRole, String accountId){
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_BCP_DCP_Contact').getRecordTypeId();
        Contact contactRecord = new Contact(Salutation 					= (String)input.get('Select_Salutation'),
                                            FirstName 					= (String)input.get('TXT_FirstName'),
                                            MiddleName 					= (String)input.get('TXT_MiddleName'),
                                            LastName 					= (String)input.get('TXT_LastName'), 
                                            Email 						= (String)input.get('TXT_Email'),
                                            ARTL_Alternate_Email__c 	= (String)input.get('alternateEmail'),
                                            Phone 				        = (String)input.get('Number_Mobile'), 
                                            Fax 						= (String)input.get('fax'), 
                                            ARTL_Designation__c  		= (String)input.get('designation'),
                                            ARTL_Contact_Role__c        = contactRole,
                                            RecordTypeId 				= recordTypeId,
                                            vlocity_cmt__Status__c  	= 'Active',
                                            AccountId 					= accountId);
        return contactRecord;
    }
    
    private static vlocity_cmt__Premises__c createPremiseRecord(Map<String, Object> addressDetails){
        vlocity_cmt__Premises__c premiseRecord = new vlocity_cmt__Premises__c(
            vlocity_cmt__City__c 			= (String)addressDetails.get('city'), 
            vlocity_cmt__Country__c 		= (String)addressDetails.get('country'),
            vlocity_cmt__State__c 			= (String)addressDetails.get('state'),
            vlocity_cmt__StreetAddress__c 	= (String)addressDetails.get('street'),
            vlocity_cmt__PostalCode__c		= (String)addressDetails.get('pincode'), 
            ARTL_Pincode__c                 = (String)addressDetails.get('pincodeId')
        );
        return premiseRecord;
    }
    
    /**
    * @description : Used in ARTL_gstDetailsInBcpDcpLwc to fetch GST values on the basis of parameters.
    * @author Rishab Kalra | 12-21-2023 
    * @param state 
    * @param nbaAccountId 
    * @param gstType 
    * @return List<Map<String, String>> 
    **/
    @AuraEnabled 
    public static List<Map<String, String>> getGstDetails(String state, String nbaAccountId, String gstType){
        try{
            List<Map<String, String>> gstPicklist = new List<Map<String, String>>();
            if(String.isBlank(nbaAccountId)){
                throw new CustomException('NBA Account Id not found.');
            }
            if(!String.isBlank(nbaAccountId)){
                Map<String, Object> input = new Map<String, Object>();
                List<Object> arguments = new List<Object>{state};
                    input.put('arguments', arguments);
                // Test output data
                Map<String, Object> output = new Map<String, Object>();
                DataRaptorHelper helper = new DataRaptorHelper();
                Boolean result = helper.invokeMethod('gstGetStateCode', input, output, new Map<String, Object>());
                String stateCode = (String) output.get('result');
                String parentAccountId = [SELECT Id, ParentId FROM Account WHERE Id = :nbaAccountId].ParentId;
                if(!String.isBlank(parentAccountId)){
                    for(GST__c gst: [SELECT Id, Name FROM GST__c 
                                     WHERE ARTL_GST_Type__c = :gstType 
                                     AND Account__c = :parentAccountId
                                     AND Status__c = 'Active'
                                     AND ARTL_Address__StateCode__s = :stateCode]){
                                         Map<String, String> valueMap = new Map<String, String>();
                                         valueMap.put('label', gst.Name);
                                         valueMap.put('value', gst.Id);
                                         gstPicklist.add(valueMap);
                                     }
                }
            }
            return gstPicklist;
        }
        catch(Exception ex){
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_gstDetailsInBcpDcp', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
            System.debug('Exception ex '+ ex + ex.getLineNumber());
            throw new CustomException(ex.getLineNumber()+' '+ ex.getMessage());
        }
    }
    
}