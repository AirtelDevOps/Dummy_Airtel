global with sharing class ARTL_UpdateSubOrderForMRR {
  @InvocableMethod(label = 'Update Suborder for MRR')
    global static void updateOLIforMRR(List<UpdateSubOrderInput> input){
        system.debug('input***'+input);
        Id mrrId = input[0].MrrId;
        List<Material_Received_Request__c> mrrList = [Select Id,Name,ItemCode__c,Master_Order__c From Material_Received_Request__c Where Id =: mrrId];
        List<Purchase_Order__c> poList = [select id,SupplierName__c,SupplierSite__c,PONumber__c from Purchase_Order__c where ItemCode__c  =: mrrList[0].ItemCode__c];
        List<ARTL_Purchase_Request__c> prList = [select id,PR_ID__c from ARTL_Purchase_Request__c  where Item_Code__c   =: mrrList[0].ItemCode__c];
        //List<OrderItem> oiList = [Select Id,Order.vlocity_cmt__OrderStatus__c,OrderId From OrderItem Where Order.POId__c = null and ARTL_ItemCode__c =: mrrList[0].ItemCode__c];
        Set<Id> updateAttOrderIds = new Set<Id>();
        List<Order> ordersToUpdate = new List<Order>();
         /* create RA task for each suborder*/
        List<order> orderList = [
                                select id,vlocity_cmt__ParentOrderId__c, vlocity_cmt__OrderStatus__c,vlocity_cmt__QuoteId__c,
                                vlocity_cmt__QuoteId__r.PM__c
                                from order 
                                where vlocity_cmt__ParentOrderId__c != '' 
                                AND vlocity_cmt__ParentOrderId__c =: mrrList[0].Master_Order__c
                                ];
                                
        for(Order ord: orderList){
            Order orUpdate = new Order();
            orUpdate.Id = ord.Id;
            orUpdate.PRID__c = prList[0].Id;
            orUpdate.POId__c = poList[0].Id;
            orUpdate.MRRNumber__c = mrrId;
            ordersToUpdate.add(orUpdate);
            if(ord.vlocity_cmt__OrderStatus__c == 'In Progress'){
                updateAttOrderIds.add(ord.Id);
            }
        } 
            
        if(ordersToUpdate.size() > 0)
            update ordersToUpdate;

       
        List<Task> taskToCreateList = new List<Task>();
        for(Order ord: orderList){
            Task raTask = new task();
            raTask.WhatId = ord.Id ;
            raTask.OwnerId = ord.vlocity_cmt__QuoteId__r.PM__c != null ? ord.vlocity_cmt__QuoteId__r.PM__c : UserInfo.getUserId();
            raTask.ARTL_TaskType__c = 'RA';
            raTask.Subject = 'RA';
            raTask.Status = 'open';
            taskToCreateList.add(raTask);

        }
        if(taskToCreateList.size() > 0){
            insert taskToCreateList;
        }

        List<vlocity_cmt__FulfilmentRequestLine__c> ffrList = [SELECT id, vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__r.Account.ARTL_Business_Unit__c,ARTL_RateSpecKey__c,   
                                                               vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c FROM vlocity_cmt__FulfilmentRequestLine__c WHERE (vlocity_cmt__Product2Id__r.ProductCode = 'VEPC_NIPS_HARDWARE_CFS' OR vlocity_cmt__Product2Id__r.ProductCode = 'VEPC_NIPS_COMPOSITE_CFS') 
                                                               AND vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c IN:updateAttOrderIds];
        if(ffrList.size() > 0){
            for(vlocity_cmt__FulfilmentRequestLine__c ffr : ffrList){
                Map<String, Object> friPriStringMap = new Map<String, Object> ();
                if(ffr.vlocity_cmt__AttributeSelectedValues__c != NULL){
                    friPriStringMap = (Map<String, Object>) JSON.deserializeUntyped(ffr.vlocity_cmt__AttributeSelectedValues__c);
                    if(friPriStringMap != NULL){
                        if(ffr.vlocity_cmt__Product2Id__r.ProductCode == 'VEPC_NIPS_HARDWARE_CFS'){
                            if(friPriStringMap.containsKey('ATT_SUPPLIER_NAME')){
                                if(friPriStringMap.get('ATT_SUPPLIER_NAME') != NULL){
                                    friPriStringMap.put('ATT_SUPPLIER_NAME',poList[0].SupplierName__c);
                                }
                            }
                            if(friPriStringMap.containsKey('ATT_SUPPLIER_ADDRESS')){
                                if(friPriStringMap.get('ATT_SUPPLIER_ADDRESS') != NULL){
                                    friPriStringMap.put('ATT_SUPPLIER_ADDRESS',poList[0].SupplierSite__c);
                                }
                            }
                        }else if(ffr.vlocity_cmt__Product2Id__r.ProductCode == 'VEPC_NIPS_COMPOSITE_CFS'){
                            if(friPriStringMap.containsKey('ATT_VENDOR_PO_NUMBER')){
                                if(friPriStringMap.get('ATT_VENDOR_PO_NUMBER') != NULL){
                                    friPriStringMap.put('ATT_VENDOR_PO_NUMBER',poList[0].PONumber__c);
                                }
                            }
                            if(friPriStringMap.containsKey('ATT_VENDOR_PR_NUMBER')){
                                if(friPriStringMap.get('ATT_VENDOR_PR_NUMBER') != NULL){
                                    friPriStringMap.put('ATT_VENDOR_PR_NUMBER',prList[0].PR_ID__c);
                                }
                            }
                            if(friPriStringMap.containsKey('ATT_VENDOR_NAME')){
                                if(friPriStringMap.get('ATT_VENDOR_NAME') != NULL){
                                    friPriStringMap.put('ATT_VENDOR_NAME',poList[0].SupplierName__c);
                                }
                            }
                        }
                    }
                }
                String FRLAttString = JSON.serialize(friPriStringMap); 
                ffr.vlocity_cmt__AttributeSelectedValues__c = FRLAttString;
            }
            update ffrList;
        }
        
    }
    
    global class UpdateSubOrderInput
    {
        @InvocableVariable(label = 'Mrr Record') global String MrrId;
        
    }
}