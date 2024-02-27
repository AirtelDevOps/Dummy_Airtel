public class ARTL_BulkApplyAdjustmentBatch implements Database.Batchable<Object>{
    public Map<String,Object> adjustmentInputMap = new Map<String,Object>();
    public List<Object> adjustmentList = new List<oBJECT>();
    public String GroupCartId ;
    public String callBatch ; 
    public String WorkingCartId ;
    public String CartId ;
    String iterationId;
    Map<String,Object> WorkingCartInput = new Map<String,Object>(); 
    Map<String,Object> LSITruePayload = new Map<String,Object>(); 
    Map<Id,Id> cloneSourceIdMap = new Map<Id,Id>();
    Map<Id, ARTL_Bulk_Iteration_Log__c> bulkIterationLogMap = new Map<Id, ARTL_Bulk_Iteration_Log__c>();
    list<ARTL_Bulk_Iteration_Log__c> bulkIterationLogRecords = New list<ARTL_Bulk_Iteration_Log__c>();
    public ARTL_BulkApplyAdjustmentBatch(Map<String,Object> fullAdjustmentInputMap){
        try{
            this.adjustmentInputMap = fullAdjustmentInputMap;
            string adjustmentInputMapstr = JSON.serialize(this.adjustmentInputMap);
            System.debug('ARTL_EventHandlerWrapperVIP this.adjustmentInputMapstr  '+adjustmentInputMapstr);
            this.iterationId = String.valueOf(fullAdjustmentInputMap.get('iterationId'));
            System.debug('iterationId size  %%%'+iterationId);
            this.adjustmentList = (List<Object>)fullAdjustmentInputMap.get('adjustmentValues');
            this.WorkingCartId = String.valueOf(fullAdjustmentInputMap.get('WorkingCartId'));
            this.GroupCartId = String.valueOf(fullAdjustmentInputMap.get('GroupCartId'));
            this.callBatch = String.valueOf(fullAdjustmentInputMap.get('callBatch'));
            this.WorkingCartInput = ( Map<String,Object>)fullAdjustmentInputMap.get('WorkingCartInput');
            
            this.CartId = String.valueOf(fullAdjustmentInputMap.get('CartId')); 
            this.LSITruePayload = ( Map<String,Object>)fullAdjustmentInputMap.get('LSITruePayload'); 
            System.debug(' this.LSITruePayload  %%%'+ this.LSITruePayload);
            System.debug('this.cloneSourceIdMap size  %%%'+this.cloneSourceIdMap);
            List<Object> BulkIterationLogTestList ;
            if(!Test.isRunningTest()){
                this.cloneSourceIdMap = ( Map<Id,Id>)fullAdjustmentInputMap.get('cloneSourceIdMap');
            }else{
                Map<String,Object> cloneMap = ( Map<String , Object>)fullAdjustmentInputMap.get('cloneSourceIdMap');
                for(String str : cloneMap.keySet()){
                    this.cloneSourceIdMap.put(str , string.valueOf(cloneMap.get(str)));
                }
            }
            
            
            List<ARTL_Bulk_Iteration_Log__c> bulkIterationLog = [select id,ARTL_Bulk_Iteration__c, Product__c, Quote_Line_Item__c,LSI__c, Status__c, ErrorMessage__c,ARTL_Bulk_Iteration__r.Quote__c from ARTL_Bulk_Iteration_Log__c where ARTL_Bulk_Iteration__c =: this.iterationId];
            System.debug('bulkIterationLog size  %%%'+bulkIterationLog);

            if(Test.isRunningTest()){
                BulkIterationLogTestList = ( List<Object>)fullAdjustmentInputMap.get('bulkIterationList');
                Map<String , Object> BulkIterationLogTestMap = (Map<String , Object>)BulkIterationLogTestList[0];
                ARTL_Bulk_Iteration_Log__c Bulk_IterationLogTest = new ARTL_Bulk_Iteration_Log__c();
                Bulk_IterationLogTest.Quote_Line_Item__c = String.valueOf(BulkIterationLogTestMap.get('Quote_Line_Item__c'));
                Bulk_IterationLogTest.Status__c = String.valueOf(BulkIterationLogTestMap.get('Status__c'));
                bulkIterationLog.add(Bulk_IterationLogTest);
            }
            
            for(ARTL_Bulk_Iteration_Log__c bulkIteration : bulkIterationLog){  
                System.debug('bulkIteration size  %%%'+bulkIteration+ '   '+bulkIteration.Quote_Line_Item__c);
                this.bulkIterationLogMap.put(bulkIteration.Quote_Line_Item__c , bulkIteration);
            }
            
            List<ARTL_Bulk_Iteration_Log__c> bulkIterationLogList = new List<ARTL_Bulk_Iteration_Log__c>();
            for (String key : this.cloneSourceIdMap.keySet()) {
                System.debug(' String.valueOf(adjustmentMap.get(id)) '+ String.valueOf(this.cloneSourceIdMap.get(key)));
                ARTL_Bulk_Iteration_Log__c bulkIterationLogRec = this.bulkIterationLogMap.get(String.valueOf(this.cloneSourceIdMap.get(key)));
                System.debug(' bulkIterationLogRec '+ bulkIterationLogRec);
                bulkIterationLogRec.Quote_Line_Item__c = key;
                bulkIterationLogList.add(bulkIterationLogRec);
                this.bulkIterationLogMap.put(key, bulkIterationLogRec);
                System.debug(' bulkIterationLogList '+ bulkIterationLogList);
            }
            System.debug(' bulkIterationLogList 2 '+ bulkIterationLogList);
            //Database.update(bulkIterationLogList);
            Database.SaveResult[] srList = Database.update(bulkIterationLogList , false);
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Success  '+sr.getId());
                }
                else {
                    String errorMessage = '';
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        errorMessage = 'The following error has occurred. '+ err.getStatusCode() + ': ' + err.getMessage() +  ' ' +err.getFields();
                        System.debug(errorMessage);
                    }
                    
                }
            }
            
            List<ARTL_Bulk_Iteration_Log__c> bulkIterationLog2 = [select id,ARTL_Bulk_Iteration__c, Product__c, Quote_Line_Item__c,LSI__c, Status__c, ErrorMessage__c,ARTL_Bulk_Iteration__r.Quote__c from ARTL_Bulk_Iteration_Log__c where ARTL_Bulk_Iteration__c =: iterationId];
            System.debug('bulkIterationLog22 size  %%%'+bulkIterationLog2);
        }catch (Exception e) {
            System.debug('error msg### ' + e.getMessage());
        }
    }
    public List<Object> start(Database.BatchableContext BC){
        return adjustmentList;
    }
    
    public void execute(Database.BatchableContext BC, object adjustmentValueobject){
        try{
            System.debug(' bulkIterationLogMap '+ bulkIterationLogMap); 
            String qliId = '';
            
            list<object> objlist =  (list<object>)adjustmentValueobject;
            Map<String, Object> adjustmentMap = (Map<String, Object>)objlist[0];
            for (String key : cloneSourceIdMap.keySet()) {
                if (cloneSourceIdMap.get(key) == adjustmentMap.get('id')) {
                    qliId = key;
                    break;
                }
            }
            ARTL_Bulk_Iteration_Log__c bulkIterationLog = this.bulkIterationLogMap.get(qliId);
            adjustmentMap.put('id' , qliId);
            adjustmentMap.put('cartId' , this.WorkingCartId);
            string adjustmentMapstr = JSON.serialize(adjustmentMap);
            System.debug('ARTL_EventHandlerWrapperVIP adjustmentMapstr  '+adjustmentMapstr);
            Map<String, Object> ipAdjustmentOutput = new Map<String, Object>();
            Map<String, Object> ipAdjustmentOption = new Map<String, Object>();
            //ipAdjustmentOption.put('useQueueable',true);
            if(!Test.isRunningTest()){
                ipAdjustmentOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService('ARTL_ApplyAdjustment', adjustmentMap, ipAdjustmentOption);
            }
            
            if(bulkIterationLog != null){
                if(Integer.valueOf(ipAdjustmentOutput.get('totalSize')) == 0 ){
                    List<Object> messagesList = (List<Object>)ipAdjustmentOutput.get('messages');
                    Object messages = messagesList[0];
                    Map<String , Object> messageMap = (Map<String , Object>)messages;
                    bulkIterationLog.ErrorMessage__c = String.valueOf(messageMap.get('message'));

                    Database.update(bulkIterationLog , false);
                }

            }
            
            string ipOutputString = JSON.serialize(ipAdjustmentOutput);                
            System.debug('ARTL_BulkApplyAdjustmentBatch ipOutputString  '+ipOutputString);
        } catch (Exception e) {
            System.debug('error msg###  batch' + e.getMessage());
        }
    }
    public void finish(Database.BatchableContext BC){
        try{
            Map<String, Object> ipAdjustmentInput = new Map<String, Object>();
            Map<String, Object> ipAdjustmentOutput = new Map<String, Object>();
            Map<String, Object> POAdjustmentOutput = new Map<String, Object>();
            ipAdjustmentInput.put('WorkingCartId',WorkingCartId);
            ipAdjustmentInput.put('GroupCartId',GroupCartId);
            ipAdjustmentInput.put('callBatch',callBatch);
            ipAdjustmentInput.put('SalesQuoteId',WorkingCartInput.get('SalesQuoteId'));
            ipAdjustmentInput.put('RootItemIds',WorkingCartInput.get('RootItemIds'));
            ipAdjustmentInput.put('reprice',true);
            ipAdjustmentInput.put('validate',true);
            System.debug('ARTL_BulkApplyAdjustmentBatch input CloneModifyTo_SalesQLIsWQPR before');
            if(!Test.isRunningTest()){
                System.debug('ARTL_BulkApplyAdjustmentBatch input CloneModifyTo_SalesQLIsWQPR before');
                ipAdjustmentOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService('CloneModifyTo_SalesQLIsWQPR', ipAdjustmentInput, null);
            }
            string ipAdjustmentOutputString = JSON.serialize(ipAdjustmentOutput);                
            System.debug('ARTL_BulkApplyAdjustmentBatch final ipAdjustmentOutputString  '+ipAdjustmentOutputString);
            
            //changes for iteration log
            //
            Map<String , Id> qliMap = new Map<String , Id>();
            List<QuoteLineItem> qliList = [select id,product2.name from QuoteLineItem where quoteId =: CartId];
            List<ARTL_Bulk_Iteration_Log__c> bulkIterationLog = [select id,ARTL_Bulk_Iteration__c, Product__c, Quote_Line_Item__c,LSI__c, Status__c, ErrorMessage__c,ARTL_Bulk_Iteration__r.Quote__c from ARTL_Bulk_Iteration_Log__c where ARTL_Bulk_Iteration__c =: iterationId];
            System.debug('bulkIterationLog size  %%%'+bulkIterationLog);
            for(QuoteLineItem qliRec : qliList){
                qliMap.put(qliRec.product2.name , qliRec.Id);
            }
            for(ARTL_Bulk_Iteration_Log__c iterationLog  : bulkIterationLog){
                iterationLog.Quote_Line_Item__c = qliMap.get(iterationLog.Product__c);
                if(iterationLog.Status__c == 'In Progress'){
                    iterationLog.Status__c = 'Success';
                }
            }
            
            Database.update(bulkIterationLog);
            
            
            List<ARTL_Bulk_Iteration__c> bulkIterationGetUser = [select id,CreatedById from ARTL_Bulk_Iteration__c where Id =: iterationId];
            System.debug('POAdjustmentOutput input before');
            
            if(LSITruePayload !=null && !Test.isRunningTest()){
                System.debug('POAdjustmentOutput input before inside If');
                System.debug('POAdjustmentOutput input '+LSITruePayload);
                POAdjustmentOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService('ARTL_CreateBillingStageEntriesBulk', LSITruePayload, null);
                System.debug('POAdjustmentOutput '+POAdjustmentOutput);
            }
            
            List<ARTL_BulkCartUpdate__c> BulkCartUpdateRecordvAR = [select id,Status__c from ARTL_BulkCartUpdate__c where (Status__c = 'Received' AND Cart_Id__c=:CartId and Sobject_Type__c='Quote')];
            System.debug('BulkCartUpdateRecordvAR '+BulkCartUpdateRecordvAR);
            if(BulkCartUpdateRecordvAR.size()>0){
                System.debug('size if '+BulkCartUpdateRecordvAR.size());
                BulkCartUpdateRecordvAR[0].Status__c = 'Processed';
                update BulkCartUpdateRecordvAR[0];
            }else if(BulkCartUpdateRecordvAR.size()==0){
                System.debug('size else '+BulkCartUpdateRecordvAR.size());
                string baseUrl = System.URL.getOrgDomainUrl().toExternalForm();
                Id typeId = [SELECT Id,CustomNotifTypeName  FROM CUstomNotificationType WHERE CustomNotifTypeName = 'ARTL_BulkQuoteUploadNotification'].Id;
                Id reportId = Test.isRunningTest() ? null : [SELECT Id FROM Report WHERE DeveloperName = 'ARTL_Bulk_Quote_Upload_Reports'].Id;
                System.debug('typeId else '+typeId);
                System.debug('reportId else '+reportId);
                System.debug('iterationId else '+iterationId);
                string url = baseUrl + '/lightning/r/Report/' + reportId + '/view?fv0=' + iterationId;
                System.debug('url else '+url);
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setBody('Bulk Processing has been completed. Please click here for more details');
                notification.setTitle('Uploadation Completed');
                if(bulkIterationGetUser.size()>0){
                    Id userId = bulkIterationGetUser[0].CreatedById;
                    notification.setSenderId(userId);
                }else{
                    notification.setSenderId(Userinfo.getUserId());
                }
                notification.setNotificationTypeId(typeId );
                String pgRef = '{type: "standard__webPage",attributes: {url: "' + url + '"}}';
                notification.setTargetPageRef(pgRef);
                System.debug('notification else '+notification);
                System.debug('pgRef else '+pgRef);
                
                if(bulkIterationGetUser.size()>0){
                    Id userId = bulkIterationGetUser[0].CreatedById;
                    System.debug('userId else '+userId);
                    notification.send(new Set<String> { userId });
                    
                }else{
                    System.debug('Userinfo.getUserId() else '+Userinfo.getUserId());
                    notification.send(new Set<String> { Userinfo.getUserId() });
                }
                
            }
        } catch (Exception e) {
            System.debug('error msg### batch ' + e.getMessage());
        }
    }
}