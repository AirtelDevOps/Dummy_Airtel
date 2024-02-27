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

trigger QuoteLineItemTrigger on QuoteLineItem (After insert, after update , after delete , after undelete,before insert) {
    QuoteLineItemTriggerHandler handler = new QuoteLineItemTriggerHandler(Trigger.new, Trigger.newMap,Trigger.oldMap);
    System.debug('test dbug');
    if(Trigger.isAfter && Trigger.isInsert) {        
        handler.afterInsert();
    }
    if(Trigger.isAfter && Trigger.isUpdate) {   
        handler.afterUpdate();
       }
    
    
}