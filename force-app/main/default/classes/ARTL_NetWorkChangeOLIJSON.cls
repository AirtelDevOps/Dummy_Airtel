global with sharing class ARTL_NetWorkChangeOLIJSON implements vlocity_cmt.VlocityOpenInterface {

    

    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean flag = false;
        
        if (methodName.equals('readOLIPayload')) {
           readOLIPayload(input,outMap);
        }
        return true;
    }
    
    global static Map<String,Object> readOLIPayload(Map<String,Object> input, Map<String,Object> outMap){

        String reqPayload;
        String orderId;
        String recordType;
        String samUser;
        String accountId;
        String caseId;
        reqPayload = String.valueOf(input.get('reqPayload'));
        orderId = String.valueOf(input.get('orderId'));
        recordType = String.valueOf(input.get('recordType'));
        samUser = String.valueOf(input.get('samUser'));
        accountId = String.valueOf(input.get('accountId'));
        caseId = String.valueOf(input.get('caseId'));
        system.debug('reqPayload =>' + reqPayload);
        system.debug('orderId =>' + orderId);
        system.debug('recordType =>' + recordType);
        system.debug('samUser =>' + samUser);

        Order oInst = [Select id from order where id=: orderId limit 1];
        oInst.Id = orderId;
        oInst.type = 'Network Change';
        oInst.vlocity_cmt__DefaultBillingAccountId__c = accountId;
        oInst.Case__c = caseId;
        oInst.Downtime_Start__c = reqPayload;
        oInst.Downtime_End__c = reqPayload;
        update oInst;
        
        String jsonString = '{"RootProduct":"MPLS","Transaction Type":"Network Change","LSI":"12345","SRNum":"SR12345","Downtime Start":"","Downtime End":"","ChildProducts":[{"Product":"Primary Link","ParentProduct":"MPLS","FeasibilityId":"","Attributes":{"Routing Protocol":"","Routing Type":"","IP Required":"","RTBH":""}}]}';
        
        // Parse the JSON string
        Map<String, Object> jsonData = (Map<String, Object>)JSON.deserializeUntyped(jsonString);

        // Get the list of child products
        List<Object> childProducts = (List<Object>)jsonData.get('ChildProducts');

        // Initialize the result list
        List<Map<String, Map<String, String>>> resultList = new List<Map<String, Map<String, String>>>();
        Map<String,String> attMap = new Map<String,String>();
        for(vlocity_cmt__Attribute__c attList : [   SELECT Id,name,vlocity_cmt__AttributeCategoryCode__c,vlocity_cmt__Code__c 
                                                    from vlocity_cmt__Attribute__c where 
                                                    vlocity_cmt__AttributeCategoryCode__c = 'ATC_ENTERPRISE_DETAILS'
        ])
        {
            attMap.put(attList.name,attList.vlocity_cmt__Code__c);
        }
        // Loop through each child product
        Map<String, Map<String, String>> childProductMap1 = new Map<String, Map<String, String>>();
        for (Object childProduct : childProducts) {
            // Extract product data and attributes
            Map<String, Object> childProductMap = (Map<String, Object>)childProduct;

            String product = (String)childProductMap.get('Product');
            Map<String, String> attributes = new Map<String, String>();
            Map<String, Object> childAttributes = (Map<String, Object>)childProductMap.get('Attributes');
            for (String attributeKey : childAttributes.keySet()) {
                System.debug('attributeKey==>>'+attributeKey);
                attributes.put((String)attMap.get(attributeKey), (String)childAttributes.get(attributeKey));
            }

            // Create the inner map for the child product
           
            childProductMap1.put(product, attributes);

            // Add the inner map to the result list
            //resultList.add(childProductMap);
        }
        System.Debug('childProductMap1#$###'+JSON.serialize(childProductMap1));
        Map<String,Map<String,Object>> OLImap = new Map<String,Map<String,Object>>();
        for(OrderItem orderItemInst : [
                                        select id,Product2.Name,vlocity_cmt__AttributeSelectedValues__c 
                                        from orderItem where OrderId =: orderId
        ]){
            String attSel = String.valueOf(orderItemInst.vlocity_cmt__AttributeSelectedValues__c);
            System.debug('attSel##'+attSel);
            if(attSel != NULL){
                Map<String, Object> oliAtt = (Map<String, Object>)JSON.deserializeUntyped(attSel);
                OLImap.put(orderItemInst.Product2.Name,oliAtt);
            }
        }
        System.Debug('OLImap#$###'+JSON.serialize(OLImap));
        // compare two JOSN and udpate it
        Map<String, Object> updatedOLIAttr = new Map<String, Object>();
        // Iterate over the keys in map1
        for (String key : OLImap.keySet()) {
                // Check if the key exists in map2
                 System.Debug('key==>>'+key);
            if (childProductMap1.containsKey(key)) {
                // If not, remove the item from map1
                //childProductMap.remove(key);
                System.Debug('key###'+key);
                Map<String, String> chldReq = childProductMap1.get(key);
                Map<String, Object> OLInested = OLImap.get(key);
                for (String key1 : chldReq.keySet()) {
                    if (OLInested.containsKey(key1)) {
                        OLInested.put(key1, (String)chldReq.get(key1));
                        updatedOLIAttr.putAll(OLInested);
                    }
                }
                OLImap.put(key,updatedOLIAttr); 
            }
             
        }
        System.debug('OLImap###'+JSON.serialize(OLImap.values()));
        List<OrderItem> orderItemListToUpdate = new List<OrderItem>();
        for(OrderItem orderItemInst : [
                                        select id,Product2.Name,vlocity_cmt__AttributeSelectedValues__c 
                                        from orderItem where orderId =: orderId AND Product2.Name=: OLImap.keySet()
        ]){
            OrderItem oitem = new OrderItem();
            oitem.Id = orderItemInst.Id;
            if(OLImap.containsKey(orderItemInst.Product2.Name))
                oitem.vlocity_cmt__AttributeSelectedValues__c = JSON.serialize(OLImap.get(orderItemInst.Product2.Name));
            System.debug(oitem.vlocity_cmt__AttributeSelectedValues__c);
            orderItemListToUpdate.add(oitem);
        }
        boolean updateSuccess = false;
        String ErrorText='';
        if(orderItemListToUpdate.size() > 0){
            try{
                update orderItemListToUpdate;
                updateSuccess = true;
            }
            catch(Exception e){
                updateSuccess = false;
                ErrorText = 'Invalid LSI/Invalid Date/Open Order exists on LSI/Dependent LSIs exists on LSI';
            }
           
        }

        outMap.put('StatusCode', updateSuccess);
        outMap.put('ErrorMessage', ErrorText);

        return outMap;
    }


}