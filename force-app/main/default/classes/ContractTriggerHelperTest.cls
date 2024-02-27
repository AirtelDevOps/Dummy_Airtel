@isTest
public class ContractTriggerHelperTest{
    
    // Test data setup method
    @testSetup
    static void dataCreation() {
        // Create a test user
        User testUser1 = new User(
            FirstName = 'Test1test',
            LastName = 'User1test',
            Alias = 'tusetest',
            Email = 'testuser1test@example.com',
            Username = 'testuser1test@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            Circle__c='NCR'
        );
        insert testUser1;
        
        // Create an account owned by the test user
        Account acc = new Account(
            Name = 'Test Account',
            OwnerId=testUser1.Id
        );
        insert acc; 
        
        // Create a product
        Product2 prod = new Product2(Name = 'Test product1', family = 'Internet',ProductCode='VEPC_E_IIL');
        insert prod;
        
        // Create a price book entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        // Create a price list
        vlocity_cmt__PriceList__c priceList = new vlocity_cmt__PriceList__c();
        priceList.Name ='Pricelist For Test class';
        priceList.vlocity_cmt__Code__c='PricelistForTestclass';
        priceList.vlocity_cmt__Pricebook2Id__c =Test.getStandardPricebookId();
        insert priceList;
        
        // Create an opportunity
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;
        
        // Create a quote
        Quote q = new Quote();
        q.OpportunityId = opp.Id;
        q.Name = 'Quote Test';
        q.vlocity_cmt__PriceListId__c=priceList.Id;
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.Status ='Draft';
        insert q;
        
        // Create a quote line item
        QuoteLineItem qli = new QuoteLineItem(
            Product2Id = prod.Id,
            QuoteId = q.Id,
            PricebookEntryId = pbEntry.Id,
            UnitPrice = pbEntry.UnitPrice,
            Quantity=1
        );
        insert qli;
    }
    
    // Test method to update CAF
    /*
    @isTest
    static void updateCAFTestForSingleProduct() {
        Test.startTest();
        
        // Retrieve a test account and quote for the contract creation
        List<Account> acObj=[SELECT Id FROM Account LIMIT 1];
        List<Quote> quoteObj=[SELECT Id FROM Quote LIMIT 1];
        
        // Create a contract record
        Contract conRecord=new Contract(
            AccountId=acObj[0].Id,
            Status='Draft',
            StartDate =System.today(),
            CurrencyIsoCode='INR',
            vlocity_cmt__QuoteId__c=quoteObj[0].Id
        );
        insert conRecord;
        
        // Retrieve the updated contract record and assert that ARTL_CAFNumber__c is not null
        Contract updatedContractRec=[SELECT Id,ARTL_CAFNumber__c FROM Contract WHERE Id=:conRecord.Id ];
        System.assertNotEquals(updatedContractRec.ARTL_CAFNumber__c, null);
        
        Test.stopTest();
    }
    */
    
    // Test method to update CAF
    @isTest
    static void updateCAFTestForMultipleProduct() {
        Test.startTest();
        Product2 prod2 = new Product2(
            Name = 'Test product2',
            family = 'Internet',
            ProductCode='VEPC_E_MPLS'
        );
        insert prod2;
        PricebookEntry pbEntry2 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod2.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry2;
        
        // Retrieve a test account and quote for the contract creation
        List<Account> acObj=[SELECT Id FROM Account LIMIT 1];
        List<Quote> quoteObj=[SELECT Id FROM Quote LIMIT 1];
        
        
        
        QuoteLineItem qli2 = new QuoteLineItem(
            Product2Id = prod2.Id,
            QuoteId = quoteObj[0].Id,
            PricebookEntryId = pbEntry2.Id,
            UnitPrice = pbEntry2.UnitPrice,
            Quantity=1
        );
        insert qli2;
        
        // Create a contract record
        Contract conRecord=new Contract(
            AccountId=acObj[0].Id,
            Status='Draft',
            StartDate =System.today(),
            CurrencyIsoCode='INR',
            vlocity_cmt__QuoteId__c=quoteObj[0].Id
        );
        insert conRecord;
        
        conRecord.Status = 'Signed';
        Update conRecord;
        
        // Retrieve the updated contract record and assert that ARTL_CAFNumber__c is not null
        Contract updatedContractRec=[SELECT Id,ARTL_CAFNumber__c FROM Contract WHERE Id=:conRecord.Id ];
        //system.debug('updatedContractRec')
        System.assertNotEquals(updatedContractRec.ARTL_CAFNumber__c, null);
        
        
        Test.stopTest();
    }
}