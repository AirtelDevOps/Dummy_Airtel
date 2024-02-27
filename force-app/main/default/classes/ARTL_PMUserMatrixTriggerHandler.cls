/**
* Class to implement the trigger handler for PM User Matrix Object
*
* @Author  Salesforce
*
*/
public class ARTL_PMUserMatrixTriggerHandler extends TriggerHandler {
    Map<Id, PM_User_Matrix__c> newPMMatrixMap = (Map<Id, PM_User_Matrix__c>) Trigger.newMap;
    Map<Id, PM_User_Matrix__c> oldPMMatrixMap = (Map<Id, PM_User_Matrix__c>) Trigger.oldMap;
    
    public ARTL_PMUserMatrixTriggerHandler() {
        this.newPMMatrixMap = (Map<Id, PM_User_Matrix__c>) Trigger.newMap;
        this.oldPMMatrixMap = (Map<Id, PM_User_Matrix__c>) Trigger.oldMap;
    }

    public override void afterInsert() {
        ARTL_PMUserMatrixTriggerHelper.assignPM(newPMMatrixMap);
        ARTL_PMUserMatrixTriggerHelper.assignTL(newPMMatrixMap);
    }

    public override void afterUpdate() {
        ARTL_PMUserMatrixTriggerHelper.reassignPM(newPMMatrixMap, oldPMMatrixMap);
        ARTL_PMUserMatrixTriggerHelper.reassignTL(newPMMatrixMap, oldPMMatrixMap);
    }
}