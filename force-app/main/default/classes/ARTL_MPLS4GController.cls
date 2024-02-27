global class ARTL_MPLS4GController implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
    public static String PRIMARY_MPLS_LINK = 'c28fb5dd-d072-4c1c-b7da-80046db82cf0';
    public static String SECONDARY_MPLS_LINK = '0c8bc86e-c30b-41dd-9077-13c1d2c54ed2';
    public static String INFRA_4G = 'c9958738-b03b-4ca7-b122-d732cf1e0f40';
    
    public void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items)
    {
        String cartId;
        List<id> orchitemids = new List<id>();
        List<id> orderids = new List<id>();
        
        for(vlocity_cmt__OrchestrationItem__c orchitemRec :items){
            orchitemids.add(orchitemRec.id);            
        }
        List<vlocity_cmt__OrchestrationPlan__c> orchPlanList = [select vlocity_cmt__OrderId__c 
                                                                from vlocity_cmt__OrchestrationPlan__c 
                                                                where id in (select vlocity_cmt__OrchestrationPlanId__c 
                                                                             from vlocity_cmt__OrchestrationItem__c where id in :orchitemids)];
        for(vlocity_cmt__OrchestrationPlan__c orchPlanRec:orchPlanList){
            orderids.add(orchPlanRec.vlocity_cmt__OrderId__c);
        } 
        
        system.debug('orderids==>'+orderids);
        list<OrderItem> ordItmList = [Select Id,vlocity_cmt__AttributeSelectedValues__c,Order.Status,
                                      Order.vlocity_cmt__OrderStatus__c,Order.vlocity_cmt__ParentOrderId__c,Order.AccountId,Order.vlocity_cmt__DefaultServiceAccountId__c,
                                      Order.vlocity_cmt__DefaultBillingAccountId__c,Order.QuoteId,vlocity_cmt__BillingAccountId__c,
                                      OrderId,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__Product2Id__r.ProductCode,RFS__c,CND__c,ARTL_4GUniqueKey__c, ARTL_Media__c,vlocity_cmt__ServiceAccountId__c  
                                      From OrderItem where OrderId IN :orderids AND (Order.vlocity_cmt__OrderStatus__c ='In Progress' OR Order.vlocity_cmt__OrderStatus__c ='Ready To Submit')  
                                      AND (vlocity_cmt__Product2Id__r.ProductCode =:PRIMARY_MPLS_LINK
                                           OR vlocity_cmt__Product2Id__r.ProductCode =:SECONDARY_MPLS_LINK) limit 1];
        if(!ordItmList.isEmpty()){
            Integer noOfLicense4G =  ordItmList.size();
            //Media is 4G, get unique key, then search in Asset using Unique Key. if Asset present 
            Map<String, Object> attributeOLIMap = (Map<String, Object>) JSON.deserializeUntyped(ordItmList[0].vlocity_cmt__AttributeSelectedValues__c);
            if(ordItmList[0].ARTL_Media__c == '4G' && ordItmList[0].ARTL_4GUniqueKey__c != null){
                String uniqueKey = ordItmList[0].ARTL_4GUniqueKey__c;
                List<Asset>  lstAsset = [Select Id, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__BillingAccountId__c, vlocity_cmt__ServiceAccountId__c 
                                         FROM Asset WHERE ARTL_4GUniqueKey__c =:uniqueKey AND vlocity_cmt__ProvisioningStatus__c = 'Active' and Product2.ProductCode=:INFRA_4G];
                Map<String,Object> jsonForMACD = new Map<String,Object>();
                Map<String, Object> ipOutput = new Map<String, Object> ();
                if(!lstAsset.isEmpty()){
                    //create a MACD order and increase the number of licenses to current value +1
                    jsonForMACD.put('AssetId',lstAsset[0].Id);
                    jsonForMACD.put('AttributeName','ATT_NUMBER_OF_LICENCES');
                    if(attributeOLIMap.get('ATT_NUMBER_OF_LICENCES')!=NULL)
                    {
                        jsonForMACD.put('AttributeValue',(noOfLicense4G + (Integer)attributeOLIMap.get('ATT_NUMBER_OF_LICENCES')));
                    }
                    else
                    {
                        jsonForMACD.put('AttributeValue',noOfLicense4G);
                    }
                    jsonForMACD.put('Account',ordItmList[0].Order.AccountId);
                    jsonForMACD.put('BillingAccount',lstAsset[0].vlocity_cmt__BillingAccountId__c);
                    jsonForMACD.put('ServiceAccount',lstAsset[0].vlocity_cmt__ServiceAccountId__c);
                    System.debug('jsonForMACD11 : '+JSON.serializePretty(jsonForMACD));
                    
                    ipOutput = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService('ARTLOM_ModifyOrder', jsonForMACD, new Map<String,Object>());
                    System.debug('ipOutput11 : '+JSON.serializePretty(ipOutput));
                    cartId = String.valueOf(ipOutput.get('CartId'));
                    if(!String.isBlank(cartId)){
                        Order orderRecord = new Order();
                        orderRecord.Id = cartId;
                        orderRecord.RecordTypeId = [select Id,DeveloperName from RecordType where DeveloperName = 'SubOrder' limit 1].Id;
                        orderRecord.vlocity_cmt__ParentOrderId__c = ordItmList[0].Order.vlocity_cmt__ParentOrderId__c;
                        orderRecord.Name = '4GOrder';
                        update orderRecord;
                    }
                    Map<String,Object> inpMap = new Map<String,Object>();
                    Map<String, Object> outMap = new Map<String, Object> ();
                    inpMap.put('CartId',cartId);
                    System.debug('inpMap : '+JSON.serializePretty(inpMap));
                    
                    outMap = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService('ARTLOM_ValidateSubmitOrder', inpMap, new Map<String,Object>());
                    System.debug('outMap : '+JSON.serializePretty(outMap));
                   
                }
                else{
                    list<OrderItem> orderItemList = [Select Id,vlocity_cmt__AttributeSelectedValues__c,Order.Status,
                                                     Order.vlocity_cmt__OrderStatus__c,Order.AccountId,Order.vlocity_cmt__DefaultServiceAccountId__c,
                                                     Order.vlocity_cmt__DefaultBillingAccountId__c,Order.QuoteId,vlocity_cmt__BillingAccountId__c,
                                                     OrderId,vlocity_cmt__Product2Id__r.Name,ARTL_4GUniqueKey__c, ARTL_Media__c,vlocity_cmt__ServiceAccountId__c  
                                                     From OrderItem where OrderId IN :orderids AND (Order.vlocity_cmt__OrderStatus__c ='In Progress' OR Order.vlocity_cmt__OrderStatus__c ='Ready To Submit')  
                                                     AND vlocity_cmt__Product2Id__r.ProductCode =:INFRA_4G AND ARTL_4GUniqueKey__c =:uniqueKey  limit 1];
                    if(orderItemList.isEmpty()){
                        
                        PricebookEntry PricebookEntry4GRecord = [select id,Product2.name from PricebookEntry where Product2.ProductCode=:INFRA_4G];
                        list<QuoteLineItem> QuoteItmList = [Select vlocity_cmt__QuoteMemberId__c From QuoteLineItem where QuoteId =:ordItmList[0].Order.QuoteId   
                                                            AND vlocity_cmt__Product2Id__r.ProductCode =:PRIMARY_MPLS_LINK limit 1];
                        Map<String,Object> attrMap = new Map<String,Object>();
                        jsonForMACD.put('AccountId',ordItmList[0].Order.AccountId);
                        jsonForMACD.put('QuoteId',ordItmList[0].Order.QuoteId);
                        jsonForMACD.put('BillingAccountId',ordItmList[0].vlocity_cmt__BillingAccountId__c);
                        jsonForMACD.put('ServiceAccountId',ordItmList[0].vlocity_cmt__ServiceAccountId__c);
                        jsonForMACD.put('ParentOrderId',ordItmList[0].Order.vlocity_cmt__ParentOrderId__c);
                        if(ordItmList[0].CND__c!=NULL)
                        {
                            jsonForMACD.put('CustomerNeedByDate',ordItmList[0].CND__c.format());
                        }
                        if(ordItmList[0].RFS__c!=NULL)
                        {
                            jsonForMACD.put('RFSDate',ordItmList[0].RFS__c.format());
                        }
                        if(!QuoteItmList.isEmpty()){
                            attrMap.put('ATT_INSTALLATION_LOCATION_ID',String.valueOf(QuoteItmList[0].vlocity_cmt__QuoteMemberId__c));
                        }
                        if(PricebookEntry4GRecord!=NULL)
                        {
                            jsonForMACD.put('PricebookEntryId',PricebookEntry4GRecord.Id);
                        }
                        attrMap.put('ATT_NUMBER_OF_LICENCES',attributeOLIMap.get('ATT_NUMBER_OF_LICENCES'));
                        attrMap.put('ATT_VPN_TYPE',attributeOLIMap.get('ATT_VPN_TYPE'));
                        attrMap.put('ATT_VPN_NAME',attributeOLIMap.get('ATT_VPN_NAME'));
                        attrMap.put('ATT_VPN_TOPOLOGY',attributeOLIMap.get('ATT_VPN_TOPOLOGY'));
                        attrMap.put('ATT_SERVICE_TYPE',attributeOLIMap.get('ATT_SERVICE_TYPE'));
                        attrMap.put('ATT_PORT_BANDWIDTH',attributeOLIMap.get('ATT_PORT_BANDWIDTH'));
                        attrMap.put('ATT_ROUTING_TYPE',attributeOLIMap.get('ATT_ROUTING_TYPE_MPLS'));
                        attrMap.put('ATT_BILL_PLAN',attributeOLIMap.get('ATT_BILL_PLAN'));
                        attrMap.put('ATT_MEDIA',attributeOLIMap.get('ATT_MEDIA'));
                        attrMap.put('ATT_MPLS_ProductType_CME',attributeOLIMap.get('ATT_MPLS_ProductType_CME'));
                        attrMap.put('ATT_CONTRACT_TERM',attributeOLIMap.get('ATT_CONTRACT_TERM'));
                        attrMap.put('ATT_LAST_MILE',attributeOLIMap.get('ATT_LAST_MILE'));
                        jsonForMACD.put('Attributes',attrMap);
                        System.debug('jsonForMACD : '+JSON.serializePretty(jsonForMACD));
                        ipOutput = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService('ARTLOM_CreateOrder', jsonForMACD, new Map<String,Object>());
                        System.debug('ipOutput : '+JSON.serializePretty(ipOutput));
                        cartId = String.valueOf(ipOutput.get('CartId'));
                    }else{
                        cartId = orderItemList[0].OrderId;
                    }
                }
            }
            if(Test.isRunningTest()){
            cartId = [Select Id from Order where Name = 'Target Order' limit 1].Id; 
        }
            if(!String.isBlank(cartId)){
                list<OrderItem> orderItemList = [Select Id,vlocity_cmt__AttributeSelectedValues__c,Order.Status,
                                                 Order.vlocity_cmt__OrderStatus__c,Order.AccountId,Order.vlocity_cmt__DefaultServiceAccountId__c,
                                                 Order.vlocity_cmt__DefaultBillingAccountId__c,Order.QuoteId,vlocity_cmt__BillingAccountId__c,
                                                 OrderId,vlocity_cmt__Product2Id__r.Name,ARTL_4GUniqueKey__c, ARTL_Media__c,vlocity_cmt__ServiceAccountId__c  
                                                 From OrderItem where OrderId=:cartId AND vlocity_cmt__Product2Id__r.ProductCode =:INFRA_4G limit 1];
                
                if(!orderItemList.isEmpty()){
                    vlocity_cmt__OrderItemRelationship__c ordItemRel = new vlocity_cmt__OrderItemRelationship__c();
                    if(ordItmList[0].vlocity_cmt__Product2Id__r.ProductCode == SECONDARY_MPLS_LINK)
                    {
                        ordItemRel.vlocity_cmt__OrderItemId__c = ordItmList[0].Id;
                    }
                    else
                    {
                        list<OrderItem> orderItemListValue = [Select Id From OrderItem where OrderId IN :orderids AND vlocity_cmt__ParentItemId__c = NULL];
                        
                        if(!orderItemListValue.isEmpty()){  
                            
                            ordItemRel.vlocity_cmt__OrderItemId__c = orderItemListValue[0].Id;
                        }
                        
                    }
                    ordItemRel.vlocity_cmt__RelatedOrderItemId__c = orderItemList[0].Id;
                    ordItemRel.vlocity_cmt__RelationshipType__c = 'ReliesOn';
                    ordItemRel.vlocity_cmt__OrderId__c = ordItmList[0].OrderId;
                    insert ordItemRel;
                    Order ord = new Order();
                    ord.Id = ordItmList[0].OrderId;
                    ord.Order_with_ReliesOn__c = cartId;
                    update ord;
                    orderItemList[0].ARTL_4GUniqueKey__c =  ordItmList[0].ARTL_4GUniqueKey__c;
                    Update orderItemList[0];
                }
            }
        }
        
    }
    
}