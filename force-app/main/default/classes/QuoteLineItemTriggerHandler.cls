/************************************************************************************************************************************************************************************************************
* @Author       : Abinash Barik <abinash.barik@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 25/09/2023
* @Test Class   : 
* @Description  : 
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1. SFDC-217              Abinash Barik         25/09/2023     Initial Dev
******************************************************************************************************************************************************************************************************************/

public class QuoteLineItemTriggerHandler {
    private final List<QuoteLineItem> triggerNewList;
    private final Map<Id,QuoteLineItem> newMap;
    private final Map<Id,QuoteLineItem> oldMap;
    public QuoteLineItemTriggerHandler(List<QuoteLineItem> triggerNewList,Map<Id,QuoteLineItem> newMap,Map<Id,QuoteLineItem> oldMap) {
        this.triggerNewList = triggerNewList;
        this.newMap = newMap;
        this.oldMap = oldMap;
    }
    
    public void afterInsert(){
        System.debug(' QLI After Insert');
      
            List< String > astRefList = new List< String >();
            for(QuoteLineItem qLI: triggerNewList){
                if(qLI.vlocity_cmt__AssetReferenceId__c != null){
                    astRefList.add(qLI.vlocity_cmt__AssetReferenceId__c);
                }
            }
            if(astRefList != null && astRefList.size() > 0){
                ARTL_MACD_CreateBillingStaging.createBillingStaging(astRefList, triggerNewList);
            }
    
        
        //QuoteLineItemTriggerHelper.createTechnicalAttribute(this.triggerNewList,this.newMap);
        //Update DOA &Capex fields on Quote 
        QuoteLineItemTriggerHelper.updateDOACapexFieldsFUpdate(null,this.newMap);
        QuoteLineItemTriggerHelper.AggregateToQuote(this.triggerNewList ,NULL);
        
       
    }

    public void afterUpdate(){
        //QuoteLineItemTriggerHelper.createTechnicalAttribute(this.triggerNewList,this.newMap);
        //Update DOA &Capex fields on Quote 
        QuoteLineItemTriggerHelper.updateDOACapexFieldsFUpdate(this.oldMap,this.newMap);
        QuoteLineItemTriggerHelper.AggregateToQuote(this.triggerNewList ,this.oldMap);
        QuoteLineItemTriggerHelper.updateQuoteValidationStatus(this.triggerNewList, this.oldMap);
        
    }
     
}