/************************************************************************************************************************************************************************************************************
* @Author       : Akshay Kaushik <akshay.kaushik@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 09/12/2023
* @Test Class   : ARTL_CreateSubOrdersTest
* @Description  : Create orderitem relationship according to newly created sub orders
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
*     Developer               Date           	  Comment
* ------------------      ---------------       -----------    
*  Akshay Kaushik          09/12/2023     		Initial Dev
******************************************************************************************************************************************************************************************************************/
global class ARTL_CreateOrderItemRelationship implements Database.Batchable < sObject > {
    String originalOrderId;
    Map < String, String > mapOfCloneOrderItemtoOrderID = new Map < String,String > ();
    Map < String,String > mapOfOriginalOliIdByClonedOliId = new Map < String,String > ();
    List<Id> OrdersToDelete = new List<Id>();
    Public ARTL_CreateOrderItemRelationship(String originalOrderId, Map < String, String > mapOfOriginalOliIdByClonedOliId, Map < String, String > mapOfCloneOrderItemtoOrderID, List < id > OrdersToDelete) {
        this.originalOrderId = originalOrderId;
        this.mapOfCloneOrderItemtoOrderID = mapOfCloneOrderItemtoOrderID;
        this.mapOfOriginalOliIdByClonedOliId = mapOfOriginalOliIdByClonedOliId;
        this.OrdersToDelete = OrdersToDelete;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        
        String Orderid = originalOrderId;
        Map < String, Schema.SObjectType > schemaMap = Schema.getGlobalDescribe();
        Set < String > quoteProdRelFieldMap = schemaMap.get('vlocity_cmt__OrderItemRelationship__c').getDescribe().fields.getMap().keySet();
        List < String > quoteProdRelFinalFields = new List < String > ();
        quoteProdRelFinalFields.addAll(quoteProdRelFieldMap);
        
        return Database.getQueryLocator('SELECT ' + String.join(quoteProdRelFinalFields, ',') +
                                        ' FROM vlocity_cmt__OrderItemRelationship__c' +
                                        ' WHERE vlocity_cmt__OrderId__c  = \'' + Orderid + '\'');
        
    }
    
    global void execute(Database.BatchableContext BC, List < vlocity_cmt__OrderItemRelationship__c > ordProdRelList) {
        System.debug('originalOrderId'+originalOrderId);
        System.debug('originalmapOfCloneOrderItemtoOrderIDOrderId'+mapOfCloneOrderItemtoOrderID);
        System.debug('mapOfOriginalOliIdByClonedOliId'+mapOfOriginalOliIdByClonedOliId);
        System.debug('OrdersToDelete'+OrdersToDelete);
        
        List < vlocity_cmt__OrderItemRelationship__c > clonedOrdProdRelList = new List < vlocity_cmt__OrderItemRelationship__c > ();
        for (vlocity_cmt__OrderItemRelationship__c eachOrdProdRel: ordProdRelList) {
            vlocity_cmt__OrderItemRelationship__c clonedOrdProdRelObj = eachordProdRel.clone(false, true, false, false);
            if (clonedOrdProdRelObj.vlocity_cmt__OrderItemId__c != null) {
                String clonedOrderItemId = mapOfOriginalOliIdByClonedOliId.get(clonedOrdProdRelObj.vlocity_cmt__OrderItemId__c);
                System.debug('clonedOrderItemId'+clonedOrderItemId);
                clonedOrdProdRelObj.vlocity_cmt__OrderItemId__c = clonedOrderItemId;
                clonedOrdProdRelObj.vlocity_cmt__OrderId__c = mapOfCloneOrderItemtoOrderID.get(clonedOrderItemId);
            }
            if (clonedOrdProdRelObj.vlocity_cmt__RelatedOrderItemId__c != null) {
                clonedOrdProdRelObj.vlocity_cmt__RelatedOrderItemId__c = mapOfOriginalOliIdByClonedOliId.get(clonedOrdProdRelObj.vlocity_cmt__RelatedOrderItemId__c);
            }
            clonedOrdProdRelList.add(clonedOrdProdRelObj);
        }
        
        if (clonedOrdProdRelList.size() > 0) {
            Insert clonedOrdProdRelList;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        ID jobId = Database.executeBatch(new ARTL_ValidateCart(originalOrderId, OrdersToDelete), 50);
    }
}