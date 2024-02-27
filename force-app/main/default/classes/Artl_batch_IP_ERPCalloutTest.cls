@isTest
private class Artl_batch_IP_ERPCalloutTest {
    
    @testSetup static void setup() {
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Product2 testProduct1 = new Product2(
            Name = 'Test Product Root',
            ProductCode = 'dac49a09-9b41-4999-b7c4-cf6319ad5b44',
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
            PO_Value__c = 1222
        );
        insert qtest;
        
        QuoteLineItem  qouteLine1 = new QuoteLineItem (UnitPrice = 1, Quantity = 1, Product2Id = testProduct1.Id,
                                                       vlocity_cmt__Product2Id__c = testProduct1.Id,
                                                       QuoteId =qtest.Id, PricebookEntryId=testPricebookEntry1.Id, RequisitionNumber__c='123',
                                                       vlocity_cmt__LineNumber__c = '0001', ARTL_OUName__c = 'Haryana');
        insert qouteLine1;
        
    } 
    
    private static testMethod void doTestFetchMr() {
        
        ARTL_Purchase_Request__c pRTest = new ARTL_Purchase_Request__c();
        pRTest.Requisition_Number__c = '1234544';
        pRTest.Quote_Line_Item__c = [select Id from QuoteLineItem limit 1].Id;
        insert pRTest;
        
        List<Order> lstMO = new List<Order>();
        Order testOrder = new Order(
            AccountId = [select id from account limit 1].Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            QuoteId = [select id from quote limit 1].Id,
            vlocity_cmt__QuoteId__c = [select id from quote limit 1].Id,
            Pricebook2Id = Test.getStandardPricebookId()
        );
        lstMO.add(testOrder);
        insert lstMO;
        
        List<Purchase_Order__c> pOTestList = new List<Purchase_Order__c>();
        Purchase_Order__c pOTest = new Purchase_Order__c();
        pOTest.PRID__c = pRTest.Id;
        pOTest.MasterOrder__c = lstMO[0].Id;
        pOTest.PONumber__c = 'B12345';
        
        pOTestList.add(pOTest);
        insert pOTestList;
        
        List<Artl_batch_IP_ERPCallout.FlowInputs> finputList = new List<Artl_batch_IP_ERPCallout.FlowInputs>();
        Artl_batch_IP_ERPCallout.FlowInputs finput = new Artl_batch_IP_ERPCallout.FlowInputs();
        finput.ids = new List<String>{pOTestList[0].Id};
            finput.activityAction = 'MrrDetails';
        finputList.add(finput);
        
        Test.startTest();
        Artl_batch_IP_ERPCallout.executeCustomBatch(finputList);
        Test.stopTest();   
    }
    
    private static testMethod void doTestFetchPR() {
        
        List<Order> lstMO = new List<Order>();
        Order testOrder = new Order(
            AccountId = [select id from account limit 1].Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            QuoteId = [select id from quote limit 1].Id,
            vlocity_cmt__QuoteId__c = [select id from quote limit 1].Id,
            Pricebook2Id = Test.getStandardPricebookId()
        );
        lstMO.add(testOrder);
        insert lstMO;
        
        List<ARTL_Purchase_Request__c> pRTestList = new List<ARTL_Purchase_Request__c>();
        ARTL_Purchase_Request__c pRTest = new ARTL_Purchase_Request__c();
        pRTest.Requisition_Number__c = '12345';
        pRTest.Master_Order__c = lstMO[0].Id;
        pRTest.Quote_Line_Item__c = [select Id from QuoteLineItem limit 1].Id;
        pRTestList.add(pRTest);
        insert pRTestList;
        
        
        List<Artl_batch_IP_ERPCallout.FlowInputs> finputList = new List<Artl_batch_IP_ERPCallout.FlowInputs>();
        Artl_batch_IP_ERPCallout.FlowInputs finput = new Artl_batch_IP_ERPCallout.FlowInputs();
        finput.ids = new List<String>{pRTestList[0].Id};
            finput.activityAction = 'NIPS_PO_Details';
        finputList.add(finput);
        
        Test.startTest();
        Artl_batch_IP_ERPCallout.executeCustomBatch(finputList);
        Test.stopTest();
    }
}