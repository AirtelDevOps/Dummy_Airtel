/************************************************************************************************************************************************************************************************************
* @Author       : Akshay Kaushik <akshay.kaushik@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 09/12/2023
* @Test Class   : ARTL_CreateSubOrdersTest
* @Description  : Validate the newly created sub order and delete previously created sub-orders.
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
*     Developer               Date           	  Comment
* ------------------      ---------------       -----------    
*  Akshay Kaushik          09/12/2023     		Initial Dev
******************************************************************************************************************************************************************************************************************/
global class ARTL_ValidateCart implements Database.Batchable < sObject > {
    String query;
    String orderId;
    List<Id> OrdersToDelete = new List<Id>();

    global ARTL_ValidateCart(String orderId, List < Id > OrdersToDelete) {
        this.orderId = orderId;
        this.OrdersToDelete = OrdersToDelete;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Query the master order ID based on the provided sub-order ID
        Order masterOrder = [SELECT QuoteId, vlocity_cmt__ParentOrderId__c FROM Order WHERE Id =: orderId];
        Id masterOrderId = masterOrder.vlocity_cmt__ParentOrderId__c;
        Id quoteId = masterOrder.QuoteId;

        if (masterOrderId != null) {
            // Query sub-orders related to the master order
            return Database.getQueryLocator(
                'SELECT Id, OrderNumber, QuoteId FROM Order' +
                ' WHERE vlocity_cmt__ParentOrderId__c = \'' + masterOrderId + '\''
            );
        }

        return null;
    }

    global void execute(Database.BatchableContext BC, List < Order > orderList) {
        List < Map < String, Object >> results = new List < Map < String, Object >> ();
        System.debug('orderList' + orderList);
        for (Order childOrder: orderList) {
            Map < String, Object > input = new Map < String, Object > ();
            Map < String, Object > output = new Map < String, Object > ();
            Map < String, Object > options = new Map < String, Object > ();

            input.put('methodName', 'runCartValidation');
            input.put('cartId', childOrder.QuoteId);
            input.put('price', 'true');
            input.put('validate', 'true');
            // Instantiate CPQAppHandler and invoke the runCartValidation method
            vlocity_cmt.CPQAppHandler cpq = new vlocity_cmt.CPQAppHandler();
            cpq.invokeMethod('runCartValidation', input, output, options);

            results.add(output);
        }
    }

    global void finish(Database.BatchableContext BC) {
        delete[SELECT Id FROM Order where Id in :OrdersToDelete];
        delete[SELECT Id FROM Task where WhatId in :OrdersToDelete];
    }
}