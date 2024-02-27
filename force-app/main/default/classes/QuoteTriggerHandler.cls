/*------------------------------------------------------Class Signature-------------------------------------------------------
Class Name      : QuoteTriggerHandler
Purpose         : Class to implement the trigger handler for Quote Object.
Nested Classes  : QuoteTriggerHelper
Date            : 05-October-2023
-------------------------------------------------------------------------------------------------------------------------------*/
public class QuoteTriggerHandler extends TriggerHandler {

    public static boolean doaInProgress = false;
    public static final String CUSTOMER_SIGNED = 'Customer Signed';
   

    List<Quote> quoteList=(List<Quote>)Trigger.New;
    Map<id,Quote> oldQuoteRec = (Map<id,Quote>) Trigger.oldMap;
    
    public QuoteTriggerHandler(){
        this.quoteList=(List<Quote>)Trigger.New;
        this.oldQuoteRec = (Map<id,Quote>) Trigger.oldMap;
    }

    public override void afterUpdate() {
        
        Map<Id, Quote> oldQuoteMap = (Map<Id, Quote>) Trigger.oldMap;
        QuoteTriggerHelper.runQuoteAfterTriggerEvents(quoteList, oldQuoteMap);
        
        //KB: This is to filter Customer Signed Quotes to create BA-SA-- Start
        Set<Id> quoteIdSet = new Set<Id>();
        boolean callInterOrderDep = false;
        for(Quote quote: quoteList){
            Quote oldQuote = (Quote)Trigger.OldMap.get(quote.Id);
            system.debug('quote.Status==>'+quote.Status);
            system.debug('oldQuote.Status==>'+oldQuote.Status);
            if(quote.Status == CUSTOMER_SIGNED && quote.Status != oldQuote.Status){
                if(quote.vlocity_cmt__Type__c == 'New'){
                    callInterOrderDep = true;
                }
                quoteIdSet.add(quote.Id);
            }
        }
        if(callInterOrderDep){
           QuoteTriggerHelper.interOrderDepency(quoteList,oldQuoteMap);
        }
        if(quoteIdSet.size()>0){
            QuoteTriggerHelper.createBASABatch(quoteIdSet);
        }

        QuoteTriggerHelper.updateOpportunityStage((Map<Id, Quote>) Trigger.newMap,(Map<Id, Quote>) Trigger.oldMap);


        //system.debug('after update trigger==>'+JSON.serializePretty(quoteList));
        //KB: This is to filter Customer Signed Quotes to create BA-SA-- End

        //system.debug('quoteList after update '+quoteList);
        
        
        // this is POC please do not touch 
        
        //system.debug('doaInProgress ***'+doaInProgress);
        /*
        if(!doaInProgress){
           DOAHandler.transformGetQuoteId(quoteList);
        }*/
    }
    
    
    public override void beforeUpdate() {
        QuoteTriggerHelper.runQuoteBeforeTriggerEvents(quoteList , oldQuoteRec);
    }    
}