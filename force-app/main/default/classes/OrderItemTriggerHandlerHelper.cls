public class OrderItemTriggerHandlerHelper {
    
    /*public static void createPMApprovalTask(map<Id,OrderItem> newmap){
     	List<Task> lsttobeInsert = new List<Task>();
        for(OrderItem oli : [Select Id,QuoteLineItemId,Order.Record_Type_Name__c,Order.vlocity_cmt__QuoteId__r.PM__c,
                             vlocity_cmt__ParentItemId__c
                            FROM OrderItem WHERE Id IN: newmap.keyset() AND vlocity_cmt__ParentItemId__c = null]){
            if(oli.vlocity_cmt__ParentItemId__c == null){
                lsttobeInsert.add(new Task(
                Subject ='PM Approval',
                WhatId = oli.OrderId,
                Type = 'PM Approval',
                ARTL_TaskType__c ='PM Approval',    
                Quote_Line_Item__c = oli.QuoteLineItemId,
                ARTL_Order_Type__c = oli.Order.Record_Type_Name__c,  
                OwnerId = oli.Order.vlocity_cmt__QuoteId__r.PM__c != null ? oli.Order.vlocity_cmt__QuoteId__r.PM__c : UserInfo.getUserId()
                ));
            }
        }
        if(!lsttobeInsert.isEmpty()){
            insert lsttobeInsert;
        }
    }*/
    /*public static void updateTechnicalAttribute(List<OrderItem> lstOrderItems){
        Map<String,OrderItem> mapOfQuoteLineWithOLI = new Map<String,OrderItem>();
        for(OrderItem oli : lstOrderItems){
            if(oli.QuoteLineItemId != null)
            	mapOfQuoteLineWithOLI.put(oli.QuoteLineItemId, oli);
        }
        List<XLI_Technical_Attribute__c> lstExistingXLI = [Select Id, Order_Line_Item__c,Quote_Line_Item__c
                                                          FROM XLI_Technical_Attribute__c
                                                          WHERE Quote_Line_Item__c IN:mapOfQuoteLineWithOLI.keySet()];
        if(!lstExistingXLI.IsEmpty()){
            for(XLI_Technical_Attribute__c xli: lstExistingXLI){
                if(xli.Quote_Line_Item__c != null && mapOfQuoteLineWithOLI.containsKey(xli.Quote_Line_Item__c)){
                    OrderItem objoli = new OrderItem();
                    xli.Order_Line_Item__c = mapOfQuoteLineWithOLI.get(xli.Quote_Line_Item__c).Id;
                }
            }
            update lstExistingXLI;
        }
    }*/
    //SFDC-1933
    /*public static void createandUpdateXLI(List<OrderItem> lstOrderItems){
        Set<Id> setOfrootItemIds = new Set<Id>();
        Map<String, OrderItem> mapOfwithOrder = new Map<String, OrderItem>();
        for(OrderItem oli: lstOrderItems){
            if(oli.vlocity_cmt__ParentItemId__c  == null && oli.vlocity_cmt__SupersededOrderItemId__c != null){
                mapOfwithOrder.put(oli.vlocity_cmt__SupersededOrderItemId__c, oli);
            }
        }
        List<XLI_Technical_Attribute__c> lstOfxlitobeUpsert = new List<XLI_Technical_Attribute__c>();
        for(XLI_Technical_Attribute__c xli : [Select Id,AttributeMetadataChanges__c,Order_Line_Item__c,Quote_Line_Item__c,
                                              Root_Quote_Line_Item__c,ARTL_Status__c,Technical_Attribute__c,
                                              Technical_Attribute_Metadata__c,
                                              Technical_Product__c FROM XLI_Technical_Attribute__c 
                                              WHERE Order_Line_Item__c IN:mapOfwithOrder.keySet() 
                                              AND Order_Line_Item__r.Order.vlocity_cmt__SupplementalAction__c = 'Amend'
                                              AND ARTL_Status__c = 'Active']){
                XLI_Technical_Attribute__c cloneObj = xli.clone();
                cloneObj.Id = null;
				if(mapOfwithOrder.containsKey(xli.Order_Line_Item__c)){
                      cloneObj.Order_Line_Item__c = mapOfwithOrder.get(xli.Order_Line_Item__c).Id;
                      xli.ARTL_Status__c = 'InActive';
                    lstOfxlitobeUpsert.add(cloneObj);
                    lstOfxlitobeUpsert.add(xli);
				}                                     
            	                                      
        }
        if(!lstOfxlitobeUpsert.isEmpty()){
            upsert lstOfxlitobeUpsert;
        }
    }*/
}