/**
* Name: CpqAppHandlerHook
* Description: Hook for CpqAppHandler
* Created By: Sagar Sadhnani
* Created Date: 15th Sep 2023
*/
global with sharing class CpqAppHandlerHookImplementation implements vlocity_cmt.VlocityOpenInterface {
    public virtual class BaseException extends Exception {
    }
    public class CustomException extends BaseException {
    }
    //Constants
    private static final String CPQ_FIELDS = 'vlocity_cmt__BillingAccountId__c,vlocity_cmt__ServiceAccountId__c,Quantity,vlocity_cmt__RecurringTotal__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__OneTimeManualDiscount__c,vlocity_cmt__RecurringManualDiscount__c,vlocity_cmt__ProvisioningStatus__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__OneTimeCharge__c,ListPrice,vlocity_cmt__ParentItemId__c,vlocity_cmt__BillingAccountId__r.Name,vlocity_cmt__ServiceAccountId__r.Name,vlocity_cmt__PremisesId__r.Name,vlocity_cmt__InCartQuantityMap__c,vlocity_cmt__EffectiveQuantity__c';
    private static final String CPQ_PRICE_DETAIL_FIELDS = 'vlocity_cmt__OneTimeCharge__c,vlocity_cmt__OneTimeManualDiscount__c,vlocity_cmt__OneTimeCalculatedPrice__c,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringCalculatedPrice__c,vlocity_cmt__RecurringTotal__c,vlocity_cmt__OneTimeLoyaltyPrice__c,vlocity_cmt__UsageUnitPrice__c,vlocity_cmt__UsagePriceTotal__c,CatalogPrice__c';
    private static final String CUSTOM_FIELDS = 'Annual_Recurring_Charge__c,Annual_Recurring_Total__c,vlocity_cmt__AttributeSelectedValues__c';
    private static final String CUSTOM_PRICE_DETAIL_FIELDS = 'Annual_Recurring_Charge__c';
    
    @TestVisible
    private static final String CART_ID = 'cartId';
    @TestVisible
    private static final String ENTERPRISE_QUOTE_RECORD_TYPE = 'EnterpriseQuote';
    
    global Boolean invokeMethod(string methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        System.debug('🌀 CpqAppHandlerHookImplementation: ' + methodName);
        System.debug('🌀  input: ' + inputMap);
        System.debug('🌀  input: ' + inputMap.keySet());

        // AttributeCustomRuleHelper.findAndRunRule(inputMap);

        try {
            
            //inputMap.put('fields', CPQ_FIELDS+','+CUSTOM_FIELDS);
            //inputMap.put('priceDetailsFields', CPQ_PRICE_DETAIL_FIELDS+','+CUSTOM_PRICE_DETAIL_FIELDS);
            
            //System.debug('methodName--' + methodName);
            if (methodName == 'checkout.PostInvoke') {
                checkoutPostInvoke(inputMap, outputMap, optionsMap);
                return true;
            }
            
                if( methodName.equalsIgnoreCase('postCartsItems.PreInvoke') || methodName.equalsIgnoreCase('postCartsPromoItems.PreInvoke') ||
                    methodName.equalsIgnoreCase('applyAdjustment.PreInvoke') || methodName.equalsIgnoreCase('deleteAdjustment.PreInvoke') ||
                    methodName.equalsIgnoreCase('putCartsItems.PreInvoke') || methodName.equalsIgnoreCase('putItemAttributes.PreInvoke')) {
                                system.debug('Updating the fields->');
                                inputMap.put('fields', CPQ_FIELDS+','+CUSTOM_FIELDS);
                                inputMap.put('priceDetailsFields', CPQ_PRICE_DETAIL_FIELDS+','+CUSTOM_PRICE_DETAIL_FIELDS);
                    }
            
            // String cpqMethodName = (String)vlocity_cmt.FlowstaticMap.flowMap.get('methodName');
            
        } catch (Exception ex) {
            System.debug('--- Exception: ' + ex.getMessage());
            System.debug('--- Stack Trace: ' + ex.getStackTraceString());
            throw ex;
        }
        return true;
    }

    private static void printFlowstaticMap(){
        if(vlocity_cmt.FlowstaticMap.flowMap!=null)
            for(String key : vlocity_cmt.FlowstaticMap.flowMap.keySet())
                System.debug('🇲🇺 FlowstaticMap ' + key + ': ' + vlocity_cmt.FlowstaticMap.flowMap.get(key) ); 
    }

    /**
    * Name: checkoutPostInvoke
    * Description: used to write post script after checkout
    * Author: Sagar Sadhnani
    */
    private void checkoutPostInvoke(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        
        //KB: Below block is to change record type of created quote from opportunity to Enterprise Quote
        if(((String)inputMap.get(CART_ID)).startsWith('006') && outputMap.containsKey('result')){
            
            String createdQuoteId;
            String objectType = '';
            Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(outputMap.get('result')));
            if(objMap.containsKey('records')){
                for(Object recobjItem : (List<Object>)objMap.get('records')) {
                    
                    objMap = (Map<String, Object>) recobjItem;
                    objMap = (Map<String, Object>) objMap.get('fields');
                    createdQuoteId = (String) objMap.get('id');
                    objectType = (String) objMap.get('objectType');
                    
                    //system.debug('@@createdQuoteId '+ objMap.get('id')); 
                }
                
                if(String.isNotBlank(createdQuoteId) && objectType.equalsIgnoreCase('Quote')){
                    Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(ENTERPRISE_QUOTE_RECORD_TYPE).getRecordTypeId();
                    Quote updateQuote = new Quote(id = createdQuoteId, recordTypeId = recordTypeId);
                    update updateQuote;
                    
                    outputMap.put('createdQuoteId', createdQuoteId);
                }
            }
        }
    }
}