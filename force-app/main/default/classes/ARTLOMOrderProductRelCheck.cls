global class ARTLOMOrderProductRelCheck implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask{
    
    global void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items){
        for (vlocity_cmt__OrchestrationItem__c item : items)
        {
            System.debug('orch item ->'+item.Id);
            vlocity_cmt__OrchestrationItem__c orchItem =[Select Id,vlocity_cmt__OrderItemId__r.Product2.ProductCode,vlocity_cmt__OrderItemId__c,vlocity_cmt__OrderItemId__r.OrderId
                                                         FROM vlocity_cmt__OrchestrationItem__c WHERE Id=:item.Id];
            Id oiRootId = [Select Id from OrderItem where vlocity_cmt__ParentItemId__c = null and orderId =:orchItem.vlocity_cmt__OrderItemId__r.OrderId limit 1].Id; 
            vlocity_cmt__OrderItemRelationship__c[] ordItemRelationship = [SELECT Id,vlocity_cmt__OrderItemId__r.Product2.ProductCode,vlocity_cmt__RelatedOrderItemId__r.Product2.ProductCode,
                                                                           vlocity_cmt__OrderItemId__c,vlocity_cmt__RelatedOrderItemId__c
                                                                           from vlocity_cmt__OrderItemRelationship__c where vlocity_cmt__OrderItemId__c =: oiRootId ] ;
            System.debug('orch item rel size ->'+ordItemRelationship.size());
            if (ordItemRelationship.size() > 0){
                vlocity_cmt__OrderItemRelationship__c[] rdItem = [Select id from vlocity_cmt__OrderItemRelationship__c where (vlocity_cmt__OrderItemId__c !=: oiRootId )AND 
                                                                  (vlocity_cmt__RelatedOrderItemId__c =:  ordItemRelationship[0].vlocity_cmt__RelatedOrderItemId__c) AND
                                                                  (vlocity_cmt__OrderItemId__r.Order.vlocity_cmt__OrderStatus__c  = 'In Progress' OR vlocity_cmt__OrderItemId__r.Order.vlocity_cmt__OrderStatus__c  ='Ready To Submit' ) ];
                if(rdItem.size() < 1){
                    OrderItem oiUpdate = new OrderItem();
                    oiUpdate.Id = ordItemRelationship[0].vlocity_cmt__RelatedOrderItemId__c;
                    oiUpdate.ARTL_4GAssetCreation__c = true;
                    update oiUpdate;
                }
            }
        }
    }
    
}