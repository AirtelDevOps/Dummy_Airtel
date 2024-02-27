public with sharing class artl_HansenOrderStatusController {
    public artl_HansenOrderStatusController() {
        
    }
    @AuraEnabled
    public Static List<String> getHansenOrderStatus (id orderId){
        List<String> statusList = new List<String>();
        List<OrderHistory> ordHistoryList = [SELECT id,NewValue from OrderHistory 
                                             where Field = 'ARTL_SOMOrder_Status__c' 
                                             and  OrderId =:orderId order by CreatedDate desc];    
        if(!ordHistoryList.isEmpty()){
            for(OrderHistory orderHist : ordHistoryList){
                statusList.add(JSON.serialize(orderHist.NewValue));
            }
        }
        return statusList;
    }
}