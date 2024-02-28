@isTest
public class ARTL_BulkCartPlatformEvtTriggerTest {
    @isTest
    PUBLIC static void testExceuteItem(){       
        Bulk_Cart_Update_Notification__e e = new Bulk_Cart_Update_Notification__e();
        e.Request_JSON_Payload__c = '{"lineItems":[{"linenumber":"0001.0001","Quantity":1,"Id":"0QL7200000087qqGAA","vlocity_cmt__AssetReferenceId__c":"b5193f68-193b-89e0-112a-479a43786ed9","vlocity_cmt__AttributeSelectedValues__c":{"ATT_INVOICE_SHIPMENT_ID":null,"ATT_NBA_ID_CFS":null,"ATT_DDOS_Mitigation_Bandwidth_CFS":"20 Mbps","ATT_RELOG_REASON":null,"ATT_RFS_Date":null,"ATT_DDOS_TYPE":"ADVANCE_ARBOR","ATT_CROSS_CONNECT_REQD":"No","ATT_DDOS_REQUIRED":"ADVANCE_ARBOR","ATT_IP_REQUIRED":"IPv4","ATT_UPTIME_SLA":"99%","ATT_CPE":null,"ATT_SERVICE_TYPE":"Unmanaged","ATT_REDUNDANCY":"No","ATT_BGP_PREFIX_LIMIT_BGPHYD":null,"ATT_OFFNET_CAPEX":null,"ATT_LAST_MILE":"Single Last Mile","ATT_POP":"Single POP","ATT_INTERFACE":null,"ATT_MEDIA":"Copper","ATT_MTU_SIZE":"1472","ATT_ENTERPRISE_CONNECTIVITY_TYPE":"Primary","ATT_ROUTING_TYPE":"None","ATT_PORT_BANDWIDTH":null,"ATT_ACCESS_BANDWIDTH":"2 Mbps","ATT_CONTRACT_TERM":"12 Months"},"price":{"Annual_Recurring_Charge__c":55555,"vlocity_cmt__OneTimeCharge__c":10000},"product":{"Name":"Primary Link","ProductCode":"f14f570c-32cf-42b3-9e5c-c29a8e6132c2","ProductId":"01t72000000zzcrAAA","PriceBookEntryId":"01u72000000HX7dAAG"},"vlocity_cmt__Action__c":"Add","vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA"}],"productCode":"3c6df3ca-4424-4131-bde3-c3ea5d5b5925","rootItemId":"17d91bef-2021-c9ea-44c0-da67385956ab","rootItemSFid":"0QL7200000087qp"}';
        e.SobjectType__c='Quote';
        e.Cart_Id__c='1234567';  
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(e);  
        Test.stopTest();
    }
    
    @IsTest
    Public static void testEventPlatform(){
        Bulk_Cart_Update_Notification__e e2 = new Bulk_Cart_Update_Notification__e();
        e2.Request_JSON_Payload__c = '{"lineItems":[{"linenumber":"0001.0001","Quantity":1,"Id":null,"vlocity_cmt__AssetReferenceId__c":"b5193f68-193b-89e0-112a-479a43786ed9","vlocity_cmt__AttributeSelectedValues__c":{"ATT_DDOS_REQUIRED":"ADVANCE_ARBOR","ATT_NBA_ID_CFS":null,"ATT_DDOS_Mitigation_Bandwidth_CFS":"20 Mbps","ATT_RELOG_REASON":null,"ATT_RFS_Date":null,"ATT_DDOS_TYPE":"ADVANCE_ARBOR","ATT_CROSS_CONNECT_REQD":"No","ATT_DDOS_REQUIRED":"ADVANCE_ARBOR","ATT_IP_REQUIRED":"IPv4","ATT_UPTIME_SLA":"99%","ATT_CPE":null,"ATT_SERVICE_TYPE":"Unmanaged","ATT_REDUNDANCY":"No","ATT_BGP_PREFIX_LIMIT_BGPHYD":null,"ATT_OFFNET_CAPEX":null,"ATT_LAST_MILE":"Single Last Mile","ATT_POP":"Single POP","ATT_INTERFACE":null,"ATT_MEDIA":"Copper","ATT_MTU_SIZE":"1472","ATT_ENTERPRISE_CONNECTIVITY_TYPE":"Primary","ATT_ROUTING_TYPE":"None","ATT_PORT_BANDWIDTH":null,"ATT_ACCESS_BANDWIDTH":"2 Mbps","ATT_CONTRACT_TERM":"12 Months"},"price":{"Annual_Recurring_Charge__c":55555,"vlocity_cmt__OneTimeCharge__c":10000},"product":{"Name":"DDOS","ProductCode":"f14f570c-32cf-42b3-9e5c-c29a8e6132c2","ProductId":"01t72000000zzcrAAA","PriceBookEntryId":"01u72000000HX7dAAG"},"vlocity_cmt__Action__c":"Add","vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA"}],"productCode":"3c6df3ca-4424-4131-bde3-c3ea5d5b5925","rootItemId":"17d91bef-2021-c9ea-44c0-da67385956ab","rootItemSFid":"0QL7200000087qp"}';
        e2.SobjectType__c='Quote';
        e2.Cart_Id__c='1234567';  
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(e2);  
        Test.stopTest();      
    }
    
    @IsTest
    Public static void testEventPlatform1(){
        ARTL_BulkCartPlatformEvtTriggerHandler BulkPlatformEvent = New ARTL_BulkCartPlatformEvtTriggerHandler();
        Map<String,object> inputMap  = New Map<String,Object>();
        Map<String,object> outputMap  = New Map<String,Object>();
        Map<String,object> optionMap  = New Map<String,Object>();
        Test.startTest();
        BulkPlatformEvent.invokeMethod('callIPBatch', inputMap,outputMap,optionMap);
        Test.stopTest();      
    }
    
    
     @IsTest
    Public static void testEventPlatform2(){
        ARTL_BulkCartPlatformEvtTriggerHandler BulkCartPlatformEvtTriggerHandler = new ARTL_BulkCartPlatformEvtTriggerHandler();
        String inputstring = '{"WorkingCartId":"2345678","ipAdditionChildProducts":[{"ProductAttribute":{"ATT_CROSS_CONNECT_MODE-CUSTOMER":"Single Mode","ATT_CROSS_CONNECT_OFFERING":"Cross Connect","ATT_CROSS_CONNECT_TYPE":"Optical","ATT_CROSS_CONNECT_BANDWIDTH":"2 Mbps","ATT_CROSS_CONNECT_LOCATION_A":null,"ATT_CROSS_CONNECT_LOCATION_B":null,"ATT_CROSS_CONNECT_PROVIDER_NAME":"CrossConnectName","ATT_THIRD_PARTY_CONTRACT_TERM":null,"ATT_TYPE_OF_CONNECTOR_CUSTOMER":"SC"},"ProductAction":"Add","ProductName":"Cross Connect"},{"ProductAttribute":{},"ProductAction":"Add","ProductName":"Dual POP Charge"},{"ProductAttribute":{"ATT_ROUTER_OWNERSHIP":null,"ATT_ROUTER_TYPE":null,"ATT_ITEM_CODE":null,"ATT_ROUTER_MAKE":null,"ATT_Sale_Type":null,"ATT_ROUTER_MODEL":null,"ATT_ADDITIONAL_ITEM_CODE_1":null,"ATT_ADDITIONAL_ITEM_CODE_2":null,"ATT_ADDITIONAL_ITEM_CODE_3":null,"ATT_ADDITIONAL_ITEM_CODE_4":null,"ATT_ADDITIONAL_ITEM_CODE_5":null,"ATT_ADDITIONAL_ITEM_CODE_6":null,"ATT_ADDITIONAL_ITEM_CODE_7":null,"ATT_HardwareRedundancyRequired":null,"ATT_Secondary_CPE_Make":null,"ATT_Secondary_CPE_Model":null,"ATT_Secondary_CPE_ItemCode":null},"ProductAction":"Add","ProductName":"Enterprise Connectivity Routers"}],"ddosType":null}';
        Map<String,object> inputMap  = New Map<String,Object>();
        Map<String,object> outputMap  = New Map<String,Object>();
        Map<String,object> optionMap  = New Map<String,Object>();
        inputMap = (Map<String,object>)Json.deserializeUntyped(inputString);
        Test.startTest();
        BulkCartPlatformEvtTriggerHandler.invokeMethod( 'updateChildProductAtrributes' , inputMap,null,null);
        BulkCartPlatformEvtTriggerHandler.invokeMethod( 'errorLogCheck' , inputMap,null,null);
        Test.stopTest();      
    }
    
    
    
    @isTest
    static void testErrorLogCheck() {
        Map<String, Object> inputMapDRFail = new Map<String, Object>();
        inputMapDRFail.put('DRReturnResponse', 'fail');
        List<Object> drResponseList = new List<Object>();
        Map<String, Object> drResponseEntry = new Map<String, Object>();
        drResponseEntry.put('vlocity_cmt__AssetReferenceId__c', 'TestAssetReferenceId');
        drResponseEntry.put('UpsertSuccess', false);
        drResponseEntry.put('UpsertError', 'Error message for DR');
        drResponseList.add(drResponseEntry);
        inputMapDRFail.put('DR_Response', drResponseList);
        inputMapDRFail.put('iterationId', 'TestIterationId');

        // Example input map for failure in ESMReturnResponse
        Map<String, Object> inputMapESMFail = new Map<String, Object>();
        inputMapESMFail.put('ESMReturnResponse', 'fail');
        Map<String, Object> esmResponseMap = new Map<String, Object>();
        esmResponseMap.put('EsmCloneResponse', 'Error message for ESM');
        inputMapESMFail.put('ESM_Response', esmResponseMap);
        inputMapESMFail.put('iterationId', 'TestIterationId');

        // Call the method to be tested
        Test.startTest();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        ARTL_BulkCartPlatformEvtTriggerHandler.errorLogCheck(inputMapDRFail, outMap, options);
        Test.stopTest();

       
    }
}