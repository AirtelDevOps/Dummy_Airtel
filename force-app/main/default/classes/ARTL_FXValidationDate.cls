global without sharing class ARTL_FXValidationDate implements vlocity_cmt.VlocityOpenInterface {
	private static String PROCESS_NAME = 'processName';
    private static String ENDPOINT_URL = 'endpoint';
    private static String NAMED_CREDENTIALS = 'namedCredentials';
    private static String API_KEY = 'apiKey';
    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> outMap, Map<String,Object> options){
        try{
            if(methodName.equals('ARTL_FXValidationDateIP')){
              ARTL_FXValidationDateIP(input,outMap,options);
              return true;
            }
        }catch(Exception ex){
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_FXValidationDate:invokeMethod', '', new Map<String,Object>{'Exception'=>ex.getMessage() , 'LineNumber' => ex.getLineNumber()}, ex);
        }
        return false;
  }
    public static void ARTL_FXValidationDateIP(Map <String, Object> input, Map <String, Object> outMap, Map <String, Object> options){
        try{
            String processName  = input.containsKey(PROCESS_NAME) && input.get(PROCESS_NAME) != null ? String.valueOf(input.get(PROCESS_NAME)): '';
            String quoteId = (String)input.get('quoteId');
            system.debug('quoteId is : ' +quoteId);
            if(String.isNotBlank(processName)){
                CalloutConfigWrapper calloutConfig = fetchConfigDetails(processName);
                if(calloutConfig != null){
                    input.put(ENDPOINT_URL,calloutConfig.endpointURL);
                    input.put(NAMED_CREDENTIALS,calloutConfig.namedCreds);
                    if(String.isNotBlank(calloutConfig.apiKey)){
                        input.put(API_KEY,calloutConfig.apiKey);
                    }
                }
                List<QuoteLineItem> qliList = [Select Id, ARTL_LSI_OLI_Formula__c from QuoteLineItem where QuoteId = :quoteId AND ARTL_LSI_OLI_Formula__c != null];
                for(QuoteLineItem qliLSI : qliList){
                    input.put('qliLSI',qliLSI.ARTL_LSI_OLI_Formula__c);
                    input.put('QuoteLineItemId',qliLSI.Id);
                    ARTL_FXValidationDate.IntegrationProcedureQueueable ipq = new ARTL_FXValidationDate.IntegrationProcedureQueueable(calloutConfig.ipName, input, null);
                    System.enqueueJob(ipq);
                }
            }else{
                ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_FXValidationDate:ARTL_FXValidationDateIP', '','', new Map<String,Object>{'Error'=>'No Process name defined.'});
            }
        }catch(Exception ex){
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_FXValidationDate:ARTL_FXValidationDateIP', '', new Map<String,Object>{'Exception'=>ex.getMessage() , 'LineNumber' => ex.getLineNumber()}, ex);
        }
    }
    public static CalloutConfigWrapper fetchConfigDetails(String processName){
        CalloutConfigWrapper configObj = new CalloutConfigWrapper();
        
        for(ARTL_Callout_Event_Configs__mdt configRecord : [SELECT ARTL_Type__c, ARTL_API_Key__c ,ARTL_EndPointURL__c,ARTL_IntegrationProcedureName__c,ARTL_NameCredentials__c,ARTL_Operation__c,ARTL_Pattern__c,ARTL_Retry__c FROM ARTL_Callout_Event_Configs__mdt WHERE MasterLabel =:processName LIMIT 1]){
            configObj.calloutType       = configRecord.ARTL_Type__c;
            configObj.endpointURL       = configRecord.ARTL_EndPointURL__c;
            configObj.ipName            = configRecord.ARTL_IntegrationProcedureName__c;
            configObj.namedCreds        = configRecord.ARTL_NameCredentials__c;
            configObj.requestMethod     = configRecord.ARTL_Operation__c;
            configObj.pattern           = configRecord.ARTL_Pattern__c;
            configObj.retryCount        = Integer.valueOf(configRecord.ARTL_Retry__c);
            configObj.apiKey        	= configRecord.ARTL_API_Key__c;
        }
        
        return configObj;
    }
    
    global class CalloutConfigWrapper{
        global String calloutType;
        global String endpointURL;
        global String ipName;
        global String namedCreds;
        global String requestMethod;
        global String pattern;
        global Integer retryCount;
        global String apiKey;
    }
    public static Map<String,Object> FXValidationDateIP(String procedureName,Map <String, Object> ipInput,Map <String, Object> ipOptions){
        Map <String, Object> ipOutput = new Map <String, Object> ();
        Map<String,Object>ipResponse = new Map<String, Object>();
        String jsonStringResponse;
        system.debug( 'lsi is : ' + (String)ipInput.get('qliLSI'));
         ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
         ipOutput.put('LSI',(String)ipInput.get('qliLSI'));
         ipOutput.put('QuoteId',(String)ipInput.get('quoteId'));
         ipOutput.put('QuoteLineItemId',(String)ipInput.get('QuoteLineItemId'));
         System.debug(JSON.serializePretty('73 ipOutput -->>'+ipOutput));
         jsonStringResponse = parseJson(ipOutput);
         ARTL_ValidateChangeEffectiveDate.invokeDateValidation(jsonStringResponse);
         ipResponse = (Map<String, Object>)JSON.deserializeUntyped(jsonStringResponse);
        System.debug('73 ipResponse -->>'+JSON.serializePretty(ipResponse));
        ARTL_Logger.debug(ARTL_Constants.CONTROLLER, procedureName+':FXValidationDateIP', '', new Map<String,Object>{'IP Input'=>ipInput , 'IP Output' => ipOutput});
        return ipResponse;
    }
    global without sharing class IntegrationProcedureQueueable implements Queueable, Database.AllowsCallouts {
        String procedureName;
        Map <String, Object> ipInput;
        Map <String, Object> ipOptions;
        
        public IntegrationProcedureQueueable(String procedureName, Map <String, Object> ipInput, Map <String, Object> ipOptions) {
            this.procedureName = procedureName;
            this.ipInput = ipInput;
            this.ipOptions = ipOptions;
        }
        
        public void execute(QueueableContext context) {
            ARTL_FXValidationDate.FXValidationDateIP(procedureName,ipInput,ipOptions);
        }
    }
    //List<Map<String,Object>>
    public static String  parseJson(Map<String,Object> jsonMap) {
        string ComponentId;
        string ServiceActiveDate;
        string effectiveStartDate;
        List<string> outputJson = new List<string>();
        String finalJSON='';
        //Map<String, Object> addNodeMap = new  Map<String, Object>();
        if (jsonMap.containsKey('getCustomerPlanOldNewMappingResMsg')) {
            Map<String, Object> resMsg = (Map<String, Object>) jsonMap.get('getCustomerPlanOldNewMappingResMsg');
            if (resMsg.containsKey('dataArea')) {
                Map<String, Object> dataArea = (Map<String, Object>) resMsg.get('dataArea');
                if (dataArea.containsKey('getCustomerPlanOldNewMapping')) {
                    Map<String, Object> mapping = (Map<String, Object>) dataArea.get('getCustomerPlanOldNewMapping');
                    if (mapping.containsKey('customerOrder')) {
                        Map<String, Object> customerOrder = (Map<String, Object>) mapping.get('customerOrder');
                        if (customerOrder.containsKey('customerOrderItem')) {
                            List<Object> orderItems = (List<Object>) customerOrder.get('customerOrderItem');
                            for (Object orderItemObject : orderItems) {
                                string json='';
                                Map<String, Object> orderItem = (Map<String, Object>) orderItemObject;
                                if (orderItem.containsKey('product')) {
                                    Map<String, Object> product = (Map<String, Object>) orderItem.get('product');
                                    if (product.containsKey('productLine')) {
                                        Map<String, Object> productLine = (Map<String, Object>) product.get('productLine');
                                        if (productLine.containsKey('type') && productLine.get('type').equals('Component')) {
                                            List<Object> externalIds = (List<Object>) product.get('externalIdentification');
                                            for (Object externalIdObject : externalIds) {
                                                Map<String, Object> externalId = (Map<String, Object>) externalIdObject;
                                                if (externalId.containsKey('name') && externalId.get('name').equals('LegacyCompId')) {
                                                    System.debug('LegacyCompId: ' + externalId.get('id'));
                                                    json=json+ '{' ;
                                                    componentId=string.valueOf(externalId.get('id'));
                                                    json = json+' "ComponentId" : "' + componentId + '",' ;   
                                                }
                                                if (externalId.containsKey('name') && externalId.get('name').equals('ServiceActiveDate')) {
                                                    System.debug('Service Active Date: ' + externalId.get('id'));
                                                    serviceActiveDate=string.valueOf(externalId.get('id'));
                                                    json = json+' "ServiceActiveDate" : "' + serviceActiveDate + '",' ; 
                                                }
                                            }
                                        }
                                    }
                                    if (orderItem.containsKey('effectiveStartDate')) {
                                        System.debug('Effective Start Date: ' + orderItem.get('effectiveStartDate'));
                                        effectiveStartDate=string.valueOf(orderItem.get('effectiveStartDate'));
                                        json =json+' "effectiveStartDate" : "' + effectiveStartDate + '"' ;
                                        json =json+'}';
                                        system.debug('jsonresult '+json);
                                        outputJson.add(json);
                                    }
                                }
                            } 
                            String concatenatedString = String.join(outputJson, ', ');
                            System.debug('concatenatedString --->>'+concatenatedString);
                            finalJSON = '{ "LSI" : "'+(String)jsonMap.get('LSI')+'",'+'"QuoteId" : "'+(String)jsonMap.get('QuoteId')+'",'+'"QuoteLineItemId" : "'+(String)jsonMap.get('QuoteLineItemId')+'",'+'"Response" : '+ '['+concatenatedString + ']}';
                            System.debug('finalJSON --->>'+finalJSON);
                        }
                    }
                }
            }  
        }
        System.debug('outputJson 80-->>'+outputJson);
        return finalJSON;
        }
        }