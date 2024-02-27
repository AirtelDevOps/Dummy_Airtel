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

public class OrderItemTriggerHandler {
	private final List<OrderItem> triggerNewList;
    private final Map<Id,OrderItem> mapOfNewList;
    public OrderItemTriggerHandler(List<OrderItem> triggerNewList,Map<Id,OrderItem> mapOfNewList) {
        this.triggerNewList = triggerNewList;
        this.mapOfNewList = mapOfNewList;
    }
    public void afterInsert(){
        //OrderItemTriggerHandlerHelper.createPMApprovalTask(this.mapOfNewList);
        //OrderItemTriggerHandlerHelper.updateTechnicalAttribute(this.triggerNewList);
        //OrderItemTriggerHandlerHelper.createandUpdateXLI(this.triggerNewList);//SFDC-1933
    }
    
}