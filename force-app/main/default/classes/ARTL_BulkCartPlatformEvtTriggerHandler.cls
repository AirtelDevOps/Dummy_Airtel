/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 02-19-2024
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class ARTL_BulkCartPlatformEvtTriggerHandler implements vlocity_cmt.VlocityOpenInterface{
    
    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> outMap, Map<String,Object> options){
        try{
            if(methodName.equals('callIPBatch')){
                callIPBatch(input,outMap,options);
                return true;
            }
            if(methodName.equals('updateChildProductAtrributes')){
                updateChildProductAtrributes(input,outMap,options);
                return true;
            }
            /*if(methodName.equals('errorLogCheck')){
                errorLogCheck(input,outMap,options);
                return true;
            }*/
        }catch(Exception ex){
        }
        return false;
    }
    
    
    public static String NS = 'vlocity_cmt';
    public static void processAfterInsert(List<Bulk_Cart_Update_Notification__e> platformEventRecords){
        
        try{
            List<Object> removeObjectList = new List<Object>();
            
            Map<ID, QuoteLineItem> mapQLIs = 
                new Map<ID, QuoteLineItem>([SELECT Product2.Name ,Product2.ProductCode, Product2Id, PricebookEntryId, vlocity_cmt__RootItemId__c,vlocity_cmt__ParentItemId__c,vlocity_cmt__AssetReferenceId__c, 
                                            vlocity_cmt__LineNumber__c,Quantity,  vlocity_cmt__ProductHierarchyPath__c,  
                                            vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringCostTotal__c,  
                                            Annual_Recurring_Charge__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__OneTimeTotal__c,
                                            vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__Action__c ,Product2.ARTL_LSIRequired__c
                                            FROM QuoteLineItem  
                                            WHERE Quote.RecordType.DeveloperName= 'EnterpriseQuote'  
                                            AND QuoteId =: platformEventRecords[0].Cart_Id__c ]);
            
            IF(Test.isRunningTest()){
                QuoteLineItem quoteLine = new QuoteLineItem();
                quoteLine.Id = '0QL7200000087qqGAA';
                quoteLine.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_INVOICE_SHIPMENT_ID":null,"ATT_NBA_ID_CFS":null,"ATT_DDOS_Mitigation_Bandwidth_CFS":"20 Mbps","ATT_RELOG_REASON":null,"ATT_RFS_Date":null,"ATT_DDOS_TYPE":"ADVANCE_ARBOR","ATT_CROSS_CONNECT_REQD":"No","ATT_DDOS_REQUIRED":"ADVANCE_ARBOR","ATT_IP_REQUIRED":"IPv4","ATT_UPTIME_SLA":"99%","ATT_CPE":null,"ATT_SERVICE_TYPE":"Unmanaged","ATT_REDUNDANCY":"No","ATT_BGP_PREFIX_LIMIT_BGPHYD":null,"ATT_OFFNET_CAPEX":null,"ATT_LAST_MILE":"Single Last Mile","ATT_POP":"Single POP","ATT_INTERFACE":null,"ATT_MEDIA":"Copper","ATT_MTU_SIZE":"1472","ATT_ENTERPRISE_CONNECTIVITY_TYPE":"Primary","ATT_ROUTING_TYPE":"None","ATT_PORT_BANDWIDTH":null,"ATT_ACCESS_BANDWIDTH":"2 Mbps","ATT_CONTRACT_TERM":"12 Months"}';
                quoteLine.vlocity_cmt__OneTimeCharge__c = 999999;
                quoteLine.Annual_Recurring_Charge__c = 666666;
                mapQLIs.put('0QL7200000087qqGAA' , quoteLine);
            }
            
            for(Bulk_Cart_Update_Notification__e platformEventRec : platformEventRecords){
                
                Map<String,Object> payload = (Map<String,Object>) JSON.deserializeUntyped(platformEventRec.Request_JSON_Payload__c);
                Map<String, Object> ipInput = new Map<String, Object>();
                Map<String, Object> ipOutput = new Map<String, Object>();
                Map<String, Object> ipOptions = new Map<String, Object>();
                List<Object> ipAdditionChildProducts = new List<Object>();
                ipOptions.put('isDebug',false);
                //ipOptions.put('queueableChainable',true);
                List<Map<String, Object>> adjustmentList = new List<Map<String, Object>>();
                //ipInput.put('lineItems', payload);
                String ddosType;
                List<ARTL_Bulk_Iteration_Log__c> bulkIterationLogList = new List<ARTL_Bulk_Iteration_Log__c>();
                ipInput.put('payload', payload);
                ipInput.put('cartId', platformEventRec.Cart_Id__c);
                ipInput.put('SobjectType', platformEventRec.SobjectType__c);
                List<Object> UpdatedLineItremList = New List<Object>();
                UpdatedLineItremList = (List<Object>)payload.get('lineItems');
                String iterationId =  platformEventRec.Iteration_Id__c;
                for(Object obj : UpdatedLineItremList){
                    System.debug('obj ###  '+obj);
                    //Map<String, Object> ipAdjustmentOption = new Map<String, Object>();
                    //Map<String, Object> ipAdjustmentOutput = new Map<String, Object>();
                    Map<String,Object> updatedLineItemJson = (Map<String,Object>)obj;
                    if(updatedLineItemJson.get('Id')!=null){
                        String ItemId = String.valueOf(updatedLineItemJson.get('Id'));
                        QuoteLineItem QLI = mapQLIs.get(ItemId);

                        //Upadting the selected attributes
                        System.debug('QLI ###  '+QLI);
                        String attributes ;
                        Map<String,object> objMap = new Map<String,object>();
                        objMap  = (Map<String,object>)obj;
                        Map<String, Object> inputProductValue = new Map<String, Object>();
                        inputProductValue = (Map<String, Object>)objMap.get('product');
                        
                        System.debug('attributes ###  '+attributes);

                        ARTL_Bulk_Iteration_Log__c bulkIterationLog = new ARTL_Bulk_Iteration_Log__c();
                        bulkIterationLog.ARTL_Bulk_Iteration__c = platformEventRec.Iteration_Id__c;
                        bulkIterationLog.Product__c = String.valueOf(inputProductValue.get('Name'));
                        bulkIterationLog.Quote_Line_Item__c = QLI.id;
                        bulkIterationLog.Status__c = 'In Progress';
                        bulkIterationLog.LSI__c = String.valueOf(QLI.Product2.ARTL_LSIRequired__c);
                        bulkIterationLog.Asset_Reference_Id__c = QLI.vlocity_cmt__AssetReferenceId__c;
                        System.debug('bulkIterationLog ###  '+bulkIterationLog);
                        bulkIterationLogList.add(bulkIterationLog);
                       
                        System.debug('mapQLIs.get(ItemId) ###  '+mapQLIs.get(ItemId));
                        if(platformEventRec.SobjectType__c == 'Quote'){
                            Map<String,Object> PriceMap = (Map<String,Object>)updatedLineItemJson.get('price');
                            IF(PriceMap.containsKey('Annual_Recurring_Charge__c')){
                                if(PriceMap.get('Annual_Recurring_Charge__c') != QLI.Annual_Recurring_Charge__c){
                                    Map<String, Object> ipAdjustmentInput = new Map<String, Object>();
                                    String annualPrice = string.valueOf(PriceMap.get('Annual_Recurring_Charge__c'));
                                    Decimal annualChangePrice = Decimal.valueOf(annualPrice);
                                    ipAdjustmentInput.put('id',ItemId);
                                    ipAdjustmentInput.put('cartId',platformEventRec.Cart_Id__c);
                                    ipAdjustmentInput.put('PricingVariableCode','REC_YRLY_STD_PRC');
                                    ipAdjustmentInput.put('AdjustmentValue',annualChangePrice);
                                    ipAdjustmentInput.put('Field','Annual_Recurring_Charge__c');
                                    adjustmentList.add(ipAdjustmentInput);
                                    string inputString = JSON.serialize(ipAdjustmentInput);
                                }
                            }
                            IF(PriceMap.containsKey('vlocity_cmt__OneTimeCharge__c')){
                                if(PriceMap.get('vlocity_cmt__OneTimeCharge__c') != QLI.vlocity_cmt__OneTimeCharge__c){
                                    Map<String, Object> ipAdjustmentInput = new Map<String, Object>();
                                    String oneTimePrice = string.valueOf(PriceMap.get('vlocity_cmt__OneTimeCharge__c'));
                                    Decimal oneTimeChangePrice = Decimal.valueOf(oneTimePrice);
                                    ipAdjustmentInput.put('id',ItemId);
                                    ipAdjustmentInput.put('cartId',platformEventRec.Cart_Id__c);
                                    ipAdjustmentInput.put('PricingVariableCode','OT_STD_PRC');
                                    ipAdjustmentInput.put('AdjustmentValue',oneTimeChangePrice);
                                    ipAdjustmentInput.put('Field','vlocity_cmt__OneTimeCharge__c');
                                    adjustmentList.add(ipAdjustmentInput);
                                    string inputString = JSON.serialize(ipAdjustmentInput);
                                }
                            }
                            
                        }    
                        
                        
                        System.debug(' withhout if objMap debug %%  '+objMap.get('Id') +'  %%%% '+objMap.get('vlocity_cmt__AttributeSelectedValues__c'));
                        if(QLI.vlocity_cmt__AttributeSelectedValues__c != null){
                            attributes =  String.valueOf(QLI.vlocity_cmt__AttributeSelectedValues__c);
                            Map<String, Object> attributeValue = (Map<String,Object>) JSON.deserializeUntyped(attributes);
                            Map<String, Object> inputattributeValue = new Map<String, Object>();
                            
                            System.debug(' if objMap debug %%  '+objMap.get('Id') +'  %%%% '+objMap.get('vlocity_cmt__AttributeSelectedValues__c'));
                            System.debug('PY JSON.serialize(objMap) attributes  %% '+JSON.serialize(objMap));
                            if(objMap.containsKey('vlocity_cmt__AttributeSelectedValues__c')){
                                
                                inputattributeValue = (Map<String, Object>)objMap.get('vlocity_cmt__AttributeSelectedValues__c');
                                
                                /*if(String.valueOf(inputProductValue.get('Name')) == 'DDOS' && string.valueOf(objMap.get('vlocity_cmt__Action__c'))=='Delete'){
                                sYSTEM.DEBUG('FIRST ENTER DDOS  &&&& '+String.valueOf(inputProductValue.get('Name'))+'   KEY    '+string.valueOf(objMap.get('vlocity_cmt__Action__c')));
                                ipInput.put('AdditionalChildProduct','DDOS');
                                ipInput.put('AdditionalChildProductAction','Delete');
                                removeObjectList.add(obj);
                                }
                                if(String.valueOf(inputProductValue.get('Name')) == 'DDOS' && string.valueOf(objMap.get('vlocity_cmt__Action__c'))=='Add'){
                                sYSTEM.DEBUG('FIRST ENTER DDOS  &&&& '+String.valueOf(inputProductValue.get('Name'))+'   KEY    '+string.valueOf(objMap.get('vlocity_cmt__Action__c')));
                                ipInput.put('AdditionalChildProduct','DDOS');
                                ipInput.put('AdditionalChildProductAction','Add');
                                }*/
                                if(inputattributeValue.keySet().size()>0 || inputattributeValue != null){
                                    for(String key:inputattributeValue.keySet()){
                                        if(attributeValue.containsKey(key))
                                        {
                                            System.debug('key ----< '+key);
                                            System.debug('inputattributeValue.get(key) ----< '+inputattributeValue.get(key));
                                            attributeValue.put(key,inputattributeValue.get(key));
                                            //For DDOS
                                            ////DDOS comment
                                           /*if(String.valueOf(inputProductValue.get('Name')) == 'Primary Link'){
                                                if(inputattributeValue.get(key) != null){
                                                    system.debug('Inside Primary Link');
                                                    system.debug('Inside Primary Link nputattributeValue' +inputattributeValue);
                                                    if(key == 'ATT_DDOS_REQUIRED' && (inputattributeValue.get(key) == 'ADVANCE_ARBOR' ||inputattributeValue.get(key) == 'PREMIUM_RADWARE' || inputattributeValue.get(key) == 'Arbor' || inputattributeValue.get(key) == 'Radware')){
                                                        system.debug('ATT_DDOS_REQUIRED');
                                                        system.debug('inputattributeValue.get(key) '+ inputattributeValue.get(key));
                                                        attributeValue.put(key,'Yes');
                                                        if(inputattributeValue.get(key) == 'ADVANCE_ARBOR' || inputattributeValue.get(key) == 'Arbor'){
                                                            ddosType = 'Arbor';
                                                            attributeValue.put('ATT_DDOS_TYPE',ddosType);
                                                        }
                                                        if(inputattributeValue.get(key) == 'PREMIUM_RADWARE' || inputattributeValue.get(key) == 'Radware'){
                                                            ddosType = 'Radware';
                                                            attributeValue.put('ATT_DDOS_TYPE',ddosType);
                                                        }
                                                        //attributeValue.put(ATT_DDOS_Mitigation_Bandwidth_CFS,'Yes');
                                                    }else if(key == 'ATT_DDOS_REQUIRED' && inputattributeValue.get(key) == 'No'){
                                                        attributeValue.put(key,'No');
                                                    }
                                                    else if(key == 'ATT_DDOS_TYPE'){
                                                    attributeValue.put(key,ddosType);
                                                    }
                                                }
                                            }
                                            else if(String.valueOf(inputProductValue.get('Name')) == 'DDOS' && string.valueOf(objMap.get('vlocity_cmt__Action__c'))=='Add'){
                                                sYSTEM.DEBUG('ENTER DDOS  &&&& '+inputattributeValue.get(key)+'   KEY    '+key);
                                                if(key == 'ATT_DDOS_TYPE'){
                                                    attributeValue.put(key,ddosType);
                                                }
                                            }*/
                                            //DDOS comment
                                            /*else if(String.valueOf(inputProductValue.get('Name')) == 'DDOS' && string.valueOf(objMap.get('vlocity_cmt__Action__c'))=='Delete'){
                                            sYSTEM.DEBUG('  '+inputattributeValue.get(key)+'   KEY    '+key);
                                            if(key == 'ATT_DDOS_TYPE' && (inputattributeValue.get(key) == 'No')){
                                            ipInput.put('AdditionalChildProductRequiredAtt','NO');
                                            }else if(key == 'ATT_DDOS_MITIGATION_BANDWIDTH'){
                                            ipInput.put('AdditionalChildProductBANDWIDTH',inputattributeValue.get(key));
                                            }
                                            Integer objIndex =UpdatedLineItremList.indexOf(obj);
                                            //removeObjectList.add(obj);
                                            
                                            }*/
                                            
                                        }      
                                        if(String.valueOf(inputProductValue.get('Name')) == 'Primary Link'){
                                            system.debug('Inside Primary Link attributeValue    '+attributeValue);
                                        } 
                                    }
                                    
                                }else{
                                    objMap.put('vlocity_cmt__AttributeSelectedValues__c',null );
                                    obj = (Object)objMap;
                                }
                                objMap.put('vlocity_cmt__AttributeSelectedValues__c',attributeValue );
                                obj = (Object)objMap;
                            }else{
                                attributeValue =(Map<String,Object>) JSON.deserializeUntyped(attributes);
                                System.debug(' else attributeValue   %% '+attributeValue);
                            }
                            
                        }else if(QLI.vlocity_cmt__AttributeSelectedValues__c == null){
                            System.debug(' ielsef objMap debug %%  '+objMap.get('Id') +'  %%%% '+objMap.get('vlocity_cmt__AttributeSelectedValues__c'));
                            objMap.put('vlocity_cmt__AttributeSelectedValues__c',null );
                            obj = (Object)objMap;
                        }
                        
                        System.debug('objMap %%%  '+objMap);
                        System.debug('obj %%%  '+obj);
                        
                        ipInput.put('adjustmentsList', adjustmentList);
                        
                    }ELSE IF(updatedLineItemJson.get('Id')==null && String.valueOf(updatedLineItemJson.get('vlocity_cmt__Action__c')) == 'Add'){
                        if(platformEventRec.SobjectType__c == 'Quote'){
                            Integer objIndex =UpdatedLineItremList.indexOf(obj);
                            //removeObjectList.add(obj);
                            Map<String,object> objMap = new Map<String,object>();
                            objMap  = (Map<String,object>)obj;
                            Map<String, Object> inputattributeValue = new Map<String, Object>();
                            Map<String, Object> inputProductValue = new Map<String, Object>();
                            if(objMap.containsKey('vlocity_cmt__AttributeSelectedValues__c') && objMap.get('vlocity_cmt__AttributeSelectedValues__c') != null){
                                inputattributeValue = (Map<String, Object>)objMap.get('vlocity_cmt__AttributeSelectedValues__c');
                                inputProductValue = (Map<String, Object>)objMap.get('product');
                                
                                //generic code for all child product
                                Map<String, Object> ipadditionalChildProduct = new Map<String, Object>();
                                ipadditionalChildProduct.put('ProductName' , inputProductValue.get('Name'));
                                ipadditionalChildProduct.put('ProductAction' , objMap.get('vlocity_cmt__Action__c'));
                                ipadditionalChildProduct.put('ProductAttribute' ,objMap.get('vlocity_cmt__AttributeSelectedValues__c'));
                                
                                ipAdditionChildProducts.add(ipadditionalChildProduct);
                                
                                
                                /*if(String.valueOf(inputProductValue.get('Name')) == 'DDOS' && string.valueOf(objMap.get('vlocity_cmt__Action__c'))=='Add'){
                                sYSTEM.DEBUG('FIRST ENTER DDOS  &&&& '+String.valueOf(inputProductValue.get('Name'))+'   KEY    '+string.valueOf(objMap.get('vlocity_cmt__Action__c')));
                                ipInput.put('AdditionalChildProduct','DDOS');
                                ipInput.put('AdditionalChildProductAction','Add');
                                }
                                if(inputattributeValue.keySet().size()>0 || inputattributeValue != null){
                                for(String key:inputattributeValue.keySet()){
                                if(String.valueOf(inputProductValue.get('Name')) == 'DDOS'){
                                sYSTEM.DEBUG('ENTER DDOS  &&&& '+inputattributeValue.get(key)+'   KEY    '+key);
                                if(key == 'ATT_DDOS_TYPE' &&(inputattributeValue.get(key) == 'ADVANCE_ARBOR' ||inputattributeValue.get(key) == 'PREMIUM_RADWARE' ||inputattributeValue.get(key) == 'Arbor' ||inputattributeValue.get(key) == 'Radware')){
                                if(inputattributeValue.get(key) == 'ADVANCE_ARBOR' || inputattributeValue.get(key) == 'Arbor'){
                                ipInput.put('AdditionalChildProductRequiredAtt','Arbor');
                                }else if(inputattributeValue.get(key) == 'PREMIUM_RADWARE' || inputattributeValue.get(key) == 'Radware'){
                                ipInput.put('AdditionalChildProductRequiredAtt','Radware');
                                }
                                
                                }else if(key == 'ATT_DDOS_MITIGATION_BANDWIDTH'){
                                ipInput.put('AdditionalChildProductBANDWIDTH',inputattributeValue.get(key));
                                }
                                
                                }
                                }
                                }*/
                            }
                            removeObjectList.add(obj); 
                            
                        }
                    }
                    else{
                        Integer objIndex =UpdatedLineItremList.indexOf(obj);
                        removeObjectList.add(obj); 
                    }
                    
                    Map<String,Object> updatedLineItemPOJson = (Map<String,Object>)obj;
                    Map<String,Object> LSITruePayload = New Map<String,Object>();
                    Map<String,Object> PODataCheck = (Map<String,Object>)updatedLineItemPOJson.get('POData');
                    Map<String,Object> DCpDataCheck = (Map<String,Object>)updatedLineItemPOJson.get('DCP');
                    Map<String,Object> BCPDataCheck = (Map<String,Object>)updatedLineItemPOJson.get('BCP');
                    Map<String,Object> BDDataCheck = (Map<String,Object>)updatedLineItemPOJson.get('BillingData');
                    If(PODataCheck !=null){
                        LSITruePayload = updatedLineItemPOJson.clone();
                        LSITruePayload.put('ContextId',platformEventRec.Cart_Id__c);
                        ipInput.put('LSITruePayload', LSITruePayload);
                    }
                    /*else{
                        ipInput.put('LSITruePayload', null);
                    }*/
                    System.debug('ARTL_EventHandlerWrapperVIP LSITruePayload  '+LSITruePayload);
                
                    
                }
                System.debug('ARTL_EventHandlerWrapperVIP removeObjectList  '+removeObjectList);
                for(Object obj : removeObjectList){
                    System.debug('ARTL_EventHandlerWrapperVIP removeObjectList obj  '+obj);
                    System.debug('ARTL_EventHandlerWrapperVIP removeObjectList UpdatedLineItremList  '+UpdatedLineItremList);
                    Integer objIndex =UpdatedLineItremList.indexOf(obj);
                    System.debug('ARTL_EventHandlerWrapperVIP removeObjectList objIndex  '+objIndex);
                    
                    UpdatedLineItremList.remove(objIndex);
                    System.debug('ARTL_EventHandlerWrapperVIP removeObjectList list UpdatedLineItremList  '+UpdatedLineItremList);
                }

                System.debug('bulkIterationLogList ###  '+bulkIterationLogList);
                Database.SaveResult[] saveResultList = Database.insert(bulkIterationLogList,false);
                for (Database.SaveResult sr : saveResultList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted bulkIterationLogList. bulkIterationLogList ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('bulkIterationLogList The following error has occurred.');                    
                            System.debug('bulkIterationLogList &&  ' + err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('bulkIterationLogList fields that affected this error: ' + err.getFields());
                        }
                    }
                }

                payload.put('lineItems' , UpdatedLineItremList);
                //ipInput.put('bulkIterationLogList' , bulkIterationLogList);
                ipInput.put('iterationId' , iterationId);
                ipInput.put('payload', payload);
                ipInput.put('ddosType', ddosType);
                ipInput.put('ipAdditionChildProducts', ipAdditionChildProducts);               
                string ipInputString = JSON.serialize(ipInput);               
                System.debug('ARTL_EventHandlerWrapperVIP ipInputString  '+ipInputString);
                ipOutput = (Map<String,Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService('ARTL_EventHandlerWrapperVIP', ipInput, ipOptions);
                string ipOutputString = JSON.serialize(ipOutput);
                
                
                System.debug('ARTL_EventHandlerWrapperVIP ipOutputString  '+ipOutputString);
                //version 2 is active previous
                //Inside the VIP, call three IPs separately in queuable//Only when there is changes. Actual vs Latest
            }
        }catch (Exception e) {
            System.debug('error msg### ' + e.getMessage());
            System.debug('error msg### '+e.getStackTraceString());
        }
        //call queuable future - 
        //create a working cart CloneEQLIsToWCPriceCopyEQLIs, reprice =true and validate = true
        //write back to EQ.
        
    }
    
    
    public static void callIPBatch( Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options){
        try{
            string ipInputString = JSON.serialize(inputMap);
            System.debug('ipInputString  &&&& callIPBatch '+ipInputString);
            ARTL_BulkApplyAdjustmentBatch BulkApplyAdjustmentBatchInstance = new ARTL_BulkApplyAdjustmentBatch(inputMap);
            IF(!Test.isRunningTest()){
                Database.executeBatch(BulkApplyAdjustmentBatchInstance, 1);  
            }
            
        }catch (Exception e) {
            System.debug('error msg### ' + e.getMessage());        }
    }
    
    
    
    
    public static void updateChildProductAtrributes( Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options){
        try{
            Map < String, string > outputUpdateChildProductAtrributesResult = new Map<String,string>();
            String workingCartId = String.ValueOf(inputMap.get('WorkingCartId'));
            String ddosType = String.ValueOf(inputMap.get('ddosType'));
            list<QuoteLineItem> qliList = [SELECT Product2.Name ,Product2.ProductCode, Product2Id, PricebookEntryId, vlocity_cmt__RootItemId__c,vlocity_cmt__ParentItemId__c,vlocity_cmt__AssetReferenceId__c, 
                                           vlocity_cmt__LineNumber__c,Quantity,  vlocity_cmt__ProductHierarchyPath__c,  
                                           vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringCostTotal__c,  
                                           Annual_Recurring_Charge__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__OneTimeTotal__c,
                                           vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__Action__c 
                                           FROM QuoteLineItem where quoteId =: workingCartId];
            
            System.debug('qliList START  updateChildProductAtrributes  '+qliList);
            Map<String,Object> additionalChildProductMap = new Map<String,Object>();
            List<Object> additionalChildProductList =(List<Object>) inputMap.get('ipAdditionChildProducts');
            System.debug('additionalChildProductList  updateChildProductAtrributes  '+additionalChildProductList);
            System.debug('additionalChildProductList  updateChildProductAtrributes  .size() '+additionalChildProductList.size());
            if(additionalChildProductList.size()>0 && additionalChildProductList!= null){
                for(Object obj : additionalChildProductList ){
                    System.debug('obj obj  updateChildProductAtrributes  '+obj);
                    Map<String,Object> updatedLineItemJson = (Map<String,Object>)obj;
                    additionalChildProductMap.put(String.valueOf(updatedLineItemJson.get('ProductName')) , obj);
                    /*if(String.valueOf(updatedLineItemJson.get('ProductName')) == 'Primary Link' ){
                    attributes =  String.valueOf(QLI.vlocity_cmt__AttributeSelectedValues__c);
                    Map<String, Object> attributeValue = (Map<String,Object>) JSON.deserializeUntyped(attributes);
                    artl_DDOS_Type = 
                    }*/
                    
                }
                System.debug('additionalChildProductMap  updateChildProductAtrributes  '+additionalChildProductMap);
                for(QuoteLineItem qli: qliList){
                    
                    Object obj = additionalChildProductMap.get(qli.Product2.Name);
                    Map<String,object> objMap  = (Map<String,object>)obj;
                    IF(objMap!=null){
                        System.debug('objMap  updateChildProductAtrributes  '+objMap);
                        if(objMap.containsKey('ProductAttribute') && objMap.get('ProductAttribute') != null && String.valueOf(objMap.get('ProductAction')) == 'Add'){
                            Map<String, Object> inputattributeValue = (Map<String, Object>)objMap.get('ProductAttribute');
                            System.debug('inputattributeValue  updateChildProductAtrributes  '+inputattributeValue);
                            //Map<String, Object> inputProductValue = (Map<String, Object>)objMap.get('product');
                            //System.debug('inputProductValue  updateChildProductAtrributes  '+inputProductValue);
                            String attributes  =  String.valueOf(QLI.vlocity_cmt__AttributeSelectedValues__c);
                            System.debug('attributes  updateChildProductAtrributes  '+attributes);
                            if(attributes != null){
                                Map<String, Object> attributeValue = (Map<String,Object>) JSON.deserializeUntyped(attributes); 
                                for(String key:inputattributeValue.keySet()){
                                    if(attributeValue.containsKey(key)){
                                        attributeValue.put(key,inputattributeValue.get(key));
                                        /*if(String.valueOf(objMap.get('ProductName')) == 'DDOS'){
                                            if(key == 'ATT_DDOS_TYPE'){
                                                attributeValue.put(key,ddosType);                                    
                                            }
                                        }*/
                                    }
                                }
                                System.debug('attributeValue  updateChildProductAtrributes  '+attributeValue);
                                qli.vlocity_cmt__AttributeSelectedValues__c = JSON.serialize(attributeValue) ;
                            }
                        }
                        
                        System.debug('qli   updateChildProductAtrributes  '+qli);
                    }
                }
                Database.SaveResult[] srList = Database.update(qliList , false);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        outputUpdateChildProductAtrributesResult.put(sr.getId() , 'Success');
                    }
                    else {
                        String errorMessage = '';
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            errorMessage = 'The following error has occurred. '+ err.getStatusCode() + ': ' + err.getMessage() +  ' ' +err.getFields();
                        }
                        outputUpdateChildProductAtrributesResult.put(sr.getId() , errorMessage);
                    }
                }
                System.debug('qliList   updateChildProductAtrributes  '+qliList);
            }
        }catch (Exception e) {
            System.debug('error msg### ' + e.getMessage()); 
            System.debug('error msg### getStackTraceString ' + e.getStackTraceString());        
            
            System.debug('error msg### getLineNumber ' + e.getLineNumber());        
        }
    }
    
    /*public static void errorLogCheck( Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options){
        try{
            String DRReturnResponse = String.valueOf(inputMap.get('DRReturnResponse'));
            String ESMReturnResponse = String.valueOf(inputMap.get('ESMReturnResponse'));
            //Object ESM_Response = inputMap.get('ESM_Response');
            List<ARTL_Bulk_Iteration_Log__c> bulkIterationLogUpdate = new List<ARTL_Bulk_Iteration_Log__c>();
            String iterationId = String.valueOf(inputMap.get('iterationId'));
            System.debug('iterationId size  %%%'+iterationId);
            List<ARTL_Bulk_Iteration_Log__c> bulkIterationLog = [select id,ARTL_Bulk_Iteration__c,Asset_Reference_Id__c, Product__c, Quote_Line_Item__c,LSI__c, Status__c, ErrorMessage__c,ARTL_Bulk_Iteration__r.Quote__c from ARTL_Bulk_Iteration_Log__c where ARTL_Bulk_Iteration__c =: iterationId];
            System.debug('bulkIterationLog size  %%%'+bulkIterationLog);
            Map<string, ARTL_Bulk_Iteration_Log__c> bulkIterationLogMap = new Map<string, ARTL_Bulk_Iteration_Log__c>();
            for(ARTL_Bulk_Iteration_Log__c bulkIteration : bulkIterationLog){  
                System.debug('bulkIteration size  %%%'+bulkIteration+ '   '+bulkIteration.Quote_Line_Item__c);
                bulkIterationLogMap.put(bulkIteration.Asset_Reference_Id__c , bulkIteration);
            }
            System.debug('bulkIterationLogMap size  %%%'+bulkIterationLogMap);
            System.debug('DRReturnResponse size  %%%'+DRReturnResponse);
            System.debug('ESMReturnResponse size  %%%'+ESMReturnResponse);
            System.debug('inputMap.get(DR_Response) size  %%%'+inputMap.get('DR_Response'));
            System.debug('inputMap.get(ESM_Response) size  %%%'+inputMap.get('ESM_Response'));
            if(DRReturnResponse == 'fail'){
                List<Object> DR_ResponseList = (List<Object>)inputMap.get('DR_Response');
                System.debug('DR_ResponseList size  %%%'+DR_ResponseList);
                for(Object obj  : DR_ResponseList){
                    Map<String,object> objMap  = (Map<String,object>)obj;
                    System.debug('objMap sizeDR_ResponseList  %%%'+objMap);
                    String assetReferenceId = String.valueOf(objMap.get('vlocity_cmt__AssetReferenceId__c'));
                    System.debug('assetReferenceId sizeDR_ResponseList  %%%'+assetReferenceId);
                    ARTL_Bulk_Iteration_Log__c bulkIteration = bulkIterationLogMap.get(assetReferenceId);
                     System.debug('bulkIteration sizeDR_ResponseList  %%%'+bulkIteration);
                    if( !(Boolean.valueOf(objMap.get('UpsertSuccess'))) && bulkIteration != null){
                        bulkIteration.ErrorMessage__c = String.valueOf(objMap.get('UpsertError'));
                        bulkIteration.Status__c = 'Failed';
                        bulkIterationLogUpdate.add(bulkIteration);
                        System.debug('bulkIterationLogUpdate sizeDR_ResponseList  %%%'+bulkIterationLogUpdate);
                    }
                    
                }
            }
            if(ESMReturnResponse == 'fail'){
                Map<String,object> objMap  = (Map<String,object>)inputMap.get('ESM_Response');
                System.debug('objMap ESMReturnResponse  %%%'+objMap);
                for(ARTL_Bulk_Iteration_Log__c bulkIteration : bulkIterationLog){
                    bulkIteration.ErrorMessage__c = String.valueOf(objMap.get('EsmCloneResponse'));
                    bulkIteration.Status__c = 'Failed';
                    System.debug('bulkIteration ESMReturnResponse  %%%'+bulkIteration);
                    bulkIterationLogUpdate.add(bulkIteration);
                    System.debug('bulkIterationLogUpdate ESMReturnResponse  %%%'+bulkIterationLogUpdate);
                }
            }
            System.debug('bulkIterationLogUpdate  %%%'+bulkIterationLogUpdate);
            if(bulkIterationLogUpdate.size()>0){
                 System.debug('bulkIterationLogUpdate size  %%%'+bulkIterationLogUpdate.size());
                Database.update(bulkIterationLogUpdate,false);
            }
            
            
        }catch (Exception e) {
            System.debug('error msg### ' + e.getMessage()); 
            System.debug('error msg### getStackTraceString ' + e.getStackTraceString());        
            
            System.debug('error msg### getLineNumber ' + e.getLineNumber());             
        }
    }*/
}