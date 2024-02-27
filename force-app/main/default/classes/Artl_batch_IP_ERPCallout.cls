public class Artl_batch_IP_ERPCallout implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful {
    List<Id> idList = new List<id>();
    String activityAction;
    String orderId;
    String taskName;
    @InvocableMethod(label = 'call IP from Batch apex')
    public static void executeCustomBatch(List<FlowInputs> inputs){
        List<Id> idList = new List<id>();
        String activityAction;
        for(FlowInputs inp: inputs){
            System.debug('ids from Flow '+ inp.ids);
            idList = inp.ids;
            activityAction = inp.activityAction;
        }
        Id jobId = Database.executeBatch(new Artl_batch_IP_ERPCallout(idList,activityAction));
    }
    public Artl_batch_IP_ERPCallout(List<Id> idList,String activityAction){
        this.idList = idList;
        this.activityAction = activityAction;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('In start method'+idList);
        if(activityAction.contains('NIPS_PR_Details') || activityAction.contains('NIPS_PO_Details')){
            return Database.getQueryLocator([select id,Quote_Line_Item__r.ARTL_OUName__c,Master_Order__r.vlocity_cmt__QuoteId__c,Requisition_Number__c,Master_Order__c,PR_ID__c  from ARTL_Purchase_Request__c where id =: idList]);
        }
       else if(activityAction.contains('MrrDetails')){
             return Database.getQueryLocator([select id,MasterOrder__c,MasterOrder__r.vlocity_cmt__QuoteId__c,PONumber__c, PRID__c, PRID__r.Quote_Line_Item__r.ARTL_OUName__c  from Purchase_Order__c where id =: idList]);
        }
        return null;
            }

    public void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Object> inputList = new List<Object>();
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> outMap = new Map<String, Object> ();
        Map<String, Object> options = new Map<String, Object> ();
        Map<String, Object> ipOutput;
        String checkoutIPName;
        if(activityAction.contains('NIPS_PR_Details')){
            checkoutIPName = 'Fetch_PR';
            taskName = 'PO';
        }
        else if(activityAction.contains('NIPS_PO_Details')){
            checkoutIPName = 'Fetch_PO';
            taskName = 'MRR';
        }
        else if(activityAction.contains('MrrDetails')){
            checkoutIPName = 'Fetch_MRR';
            taskName = 'RA';
        }
        System.debug('checkoutIPName##'+checkoutIPName);
        Set<Id> quoteIdList = new Set<Id>();
        for (sObject sobj : scope) {
			System.debug('sobj type'+sobj.getSObjectType());
            
            if((String.valueOf(sobj.getSObjectType()) == 'ARTL_Purchase_Request__c')){
                quoteIdList.add(String.valueOf(sobj.getSobject('Master_Order__r').get('vlocity_cmt__QuoteId__c')));
                orderId = String.valueOf(sobj.get('Master_Order__c'));
                
            }else if((String.valueOf(sobj.getSObjectType()) == 'Purchase_Order__c')){
                quoteIdList.add(String.valueOf(sobj.getSobject('MasterOrder__r').get('vlocity_cmt__QuoteId__c')));
                orderId = String.valueOf(sobj.get('MasterOrder__c'));
                
            }
        }
        
        List<QuoteLineItem> quoteLine = [
                               SELECT id, RequisitionNumber__c,ARTL_OUName__c, ItemCode__c 
                               from QuoteLineItem  
                               where QuoteId=: quoteIdList
                               AND (vlocity_cmt__Product2Id__r.ProductCode = 'dac49a09-9b41-4999-b7c4-cf6319ad5b44'
                               OR vlocity_cmt__Product2Id__r.ProductCode = 'c09a2e70-64af-4ad6-8427-06c8489234d7')
        					   AND RequisitionNumber__c != '' 
                                 ];
        String ouName = quoteLine[0].ARTL_OUName__c;
        for (sObject sobj : scope) {

            if(String.valueOf(sobj.getSObjectType()) == 'ARTL_Purchase_Request__c'){
                ipInput.put('requisitionNumber', String.valueOf(sobj.get('Requisition_Number__c')));
                //ipInput.put('ouName', String.valueOf(sobj.getSobject('Quote_Line_Item__r').get('ARTL_OUName__c')));
                ipInput.put('ouName',ouName);
                ipInput.put('domain', 'B2B');
                ipInput.put('consumerTransactionId', sobj.get('Id'));
                ipInput.put('consumerName', 'SFDC');
                ipInput.put('programmeName', 'fetchPRDetails');
                ipInput.put('activityAction', 'NIPS_PR_Details');
                ipInput.put('orderId', String.valueOf(sobj.get('Master_Order__c')));
                ipInput.put('prId', String.valueOf(sobj.get('PR_ID__c')));
                ipInput.put('processName', checkoutIPName);
            }
            else if(String.valueOf(sobj.getSObjectType()) == 'Purchase_Order__c'){
                //ipInput.put('ouName', String.valueOf(sobj.getSobject('PRID__r').getSobject('Quote_Line_Item__r').get('ARTL_OUName__c')));
                ipInput.put('ouName',ouName);
                ipInput.put('domain', 'B2B');
                ipInput.put('consumerTransactionId', sobj.get('Id'));
                ipInput.put('consumerName', 'SFDC');
                ipInput.put('programmeName', 'fetchPRDetails');
                ipInput.put('activityAction', 'MrrDetails');
                ipInput.put('orderId', String.valueOf(sobj.get('MasterOrder__c')));
                ipInput.put('poNumber', String.valueOf(sobj.get('PONumber__c')));
                ipInput.put('processName', checkoutIPName);
                ipInput.put('poRecordId', sobj.get('Id') );

            }

            System.debug('>>>>here First batch >>>>: '+JSON.serialize(ipInput));
            
            //ipOutput = invokeMethod('checkoutIPName', ipInput, null, null);
            //vlocity_cmt.VlocityBatchFramework.startIntegrationProcedureBatch(checkoutIPName, inputList, new Map<String, Object>{'sendInputAsList' => false,'batchSize' => '1'});
            ARTL_CalloutEventHandler eventClass = new ARTL_CalloutEventHandler();
            eventClass.invokeMethod('initiateCallout', ipInput, outMap, options);
        }

    }
    public static Map<String, Object> invokeMethod(String methodName, Map<String, Object> ipInput,  Map<String, Object> ipOutput, Map<String, Object> ipOptions) {
        ipOutput = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(methodName, ipInput , ipOptions);
        return ipOutput;
    }
    public void finish(Database.BatchableContext bc) {

        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:bc.getJobId() limit 1];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{a.CreatedBy.Email});
        email.setSubject('Jobs running in background completed.');
        String body = 'Your '+ taskName +' task has been Created.';
        body += '<br></br>';
        body += 'Plese click below link to see the records.';
        body += '<br></br>';
        String link = URL.getOrgDomainUrl().toExternalForm()+'/'+orderId;
        body += link;
        email.setHtmlBody(body);
        //email.setPlainTextBody('Your job has been completed. Please click this link to see the records.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });


    }

    public class FlowInputs{
    
        @InvocableVariable
        public List<String> ids;
        @InvocableVariable
        public  String activityAction;
        
        
      
        
    }
}