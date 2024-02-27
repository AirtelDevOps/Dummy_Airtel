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

trigger TaskTrigger on Task (before update, after update, before insert) {
    TaskTriggerHandler handler = new TaskTriggerHandler(Trigger.new, Trigger.newMap,Trigger.oldMap);  
    if(Trigger.isBefore && Trigger.isUpdate) {        
        handler.beforeUpdate();
    }
    if(Trigger.isAfter && Trigger.isUpdate) {        
        handler.afterUpdate();
    }
    if(Trigger.isBefore && Trigger.isInsert) {        
        handler.beforeInsert();
    }
}