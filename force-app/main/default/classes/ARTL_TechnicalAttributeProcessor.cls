/**
 * Class to process Technical Attributes: ARTL_TechnicalAttributeProcessor
 *
 * @Author  Trishank Chaddha
 * @Company Salesforce (SFI)
 * @Date    25/10/2023
 * @Test Class: 
 * @Description  Process Technical Attributes
 */
global without sharing class ARTL_TechnicalAttributeProcessor implements vlocity_cmt.VlocityOpenInterface {
    public static Map<String,String> requestPayloadMap          	= new Map<String,String>();
    
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
        try {
            /*if (methodName.equals('processTechnicalAttributes')) {
                processTechnicalAttributes(input, outMap, options);
                return true;
            } else*/ if (methodName.equals('extractAttributesFromJSON')) {
                extractAttributesFromJSON(input, outMap, options);
                return true;
            }
        } catch (Exception ex) {
            System.debug('DEBUGG ' + ex.getMessage() + ' ' + ex.getLineNumber());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_TechnicalAttributeProcessor:processTechnicalAttributes', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
        }
        return false;
    }
    
    public static void extractAttributesFromJSON(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){
        List<Object> requestPayloadList = (List<Object>)input.get('requestPL');
        String taskType 				= String.valueOf(input.get('taskType'));
        Boolean fetchTechAttrMap 		= Boolean.valueOf(input.get('isFetchTechAttrMap'));
        String taskId 					= String.valueOf(input.get('taskId')); 
        
        Map<String, String> attributeMap = new Map<String, String>();
        //fetch and store Miscellaneous request payload & Technical attributes in requestPayloadMap
        fetchRequestPayloadFromTask(taskType);
        attributeMap 		= processRequestPayload(requestPayloadList);
        
        //store a unique key
        attributeMap.put('taskId',taskId);
        
        //to fetch technical attributes for NW Jeopardy
        if(fetchTechAttrMap){
            if(input.containsKey('QLI_Id')){
                Map<String, String> masterTechAttMap = new Map<String, String>();
                Id qliId = (Id)input.get('QLI_Id');
                masterTechAttMap = processTechnicalAttributes(qliId);
                
                attributeMap.putAll(masterTechAttMap);
            }else {
                // Handle the case when 'QLI_Id' is not provided in the input map
                ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_TechnicalAttributeProcessor:extractAttributesFromJSON', 'QLI_Id is missing in input', new Map<String, Object>{}, null);
            }  
        }
        
        outMap.put('requestTechAtrrMapList', new List<Object>{attributeMap});
    }
    
    private static void fetchRequestPayloadFromTask(String taskType){
        for(ARTL_TaskTypeIP__mdt  taskTypeMdt:[SELECT Id, ARTL_Request_Payload_Map__c,ARTL_Technical_Attribute_Map__c FROM ARTL_TaskTypeIP__mdt  WHERE DeveloperName =: taskType]){
            requestPayloadMap.put('reqPayload',taskTypeMdt?.ARTL_Request_Payload_Map__c) ;//(Map<String,Object>)JSON.deserializeUntyped(taskTypeMdt.ARTL_Request_Payload_Map__c));
        	requestPayloadMap.put('techAttrPayload',taskTypeMdt?.ARTL_Technical_Attribute_Map__c) ;
        }
    }
    
    //to create payload and fetch Miscellaneous request payload attributes
    private static Map<String, String> processRequestPayload(List<Object> requestPayloadList){
        Map<String,Object> reqPayloadKeyMap = new Map<String,Object>();
        Map<String, String> attributeMap 	= new Map<String, String>();
        
		if(requestPayloadMap.containsKey('reqPayload') && String.isNotBlank(requestPayloadMap.get('reqPayload'))){
            reqPayloadKeyMap = (Map<String,Object>)JSON.deserializeUntyped(requestPayloadMap.get('reqPayload'));
            if(reqPayloadKeyMap!= null && (!reqPayloadKeyMap.keySet().isEmpty())){
                for(String reqAttr:reqPayloadKeyMap.keySet()){
                    attributeMap.put(reqAttr,null);
                    if(!requestPayloadList.isEmpty()){
                        for(Object obj:requestPayloadList){
                            // Deserialize the JSON string into a map
                    		Map<String, Object> jsonMap = (Map<String, Object>)obj;
                            if(jsonMap != null && (reqPayloadKeyMap.get(reqAttr) != null && (String.valueOf(reqPayloadKeyMap.get(reqAttr)) == String.valueOf(jsonMap.get('_Name'))))){
                                attributeMap.put(reqAttr,String.valueOf(jsonMap.get('_Value')));
                            }
                        }
                    }
                }
            } 
        }
		  
        return attributeMap;
    }
    
    // Method to process Technical Attributes and return the masterTechAttMap
    public static Map<String,String> processTechnicalAttributes(String qliId) {
        Map<String,Object> techAttrMap = new Map<String,Object>();
        Map<String, String> masterTechAttMap = new Map<String, String>();
        
        if(requestPayloadMap.containsKey('techAttrPayload') && String.isNotBlank(requestPayloadMap.get('techAttrPayload'))){
            techAttrMap = (Map<String,Object>)JSON.deserializeUntyped(requestPayloadMap.get('techAttrPayload'));
            if(techAttrMap != null){
                for(XLI_Technical_Attribute__c techAttribute : [SELECT Technical_Attribute__c FROM XLI_Technical_Attribute__c WHERE Root_Quote_Line_Item__c = :qliId]) {
                    String jsonStr = techAttribute.Technical_Attribute__c;
                    if (String.isNotBlank(jsonStr)) {
                        Map<String, Object> techAttMap = new Map<String, Object>();
                        techAttMap = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
                        if (techAttMap != null) {
                            for (String techAttr : techAttrMap.keySet()){
                                if(techAttrMap.get(techAttr) != null && techAttMap.containsKey(String.valueOf(techAttrMap.get(techAttr)))){
                                    masterTechAttMap.put(techAttr, String.valueOf(techAttMap.get(techAttr)));
                                }else{
                                    masterTechAttMap.put(techAttr, null);
                                }
                            }
                        }
                    }
                }
            }     
        }
        return masterTechAttMap;
    }
}