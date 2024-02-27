public with sharing class ARTL_BulkUploadCartStageLoad {
    public class BulkUploadException extends Exception {} 
    
    @AuraEnabled
    public static String getBulkCartUpdateFile(String body){
        try {
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint('https://b2benterprisebusiness.airtel.com/app/v1/excels/DownloadSfdc');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('api-key', 'NzE5OTNkYTAtNzk5Yi0wMDRhLWQ2MjYtMTQzNGM1ZmFmMDQw');
            request.setHeader('accept','*/*');
            System.debug('body +++ '+body);
            //body = '[{"setup":{"userName":"anju.kumari@salesforce.com","cartIdI":"xxxxxxxxxxx","clientId":"xxxxxxxxxxxxxx","clientSecret":"xxxxxxxxxxxxx"},"records":[{"rootItemId":"e2efe971-ea2a-d3b0-524a-126f80ec9476","lineItems":[{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY","vlocity_cmt__Action__c":"Add","vlocity_cmt__AttributeSelectedValues__c":null,"price":{"vlocity_cmt__OneTimeTotal__c":70000,"vlocity_cmt__OneTimeCharge__c":0,"Annual_Recurring_Charge__c":0,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0},"ProductName":"Internet","linenumber":"0001"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA","vlocity_cmt__Action__c":"Add","price":{"vlocity_cmt__OneTimeTotal__c":90000,"vlocity_cmt__OneTimeCharge__c":15000,"Annual_Recurring_Charge__c":365350,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0},"ProductName":"Primary Link","linenumber":"0001.0001"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA<01t7200000100fNAAQ","vlocity_cmt__Action__c":"Add","vlocity_cmt__AttributeSelectedValues__c":null,"price":{"vlocity_cmt__OneTimeTotal__c":333333,"vlocity_cmt__OneTimeCharge__c":444444,"Annual_Recurring_Charge__c":565656,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0},"ProductName":"iConnectivity IP Block","linenumber":"0001.0001.0001"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA<01t7200000100fNAAQ<01t7200000100kDAAQ","vlocity_cmt__Action__c":"Add","price":{"vlocity_cmt__OneTimeTotal__c":0,"vlocity_cmt__OneTimeCharge__c":0,"Annual_Recurring_Charge__c":0,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0},"ProductName":"iConnectivity LAN IP","linenumber":"0001.0001.0001.0001"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA<01t720000010CbhAAE","vlocity_cmt__Action__c":"Add","price":{"vlocity_cmt__OneTimeTotal__c":0,"vlocity_cmt__OneTimeCharge__c":0,"Annual_Recurring_Charge__c":0,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0},"ProductName":"iConnectivity Routing Type","linenumber":"0001.0001.0002"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA<01t72000000zzzRAAQ","vlocity_cmt__Action__c":"Add","price":{"vlocity_cmt__OneTimeTotal__c":0,"vlocity_cmt__OneTimeCharge__c":0,"Annual_Recurring_Charge__c":0,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0},"ProductName":"Access Last Mile Charge","linenumber":"0001.0001.0003"}]}]},"Requested in 1.769 sec","Workbench 58.0.0"]';            
            //Need to remove this lateer, right now it's hardcoded. 
            request.setBody(body);
            Http http = new Http();
            HttpResponse response = http.send(request);
            System.debug('Response: ' + JSON.serialize(response.getBody()));
            System.debug('Response2: ' + response.getBodyAsBlob());
            return EncodingUtil.base64Encode(response.getBodyAsBlob());
        } catch (Exception e) {
              system.debug('debug error '+ e.getStackTraceString());
                System.debug('Exception type caught: ' + e.getTypeName());    
                System.debug('Message: ' + e.getMessage());    
                System.debug('Cause: ' + e.getCause());    // returns null
                System.debug('Line number: ' + e.getLineNumber());    
                System.debug('Stack trace: ' + e.getStackTraceString());    

            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string invokeGetQLIAPI(String quoteId){
        try {
            Id cartId = quoteId;
            String sObjectType = cartId.getSObjectType().getDescribe().getName();
            //String qutId = '0Q0720000005XMjCAM';
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            if(sObjectType == 'Quote'){
                request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/api/getQuoteLineItems/'+quoteId);
            }else if(sObjectType == 'Order'){
                request.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/api/getOrderLineItems/'+quoteId);
            }
            request.setHeader('Content-Type', 'application/json');
            //request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            //request.setHeader('Authorization', 'Bearer ' + System.UserInfo.getSessionId());
            request.setHeader('Authorization', 'Bearer ' + UtilsGetSessionId.getSessionIdFromVFPage(Page.getSessionIdVFPage));
            System.debug('UserInfo.getSessionId() '+UserInfo.getSessionId());
            //String body = JSON.serialize(mapRequest);
            //request.setBody(body);
            Http http = new Http();
            HttpResponse response = http.send(request);
            System.debug('Response: ' + JSON.serialize(response.getBody()));
            System.debug('Response2: ' + response.getBody());
            return response.getBody();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String loadCartRecords(String jsonRequest){
        //String jsonRequests = jsonRequest;
        //String jsonRequests = '{"userRole":null,"userEmail":"priyankajangir@cyntexa.com","orderType":"New","cartId":"0Q0720000008blZCAQ","NBANumber":"ab1-01652471","DownloadDateTime":"2024-02-21","SecurityKey":"2345","records":[{"rootItemSFid":"0QL72000000A2OjGAK","rootItemId":"ed26f0ac-c4d5-af9b-5a47-53ad929d8fa7","productCode":"3c6df3ca-4424-4131-bde3-c3ea5d5b5925","lineItems":[{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY","vlocity_cmt__Action__c":"Add","product":{"PriceBookEntryId":"01u72000000HWwLAAW","ProductId":"01t72000000znVFAAY","ProductCode":"3c6df3ca-4424-4131-bde3-c3ea5d5b5925","Name":"Internet"},"price":{"vlocity_cmt__OneTimeTotal__c":9898.00,"vlocity_cmt__OneTimeCharge__c":0.00,"Annual_Recurring_Charge__c":0.00,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0.00},"vlocity_cmt__AttributeSelectedValues__c":{"ATT_HANDOVER_TYPE":null,"ATT_SubProductName":"Enterprise ILL","ATT_RATIO":"1:1"},"vlocity_cmt__AssetReferenceId__c":"ed26f0ac-c4d5-af9b-5a47-53ad929d8fa7","Id":"0QL72000000A2OjGAK","Quantity":1.00,"linenumber":"0005"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA","vlocity_cmt__Action__c":"Add","product":{"PriceBookEntryId":"01u72000000HX7dAAG","ProductId":"01t72000000zzcrAAA","ProductCode":"f14f570c-32cf-42b3-9e5c-c29a8e6132c2","Name":"Primary Link"},"price":{"vlocity_cmt__OneTimeTotal__c":9898.00,"vlocity_cmt__OneTimeCharge__c":9898.00,"Annual_Recurring_Charge__c":65656.00,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0.00},"vlocity_cmt__AttributeSelectedValues__c":{"ATT_HANDOVER_TYPE":null,"ATT_BGP_DAMPENING":false,"ATT_RTBH":null,"ATT_SUB_PRODUCT_NAME_CFS":"Enterprise ILL","ATT_Rate_Revision":null,"ATT_DDOS_Mitigation_Bandwidth_CFS":null,"ATT_DEMO_DURATION":null,"ATT_PROFILE_UPDATE":null,"ATT_RELOG_REASON":null,"ATT_ISDEMO_CFS":null,"ATT_DEPENDENT_LINK_LSI":null,"ATT_CUSTOMER_LINK_TYPE":null,"ATT_DDOS_TYPE":null,"ATT_CROSS_CONNECT_REQD":"No","ATT_DDOS_REQUIRED":"No","ATT_IP_REQUIRED":"IPv4","ATT_UPTIME_SLA":"99%","ATT_CPE":"Single CPE","ATT_SERVICE_TYPE":"Fully Managed","ATT_REDUNDANCY":"No","ATT_THIRD_PARTY_TYPE":null,"ATT_BGP_PREFIX_LIMIT_BGPHYD":null,"ATT_OFFNET_CAPEX":null,"ATT_LAST_MILE":"Single Last Mile","ATT_BGP_SESSION_PER_LINK_BGPHYD":null,"ATT_SEND_COMMUNITY_BGPHYD":null,"ATT_REMOVE_PRIVATE_AS_BGPHYD":null,"ATT_FAST_DETECT_BGPHYD":null,"ATT_DEFAULT_ORIGINATE_BGPHYD":null,"ATT_BFD_BGPHYD":null,"ATT_EBGP_MULTIHOP_BGPHYD":null,"ATT_ROUTING_TABLE_BGP":null,"ATT_RESTART_BGPHYD":null,"ATT_PEERING_TYPE_BGPHYD":null,"ATT_MULTIPLIER_BGPHYD":null,"ATT_MINIMUM_INTERVAL_BGPHYD":null,"ATT_KEEPALIVE_BGPHYD":null,"ATT_HOLDTIME_BGPHYD":null,"ATT_ENCAPSULATION_TYPE__BGPHYD":null,"ATT_CUSTOMER_LAN_IP_BGPHYD":null,"ATT_CUSTOMER_AS_NUMBER_BGPHYD":null,"ATT_BGP_ROUTING_TYPE_BGPHYD":null,"ATT_BGP_PASSWORD_BGPHYD":null,"ATT_BGP_INPUT_TYPE_BGPHYD":null,"ATT_AS_SET_BGPHYD":null,"ATT_AS_OVERRIDE_BGPHYD":null,"ATT_ROUTING_PROTOCOL":"None","ATT_POP":"Dual POP","ATT_BGP_Log_BGPHYD":null,"ATT_LEGACY_PORT_BANDWIDTH":null,"ATT_LEGACY_ACCESS_BANDWIDTH":null,"ATT_CONTRACT_TERM":"12 Months","ATT_BGP-REPLACE_AS_BGP":false,"ATT_URL_FILTERING_BGP":false,"ATT_TIMERS_KEEPALIVE_HOLDTIME_BGPHYD":"No","ATT_SOO_BGPHYD":null,"ATT_REMOTE_LOOPBACK_IP_BGPHYD":"Default BGP","ATT_REMOTE_LOOPBACK_IP_SUBNET_BGPHYD":null,"ATT_LOCAL_LOOPBACK_IP_BGPHYD":null,"ATT_INTERFACE":null,"ATT_MEDIA":"Third Party","ATT_MTU_SIZE":"1472","ATT_ENTERPRISE_CONNECTIVITY_TYPE":"Primary","ATT_ROUTING_TABLE_HYD":null,"ATT_ROUTING_TYPE":"None","ATT_PORT_BANDWIDTH":"4 Mbps","ATT_ACCESS_BANDWIDTH":"5 Mbps"},"vlocity_cmt__AssetReferenceId__c":"6e13b311-bae1-6aa6-29bf-0592ab82d7d3","Id":"0QL72000000A2OkGAK","DCP":{"DCPId":null,"DCDPStr":null},"BCP":{"BCPId":"a7e720000000EvpAAE","BCDPStr":"- Aashish - jagya - 9999655199 - aashish.jagya@healthmapdiagnostics.com -  - JIND - Haryana - 126102 -  -"},"BillingData":{"LicenseCompany":"BAL Internet","LegalEntity":"Bharti Airtel Ltd","BillDispatchMethod":"E-mail","BillFrequency":"Monthly","BillingMode":null,"BillingLevel":"Account Level"},"POData":{"POGroupId":null,"PODate":null,"POAmount":null,"PONumber":null,"POTerm":null},"FeasibilityId":null,"Quantity":1.00,"linenumber":"0005.0001"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA<01t7200000100fNAAQ","vlocity_cmt__Action__c":"Add","product":{"PriceBookEntryId":"01u72000000HXcHAAW","ProductId":"01t7200000100fNAAQ","ProductCode":"76d5ed76-e64f-468a-b0b9-fca6b2b33d92","Name":"Connectivity IP Block"},"price":{"vlocity_cmt__OneTimeTotal__c":0.00,"vlocity_cmt__OneTimeCharge__c":0.00,"Annual_Recurring_Charge__c":0.00,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0.00},"vlocity_cmt__AttributeSelectedValues__c":{"ATT_Loopback_IPV6_Subnet":null,"ATT_LOOPBACK_IPV4_SUBNET":null},"vlocity_cmt__AssetReferenceId__c":"36be3fd4-b13d-01f4-0eed-6d4fac735311","Id":"0QL72000000A2OlGAK","Quantity":1.00,"linenumber":"0005.0001.0001"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA<01t7200000100fNAAQ<01t7200000100kDAAQ","vlocity_cmt__Action__c":"Add","product":{"PriceBookEntryId":"01u72000000HXfVAAW","ProductId":"01t7200000100kDAAQ","ProductCode":"a877d7a3-af3f-482e-ba48-bb1e99e8978b","Name":"Connectivity LAN IP"},"price":{"vlocity_cmt__OneTimeTotal__c":0.00,"vlocity_cmt__OneTimeCharge__c":0.00,"Annual_Recurring_Charge__c":0.00,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0.00},"vlocity_cmt__AttributeSelectedValues__c":{"ATT_IP_Type":"IPv4","ATT_LAN_IPV4_SUBNET_MASK":"/32","ATT_LAN_IPV6_SUBNET_MASK":"Not Applicable","ATT_ADDITIONAL_IP_BLOCK":false,"ATT_LAN_IPV4":null,"ATT_LAN_IPV6":null,"ATT_Add_LAN_IPv4":null,"ATT_Add_LAN_IPV4_Subnet":null,"ATT_Add_LAN_IPv6":null,"ATT_Add_LAN_IPV6_Subnet":null,"ATT_Additional_LAN_IPv4":null,"ATT_Additional_LAN_IPv6":null,"ATT_Delete_LAN_IPv4":null,"ATT_Delete_LAN_IPv6":null},"vlocity_cmt__AssetReferenceId__c":"2ed10229-f313-d257-024d-39f6fb748cbb","Id":"0QL72000000A2OmGAK","Quantity":1.00,"linenumber":"0005.0001.0001.0001"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA<01t72000000zzzRAAQ","vlocity_cmt__Action__c":"Add","product":{"PriceBookEntryId":"01u72000000HWujAAG","ProductId":"01t72000000zzzRAAQ","ProductCode":"834851ba-1268-4700-a145-2863b0f9a70f","Name":"Access Last Mile Charge"},"price":{"vlocity_cmt__OneTimeTotal__c":0.00,"vlocity_cmt__OneTimeCharge__c":0.00,"Annual_Recurring_Charge__c":0.00,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0.00},"vlocity_cmt__AttributeSelectedValues__c":null,"vlocity_cmt__AssetReferenceId__c":"31d36d7f-365c-ec39-132b-a115d34b6cd7","Id":"0QL72000000A2OnGAK","Quantity":1.00,"linenumber":"0005.0001.0002"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA<01t72000001pOqvAAE","vlocity_cmt__Action__c":"Add","product":{"PriceBookEntryId":"01u72000000Iy2XAAS","ProductId":"01t72000001pOqvAAE","ProductCode":"ARTL_Port_Bandwidth_Charge","Name":"Port Bandwidth Charge"},"price":{"vlocity_cmt__OneTimeTotal__c":0.00,"vlocity_cmt__OneTimeCharge__c":0.00,"Annual_Recurring_Charge__c":0.00,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0.00},"vlocity_cmt__AttributeSelectedValues__c":null,"vlocity_cmt__AssetReferenceId__c":"d44cbb3e-2add-f0e7-8628-fa8e00489c50","Id":"0QL72000000A2OoGAK","Quantity":1.00,"linenumber":"0005.0001.0003"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA<01t72000001pOxNAAU","vlocity_cmt__Action__c":"Add","product":{"PriceBookEntryId":"01u72000000IxxhAAC","ProductId":"01t72000001pOxNAAU","ProductCode":"ARTL_Dual_POP_Charge","Name":"Dual POP Charge"},"price":{"vlocity_cmt__OneTimeTotal__c":0.00,"vlocity_cmt__OneTimeCharge__c":0.00,"Annual_Recurring_Charge__c":0.00,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0.00},"vlocity_cmt__AttributeSelectedValues__c":null,"vlocity_cmt__AssetReferenceId__c":"ab9c068c-164b-7502-40ae-107e1611cf15","Id":"0QL72000000A2OpGAK","Quantity":1.00,"linenumber":"0005.0001.0005"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA<01t720000010b2DAAQ","vlocity_cmt__Action__c":"Add","product":{"PriceBookEntryId":"01u72000000HYuvAAG","ProductId":"01t720000010b2DAAQ","ProductCode":"VEPC_THIRD_PARTY","Name":"Third Party"},"price":{"vlocity_cmt__OneTimeTotal__c":0.00,"vlocity_cmt__OneTimeCharge__c":0.00,"Annual_Recurring_Charge__c":0.00,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0.00},"vlocity_cmt__AttributeSelectedValues__c":{"ATT_THIRD_PARTY_TYPE":"Third Party Ip1"},"vlocity_cmt__AssetReferenceId__c":"7ac49346-dce2-9bfe-8251-68f76ef1cdf0","Id":"0QL72000000A2OqGAK","Quantity":1.00,"linenumber":"0005.0001.0006"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA<01t720000010685AAA","vlocity_cmt__Action__c":"Add","product":{"PriceBookEntryId":"01u72000000HXIvAAO","ProductId":"01t720000010685AAA","ProductCode":"VEPC_INSTALLATION_CHARGE","Name":"Installation Charge"},"price":{"vlocity_cmt__OneTimeTotal__c":0.00,"vlocity_cmt__OneTimeCharge__c":0.00,"Annual_Recurring_Charge__c":0.00,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0.00},"vlocity_cmt__AttributeSelectedValues__c":null,"vlocity_cmt__AssetReferenceId__c":"d6a0d4b3-a07c-f36d-463e-e01b11fc9972","Id":"0QL72000000A2OrGAK","Quantity":1.00,"linenumber":"0005.0001.0007"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA<01t7200000101JhAAI","vlocity_cmt__Action__c":"Add","product":{"PriceBookEntryId":"01u72000000HXZ3AAO","ProductId":"01t7200000101JhAAI","ProductCode":"2808c41f-a83c-492d-bba9-9bf09e3d8247","Name":"Enterprise Connectivity Routers"},"price":{"vlocity_cmt__OneTimeTotal__c":0.00,"vlocity_cmt__OneTimeCharge__c":0.00,"Annual_Recurring_Charge__c":0.00,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0.00},"vlocity_cmt__AttributeSelectedValues__c":{"ATT_ROUTER_OWNERSHIP":null,"ATT_ROUTER_LEASE_TYPE":"Financial Lease","ATT_ROUTER_TYPE":"Standard","ATT_ITEM_CODE":null,"ATT_ROUTER_MAKE":null,"ATT_HardwareRedundancyRequired_UTM":null,"ATT_Secondary_CPE_Make_UTM":null,"ATT_Secondary_CPE_Model_UTM":null,"ATT_Is_UTM":"No","ATT_Secondary_CPE_ItemCode_UTM":null,"ATT_Sale_Type":"Outright Sale","ATT_ROUTER_MODEL":null,"ATT_ROUSTER_HOST_NAME":null,"ATT_ADDITIONAL_ITEM_CODE_1":null,"ATT_ADDITIONAL_ITEM_CODE_2":null,"ATT_ADDITIONAL_ITEM_CODE_3":null,"ATT_ROUTER_PASSWORD":null,"ATT_ROUTER_SERIAL_NUMBER":null,"ATT_ROUTER_USERNAME":null,"ATT_ADDITIONAL_ITEM_CODE_4":null,"ATT_ADDITIONAL_ITEM_CODE_5":null,"ATT_ADDITIONAL_ITEM_CODE_6":null,"ATT_ADDITIONAL_ITEM_CODE_7":null,"ATT_OPERATING_UNIT":null},"vlocity_cmt__AssetReferenceId__c":"f29c59e5-ac23-9aa0-9ad6-dc8096a3eb45","Id":"0QL72000000A2OsGAK","Quantity":1.00,"linenumber":"0005.0001.0008"},{"vlocity_cmt__ProductHierarchyPath__c":"01t72000000znVFAAY<01t72000000zzcrAAA<01t72000001063FAAQ","vlocity_cmt__Action__c":"Add","product":{"PriceBookEntryId":"01u72000000HXFhAAO","ProductId":"01t72000001063FAAQ","ProductCode":"VEPC_MANAGEABILITY_CHARGE","Name":"Manageability Charge"},"price":{"vlocity_cmt__OneTimeTotal__c":0.00,"vlocity_cmt__OneTimeCharge__c":0.00,"Annual_Recurring_Charge__c":0.00,"vlocity_cmt__RecurringCostTotal__c":null,"vlocity_cmt__RecurringCharge__c":0.00},"vlocity_cmt__AttributeSelectedValues__c":null,"vlocity_cmt__AssetReferenceId__c":"83f6cb14-1f62-9627-cbdc-d872256caa72","Id":"0QL72000000A2OtGAK","Quantity":1.00,"linenumber":"0005.0001.0009"}]}]}';
        //SYSTEM.DEBUG('jsonRequest &&&& '+jsonRequests);
        SYSTEM.DEBUG('jsonRequest &&&& '+jsonRequest);
        Map<String,Object> mapRequest = (Map<String,Object>)JSON.deserializeUntyped(jsonRequest);
        System.debug('mapRequest &&'+mapRequest);
        String cartId = String.valueOf(mapRequest.get('cartId'));
        Id recordId = String.valueOf(mapRequest.get('cartId'));
        String sObjectType = recordId.getSObjectType().getDescribe().getName();
        System.debug(sObjectType);

        List<ARTL_BulkCartUpdate__c> bulkCartUpdateList = [Select id,Status__c from ARTL_BulkCartUpdate__c where Cart_Id__c =:cartId AND Status__c = 'Received'];
        if(bulkCartUpdateList.size() > 0){
            for(ARTL_BulkCartUpdate__c bulkCartUpdate : bulkCartUpdateList){
                bulkCartUpdate.Status__c = 'Failed';
            }
            Database.Update(bulkCartUpdateList);
        }

        List<ARTL_Bulk_Iteration__c> bulkIterationList= [select id from ARTL_Bulk_Iteration__c where Quote__c =:cartId ];
        Integer bulkIterationSize = bulkIterationList.size() + 1;
        ARTL_Bulk_Iteration__c bulkIteration = new ARTL_Bulk_Iteration__c();
        bulkIteration.Quote__c = cartId;
        bulkIteration.Iteration_Id__c = String.valueof(bulkIterationSize);
        Database.insert(bulkIteration);
        
        if (mapRequest.containsKey('records')) {
            List<Object> lstRecords = (List<Object>)mapRequest.get('records');
            List<ARTL_BulkCartUpdate__c> lstBulkCartUpdate = new List<ARTL_BulkCartUpdate__c>();            
            for(Object objIterator : lstRecords){
                ARTL_BulkCartUpdate__c objBulkCart = new ARTL_BulkCartUpdate__c();
                objBulkCart.Cart_Id__c = cartId;
                objBulkCart.Sobject_Type__c = sobjectType;
                objBulkCart.Status__c = 'Received';
                objBulkCart.Iteration_Id__c = bulkIteration.id;
                objBulkCart.Request_JSON_Payload__c = JSON.serialize(objIterator);
                lstBulkCartUpdate.add(objBulkCart);
            }
            insert lstBulkCartUpdate;
            List<ARTL_BulkCartUpdate__c> BulkCartUpdateRecordvAR = [select id,Status__c from ARTL_BulkCartUpdate__c where (Status__c = 'Received' AND Cart_Id__c=:cartId and Sobject_Type__c='Quote')  LIMIT  1];
            if(BulkCartUpdateRecordvAR.size()>0){
                BulkCartUpdateRecordvAR[0].Status__c = 'Processed';
                update BulkCartUpdateRecordvAR[0];
            }
            return 'method call if';
        }
        else {
            
            throw new BulkUploadException('No records found in the Request');
            
        }
    }
    
    @testVisible
    private String getSobjectType(String recordId){
        
        switch on recordId.substring(0,2) {
            when '0Q0' {	
                return 'Quote';
            }	
            when '801' {	
                return 'Order';
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static string ARTL_ExceltoJsonCallout(String hbody){
        try{
            Http http = new Http();
            System.debug('base64 '+hbody);
            Blob payloadBlob = EncodingUtil.base64Decode(hbody);
            System.debug('payloadBlob '+payloadBlob);
            //String payload = payloadBlob.toString();
            //System.debug('payload '+payload);
            HttpRequest request = new HttpRequest();
            request.setEndPoint('https://b2benterprisebusiness.airtel.com/app/v1/excels/ExcelToJsonSfdc');
            request.setMethod('POST');
            request.setHeader('api-key', 'NzE5OTNkYTAtNzk5Yi0wMDRhLWQ2MjYtMTQzNGM1ZmFmMDQw');
            request.setHeader('Content-Type', 'application/octet-stream');
            //request.setHeader('Authorization', 'Basic aHVsazpodWxrQDEyMw==');
            //Attachment att = [select Body from Attachment where Id = '00P72000005HMu5'];
            //request.setBody(att.Body);
            //request.setBodyAsBlob(att.Body);
            request.setBodyasBlob(payloadBlob);
            HttpResponse response = http.send(request);
            System.debug(response.getBody());
            System.debug(response);
            return response.getBody();
            //return 'response';
        }
        catch(Exception e){
            System.debug('e  '+e);
            return e.getmessage();
        }
    }
    /*Created by KOMAL SHARMA for validation  during Bulk Asset Modification */
   /* Public static void ARTL_BulkAssetModificationValidation(List<ARTL_Bulk_Upload_Iteration__c> UploadIterationsList ,List<ARTL_Bulk_Upload_Staging__c> UploadStagingList , List<Asset> AssetsList,  Id accountId){
        try{
            Map<String, Asset> bulkAssetModificationMap = new Map<String, Asset>();
            Map<String, Asset> rootAssetMap = new Map<String, Asset>();
            Map<String, string> errorMessageMap = new Map<String, string>();
            Set<String> assetRootIds = new Set<String>();
            List<Id> SuccessUpdateAssetList = new List<Id>();
            ARTL_Bulk_Upload_Iteration__c IterationRecord = UploadIterationsList[0];
            System.debug('IterationRecord '+IterationRecord);
            for(Asset assetRecord: AssetsList){
                if(assetRecord.AccountId == accountId){
                    //System.debug('assetRecord   ***  '+assetRecord);
                    assetRootIds.add(assetRecord.vlocity_cmt__RootItemId__c);
                    
                }
            }
            List<Id> rootAssetIds = new List<Id>();
            List<Asset> rootAssetList = [select id,AccountId ,RootAssetId, vlocity_cmt__RootItemId__c, vlocity_cmt__ParentItemId__c,vlocity_cmt__AssetReferenceId__c,  vlocity_cmt__LineNumber__c from Asset where vlocity_cmt__AssetReferenceId__c IN : assetRootIds AND AccountId =:accountId ];
            for(Asset assetRecord: rootAssetList){
                rootAssetIds.add(assetRecord.id);
                rootAssetMap.put(assetRecord.vlocity_cmt__AssetReferenceId__c ,assetRecord);
            }
            
            for(Asset assetRecord: AssetsList){
                if(!rootAssetMap.containsKey(assetRecord.vlocity_cmt__RootItemId__c)){
                    errorMessageMap.put(String.valueOf(assetRecord.ARTL_LSI__c), 'Uploading an mismatch asset');
                }else{
                    errorMessageMap.put(String.valueOf(assetRecord.ARTL_LSI__c), 'Uploading an right asset');
                    SuccessUpdateAssetList.add(assetRecord.id);
                }
            }
            
            for(ARTL_Bulk_Upload_Staging__c UploadStagingRecord: UploadStagingList){
                if(errorMessageMap.containsKey(UploadStagingRecord.Record_Id__c)){
                    UploadStagingRecord.Errors__c = errorMessageMap.get(UploadStagingRecord.Record_Id__c);
                }
            }
            For(ID df:SuccessUpdateAssetList){
                system.debug('df '+df);
            }
            update UploadStagingList;
            System.debug('UploadStagingList-->'+UploadStagingList);
            Map<String, Object> ipAdjustmentInput = new Map<String, Object>();
            ipAdjustmentInput.put('accountId',accountId);
            ipAdjustmentInput.put('SuccessUpdateAssetList',SuccessUpdateAssetList);
            If(UploadStagingList.size()>0){
                ARTL_AssetController.createQuoteAndOpportunity(UploadStagingList,IterationRecord,ipAdjustmentInput,rootAssetIds);
            }
        }catch(Exception e){
            String str = e.getMessage() + e.getStackTraceString();
            System.debug('ARTL_BulkAssetModificationValidation  '+str);
        }
        
    }*/
}