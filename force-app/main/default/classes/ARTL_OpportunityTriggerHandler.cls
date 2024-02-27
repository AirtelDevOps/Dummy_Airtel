/**
 * Description: Used as Handler class of Opportunity Trigger based on the trigger framework
 * Author: Salesforce (Sagar)
 */
public class ARTL_OpportunityTriggerHandler extends TriggerHandler {
    
    private Map<Id, Opportunity> oldOppMap;
    private final String CLOSED_WON = 'Closed Won';
    private final String PARTIAL_WON = 'Partial Won';
    
    public override void beforeInsert() {
        List<Opportunity> oppList=(List<Opportunity>)Trigger.New;
        system.debug('beforeInsert opportunity trigger');
        try{
            ARTL_OpportunityTriggerHelper.defaultOpportunityStage(oppList);
        }catch(Exception e){
            System.debug('Exception in class::ARTL_OpportunityTriggerHandler and method::afterInsert @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
    }
    
    public override void beforeUpdate() {
        this.oldOppMap = (Map<Id, Opportunity>) Trigger.oldMap;
        //SFDC-776 - Author: Sagar -- start
        for(Opportunity opp : (List<Opportunity>) Trigger.new) {
            if(opp.stagename.equalsIgnoreCase(System.Label.ARTL_Stage_Close_Lost) && this.oldOppMap.get(opp.id).stagename != opp.stagename){
                opp.Opportunity_Closure_Status__c = System.Label.ARTL_Closer_Status_Lost;
            }
        }
        //SFDC-776 - Author: Sagar -- end
    }

    public override void afterUpdate() {
        this.oldOppMap = (Map<Id, Opportunity>) Trigger.oldMap;
        //Create Non feasible Opportunity products with opportunity (SFDC-95) -- Start
        Map<Id, Opportunity> partialWinOppMap = new Map<Id, Opportunity>();
        Map<Id, List<String>> oppIPMap = new Map<Id, List<String>>();
        
        for(Opportunity opp : (List<Opportunity>) Trigger.new) {
            if(opp.stagename != null && opp.stagename.equalsIgnoreCase(CLOSED_WON) && this.oldOppMap.get(opp.id).stagename != opp.stagename &&
            opp.Opportunity_Closure_Status__c != null && opp.Opportunity_Closure_Status__c.equalsIgnoreCase(PARTIAL_WON)
            ){
                partialWinOppMap.put(opp.id, opp);
            }
            if (opp.stagename.equalsIgnoreCase(CLOSED_WON) &&
                       this.oldOppMap.get(opp.id).stagename != opp.stagename) {
                if (!oppIPMap.containsKey(opp.Id)) {
                    oppIPMap.put(opp.Id, new List<String>());
                }
                oppIPMap.get(opp.Id).add('ARTL_OpportunitySolaceQueue');
            }
        }
        if(!partialWinOppMap.isEmpty()){
            ARTL_OpportunityTriggerHelper.partialWonOpportunities(partialWinOppMap);
        }
        if (!oppIPMap.isEmpty()) {
            for (Id oppId : oppIPMap.keySet()) {
                for (String ipAddress : oppIPMap.get(oppId)) {
                    ARTL_InvokeIP.invokeIPOnAccCreation(oppId, ipAddress);
                }
            }
        }
        //Create Non feasible Opportunity products with opportunity (SFDC-95) -- End
        
    }
  
    
  }