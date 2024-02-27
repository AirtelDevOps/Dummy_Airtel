@isTest(SeeAllData=false)
global with sharing class SummaryViewHelperTest {

    private static String feasibilityRequest = '{"feasibilityMedia":"FTTH"}';
    private static String feasibilityResponse = '{"wirelineNetworkElement":{"media":"FTTH", "maxBandwidth":"10 Mbps"}, "wirelessNetworkElement":{"media":"FTTH", "maxBandwidth":"10 Mbps"}, "fourGNetworkElement":{"media":"FTTH", "maxBandwidth":"10 Mbps"}, "fiveGNetworkElement":{"media":"FTTH", "maxBandwidth":"10 Mbps"}, "thirdPartyResponse":{"media":"FTTH", "maxBandwidth":"10 Mbps"}, "offNetResponse":{"media":"FTTH", "maxBandwidth":"10 Mbps"}}';
    private static String attributeValues = '{"ATT_MEDIA":"FTTH"}';

    @TestSetup
    private static void prepareTestData(){
        Map<String,Object> testData = new Map<String,Object>();

        insert new vlocity_cmt__TriggerSetup__c(Name = 'AllTriggers', vlocity_cmt__IsTriggerOn__c = true);
        insert new vlocity_cmt__CpqConfigurationSetup__c(Name='UseAssetReferenceIdForParentAndRoot', vlocity_cmt__SetupValue__c='True');

        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account testBusinessAccount = new Account(Name = 'Test Business Account', RecordTypeId=businessRecordTypeId);
        insert testBusinessAccount;

        List<Product2> productList = new List<Product2>();
        Product2 product1 = new Product2(Name= 'Test Product 1', Description='Test Description 1', ProductCode = 'TestProduct1');
        Product2 product2 = new Product2(Name= 'Test Product 2', Description='Test Description 2', ProductCode = 'TestProduct1');
        
        productList.add(product1);
        productList.add(product2);
        insert productList;

        List<PricebookEntry> stdPriceBookEntryList = new List<PricebookEntry>();
        PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                    Product2Id = product1.Id, UnitPrice = 101, vlocity_cmt__RecurringPrice__c = 201, IsActive = true, UseStandardPrice = false);
        PricebookEntry pricebookEntry2 = new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(),
                                    Product2Id = product2.Id, UnitPrice = 101, vlocity_cmt__RecurringPrice__c = 201, IsActive = true, UseStandardPrice = false);

        stdPriceBookEntryList.add(pricebookEntry1);
        stdPriceBookEntryList.add(pricebookEntry2);
        insert stdPriceBookEntryList;

        opportunity opp = new opportunity(Name ='Opp new', StageName = 'Prospecting', CloseDate = date.today(), AccountId = testBusinessAccount.Id);
        insert opp;

        Quote testQuote = new Quote(Name = 'Test Quote', OpportunityId=opp.Id, Status = 'Draft', 
                                    RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('WorkingCart').getRecordTypeId(), 
                                    Pricebook2Id = Test.getStandardPricebookId() );
        insert testQuote;

        ARTL_Feasibility__c fea = new ARTL_Feasibility__c(ARTL_Feasibility_Status__c='Feasible');
        insert fea;

        List<QuoteLineItem> lineItemList = new List<QuoteLineItem>();
        QuoteLineItem testLineItem1 = new QuoteLineItem(Product2Id = product1.Id, Quantity = 1, QuoteId = testQuote.Id, vlocity_cmt__RecurringCharge__c = 100,  UnitPrice = 10001,  PricebookEntryId = pricebookEntry1.Id,
                                                vlocity_cmt__Product2Id__c = product1.Id, vlocity_cmt__LineNumber__c = '0001');
        QuoteLineItem testLineItem2 = new QuoteLineItem(Product2Id = product2.Id, Quantity = 1, QuoteId = testQuote.Id, vlocity_cmt__RecurringCharge__c = -10,  UnitPrice = 10001,  PricebookEntryId = pricebookEntry1.Id,
                                                vlocity_cmt__Product2Id__c = product2.Id, vlocity_cmt__LineNumber__c = '0001.0001', ARTL_Feasibility__c=fea.Id, ARTL_Feasibility_Request__c=feasibilityRequest, ARTL_Feasibility_Response__c=feasibilityResponse, vlocity_cmt__AttributeSelectedValues__c=attributeValues);
        QuoteLineItem testLineItem3 = new QuoteLineItem(Product2Id = product1.Id, Quantity = 1, QuoteId = testQuote.Id, vlocity_cmt__RecurringCharge__c = 100,  UnitPrice = 10001,  PricebookEntryId = pricebookEntry1.Id,
                                                vlocity_cmt__Product2Id__c = product1.Id, vlocity_cmt__LineNumber__c = '0002', ARTL_Feasibility__c=fea.Id, ARTL_Feasibility_Request__c=feasibilityRequest, ARTL_Feasibility_Response__c=feasibilityResponse, vlocity_cmt__AttributeSelectedValues__c=attributeValues);
        
        lineItemList.add(testLineItem1);
        lineItemList.add(testLineItem2);
        lineItemList.add(testLineItem3);
        insert lineItemList;
    }

    @isTest()
    static void getMediaTest(){
        String cartId = [SELECT Id FROM Quote LIMIT 1].get(0).Id;
        List<SObject> itemList = [SELECT Id, vlocity_cmt__LineNumber__c, vlocity_cmt__AssetReferenceId__c, vlocity_cmt__ParentItemId__c, vlocity_cmt__RootItemId__c, ARTL_Feasibility__r.ARTL_Feasibility_Status__c, ARTL_Feasibility_Request__c, ARTL_Feasibility_Response__c, vlocity_cmt__AttributeSelectedValues__c FROM QuoteLineItem WHERE QuoteId=:cartId AND vlocity_cmt__ParentItemId__c=null];

        for(SObject item : itemList)
            System.debug('🎁 ' + JSON.serialize(item));

        vlocity_cmt.VlocityOpenInterface voi = new SummaryViewHelper();
        Map<String,Object> input = new Map<String,Object>{'CartId'=>cartId, 'ItemList'=>itemList};
        Map<String,Object> output = new Map<String,Object>();

        voi.invokeMethod('getMedia', input, output, null);

        Map<String,Object> result = (Map<String,Object>)output.get('result');
        for( String key : result.keySet() )
            System.debug('🎃 ' + key + ': ' + JSON.serialize(result.get(key)));
    }
}