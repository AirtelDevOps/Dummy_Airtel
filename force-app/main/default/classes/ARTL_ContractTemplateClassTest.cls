@isTest
private class ARTL_ContractTemplateClassTest {
    
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
        
        Product2 prod2 = new Product2(Name = 'Test product2', family = 'Internet',ProductCode='VEPC_PRIMARY_LINK',ARTL_LSIRequired__c=true);
        insert prod2;
        
        // Create a price book entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        PricebookEntry pbEntry2 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod2.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry2;
        
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
        
        
        vlocity_cmt__QuoteMember__c quoteMemRec=new vlocity_cmt__QuoteMember__c(
        	Name='test qm name',
            vlocity_cmt__QuoteId__c=q.Id,
            vlocity_cmt__StreetAddress__c='Street address',
            vlocity_cmt__PostalCode__c='670143',
            vlocity_cmt__City__c='Kannur',
            vlocity_cmt__State__c='Kerala',
            vlocity_cmt__Country__c='India'
            
        );
        insert quoteMemRec;
        
        // Create a quote line item
        QuoteLineItem qli = new QuoteLineItem(
            Product2Id = prod.Id,
            QuoteId = q.Id,
            PricebookEntryId = pbEntry.Id,
            UnitPrice = pbEntry.UnitPrice,
            Quantity=1,
            vlocity_cmt__QuoteMemberId__c=quoteMemRec.Id,
            Annual_Recurring_Total__c=50000,
            vlocity_cmt__OneTimeTotal__c=10000,
            vlocity_cmt__AttributeSelectedValues__c='{"ATT_ACCESS_BANDWIDTH":"12"}'
        );
        insert qli;
        
        QuoteLineItem qli2 = new QuoteLineItem(
            Product2Id = prod2.Id,
            QuoteId = q.Id,
            PricebookEntryId = pbEntry2.Id,
            UnitPrice = pbEntry2.UnitPrice,
            Quantity=1,
            vlocity_cmt__QuoteMemberId__c=quoteMemRec.Id,
            vlocity_cmt__ParentItemId__c=qli.Id,
            Annual_Recurring_Total__c=50000,
            vlocity_cmt__OneTimeTotal__c=10000,
            vlocity_cmt__AttributeSelectedValues__c='{"ATT_ACCESS_BANDWIDTH":"12"  ,   "ATT_CPE":"ATT_CPE"  ,  "ATT_IP_Type":"ATT_IP_Type"  ,  "ATT_MEDIA":"ATT_MEDIA" , "ATT_POP":"ATT_POP"  ,  "ATT_PORT_BANDWIDTH":"2"  , "ATT_ROUTING_TYPE":"ATT_ROUTING_TYPE"  ,  "ATT_SERVICE_TYPE":"ATT_SERVICE_TYPE" ,  "ATT_CONTRACT_TERM":"ATT_CONTRACT_TERM"  ,  "ATT_LAST_MILE":"ATT_LAST_MILE"  ,  "ATT_IP_REQUIRED":true }'
            //vlocity_cmt__RootItemId__c=qli.Id
        );
        insert qli2;
        
        
        
        
        Contract conRecord=new Contract(
            AccountId=acc.Id,
            Status='Draft',
            StartDate =System.today(),
            CurrencyIsoCode='INR',
            vlocity_cmt__QuoteId__c=q.Id
        );
        insert conRecord;
        
        vlocity_cmt__DocumentTemplate__c docTemplate=new vlocity_cmt__DocumentTemplate__c(
        	Name='test contract template'
        );
        insert docTemplate;
    }

    @isTest
    static void testInvokeMethod() {
        // Create a test Contract and Document Template
       Contract testContract=[SELECT Id FROM Contract LIMIT 1];
        vlocity_cmt__DocumentTemplate__c testTemplate=[SELECT Id FROM vlocity_cmt__DocumentTemplate__c LIMIT 1];
        
        // Set the necessary fields for the test Contract

        // You may also need to create other required records based on your implementation

        // Call the invokeMethod
        ARTL_ContractTemplateClass contractTemplateClassInstance = new ARTL_ContractTemplateClass();
        Map<String, Object> inputParams = new Map<String, Object>{
            'contextId' => testContract.Id,
            'templateId' => testTemplate.Id  // Replace 'TemplateId' with a valid Document Template Id
        };
        Map<String, Object> outputParams = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Test.startTest();
        Boolean success = (Boolean)contractTemplateClassInstance.invokeMethod('getTokenData', inputParams, outputParams, options);
        Test.stopTest();

        // Assert the success and any other expected outcomes
        System.assertEquals(true, success);

        // You may need to add more assertions based on your specific requirements
    }

    // Add more test methods based on different scenarios and edge cases
}