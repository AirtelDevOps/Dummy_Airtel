/************************************************************************************************************************************************************************************************************
* @Author       : Akshay Kaushik <akshay.kaushik@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 09/11/2023
* @Test Class   : ARTL_CreateSubOrdersTest
* @Description  : Create Sub orders according to root item custom logic
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
*     Developer               Date                Comment
* ------------------      ---------------       -----------    
*  Akshay Kaushik          09/11/2023           Initial Dev
******************************************************************************************************************************************************************************************************************/
global class ARTL_CreateSubOrderCustomLogic implements Database.Batchable < sObject > , Database.Stateful {
    global String orderId;
    global Id PMID;
    global List<Id> OrdersToDelete = new List<Id>();
    Map < String, String > mapOfCloneOrderItemtoOrderID = new Map < String, String > ();
    Map < String, String > mapOfOriginalOliIdByClonedOliId = new Map < String, String > ();
    global ARTL_CreateSubOrderCustomLogic(String orderId,Id PMID) {
        this.orderId = orderId;
        this.PMID = PMID;
        system.debug('orderId==>'+ orderId);
        system.debug('PMID==>'+ PMID);
        List<OrderItem> lstOIs = [SELECT Id, Quantity, vlocity_cmt__LineNumber__c, OrderId from OrderItem
                                 WHERE vlocity_cmt__ParentItemId__c = null AND OrderId =: orderId];
        system.debug('lstOIs Size==>'+lstOIs.size());
        system.debug('lstOIs==>'+lstOIs);
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT vlocity_cmt__AssetReferenceId__c,Quantity,OrderId FROM OrderItem' +
                                        ' WHERE vlocity_cmt__ParentItemId__c = null AND OrderId = \'' + orderId + '\'');
    }
    global void execute(Database.BatchableContext BC, List < OrderItem > OrderItemsList) {
        
        Map < String, Schema.SObjectType > schemaMap = Schema.getGlobalDescribe();
        Set < String > OrderItemFieldMap = schemaMap.get('OrderItem').getDescribe().fields.getMap().keySet();
        List < String > OrderItemFinalFields = new List < String > ();
        OrderItemFinalFields.addAll(OrderItemFieldMap);
        Set < String > OrderFieldMap = schemaMap.get('Order').getDescribe().fields.getMap().keySet();
        List < String > OrderFinalFields = new List < String > ();
        OrderFinalFields.addAll(OrderFieldMap);
        
        List < Order > clonedOrders = new List < Order > ();
        List < OrderItem > clonedOrderitems = new List < OrderItem > ();
        List < vlocity_cmt__OrderDiscount__c > clonedOrderdiscounts = new List < vlocity_cmt__OrderDiscount__c > ();
        List < vlocity_cmt__OrderDiscountPricing__c > clonedOrderdiscountpricings = new List < vlocity_cmt__OrderDiscountPricing__c > ();
        List < vlocity_cmt__OrderDiscountItem__c > clonedOrderdiscountitems = new List < vlocity_cmt__OrderDiscountItem__c > ();
        List < vlocity_cmt__OrderAppliedPromotion__c > clonedOrderappliedpromotions = new List < vlocity_cmt__OrderAppliedPromotion__c > ();
        List < vlocity_cmt__OrderPriceAdjustment__c > clonedOrderpriceadjustments = new List < vlocity_cmt__OrderPriceAdjustment__c > ();
        List < vlocity_cmt__OrderItemPriceAdjustment__c > clonedOrderitempriceadjustments = new List < vlocity_cmt__OrderItemPriceAdjustment__c > ();
        List < vlocity_cmt__OrderAppliedPromotionItem__c > clonedOrderappliedpromotionitems = new List < vlocity_cmt__OrderAppliedPromotionItem__c > ();
        for (OrderItem orderitemrec: OrderItemsList) {
            if (orderitemrec.Quantity > 1) {
                Id OrderItemId = orderitemrec.Id;
                for (integer i = 0; i < orderitemrec.Quantity; i++) {
                    String rootiitemId = orderitemrec.vlocity_cmt__AssetReferenceId__c;
                    String QueryforOrder = 'SELECT ' + String.join(OrderFinalFields, ',') +
                        ' FROM Order' +
                        ' WHERE Id =:orderId';
                    List < Order > listord = Database.query(QueryforOrder);
                    Order ord = listord[0];
                    Id ordId = ord.Id;
                    OrdersToDelete.add(ordId);
                    Order ClonedOrder = ord.clone(false, false, false, false);
                    insert ClonedOrder;
                    
                    
                    String Clonedorderid = ClonedOrder.Id;
                    String QueryforOrderItem = 'SELECT ' + String.join(OrderItemFinalFields, ',') +
                        ' FROM OrderItem' +
                        ' WHERE OrderId=:orderId AND id =:OrderItemId';
                    List < OrderItem > listorditem = Database.query(QueryforOrderItem);
                    for (OrderItem orditem: listorditem) {
                        String OrderId = ClonedOrder.id;
                        OrderItem ClonedOrderitem = orditem.clone(false, false, false, false);
                        ClonedOrderitem.OrderId = OrderId;
                        ClonedOrderitem.vlocity_cmt__ParentItemId__c = '';
                        ClonedOrderitem.vlocity_cmt__AssetReferenceId__c = '';
                        ClonedOrderitem.vlocity_cmt__RootItemId__c = '';
                        ClonedOrderitem.Quantity = 1;
                        insert ClonedOrderitem;
                        String ClonedOrderItemId = String.valueOf(ClonedOrderitem.id);
                        if(PMID!=null){
            OrderShare ordershareforPM = new OrderShare();
            ordershareforPM.OrderAccessLevel = 'Edit';
            ordershareforPM.OrderId=Clonedorderid;
            ordershareforPM.RowCause='Manual';
            ordershareforPM.UserOrGroupId=PMID;
            insert ordershareforPM;
                    }
                        mapOfCloneOrderItemtoOrderID.put(String.valueOf(ClonedOrderitem.Id), OrderId);
                        mapOfOriginalOliIdByClonedOliId.put(String.valueOf(orditem.id), String.valueOf(ClonedOrderitem.Id));
                    }
                }
            } 
            else {
                System.debug('quantity =1');
                String OrderIdtest = orderId;
                String rootiitemId = orderitemrec.vlocity_cmt__AssetReferenceId__c;
                String QueryforOrder2 = 'SELECT ' + String.join(OrderFinalFields, ',') +
                    ' FROM Order' +
                    ' WHERE Id =:OrderIdtest';
                List < Order > listord = Database.query(QueryforOrder2);
                Order ord = listord[0];
                Order ClonedOrder = ord.clone(false, false, false, false);
                Id ordId = ord.id;
                OrdersToDelete.add(ordId);
                insert ClonedOrder;
                
                String QueryforOrderItem = 'SELECT ' + String.join(OrderItemFinalFields, ',') +
                    ' FROM OrderItem' +
                    ' WHERE OrderId=:OrderIdtest AND vlocity_cmt__RootItemId__c =:rootiitemId';
                List < OrderItem > listorditem = Database.query(QueryforOrderItem);
                for (OrderItem orditem: listorditem) {
                    String OrderId = ClonedOrder.id;
                    OrderItem ClonedOrderitem = orditem.clone(false, false, false, false);
                    ClonedOrderitem.OrderId = OrderId;
                    ClonedOrderitem.vlocity_cmt__ParentItemId__c = '';
                    ClonedOrderitem.vlocity_cmt__AssetReferenceId__c = '';
                    ClonedOrderitem.vlocity_cmt__RootItemId__c = '';
                    insert ClonedOrderitem;
                    String OrderitemId = ClonedOrderitem.id;
                    String ExistingOrderitemId = listorditem[0].id;
                    if(PMID!=null){
            OrderShare ordershareforPM = new OrderShare();
            ordershareforPM.OrderAccessLevel = 'Edit';
            ordershareforPM.OrderId=OrderId;
            ordershareforPM.RowCause='Manual';
            ordershareforPM.UserOrGroupId=PMID;
            insert ordershareforPM;
                    }
                    mapOfCloneOrderItemtoOrderID.put(String.valueOf(ClonedOrderitem.Id), OrderId);
                    mapOfOriginalOliIdByClonedOliId.put(String.valueOf(orditem.id), String.valueOf(ClonedOrderitem.Id));
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        //SKumar
        ID jobId = Database.executeBatch(new ARTL_CreateOrderItemRelationship(orderId, mapOfOriginalOliIdByClonedOliId, mapOfCloneOrderItemtoOrderID, OrdersToDelete), 50);
    }
}