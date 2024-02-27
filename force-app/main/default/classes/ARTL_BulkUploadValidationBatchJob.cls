global class ARTL_BulkUploadValidationBatchJob implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {
    private String iterationId;
    private String type;
    List<Map<String,Object>> lstRequestRecords;
    List<String> fieldNames;
    List<String> fieldAPINames;
    String fieldQuery;
    Map<String,String> mapSource;
    public ARTL_Bulk_Upload_Config__mdt objMdt;
    Map<String, Schema.SObjectField> objectFields;
    public static final String OBJECT_STAGE = 'ARTL_Bulk_Upload_Staging__c';
    public List<String> lstFieldSet = new List<String>{'Account_Number__c','Type__c','ownerid','ownerId','name','isdeleted','lastactivitydate','CurrencyIsoCode'};
        
    public ARTL_BulkUploadValidationBatchJob(String iterationId, String type){
            this.iterationId = iterationId;
            this.type = type;
            objMdt = 
                [SELECT Field_API_Name__c 
                 FROM ARTL_Bulk_Upload_Config__mdt 
                 WHERE DeveloperName=:type]; 
            fieldNames = objMdt.Field_API_Name__c.split(',');
            //Need to add another field for API names of saving object field.
            objectFields = Schema.getGlobalDescribe().get(OBJECT_STAGE).getDescribe().fields.getMap();
           
            ARTL_Bulk_Upload_Config__mdt objMdtFields = 
                [SELECT Object_Fields__c  
                 FROM ARTL_Bulk_Upload_Config__mdt 
                 WHERE DeveloperName=:type]; 
            this.fieldQuery = objMdtFields.Object_Fields__c;
            fieldAPINames = objMdtFields.Object_Fields__c .split(',');
           
            mapSource = new Map<String,String>();
            for(Integer i=0;i<fieldNames.size();i++){
                mapSource.put(fieldAPINames[i],fieldNames[i]);
            }
           
        }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(!fieldQuery.contains('State__c')) {
            this.fieldQuery += ',State__c';
        }
        String query = 'SELECT '+fieldQuery+',Type__c,Id,Record_Id__c,Errors__c FROM ARTL_Bulk_Upload_Staging__c WHERE Type__c=:type AND ARTL_Bulk_Upload_Iteration__r.Id=:iterationId';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<ARTL_Bulk_Upload_Staging__c> scope){
        
        if(scope[0].Type__c == 'BUC'){
            Map<String,List<ARTL_Bulk_Upload_Staging__c>> mapAccountNumberToStage = new Map<String,List<ARTL_Bulk_Upload_Staging__c>>();
            for(ARTL_Bulk_Upload_Staging__c objStage : scope){
                if(objStage.Account_Number__c != null ){
                    List<ARTL_Bulk_Upload_Staging__c> lstStage = new List<ARTL_Bulk_Upload_Staging__c>();
                    if(mapAccountNumberToStage.containsKey(objStage.Account_Number__c))
                        lstStage = mapAccountNumberToStage.get(objStage.Account_Number__c);
                    
                    lstStage.add(objStage);
                    mapAccountNumberToStage.put(objStage.Account_Number__c, lstStage);
                }
            }
            for(Account objAccount: [SELECT Id,AccountNumber FROM Account WHERE AccountNumber IN:mapAccountNumberToStage.keyset()]){
                for(ARTL_Bulk_Upload_Staging__c objStage : mapAccountNumberToStage.get(objAccount.AccountNumber)){
                    objStage.Account_Name__c = objAccount.Id;
                }
                //mapAccountNumberToStage.get(objAccount.AccountNumber).Account_Name__c = objAccount.Id;
            }
            mapAccountNumberToStage.clear(); 
            
            for(ARTL_Bulk_Upload_Staging__c objStage : scope){
                if(objStage.Account_Plan__c != null ){
                    List<ARTL_Bulk_Upload_Staging__c> lstStage = new List<ARTL_Bulk_Upload_Staging__c>();
                    if(mapAccountNumberToStage.containsKey(objStage.Account_Plan__c))
                        lstStage = mapAccountNumberToStage.get(objStage.Account_Plan__c);
                    
                    lstStage.add(objStage);
                    mapAccountNumberToStage.put(objStage.Account_Plan__c, lstStage);
                }
            }
            for(Account_Plan__c objAccount: [SELECT Id,Name FROM Account_Plan__c WHERE Name IN:mapAccountNumberToStage.keyset()]){
                for(ARTL_Bulk_Upload_Staging__c objStage : mapAccountNumberToStage.get(objAccount.Name)){
                    objStage.Account_Plan__c = objAccount.Id;
                }
            }
            mapAccountNumberToStage.clear(); 
            
            for(ARTL_Bulk_Upload_Staging__c objStage : scope){
                if(objStage.Product_Category__c != null ){
                    List<ARTL_Bulk_Upload_Staging__c> lstStage = new List<ARTL_Bulk_Upload_Staging__c>();
                    if(mapAccountNumberToStage.containsKey(objStage.Product_Category__c))
                        lstStage = mapAccountNumberToStage.get(objStage.Product_Category__c);
                    
                    lstStage.add(objStage);
                    mapAccountNumberToStage.put(objStage.Product_Category__c, lstStage);
                }
            }
            for(Product2 objAccount: [SELECT Id,Name FROM Product2 WHERE Name IN:mapAccountNumberToStage.keyset()]){
                for(ARTL_Bulk_Upload_Staging__c objStage : mapAccountNumberToStage.get(objAccount.Name)){
                    objStage.Product_Category__c = objAccount.Id;
                }
            }
            lstRequestRecords = getRecordsMapped(scope);
            Map<String,Object> mapRequest = new Map<String,Object>{'records'=>lstRequestRecords, 'allOrNone'=>false};
            List<Object> response = sendInsertRequest(mapRequest);
            mapInsertResponseToStage(response, scope);
        }
        if(scope[0].Type__c == 'Quota'){
            Map<String,List<ARTL_Bulk_Upload_Staging__c>> mapOIMToStage = new Map<String,List<ARTL_Bulk_Upload_Staging__c>>();
            for(ARTL_Bulk_Upload_Staging__c objStage : scope){
                if(objStage.OIMID__c != null ){
                    List<ARTL_Bulk_Upload_Staging__c> lstStage = new List<ARTL_Bulk_Upload_Staging__c>();
                    if(mapOIMToStage.containsKey(objStage.OIMID__c))
                        lstStage = mapOIMToStage.get(objStage.OIMID__c);
                    
                    lstStage.add(objStage);
                    mapOIMToStage.put(objStage.OIMID__c, lstStage);
                }
            }
            for(User objAccount: [select OIM_Id__c, Id from User WHERE OIM_Id__c IN:mapOIMToStage.keyset()]){
                for(ARTL_Bulk_Upload_Staging__c objStage : mapOIMToStage.get(objAccount.OIM_Id__c)){
                    objStage.OIMID__c = objAccount.Id;
                } 
            }
            for(ARTL_Bulk_Upload_Staging__c objStage : scope){
                if(objStage.Forecast_Name__c != null ){
                    List<ARTL_Bulk_Upload_Staging__c> lstStage = new List<ARTL_Bulk_Upload_Staging__c>();
                    if(mapOIMToStage.containsKey(objStage.Forecast_Name__c))
                        lstStage = mapOIMToStage.get(objStage.Forecast_Name__c);
                    
                    lstStage.add(objStage);
                    mapOIMToStage.put(objStage.Forecast_Name__c, lstStage);
                }
            }
            for(ForecastingType objAccount: [select DeveloperName, Id from ForecastingType WHERE DeveloperName IN:mapOIMToStage.keyset()]){
                for(ARTL_Bulk_Upload_Staging__c objStage : mapOIMToStage.get(objAccount.DeveloperName)){
                    objStage.Forecast_Name__c = objAccount.Id;
                } 
            }
            mapOIMToStage.clear();
            lstRequestRecords = getQuotaRecordsMapped(scope);
            // List<Map<String,Object>> lstRequestRecords = getRecordsMapped(scope);
            Map<String,Object> mapRequest = new Map<String,Object>{'records'=>lstRequestRecords, 'allOrNone'=>false};
            List<Object> response = sendInsertRequest(mapRequest);
            mapInsertResponseToStage(response, scope);
           
        }
        
        
        if(scope[0].Type__c == 'BCPDCP_Contact') {
            Id bcpdcpContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_BCP_DCP_Contact').getRecordTypeId();
            Set<String> accountNumbers = new Set<String>();
            Set<String> gstNumbers = new Set<String>();
            //Set<String> bcpdcpNumbers = new Set<String>();
            Set<String> pincodeNumbers = new Set<String>();
            //Map<String,Id> lastNameAndEmailWithScopeRecordIds = new Map<String,Id>();
            Map<String,ARTL_Bulk_Upload_Staging__c> scopeMap = new Map<String,ARTL_Bulk_Upload_Staging__c>();
            for(ARTL_Bulk_Upload_Staging__c stagingRecord : scope){
                if(String.isNotBlank(stagingRecord.Pincode__c)) {
                    pincodeNumbers.add(stagingRecord.Pincode__c);
                }
                if(String.isNotBlank(stagingRecord.NBA_Account__c)) {
                    accountNumbers.add(stagingRecord.NBA_Account__c);
                }
                if(String.isNotBlank(stagingRecord.GST__c)) {
                    gstNumbers.add(stagingRecord.GST__c);
                }
                //if(String.isNotBlank(stagingRecord.BCP_DCP_Number__c)) {
                    //bcpdcpNumbers.add(stagingRecord.BCP_DCP_Number__c);
                //}
                //lastNameAndEmailWithScopeRecordIds.put(stagingRecord.Last_Name__c + ':' + stagingRecord.Email_Address__c, stagingRecord.Id);
                scopeMap.put(stagingRecord.Id, stagingRecord);
            }
            Map<String,String> accountNumberWithAccountId = new Map<String,String>();
            Map<String,Account> accountMap = new Map<String,Account>();
            for(Account accountRecord : [SElECT Id,Name,AccountNumber,ParentId,Parent.AccountNumber FROM Account WHERE AccountNumber in :accountNumbers and RecordType.DeveloperName='BillingAggregator']) {
                accountNumberWithAccountId.put(accountRecord.AccountNumber,accountRecord.Id);
                accountMap.put(accountRecord.Id,accountRecord);
            }
            Map<String,String> gstNumberWithId = new Map<String,String>();
            Map<String,GST__c> gstMap = new Map<String,GST__c>();
            for(GST__c gstRecord : [SELECT Id,Name FROM GST__c WHERE name in :gstNumbers]) {
                gstNumberWithId.put(gstRecord.Name,gstRecord.Id);
                gstMap.put(gstRecord.Id,gstRecord);
            }
            //Map<Id,ContactPremiseRelation__c> cprMap = new Map<Id,ContactPremiseRelation__c>();
            //Map<String,ContactPremiseRelation__c> bcpdcpNumberWithCPRRecord = new Map<String,ContactPremiseRelation__c>();
            //for(ContactPremiseRelation__c cprRecord : [SELECT Id,Contact__c,Premises__c,BCP_DCP_Number__c FROM ContactPremiseRelation__c WHERE BCP_DCP_Number__c in :bcpdcpNumbers]) {
                //cprMap.put(cprRecord.Id,cprRecord);
                //bcpdcpNumberWithCPRRecord.put(cprRecord.BCP_DCP_Number__c,cprRecord);
            //}
            Map<Id,ARTL_Pincode__c> pincodeMap = new Map<Id, ARTL_Pincode__c>();
            Map<String, ARTL_Pincode__c> pincodeCityAndRecordMap = new Map<String, ARTL_Pincode__c>();
            for(ARTL_Pincode__c pincodeRecord : [SELECT Id,Name,ARTL_City__c,ARTL_State__c,ARTL_Country__c FROM ARTL_Pincode__c WHERE Name in :pincodeNumbers]) {
                pincodeMap.put(pincodeRecord.Id,pincodeRecord);
                pincodeCityAndRecordMap.put(pincodeRecord.Name + '-' + String.valueOf(pincodeRecord.ARTL_City__c).toLowerCase(), pincodeRecord);
            }
            try {
                List<Contact> contactsToBeInserted = new List<Contact>();
                List<vlocity_cmt__Premises__c> premiseRecordsToBeInserted = new List<vlocity_cmt__Premises__c>();
                List<GST__c> gstRecordsToBeInserted = new List<GST__c>();
                for(ARTL_Bulk_Upload_Staging__c stagingRecord : scope) {
                    Contact contactRecord = new Contact();
                    contactRecord.RecordTypeId = bcpdcpContactRecordTypeId;
                    //contactRecord.Id = (String.isNotBlank(stagingRecord.BCP_DCP_Number__c) && bcpdcpNumberWithCPRRecord.containsKey(stagingRecord.BCP_DCP_Number__c)) ? bcpdcpNumberWithCPRRecord.get(stagingRecord.BCP_DCP_Number__c).Contact__c : null;
                    if(String.isNotBlank(stagingRecord.Salutation__c)) {
                    	contactRecord.Salutation = stagingRecord.Salutation__c;
                    }
                    if(String.isNotBlank(stagingRecord.First_Name__c)) {
                    	contactRecord.FirstName = stagingRecord.First_Name__c;
                    }
                    if(String.isNotBlank(stagingRecord.Last_Name__c)) {
                    	contactRecord.LastName = stagingRecord.Last_Name__c;
                    }
                    if(String.isNotBlank(stagingRecord.Middle_Name__c)) {
                    	contactRecord.MiddleName = stagingRecord.Middle_Name__c;
                    }
                    if(String.isNotBlank(stagingRecord.Designation__c)) {
                    	contactRecord.ARTL_Designation__c = stagingRecord.Designation__c;
                    }
                    if(String.isNotBlank(stagingRecord.Responsibility__c)) {
                    	contactRecord.ARTL_Contact_Role__c = stagingRecord.Responsibility__c;
                    }
                    if(String.isNotBlank(stagingRecord.Phone__c)) {
                    	contactRecord.Phone = stagingRecord.Phone__c;
                    }
                    if(String.isNotBlank(stagingRecord.Phone_Code__c)) {
                    	contactRecord.Country_Code__c = stagingRecord.Phone_Code__c;
                    }
                    if(String.isNotBlank(stagingRecord.Email_Address__c)) {
                    	contactRecord.Email = stagingRecord.Email_Address__c;
                    }
                    if(String.isNotBlank(stagingRecord.State__c)) {
                    	contactRecord.vlocity_cmt__Status__c = stagingRecord.State__c;
                    }
                    contactRecord.Staging_Record_Id__c = stagingRecord.Id;
                    // null check
                    if(String.isNotBlank(stagingRecord.NBA_Account__c) && accountNumberWithAccountId.containsKey(stagingRecord.NBA_Account__c)) {
                        contactRecord.AccountId = accountNumberWithAccountId.get(stagingRecord.NBA_Account__c);
                    }
                    contactsToBeInserted.add(contactRecord);
                    
                    vlocity_cmt__Premises__c premiseRecord = new vlocity_cmt__Premises__c();
                    premiseRecord.Staging_Record_Id__c = stagingRecord.Id;
                    //premiseRecord.Id = (String.isNotBlank(stagingRecord.BCP_DCP_Number__c) && bcpdcpNumberWithCPRRecord.containsKey(stagingRecord.BCP_DCP_Number__c)) ? bcpdcpNumberWithCPRRecord.get(stagingRecord.BCP_DCP_Number__c).Premises__c : null;
                    if(String.isNotBlank(stagingRecord.Address_Line_1__c)) {
                        String addressString = stagingRecord.Address_Line_1__c;
                        Integer maxLength = 255;
                        addressString = addressString.length() > maxLength ? addressString.substring(0, maxLength) : addressString;
                        premiseRecord.vlocity_cmt__StreetAddress__c = addressString;
                    }
                    
                    //premiseRecord.vlocity_cmt__Address1__c = stagingRecord.Address_Line_1__c;
                    //premiseRecord.vlocity_cmt__Address2__c = stagingRecord.Address_Line_2__c + ' ' + stagingRecord.Address_Line_3__c;
                    if(String.isNotBlank(stagingRecord.Pincode__c) && String.isNotBlank(stagingRecord.City__c)) {
                        String pincodeKey = stagingRecord.Pincode__c + '-' + String.valueOf(stagingRecord.City__c).toLowerCase();
                        ARTL_Pincode__c pincodeRecord = (pincodeCityAndRecordMap.containsKey(pincodeKey)) ? pincodeCityAndRecordMap.get(pincodeKey) : null;
                        if(pincodeRecord != null) {           
                            premiseRecord.ARTL_Pincode__c = pincodeRecord.Id;
                            premiseRecord.vlocity_cmt__PostalCode__c = pincodeRecord.Name;
                            premiseRecord.vlocity_cmt__City__c = pincodeRecord.ARTL_City__c;
                            premiseRecord.vlocity_cmt__State__c = pincodeRecord.ARTL_State__c;
                            premiseRecord.vlocity_cmt__Country__c = pincodeRecord.ARTL_Country__c;
                        }
                    }
                    premiseRecordsToBeInserted.add(premiseRecord);
                    
                    //if(!gstNumberWithId.containsKey(stagingRecord.GST__c)) {
                        //GST__c gstRecord = new GST__c();
                        //gstRecord.Name = stagingRecord.GST__c;
                        //gstRecordsToBeInserted.add(gstRecord);
                    //}
                }
                Map<Id,Contact> contactMap = new Map<Id,Contact>();
                Map<String,String> accountAndContactMap = new Map<String,String>();
                List<Database.SaveResult> contactSaveResults = Database.insert(contactsToBeInserted, false);
                for(Contact contactRecord : contactsToBeInserted) {
                    If(String.isNotBlank(contactRecord.Id)) {
                        contactMap.put(contactRecord.Id,contactRecord);
                        accountAndContactMap.put(contactRecord.Id,contactRecord.AccountId);
                    }
                }
                Map<Id,vlocity_cmt__Premises__c> premiseMap = new Map<Id,vlocity_cmt__Premises__c>();
                List<Database.SaveResult> premiseSaveResults = Database.insert(premiseRecordsToBeInserted, false);
                for(vlocity_cmt__Premises__c premiseRecord : premiseRecordsToBeInserted) {
                    If(String.isNotBlank(premiseRecord.Id)) {
                        premiseMap.put(premiseRecord.Id,premiseRecord);
                    }
                }
                //List<Database.SaveResult> gstSaveResults = Database.insert(gstRecordsToBeInserted, false);
                
                //for(GST__c gstRecord : gstRecordsToBeInserted) {
                    //gstMap.put(gstRecord.Id,gstRecord);
                    //gstNumberWithId.put(gstRecord.Name,gstRecord.Id);
                //}
                
                List<AccountContactRelation> accountContactRelationRecordsToBeInserted = new List<AccountContactRelation>();
                List<ContactPremiseRelation__c> contactPremiseRelationRecordsToBeInserted = new List<ContactPremiseRelation__c>();
                List<Contact> contactsToBeDeleted = new List<Contact>();
                List<vlocity_cmt__Premises__c> premisesToBeDeleted = new List<vlocity_cmt__Premises__c>();
                Map<Id,ARTL_Bulk_Upload_Staging__c> stagingRecordsFinalUpdateMap = new Map<Id,ARTL_Bulk_Upload_Staging__c>();
                for(Integer i=0;i<contactSaveResults.size();i++) {                        
                    String scopeRecordId = contactsToBeInserted[i].Staging_Record_Id__c;
                    if(contactSaveResults[i].isSuccess()) {
                        if(premiseSaveResults[i].isSuccess()) {
                            ARTL_Bulk_Upload_Staging__c scopeRecord = scopeMap.get(scopeRecordId);
                            
                            AccountContactRelation accountContactRelationRecord = new AccountContactRelation();
                            accountContactRelationRecord.ContactId = contactsToBeInserted[i].Id;
                            accountContactRelationRecord.AccountId = accountMap.get(accountNumberWithAccountId.get(scopeRecord.NBA_Account__c)).ParentId;
                            accountContactRelationRecord.Roles = scopeRecord.Customer_Type__c;
                            accountContactRelationRecordsToBeInserted.add(accountContactRelationRecord);
                            
                            ContactPremiseRelation__c contactPremiseRelationRecord = new ContactPremiseRelation__c();
                            //contactPremiseRelationRecord.Id = (String.isNotBlank(scopeRecord.BCP_DCP_Number__c) && bcpdcpNumberWithCPRRecord.containsKey(scopeRecord.BCP_DCP_Number__c)) ? bcpdcpNumberWithCPRRecord.get(scopeRecord.BCP_DCP_Number__c).Id : null;
                            
                            contactPremiseRelationRecord.Contact__c = contactsToBeInserted[i].Id;
                            contactPremiseRelationRecord.Premises__c = premiseRecordsToBeInserted[i].Id;
                            contactPremiseRelationRecord.ARTL_NBA_Account__c = contactsToBeInserted[i].AccountId;
                            
                            
                            if(String.isNotBlank(scopeRecord.GST__c)) {
                                contactPremiseRelationRecord.GST__c = gstNumberWithId.get(scopeRecord.GST__c);
                            }                                    
                            contactPremiseRelationRecord.ARTL_GST_Applicable__c = scopeRecord.GST_Applicable__c;
                            contactPremiseRelationRecord.ARTL_Standard_Reason__c = scopeRecord.Standard_Reason__c;
                            contactPremiseRelationRecord.Role__c = scopeRecord.Customer_Type__c;
                            
                            contactPremiseRelationRecordsToBeInserted.add(contactPremiseRelationRecord);
                        } else {
                            Contact contactRecord = new Contact();
                            contactRecord.Id = contactSaveResults[i].getId();
                            contactsToBeDeleted.add(contactRecord);
                            if(String.isNotBlank(scopeRecordId)) {
                                ARTL_Bulk_Upload_Staging__c scopeRecord = (stagingRecordsFinalUpdateMap.containsKey(scopeRecordId)) ? stagingRecordsFinalUpdateMap.get(scopeRecordId) : scopeMap.get(scopeRecordId);
                                String errorMessage = '';
                                if(scopeRecord.Errors__c == null) {
                                    scopeRecord.Errors__c = '';
                                }
                                for(Database.Error err : premiseSaveResults[i].getErrors()) {
                                    errorMessage += err.getMessage();
                                }
                                scopeRecord.Errors__c = errorMessage;
                                stagingRecordsFinalUpdateMap.put(scopeRecord.Id,scopeRecord);
                            }
                        }
                    } else {
                        //store errors in staging records
                        if(premiseSaveResults[i].isSuccess()) {
                            vlocity_cmt__Premises__c premiseRecordToBeDeleted = new vlocity_cmt__Premises__c();
                            premiseRecordToBeDeleted.Id = premiseRecordsToBeInserted[i].Id;
                            premisesToBeDeleted.add(premiseRecordToBeDeleted);
                        }
                        if(String.isNotBlank(scopeRecordId)) {
                            ARTL_Bulk_Upload_Staging__c scopeRecord = (stagingRecordsFinalUpdateMap.containsKey(scopeRecordId)) ? stagingRecordsFinalUpdateMap.get(scopeRecordId) : scopeMap.get(scopeRecordId);
                            String errorMessage = '';
                            if(scopeRecord.Errors__c == null) {
                                scopeRecord.Errors__c = '';
                            }
                            for(Database.Error err : contactSaveResults[i].getErrors()) {
                                errorMessage += err.getMessage();
                            }
                            scopeRecord.Errors__c = errorMessage;
                            System.debug('scopeRecord.Errors__c' + scopeRecord.Errors__c);
                            stagingRecordsFinalUpdateMap.put(scopeRecord.Id,scopeRecord);
                        }
                    }
                }
                List<Database.SaveResult> contactPremiseRelationSaveResult = Database.insert(contactPremiseRelationRecordsToBeInserted, false);
                List<Database.SaveResult> accountContactRelationSaveResult = Database.insert(accountContactRelationRecordsToBeInserted, false);
                for(Integer i=0;i<contactPremiseRelationSaveResult.size();i++) {
                    String relatedContactId = contactPremiseRelationRecordsToBeInserted[i].Contact__c;
                    Contact relatedContactRecord = contactMap.containsKey(relatedContactId) ? contactMap.get(relatedContactId) : new Contact();
                    String scopeRecordId = relatedContactRecord.Staging_Record_Id__c;
                    if(contactPremiseRelationSaveResult[i].isSuccess()) {
                        if(String.isNotBlank(scopeRecordId)) {
                            ARTL_Bulk_Upload_Staging__c scopeRecord = (stagingRecordsFinalUpdateMap.containsKey(scopeRecordId)) ? stagingRecordsFinalUpdateMap.get(scopeRecordId) : scopeMap.get(scopeRecordId);
                            scopeRecord.Record_Id__c = relatedContactRecord.Id;
                            stagingRecordsFinalUpdateMap.put(scopeRecord.Id,scopeRecord);
                        }
                    } else {
                        Contact contactRecord = new Contact();
                        contactRecord.Id = contactPremiseRelationRecordsToBeInserted[i].Contact__c;
                        contactsToBeDeleted.add(contactRecord);
                        vlocity_cmt__Premises__c premiseRecordToBeDeleted = new vlocity_cmt__Premises__c();
                        premiseRecordToBeDeleted.Id = contactPremiseRelationRecordsToBeInserted[i].Premises__c;
                        premisesToBeDeleted.add(premiseRecordToBeDeleted);
                        if(String.isNotBlank(scopeRecordId)) {
                            ARTL_Bulk_Upload_Staging__c scopeRecord = (stagingRecordsFinalUpdateMap.containsKey(scopeRecordId)) ? stagingRecordsFinalUpdateMap.get(scopeRecordId) : scopeMap.get(scopeRecordId);
                            String errorMessage = '';
                            if(scopeRecord.Errors__c == null) {
                                scopeRecord.Errors__c = '';
                            }
                            for(Database.Error err : contactPremiseRelationSaveResult[i].getErrors()) {
                                errorMessage += err.getMessage();
                            }
                            scopeRecord.Errors__c = errorMessage;
                            stagingRecordsFinalUpdateMap.put(scopeRecord.Id,scopeRecord);
                        }
                    }
                }
                List<AccountContactRelation> existingACRRecords = [SELECT Id,AccountId,ContactId,Roles FROM AccountContactRelation where accountId in :accountAndContactMap.values() and contactid in :accountAndContactMap.keySet()];
                List<AccountContactRelation> toUpdateACRRecords = new List<AccountContactRelation>();
                For(AccountContactRelation acrRecord : existingACRRecords) {
                    Contact relatedContactRecord = contactMap.get(acrRecord.ContactId);
                    String scopeRecordId = relatedContactRecord.Staging_Record_Id__c;
                    ARTL_Bulk_Upload_Staging__c scopeRecord = scopeMap.get(scopeRecordId);
                    acrRecord.Roles = scopeRecord.Customer_Type__c;
                    toUpdateACRRecords.add(acrRecord);
                }
                if(!toUpdateACRRecords.isEmpty()) {
                    Database.update(toUpdateACRRecords,false);
                }
                if(!contactsToBeDeleted.isEmpty()) {
                    Database.delete(contactsToBeDeleted,false);
                }
                if(!premisesToBeDeleted.isEmpty()) {
                    Database.delete(premisesToBeDeleted,false);
                }
                if(!stagingRecordsFinalUpdateMap.isEmpty()) {
                    Database.update(stagingRecordsFinalUpdateMap.values(),false);
                }
            } catch(Exception e) {
                ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_BulkUploadValidationBatchJob:invoke', '', new Map<String,Object>{'Exception'=>e.getMessage() , 'LineNumber' => e.getLineNumber(), 'StackTrace' => e.getStackTraceString() }, e);
                List<ARTL_Bulk_Upload_Staging__c> erroredStagingRecords = new List<ARTL_Bulk_Upload_Staging__c>();
                for(ARTL_Bulk_Upload_Staging__c stagingRecord : scope) {
                    if(String.isBlank(stagingRecord.Record_Id__c) && String.isBlank(stagingRecord.Errors__c)) {
                        stagingRecord.Errors__c = 'System Exception : Please contact your Airtel admin.';
                        erroredStagingRecords.add(stagingRecord);
                    }
                }
                Database.update(erroredStagingRecords,false);
            }
        }
        // for bcp dcp update contacts
        if(scope[0].Type__c == 'BCPDCP_Contact_Update') {
            ARTL_UpdateBcpDcpLwcController.isUpdateBcpDcp = true;
            //Id bcpdcpContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_BCP_DCP_Contact').getRecordTypeId();
            //Set<String> accountNumbers = new Set<String>();
            Set<String> gstNumbers = new Set<String>();
            Set<String> bcpdcpNumbers = new Set<String>();
            Set<String> pincodeNumbers = new Set<String>();
            //Map<String,Id> lastNameAndEmailWithScopeRecordIds = new Map<String,Id>();
            Map<String,ARTL_Bulk_Upload_Staging__c> scopeMap = new Map<String,ARTL_Bulk_Upload_Staging__c>();
            Map<Id,ARTL_Bulk_Upload_Staging__c> stagingRecordsFinalUpdateMap = new Map<Id,ARTL_Bulk_Upload_Staging__c>();
            List<ARTL_Bulk_Upload_Staging__c> scopeList = new List<ARTL_Bulk_Upload_Staging__c>();
            //List<String> standardReasonsWithGstNotRequired = new List<String>{'Exempt','Applied For','Zero Rated Supply- Export','Airtel- Foreign Legal Entity','Others','Exempt-Trust/Entities 12AA'};
            for(ARTL_Bulk_Upload_Staging__c stagingRecord : scope){
                if(String.isNotBlank(stagingRecord.Pincode__c)) {
                    pincodeNumbers.add(stagingRecord.Pincode__c);
                }
                //if(String.isNotBlank(stagingRecord.NBA_Account__c)) {
                    //accountNumbers.add(stagingRecord.NBA_Account__c);
                //}
                if(String.isNotBlank(stagingRecord.GST__c)) {
                    gstNumbers.add(stagingRecord.GST__c);
                }
                if(String.isNotBlank(stagingRecord.BCP_DCP_Number__c) && bcpdcpNumbers.contains(stagingRecord.BCP_DCP_Number__c)) {
                    stagingRecord.Errors__c = 'Duplicate contact in this list, please add only row per contact.';
                    stagingRecordsFinalUpdateMap.put(stagingRecord.Id,stagingRecord);
                    continue;
                }
                if(String.isNotBlank(stagingRecord.BCP_DCP_Number__c)) {
                    bcpdcpNumbers.add(stagingRecord.BCP_DCP_Number__c);
                    scopeList.add(stagingRecord);
                }
                //lastNameAndEmailWithScopeRecordIds.put(stagingRecord.Last_Name__c + ':' + stagingRecord.Email_Address__c, stagingRecord.Id);
                scopeMap.put(stagingRecord.Id, stagingRecord);
            }
            //Map<String,String> accountNumberWithAccountId = new Map<String,String>();
            //Map<String,Account> accountMap = new Map<String,Account>();
            //for(Account accountRecord : [SElECT Id,Name,AccountNumber,ParentId,Parent.AccountNumber FROM Account WHERE AccountNumber in :accountNumbers]) {
                //accountNumberWithAccountId.put(accountRecord.AccountNumber,accountRecord.Id);
                //accountMap.put(accountRecord.Id,accountRecord);
            //}
            Map<String,String> gstNumberWithId = new Map<String,String>();
            Map<String,GST__c> gstMap = new Map<String,GST__c>();
            for(GST__c gstRecord : [SELECT Id,Name FROM GST__c WHERE name in :gstNumbers]) {
                gstNumberWithId.put(gstRecord.Name,gstRecord.Id);
                gstMap.put(gstRecord.Id,gstRecord);
            }
            Map<Id,ContactPremiseRelation__c> cprMap = new Map<Id,ContactPremiseRelation__c>();
            Map<String,ContactPremiseRelation__c> bcpdcpNumberWithCPRRecord = new Map<String,ContactPremiseRelation__c>();
            Map<String,String> premiseIdWithCityMap = new Map<String,String>();
            for(ContactPremiseRelation__c cprRecord : [SELECT Id,Contact__c,Premises__c,BCP_DCP_Number__c,Premises__r.vlocity_cmt__City__c FROM ContactPremiseRelation__c WHERE BCP_DCP_Number__c in :bcpdcpNumbers]) {
                cprMap.put(cprRecord.Id,cprRecord);
                bcpdcpNumberWithCPRRecord.put(cprRecord.BCP_DCP_Number__c,cprRecord);
                premiseIdWithCityMap.put(cprRecord.Premises__c,cprRecord.Premises__r.vlocity_cmt__City__c);
            }
            Map<Id,ARTL_Pincode__c> pincodeMap = new Map<Id, ARTL_Pincode__c>();
            Map<String, ARTL_Pincode__c> pincodeCityAndRecordMap = new Map<String, ARTL_Pincode__c>();
            for(ARTL_Pincode__c pincodeRecord : [SELECT Id,Name,ARTL_City__c,ARTL_State__c,ARTL_Country__c FROM ARTL_Pincode__c WHERE Name in :pincodeNumbers]) {
                pincodeMap.put(pincodeRecord.Id,pincodeRecord);
                pincodeCityAndRecordMap.put(pincodeRecord.Name + '-' + String.valueOf(pincodeRecord.ARTL_City__c).toLowerCase(), pincodeRecord);
            }
            try {
                List<Contact> contactsToBeInserted = new List<Contact>();
                List<vlocity_cmt__Premises__c> premiseRecordsToBeInserted = new List<vlocity_cmt__Premises__c>();
                //List<GST__c> gstRecordsToBeInserted = new List<GST__c>();
                for(ARTL_Bulk_Upload_Staging__c stagingRecord : scopeList) {
                    Contact contactRecord = new Contact();
                    //contactRecord.RecordTypeId = bcpdcpContactRecordTypeId;
                    contactRecord.Id = (String.isNotBlank(stagingRecord.BCP_DCP_Number__c) && bcpdcpNumberWithCPRRecord.containsKey(stagingRecord.BCP_DCP_Number__c)) ? bcpdcpNumberWithCPRRecord.get(stagingRecord.BCP_DCP_Number__c).Contact__c : null;
                    
                    if(contactRecord.Id == null) {
                        stagingRecord.Errors__c = 'BCP/DCP Number not found. ';
                        stagingRecordsFinalUpdateMap.put(stagingRecord.Id,stagingRecord);
                    }

                    if(String.isNotBlank(stagingRecord.Salutation__c)) {
                    	contactRecord.Salutation = stagingRecord.Salutation__c;
                    }
                    if(String.isNotBlank(stagingRecord.First_Name__c)) {
                    	contactRecord.FirstName = stagingRecord.First_Name__c;
                    }
                    if(String.isNotBlank(stagingRecord.Last_Name__c)) {
                    	contactRecord.LastName = stagingRecord.Last_Name__c;
                    }
                    if(String.isNotBlank(stagingRecord.Middle_Name__c)) {
                    	contactRecord.MiddleName = stagingRecord.Middle_Name__c;
                    }
                    if(String.isNotBlank(stagingRecord.Designation__c)) {
                    	contactRecord.ARTL_Designation__c = stagingRecord.Designation__c;
                    }
                    if(String.isNotBlank(stagingRecord.Responsibility__c)) {
                    	contactRecord.ARTL_Contact_Role__c = stagingRecord.Responsibility__c;
                    }
                    if(String.isNotBlank(stagingRecord.Phone__c)) {
                    	contactRecord.Phone = stagingRecord.Phone__c;
                    }
                    if(String.isNotBlank(stagingRecord.Phone_Code__c)) {
                    	contactRecord.Country_Code__c = stagingRecord.Phone_Code__c;
                    }
                    if(String.isNotBlank(stagingRecord.Email_Address__c)) {
                    	contactRecord.Email = stagingRecord.Email_Address__c;
                    }
                    if(String.isNotBlank(stagingRecord.State__c)) {
                    	contactRecord.vlocity_cmt__Status__c = stagingRecord.State__c;
                    }
                    contactRecord.Staging_Record_Id__c = stagingRecord.Id;
                    // null check
                    //if(String.isNotBlank(stagingRecord.NBA_Account__c) && accountNumberWithAccountId.containsKey(stagingRecord.NBA_Account__c)) {
                        //contactRecord.AccountId = accountNumberWithAccountId.get(stagingRecord.NBA_Account__c);
                    //}
                    contactsToBeInserted.add(contactRecord);
                    
                    vlocity_cmt__Premises__c premiseRecord = new vlocity_cmt__Premises__c();
                    premiseRecord.Id = (String.isNotBlank(stagingRecord.BCP_DCP_Number__c) && bcpdcpNumberWithCPRRecord.containsKey(stagingRecord.BCP_DCP_Number__c)) ? bcpdcpNumberWithCPRRecord.get(stagingRecord.BCP_DCP_Number__c).Premises__c : null;
                    premiseRecord.Staging_Record_Id__c = stagingRecord.Id;
                    if(String.isNotBlank(stagingRecord.Address_Line_1__c)) {
                        String addressString = stagingRecord.Address_Line_1__c;
                        Integer maxLength = 255;
                        addressString = addressString.length() > maxLength ? addressString.substring(0, maxLength) : addressString;
                        premiseRecord.vlocity_cmt__StreetAddress__c = addressString;
                    }
                    
                    //premiseRecord.vlocity_cmt__Address1__c = stagingRecord.Address_Line_1__c;
                    //premiseRecord.vlocity_cmt__Address2__c = stagingRecord.Address_Line_2__c + ' ' + stagingRecord.Address_Line_3__c;
                    if(String.isNotBlank(stagingRecord.Pincode__c)) {
                        String cityName = premiseIdWithCityMap.get(premiseRecord.Id);
                        String pincodeKey = stagingRecord.Pincode__c + '-' + cityName?.toLowerCase();
                        ARTL_Pincode__c pincodeRecord = (pincodeCityAndRecordMap.containsKey(pincodeKey)) ? pincodeCityAndRecordMap.get(pincodeKey) : null;
                        if(pincodeRecord != null && String.isNotBlank(stagingRecord.Pincode__c)) {    
                            premiseRecord.ARTL_Pincode__c = pincodeRecord.Id;
                            premiseRecord.vlocity_cmt__PostalCode__c = pincodeRecord.Name;
                            premiseRecord.vlocity_cmt__City__c = pincodeRecord.ARTL_City__c;
                            premiseRecord.vlocity_cmt__State__c = pincodeRecord.ARTL_State__c;
                            premiseRecord.vlocity_cmt__Country__c = pincodeRecord.ARTL_Country__c;
                        } 
                        if(String.isNotBlank(stagingRecord.Pincode__c) && pincodeRecord == null){
                            premiseRecord.vlocity_cmt__PostalCode__c = null;
                        }
                    }
                    premiseRecordsToBeInserted.add(premiseRecord);
                    
                    //if(!gstNumberWithId.containsKey(stagingRecord.GST__c)) {
                        //GST__c gstRecord = new GST__c();
                        //gstRecord.Name = stagingRecord.GST__c;
                        //gstRecordsToBeInserted.add(gstRecord);
                    //}
                }
                Map<Id,Contact> contactMap = new Map<Id,Contact>();
                Map<String,String> accountAndContactMap = new Map<String,String>();
                List<Database.SaveResult> contactSaveResults = Database.update(contactsToBeInserted, false);
                for(Contact contactRecord : contactsToBeInserted) {
                    If(String.isNotBlank(contactRecord.Id)) {
                        contactMap.put(contactRecord.Id,contactRecord);
                        accountAndContactMap.put(contactRecord.Id,contactRecord.AccountId);
                    }
                }
                Map<Id,vlocity_cmt__Premises__c> premiseMap = new Map<Id,vlocity_cmt__Premises__c>();
                List<Database.SaveResult> premiseSaveResults = Database.update(premiseRecordsToBeInserted, false);
                for(vlocity_cmt__Premises__c premiseRecord : premiseRecordsToBeInserted) {
                    If(String.isNotBlank(premiseRecord.Id)) {
                        premiseMap.put(premiseRecord.Id,premiseRecord);
                    }
                }
                //List<Database.SaveResult> gstSaveResults = Database.insert(gstRecordsToBeInserted, false);
                
                //for(GST__c gstRecord : gstRecordsToBeInserted) {
                    //gstMap.put(gstRecord.Id,gstRecord);
                    //gstNumberWithId.put(gstRecord.Name,gstRecord.Id);
                //}
                
                //List<AccountContactRelation> accountContactRelationRecordsToBeInserted = new List<AccountContactRelation>();
                List<ContactPremiseRelation__c> contactPremiseRelationRecordsToBeInserted = new List<ContactPremiseRelation__c>();
                //List<Contact> contactsToBeDeleted = new List<Contact>();
                //List<vlocity_cmt__Premises__c> premisesToBeDeleted = new List<vlocity_cmt__Premises__c>();
                
                for(Integer i=0;i<contactSaveResults.size();i++) {                        
                    String scopeRecordId = contactsToBeInserted[i].Staging_Record_Id__c;
                    if(contactSaveResults[i].isSuccess()) {
                        if(premiseSaveResults[i].isSuccess()) {
                            ARTL_Bulk_Upload_Staging__c scopeRecord = scopeMap.get(scopeRecordId);
                            //if(String.isBlank(scopeRecord.BCP_DCP_Number__c)) {
                                //AccountContactRelation accountContactRelationRecord = new AccountContactRelation();
                                //accountContactRelationRecord.ContactId = contactsToBeInserted[i].Id;
                                //accountContactRelationRecord.AccountId = accountMap.get(accountNumberWithAccountId.get(scopeRecord.NBA_Account__c)).ParentId;
                                //accountContactRelationRecord.Roles = scopeRecord.Customer_Type__c;
                                //accountContactRelationRecordsToBeInserted.add(accountContactRelationRecord);
                            //}
                            ContactPremiseRelation__c contactPremiseRelationRecord = (String.isNotBlank(scopeRecord.BCP_DCP_Number__c) && bcpdcpNumberWithCPRRecord.containsKey(scopeRecord.BCP_DCP_Number__c)) ? bcpdcpNumberWithCPRRecord.get(scopeRecord.BCP_DCP_Number__c) : new ContactPremiseRelation__c();
                            contactPremiseRelationRecord.Id = (String.isNotBlank(scopeRecord.BCP_DCP_Number__c) && bcpdcpNumberWithCPRRecord.containsKey(scopeRecord.BCP_DCP_Number__c)) ? bcpdcpNumberWithCPRRecord.get(scopeRecord.BCP_DCP_Number__c).Id : null;
                            //if(String.isBlank(scopeRecord.BCP_DCP_Number__c)) {
                                //contactPremiseRelationRecord.Contact__c = contactsToBeInserted[i].Id;
                                //contactPremiseRelationRecord.Premises__c = premiseRecordsToBeInserted[i].Id;
                                //contactPremiseRelationRecord.ARTL_NBA_Account__c = contactsToBeInserted[i].AccountId;
                            //}
                            if(String.isNotBlank(scopeRecordId)) {
                                if(String.isNotBlank(scopeRecord.GST__c)) {
                                    contactPremiseRelationRecord.GST__c = gstNumberWithId.get(scopeRecord.GST__c);
                                }
                                //if(standardReasonsWithGstNotRequired.contains(scopeRecord.Standard_Reason__c)) {
                                    //contactPremiseRelationRecord.GST__c = gstNumberWithId.get(scopeRecord.GST__c);
                                //}
                                if(String.isNotBlank(scopeRecord.GST_Applicable__c)) {
                                    contactPremiseRelationRecord.ARTL_GST_Applicable__c = scopeRecord.GST_Applicable__c;
                                }
                                if(String.isNotBlank(scopeRecord.Standard_Reason__c)) {
                                    contactPremiseRelationRecord.ARTL_Standard_Reason__c = scopeRecord.Standard_Reason__c;
                                }
                                //contactPremiseRelationRecord.Role__c = scopeRecord.Customer_Type__c;
                            }
                            contactPremiseRelationRecordsToBeInserted.add(contactPremiseRelationRecord);
                        } else {
                            //Contact contactRecord = new Contact();
                            //contactRecord.Id = contactSaveResults[i].getId();
                            //contactsToBeDeleted.add(contactRecord);
                            if(String.isNotBlank(scopeRecordId)) {
                                ARTL_Bulk_Upload_Staging__c scopeRecord = (stagingRecordsFinalUpdateMap.containsKey(scopeRecordId)) ? stagingRecordsFinalUpdateMap.get(scopeRecordId) : scopeMap.get(scopeRecordId);
                                String errorMessage = '';
                                if(scopeRecord.Errors__c == null) {
                                    scopeRecord.Errors__c = '';
                                }
                                for(Database.Error err : premiseSaveResults[i].getErrors()) {
                                    errorMessage += err.getMessage();
                                }
                                scopeRecord.Errors__c = errorMessage;
                                stagingRecordsFinalUpdateMap.put(scopeRecord.Id,scopeRecord);
                            }
                        }
                    } else {
                        //store errors in staging records
                        //if(premiseSaveResults[i].isSuccess()) {
                            //vlocity_cmt__Premises__c premiseRecordToBeDeleted = new vlocity_cmt__Premises__c();
                            //premiseRecordToBeDeleted.Id = premiseRecordsToBeInserted[i].Id;
                            //premisesToBeDeleted.add(premiseRecordToBeDeleted);
                        if(String.isNotBlank(scopeRecordId)) {
                            ARTL_Bulk_Upload_Staging__c scopeRecord = (stagingRecordsFinalUpdateMap.containsKey(scopeRecordId)) ? stagingRecordsFinalUpdateMap.get(scopeRecordId) : scopeMap.get(scopeRecordId);
                            String errorMessage = '';
                            if(scopeRecord.Errors__c == null) {
                                scopeRecord.Errors__c = '';
                            }
                            for(Database.Error err : contactSaveResults[i].getErrors()) {
                                errorMessage += err.getMessage();
                            }
                            scopeRecord.Errors__c = errorMessage;
                            stagingRecordsFinalUpdateMap.put(scopeRecord.Id,scopeRecord);
                        }
                        //}
                        
                    }
                }
                List<Database.SaveResult> contactPremiseRelationSaveResult = Database.update(contactPremiseRelationRecordsToBeInserted, false);
                //List<Database.SaveResult> accountContactRelationSaveResult = Database.insert(accountContactRelationRecordsToBeInserted, false);
                for(Integer i=0;i<contactPremiseRelationSaveResult.size();i++) {
                    String relatedContactId = contactPremiseRelationRecordsToBeInserted[i].Contact__c;
                    Contact relatedContactRecord = contactMap.containsKey(relatedContactId) ? contactMap.get(relatedContactId) : new Contact();
                    String scopeRecordId = relatedContactRecord.Staging_Record_Id__c;
                    if(contactPremiseRelationSaveResult[i].isSuccess()) {
                        if(String.isNotBlank(scopeRecordId)) {
                            ARTL_Bulk_Upload_Staging__c scopeRecord = (stagingRecordsFinalUpdateMap.containsKey(scopeRecordId)) ? stagingRecordsFinalUpdateMap.get(scopeRecordId) : scopeMap.get(scopeRecordId);
                            scopeRecord.Record_Id__c = relatedContactRecord.Id;
                            stagingRecordsFinalUpdateMap.put(scopeRecord.Id,scopeRecord);
                        }
                    } else {
                        //Contact contactRecord = new Contact();
                        //contactRecord.Id = contactPremiseRelationRecordsToBeInserted[i].Contact__c;
                        //contactsToBeDeleted.add(contactRecord);
                        //vlocity_cmt__Premises__c premiseRecordToBeDeleted = new vlocity_cmt__Premises__c();
                        //premiseRecordToBeDeleted.Id = contactPremiseRelationRecordsToBeInserted[i].Premises__c;
                        //premisesToBeDeleted.add(premiseRecordToBeDeleted);
                        if(String.isNotBlank(scopeRecordId)) {
                            ARTL_Bulk_Upload_Staging__c scopeRecord = (stagingRecordsFinalUpdateMap.containsKey(scopeRecordId)) ? stagingRecordsFinalUpdateMap.get(scopeRecordId) : scopeMap.get(scopeRecordId);
                            String errorMessage = '';
                            if(scopeRecord.Errors__c == null) {
                                scopeRecord.Errors__c = '';
                            }
                            for(Database.Error err : contactPremiseRelationSaveResult[i].getErrors()) {
                                errorMessage += err.getMessage();
                            }
                            scopeRecord.Errors__c = errorMessage;
                            stagingRecordsFinalUpdateMap.put(scopeRecord.Id,scopeRecord);
                        }
                    }
                }
                if(!stagingRecordsFinalUpdateMap.isEmpty()) {
                    Database.update(stagingRecordsFinalUpdateMap.values(),false);
                }
            } catch(Exception e) {
                ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_BulkUploadValidationBatchJob:invoke', '', new Map<String,Object>{'Exception'=>e.getMessage() , 'LineNumber' => e.getLineNumber(), 'StackTrace' => e.getStackTraceString() }, e);
                List<ARTL_Bulk_Upload_Staging__c> erroredStagingRecords = new List<ARTL_Bulk_Upload_Staging__c>();
                for(ARTL_Bulk_Upload_Staging__c stagingRecord : scope) {
                    if(String.isBlank(stagingRecord.Record_Id__c) && String.isBlank(stagingRecord.Errors__c)) {
                        stagingRecord.Errors__c = 'System Exception : Please contact your Airtel admin.';
                        erroredStagingRecords.add(stagingRecord);
                    }
                }
                Database.update(erroredStagingRecords,false);
            }
        }
        
      	// insert for party contacts
        if(scope[0].Type__c == 'Party_Contact') {
            Id partyRecordRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_Party_Contact').getRecordTypeId();
            Set<String> accountNumbers = new Set<String>();
            //Map<String,Id> lastNameAndEmailWithScopeRecordIds = new Map<String,Id>();
            Map<String,ARTL_Bulk_Upload_Staging__c> scopeMap = new Map<String,ARTL_Bulk_Upload_Staging__c>();
            //Set<String> contactNumbers = new Set<String>();
            for(ARTL_Bulk_Upload_Staging__c stagingRecord : scope){
                if(String.isNotBlank(stagingRecord.Parent_Account__c)) {
                    accountNumbers.add(stagingRecord.Parent_Account__c);
                }
                //if(String.isNotBlank(stagingRecord.Contact_Number__c)) {
                    //contactNumbers.add(stagingRecord.Contact_Number__c);
                //}
                //lastNameAndEmailWithScopeRecordIds.put(stagingRecord.Last_Name__c + ':' + stagingRecord.Email_Address__c, stagingRecord.Id);
                scopeMap.put(stagingRecord.Id, stagingRecord);
            }
            Map<String,String> accountNumberWithAccountId = new Map<String,String>();
            Map<String,Account> accountMap = new Map<String,Account>();
            for(Account accountRecord : [SElECT Id,Name,AccountNumber FROM Account WHERE AccountNumber in :accountNumbers AND RecordType.DeveloperName='Business']) {
                accountNumberWithAccountId.put(accountRecord.AccountNumber,accountRecord.Id);
                accountMap.put(accountRecord.Id,accountRecord);
            }
            //Map<Id,Contact> contactMap = new Map<Id,Contact>();
            //Map<String,Contact> contactNumbersWithContactMap = new Map<String,Contact>();
            //for(Contact contactRecord : [SELECT Id,Name,ARTL_External_Contact_Number__c FROM Contact WHERE ARTL_External_Contact_Number__c in :contactNumbers]) {
                //contactMap.put(contactRecord.Id,contactRecord);
                //contactNumbersWithContactMap.put(contactRecord.ARTL_External_Contact_Number__c,contactRecord);
            //}
            try {
                List<Contact> contactsToBeInserted = new List<Contact>();
                for(ARTL_Bulk_Upload_Staging__c stagingRecord : scope) {
                    Contact contactRecord = new Contact();
                    //contactRecord.Id = (String.isNotBlank(stagingRecord.Contact_Number__c) && contactNumbersWithContactMap.containsKey(stagingRecord.Contact_Number__c)) ? contactNumbersWithContactMap.get(stagingRecord.Contact_Number__c).Id : null;
                    contactRecord.RecordTypeId = partyRecordRecordTypeId;
                    if(String.isNotBlank(stagingRecord.Salutation__c)) {
                    	contactRecord.Salutation = stagingRecord.Salutation__c;
                    }
                    if(String.isNotBlank(stagingRecord.First_Name__c)) {
                    	contactRecord.FirstName = stagingRecord.First_Name__c;
                    }
                    if(String.isNotBlank(stagingRecord.Last_Name__c)) {
                    	contactRecord.LastName = stagingRecord.Last_Name__c;
                    }
                    if(String.isNotBlank(stagingRecord.Middle_Name__c)) {
                    	contactRecord.MiddleName = stagingRecord.Middle_Name__c;
                    }
                    if(String.isNotBlank(stagingRecord.Designation__c)) {
                    	contactRecord.ARTL_Designation__c = stagingRecord.Designation__c;
                    }
                    if(String.isNotBlank(stagingRecord.Responsibility__c)) {
                    	contactRecord.ARTL_Contact_Role__c = stagingRecord.Responsibility__c;
                    }
                    if(String.isNotBlank(stagingRecord.Phone__c)) {
                    	contactRecord.Phone = stagingRecord.Phone__c;
                    }
                    if(String.isNotBlank(stagingRecord.Phone_Code__c)) {
                    	contactRecord.Country_Code__c = stagingRecord.Phone_Code__c;
                    }
                    if(String.isNotBlank(stagingRecord.Email_Address__c)) {
                    	contactRecord.Email = stagingRecord.Email_Address__c;
                    }
                    contactRecord.Staging_Record_Id__c = stagingRecord.Id;
                    if(String.isNotBlank(stagingRecord.Parent_Account__c) && accountNumberWithAccountId.containsKey(stagingRecord.Parent_Account__c)) {
                        contactRecord.AccountId = accountNumberWithAccountId.get(stagingRecord.Parent_Account__c);
                    }
                    contactsToBeInserted.add(contactRecord);
                }
                List<Database.SaveResult> contactSaveResults = Database.insert(contactsToBeInserted, false);

                Map<Id,ARTL_Bulk_Upload_Staging__c> stagingRecordsFinalUpdateMap = new Map<Id,ARTL_Bulk_Upload_Staging__c>();
                for(Integer i=0;i<contactSaveResults.size();i++) {
                    String scopeRecordId = contactsToBeInserted[i].Staging_Record_Id__c;
                    if(String.isNotBlank(scopeRecordId)) {
                        ARTL_Bulk_Upload_Staging__c stagingRecord = (stagingRecordsFinalUpdateMap.containsKey(scopeRecordId)) ? stagingRecordsFinalUpdateMap.get(scopeRecordId) : scopeMap.get(scopeRecordId);
                        if(contactSaveResults[i].isSuccess()) {
                            stagingRecord.Record_Id__c = contactSaveResults[i].getId();
                        } else {
                            String errorMessage = '';
                            for(Database.Error err : contactSaveResults[i].getErrors()) {
                                errorMessage += err.getMessage();
                            }
                            stagingRecord.Errors__c = errorMessage;
                        }
                        stagingRecordsFinalUpdateMap.put(stagingRecord.Id,stagingRecord);
                    }
                }
                if(!stagingRecordsFinalUpdateMap.isEmpty()) {
                    Database.update(stagingRecordsFinalUpdateMap.values(),false);
                }
            } catch (Exception e) {
                ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_BulkUploadValidationBatchJob:invoke', '', new Map<String,Object>{'Exception'=>e.getMessage() , 'LineNumber' => e.getLineNumber(), 'StackTrace' => e.getStackTraceString() }, e);
                List<ARTL_Bulk_Upload_Staging__c> erroredStagingRecords = new List<ARTL_Bulk_Upload_Staging__c>();
                for(ARTL_Bulk_Upload_Staging__c stagingRecord : scope) {
                    if(String.isBlank(stagingRecord.Record_Id__c) && String.isBlank(stagingRecord.Errors__c)) {
                        stagingRecord.Errors__c = 'System Exception : Please contact your Airtel admin.';
                        erroredStagingRecords.add(stagingRecord);
                    }
                }
                Database.update(erroredStagingRecords,false);
            }
        }
        //update for party contacts
        if(scope[0].Type__c == 'Party_Contact_Update') {
            //Id partyRecordRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_Party_Contact').getRecordTypeId();
            //Set<String> accountNumbers = new Set<String>();
            //Map<String,Id> lastNameAndEmailWithScopeRecordIds = new Map<String,Id>();
            Map<String,ARTL_Bulk_Upload_Staging__c> scopeMap = new Map<String,ARTL_Bulk_Upload_Staging__c>();
            Set<String> contactNumbers = new Set<String>();
            Map<Id,ARTL_Bulk_Upload_Staging__c> stagingRecordsFinalUpdateMap = new Map<Id,ARTL_Bulk_Upload_Staging__c>();
            List<ARTL_Bulk_Upload_Staging__c> scopeList = new List<ARTL_Bulk_Upload_Staging__c>();
            for(ARTL_Bulk_Upload_Staging__c stagingRecord : scope){
                //if(String.isNotBlank(stagingRecord.Parent_Account__c)) {
                    //accountNumbers.add(stagingRecord.Parent_Account__c);
                //}
                if(String.isNotBlank(stagingRecord.Contact_Number__c) && contactNumbers.contains(stagingRecord.Contact_Number__c)) {
                    stagingRecord.Errors__c = 'Duplicate contact in this list, please add only row per contact.';
                    stagingRecordsFinalUpdateMap.put(stagingRecord.Id,stagingRecord);
                    continue;
                }
                if(String.isNotBlank(stagingRecord.Contact_Number__c)) {
                    contactNumbers.add(stagingRecord.Contact_Number__c);
                    scopeList.add(stagingRecord);
                }
                //lastNameAndEmailWithScopeRecordIds.put(stagingRecord.Last_Name__c + ':' + stagingRecord.Email_Address__c, stagingRecord.Id);
                scopeMap.put(stagingRecord.Id, stagingRecord);
            }
            //Map<String,String> accountNumberWithAccountId = new Map<String,String>();
            //Map<String,Account> accountMap = new Map<String,Account>();
            //for(Account accountRecord : [SElECT Id,Name,AccountNumber FROM Account WHERE AccountNumber in :accountNumbers]) {
                //accountNumberWithAccountId.put(accountRecord.AccountNumber,accountRecord.Id);
                //accountMap.put(accountRecord.Id,accountRecord);
            //}
            Map<Id,Contact> contactMap = new Map<Id,Contact>();
            Map<String,Contact> contactNumbersWithContactMap = new Map<String,Contact>();
            for(Contact contactRecord : [SELECT Id,Name,ARTL_External_Contact_Number__c FROM Contact WHERE ARTL_External_Contact_Number__c in :contactNumbers]) {
                contactMap.put(contactRecord.Id,contactRecord);
                contactNumbersWithContactMap.put(contactRecord.ARTL_External_Contact_Number__c,contactRecord);
            }
            try {
                List<Contact> contactsToBeInserted = new List<Contact>();
                for(ARTL_Bulk_Upload_Staging__c stagingRecord : scopeList) {
                    Contact contactRecord = new Contact();
                    contactRecord.Id = (String.isNotBlank(stagingRecord.Contact_Number__c) && contactNumbersWithContactMap.containsKey(stagingRecord.Contact_Number__c)) ? contactNumbersWithContactMap.get(stagingRecord.Contact_Number__c).Id : null;
                    //contactRecord.RecordTypeId = partyRecordRecordTypeId;
                    if(contactRecord.Id == null) {
                        stagingRecord.Errors__c = 'Contact not found. ';
                        stagingRecordsFinalUpdateMap.put(stagingRecord.Id,stagingRecord);
                    }
                    if(String.isNotBlank(stagingRecord.Salutation__c)) {
                    	contactRecord.Salutation = stagingRecord.Salutation__c;
                    }
                    if(String.isNotBlank(stagingRecord.First_Name__c)) {
                    	contactRecord.FirstName = stagingRecord.First_Name__c;
                    }
                    if(String.isNotBlank(stagingRecord.Last_Name__c)) {
                    	contactRecord.LastName = stagingRecord.Last_Name__c;
                    }
                    if(String.isNotBlank(stagingRecord.Middle_Name__c)) {
                    	contactRecord.MiddleName = stagingRecord.Middle_Name__c;
                    }
                    if(String.isNotBlank(stagingRecord.Designation__c)) {
                    	contactRecord.ARTL_Designation__c = stagingRecord.Designation__c;
                    }
                    if(String.isNotBlank(stagingRecord.Responsibility__c)) {
                    	contactRecord.ARTL_Contact_Role__c = stagingRecord.Responsibility__c;
                    }
                    if(String.isNotBlank(stagingRecord.Phone__c)) {
                    	contactRecord.Phone = stagingRecord.Phone__c;
                    }
                    if(String.isNotBlank(stagingRecord.Phone_Code__c)) {
                    	contactRecord.Country_Code__c = stagingRecord.Phone_Code__c;
                    }
                    if(String.isNotBlank(stagingRecord.Email_Address__c)) {
                    	contactRecord.Email = stagingRecord.Email_Address__c;
                    }
                    contactRecord.Staging_Record_Id__c = stagingRecord.Id;
                    //if(String.isNotBlank(stagingRecord.Parent_Account__c) && accountNumberWithAccountId.containsKey(stagingRecord.Parent_Account__c)) {
                        //contactRecord.AccountId = accountNumberWithAccountId.get(stagingRecord.Parent_Account__c);
                    //}
                    contactsToBeInserted.add(contactRecord);
                }
                List<Database.SaveResult> contactSaveResults = Database.update(contactsToBeInserted, false);

                
                for(Integer i=0;i<contactSaveResults.size();i++) {
                    String scopeRecordId = contactsToBeInserted[i].Staging_Record_Id__c;
                    if(String.isNotBlank(scopeRecordId)) {
                        ARTL_Bulk_Upload_Staging__c stagingRecord = (stagingRecordsFinalUpdateMap.containsKey(scopeRecordId)) ? stagingRecordsFinalUpdateMap.get(scopeRecordId) : scopeMap.get(scopeRecordId);
                        if(contactSaveResults[i].isSuccess()) {
                            stagingRecord.Record_Id__c = contactSaveResults[i].getId();
                        } else {
                            String errorMessage = '';
                            for(Database.Error err : contactSaveResults[i].getErrors()) {
                                errorMessage += err.getMessage();
                            }
                            stagingRecord.Errors__c = errorMessage;
                        }
                        stagingRecordsFinalUpdateMap.put(stagingRecord.Id,stagingRecord);
                    }
                }
                if(!stagingRecordsFinalUpdateMap.isEmpty()) {
                    Database.update(stagingRecordsFinalUpdateMap.values(),false);
                }
            } catch (Exception e) {
                ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_BulkUploadValidationBatchJob:invoke', '', new Map<String,Object>{'Exception'=>e.getMessage() , 'LineNumber' => e.getLineNumber(), 'StackTrace' => e.getStackTraceString() }, e);
                List<ARTL_Bulk_Upload_Staging__c> erroredStagingRecords = new List<ARTL_Bulk_Upload_Staging__c>();
                for(ARTL_Bulk_Upload_Staging__c stagingRecord : scope) {
                    if(String.isBlank(stagingRecord.Record_Id__c) && String.isBlank(stagingRecord.Errors__c)) {
                        stagingRecord.Errors__c = 'System Exception : Please contact your Airtel admin.';
                        erroredStagingRecords.add(stagingRecord);
                    }
                }
                Database.update(erroredStagingRecords,false);
            }
        }

    }
    
    global void finish(Database.BatchableContext BC) {
        
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Report fld;
        String emailBody = '';
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Bulk Data Status ' + a.Status);
        
        String reportName;
        if(type == 'BUC'){
            reportName = 'BUC_Error_Report_xhK';
        }else if(type == 'Quota'){
            reportName = 'Quota_Error_pul';
        } else if(type == 'BCPDCP_Contact') {
            reportName = 'BCPDCP_Contact_Error_Report_IuY';
        } else if(type == 'BCPDCP_Contact_Update') {
            reportName = 'BCPDCP_Contact_Error_Report_IuY';
        } else if(type == 'Party_Contact_Update') {
            reportName = 'Party_Contact_Error_Report_KrR';
        } else if(type == 'Party_Contact') {
            reportName = 'Party_Contact_Error_Report_KrR';
        }
        
        if(!Test.IsRunningTest()){
            fld = [Select Id from Report where DeveloperName =:reportName];
            emailBody = '<html>Record Processing is Completed. Please visit Error Tracking Report to see errors if any: <a href="'+System.URL.getOrgDomainUrl().toExternalForm()+'/lightning/r/Report/'+fld.Id+'/view?fv0=' + this.iterationId + '">'+'Here'+'</a></html>';
        }
                    
        mail.setHtmlBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    private List<Map<String,Object>> getRecordsMapped(List<Sobject> scope){
        List<Map<String,Object>> lstrecords = new List<Map<String,Object>>();
        for(Sobject sobj : scope){
            Map<String,Object> record = new Map<String,Object>();
       
            for(String fieldAPIName : fieldAPINames){
                if(!lstFieldSet.contains(fieldAPIName)) //Add additional field in the list if needed to be checked.
                    record.put(fieldAPIName, sobj.get(fieldAPIName));
                
            }
            Map<String,Object> mapAttributes = new Map<String,Object>{'type'=> getAttributeType(this.type)};
                record.put('attributes', mapAttributes);
            lstrecords.add(record);
            
        }
        return lstrecords;
    }
    private List<Map<String,Object>> getQuotaRecordsMapped(List<Sobject> scope){
        List<Map<String,Object>> lstrecords = new List<Map<String,Object>>();
        for(Sobject sobj : scope){
            Map<String,Object> record = new Map<String,Object>();
            for(String fieldAPIName : fieldAPINames){
                if(!lstFieldSet.contains(fieldAPIName)){
                    if(mapSource.containsKey(fieldAPIName)){
                        record.put(mapSource.get(fieldAPIName), sobj.get(fieldAPIName));
                    }
                    else {
                        record.put(fieldAPIName, sobj.get(fieldAPIName));
                    }
                }      
            }  
            Map<String,Object> mapAttributes = new Map<String,Object>{'type'=> getAttributeType(this.type)};
                record.put('attributes', mapAttributes);
            lstrecords.add(record);
        }
      
        return lstrecords;
    }
    private String getAttributeType(String type){
        switch on type {
            when  'BUC'{
                return 'Bottom_Up_Construct__c';
            }
            when 'Quota' {
                return 'ForecastingQuota';
            }
            when else{
                return '';
            }
        }
    }
    private static List<Object> sendInsertRequest(Map<String,Object> mapRequest){
        List<Object> lstObject;
           HttpRequest request = new HttpRequest();
           request.setMethod('POST');
           request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/data/v59.0/composite/sObjects');
           request.setHeader('Content-Type', 'application/json');
           request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
           String body = JSON.serialize(mapRequest);
           request.setBody(body);
           Http http = new Http();
           HttpResponse response = http.send(request);
           System.debug('Response body'+response);
           lstObject = (Object[])JSON.deserializeUntyped(response.getBody());
              
         return lstObject;  
    }
    private void mapInsertResponseToStage(List<Object> response, List<Sobject> scope){
        List<ARTL_Bulk_Upload_Staging__c> lstToInsert = new  List<ARTL_Bulk_Upload_Staging__c>();
        System.debug('Repos$$'+response);
        System.debug('Scope$$'+scope);
        if(response!=NULL){
            for(Integer i=0;i<response.size();i++){
            Object resp = response[i];
            Map<String,Object> mapDMLResp = (Map<String,Object>)resp;
            if(mapDMLResp.get('success') == true){
                //scope[i].Record_Id__c = mapDMLResp.get('id'); 
                ARTL_Bulk_Upload_Staging__c scopeRecord = (ARTL_Bulk_Upload_Staging__c)scope.get(i);
                String id = String.valueOf(mapDMLResp.get('id')); 
                scopeRecord.Record_Id__c = String.valueOf(mapDMLResp.get('id')); 
                lstToInsert.add(scopeRecord);
            }
            else{
                /*Map<String,Object> mapError = (Map<String,Object>)mapDMLResp.get('errors');
                ARTL_Bulk_Upload_Staging__c scopeRecord = (ARTL_Bulk_Upload_Staging__c)scope.get(i);
                scopeRecord.Errors__c = String.valueOf(mapError.get('message')); 
                //scope[i].Errors__c =  mapError.get('message'); */
                List<Object> message = (List<Object>)(((Map<String,Object>)response[i]).get('errors'));
                Map<String,Object> messageMap = (Map<String,Object>)message[0];
                
                ARTL_Bulk_Upload_Staging__c scopeRecord = (ARTL_Bulk_Upload_Staging__c)scope.get(i);
                scopeRecord.Errors__c = String.valueOf(messageMap.get('message')); 
                lstToInsert.add(scopeRecord);
            
            }
        }
         upsert lstToInsert; //uncomment after adding hte RecordId and Error Message.
        }
    }
}