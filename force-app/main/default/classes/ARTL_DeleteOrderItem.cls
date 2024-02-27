/**
* Class to delete OrderItem Relationship 
*
* @Author  Harika
* @Company Salesforce 
* @Date    09/02/2024
* @Description  To delete OrderItem Relationship during Order Cancellation Journey
*/

global without sharing class ARTL_DeleteOrderItem implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
        try {
            
            if (methodName.equals('deleteOrderItem')) {
                deleteOrderItem(input, outMap, options);
                return true;
            } else if(methodName == 'deleteRelOrderItemAmend'){
                deleteRelOrderItemAmend(input,outMap,options);
                return true;
            }  else if(methodName == 'createOrdertemIRel'){
                createOrdertemIRel(input,outMap,options);
                return true;
            } 
        } catch (Exception ex) {
            System.debug('DEBUGG ' + ex.getMessage() + ' ' + ex.getLineNumber());
            
        }
        return false;
    }
    
    public static void deleteOrderItem(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){
        
        String orderId = String.valueOf(input.get('CartId')); 
        
        List<vlocity_cmt__OrderItemRelationship__c> ordItemRel = [Select Id from vlocity_cmt__OrderItemRelationship__c where vlocity_cmt__OrderId__c =:orderId ];
        
        if(ordItemRel.size()>0)
        {
            delete ordItemRel;
        }
        
    }
    
    //Amend
    public static void deleteRelOrderItemAmend(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){
        
        String orderId = String.valueOf(input.get('CartId')); 
        Map<Id,Id> oiAndOIRelMap = new Map<Id,Id>();
        List<vlocity_cmt__OrderItemRelationship__c> ordItemRel = [Select Id,vlocity_cmt__OrderItemId__c, vlocity_cmt__RelatedOrderItemId__c from vlocity_cmt__OrderItemRelationship__c where vlocity_cmt__OrderId__c =:orderId ];
        if(ordItemRel.size()>0)
        {
            for(vlocity_cmt__OrderItemRelationship__c oir : ordItemRel){
                oiAndOIRelMap.put(oir.vlocity_cmt__OrderItemId__c,oir.vlocity_cmt__RelatedOrderItemId__c);
            }
            List<OrderItem> oiToUpdate = new List<OrderItem>();
            for(OrderItem oi: [select Id,vlocity_cmt__ReliesOnItemId__c from OrderItem  where OrderId =:orderId]){
                if(oiAndOIRelMap.containsKey(oi.Id)){
                    oi.vlocity_cmt__ReliesOnItemId__c = oiAndOIRelMap.get(oi.Id);
                    oiToUpdate.add(oi);
                }
            }
            if(oiToUpdate.size()>0)
                update oiToUpdate;
            delete ordItemRel;
        }
    }
    
    //Amend - create Order Item Relationship
    public static void createOrdertemIRel(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){
        String supplementalOrderId = String.valueOf(input.get('supplementalOrderId')); 
        List<vlocity_cmt__OrderItemRelationship__c> ordItemRel =  new  List<vlocity_cmt__OrderItemRelationship__c>();
        for(OrderItem oi: [Select Id,vlocity_cmt__SupersededOrderItemId__r.vlocity_cmt__ReliesOnItemId__c  from 
                           OrderItem where vlocity_cmt__SupersededOrderItemId__r.vlocity_cmt__ReliesOnItemId__c != null and OrderId =:supplementalOrderId]){
                               vlocity_cmt__OrderItemRelationship__c oir = new vlocity_cmt__OrderItemRelationship__c();
                               oir.vlocity_cmt__RelationshipType__c = 'ReliesOn';
                               oir.vlocity_cmt__OrderId__c= supplementalOrderId;
                               oir.vlocity_cmt__OrderItemId__c=oi.Id;
                               oir.vlocity_cmt__RelatedOrderItemId__c =oi.vlocity_cmt__SupersededOrderItemId__r.vlocity_cmt__ReliesOnItemId__c;
                               ordItemRel.add(oir);
                           }
        if(ordItemRel.size()>0)
            insert ordItemRel;
    }
    
}