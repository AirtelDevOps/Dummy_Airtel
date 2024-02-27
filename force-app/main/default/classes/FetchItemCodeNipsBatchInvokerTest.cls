@isTest(SeeAllData=false)
public with sharing class FetchItemCodeNipsBatchInvokerTest {

    @isTest
    private static Map<String,Object> prepareTestData(){

        Map<String,Object> testData = new Map<String,Object>();

        Account testBusinessAccount = new Account(Name = 'Test Business Account');
        insert testBusinessAccount;

        Opportunity testOpp = new Opportunity(Name='Test Opportunity', AccountId=testBusinessAccount.id, StageName='Qualification', CloseDate = Date.today().addDays(10));
        insert testOpp;

        List<vlocity_cmt__ObjectClass__c> vObjTypeList = new List<vlocity_cmt__ObjectClass__c>();
        vlocity_cmt__ObjectClass__c vObjType1 = new vlocity_cmt__ObjectClass__c(Name = 'VAS Specification Type', vlocity_cmt__ObjectApiName__c = 'VAS Specification Type');
        vObjTypeList.add(vObjType1);

        vlocity_cmt__ObjectClass__c vObjType2 = new vlocity_cmt__ObjectClass__c(Name = 'Access Object Type', vlocity_cmt__ObjectApiName__c = 'Access Object Type');
        vObjTypeList.add(vObjType2);

        insert vObjTypeList;

        List<Product2> productList = new List<Product2>();
        Pricebook2 standardBook =  new Pricebook2(Id=Test.getStandardPricebookId(), Name = 'TestPricebook', IsActive = true, CurrencyIsoCode = 'USD');
        
        Product2 product1 = new Product2(Name= 'Test Product', Description='Test Description 1', vlocity_cmt__JSONAttribute__c='Test JSON Attribute 1',
                                            vlocity_cmt__Type__c = 'Voice', vlocity_cmt__SubType__c = 'Features', vlocity_cmt__ObjectTypeId__c = vObjType1.Id, 
                                            ProductCode = 'dac49a09-9b41-4999-b7c4-cf6319ad5b44');
        productList.add(product1);
        insert productList;

        List<PricebookEntry> stdPriceBookEntryList = new List<PricebookEntry>();

        PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                                    Product2Id = product1.Id, UnitPrice = 101, vlocity_cmt__RecurringPrice__c = 201, IsActive = true, UseStandardPrice = false, CurrencyIsoCode = 'USD');
        stdPriceBookEntryList.add(pricebookEntry1);
        insert stdPriceBookEntryList;

        Quote testQuote = new Quote(Name = 'Test Quote', OpportunityId = testOpp.Id, Status = 'Open', CurrencyIsoCode = 'USD', RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('EnterpriseQuote').getRecordTypeId(), Pricebook2Id = standardBook.Id );
        insert testQuote;

        QuoteLineItem testLineItem = new QuoteLineItem(Product2Id = product1.Id, Quantity = 1, QuoteId = testQuote.Id, vlocity_cmt__RecurringTotal__c = 100,  UnitPrice = 10001,  PricebookEntryId = pricebookEntry1.Id,
                                                        vlocity_cmt__AssetReferenceId__c = 'qLine1', vlocity_cmt__LineNumber__c = '0001');
        insert testLineItem;

        testData.put('Quote',testQuote);
        testData.put('QLI',testLineItem);

        return testData;
    }
    @isTest  
    public static void fetchItemCodeInitiateTest(){

        prepareTestData();
        String quoteId = [SELECT Id FROM Quote LIMIT 1].Id;

        Map<String,Object> input = new Map<String,Object>();
        Map<String,Object> output = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();

        Map<String,Object> testData = prepareTestData();
        Quote qte = (Quote)testData?.get('Quote');

        input.put('QuoteId', quoteId);

        Test.startTest();
        FetchItemCodeNipsBatchInvoker ficnbi = new FetchItemCodeNipsBatchInvoker();
        ficnbi.invokeMethod('fetchItemCodeInitiate', input, output, options );
        Test.stopTest();
    }

    @isTest 
    public static void unknownMethodName() {

        FetchItemCodeNipsBatchInvoker ficnbi = new FetchItemCodeNipsBatchInvoker();

        Test.startTest();
        ficnbi.invokeMethod('unknownMethodName',null,null,null);
        Test.stopTest();
    }
    
}