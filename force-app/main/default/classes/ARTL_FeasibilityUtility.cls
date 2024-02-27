/******************************************************************************************************
* @Author:      Sagar Sadhnani  <sagar.sadhnani@salesforce.com >
* @Company:     Salesforc
* @Date:        17th Nov 2023
* @Reviewer:
* @Review Date:
* @Description: This utility is used for Feasibility feature.
* ++++++++++++++++++++++ Changes Implemented / Modification Log ++++++++++++++++++++++++++++++++++++++
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1. SFDC-1636	          Sagar Sadhnani        11/20/2023     Added a method to Parse feasibility Response and Save in Feasibility Data Model
*******************************************************************************************************/

global without sharing class ARTL_FeasibilityUtility implements vlocity_cmt.VlocityOpenInterface {
    
    private static final string FEASIBILITY_REQUEST_TRANSFORM  = 'requestTransform';
    private static final string ADDRESS_VERIFICATION_FOR_QUOTE  = 'addressVerificationForQuote';
    private static final string SUCCESS  = 'success';
    private static final string FEASIBILITY_ID  = 'feasibilityId';
    private static final string RESULT  = 'result';
    private static final string REQUEST_ID  = 'requestId';
    private static final string FEASIBILITY_STATUS  = 'feasibilityStatus';
    private static final string FEASIBILITY_COMPLETED_STATUS  = 'Feasibility Completed';
    private static final string FEASIBILITY_CHECK_COMPLETED_EVENT = 'FEASIBILITY_CHECK_COMPLETED';
    private static final string RESPONSE_INTERFACE = 'interfaces';
    private static final string ATT_INTERFACE = 'ATT_INTERFACE';
    
    
    global boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){
        try
        {      
            System.debug('invokeMethod.methodName'+methodName);
            if(methodName.equalsIgnoreCase(FEASIBILITY_REQUEST_TRANSFORM)){
                return transformRequestAndUpdateQLI(input, output, options);
            } else if(methodName.equalsIgnoreCase(ADDRESS_VERIFICATION_FOR_QUOTE)){
                return addressVerificationForQuote(input, output, options);
            }
              
        }
        catch (Exception ex){         
            System.debug('Exception thrown at invoke ' + methodName + 'msg--'+ex.getMessage());
            System.debug('Exception trace at invoke ' + ex.getStackTraceString());
            output.put('error', ex.getMessage());
        }      
        return false;
    }

    public static void parseData(String data) {
        List<ARTL_Feasibility__c> feasibilityInsertList = new List<ARTL_Feasibility__c>();
        List< ARTL_Feasibility_Line_Item__c> fLIInsertList = new List< ARTL_Feasibility_Line_Item__c>();
        List< ARTL_Feasibility_Attribute__c> fAttrInsertList = new List< ARTL_Feasibility_Attribute__c>();
        Map<Id, QuoteLineItem> qliUpdateMap = new Map<Id, QuoteLineItem>();

        Map<String,Object> dataMap = (Map<String,Object>)JSON.deserializeUntyped(data);
        //KB: checking if its a success response and includes parent node
        if((Boolean)dataMap.get(SUCCESS) && dataMap.containsKey(RESULT)){
            
            Map<String,Object> resultMap = (Map<String,Object>)dataMap.get(RESULT);
            
            if(resultMap.containsKey(FEASIBILITY_ID) && resultMap.containsKey(REQUEST_ID) && resultMap.get(REQUEST_ID) != null){
                String qLIId = (String) resultMap.get(REQUEST_ID);
                //KB: below code is to construct feasibility instance with necessary fields
                ARTL_Feasibility__c feasibilityObj = new ARTL_Feasibility__c(ARTL_Feasibility_ID__c = (String)resultMap.get(FEASIBILITY_ID),
                                        ARTL_Feasibility_Status__c = (String)resultMap.get(FEASIBILITY_STATUS), ARTL_QLI__c = qLIId
                );
                feasibilityInsertList.add(feasibilityObj);
                
                for(String resultAttr: resultMap.keySet()){
                    system.debug('!! attr = '+ resultAttr);
                    parseInfiniteData(resultMap, resultAttr, feasibilityObj, fLIInsertList, fAttrInsertList, null);
                }
                qliUpdateMap.put(qLIId ,new QuoteLineItem(id = qLIId, ARTL_Feasibility__r = feasibilityObj,  ARTL_Feasibility_Response__c = JSON.serialize(dataMap.get(RESULT))));
            }

            if(!feasibilityInsertList.isEmpty()){
                insert feasibilityInsertList;

                if(!fLIInsertList.isEmpty()){
                    for(ARTL_Feasibility_Line_Item__c fli : fLIInsertList){
                        fli.ARTL_Feasibility__c = fli.ARTL_Feasibility__r.id;
                    }
                    insert fLIInsertList;

                    if(!fAttrInsertList.isEmpty()){
                        for(ARTL_Feasibility_Attribute__c fa : fAttrInsertList){
                            fa.ARTL_Feasibility_Line_Item__c = fa.ARTL_Feasibility_Line_Item__r.id;
                        }
                        insert fAttrInsertList;
                        
                        if(!qliUpdateMap.isEmpty()){
                             
                            List<QuoteLineItem> qliList = [SELECT quoteId, vlocity_cmt__AttributeSelectedValues__c FROM QuoteLineItem WHERE id IN :qliUpdateMap.keySet()];
                            String quoteId = qliList[0].quoteId;
                            
                            //KB: Updating interface attribute from the response
                            if(resultMap.containsKey(RESPONSE_INTERFACE) && resultMap.get(RESPONSE_INTERFACE) != null){
                                for(QuoteLineItem obj : qliList){
                                    Map<String, Object> attributeMap = (Map<String, Object>) JSON.deserializeUntyped(obj.vlocity_cmt__AttributeSelectedValues__c);
                                    attributeMap.put(ATT_INTERFACE, resultMap.get(RESPONSE_INTERFACE));
                                    qliUpdateMap.get(obj.id).vlocity_cmt__AttributeSelectedValues__c = JSON.serialize(attributeMap);     
                                }
                            }
                            //KB: Updating feasibility on parent qli as well. In case of primary link, stamping on internet.
                            Set<String> productMappingSet = new Set<String>();
                            for(ARTL_Feasibility_ID_Product_Mapping__mdt productMapping : [SELECT ARTL_From_Product_Code__c, ARTL_To_Product_Code__c FROM ARTL_Feasibility_ID_Product_Mapping__mdt LIMIT 100]){
                                productMappingSet.add(productMapping.ARTL_From_Product_Code__c);
                                productMappingSet.add(productMapping.ARTL_To_Product_Code__c);
                            }
                            if(!productMappingSet.isEmpty()){
                                Map<String, String> rootItemToFeasibilityMap = new Map<String, String>();
                                for(Id qliId : qliUpdateMap.keySet()){
                                    qliUpdateMap.get(qliId).ARTL_Feasibility__c = qliUpdateMap.get(qliId).ARTL_Feasibility__r.id;
                                }

                                for(QuoteLineItem qli: [SELECT ARTL_Feasibility__c, vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__ParentItemId__c, vlocity_cmt__RootItemId__c
                                                        FROM quotelineitem WHERE vlocity_cmt__Product2Id__r.ProductCode IN: productMappingSet AND quoteId = :quoteId
                                                        ORDER BY vlocity_cmt__ParentItemId__c NULLS LAST]
                                ){
                                    if(qliUpdateMap.containsKey(qli.id) && qli.vlocity_cmt__ParentItemId__c != null){
                                        rootItemToFeasibilityMap.put(qli.vlocity_cmt__ParentItemId__c, qliUpdateMap.get(qli.id).ARTL_Feasibility__c);
                                    }
                                    if(rootItemToFeasibilityMap.containsKey(qli.vlocity_cmt__RootItemId__c) && qli.vlocity_cmt__ParentItemId__c == null){
                                        qliUpdateMap.put(qli.id ,new QuoteLineItem(id = qli.id, ARTL_Feasibility__c = rootItemToFeasibilityMap.get(qli.vlocity_cmt__RootItemId__c)));
                                    }
                                }
                            }
                            

                            update qliUpdateMap.values();

                            //KB: Once we ll get response for all the valid QLIs then marking quote status as Feasibility Completed
                            
                            /*List<QuoteLineItem> pendingFeasibilityQLIs = [SELECT id FROM QuoteLineItem 
                                                                        WHERE QuoteId = :quoteId AND ARTL_Feasibility__c = null AND
                                                                        vlocity_cmt__Product2Id__r.ARTL_OFT_Product_Name__c <> null AND
                                                                        vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c <> null
                                                                        LIMIT 1];
                            if(pendingFeasibilityQLIs.isEmpty()){*/
                                update new Quote(id = quoteId, status = FEASIBILITY_COMPLETED_STATUS);   
                                
                                List<ARTL_Feasibility_Event__e> feasibilityEvtList = new List<ARTL_Feasibility_Event__e>();
                                ARTL_Feasibility_Event__e obj = new ARTL_Feasibility_Event__e();
                                obj.ARTL_QuoteId__c  = quoteId;
                                obj.subEventName__c = FEASIBILITY_CHECK_COMPLETED_EVENT;
                                feasibilityEvtList.add(obj);

                                Database.SaveResult[] contractresult = EventBus.publish(feasibilityEvtList);
            
                            //}
                             
                        }
                    }

                }
                
            }
        }
        
    }
 //@TestVisible
    private static void parseInfiniteData(Map<String,Object> resultMap, String level1Attr, ARTL_Feasibility__c feasibilityObj, List< ARTL_Feasibility_Line_Item__c> fLIInsertList, List< ARTL_Feasibility_Attribute__c> fAttrInsertList, ARTL_Feasibility_Line_Item__c parentFLI){
        if(resultMap.get(level1Attr) != null && String.valueOf(resultMap.get(level1Attr)).trim().startsWith('{')){
            system.debug('!! object ');
            //KB: creating feasibility line items for JSON objects attibutes
            ARTL_Feasibility_Line_Item__c fLIObj = new ARTL_Feasibility_Line_Item__c(
                ARTL_Feasibility__r = feasibilityObj, Name = level1Attr, ParentId__r = parentFLI
            );
            fLIInsertList.add(fLIObj);
            Map<String,Object> level2HierarchyMap = (Map<String,Object>)resultMap.get(level1Attr);
            
            for(String level2Attr: level2HierarchyMap.keySet()){
                parseInfiniteData(level2HierarchyMap, level2Attr, feasibilityObj, fLIInsertList, fAttrInsertList, fLIObj);
            }
                
        }else if(parentFLI != null){
            //KB: truncating value if its greater than field length
            String fullValue = String.valueOf(resultMap.get(level1Attr));
            fullValue = fullValue.length() > 255 ? (fullValue.subString(0,250) + '...') : fullValue;
            //system.debug('@@@@ fullValue length =' + fullValue);
            fAttrInsertList.add(new ARTL_Feasibility_Attribute__c(
                Name = level1Attr, Value__c = fullValue, ARTL_Feasibility_Line_Item__r = parentFLI
            ));
        }
    }

    private static boolean addressVerificationForQuote(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap){
        Database.executeBatch(new ARTL_FeasibilityAddressVerificationBatch((String)inputMap.get('quoteId')), 1);
        return true;
    }

    @AuraEnabled
    public static String getReportId(String reportName){
        if(String.isNotBlank(reportName)){
            return [Select id FROM Report WHERE developername = :reportName].id;
        }
        return null;
        
    }
    
    private static boolean transformRequestAndUpdateQLI(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap){
        System.debug('DEBUGG '+ inputMap);
        List<Object> requestList = (List<Object>)inputMap.get('request');
        List<Object> outputList = new List<Object>();
        List<QuoteLineItem> listOfQli = new List<QuoteLineItem>();
        System.debug('DEBUGG req '+ requestList);
        for(Object obj: requestList){
            Map<String,Object> requestInstance = (Map<String, Object>)obj;
            if(requestInstance.containsKey(REQUEST_ID) && requestInstance.get(REQUEST_ID) != null){
                listOfQli.add(new QuoteLineItem(Id = (String) requestInstance.get(REQUEST_ID),
                                               ARTL_Feasibility_Request__c = JSON.Serialize(obj)));
            }
        }
        if(!listOfQli.isEmpty()){
            update listOfQli;
        }
        
        return true;
    }

}