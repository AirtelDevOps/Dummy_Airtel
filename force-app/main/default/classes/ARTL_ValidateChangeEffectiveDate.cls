/******************************************************************************************************
* @Author:      Saurav Madhusoodanan TV  <smadhusoodanantv@salesforce.com >
* @Company:     Salesforce
* @Date:        05/01/2024
* @Reviewer:
* @Review Date:
* @Description: Class to validate the change effective date
* ++++++++++++++++++++++ Changes Implemented / Modification Log ++++++++++++++++++++++++++++++++++++++
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 
*******************************************************************************************************/
global without sharing class ARTL_ValidateChangeEffectiveDate {
    
    // Map to store Component Id to Effective Date mapping
    public static Map<String, String> cmpidToEffeDateMap = new Map<String, String>();
    
    // List to store Quote Line Items for validation
    public static List<QuoteLineItem> lsiQLIsList;
    
    /**
     * Invokes the date validation logic based on the API response.
     * @param dateResponseFromApi The API response containing relevant data.
     */
    public static void invokeDateValidation(String dateResponseFromApi) {
        system.debug('invokeDateValidation 26');
        Map<String, Object> dateResponseMap;
        Double lSIId;
        Id quoteId;
        List<Object> cmpidDateResponseList;

        try {
            if (String.isNotBlank(dateResponseFromApi)) {
                System.debug('output dateResponseMap=>'+JSON.serializePretty(dateResponseFromApi));
                System.debug('output dateResponseMap=>'+dateResponseFromApi);
                
                dateResponseMap = (Map<String, Object>) JSON.deserializeUntyped(dateResponseFromApi);
                System.debug('output dateResponseMap=>'+JSON.serializePretty(dateResponseMap));
                // Fetch LSI from the response
                lSIId = Double.valueOf((String) dateResponseMap.get('LSI'));
                // Fetch Quote Id from the response
                quoteId = Id.valueOf((String) dateResponseMap.get('QuoteId'));
                cmpidDateResponseList = (List<Object>) dateResponseMap.get('Response');
                
                // Construct component Id to effective start date Map
                constructCmpidToEffeDateMap(cmpidDateResponseList);
                // Query Quote Line Items for the validations
                fetchQLIForValidation(lSIId, quoteId); 
                // Validate and Update Validated date and Reason
                validateDate();
            }
        } catch (Exception e) {
            System.debug('Exception');
            System.debug('Exception in class::ARTL_ValidateChangeEffectiveDate and method::validateDate @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
    }
    
    /**
     * Fetches Quote Line Items for validation based on LSI and Quote Id.
     * @param lSIId The LSI ID used for filtering Quote Line Items.
     * @param quoteId The Quote ID used for filtering Quote Line Items.
     */
    public static Void fetchQLIForValidation(Double lSIId, Id quoteId) {
        String rootItemId;
        QuoteLineItem lsiQLIRecord;

        try {
            if (lSIId != null && quoteId != null) {
                lsiQLIRecord = [SELECT Id, vlocity_cmt__RootItemId__c 
                                FROM QuoteLineItem 
                                WHERE ARTL_LSI__c = :lSIId AND QuoteId = :quoteId];
                rootItemId = lsiQLIRecord.vlocity_cmt__RootItemId__c;
                lsiQLIsList = [SELECT Id, vlocity_cmt__RootItemId__c, ARTL_LSI__c, ARTL_Component_Id__c,
                               ARTL_Effective_Change_Date__c, ARTL_FX_Validated_Date__c, ARTL_FXValidationMessage__c, ARTL_LSI_Installed_Date__c 
                               FROM QuoteLineItem 
                               WHERE vlocity_cmt__RootItemId__c = :rootItemId AND QuoteId = :quoteId];
                System.debug('lsiQLIsList=>' + JSON.SerializePretty(lsiQLIsList));
            }
        } catch (Exception e) {
            System.debug('Exception');
            System.debug('Exception in class::ARTL_ValidateChangeEffectiveDate and method::fetchQLIForValidation @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
    }
    
    /**
     * Constructs the Component Id to Effective Date map based on the API response.
     * @param cmpidDateResponseList The list of API responses containing Component Id and Effective Start Date.
     */
    public static void constructCmpidToEffeDateMap(List<Object> cmpidDateResponseList) {
        Map<String, Object> cmpidDateResponseListItem;

        try {
            for (Object item : cmpidDateResponseList) {
                cmpidDateResponseListItem = (Map<String, Object>) item;
                cmpidToEffeDateMap.put((String) cmpidDateResponseListItem.get('ComponentId'),
                                       (String) cmpidDateResponseListItem.get('effectiveStartDate'));
            }
            System.debug('cmpidToEffeDateMap=>' + JSON.SerializePretty(cmpidToEffeDateMap));
        } catch (Exception e) {
            System.debug('Exception');
            System.debug('Exception in class::ARTL_ValidateChangeEffectiveDate and method::constructCmpidToEffeDateMap @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
    }
    
    /**
     * Validates the date and updates Validated date and Reason for each Quote Line Item.
     */
    public static void validateDate() {
        String cmpId;
        Date changeEffectiveDate;
        Date effectiveStartDate;
        Date lsiInstalledDate;
        Date dateBefore18Months;

        try {
            for (QuoteLineItem qliRecord : lsiQLIsList) {
                System.debug('qliRecord=>' + JSON.SerializePretty(qliRecord));
                cmpId = qliRecord.ARTL_Component_Id__c;
                System.debug('cmpId=>' + JSON.SerializePretty(cmpId));
                changeEffectiveDate = qliRecord.ARTL_Effective_Change_Date__c;
                System.debug('changeEffectiveDate=>' + changeEffectiveDate);
                lsiInstalledDate=Date.ValueOf(qliRecord.ARTL_LSI_Installed_Date__c);
                System.debug('lsiInstalledDate=>' + lsiInstalledDate);
                dateBefore18Months=lsiInstalledDate.addMonths(-18);
                System.debug('dateBefore18Months=>' + dateBefore18Months);
                
                if (cmpidToEffeDateMap.containsKey(cmpId)) {
                    System.debug('inside ifff 1=>');
                    effectiveStartDate = Date.valueOf(cmpidToEffeDateMap.get(cmpId));
                    System.debug('effectiveStartDate=>' + effectiveStartDate);
                    if (changeEffectiveDate < effectiveStartDate && changeEffectiveDate < lsiInstalledDate && changeEffectiveDate > dateBefore18Months) {
                        System.debug('inside ifff=>changeEffectiveDate < effectiveStartDate');
                        qliRecord.ARTL_FX_Validated_Date__c = effectiveStartDate;
                        qliRecord.ARTL_FXValidationMessage__c = 'Allowed from ' + String.valueOf(effectiveStartDate);
                    }else{
                        System.debug('inside ifff=>changeEffectiveDate > effectiveStartDate');
                        qliRecord.ARTL_FXValidationMessage__c = 'FX Date Validation Failed';
                    }
                }
            }
            update lsiQLIsList;
            System.debug('final lsiQLIsList=>' + JSON.SerializePretty(lsiQLIsList));
        } catch (Exception e) {
            System.debug('Exception');
            System.debug('Exception in class::ARTL_ValidateChangeEffectiveDate and method::validateDate @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
    }
    @AuraEnabled
    public static Boolean checkFXvalidatedDate(Id quoteId){
        List<QuoteLineItem> qliList;
        Boolean needFXValidation=False;
        try{
            qliList=[SELECT Id, ARTL_FX_Validated_Date__c, ARTL_FXValidationMessage__c, ARTL_LSI__c 
                     FROM QuoteLineItem 
                     WHERE QuoteId=:quoteId];
            if(qliList != null && !qliList.isEmpty()){
                for(QuoteLineItem qli:qliList){
                    if(qli.ARTL_FX_Validated_Date__c == null){
                        needFXValidation=True;
                        break;
                    }
                }
            }
        }catch(Exception e){
            System.debug('Exception');
            System.debug('Exception in class::ARTL_ValidateChangeEffectiveDate and method::validateDate @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
        return needFXValidation;
    }
    
    @AuraEnabled
    public static Map <String, Object> invokeFXValidationAPI(Id quoteId){
        Map <String, Object> inputMap = new Map <String, Object>();
        Map <String, Object> outMap= new Map <String, Object>();
        Map <String, Object> options = new Map <String, Object>();
        try{
            
            
            inputMap.put('processName','FXValidateAPI');
            inputMap.put('quoteId',quoteId);
            //String processName = 'FXValidateAPI';
            if (Test.isRunningTest()) {
           		system.debug('test class invokeFXValidationAPI=>');
                StaticResource sr= ARTL_TestDataFactory.fetchDataFromStaticResource('artl_invokeFXValidationAPIResponse');
                String allcontents = sr.body.toString();
                Object untypedObject = JSON.deserializeUntyped(allcontents);
                outMap = (Map<String, Object>)untypedObject;
            }else{
                ARTL_FXValidationDate.ARTL_FXValidationDateIP(inputMap,outMap,options);
            	system.debug('outputMAp=>'+JSON.serializePretty(outMap));
            }
            
            
        }catch(Exception e){
            System.debug('Exception');
            System.debug('Exception in class::ARTL_ValidateChangeEffectiveDate and method::validateDate @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
        return outMap;
    }
}