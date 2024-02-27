@isTest
private class ARTL_CreateDCPControllerTest {
    
  
    @isTest
    static void testCreateDCP() {
        // Test input
       // List<Object> objList = new List<Object>{/* Add test data */};
            // String quoteId = 'sampleQuoteId'; // Replace with an actual Quote Id
            
            // create test data for order, Account, Quote, Opportunity
             Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
            Account acc = new Account();
        acc.name='27AWTPT6176B1ZX';
        acc.BillingStreet = '3022  Strother Street';
        acc.BillingCity = 'Into';
        acc.BillingState = 'Alabama';
        acc.BillingPostalCode = '35222';
        acc.BillingCountry = 'US';
        acc.RecordTypeId = recordTypeId;
        acc.ARTL_PAN__c='AWTPT6176B';
        acc.ARTL_GST_IN__c='27AWTPT6176B1ZX';
        
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
        qtest.ARTL_NBA_Account__c=acc.id;
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
        qouteLine.vlocity_cmt__ServiceAccountId__c =acc.id;
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
        // Create an instance of the class
        //ARTL_CreateDCPController controller = new ARTL_CreateDCPController();
        vlocity_cmt__Premises__c Premise = new vlocity_cmt__Premises__c(Name= 'Test presmie',vlocity_cmt__StreetAddress__c='test',
                                                                       vlocity_cmt__City__c='Delhi',vlocity_cmt__State__c='Maharashtra',
                                                                       vlocity_cmt__PostalCode__c  = '11031');
        insert Premise;
        // Call the createDCP method
        List<Object> objList = new List<Object>();
        //List<vlocity_cmt__QuoteMember__c> QMember = New list<vlocity_cmt__QuoteMember__c>();
        GST__c gst= new GST__c(Name = '27AWTPT6176B1ZX',Postal_Code__c=110031,ARTL_Dty_GST_API_Response__c='SEZ',Account__c= acc.Id,Address_Line_1__c='5th Cross, Indira Marg', City__c='Delhi',Address_Line_2__c='Test' );
        insert gst;
        
        system.debug('gst::::::' + gst + ':::::::::' + gst.ARTL_Address__c);
       vlocity_cmt__QuoteMember__c Qmember = new vlocity_cmt__QuoteMember__c(vlocity_cmt__QuoteId__c = qtest.id,
                                                                                    Name = 'Test Quote Member',vlocity_cmt__PremisesId__c=Premise.id,
                                                                                    Feasibility_Status__c  = 'Feasible');
        insert QMember;
        // Sample test data
        Map<String, Object> obj1 = new Map<String, Object>{
            'qmId' => '001Q00000123456789',
                'FirstName' => 'John',
                'MiddleName' => 'M',
                'LastName' => 'Doe',
                'Phone' => '1234567890',
                'Email' => 'john.doe@example.com',
                'Designation' => 'Manager',
                'GST' => gst.id,
                'Gstappl' => 'Yes',
                'StdReason' => 'Others',
                'qmId' => string.valueof(QMember.id)
                };
                    objList.add(obj1);
        
        Map<String, Object> obj2 = new Map<String, Object>{
            'qmId' => '001Q00000123456790',
                'FirstName' => 'Jane',
                'MiddleName' => 'A',
                'LastName' => 'Smith',
                'Phone' => '9876543210',
                'Email' => 'jane.smith@example.com',
                'Designation' => 'Coordinator',
                'GST' => gst.id,
                'Gstappl' => 'No',
                'StdReason' => 'Others',
                 'qmId' => string.valueof(QMember.id)
                };
                    objList.add(obj2);
        List<ARTL_CreateDCPController.dispTableWrapper> result = ARTL_CreateDCPController.createDCP(objList, qtest.id);
        List<ARTL_CreateDCPController.dispTableWrapper> result1 = ARTL_CreateDCPController.fetchDCPwire(qtest.Id);
        
        // Add assertions based on the expected result
        System.assertNotEquals(null, result);
        // Add more assertions as needed
    }
    
    @isTest
    static void testFetchDCP() {
        // Test input
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
        qouteLine.vlocity_cmt__ServiceAccountId__c =acc.id;
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
        
        //String quoteId = ; // Replace with an actual Quote Id
        
        // Create an instance of the class
        //ARTL_CreateDCPController controller = new ARTL_CreateDCPController();
        
        // Call the fetchDCP method
        List<ARTL_CreateDCPController.dispTableWrapper> result = ARTL_CreateDCPController.fetchDCP(qtest.Id);
        
        // Add assertions based on the expected result
        System.assertNotEquals(null, result);
        // Add more assertions as needed
    }
    
    // Add more test methods as needed to cover different scenarios and edge cases
}