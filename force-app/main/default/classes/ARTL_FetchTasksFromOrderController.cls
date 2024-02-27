/************************************************************************************************************************************************************************************************************
* @Author       : Bijaya Dutta <bijaya.dutta@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 29/12/2023
* @Test Class   : ARTL_FetchTasksFromOrderControllerTest
* @Description  : To Fetch the tasks related to a particular order
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1. SFDC-2848              Bijaya Dutta         29/12/2023     Initial Dev
******************************************************************************************************************************************************************************************************************/

public with sharing class ARTL_FetchTasksFromOrderController {
    @AuraEnabled(cacheable=true)
    public static List<Task> getTasks(Id orderId) {
        String recordTypeName = [
            SELECT RecordType.DeveloperName
            FROM Order
            WHERE Id = :orderId
        ].RecordType.DeveloperName;

        List<Task> tasks = new List<Task>();

        if (recordTypeName == 'MasterOrder') {
            // For Master Order, retrieve tasks for both Master and Sub Orders
            tasks.addAll([SELECT Id, Subject,Account.Name, Status,What.Name, Product_Name__c, Owner.Name,ARTL_TaskType__c,
                          vlocity_cmt__CompletedDate__c FROM Task
                          WHERE WhatId = :orderId]); 

            // Retrieve tasks for Sub Orders
            List<Order> subOrders = [SELECT Id FROM Order WHERE vlocity_cmt__ParentOrderId__c = :orderId];
            Set<Id> subOrderIds = new Set<Id>();
            for (Order subOrder : subOrders) {
                subOrderIds.add(subOrder.Id);
            }
            tasks.addAll([SELECT Id, Subject,Account.Name, Status, What.Name, Product_Name__c, Owner.Name,ARTL_TaskType__c,
                        vlocity_cmt__CompletedDate__c FROM Task
                        WHERE WhatId IN :subOrderIds]);
        } else if (recordTypeName == 'SubOrder') {
            // For Sub Order, retrieve tasks only for that specific Sub Order
            tasks.addAll([SELECT Id, Subject, Account.Name,Status, What.Name,Product_Name__c, Owner.Name,ARTL_TaskType__c,
                          vlocity_cmt__CompletedDate__c FROM Task
                          WHERE WhatId = :orderId]);
        }

        return tasks;
    }
}