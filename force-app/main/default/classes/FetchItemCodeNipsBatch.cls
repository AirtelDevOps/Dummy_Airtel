global with sharing class FetchItemCodeNipsBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{


    global String quoteId;
    global Integer failureCount=0;
    global Integer successCount=0;
    private final String TOAST_MESSAGE = 'Fetch Item Code Completed';

    @TestVisible
    global FetchItemCodeNipsBatch(String QuoteId){
        this.quoteId =  QuoteId;
        //System.debug(' quoteId1--> '+quoteId);  

    }

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator('SELECT Id FROM QuoteLineItem WHERE ( Product2.ProductCode = \'dac49a09-9b41-4999-b7c4-cf6319ad5b44\' OR Product2.ProductCode = \'c09a2e70-64af-4ad6-8427-06c8489234d7\') AND QuoteId =:quoteId' );

     }

    public void execute(Database.BatchableContext bc, List<QuoteLineItem> scope){
        
        // System.debug(' qliList--> '+JSON.serialize(scope)); 

        String qliId = (String)scope[0].get('Id');
        // System.debug(' qliId---> '+ qliId); 


        String vipName = 'ARTL_FetchItemCode';
        Map<String,Object> input = new Map<String, Object>();

        input.put('QLIId', qliId);
        input.put('endpoint', 'https://b2benterprisebusiness.airtel.com/services/getmetadata/metadata/v5');
        input.put('apiKey', 'ZGM4NWI4YzItZTAxYy05NzA5LWFkMGQtZTU4OWY5ZDNhNGNh');
        
        Boolean apiSuccess = (Boolean)((Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(vipName, input, null)).get('apiSuccess');

        if(apiSuccess != null)
            if(!apiSuccess)
                failureCount ++;
            else 
                successCount ++;
        //System.debug(' failureCount---> '+ failureCount); 

        
    }

    public void finish(Database.BatchableContext bc){
 
        List<NotificationWorker__e> eventList = new List<NotificationWorker__e>();
        NotificationWorker__e nw = new NotificationWorker__e();
        nw.artlQuoteId__c  = quoteId;
        nw.SubEventName__c = TOAST_MESSAGE;
        nw.failureCount__c = failureCount;
        nw.successCount__c = successCount;
        eventList.add(nw);

        Database.SaveResult[] result = EventBus.publish(eventList);
        
    }

    

    
}