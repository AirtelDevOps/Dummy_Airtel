/************************************************************************************************************************************************************************************************************
* @Author       : Abinash Barik <abinash.barik@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 06/11/2023
* @Test Class   : 
* @Description  : 
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1. SFDC-217              Abinash Barik         06/11/2023     Initial Dev
******************************************************************************************************************************************************************************************************************/

trigger OrderItemTrigger on OrderItem (after insert, before update, before insert) {
    OrderItemTriggerHandler handler = new OrderItemTriggerHandler(Trigger.new, Trigger.newmap); 
	if(Trigger.isAfter) {        
       // handler.afterInsert();
    }
}