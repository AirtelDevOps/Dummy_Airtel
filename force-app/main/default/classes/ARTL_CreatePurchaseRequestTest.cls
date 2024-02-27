@isTest
public with sharing class ARTL_CreatePurchaseRequestTest {
    @isTest
    static void testIntegrationMethod() {
        ARTL_CreatePurchaseRequest.InputVariable NewObject = new ARTL_CreatePurchaseRequest.InputVariable();
        List < ARTL_CreatePurchaseRequest.InputVariable > testinput = new List < ARTL_CreatePurchaseRequest.InputVariable >();
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Product2 testProduct1 = new Product2(
            Name = 'NIPS_SERVICE',
            ProductCode = 'c09a2e70-64af-4ad6-8427-06c8489234d7',
            IsActive = true
        );
        insert testProduct1;
        
        PricebookEntry testPricebookEntry1 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct1.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert testPricebookEntry1;
        
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(
            vlocity_cmt__Pricebook2Id__c = Test.getStandardPricebookId(),
            vlocity_cmt__IsActive__c = true,
            vlocity_cmt__Code__c = 'TestPricebook5'
        );
        insert pl1;
        
        Opportunity opp = new Opportunity(
            Name = 'EPC Deal AA',
            AccountId = testAccount.Id,
            vlocity_cmt__PriceListId__c = pl1.Id,
            CloseDate = System.today(),
            StageName = 'Initial',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert opp;
        
        Quote qtest = new Quote(
            Name = 'Quote - EPC Deal AA',
            Status = 'Draft',
            OpportunityId = opp.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            vlocity_cmt__PriceListId__c = pl1.Id,
            vlocity_cmt__PoDate__c = Date.today(),
            vlocity_cmt__PoNumber__c = '12345',
            PO_Term__c = '12',
            PO_Value__c = 1222,
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'EnterpriseQuote' AND SobjectType = 'Quote' LIMIT 1].Id
        );
        insert qtest;
        
        QuoteLineItem  qouteLine1 = new QuoteLineItem (UnitPrice = 1, Quantity = 1, Product2Id = testProduct1.Id,
                                                      vlocity_cmt__Product2Id__c = testProduct1.Id,
                                                      QuoteId =qtest.Id, PricebookEntryId=testPricebookEntry1.Id,
                                                      vlocity_cmt__LineNumber__c = '0001',
                                                      RequisitionNumber__c='12345;2345');
        insert qouteLine1;
        
         
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            vlocity_cmt__QuoteId__c = qtest.Id,
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert testOrder;
        
        NewObject.Id = testOrder.Id;
        testinput.add(NewObject);
        Test.startTest();
        ARTL_CreatePurchaseRequest.CreatePRRecord(testinput);
 		Test.stopTest();
    }
}