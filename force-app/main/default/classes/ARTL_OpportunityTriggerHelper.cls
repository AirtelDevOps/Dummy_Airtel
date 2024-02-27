/**
* @Description: Class to implement the trigger helper for Opportunity Object
* @Author:  Salesforce (Sagar)
* @CreatedDate: 17th Oct 2023
*/
public with Sharing class ARTL_OpportunityTriggerHelper {
    
    private static final String NOT_FEASIBLE = 'NOT_FEASIBLE';
    private static final String INITIAL_STAGE = 'Initial';
    
    /**
     * Name: partialWonOpportunities
     * Description: used to create child opportunity and opportunity products for non feasible products(bundle)
     * Author: Sagar Sadhnani
     */
    public static void partialWonOpportunities(Map<Id, Opportunity> partialWinOppMap) {
        
        
        
        Map<String, OpportunityLineItem> uniqueOLIMap = new Map<String, OpportunityLineItem>();
        Map<String, Opportunity> oldNewOppMap = new Map<String, Opportunity>();

        for(QuoteLineItem qli : [SELECT Product2Id, vlocity_cmt__OneTimeTotal__c, Annual_Recurring_Total__c, Quantity, Quote.OpportunityId 
                                FROM quotelineitem 
                                WHERE ARTL_Feasibility__r.ARTL_Feasibility_Status__c = :NOT_FEASIBLE AND Quote.OpportunityId IN :partialWinOppMap.keySet() AND vlocity_cmt__ParentItemId__c = null]
        )
        {
            //Opportunity newOpp;
            OpportunityLineItem newOLI;
            //KB: Creating Child Opp
            if(!oldNewOppMap.containsKey(qli.Quote.OpportunityId)){
                oldNewOppMap.put(qli.Quote.OpportunityId, new Opportunity( name = partialWinOppMap.get(qli.Quote.OpportunityId).name, 
                                accountId = partialWinOppMap.get(qli.Quote.OpportunityId).accountid, stagename = INITIAL_STAGE, 
                                CloseDate = System.today().addYears(1), vlocity_cmt__PriceListId__c = partialWinOppMap.get(qli.Quote.OpportunityId).vlocity_cmt__PriceListId__c,
                                Parent_Opportunity__c = qli.Quote.OpportunityId, Pricebook2Id = partialWinOppMap.get(qli.Quote.OpportunityId).Pricebook2Id)
                );
            }
            Decimal aggregatedPrice = (qli.vlocity_cmt__OneTimeTotal__c != null ? qli.vlocity_cmt__OneTimeTotal__c : 0) + (qli.Annual_Recurring_Total__c != null ? qli.Annual_Recurring_Total__c : 0);
            
            if(!uniqueOLIMap.containsKey(qli.Quote.OpportunityId + '___' + qli.Product2Id)){
                
                newOLI = new OpportunityLineItem(Opportunity = oldNewOppMap.get(qli.Quote.OpportunityId), UnitPrice = aggregatedPrice,
                                                Product2Id = qli.Product2Id, Quantity = qli.Quantity                                
                );
                
            }else{//KB: Here we need to create only unique products with rolled up quantities and price
                
                newOLI = uniqueOLIMap.get(qli.Quote.OpportunityId + '___' + qli.Product2Id);
                newOLI.Quantity += qli.Quantity;
                newOLI.UnitPrice += aggregatedPrice;
            }
            uniqueOLIMap.put(qli.Quote.OpportunityId + '___' + qli.Product2Id, newOLI);
        }
        if(!uniqueOLIMap.isEmpty()){
            insert oldNewOppMap.values();

            for(String key : uniqueOLIMap.keySet()){
                uniqueOLIMap.get(key).OpportunityId = uniqueOLIMap.get(key).Opportunity.Id;
            }

            insert uniqueOLIMap.values();
        }
        
    }
    
    public static void defaultOpportunityStage(List<Opportunity> oppList){
        try{
            system.debug('beforeInsert opportunity trigger::defaultOpportunityStage');
            for(Opportunity oppRecord:oppList){
                system.debug('oppRecord=>'+JSON.serializePretty(oppRecord));
                System.debug(' StageName =>'+oppRecord.StageName);
                oppRecord.StageName='Qualified';
                system.debug('oppRecord=>'+JSON.serializePretty(oppRecord));
            }
            system.debug('oppList=>'+JSON.serializePretty(oppList));
        }catch(Exception e){
            System.debug('Exception in class::ARTL_OpportunityTriggerHelper and method::defaultOpportunityStage @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
    }
    
}