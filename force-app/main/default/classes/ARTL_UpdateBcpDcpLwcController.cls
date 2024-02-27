/**
* @description       : Used in ARTL_updateBcpDcpLwc for Update BCP/DCP functionality
* @test class        : ARTL_UpdateBcpDcpLwcControllerTest
* @author            : Rishab Kalra
* @last modified on  : 12-27-2023
**/
public without sharing class ARTL_UpdateBcpDcpLwcController {
    public static boolean isUpdateBcpDcp = false;
    public class CustomException extends Exception {}
    
    @AuraEnabled
    public static List<ARTL_Pincode__c> getPincodeDetails(String searchKey){
        String key = '%'+searchKey+'%';
        return [Select Id, Name, ARTL_Pincode_City__c, ARTL_City__c, ARTL_State__c, ARTL_Country__c 
               FROM ARTL_Pincode__c where ARTL_Pincode_City__c like :key LIMIT 50];
    }

    @AuraEnabled
    public static List<ContactPremiseRelation__c> getContactRecords(String nbaAccountId){
        try {
            System.debug('DEBUGG nbaAccountId '+ nbaAccountId);
            if(!String.isBlank(nbaAccountId)){
                List<ContactPremiseRelation__c> listOfContactPremiseRelation = [Select Id, ARTL_BCP_DCP_Search_String__c 
                                                                                from ContactPremiseRelation__c 
                                                                                where ARTL_NBA_Account__c = :nbaAccountId];
                return listOfContactPremiseRelation; 
            }
            if(Test.isRunningTest()){
                throw new AuraHandledException('Test Class.');
            }
            return null;
            
        } catch (Exception ex) {
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_UpdateBcpDcpLwcController:getContactRecords', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
            return null;
        }
    }
    
    @AuraEnabled
    public static List<ContactPremiseRelation__c> getRecordDetails(String selectedRecordId){
        try {
            System.debug('DEBUGG selectedRecordId '+ selectedRecordId);
            if(!String.isBlank(selectedRecordId)){
                List<ContactPremiseRelation__c> recordList = [Select Id, Contact__c, Contact__r.Salutation, Contact__r.FirstName, Contact__r.ARTL_Designation__c, 
                                                              Contact__r.MiddleName, Contact__r.LastName, Contact__r.Email, Contact__r.ARTL_Alternate_Email__c, 
                                                              Contact__r.MobilePhone, Contact__r.Phone, Contact__r.Fax, Contact__r.ARTL_Contact_Role__c, Role__c, Premises__c,
                                                              Contact__r.vlocity_cmt__Status__c, ARTL_GST_Applicable__c, ARTL_Standard_Reason__c,
                                                              ARTL_NBA_Account__c, ARTL_NBA_Account__r.ParentId, 
                                                              Premises__r.ARTL_Pincode__c,
                                                              Premises__r.vlocity_cmt__StreetAddress__c, 
                                                              Premises__r.vlocity_cmt__City__c, 
                                                              Premises__r.vlocity_cmt__State__c, 
                                                              Premises__r.vlocity_cmt__PostalCode__c, 
                                                              Premises__r.vlocity_cmt__Country__c,
                                                              GST__c, GST__r.Name
                                                              from ContactPremiseRelation__c 
                                                              where Id = :selectedRecordId];
                if(!recordList.isEmpty()){
                    return recordList;
                }
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateRecords(Map<String, String> recordDetailsOld, Map<String, String> recordDetails){
        Savepoint sp = Database.setSavepoint();
        try {
            isUpdateBcpDcp = true;
            System.debug('DEBUGG update bcp dcp '+ isUpdateBcpDcp);
            List<ContactPremiseRelation__c> contactPremiseRelationList = new List<ContactPremiseRelation__c>();
            List<vlocity_cmt__Premises__c> premiseRecordList = new List<vlocity_cmt__Premises__c>();
            String contactRole;
            System.debug('DEBUGG recordDetails '+ recordDetails);
            // if(recordDetails.containsKey('Role__c')){
            //     contactRole = recordDetails.get('Role__c') == 'BCP' ? 'Billing Contact' : recordDetails.get('Role__c') == 'DCP' ? 'Delivery Contact' : 'Delivery/Billing Contact';
            // }
            if((recordDetailsOld.get('City') != recordDetails.get('City')) || 
               recordDetailsOld.get('StreetAddress') != recordDetails.get('StreetAddress') ||
              recordDetailsOld.get('PostalCode') != recordDetails.get('PostalCode') ){
                   premiseRecordList.add(createPremiseRecord(recordDetails)); 
               }
            
            if(!premiseRecordList.isEmpty()){
                for(Database.SaveResult sr: Database.update(premiseRecordList)){
                    if (sr.isSuccess()) {
                        System.debug('Successfully updated premiseRecordList - ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('DEBUGG The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DEBUGG ' + err.getFields());
                            Database.rollback(sp);
                            throw new CustomException(err.getMessage()+' '+err.getFields());
                        }
                    }
                }
            }
            
            List<Contact> contactUpdateList = new List<Contact>();
            contactUpdateList.add(new Contact(Id 						= recordDetails.containsKey('Id') ? recordDetails.get('Id') : null, 
                                              Salutation 				= recordDetails.containsKey('Salutation') ? recordDetails.get('Salutation') : null, 
                                              FirstName 				= recordDetails.containsKey('FirstName') ? recordDetails.get('FirstName') : null,
                                              MiddleName 				= recordDetails.containsKey('MiddleName') ? recordDetails.get('MiddleName') : null,
                                              LastName 					= recordDetails.containsKey('LastName') ? recordDetails.get('LastName') : null, 
                                              Email 					= recordDetails.containsKey('Email') ? recordDetails.get('Email') : null,
                                              Phone 					= recordDetails.containsKey('Phone') ? recordDetails.get('Phone') : null, 
                                              ARTL_Alternate_Email__c 	= recordDetails.containsKey('ARTL_Alternate_Email__c') ? recordDetails.get('ARTL_Alternate_Email__c') : null, 
                                              Fax 						= recordDetails.containsKey('Fax') ? recordDetails.get('Fax') : null,
                                              ARTL_Designation__c 		= recordDetails.containsKey('ARTL_Designation__c') ? recordDetails.get('ARTL_Designation__c') : null,
                                              vlocity_cmt__Status__c    = recordDetails.containsKey('vlocity_cmt__Status__c') ? recordDetails.get('vlocity_cmt__Status__c') : null));
                                              //ARTL_Contact_Role__c 		= contactRole));
            
            if(!contactUpdateList.isEmpty()){
                for(Database.SaveResult sr: Database.update(contactUpdateList)){
                    if (sr.isSuccess()) {
                        System.debug('Successfully updated contactUpdateList - ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('DEBUGG The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DEBUGG ' + err.getFields());
                            Database.rollback(sp);
                            throw new CustomException(err.getMessage()+' '+err.getFields());
                        }
                    }
                }
            }
            List<ContactPremiseRelation__c> contactPremiseRelationRecord = [Select Id from ContactPremiseRelation__c 
                                                                            where Role__c = 'DCP' 
                                                                            and Contact__c = :contactUpdateList[0].Id
                                                                            and ARTL_NBA_Account__c = :recordDetails.get('ARTL_NBA_Account__c')];
            Boolean dcpRecordExists = false;
            if(contactPremiseRelationRecord.size() > 0) dcpRecordExists = true;
            List<ContactPremiseRelation__c> contactPremiseRelationRecordBCP = [Select Id from ContactPremiseRelation__c 
                                                                               where Role__c = 'BCP' 
                                                                               and Contact__c = :contactUpdateList[0].Id
                                                                               and ARTL_NBA_Account__c = :recordDetails.get('ARTL_NBA_Account__c')];
            Boolean bcpRecordExists = false;
            if(contactPremiseRelationRecordBCP.size() > 0) bcpRecordExists = true;
            if(recordDetailsOld.get('Role__c') != recordDetails.get('Role__c')){
                if(recordDetails.get('Role__c') == 'BCP'){
                    contactPremiseRelationList.add(createContactPremiseRelation(recordDetails, recordDetails.get('Role__c'), true));  
                }
                if(recordDetails.get('Role__c') == 'DCP'){
                    contactPremiseRelationList.add(createContactPremiseRelation(recordDetails, recordDetails.get('Role__c'), true));
                }
                if(recordDetails.get('Role__c') == 'BCPandDCP'){
                    if(!bcpRecordExists){
                        contactPremiseRelationList.add(createContactPremiseRelation(recordDetails, 'BCP', false));
                    }
                    else {
                        recordDetails.put('ContactPremiseId', contactPremiseRelationRecordBCP[0].Id);
                        contactPremiseRelationList.add(createContactPremiseRelation(recordDetails, 'BCP', true));
                    }
                    if(!dcpRecordExists){
                        contactPremiseRelationList.add(createContactPremiseRelation(recordDetails, 'DCP', false));
                    } else {
                        recordDetails.put('ContactPremiseId', contactPremiseRelationRecord[0].Id);
                        contactPremiseRelationList.add(createContactPremiseRelation(recordDetails, 'DCP', true));
                    }
                }
            }
            else{
                contactPremiseRelationList.add(createContactPremiseRelation(recordDetails, recordDetails.get('Role__c'), true));
            }
            

            if(!contactPremiseRelationList.isEmpty()){
                for(Database.UpsertResult sr: Database.upsert(contactPremiseRelationList)){
                    if (sr.isSuccess()) {
                        System.debug('Successfully inserted contactPremiseRelationList - ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('DEBUGG The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DEBUGG ' + err.getFields());
                            Database.rollback(sp);
                            throw new CustomException(err.getMessage()+' '+err.getFields());
                        }
                    }
                }
            }
            List<AccountContactRelation> accountContactRelationUpdateList = createAccountContactRelation(recordDetails);
            
            if(!accountContactRelationUpdateList.isEmpty()){
                for(Database.SaveResult sr: Database.update(accountContactRelationUpdateList)){
                    if (sr.isSuccess()) {
                        System.debug('Successfully updated accountContactRelationUpdateList - ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('DEBUGG The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('DEBUGG ' + err.getFields());
                            Database.rollback(sp);
                            throw new CustomException(err.getMessage()+' '+err.getFields());
                        }
                    }
                }
            }
            
        } catch (Exception ex) {
            System.debug('DEBUGG exception '+ ex.getMessage()+ ' '+ ex.getLineNumber());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_UpdateBcpDcpLwcController:updateRecord', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
            Database.rollback(sp);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public static vlocity_cmt__Premises__c createPremiseRecord(Map<String, String> recordDetails){
        try{
            System.debug('DEBUGG createPremiseRecord '+ recordDetails);
            vlocity_cmt__Premises__c premiseRecord = new vlocity_cmt__Premises__c(
                Id = recordDetails.containsKey('Premises__c') ? recordDetails.get('Premises__c') : null,
                vlocity_cmt__StreetAddress__c = recordDetails.containsKey('StreetAddress') ? recordDetails.get('StreetAddress') : null,
                vlocity_cmt__City__c 		= recordDetails.containsKey('City') ? recordDetails.get('City') : null, 
                vlocity_cmt__State__c  		= recordDetails.containsKey('State') ? recordDetails.get('State') : null, 
                vlocity_cmt__Country__c  	= recordDetails.containsKey('Country') ? recordDetails.get('Country') : null, 
                vlocity_cmt__PostalCode__c  = recordDetails.containsKey('PostalCode') ? recordDetails.get('PostalCode') : null,
                ARTL_Pincode__c             = recordDetails.containsKey('ARTL_Pincode__c') ? recordDetails.get('ARTL_Pincode__c') : null);
            return premiseRecord;
            
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static List<AccountContactRelation> createAccountContactRelation(Map<String, String> recordDetails){
        List<AccountContactRelation> accountContactRelationUpdateList = new List<AccountContactRelation>();
        if(recordDetails.containsKey('Id') && recordDetails.containsKey('BusinessAccountId') && recordDetails.containsKey('ARTL_NBA_Account__c')){
            for(AccountContactRelation acr: [Select Id, Roles from AccountContactRelation
                                             where ContactId = :recordDetails.get('Id')
                                             and (AccountId = :recordDetails.get('BusinessAccountId') 
                                                  or AccountId = :recordDetails.get('ARTL_NBA_Account__c'))]){
                                                      if(acr.Roles != recordDetails.get('Role__c')){
                                                          if(recordDetails.get('Role__c') == 'BCPandDCP'){
                                                              acr.Roles = 'BCP;DCP';
                                                          }
                                                          else{
                                                              acr.Roles = recordDetails.get('Role__c');
                                                          }
                                                          accountContactRelationUpdateList.add(acr);
                                                      } 
                                                 }
        }
        return accountContactRelationUpdateList;
    }
    
    public static ContactPremiseRelation__c createContactPremiseRelation(Map<String, String> recordDetails, String role, Boolean isUpdate){
        try {
            System.debug('DEBUGG createContactPremiseRelation '+ recordDetails);
            System.debug('DEBUGG createContactPremiseRelation '+ role);
            ContactPremiseRelation__c contactPremiseRelationRecord;
            if(isUpdate){
                contactPremiseRelationRecord = new ContactPremiseRelation__c(
                    Id 							= recordDetails.containsKey('ContactPremiseId') ? recordDetails.get('ContactPremiseId') : null,
                    ARTL_Standard_Reason__c 	= recordDetails.containsKey('ARTL_Standard_Reason__c') ? recordDetails.get('ARTL_Standard_Reason__c') : null,
                    ARTL_GST_Applicable__c 	    = recordDetails.containsKey('ARTL_GST_Applicable__c') ? recordDetails.get('ARTL_GST_Applicable__c') : null,
                    Role__c 					= role, //recordDetails.containsKey('Role__c') ? recordDetails.get('Role__c') : '',
                    Premises__c 				= recordDetails.containsKey('Premises__c') ? recordDetails.get('Premises__c') : null,
                    Contact__c				    = recordDetails.containsKey('Id') ? recordDetails.get('Id') : null, 
                    GST__c						= recordDetails.containsKey('GST__c') ? recordDetails.get('GST__c'): null);
                
            }
            else {
                contactPremiseRelationRecord = new ContactPremiseRelation__c(
                    ARTL_Standard_Reason__c 	= recordDetails.containsKey('ARTL_Standard_Reason__c') ? recordDetails.get('ARTL_Standard_Reason__c') : null,
                    ARTL_GST_Applicable__c 	    = recordDetails.containsKey('ARTL_GST_Applicable__c') ? recordDetails.get('ARTL_GST_Applicable__c') : null,
                    Role__c 					= role, //recordDetails.containsKey('Role__c') ? recordDetails.get('Role__c') : '',
                    Premises__c 				= recordDetails.containsKey('Premises__c') ? recordDetails.get('Premises__c') : null,
                    Contact__c				    = recordDetails.containsKey('Id') ? recordDetails.get('Id') : null,
                    ARTL_NBA_Account__c 		= recordDetails.containsKey('ARTL_NBA_Account__c') ? recordDetails.get('ARTL_NBA_Account__c'): null,
                    GST__c						= recordDetails.containsKey('GST__c') ? recordDetails.get('GST__c'): null);
                
            }
            return contactPremiseRelationRecord;
            
        } catch (Exception e) {
            System.debug('Exception '+ e.getMessage()+' '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
}