Global without sharing class ARTL_AssetController implements vlocity_cmt.VlocityOpenInterface{
    
    public class AssetIterationWrapper {
        
    }
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options){
        if (methodName == 'BulkUploadValidationAndUpdation') {
            getAssetRecordsFromIterationId(inputs, output, options);
            return true;
        }
        if(methodName == 'invokeAssettoQuoteAPI'){
            invokeAssetToQuoteAPI(inputs, output, options);
            return true;
        }
        if(methodName == 'sendNotification'){
            sendNotification(inputs, output, options);
            return true;
        }
        return false;
    }
    public static void invokeAssetToQuoteAPI(Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options){
        try {
            String str = URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/vlocity_cmt/v2/carts';
            output.put('Content-Type', 'application/json');
            output.put('url', str);
            output.put('Authorization', 'Bearer ' + UtilsGetSessionId.getSessionIdFromVFPage(Page.getSessionIdVFPage));
            System.debug('UserInfo.getSessionId() '+UserInfo.getSessionId());
        } catch (Exception e) {
            
            System.debug('e message '+e.getMessage());        }
    }
    public static void getAssetRecordsFromIterationId ( Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options) {
        try{
            String iterationId = (String) inputs.get('IterationId');
            String contextId = (String)inputs.get('ContextId');
            List<ARTL_Bulk_Upload_Iteration__c> iterationList = [SELECT Id, Opportunity_Name__c, Opportunity_Stage__c,Opportunity_Close_Date__c, 
                                                                 Quote_Name__c, Quote_Id__c,Opportunity_Id__c, Amount__c 
                                                                 FROM ARTL_Bulk_Upload_Iteration__c WHERE Id =: iterationId];
            
            List<ARTL_Bulk_Upload_Staging__c> stagingList = [SELECT Id,Errors__c, Status__c, ARTL_Bulk_Upload_Iteration__c, Record_Id__c FROM ARTL_Bulk_Upload_Staging__c 
                                                             WHERE ARTL_Bulk_Upload_Iteration__c =: iterationId and Record_Id__c!= null];
            Set<Decimal> assetLSIIdSet = new Set<Decimal>();
            for(ARTL_Bulk_Upload_Staging__c stagingRec : stagingList) {
                assetLSIIdSet.add(Decimal.valueOf(stagingRec.Record_Id__c));
            }                                               
            List<Asset> assetList = [SELECT Id, AccountId ,RootAssetId, vlocity_cmt__RootItemId__c, vlocity_cmt__ParentItemId__c, ARTL_LSI__c,
                                        vlocity_cmt__BillingAccountId__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__AssetReferenceId__c,  
                                        vlocity_cmt__LineNumber__c 
                                        FROM Asset WHERE ARTL_LSI__c IN: AssetLSIIdSet];
            
            Set<String> accountIdSet = new Set<String>();
            for(Asset assetRec : assetList) {
                accountIdSet.add(assetRec.AccountId);
            }
            
            Map<String, String> erroroutput = NEW Map<String, String>();
            Map<String, List<Object>> erroroutputList = NEW Map<String, List<Object>>();
            erroroutput.put('contextId message' , contextId);
            erroroutputList.put('iterationList message' , iterationList);
            erroroutputList.put('stagingList message' , stagingList);
            erroroutputList.put('assetList message' , assetList);
            output.put('List' , erroroutputList);
            output.put('contextId message' , erroroutput);
            //System.debug('output in try '+output);
            //validateAssetForProcessing(iterationList, stagingList, assetList, accountIdSet, contextId); 
            ARTL_BulkAssetModificationValidation(iterationList, stagingList, assetList, contextId);
            
        } catch(Exception e) {
            Map<String, String> erroroutput = NEW Map<String, String>();
            String str = e.getMessage() + e.getStackTraceString();
            erroroutput.put('errror message' , str);
            output.put('error' , erroroutput);
            System.debug('output  '+output);
        }
        
    }
    
    /* Blanket method to include Asset Validation. Can be deprecated if not used. Current validation logic is in  ARTL_BulkUploadCartStageLoad.ARTL_BulkAssetModificationValidation() method */
    public static void validateAssetForProcessing(List<ARTL_Bulk_Upload_Iteration__c> iterationList, List<ARTL_Bulk_Upload_Staging__c> stagingList, List<Asset> assetList, Set<String> accountIdSet, String contextId) {
        
    }
    
    /* Create Quote and Opportunity after Asset Validation. Quote and Opportunity to be created if the asset list is empty, indicating all the assets are validated. */
    public static void createQuoteAndOpportunity(List<ARTL_Bulk_Upload_Staging__c> StagingValidatedList, ARTL_Bulk_Upload_Iteration__c iterationRecord , Map<String,Object> inputMap ,  List<Id> rootAssetIds) {
        system.debug('inside createQuoteAndOpportunity');
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> OptionMap = new Map<String,Object>();
        OptionMap.put('useFuture' ,true);
        if(!StagingValidatedList.isEmpty() && StagingValidatedList.size() != 0) {
            
            /* List<ARTL_Bulk_Upload_Staging__c> stagingList = [SELECT Id, ARTL_Bulk_Upload_Iteration__c, Record_Id__c FROM ARTL_Bulk_Upload_Staging__c 
        WHERE ARTL_Bulk_Upload_Iteration__c =: IterationRecord.Id]; */
            
            Set<Decimal> assetLSIIdSet = new Set<Decimal>();
            //for(ARTL_Bulk_Upload_Staging__c stagingRec : stagingList) {
            for(ARTL_Bulk_Upload_Staging__c stagingRec : StagingValidatedList) {
                assetLSIIdSet.add(Decimal.valueOf(stagingRec.Record_Id__c));
            }   
            List<Asset> assetList = [SELECT Id, AccountId ,RootAssetId, vlocity_cmt__RootItemId__c, vlocity_cmt__ParentItemId__c, ARTL_LSI__c,
                                     vlocity_cmt__AssetReferenceId__c,  vlocity_cmt__LineNumber__c FROM Asset WHERE ARTL_LSI__c IN: AssetLSIIdSet];
            
            // List<sObject> recordsToUpsert = new List<sObject>();
            
            if((iterationRecord.Quote_Id__c != '' && iterationRecord.Quote_Id__c != null) && (iterationRecord.Opportunity_Id__c != '' && iterationRecord.Opportunity_Id__c != null)) {
                Opportunity oppRec = new Opportunity();
                oppRec.Id = iterationRecord.Opportunity_Id__c;
                //Database.update(oppRec);  Update not required if Opportunity ID is populated
                
                Quote quoteRec = new Quote();
                //quoteRec.Id = iterationRecord.Quote_Id__c;
                //Database.update(quoteRec); Update not required if Quote ID is populated
                
            } else {
                
                
                Opportunity oppRec = new Opportunity();
                oppRec.AccountId = AssetList.get(0).AccountId;
                oppRec.Name = iterationRecord.Opportunity_Name__c;
                oppRec.StageName = iterationRecord.Opportunity_Stage__c;
                oppRec.CloseDate = iterationRecord.Opportunity_Close_Date__c;
                oppRec.Amount = iterationRecord.Amount__c;
                Database.insert(oppRec);
                System.debug('Opp Rec-->'+oppRec);
                
                Quote quoteRec = new Quote();
                quoteRec.OpportunityId = oppRec.Id;
                quoteRec.Name = iterationRecord.Quote_Name__c;
                Database.insert(quoteRec);
                System.debug('Quote Rec-->'+quoteRec);
                
                iterationRecord.Quote_Id__c = quoteRec.Id; 
                iterationRecord.Opportunity_Id__c = oppRec.Id;
                Database.update(iterationRecord);
            }
            
            /* if(!recordsToUpsert.isEmpty()) {
        Database.upsert(recordsToUpsert);
        } */
                    
                    /*List<Asset> assetListToUpdate = new List<Asset>();
        for(Asset assetRec : assetList) {
        Asset assetRecord = new Asset(Id = assetRec.Id);
        //assetRecord.QuoteId = quoteRec.Id;
        assetListToUpdate.add(assetRecord);
        }
        Database.update(assetListToUpdate);*/
            system.debug('String.ValueOf(inputMap.get(accountId))' + String.ValueOf(inputMap.get('accountId')));
            Id accountId = String.ValueOf(inputMap.get('accountId'));
            //List<Id> SuccessUpdateAssetList  = (List<Id>)inputMap.get('SuccessUpdateAssetList');
            createAssetToQuote(accountId , rootAssetIds,iterationRecord.Id);
            
            
        } 
    }
    
    @future(callout=true)
    public static void createAssetToQuote(Id accountId , List<Id> SuccessUpdateAssetList, Id iterationId ) {
        Map<String, Object> inputMap = new Map<String, Object>();
        system.debug('accountId Ip Call '+ accountId);
        system.debug('iterationId Ip Call '+ iterationId);
        for(Id ass : SuccessUpdateAssetList){
            system.debug('as Id  Ip Call '+ ass);
        }
        inputMap.put('accountId',accountId);
        inputMap.put('IterationId',iterationId);
        inputMap.put('assetIdList',SuccessUpdateAssetList);
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> OptionMap = new Map<String,Object>();
        OptionMap.put('isDebug' ,false);
        System.debug('Ip map Input ' + JSON.serialize(inputMap));
        outputMap = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService('ARTL_AssetToQuoteCreation', inputMap, OptionMap);
        System.debug('outputMap**   '+ outputMap);
        
    }
    
    /*Created by KOMAL SHARMA for validation  during Bulk Asset Modification */
    Public static void ARTL_BulkAssetModificationValidation(List<ARTL_Bulk_Upload_Iteration__c> UploadIterationsList ,List<ARTL_Bulk_Upload_Staging__c> UploadStagingList , List<Asset> AssetsList,  Id accountId){
        try{
            System.debug('ARTL_BulkAssetModificationValidation AssetsList  '+AssetsList);
            System.debug('ARTL_BulkAssetModificationValidation accountId  '+accountId);
            Map<String, Asset> bulkAssetModificationMap = new Map<String, Asset>();
            Map<String, Asset> rootAssetMap = new Map<String, Asset>();
            Map<String, string> errorMessageMap = new Map<String, string>();
            Set<String> lsiNumWithBlankServiceOrBillingAcc = new Set<String>();
            Set<String> assetRootIds = new Set<String>();
            List<Id> SuccessUpdateAssetList = new List<Id>();
            ARTL_Bulk_Upload_Iteration__c IterationRecord = UploadIterationsList[0];
            System.debug('ARTL_BulkAssetModificationValidation IterationRecord '+IterationRecord);
            System.debug('ARTL_BulkAssetModificationValidation AssetsList '+AssetsList.size());
            for(Asset assetRecord: AssetsList){
                if(assetRecord.AccountId == accountId){
                    //System.debug('assetRecord   ***  '+assetRecord);
                    System.debug('ARTL_BulkAssetModificationValidation assetRecord.vlocity_cmt__RootItemId__c '+assetRecord.vlocity_cmt__RootItemId__c);
                    assetRootIds.add(assetRecord.vlocity_cmt__RootItemId__c);
                    
                }else{
                    System.debug('ARTL_BulkAssetModificationValidation assetRecord.AccountId  accountId'+ assetRecord.AccountId +'   '+ accountId);
                }
                
                if (assetRecord.vlocity_cmt__ServiceAccountId__c == null || assetRecord.vlocity_cmt__BillingAccountId__c == null) {
                    lsiNumWithBlankServiceOrBillingAcc.add(String.valueOf(assetRecord.ARTL_LSI__c));
                }
            }

            System.debug('ARTL_BulkAssetModificationValidation assetRootIds '+assetRootIds);
            List<Id> rootAssetIds = new List<Id>();
            List<Asset> rootAssetList = [select id,AccountId ,RootAssetId, vlocity_cmt__RootItemId__c, vlocity_cmt__ParentItemId__c,vlocity_cmt__AssetReferenceId__c,  vlocity_cmt__LineNumber__c from Asset where vlocity_cmt__AssetReferenceId__c IN : assetRootIds AND AccountId =:accountId ];
            System.debug('ARTL_BulkAssetModificationValidation rootAssetList '+rootAssetList);
            for(Asset assetRecord: rootAssetList){
                rootAssetIds.add(assetRecord.id);
                rootAssetMap.put(assetRecord.vlocity_cmt__AssetReferenceId__c ,assetRecord);
            }
            System.debug('ARTL_BulkAssetModificationValidation rootAssetIds '+rootAssetIds);
            System.debug('ARTL_BulkAssetModificationValidation rootAssetMap '+rootAssetMap);
            
            for(Asset assetRecord: AssetsList){
                if(!rootAssetMap.containsKey(assetRecord.vlocity_cmt__RootItemId__c)){
                    System.debug('ARTL_BulkAssetModificationValidation assetRecord.vlocity_cmt__RootItemId__c '+assetRecord.vlocity_cmt__RootItemId__c);
                    errorMessageMap.put(String.valueOf(assetRecord.ARTL_LSI__c), 'Uploading an mismatch asset');
                }else{
                    System.debug(' else ARTL_BulkAssetModificationValidation assetRecord.vlocity_cmt__RootItemId__c '+assetRecord.vlocity_cmt__RootItemId__c);
                    errorMessageMap.put(String.valueOf(assetRecord.ARTL_LSI__c), 'Uploading an right asset');
                    SuccessUpdateAssetList.add(assetRecord.id);
                }
            }
            System.debug('ARTL_BulkAssetModificationValidation errorMessageMap '+errorMessageMap);
            for(ARTL_Bulk_Upload_Staging__c UploadStagingRecord: UploadStagingList){
                if(errorMessageMap.containsKey(UploadStagingRecord.Record_Id__c)){
                    System.debug('ARTL_BulkAssetModificationValidation UploadStagingRecord.Record_Id__c '+UploadStagingRecord.Record_Id__c);
                    //String ErrorMesage = errorMessageMap.get(UploadStagingRecord.Record_Id__c);
                    UploadStagingRecord.Errors__c = errorMessageMap.get(UploadStagingRecord.Record_Id__c);
                     if(errorMessageMap.get(UploadStagingRecord.Record_Id__c) == 'Uploading an right asset'){
                            UploadStagingRecord.Status__c	='Success';
                    }
                    else{
                           UploadStagingRecord.Status__c	='Failed';
                    }
                }else{
                    System.debug('else ARTL_BulkAssetModificationValidation UploadStagingRecord.Record_Id__c '+UploadStagingRecord.Record_Id__c);
                }

                if(lsiNumWithBlankServiceOrBillingAcc.contains(UploadStagingRecord.Record_Id__c)){
                    uploadStagingRecord.Status__c	= 'Ignored';
                    uploadStagingRecord.Errors__c	= 'LSI with blank Service or Billing Account';
                }
            }
            System.debug('ARTL_BulkAssetModificationValidation UploadStagingList-->'+UploadStagingList);
            For(ID df:SuccessUpdateAssetList){
                system.debug('df '+df);
            }
            update UploadStagingList;
            System.debug('UploadStagingList-->'+UploadStagingList);
            Map<String, Object> ipAdjustmentInput = new Map<String, Object>();
            ipAdjustmentInput.put('accountId',accountId);
            ipAdjustmentInput.put('SuccessUpdateAssetList',SuccessUpdateAssetList);
            If(UploadStagingList.size()>0){
                createQuoteAndOpportunity(UploadStagingList,IterationRecord,ipAdjustmentInput,rootAssetIds);
            }
        }catch(Exception e){
            String str = e.getMessage() + e.getStackTraceString();
            System.debug('ARTL_BulkAssetModificationValidation  '+str);
        }
        
    }
    
    Public static void sendNotification(Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options){
        Id IterationId = (String)inputs.get('IterationId');
        List<Id> StagingErrorRecords  = New List<Id>();
        
        List<ARTL_Bulk_Upload_Staging__c> stagingList = [SELECT Id,Errors__c, ARTL_Bulk_Upload_Iteration__c, Record_Id__c FROM ARTL_Bulk_Upload_Staging__c 
                                                         WHERE ARTL_Bulk_Upload_Iteration__c =: IterationId and Record_Id__c!= null];
        for(ARTL_Bulk_Upload_Staging__c Staging : stagingList){
            If(Staging.Errors__c =='Uploading an mismatch asset'){
                StagingErrorRecords.add(Staging.Id);
            }
        }
        List<CustomNotificationType > TemplateInfoDetail = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE CustomNotifTypeName = 'CSV Bulk Asset Uplaod and update Notification'];
        If(StagingErrorRecords.size()==0){                       
            //if(IterationId !=null){
            Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
            currNotification.setTitle('Bulk Asset Uploadation successful ');
            //currNotification.setBody(currAccCon.CARS_Contact_Name__c + ' has de-linked from ' + currAccCon.CARS_Account_Name__c +'on' + system.today());
            currNotification.setBody('Bulk asset uploadation is successfully completed for more details check the related List' + system.today());
            currNotification.setNotificationTypeId(TemplateInfoDetail[0].Id);
            currNotification.setTargetId(IterationId);
            try {
                currNotification.send(new Set<String> { Userinfo.getUserId() });
            }
            catch (Exception ex) {
                System.debug('Notification Failed: ' + ex.getMessage());
            }
            //}
        }
        else {
            Messaging.CustomNotification currNotification = new Messaging.CustomNotification();
            currNotification.setTitle('Bulk Asset Uploadation Failed');
            //currNotification.setBody(currAccCon.CARS_Contact_Name__c + ' has de-linked from ' + currAccCon.CARS_Account_Name__c +'on' + system.today());
            currNotification.setBody(' Bulk asset uploadation is failed for more details check the related List' + system.today());
            currNotification.setNotificationTypeId(TemplateInfoDetail[0].Id);
            currNotification.setTargetId(IterationId);
            try {
                currNotification.send(new Set<String> { Userinfo.getUserId() });
            }
            catch (Exception ex) {
                System.debug('Notification Failed: ' + ex.getMessage());
            } 
        }
    } 
}