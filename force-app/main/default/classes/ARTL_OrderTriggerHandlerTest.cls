@isTest 
public class ARTL_OrderTriggerHandlerTest {
  
    @isTest
    static void testAfterInsert() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account',vlocity_cmt__Status__c ='Active');
        insert testAccount;
        AccountTeamMember member = new AccountTeamMember(
        	userId = UserInfo.getUserId(),
            AccountId = testAccount.Id,
            TeamMemberRole = 'PM'
        );
        insert member;
        Product2 testProduct1 = new Product2(
            Name = 'Test Product Root',
            ProductCode = 'VEPC_AOI_Combo',
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
            //PM__c = [select id from user where Username = 'testuser1test@example.com' limit 1].Id,
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
                                                       vlocity_cmt__LineNumber__c = '0001');
        insert qouteLine1;
        
        QuoteLineItem  qouteLine2 = new QuoteLineItem (UnitPrice = 1, Quantity = 1, Product2Id = testProduct1.Id,
                                                       vlocity_cmt__Product2Id__c = testProduct1.Id,
                                                       QuoteId =qtest.Id, PricebookEntryId=testPricebookEntry1.Id,
                                                       vlocity_cmt__LineNumber__c = '0002');
        insert qouteLine2;
        
        Order testOrder1 = new Order(
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            name = 'testOrder',
            Status = 'Draft',
            vlocity_cmt__QuoteId__c = qtest.Id,
            Pricebook2Id = Test.getStandardPricebookId()
            //vlocity_cmt__ParentOrderId__c = testOrder.Id
        );
        insert testOrder1;
        
        /*User testUser = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        
        // Assigning PM__c to Quote
        qtest.PM__c = testUser.Id;
        update qtest;
        List<Order> orderList = [select id,CreatedById, vlocity_cmt__QuoteId__r.PM__c,vlocity_cmt__QuoteId__c,vlocity_cmt__QuoteId__r.Name from Order   ]; 

        Test.startTest();
        // Call the method under test
        ARTL_OrderTriggerHandler.afterInsert(orderList);
        Test.stopTest();
        
        // Query OrderShare records created by the method
        List<OrderShare> orderShares = [SELECT Id FROM OrderShare WHERE OrderId = :testOrder1.Id];*/
      
    }
    
}