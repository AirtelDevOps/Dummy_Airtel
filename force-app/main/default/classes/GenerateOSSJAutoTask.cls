global class GenerateOSSJAutoTask implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
    global void executeBatch(List < vlocity_cmt__OrchestrationItem__c > items) {
        for (vlocity_cmt__OrchestrationItem__c item: items) {
            /* your custom logic here */
            //System.debug(LoggingLevel.INFO, 'Hello world: orchestration task Id = ' + item.Id);
            generateOSSJClass(items);
        }
    }

    global void generateOSSJClass(List < vlocity_cmt__OrchestrationItem__c > oItemsList) {
        String orchItemId;
        String OrderId;
        String ProductCode;
        String orderItemId;
        String orderType;

        if (oItemsList.size() > 0) {
            orchItemId = oItemsList[0].id;
            String query = 'SELECT vlocity_cmt__OrchestrationPlanId__c,vlocity_cmt__OrderItemId__c,vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c,vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.ARTL_OrderType__c,vlocity_cmt__OrderItemId__r.Product2.ProductCode FROM vlocity_cmt__OrchestrationItem__c WHERE Id = :orchItemId';
            List < vlocity_cmt__OrchestrationItem__c > items = database.query(query);
            vlocity_cmt__OrchestrationItem__c item;
            if (items.size() == 1) {
                item = items[0];
                OrderId = item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c;
                orderItemId = item.vlocity_cmt__OrderItemId__c;
                ProductCode = item.vlocity_cmt__OrderItemId__r.Product2.ProductCode;
                orderType = item.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.ARTL_OrderType__c;
            }
        }

        List < string > callClassList = new List < string > ();
        for (OSSJInvokeMetaData__mdt mpclass: [SELECT id, ClassName__c, MethodName__c, Product_Code__c FROM OSSJInvokeMetaData__mdt
                WHERE Product_Code__c =: ProductCode AND OrderType__c =: orderType
            ]) {
            callClassList.add(mpclass.ClassName__c + '-' + mpclass.MethodName__c);
        }
        List < vlocity_cmt__OrchestrationItem__c > oItemList = new List < vlocity_cmt__OrchestrationItem__c > ();
        for (String callClassObj: callClassList) {

            List < String > classMethd = callClassObj.split('-');
            String className = classMethd[0];

            Type t = Type.forName(className);
            system.debug('Type --->' + t);
            IProcess api = (IProcess) t.newInstance();
            String output = api.generateXML(orderItemId);
            system.debug('Output ---->' + output);
            vlocity_cmt__OrchestrationItem__c oItem = new vlocity_cmt__OrchestrationItem__c();
            if (String.isNotBlank(output)) {
                system.debug('Inside If ---->');
                oItem.vlocity_cmt__Request__c = output;
                oItem.vlocity_cmt__State__c = 'Completed';
            } else {
                oItem.vlocity_cmt__State__c = 'Fatally Failed';
            }
            system.debug('State ---->' + oItem.vlocity_cmt__State__c);
            oItem.Id = orchItemId;
            oItemList.add(oItem);
        }
        if (oItemList.size() > 0) {
            update oItemList;
        }
    }
}