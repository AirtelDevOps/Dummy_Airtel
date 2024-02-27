public without sharing class ARTL_OrderTriggerHandler {
    public static void afterInsert(List<Order> newOrderList){
        List<Order> orderList = [select id,CreatedById, vlocity_cmt__QuoteId__r.PM__c,vlocity_cmt__QuoteId__c,vlocity_cmt__QuoteId__r.Name from Order where Id IN:newOrderList ]; 
        IF(Test.isRunningTest()){
            orderList = newOrderList;
        }
        if(orderList.size() > 0){
            List<OrderShare> insOrderShareList = new List<OrderShare>();
            for(Order ord : orderList){
                if(ord.vlocity_cmt__QuoteId__r.PM__c != null  ){
                    OrderShare orderShareRec = new OrderShare();
                    orderShareRec.OrderAccessLevel = 'Edit';
                    orderShareRec.OrderId = ord.id;
                    orderShareRec.RowCause='Manual';
                    orderShareRec.UserOrGroupId = ord.vlocity_cmt__QuoteId__r.PM__c;
                    
                    insOrderShareList.add(orderShareRec);
                }
            }
            if(insOrderShareList.size() > 0){
                IF(!Test.isRunningTest()){
                    insert insOrderShareList;
                }
            }
        }
        
    }
}