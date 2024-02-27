public class ARTL_ValidateStagingDataHelper {
    @AuraEnabled
    public static void invokeARTL_ValidateStagingData(String recordId, Boolean isTest){
        System.debug('ARTL_ValidateStagingDataHelper.invokeARTL_ValidateStagingData.recordId'+recordId);
        Database.executeBatch(new ARTL_ValidateStagingData(recordId, isTest)); 
    }
    
    
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object>getMetadata(){
        String procedureName = 'ARTL_validateBillingStagingFields';
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        try{
            ipOutput = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
            
            System.debug('IP Output: ' + ipOutput.keySet());
        }
        catch (Exception e){
            system.debug('Exception in ARTL_ValidateStagingDataHelper.getMetadata: at Line ('+e.getLineNumber()+') Error Message: ' + e.getMessage());
        }
        
        return ipOutput;
    }
    
    public static Map<String, Object>validateGST(String gstNumber){
        
        String procedureName = 'ARTL_EnrichQuoteGSTValidation';
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        try{
            ipInput.put('gst', gstNumber);
            
            ipOutput = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
            
            System.debug('IP Output: ' + ipOutput);
        }
        catch (Exception e){
            system.debug('Exception in ARTL_ValidateStagingDataHelper.validateGST: at Line ('+e.getLineNumber()+') Error Message: ' + e.getMessage());
        }
        return ipOutput;
    }
    
    /*public static List<String> validateWithDeliveryGST(List<Object> validateFiledsList,ARTL_Billing_Staging__c stage){
String errorMesg = '';
Map<String, Object> validateFields = new Map<String, Object>();
system.debug('validateFiledsList-->'+validateFiledsList);
List<string> errorMessage = new List<string>();
String BillingStandardReason = (string)stage.get('Billing_Standard_Reason__c');
String DeliveryGST  = (string)stage.get('Delivery_GST__c');
if(DeliveryGST == null && BillingStandardReason == null){
errorMessage.add('Billing Standard Reason or Delivery GST is MANDATORY');
errorMesg = string.join(errorMessage,',');
//errorMessageList.add(errorMesg);
}
if(BillingStandardReason != null){
List<string> validFieldList = new List<string>();
for(Object fields : validateFiledsList){
validateFields = (Map<String, Object>) fields; 
validFieldList.add((String)validateFields.get('name'));
} 
if (validFieldList.contains(BillingStandardReason)) {
System.debug(BillingStandardReason + ' exists in the list.');
} else {
errorMessage.add('Invalid BillingStandard Reason');
System.debug(BillingStandardReason + ' does not exist in the list.');
}
errorMesg = string.join(errorMessage,',');
// errorMessageList.add(errorMesg); 
}
return errorMessage;
}*/
    
    public static boolean validateStandardReasons(String standardReason, List<object> validateFiledsList){
        boolean isValid = false;
        Map<String, Object> validateFields = new Map<String, Object>();
        try{
            if(standardReason != null){
                List<string> validFieldList = new List<string>();
                for(Object fields : validateFiledsList){
                    validateFields = (Map<String, Object>) fields; 
                    validFieldList.add((String)validateFields.get('name'));
                } 
                if (validFieldList.contains(standardReason)) {
                    isValid = true;
                } else {
                    isValid = false;
                }
            }
        }
        catch (Exception e){
            system.debug('Exception in ARTL_ValidateStagingDataHelper.validateStandardReasons: at Line ('+e.getLineNumber()+') Error Message: ' + e.getMessage());
        }
        return isValid;
    }
    
    public Static String getOpportunityId(){
        //String opptyId;
        Opportunity opp = new Opportunity();
        opp.AccountId = getAccountId();
        opp.Name = 'Test Opportunity';
        opp.CloseDate= System.Today()+7;
        opp.StageName='Qualified';
        insert opp;
        return opp.id;
    }
    
    public Static String getAccountId(){
        // insert account
        Account acc = new Account(
            Name = 'Test Account',
            ARTL_Category__c ='A',
            ARTL_Customer_Segment__c  = 'AB',
            ARTL_Business_Circle_Region__c = 'MUM',
            ARTL_Service_Segment__c = 'Growth',
            ARTL_Vertical_Segment__c = 'BFI',
            //ARTL_Billing_Pincode__c = '682035',
            BillingState = 'Mumbai', 
            BillingCity = 'Maharashtra', 
            BillingStreet = 'Test', 
            BillingPostalCode = '110031', 
            BillingCountry = 'India',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId()
            
        );
        insert acc; 
        return acc.Id;
    } 
    
    public Static String getServiceAccountId(){
        // insert account
        Account acc = new Account(
            Name = 'Test Service Account',
            ARTL_Category__c ='A',
            ARTL_Customer_Segment__c  = 'AB',
            ARTL_Business_Circle_Region__c = 'MUM',
            ARTL_Service_Segment__c = 'Growth',
            ARTL_Vertical_Segment__c = 'BFI',
            //ARTL_Billing_Pincode__c = '682035',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service').getRecordTypeId()
            
        );
        insert acc; 
        return acc.Id;
    } 
    
    public Static String getBillingAccountId(){
        // insert account
        Account acc = new Account(
            Name = 'Test Billing Account',
            ARTL_Category__c ='A',
            ARTL_Customer_Segment__c  = 'AB',
            ARTL_Business_Circle_Region__c = 'MUM',
            ARTL_Service_Segment__c = 'Growth',
            ARTL_Vertical_Segment__c = 'BFI',
            //ARTL_Billing_Pincode__c = '682035',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing').getRecordTypeId()
            
        );
        insert acc; 
        return acc.Id;
    } 
    
    
    public static string getQuoteIdPos(){
        //String quoteId;
        String priceListId = getPriceListId();
        Quote qt = new Quote();
        qt.OpportunityId  = getOpportunityId();
        qt.Name = 'Test Quote';
        qt.vlocity_cmt__PriceListId__c =priceListId;
        System.debug('qt.vlocity_cmt__PriceListId__cPNN'+qt.vlocity_cmt__PriceListId__c);
        qt.Pricebook2Id = Test.getStandardPricebookId();
        qt.ExpirationDate = System.Today()+7;
        qt.Status = 'Proposal Accepted';
        insert qt;
        
        //KB: Data creation for BA-SA Back end process--Start
        Quote qt1 = new Quote();
        qt1.OpportunityId  = getOpportunityId();
        qt1.Name = 'Test Quote1';
        qt1.vlocity_cmt__PriceListId__c =priceListId;
        System.debug('qt.vlocity_cmt__PriceListId__cPNN'+qt.vlocity_cmt__PriceListId__c);
        qt1.Pricebook2Id = Test.getStandardPricebookId();
        qt1.ExpirationDate = System.Today()+7;
        qt1.Status = 'Proposal Accepted';
        insert qt1;
        
        //Update status
        qt1.Status = 'Customer Signed';
        update qt1;
        
        vlocity_cmt__QuoteMember__c  qm1 = new vlocity_cmt__QuoteMember__c ();
        qm1.Name = 'Test QuoteMember';
        qm1.vlocity_cmt__QuoteId__c  = qt1.Id;
        insert qm1;
        
        QuoteLineItem qli1 = new QuoteLineItem();
        qli1.QuoteId = qt1.Id;
        qli1.vlocity_cmt__QuoteMemberId__c = qm1.Id;
        qli1.Product2Id = getProductId();
        qli1.PricebookEntryId = getPbeId();
        qli1.vlocity_cmt__ServiceAccountId__c = getServiceAccountId();
        qli1.vlocity_cmt__BillingAccountId__c = getBillingAccountId();
        qli1.UnitPrice = 10;
        qli1.Quantity = 1;
        insert qli1;
        
        //KB: Data creation for BA-SA Back end process--End
        
        vlocity_cmt__QuoteMember__c  qm = new vlocity_cmt__QuoteMember__c ();
        qm.Name = 'Test QuoteMember';
        qm.vlocity_cmt__QuoteId__c  = qt.Id;
        insert qm;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qt.Id;
        qli.vlocity_cmt__QuoteMemberId__c = qm.Id;
        qli.Product2Id = getProductId();
        qli.PricebookEntryId = getPbeId();
        qli.UnitPrice = 10;
        qli.Quantity = 1;
        insert qli;
        
        ARTL_Billing_Staging__c bStage = new ARTL_Billing_Staging__c ();
        bStage.Quote__c = qt.Id;
        bStage.Quote_Line_Item__c = qli.Id;
        bStage.Billing_Standard_Reason__c = 'SEZ';
        bStage.Delivery_Standard_Reason__c = 'SEZ';
        bStage.DCP_First_Name__c = 'DCP First';
        bStage.DCP_Last_Name__c = 'DCP Last';
        bStage.DCP_Phone__c = '56789';
        bStage.DCP_Email__c = 'testDCP@Gmail.com';
        bStage.Legal_Entity__c = 'Bharti Airtel Ltd';
        bStage.Billing_Type__c = 'Advance';
        bStage.Credit_Period__c = '0 days';
        bStage.BCP_First_Name__c = 'BCP First';
        bStage.BCP_Last_Name__c = 'BCP last';
        bStage.BCP_Email__c = 'testBCP@gmail.com';
        bStage.BCP_Phone__c = '71921';
        bStage.Billing_City__c = 'Kochi';
        bStage.Billing_Country__c = 'India';
        bStage.Billing_Street__c = 'MG Road';
        bStage.Billing_State__c = 'Kerala';
        bStage.Billing_PinCode__c = '682035';
        bStage.Site_is_Same_as_Billing_Address__c = true;
        bStage.BillingFrequency__c = 'Advanced Quarterly Billing';
        bStage.Product_Code__c = 'VEPC_E_IIL';
        bStage.Product_Name__c = 'Internet';
        bStage.PO_Group__c = '190';
        bstage.PO__c = '4';
        
        insert bStage;
        
        System.debug('bStage.ID--->'+bStage.Id);
        System.debug('qt.ID--->'+qt.Id);
        return qt.Id;
    }
    public static string getQuoteIdNeg(){
        //String quoteId;
        Quote qt = new Quote();
        qt.OpportunityId  = getOpportunityId();
        qt.Name = 'Test Quote';
        qt.vlocity_cmt__PriceListId__c =getPriceListId();
        System.debug('qt.vlocity_cmt__PriceListId__cPNN'+qt.vlocity_cmt__PriceListId__c);
        qt.Pricebook2Id = Test.getStandardPricebookId();
        qt.ExpirationDate = System.Today()+7;
        qt.Status = 'Proposal Accepted';
        insert qt;
        
        vlocity_cmt__QuoteMember__c  qm = new vlocity_cmt__QuoteMember__c ();
        qm.Name = 'Test QuoteMember';
        qm.vlocity_cmt__QuoteId__c  = qt.Id;
        insert qm;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qt.Id;
        qli.vlocity_cmt__QuoteMemberId__c = qm.Id;
        qli.Product2Id = getProductId();
        qli.PricebookEntryId = getPbeId();
        qli.UnitPrice = 10;
        qli.Quantity = 1;
        insert qli;
        
        ARTL_Billing_Staging__c bStage = new ARTL_Billing_Staging__c ();
        bStage.Quote__c = qt.Id;
        bStage.Quote_Line_Item__c = qli.Id;
        bStage.Billing_Standard_Reason__c = 'SEZ';
        bStage.Delivery_Standard_Reason__c = 'SEZ';
        bStage.DCP_First_Name__c = 'DCP First';
        bStage.DCP_Last_Name__c = 'DCP Last';
        bStage.DCP_Phone__c = '56789';
        bStage.DCP_Email__c = 'testDCP@Gmail.com';
        bStage.Legal_Entity__c = 'Bharti Airtel Ltd';
        bStage.Billing_Type__c = 'Advance';
        bStage.Credit_Period__c = '0 days';
        bStage.BCP_First_Name__c = 'BCP First';
        bStage.BCP_Last_Name__c = 'BCP last';
        bStage.BCP_Email__c = 'testBCP@gmail.com';
        bStage.BCP_Phone__c = '71921';
        bStage.Billing_City__c = 'Kochi';
        bStage.Billing_Country__c = 'India';
        bStage.Billing_Street__c = 'MG Road';
        bStage.Billing_State__c = 'Kerala';
        bStage.Billing_PinCode__c = '682035';
        bStage.Site_is_Same_as_Billing_Address__c = true;
        bStage.BillingFrequency__c = 'Advanced Quarterly Billing';
        bStage.Product_Code__c = 'VEPC_E_IIL';
        bStage.Product_Name__c = 'NIPS';
        bstage.Store__c = 'AHM';
        
        insert bStage;
        
        System.debug('bStage.ID--->'+bStage.Id);
        System.debug('qt.ID--->'+qt.Id);
        return qt.Id;
    }
    
    public static string getPbeId(){
        // insert pricebook entry for the product
        PricebookEntry standardPrice = new PricebookEntry();
        standardPrice.Pricebook2Id = Test.getStandardPricebookId();
        standardPrice.Product2Id = getProductId();
        standardPrice.UnitPrice = 100;
        standardPrice.IsActive = true;
        standardPrice.UseStandardPrice = false;
        insert standardPrice ;
        return standardPrice.Id;
    }
    
    public Static String getProductId(){
        // insert product
        Product2 p = new Product2();
        p.Name = ' Test Product ';
        p.Description='Test Product Entry For Product';
        p.productCode = 'TEST-PROD';
        p.isActive = true;
        insert p; 
        return p.Id;
    }
    
    public static string getPriceListId(){
        
        vlocity_cmt__PriceList__c standardPriceList = new vlocity_cmt__PriceList__c();
        standardPriceList.vlocity_cmt__Pricebook2Id__c=Test.getStandardPricebookId();
        standardPriceList.Name='Test standardPriceList';
        standardPriceList.vlocity_cmt__Code__c ='TEST_001';
        insert standardPriceList ;
        return standardPriceList.Id;
    }
    
    public static User getUser(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User user = new User(LastName = 'Jackson',FirstName='Michael', Alias = 'jl', Email = 'Michael.Jackson@testorg.com',
                             Username = 'Michael.Jackson@testorg.com', ProfileId = profileId.id,TimeZoneSidKey = 'GMT', 
                             LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',LocaleSidKey = 'en_US');
        // string userId = UserInfo.getUserId();
        insert user;
        return user;
    } 
    
    public static Set<Id> getQuoteIdSet(){
        Set<Id> quoteIdSet = new Set<Id>();
        String quoteId = getQuoteIdPos();
        List<Quote> quoteList = [Select Id From Quote LIMIT 2];
        for(Quote q: quoteList)
        {
            quoteIdSet.add(q.Id);
        }
        return quoteIdSet;
    }
    
    public static Id getGroupId(){
        Id groupId;
        User oppUser = getUser();
        Group grp = new Group(Name='OppShareGroup', DeveloperName='OppShareGroup');
        insert grp;
        
        // Avoid mixed DML using runAs
        System.runAs(new User(Id = UserInfo.getUserId())) {
            GroupMember gm = new GroupMember(GroupId = grp.Id, UserOrGroupId = oppUser.Id);
            insert gm;
        }
        return groupId;
    }    
}