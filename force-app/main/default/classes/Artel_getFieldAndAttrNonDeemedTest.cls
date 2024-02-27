@isTest
public class Artel_getFieldAndAttrNonDeemedTest {
    
    @testSetup static void setup() {
        
        // create test data for order, Account, Quote, Opportunity
        Account acc = new Account();
        acc.name='Parent Test';
        acc.BillingStreet = '3022  Strother Street';
        acc.BillingCity = 'Into';
        acc.BillingState = 'Alabama';
        acc.BillingPostalCode = '35222';
        acc.BillingCountry = 'US';
        
        insert acc ;
        
        Product2[] products = new Product2[2];

        products[0]=new Product2(name='Test Product1', ProductCode='VEPC_ENTERPRISE_ICONNECTIVITY_ROUTERS');
        products[1]=new Product2(name='Test Product2', ProductCode='VEPC_PRIMARY_LINK');
        
        insert products;

        PricebookEntry[] pbes = new PricebookEntry[products.size()];
        Id pbId = Test.getStandardPricebookId();

        for (Integer i=0; i<products.size(); i++)
        {
            pbes[i] = new PricebookEntry(product2Id = products[i].id, IsActive = true, unitPrice = 10, pricebook2id = pbId, useStandardPrice = false);
        }

        insert pbes;

        
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = pbId, vlocity_cmt__IsActive__c = true, vlocity_cmt__Code__c = 'TestPricebook5');
        insert pl1;
        
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
        qtest.vlocity_cmt__PoDate__c = Date.today();
        qtest.vlocity_cmt__PoNumber__c = '12345';
        qtest.PO_Term__c = '12';
        qtest.PO_Value__c = 1222;
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
        QuoteLineItem  qouteLine2 = new QuoteLineItem ();
        qouteLine2.UnitPrice = 1;
        qouteLine2.Quantity = 1;
        qouteLine2.Product2Id = products[1].Id;
        qouteLine2.vlocity_cmt__Product2Id__c = products[1].Id;
        qouteLine2.QuoteId =qtest.Id;
        qouteLine2.PricebookEntryId=pbes[0].Id;
        insert qouteLine2;
        
        List<Order> orderList = new List<Order>();
        Order ord = new Order(AccountId = acc.id,vlocity_cmt__QuoteId__c = qtest.Id ,
                effectiveDate = Date.today(), pricebook2id = pbId, status = 'Draft',
                vlocity_cmt__PriceListId__c = pl1.Id);
        orderList.add(ord);
        insert orderList;
        system.debug('orderList###'+orderList);
        

        
    }
    
    @isTest
    public static void testExceuteItem(){
    
        
           
        Artel_getFieldAndAttrNonDeemed obj = new Artel_getFieldAndAttrNonDeemed();
        obj.ordId  = [select id from Order limit 1].Id;
        obj.getOrderRelDetails();
        
        
    
    }
    
    @isTest 
    public static void testExceuteTaskItem(){
        
        List<Task> tlist = new List<Task>();
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject='LOC Customer';
        t.Status='Not Started';
        t.Priority='Normal';
      	t.whatId = [select id from Order limit 1].Id;
        tlist.add(t);
        insert tlist; 
        
        Test.startTest();
        Artel_getFieldAndAttrNonDeemed demmed = new Artel_getFieldAndAttrNonDeemed();
        demmed.ordId  = [select id from Order limit 1].Id;
        demmed.getapproveTask();
		Test.stopTest();
       
    }
    @isTest 
    public static void testExceuteRejecTaskItem(){
        
        List<Task> tlist = new List<Task>();
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject='LOC Customer';
        t.Status='Not Started';
        t.Priority='Normal';
      	t.whatId = [select id from Order limit 1].Id;
        tlist.add(t);
        insert tlist; 
        
        Test.startTest();
        Artel_getFieldAndAttrNonDeemed demmed = new Artel_getFieldAndAttrNonDeemed();
        demmed.ordId  = [select id from Order limit 1].Id;
        demmed.getrejectTask();
        Test.stopTest();
    }
   }