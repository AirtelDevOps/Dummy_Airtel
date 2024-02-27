global class ARTLUpdateRateValues implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {

    public void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items)
    {	system.debug('inside update rate value batch');
        List<vlocity_cmt__FulfilmentRequestLine__c> FRLRecordsToUpdate = new List<vlocity_cmt__FulfilmentRequestLine__c>();
        List<id> orchitemids = new List<id>(); 
        for(vlocity_cmt__OrchestrationItem__c orchitemRec :items){
			orchitemids.add(orchitemRec.id);            
        }
        List<id> orderids = new List<id>();
        List<vlocity_cmt__FulfilmentRequestLine__c> ListOfEligibleFRLs = new List<vlocity_cmt__FulfilmentRequestLine__c>();
        List<vlocity_cmt__FulfilmentRequestLine__c> updatedFRL = new List<vlocity_cmt__FulfilmentRequestLine__c>();
        List<vlocity_cmt__OrchestrationPlan__c> orchPlanList = [select vlocity_cmt__OrderId__c from vlocity_cmt__OrchestrationPlan__c where id in (select vlocity_cmt__OrchestrationPlanId__c from vlocity_cmt__OrchestrationItem__c where id in :orchitemids)];
        for(vlocity_cmt__OrchestrationPlan__c orchPlanRec:orchPlanList){
            orderids.add(orchPlanRec.vlocity_cmt__OrderId__c);
        }
        list <id> FRLids = new List<id>();
        Set<Id> intRelOrdItmIds = new Set<Id>();
        Set<Id> secIntRelOrdItmIds = new Set<Id>();
        //List<id> ordItemIds = new List<Id>();
        list<OrderItem> ordItmList = [Select Id , Annual_Recurring_Charge__c , UnitPrice, ARTL_LSI__c ,vlocity_cmt__RootItemId__c,vlocity_cmt__ParentItemId__c, vlocity_cmt__OneTimeCharge__c,OrderId,vlocity_cmt__Product2Id__r.Name From OrderItem where OrderId IN :orderids];
        Set<Id> parentInternetOrdItmList = new Set<Id>();
        Set<Id> parentSecInternetOrdItmList = new Set<Id>();
     	Set<Id> infraOrdItmList = new Set<Id>();
        for(OrderItem ordItem : ordItmList){
            system.debug('ordItem.UnitPrice'+ordItem.UnitPrice);
            system.debug('ordItem.vlocity_cmt__Product2Id__r.Name --->' + ordItem.vlocity_cmt__Product2Id__r.Name);
            if(ordItem.vlocity_cmt__Product2Id__r.Name == 'Internet' || ordItem.vlocity_cmt__Product2Id__r.Name == 'MPLS'){
                system.debug('ordItem.vlocity_cmt__Product2Id__r.Name inside if --->' + ordItem.vlocity_cmt__Product2Id__r.Name);
                parentInternetOrdItmList.add(ordItem.Id);
            }
            if(ordItem.vlocity_cmt__Product2Id__r.Name == 'Secondary Internet Link' || ordItem.vlocity_cmt__Product2Id__r.Name == 'Secondary MPLS Link' || ordItem.vlocity_cmt__Product2Id__r.Name == 'MPLS'){
                system.debug('ordItem.vlocity_cmt__Product2Id__r.Name insidde if --->' + ordItem.vlocity_cmt__Product2Id__r.Name);
                parentSecInternetOrdItmList.add(ordItem.Id);
            }
            if(ordItem.vlocity_cmt__Product2Id__r.Name == '4G Infra'){
                infraOrdItmList.add(ordItem.Id);
            }
        }
        list<vlocity_cmt__FulfilmentRequestLine__c> FRLList = [select id,vlocity_cmt__AttributeSelectedValues__c,ARTL_Updated_Attributes__c,vlocity_cmt__InventoryItemId__r.vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__Action__c,vlocity_cmt__Product2Id__r.ARTL_Parent_Products__c,vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c,vlocity_cmt__Product2Id__r.Name from vlocity_cmt__FulfilmentRequestLine__c where  vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c in :orderids ];
        for(vlocity_cmt__FulfilmentRequestLine__c FrlRec:FRLList){
            for(OrderItem ordItm : ordItmList){
                if(((ordItm.vlocity_cmt__Product2Id__r.Name == 'Primary Link' || ordItm.vlocity_cmt__Product2Id__r.Name == 'Secondary Internet Link') && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Bandwidth OTC CFS')
                  || ((ordItm.vlocity_cmt__Product2Id__r.Name == 'Primary MPLS Link' || ordItm.vlocity_cmt__Product2Id__r.Name == 'Secondary MPLS Link') && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Bandwidth OTC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'Cross Connect' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Cross Connect OTC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'DDOS' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'DDOS OTC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'Hardware' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Hardware OTC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'DDOS' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'One Time Charge CFS')
                  || ((ordItm.vlocity_cmt__Product2Id__r.Name == 'NIPS Hardware' || ordItm.vlocity_cmt__Product2Id__r.Name == 'NIPS Service') && FrlRec.vlocity_cmt__Product2Id__r.Name == 'NIPS - OTC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'Hardware Replacement Charge' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Hardware Replacement OTC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'Installation Charge' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Installation OTC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'Connectivity IP Block' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'IP OTC CFS')){
                    FrlRec.ARTL_ProductPrice__c = integer.valueOf(ordItm.vlocity_cmt__OneTimeCharge__c);
                }

                if((ordItm.vlocity_cmt__Product2Id__r.Name == 'Cross Connect' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Cross Connect ARC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'Port Bandwidth Charge' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Port Bandwidth ARC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'Manageability Charge' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Manageability ARC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'Access Last Mile Charge' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Last Mile ARC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'Dual POP Charge' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Dual PoP ARC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'DDOS' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'DDOS ARC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'Hardware' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Hardware ARC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'DDOS' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Annual Recurring Charge CFS')
                  || ((ordItm.vlocity_cmt__Product2Id__r.Name == 'Primary MPLS Link' || ordItm.vlocity_cmt__Product2Id__r.Name == 'Secondary MPLS Link') && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Access Bandwidth ARC CFS')
                  || ((ordItm.vlocity_cmt__Product2Id__r.Name == 'Primary Link' || ordItm.vlocity_cmt__Product2Id__r.Name == 'Secondary Internet Link') && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Access Bandwidth ARC CFS')
                  || ((ordItm.vlocity_cmt__Product2Id__r.Name == 'NIPS Hardware' || ordItm.vlocity_cmt__Product2Id__r.Name == 'NIPS Service') && FrlRec.vlocity_cmt__Product2Id__r.Name == 'NIPS - ARC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'Enterprise Connectivity Routers' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Lease Rental ARC CFS')
                  || (ordItm.vlocity_cmt__Product2Id__r.Name == 'Connectivity IP Block' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'IP Charge ARC CFS')){
                    FrlRec.ARTL_ProductPrice__c = integer.valueOf(ordItm.Annual_Recurring_Charge__c);
                }
                
                if(FrlRec.vlocity_cmt__Product2Id__r.Name == 'Primary Link CFS' || FrlRec.vlocity_cmt__Product2Id__r.Name == 'MPLS Link CFS' || FrlRec.vlocity_cmt__Product2Id__r.Name == 'Enterprise iconnectivity Routers CFS'){
                    Map<String, Object> xlvalue = (Map<String, Object>) JSON.deserializeUntyped(FrlRec.vlocity_cmt__AttributeSelectedValues__c);
                    if(ordItm.vlocity_cmt__Product2Id__r.Name == 'Port Bandwidth Charge' && (FrlRec.vlocity_cmt__Product2Id__r.Name == 'Primary Link CFS' || FrlRec.vlocity_cmt__Product2Id__r.Name == 'MPLS Link CFS')){
                        xlvalue.put('ATT_PORT_BANDWIDTH_ARC',integer.valueOf(ordItm.Annual_Recurring_Charge__c));
                    }
                    if(ordItm.vlocity_cmt__Product2Id__r.Name == 'Dual POP Charge' && (FrlRec.vlocity_cmt__Product2Id__r.Name == 'Primary Link CFS' || FrlRec.vlocity_cmt__Product2Id__r.Name == 'MPLS Link CFS')){
                        xlvalue.put('ATT_Dual Pop ARC_CFS',integer.valueOf(ordItm.Annual_Recurring_Charge__c));
                    }
                    if(ordItm.vlocity_cmt__Product2Id__r.Name == 'Manageability Charge' && (FrlRec.vlocity_cmt__Product2Id__r.Name == 'Primary Link CFS' || FrlRec.vlocity_cmt__Product2Id__r.Name == 'MPLS Link CFS')){
                        xlvalue.put('ATT_MANAGEABILITY_ARC',integer.valueOf(ordItm.Annual_Recurring_Charge__c));
                    }
                    if(ordItm.vlocity_cmt__Product2Id__r.Name == 'Access Last Mile Charge' && (FrlRec.vlocity_cmt__Product2Id__r.Name == 'Primary Link CFS' || FrlRec.vlocity_cmt__Product2Id__r.Name == 'MPLS Link CFS')){
                        xlvalue.put('ATT_Last_Mile_ARC_CFS',integer.valueOf(ordItm.Annual_Recurring_Charge__c));
                    }
                    if(ordItm.vlocity_cmt__Product2Id__r.Name == 'Third Party' && (FrlRec.vlocity_cmt__Product2Id__r.Name == 'Primary Link CFS' || FrlRec.vlocity_cmt__Product2Id__r.Name == 'MPLS Link CFS')){
                        xlvalue.put('ATT_Third_Party_ARC',(integer)ordItm.Annual_Recurring_Charge__c);
                        xlvalue.put('ATT_Third_Party_OTC',(integer)ordItm.vlocity_cmt__OneTimeCharge__c);
                    }
                    if((ordItm.vlocity_cmt__Product2Id__r.Name == 'Primary Link' || ordItm.vlocity_cmt__Product2Id__r.Name == 'Secondary Internet Link' || ordItm.vlocity_cmt__Product2Id__r.Name == 'Primary MPLS Link' || ordItm.vlocity_cmt__Product2Id__r.Name == 'Secondary MPLS Link') && (FrlRec.vlocity_cmt__Product2Id__r.Name == 'Primary Link CFS' || FrlRec.vlocity_cmt__Product2Id__r.Name == 'MPLS Link CFS')){
                        xlvalue.put('ATT_ACCESS_BANDWIDTH_ARC',(integer)ordItm.Annual_Recurring_Charge__c);
                        xlvalue.put('ATT_BANDWIDTH_OTC',(integer)ordItm.vlocity_cmt__OneTimeCharge__c);
                    }
                    system.debug('OIPName==>'+ordItm.vlocity_cmt__Product2Id__r.Name+'/ FRLPName==>'+FrlRec.vlocity_cmt__Product2Id__r.Name);
                    if(ordItm.vlocity_cmt__Product2Id__r.Name == 'Enterprise Connectivity Routers' && FrlRec.vlocity_cmt__Product2Id__r.Name == 'Enterprise iconnectivity Routers CFS'){
                        xlvalue.put('ATT_Lease_Rental_ARC',(integer)ordItm.Annual_Recurring_Charge__c);
                        xlvalue.put('ATT_HARDWARE_REPLACE_OTC',(integer)ordItm.vlocity_cmt__OneTimeCharge__c);
                        xlvalue.put('ATT_Installation_OTC',(integer)ordItm.vlocity_cmt__OneTimeCharge__c);
                    }
                    FrlRec.vlocity_cmt__AttributeSelectedValues__c = Json.Serialize(xlvalue);
            }
            }
            updatedFRL.add(FrlRec);
        }
             if(updatedFRL.size()>0){
            update updatedFRL;
        }
     	List<vlocity_cmt__FulfilmentRequestLine__c> updatedFRLNew = new List<vlocity_cmt__FulfilmentRequestLine__c>();
        boolean is4g = false;
     	list<vlocity_cmt__FulfilmentRequestLine__c> FRLListNew = [select id,vlocity_cmt__AttributeSelectedValues__c,ARTL_Updated_Attributes__c,vlocity_cmt__InventoryItemId__r.vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__Action__c,vlocity_cmt__Product2Id__r.ARTL_Parent_Products__c,vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c,vlocity_cmt__Product2Id__r.Name from vlocity_cmt__FulfilmentRequestLine__c where  vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c in :orderids ];

        if(parentInternetOrdItmList.size()>0){
            system.debug('--------- inside parentInternetOrdItmList if -------');
            List<vlocity_cmt__OrderItemRelationship__c> ordPrdRelList = [Select id , vlocity_cmt__RelatedOrderItemId__r.Order.vlocity_cmt__OrderStatus__c,vlocity_cmt__RelatedOrderItemId__r.OrderId,vlocity_cmt__OrderItemId__c,vlocity_cmt__RelatedOrderItemId__c,vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__Product2Id__r.Name From vlocity_cmt__OrderItemRelationship__c where vlocity_cmt__RelatedOrderItemId__c IN :parentInternetOrdItmList AND (vlocity_cmt__RelatedOrderItemId__r.Order.vlocity_cmt__OrderStatus__c = 'In Progress' OR vlocity_cmt__RelatedOrderItemId__r.Order.vlocity_cmt__OrderStatus__c = 'Ready for Submit')];
            system.debug('ordPrdRelList -----> ' + ordPrdRelList);
            Set<Id> oirIds = new Set<Id>();
            if(ordPrdRelList.size() > 0){
                for(vlocity_cmt__OrderItemRelationship__c oir : ordPrdRelList){
                    oirIds.add(oir.vlocity_cmt__OrderItemId__c);
                    if(oir.vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__Product2Id__r.Name == '4G Infra'){
                        system.debug('----- inside 4g infra if ------');
                        is4g = true;
                    }
                }
                List<vlocity_cmt__OrderItemRelationship__c> secLinkPrdRelList = [Select Id , vlocity_cmt__OrderItemId__r.ARTL_LSI__c,vlocity_cmt__RelatedOrderItemId__c From vlocity_cmt__OrderItemRelationship__c where vlocity_cmt__OrderItemId__c IN :oirIds AND (vlocity_cmt__OrderItemId__r.vlocity_cmt__Product2Id__r.Name = 'Secondary Internet Link' OR vlocity_cmt__OrderItemId__r.vlocity_cmt__Product2Id__r.Name = 'Secondary MPLS Link')];
                system.debug('secLinkPrdRelList -----> ' + secLinkPrdRelList);
                if(secLinkPrdRelList.size()>0){
                Map<Id,String> lsiMap = new Map<Id,String>();
                for(vlocity_cmt__OrderItemRelationship__c secOir : secLinkPrdRelList){
                    if(lsiMap.get(secOir.vlocity_cmt__RelatedOrderItemId__c) != null){
                        lsiMap.put(secOir.vlocity_cmt__RelatedOrderItemId__c , lsiMap.get(secOir.vlocity_cmt__RelatedOrderItemId__c) + secOir.vlocity_cmt__OrderItemId__r.ARTL_LSI__c + ',');
                    }
                    else{
                        lsiMap.put(secOir.vlocity_cmt__RelatedOrderItemId__c , secOir.vlocity_cmt__OrderItemId__r.ARTL_LSI__c + ',');
                    }
                }
                system.debug('lsiMap ------> ' + lsiMap);
                for(vlocity_cmt__FulfilmentRequestLine__c FrlRec:FRLListNew){
                    
                    for(OrderItem ordItm : ordItmList){  
                        if(FrlRec.vlocity_cmt__Product2Id__r.Name == 'Internet Product Specification CFS' || FrlRec.vlocity_cmt__Product2Id__r.Name == 'EMPLS Product Specification CFS' || FrlRec.vlocity_cmt__Product2Id__r.Name == 'Primary Link CFS'){
                            system.debug('FrlRec.vlocity_cmt__Product2Id__r.Name --------> ' + FrlRec.vlocity_cmt__Product2Id__r.Name);
                            if(ordItm.vlocity_cmt__Product2Id__r.Name == 'Internet' || (ordItm.vlocity_cmt__Product2Id__r.Name == 'MPLS' && is4g == false)){
                                system.debug('ordItem.vlocity_cmt__Product2Id__r.Name Line 131-------> ' + ordItm.vlocity_cmt__Product2Id__r.Name);
                                Map<String, Object> xlvalue = (Map<String, Object>) JSON.deserializeUntyped(FrlRec.vlocity_cmt__AttributeSelectedValues__c);
                                xlvalue.put('ATT_DEPENDENT_LINK_LSI' , lsiMap.get(ordItm.Id).removeEnd(','));
                                FrlRec.vlocity_cmt__AttributeSelectedValues__c = Json.Serialize(xlvalue);
                            }
                        }
                }
                    updatedFRLNew.add(FrlRec);
                }
                }
            }
        }
        
        if(parentSecInternetOrdItmList.size() > 0){
            system.debug('------ inside parentSecInternetOrdItmList if ------');
			List<vlocity_cmt__OrderItemRelationship__c> ordPrdRelList = [Select id , vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__Product2Id__r.Name , vlocity_cmt__RelatedOrderItemId__r.ARTL_LSI__c , vlocity_cmt__RelatedOrderItemId__r.Order.vlocity_cmt__OrderStatus__c,vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__RootItemId__c,vlocity_cmt__RelatedOrderItemId__r.OrderId From vlocity_cmt__OrderItemRelationship__c where vlocity_cmt__OrderItemId__c IN :parentSecInternetOrdItmList AND (vlocity_cmt__RelatedOrderItemId__r.Order.vlocity_cmt__OrderStatus__c = 'In Progress' OR vlocity_cmt__RelatedOrderItemId__r.Order.vlocity_cmt__OrderStatus__c = 'Ready for Submit')];
            system.debug('ordPrdRelList  Line 151- ----->' + ordPrdRelList);
            if(ordPrdRelList.size() > 0){
                //Map<Id , String> relPrimMap = new Map<Id,String>();
                List<Id> relOrderIds = new List<Id>();
                for(vlocity_cmt__OrderItemRelationship__c oir : ordPrdRelList){
                    relOrderIds.add(oir.vlocity_cmt__RelatedOrderItemId__r.OrderId);
                    if(oir.vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__Product2Id__r.Name == '4G Infra'){
                        system.debug('------ inside 4g infra if -----');
                        is4g = true;
                    }
                    //relPrimMap.put(oir.vlocity_cmt__RelatedOrderItemId__c , oir.vlocity_cmt__RelatedOrderItemId__r.ARTL_LSI__c + '');
                }
                List<OrderItem> primOIList = [Select Id , ARTL_LSI__c,OrderId From OrderItem where OrderId IN :relOrderIds AND ARTL_LSI__c != null AND (Order.vlocity_cmt__OrderStatus__c = 'In Progress' OR Order.vlocity_cmt__OrderStatus__c = 'Ready For Submit')];
                system.debug('primOIList ------->' + primOIList);
                for(vlocity_cmt__FulfilmentRequestLine__c FrlRec:FRLListNew){
                    if(FrlRec.vlocity_cmt__Product2Id__r.Name == 'Primary Link CFS' || FrlRec.vlocity_cmt__Product2Id__r.Name == 'MPLS Link CFS'){
                                Map<String, Object> xlvalue = (Map<String, Object>) JSON.deserializeUntyped(FrlRec.vlocity_cmt__AttributeSelectedValues__c);
                        if(is4g == false){
                                xlvalue.put('ATT_Parent_Link_ID_CFS' , primOIList[0].ARTL_LSI__c);
                                FrlRec.vlocity_cmt__AttributeSelectedValues__c = Json.Serialize(xlvalue);
                        		updatedFRLNew.add(FrlRec);
                        }
                        else{
                            xlvalue.put('ATT_4G_INFRA_LINK' , primOIList[0].ARTL_LSI__c);
                                FrlRec.vlocity_cmt__AttributeSelectedValues__c = Json.Serialize(xlvalue);
                        		updatedFRLNew.add(FrlRec);
                        }
                    }
                }
            }
        }
        //system.debug('updatedFRL  -------> ' + updatedFRLNew);
        if(updatedFRLNew.size()>0){
            update updatedFRLNew;
        }
     
     List<vlocity_cmt__FulfilmentRequestLine__c> updatedFRL4g = new List<vlocity_cmt__FulfilmentRequestLine__c>();
     if(infraOrdItmList.size() > 0){
         List<vlocity_cmt__OrderItemRelationship__c> infraOrdPrdRelList = [Select id , vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__Product2Id__r.Name , vlocity_cmt__RelatedOrderItemId__r.ARTL_LSI__c , vlocity_cmt__OrderItemId__r.OrderId, vlocity_cmt__RelatedOrderItemId__r.Order.vlocity_cmt__OrderStatus__c,vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__RootItemId__c,vlocity_cmt__RelatedOrderItemId__r.OrderId From vlocity_cmt__OrderItemRelationship__c where vlocity_cmt__RelatedOrderItemId__c IN :infraOrdItmList AND (vlocity_cmt__RelatedOrderItemId__r.Order.vlocity_cmt__OrderStatus__c = 'In Progress' OR vlocity_cmt__RelatedOrderItemId__r.Order.vlocity_cmt__OrderStatus__c = 'Ready for Submit')];
         
         system.debug('infraOrdPrdRelList==>'+infraOrdPrdRelList);
         system.debug('FRLListNew==>'+FRLListNew);
         system.debug('infraOrdItmList==>'+infraOrdItmList);
         if(infraOrdPrdRelList.size() > 0){
         OrderItem primOrdItm = [Select Id , vlocity_cmt__AttributeSelectedValues__c , CND_Date__c , Order.Contract.ContractNumber , Order.POId__c , RFS_Date__c From OrderItem where OrderId = :infraOrdPrdRelList[0].vlocity_cmt__OrderItemId__r.OrderId AND (vlocity_cmt__Product2Id__r.Name = 'Primary MPLS Link' OR vlocity_cmt__Product2Id__r.Name = 'Secondary MPLS Link' OR vlocity_cmt__Product2Id__r.Name = 'MPLS') LIMIT 1];
         for(vlocity_cmt__FulfilmentRequestLine__c FrlRec:FRLListNew){
             if(FrlRec.vlocity_cmt__Product2Id__r.Name == 'EMPLS Product Specification CFS'){
                 Map<String, Object> xlvalue = (Map<String, Object>) JSON.deserializeUntyped(FrlRec.vlocity_cmt__AttributeSelectedValues__c);
                 try{
                 Map<String, Object> infraValue = (Map<String, Object>) JSON.deserializeUntyped(primOrdItm.vlocity_cmt__AttributeSelectedValues__c);
                 xlvalue.put('ATT_CAF_NUMBER',primOrdItm.Order.Contract.ContractNumber);
                 xlvalue.put('ATT_REDUNDANCY',infraValue.get('ATT_REDUNDANCY'));
                 xlvalue.put('ATT_CONTRACT_TERM',infraValue.get('ATT_CONTRACT_TERM'));
                 xlvalue.put('ATT_SERVICE_TYPE',infraValue.get('ATT_SERVICE_TYPE'));
                 xlvalue.put('ATT_RFS_Date',primOrdItm.RFS_Date__c);
                 xlvalue.put('ATT_PO_ID',primOrdItm.Order.POId__c);
                 xlvalue.put('ATT_TECH_CPE',infraValue.get('ATT_TECH_CPE'));
                 xlvalue.put('ATT_LAST_MILE',infraValue.get('ATT_LAST_MILE'));
                 xlvalue.put('ATT_CUSTOMER_NEED_BY_DATE',primOrdItm.CND_Date__c);
                 FrlRec.vlocity_cmt__AttributeSelectedValues__c = Json.Serialize(xlvalue);
                 updatedFRL4g.add(FrlRec);
                 }
                 catch(exception e){
                     system.debug('Error');
                 }
             }
         }
     }
        if(updatedFRL4g.size()>0){
            update updatedFRL4g;
        } 
     }
    }
}