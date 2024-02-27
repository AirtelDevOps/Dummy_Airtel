global with sharing class ARTL_ModifyOrderItem implements vlocity_cmt.VlocityOpenInterface2 {
   
    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        Boolean result = true;
        try {
            if ('updateOrderItemAtt'.equalsIgnoreCase(methodName)) {
                updateOrderItemAtt(inputMap, outMap, options);
            } else {
                result = false;
            }
        } catch (Exception e) {
            result = false;
        }
        return result;
    }
   
    public void updateOrderItemAtt(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        Map<String, Object> oiSetlectedAttMap = new Map<String, Object>();
        String orderId = (String)inputMap.get('OrderId');
        String attributeName = (String)inputMap.get('AttributeName');
        String attributeValue = String.valueOf(inputMap.get('AttributeValue'));
        List<OrderItem> oiList = [select Id,vlocity_cmt__AttributeSelectedValues__c from OrderItem where OrderId =:orderId];
        if(oiList.size() > 0){
            for(OrderItem oi : oiList){
            if(oi.vlocity_cmt__AttributeSelectedValues__c != null){
                oiSetlectedAttMap = (Map<String, Object>) JSON.deserializeUntyped(oi.vlocity_cmt__AttributeSelectedValues__c);
                if(oiSetlectedAttMap.containsKey(attributeName)){
                    oiSetlectedAttMap.put(attributeName, attributeValue);
                }
                oi.vlocity_cmt__AttributeSelectedValues__c = JSON.serialize(oiSetlectedAttMap); 
            }
        }
        update oiList;
        outMap.put('OrderItemUpdated','Yes');
        }
    }
}