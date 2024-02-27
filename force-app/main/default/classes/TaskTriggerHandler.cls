public class TaskTriggerHandler {
    
    private final List<Task> triggerNewList;
    private final Map<Id,Task> newMap;
    private final Map<Id,Task> oldMap;
    public TaskTriggerHandler(List<Task> triggerNewList,Map<Id,Task> newMap,Map<Id,Task> oldMap) {
        this.triggerNewList = triggerNewList;
        this.newMap = newMap;
        this.oldMap = oldMap;
    }
    

    public void afterUpdate(){
        Set<Id> setOfOrderIds = new Set<Id>();
        List<Task> lstOfTaskTobeCloned = new List<Task>();
        for(Task objtask: this.triggerNewList){
            system.debug('TaskListHandler==>'+objtask);
            system.debug('TaskMapHandler==>'+objtask);
            if(objtask.Record_Type_Name__c == 'LOC' && objtask.ARTL_Rejection_Category__c != null && objtask.ARTL_Rejection_Category__c.equalsIgnoreCase('Invalid') && objtask.Record_Type_Name__c == 'LOC' &&
              objtask.ARTL_Rejection_Category__c != this.oldMap.get(objtask.id).ARTL_Rejection_Category__c){
                  setOfOrderIds.add(objtask.WhatId);
              }
            if(objtask.Record_Type_Name__c == 'LOC' && objtask.Status == 'Rejected by PM' && objtask.Status != this.oldMap.get(objtask.id).Status){
                lstOfTaskTobeCloned.add(objtask);
            }
        }
        if(!setOfOrderIds.isEmpty()){
            TaskTriggerHelper.updateRelatedTaskStatus(setOfOrderIds,this.oldMap);
        }
        if(!lstOfTaskTobeCloned.isEmpty()){
            TaskTriggerHelper.createTaskForPM(lstOfTaskTobeCloned);
        }
        TaskTriggerHelper.updateEffectiveDateOnOLI(this.triggerNewList);
        
    }
    public void beforeUpdate(){
        TaskTriggerHelper.resetTaskFields(this.triggerNewList,this.oldMap);
        TaskTriggerHelper.validateAttachment(this.triggerNewList,this.oldMap);
    }
    public void beforeInsert(){
        TaskTriggerHelper.populateAccount(this.triggerNewList);
    }
    
}