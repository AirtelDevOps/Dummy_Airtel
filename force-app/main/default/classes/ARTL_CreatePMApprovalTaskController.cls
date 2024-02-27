/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ARTL_CreatePMApprovalTaskController
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Abinash Barik    <abinash.barik@salesforce.com>
* @modifiedBy     Akshay Kaushik   <akshay.kaushik@salesforce.com>
* @maintainedBy   Abinash Barik    <abinash.barik@salesforce.com>
* @version        1.1
* @created        2023-10-26
* @modified       2024-02-08
* @Test Class	: ARTL_CreatePMApprovalTaskControllerTest
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* 1.0             abinash.barik@salesforce.com
* 2023-10-26	Create PM approval Task for each Sub Order created and Submitted to OM.
*				Task should be linked to Order and Root Quote Line Item Id.
*				Task must be assigned to PM linked to Quote
* 2024-02-08    Added Conditions for Task creation
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
global  with sharing class ARTL_CreatePMApprovalTaskController {
	//Invocable Method to call from Flow To generate Approval PM Task only for Sub Order
    @InvocableMethod(label='create Approval Task')
    public static void createPMApprovalTask(List<FlowInput> flowInputs) {
        String orderId = flowInputs.get(0).recordId;
        Order ord = [Select Id,vlocity_cmt__QuoteId__c,vlocity_cmt__SupplementalAction__c,vlocity_cmt__QuoteId__r.PM__c,Record_Type_Name__c  
                     FROM Order WHERE Id=:orderId];
        List<OrderItem> lstoli = new List<OrderItem>();
        
        lstoli =[Select id,QuoteLineItemId,OrderId,Quantity,QuoteLineItem.Quote.PM__c  
                 FROM OrderItem 
                 	WHERE OrderId =:ord.Id 
					AND  vlocity_cmt__ParentItemId__c =null];
        List<Task> lsttobeInsert = new List<Task>();
        System.debug('lstoli'+lstoli);
        if(lstoli!=null && lstoli.size()==1 && lstoli[0].Quantity<2){
            if(ord.vlocity_cmt__SupplementalAction__c != 'Cancel'){
        for(OrderItem oli: lstoli){
            lsttobeInsert.add(new Task(
            Subject ='PM Approval',
            WhatId = ord.Id,
			Type = 'PM Approval',
            ARTL_TaskType__c ='PM Approval',    
			Quote_Line_Item__c = oli.QuoteLineItemId,
            ARTL_Order_Type__c = ord.Record_Type_Name__c,  
            OwnerId = ord.vlocity_cmt__QuoteId__r.PM__c != null ? ord.vlocity_cmt__QuoteId__r.PM__c : UserInfo.getUserId()
            ));
        }
        if(!lsttobeInsert.isEmpty()){
            Insert lsttobeInsert;
        }
        }
        }
        
    }
    //Flow Inputs
    public class FlowInput{
        @InvocableVariable(required=true) public Id recordId;
    }
    
}