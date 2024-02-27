@isTest
public class artl_HansenOrderStatusControllerTest {

    @isTest
    static void testGetHansenOrderStatus() {
        Id[] oiIds;
            Id orderId;
            Id[] FRLineIds;
            Id FRId;
            Product2[] products;
         Account grandParent = new Account(name='GrandparentTest');
        insert grandParent;
        
        Account parent = new Account(name='ParentTest', ParentId = grandParent.id);
        insert parent;
        
        Account acc = new Account(name='Test', ParentId = parent.id, ARTL_Business_Unit__c='EGB');
        insert acc;
        
        Id pbId = Test.getStandardPricebookId();
        
        products = new Product2[2];
        
        products[0]=new Product2(name='VEPC_Access_Bandwidth_ARC_CFS', ProductCode='VEPC_Access_Bandwidth_ARC_CFS ',vlocity_cmt__JSONAttribute__c = '');
        
        products[1]=new Product2(name='VEPC_PRIMARY_LINK_CFS ', ProductCode='VEPC_PRIMARY_LINK_CFS ', vlocity_cmt__JSONAttribute__c = '');
       
        insert products;
        
        PricebookEntry[] pbes = new PricebookEntry[products.size()];
        
        for (Integer i=0; i<products.size(); i++)
        {
            pbes[i] = new PricebookEntry(product2Id = products[i].id, unitPrice = 10, pricebook2id = pbId, useStandardPrice = false,IsActive = true);
        }
        
        insert pbes;
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = pbId, vlocity_cmt__IsActive__c = true, vlocity_cmt__Code__c = 'TestPricebook5');
        insert pl1;
        
        vlocity_cmt__OrchestrationItem__c item;

        vlocity_cmt__Subscription__c subs = new vlocity_cmt__Subscription__c(Name='TestSubs',vlocity_cmt__CurrentContractStartDate__c=Date.Today(), vlocity_cmt__CurrentContractEndDate__c = Date.Today(), vlocity_cmt__SubscriptionNumber__c = '123454321', vlocity_cmt__ServiceAccountId__c = acc.Id);    
        insert subs;
        
        Opportunity  opp = new Opportunity ();
        opp.name= 'EPC Deal AA';
        opp.accountId = acc.id;
        opp.vlocity_cmt__PriceListId__c = pl1.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Initial';
        opp.Pricebook2Id = pbId;
        insert opp;


        
        Quote qtest = new Quote();
        qtest.name = 'Quote - EPC Deal AA';
        qtest.Status = 'Draft';
        qtest.OpportunityId = opp.Id;
        qtest.Pricebook2Id = pbId;
        qtest.vlocity_cmt__PriceListId__c = pl1.Id;
        qtest.RecordTypeId =  [SELECT Id FROM RecordType WHERE DeveloperName= 'EnterpriseQuote' AND SobjectType= 'Quote' LIMIT 1].Id;
        insert qtest;
        
        QuoteLineItem  qouteLine = new QuoteLineItem ();
        qouteLine.UnitPrice = 1;
        qouteLine.Quantity = 1;
        qouteLine.Product2Id = products[0].Id;
        qouteLine.vlocity_cmt__Product2Id__c = products[0].Id;
        qouteLine.QuoteId =qtest.Id;
        qouteLine.PricebookEntryId=pbes[0].Id;
        insert qouteLine;
        Order order = new Order(AccountId = acc.id, effectiveDate = Date.today(), pricebook2id = pbId, status = 'Draft',vlocity_cmt__QuoteId__c = qtest.Id ,QuoteId = qtest.Id);
        insert order;
		order.ARTL_SOMOrder_Status__c = 'test1';
        update order;
        List<OrderHistory> testOrderHistoryList = new List<OrderHistory>();
        for (Integer i = 0; i < 3; i++) {
            OrderHistory testOrderHistory = new OrderHistory(
                OrderId = order.Id,
                Field = 'ARTL_SOMOrder_Status__c'
            );
            testOrderHistoryList.add(testOrderHistory);
        }
        insert testOrderHistoryList;
        List<OrderHistory> ordHistoryList = [SELECT id,NewValue from OrderHistory 
                                                 where Field = 'ARTL_SOMOrder_Status__c' 
                                                 and  OrderId =:order.Id order by CreatedDate desc];

        // Call the method from the controller
        Test.startTest();
        List<String> result = artl_HansenOrderStatusController.getHansenOrderStatus(order.Id);
        Test.stopTest();

    }
    
}