public class ARTL_ValidateStagingData implements Database.Batchable<sObject>,Database.AllowsCallouts,Database.Stateful{
    /*String quoteid='0Q0720000003eFRCAY';
Database.executeBatch(new ARTL_ValidateStagingData(quoteid));*/
    
    public String quoteId;
    public boolean isTest;
    
    public ARTL_ValidateStagingData(String quoteId, Boolean isTest){
        this.quoteId = quoteId;
        this.isTest = isTest;
        //this.isTest = isTest;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('quoteId '+quoteId);
        return Database.getQueryLocator([
            SELECT Id, Quote__c, Quote_Line_Item__c, Quote_Line_Item__r.Quote.AccountId, Service_Account_Id__c, Product_Name__c, Product_Code__c, Site_Street__c, Site_City__c, Site_State__c, Site_Country__c,
            Site_PinCode__c, Delivery_GST__c, Billing_GST_Applicable_for_Billing__c, Billing_GST__c, Site_GST_Applicable_for_Billing__c, Has_Service_Account__c, 
            Billing_Standard_Reason__c, Delivery_Standard_Reason__c, Installation_GST_Applicable__c, DCP_First_Name__c, DCP_Last_Name__c,
            DCP_Phone__c, DCP_Email__c, NBA_Account_Number__c, Billing_Account_Number__c, PO__c, PO_Start_Date__c, PO_Group__c, 
            Legal_Entity__c, Credit_Period__c, Store__c, Billing_Level__c, Billing_Street__c, Billing_City__c, Billing_State__c, 
            Billing_PinCode__c,Billing_Country__c, BCP_First_Name__c, BCP_Last_Name__c, BCP_Phone__c, BCP_Email__c, Site_is_Same_as_Billing_Address__c, Shipping_Street__c,
            Shipping_City__c, Shipping_State__c, PO_Terms_Years__c, Shipping_PinCode__c,Shipping_Country__c, ARTL_PO_Id__c, ARTL_PO_Group_Id__c, Quote_Member__c, OwnerId, ARTL_Bill_Frequency__c, Bill_Type__c,
            Quote_Line_Item__r.vlocity_cmt__QuoteMemberId__r.DCP_Record__c,Quote_Line_Item__r.vlocity_cmt__QuoteMemberId__c,BCP_Id__c,Quote_Line_Item__r.ARTL_LSI__c
            FROM ARTL_Billing_Staging__c
            WHERE Quote__c=:quoteId]
                                       );
    }
    
    public void execute(Database.BatchableContext BC, List<ARTL_Billing_Staging__c> scope)
    {
        Map<String, Object> resultMap = new Map<String, Object>();
        Set<String> poNumberList = new Set<String>();
        Map<string,string> StageLsiToErrorMap= new Map<string,string>();
        Map<string,string> QliToError= new Map<string,string>();
        List<QuoteLineItem> qliToUpdate=new List<QuoteLineItem>();
        if(isTest){
            StaticResource sr= ARTL_TestDataFactory.fetchDataFromStaticResource('Artl_ValidateBillingStagingResponse');
            String allcontents = sr.body.toString();
            Object untypedObject = JSON.deserializeUntyped(allcontents);
            resultMap = (Map<String, Object>)untypedObject;
        }
        else{
            resultMap = ARTL_ValidateStagingDataHelper.getMetadata();
            system.debug(resultMap.keySet());
        }
        
        //Map<String, Object> resultMap = ARTL_ValidateStagingDataHelper.getMetadata();
        List<Object> validateFiledsList = new List<Object> ();
        List<sObject> billingAccountList = new List<sObject> ();
        Set<String> AccountNumbers = new Set<String>();
        boolean isValid;
        Map<String, ARTL_Billing_Staging__c> POGroupMap = new Map<String, ARTL_Billing_Staging__c>();
        //Map<String, ARTL_Billing_Staging__c> POMap = new Map<String, ARTL_Billing_Staging__c>();
        Map<String, List<ARTL_Billing_Staging__c>> POMap = new Map<String, List<ARTL_Billing_Staging__c>>();
        
        try{
            for(ARTL_Billing_Staging__c stage:scope){
                //system.debug(stage.Quote_Line_Item__r.vlocity_cmt__QuoteMemberId__c);
                //system.debug(stage.Quote_Line_Item__r.vlocity_cmt__QuoteMemberId__r.DCP_Record__c);
                List<string> errorMessageList = new List<string>();
                //For Validation
                for(String validateItem: resultMap.keyset()){
                    system.debug('validateItem:::' + validateItem);
                if (validateItem == 'fields') {
                    system.debug('inside fields');
                    String errorMessage = '';
                    //List<String> errorMessageList = new List<String>();
                    List<Object> validateFieldsList = (List<Object>)resultMap.get(validateItem);
                    
                    for (Object fieldObj : validateFieldsList) {
                        Map<String, Object> validateFields = (Map<String, Object>)fieldObj;
                        Object fieldVal;
                        String fieldName = (String)validateFields.get('fieldName');
                    if (!errorMessageList.contains(fieldName)) {
                        if(fieldName.contains('Quote_Line_Item__r.vlocity_cmt__QuoteMemberId__r.DCP_Record__c') && stage.get('Quote_Line_Item__c')!=null &&
                        stage.getsobject('Quote_Line_Item__r').getsobject('vlocity_cmt__QuoteMemberId__r')!=null){
                        // dependentFieldVal = stage.getsobject('Quote_Line_Item__r').getsobject('vlocity_cmt__QuoteMemberId__r').get(dependentField.trim());
                        fieldVal = stage.getsobject('Quote_Line_Item__r').getsobject('vlocity_cmt__QuoteMemberId__r').get('DCP_Record__c');
                            
                            }
                            else {
                                fieldVal = stage.get((String)validateFields.get('fieldName'));
                            }
                        
                        Boolean requiredFieldVal = (Boolean)validateFields.get('required');
                        if ((fieldVal == null && requiredFieldVal && validateFields.containsKey('dependentOn')))
                            {
                                if ( (String)validateFields.get('dependentOn') != null 
                                && !String.isBlank(((String)validateFields.get('dependentOn')).trim() )){
                                    Set<String> dependentOnList = new Set<String>(((String)validateFields.get('dependentOn')).split(','));
                                    for (String dependentField : dependentOnList) {
                                        Object dependentFieldVal;
                                        system.debug(dependentField);
                                        //system.debug('stage::' + (stage.getsobject('Quote_Line_Item__r').getsobject('vlocity_cmt__QuoteMemberId__r')).get('DCP_Record__c'));
                                        if(dependentField.trim().contains('Quote_Line_Item__r.vlocity_cmt__QuoteMemberId__r.DCP_Record__c') && stage.get('Quote_Line_Item__c')!=null &&
                                        stage.getsobject('Quote_Line_Item__r').getsobject('vlocity_cmt__QuoteMemberId__r')!=null){
                                        // dependentFieldVal = stage.getsobject('Quote_Line_Item__r').getsobject('vlocity_cmt__QuoteMemberId__r').get(dependentField.trim());
                                        dependentFieldVal = stage.getsobject('Quote_Line_Item__r').getsobject('vlocity_cmt__QuoteMemberId__r').get('DCP_Record__c');
                                            
                                    }
                                        else if(!dependentField.trim().contains('Quote_Line_Item__r.vlocity_cmt__QuoteMemberId__r.DCP_Record__c')){
                                            dependentFieldVal=stage.get(dependentField.trim());
                                        }
                                                                                    
                                            if (dependentFieldVal == null) {
                                                if (!errorMessageList.contains(dependentField)) {
                                                    errorMessageList.add(dependentField.trim());
                                                }
                                                }
                                        }
                                }
                        
                            }
                            else if((fieldVal == null && requiredFieldVal && !validateFields.containsKey('dependentOn'))) {
                                if (!errorMessageList.contains(fieldName)) {
                                    errorMessageList.add(fieldName);
                                }
                            }
                        
                    }
                    }
                    
                    }
                    
                    if(validateItem =='LegalEntity'){
                        String errorMesg = '';
                        Map<String, Object> validateFields = new Map<String, Object>();
                        validateFiledsList = (List<Object>)resultMap.get(validateItem);
                        system.debug('validateFiledsList-->'+validateFiledsList);
                        List<string> errorMessage = new List<string>();
                        String stageProductName = (string)stage.get('Product_Name__c');
                        String LegalEntity = (string)stage.get('Legal_Entity__c');
                        if(!String.isBlank(stageProductName) && stageProductName != null){
                            for(Object fields : validateFiledsList){
                                validateFields = (Map<String, Object>) fields;  
                                String validationMapProductName = (String)validateFields.get('Product');
                                if(validationMapProductName == stageProductName && !String.isBlank(LegalEntity) && (String)validateFields.get('LegalEntity') != LegalEntity){
                                    //System.debug('LegalEntity::Invalid');
                                    errorMessage.add('Invalid LegalEntity');
                                    errorMesg = string.join(errorMessage,',');
                                    errorMessageList.add(errorMesg);
                                }
                                else if(validationMapProductName == stageProductName && String.isBlank(LegalEntity)){
                                    
                                    //System.debug('LegalEntity::MANDATORY');
                                    errorMessage.add('LegalEntity is Mandatory');
                                    errorMesg = string.join(errorMessage,',');
                                    errorMessageList.add(errorMesg);                                    }
                                else{
                                    //System.debug('LegalEntity::Is Valid');
                                }  
                                
                            }
                        }
                    } 
                    if(validateItem =='BillingStandardReason'){
                        String errorMesg = '';
                        Map<String, Object> validateFields = new Map<String, Object>();
                        validateFiledsList = (List<Object>)resultMap.get(validateItem);
                        system.debug('validateFiledsList-->'+validateFiledsList);
                        Set<string> errorMessage = new Set<string>();
                        String BillingStandardReason = (string)stage.get('Billing_Standard_Reason__c');
                        String DeliveryGST  = (string)stage.get('Delivery_GST__c');
                        if(DeliveryGST == null && BillingStandardReason == null){
                            errorMessage.add('Billing Standard Reason or Delivery GST is MANDATORY');
                            errorMesg = string.join(errorMessage,',');
                            errorMessageList.add(errorMesg);
                        }
                        isValid = ARTL_ValidateStagingDataHelper.validateStandardReasons(BillingStandardReason, validateFiledsList);
                        if (isValid == true) {
                            System.debug(BillingStandardReason + ' exists in the list.');
                        } 
                        else {
                            errorMessage.add('Invalid Billing Standard Reason');
                            System.debug(BillingStandardReason + ' does not exist in the list.');
                        }
                        errorMesg = string.join(errorMessage,',');
                        errorMessageList.add(errorMesg); 
                        
                        
                       
                    } 
                    if(validateItem =='DeliveryStandardReason'){
                        String errorMesg = '';
                        Map<String, Object> validateFields = new Map<String, Object>();
                        validateFiledsList = (List<Object>)resultMap.get(validateItem);
                        system.debug('validateFiledsList-->'+validateFiledsList);
                        Set<string> errorMessage = new Set<string>();
                        String DeliveryStandardReason  = (string)stage.get('Delivery_Standard_Reason__c');
                        String DeliveryGST  = (string)stage.get('Delivery_GST__c');
                        if(DeliveryGST == null && DeliveryStandardReason == null){
                            errorMessage.add('Delivery Standard Reason or Delivery GST is MANDATORY');
                            errorMesg = string.join(errorMessage,',');
                            errorMessageList.add(errorMesg);
                        }
                        
                        isValid = ARTL_ValidateStagingDataHelper.validateStandardReasons(DeliveryStandardReason, validateFiledsList);
                        if (isValid == true) {
                            System.debug(DeliveryStandardReason + ' exists in the list.');
                        } 
                        else {
                            errorMessage.add('Invalid Delivery Standard Reason');
                            System.debug(DeliveryStandardReason + ' does not exist in the list.');
                        }
                        errorMesg = string.join(errorMessage,',');
                        errorMessageList.add(errorMesg); 
                        
                       
                    } 
                    if(validateItem == 'BillType'){
                        String errorMesg = '';
                        Map<String, Object> validateFields = new Map<String, Object>();
                        validateFiledsList = (List<Object>)resultMap.get(validateItem);
                        system.debug('validateFiledsList-->'+ JSON.serializePretty(validateFiledsList) );
                        system.debug('stageBillType---->'+JSON.serializePretty(stage));
                        Set<string> errorMessage = new Set<string>();
                        String billType  = (string)stage.get('Bill_Type__c');
                        
                        isValid = ARTL_ValidateStagingDataHelper.validateStandardReasons(billType, validateFiledsList);
                        if (isValid == true) {
                            System.debug(billType + ' exists in the list.');
                        } 
                        else {
                            errorMessage.add('Invalid Bill Type');
                            System.debug(billType + ' does not exist in the list.');
                        }
                        errorMesg = string.join(errorMessage,',');
                        errorMessageList.add(errorMesg); 
                        
                       
                    }
                    if(validateItem == 'CreditPeriod'){
                        String errorMesg = '';
                        Map<String, Object> validateFields = new Map<String, Object>();
                        validateFiledsList = (List<Object>)resultMap.get(validateItem);
                        system.debug('validateFiledsList-->'+ JSON.serializePretty(validateFiledsList) );
                        system.debug('stageBillType---->'+JSON.serializePretty(stage));
                        Set<string> errorMessage = new Set<string>();
                        String creditPeriod  = (string)stage.get('Credit_Period__c');
                        isValid = ARTL_ValidateStagingDataHelper.validateStandardReasons(creditPeriod, validateFiledsList);
                        if (isValid == true) {
                            System.debug(creditPeriod + ' exists in the list.');
                        } 
                        else {
                            errorMessage.add('Invalid Credit Period');
                            System.debug(creditPeriod + ' does not exist in the list.');
                        }
                        errorMesg = string.join(errorMessage,',');
                        errorMessageList.add(errorMesg); 
                        
                        
                    }
                    if(validateItem == 'Store'){
                        String stageProductName = (string)stage.get('Product_Name__c');
                        String errorMesg = '';
                        Map<String, Object> validateFields = new Map<String, Object>();
                        validateFiledsList = (List<Object>)resultMap.get(validateItem);
                        Set<string> errorMessage = new Set<string>();
                        String store  = (string)stage.get('Store__c');
                        system.debug(stageProductName);
                        if(stageProductName!=null && stageProductName.contains('NIPS') && !string.isBlank(store)){
                            isValid = ARTL_ValidateStagingDataHelper.validateStandardReasons(store, validateFiledsList);
                            if (isValid == true) {
                                System.debug(store + ' exists in the list.');
                            } 
                            else { 
                                errorMessage.add('Invalid Store');
                                System.debug(store + ' does not exist in the list.');
                            }
                            errorMesg = string.join(errorMessage,',');
                            errorMessageList.add(errorMesg); 
                            
                          
                        }
                        
                        if(stageProductName!=null && stageProductName.contains('NIPS') && string.isBlank(store)){
                            errorMessage.add('Store is mandatory for NIPS products');
                            //System.debug(store + ' does not exist in the list.');
                            errorMesg = string.join(errorMessage,',');
                            errorMessageList.add(errorMesg); 
                        }
                    }
                    if(validateItem == 'BillingFrequency'){
                        String errorMesg = '';
                        Map<String, Object> validateFields = new Map<String, Object>();
                        validateFiledsList = (List<Object>)resultMap.get(validateItem);
                        system.debug('validateFiledsList-->'+ JSON.serializePretty(validateFiledsList) );
                        system.debug('stageBillType---->'+JSON.serializePretty(stage));
                        Set<string> errorMessage = new Set<string>();
                        String billFrequency  = (string)stage.get('ARTL_Bill_Frequency__c');
                        isValid = ARTL_ValidateStagingDataHelper.validateStandardReasons(billFrequency, validateFiledsList);
                        if (isValid == true) {
                            System.debug(billFrequency + ' exists in the list.');
                        } 
                        else {
                            errorMessage.add('Invalid Billing Frequency');
                            System.debug(billFrequency + ' does not exist in the list.');
                        }
                        errorMesg = string.join(errorMessage,',');
                        errorMessageList.add(errorMesg); 
                        
                        if(billFrequency != null){
                            List<string> validFieldList = new List<string>();
                            for(Object fields : validateFiledsList){
                                validateFields = (Map<String, Object>) fields; 
                                validFieldList.add((String)validateFields.get('name'));
                            } 
                            if (validFieldList.contains(billFrequency)) {
                                System.debug(billFrequency + ' exists in the list.');
                            } else {
                                errorMessage.add('Invalid bill frequency');
                                System.debug(billFrequency + ' does not exist in the list.');
                            }
                            errorMesg = string.join(errorMessage,',');
                            errorMessageList.add(errorMesg); 
                        }
                    }
                    
                }
                
                if(stage.get('Site_is_Same_as_Billing_Address__c') == true){
                    stage.put('Shipping_Street__c',stage.get('Billing_Street__c'));
                    stage.put('Shipping_PinCode__c',stage.get('Billing_PinCode__c'));
                    stage.put('Shipping_City__c',stage.get('Billing_City__c'));
                    stage.put('Shipping_State__c',stage.get('Billing_State__c'));
                    stage.put('Shipping_Country__c',stage.get('Billing_Country__c'));
                }
                
                
                
               
                //GST Validation
                if(!String.isBlank((string)stage.get('Billing_GST__c'))){
                    Map<String, Object> gstValRes = ARTL_ValidateStagingDataHelper.validateGST((string)stage.get('Billing_GST__c'));
                    System.debug('Billing_GST__c '+JSON.serializePretty(gstValRes));
                    if(gstValRes.get('success')== false) {
                        errorMessageList.add('Something went wrong with Billing GST');  
                    }                   
                }
                if(!String.isBlank((string)stage.get('Delivery_GST__c'))){
                    Map<String, Object> gstValRes = ARTL_ValidateStagingDataHelper.validateGST((string)stage.get('Delivery_GST__c'));
                    if(gstValRes.get('success')== false) {
                        errorMessageList.add('Something went wrong with Delivery GST');  
                    }                   
                }
                
                
                //Po Creation
                if(stage.PO_Group__c != null){
                    POGroupMap.put(stage.PO_Group__c, stage);
                }
                if(POMap.containsKey(stage.PO__c + '___' + stage.Quote_Line_Item__r.Quote.AccountId)){
                    POMap.get(stage.PO__c + '___' + stage.Quote_Line_Item__r.Quote.AccountId).add(stage);
                }else{
                    POMap.put(stage.PO__c + '___' + stage.Quote_Line_Item__r.Quote.AccountId, new List<ARTL_Billing_Staging__c>{stage});
                }
                
                
                /**************** Validation Message Creation ***************/                  
                set<string> errorMessageSet = new set<string>(errorMessageList);
                errorMessageSet.remove('');
                errorMessageSet.remove(null);
                errorMessageList = new list<string>(errorMessageSet);
                Set<String> uniqueErrorMessageSet = new Set<String>();
                for (String errorMessage : errorMessageSet) {
                    if (String.isNotBlank(errorMessage)) {
                        uniqueErrorMessageSet.add(errorMessage);
                    }
                }
                System.debug('errorMessageList' + JSON.serializePretty(uniqueErrorMessageSet));
                
                if(uniqueErrorMessageSet!=null && !uniqueErrorMessageSet.isEmpty()){
                    String validationMessage = string.join(uniqueErrorMessageSet,',');
                    stage.put('Validation_Message__c',validationMessage);
                    stage.put('Status__c','Failed');
                    //Ajay 05/02/2024
                    Boolean isDuplicate=false;
                    for(QuoteLineItem currentQLI:qliToUpdate){
                        if(currentQLI.id==string.valueof(stage.Quote_Line_Item__c)){
                            isDuplicate=true;
                        }
                    }
                    if(stage.Quote_Line_Item__r.ARTL_LSI__c!=null && !isDuplicate){
                        StageLsiToErrorMap.put(string.valueof(stage.Quote_Line_Item__r.ARTL_LSI__c),validationMessage);
                        qliToUpdate.add(new QuoteLineItem(id=string.valueof(stage.Quote_Line_Item__c),validation_message__c=validationMessage,ARTL_Validation_Status__c='Failed'));
                    }
                }
                else{
                    stage.put('Validation_Message__c','');
                    stage.put('Status__c','Success');
                    Boolean isDuplicate=false;
                    for(QuoteLineItem currentQLI:qliToUpdate){
                        if(currentQLI.id==string.valueof(stage.Quote_Line_Item__c)){
                            isDuplicate=true;
                        }
                    }
                    if(stage.Quote_Line_Item__r!=null && !isDuplicate){
                    qliToUpdate.add(new QuoteLineItem(id=stage.Quote_Line_Item__c,ARTL_Validation_Status__c='Passed',validation_message__c=null));
                    }
                }
            }
           			
            System.debug('POGroupMap--->'+JSON.serializePretty(POGroupMap));
            System.debug('POMap---->'+JSON.serializePretty(POMap));
            ARTL_BACreationPreProcessBatchHelper.getPOGroupOrCreate(POGroupMap);
            //KB: Assign PO Group ID to Rest of the Billing Staging Records
            ARTL_BACreationPreProcessBatchHelper.updateRestStagingWithPOGroup(POMap, POGroupMap);
            ARTL_BACreationPreProcessBatchHelper.getPOOrCreate(POMap);
            //System.debug('scope '+JSON.serializePretty(scope));
            update scope; 
            if(qliToUpdate.size()>0){
                update qliToUpdate;
            }
            
            if(!StageLsiToErrorMap.isEmpty())
            {
                List<ARTL_Common_Toast_Event__e> commonToastEvtList = new List<ARTL_Common_Toast_Event__e>();
                ARTL_Common_Toast_Event__e obj = new ARTL_Common_Toast_Event__e();
                 obj.Id__c  = scope[0].Quote__c;
                system.debug(StageLsiToErrorMap);
                 obj.Message__c  = JSON.serialize(StageLsiToErrorMap.keySet());
                 obj.Sub_Event__c = 'Quote Validation Event';
                 obj.Success__c = false;
                 commonToastEvtList.add(obj);

                Database.SaveResult[] contractresult = EventBus.publish(commonToastEvtList); 
            }

            else if(StageLsiToErrorMap.isEmpty())
            {
                List<ARTL_Common_Toast_Event__e> commonToastEvtList = new List<ARTL_Common_Toast_Event__e>();
                ARTL_Common_Toast_Event__e obj = new ARTL_Common_Toast_Event__e();
                 obj.Id__c  = scope[0].Quote__c;
                 obj.Message__c  = 'Success';
                 obj.Sub_Event__c = 'Quote Validation Event';
                 obj.Success__c = true;
                 commonToastEvtList.add(obj);

                Database.SaveResult[] contractresult = EventBus.publish(commonToastEvtList); 
            }
        }

        catch(Exception e) {
            System.debug(e);
        }
        
    }
    
    public void finish(Database.BatchableContext BC)
    {
        /*
Id typeId = [SELECT Id,CustomNotifTypeName  FROM CUstomNotificationType WHERE CustomNotifTypeName = 'ARTL BA SA Validation'].Id;
Id reportId = [SELECT Id FROM Report WHERE Name = 'New Billing Stagings with Quote Report'].Id;
//String reportURL = '/lightning/report/' + reportId + '/view?fv0=' + quoteId;
Messaging.CustomNotification notification = new Messaging.CustomNotification();
notification.setBody('Go to reports to check the validation status');
notification.setTitle('Validation has been completed!!');
notification.setSenderId(Userinfo.getUserId());
notification.setNotificationTypeId(typeId );
notification.setTargetId('https://business-force-5632--artldevp2.sandbox.lightning.force.com/lightning/r/Report/00O720000042XjxEAE/view?fv0=0Q0720000003yajCAA');
//notification.setTargetId(reportId+'/view?fv0='+quoteId);
//notification.setTargetPageRef(reportURL);
notification.send(new Set<String> { Userinfo.getUserId() });
*/
        //string quoteId = '0Q0720000003yajCAA';
        string baseUrl = System.URL.getOrgDomainUrl().toExternalForm();
        Id typeId = [SELECT Id,CustomNotifTypeName  FROM CUstomNotificationType WHERE CustomNotifTypeName = 'ARTL BA SA Validation'].Id;
        Id reportId = Test.isRunningTest() ? null : [SELECT Id FROM Report WHERE Name = 'New Billing Stagings with Quote Report'].Id;
        string url = baseUrl + '/lightning/r/Report/' + reportId + '/view?fv0=' + quoteId;
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setBody('Go to reports to check the validation status');
        notification.setTitle('Validation has been completed!!');
        notification.setSenderId(Userinfo.getUserId());
        notification.setNotificationTypeId(typeId );
        String pgRef = '{type: "standard__webPage",attributes: {url: "' + url + '"}}';
        notification.setTargetPageRef(pgRef);
        notification.send(new Set<String> { Userinfo.getUserId() });
    }
}