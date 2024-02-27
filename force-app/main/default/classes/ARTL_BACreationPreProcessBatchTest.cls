@isTest
private class ARTL_BACreationPreProcessBatchTest  {

     
    @isTest
    static void testGetOrderRelDetails() {
        
         Account[] accounts =new Account[3];
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Id billingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        Id serviceAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        accounts[0] = new Account(Name = 'Test Business Account',RecordTypeId = businessAccountRecordTypeId);
        accounts[1] = new Account(Name = 'Test Billing Account',RecordTypeId  = billingAccountRecordTypeId);
        accounts[2] = new Account(Name = 'Test Service Account',RecordTypeId  = serviceAccountRecordTypeId);
        insert accounts;
        
        Product2[] products = new Product2[2];
        products[0]=new Product2(name='Test Product1', ProductCode='VEPC_ENTERPRISE_ICONNECTIVITY_ROUTERS');
        products[1]=new Product2(name='Test Product2', ProductCode='VEPC_PRIMARY_LINK');
        
        insert products;
        
        PricebookEntry[] pbes = new PricebookEntry[products.size()];
        Id pbId = Test.getStandardPricebookId();
        
        for (Integer i=0; i<products.size(); i++){
            pbes[i] = new PricebookEntry(product2Id = products[i].id, 
                                         IsActive = true, 
                                         unitPrice = 10, 
                                         pricebook2id = pbId, 
                                         useStandardPrice = false);
        }
        
        insert pbes;
        
        
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = pbId, 
                                                                      vlocity_cmt__IsActive__c = true, 
                                                                      vlocity_cmt__Code__c = 'TestPricebook5');
        insert pl1;
        
        Opportunity  opp = new Opportunity ();
        opp.name= 'EPC Deal AA';
        opp.accountId = accounts[0].id;
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
        
        PO_Group__c poGroup = new PO_Group__c();
        poGroup.ARTL_PO_Group_Number__c = '123';
        insert poGroup;
        
        PO_Group__c poGroup1 = new PO_Group__c();
        poGroup1.ARTL_PO_Group_Number__c = '1234';
        insert poGroup1;
        
        ARTL_Purchase_Order__c PurchaseOrder = new ARTL_Purchase_Order__c();
        PurchaseOrder.ARTL_PO_Number__c = '111111';
        PurchaseOrder.PO_Group__c = poGroup.id;
        insert PurchaseOrder;
        
        QuoteLineItem  quoteLine1 = new QuoteLineItem ();
        quoteLine1.UnitPrice = 1;
        quoteLine1.Quantity = 1;
        quoteLine1.Product2Id = products[1].Id;
        quoteLine1.vlocity_cmt__Product2Id__c = products[1].Id;
        quoteLine1.QuoteId =qtest.Id;
        quoteLine1.PricebookEntryId=pbes[0].Id;
        quoteLine1.vlocity_cmt__Action__c='Change';
        quoteLine1.ARTL_Purchase_Order__c = PurchaseOrder.Id;
        quoteLine1.vlocity_cmt__ServiceAccountId__c =accounts[2].id;
        quoteLine1.vlocity_cmt__BillingAccountId__c =accounts[1].id;
        
        insert quoteLine1;
        
        QuoteLineItem  quoteLine = new QuoteLineItem ();
        quoteLine.UnitPrice = 1;
        quoteLine.Quantity = 1;
        quoteLine.Product2Id = products[0].Id;
        quoteLine.vlocity_cmt__Product2Id__c = products[0].Id;
        quoteLine.QuoteId =qtest.Id;
        quoteLine.PricebookEntryId=pbes[0].Id;
        quoteLine.vlocity_cmt__Action__c='Add';
        quoteLine.ARTL_Purchase_Order__c =null;
        quoteLine.vlocity_cmt__ServiceAccountId__c =accounts[2].id;
        quoteLine.vlocity_cmt__BillingAccountId__c =accounts[1].id;
        
        
        
        ARTL_Billing_Staging__c stage = new ARTL_Billing_Staging__c();
        stage.Quote__c = qtest.Id;
        stage.Quote_Line_Item__c = quoteLine.Id;
        insert stage;
            List<ARTL_Billing_Staging__c> basaList=[SELECT Id FROM ARTL_Billing_Staging__c];
        for(ARTL_Billing_Staging__c BL : basaList)
        {
            BL.Quote__c = qtest.Id;
        BL.Status__c = 'Success';
            BL.ARTL_PO_Group_Id__c = Null;
             BL.BCP_Last_Name__c = 'Test';
        } 
        
        update basaList;
        system.debug('baselist::' + basaList);
        test.starttest();
            ARTL_BACreationPreProcessBatch testBatch = new ARTL_BACreationPreProcessBatch(new Set<Id>{qtest.Id});

        // Start the batch execution
       ID batchprocessid= Database.executeBatch(testBatch);
        system.debug('batchprocessid::' + batchprocessid);
            Test.stopTest();
    }
    
      @isTest
    static void testGetOrderRelDetails2() {
            
         Account[] accounts =new Account[3];
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Id billingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        Id serviceAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        accounts[0] = new Account(Name = 'Test Business Account',RecordTypeId = businessAccountRecordTypeId);
        accounts[1] = new Account(Name = 'Test Billing Account',RecordTypeId  = billingAccountRecordTypeId);
        accounts[2] = new Account(Name = 'Test Service Account',RecordTypeId  = serviceAccountRecordTypeId);
        insert accounts;
        
        Product2[] products = new Product2[2];
        products[0]=new Product2(name='Test Product1', ProductCode='VEPC_ENTERPRISE_ICONNECTIVITY_ROUTERS');
        products[1]=new Product2(name='Test Product2', ProductCode='VEPC_PRIMARY_LINK');
        
        insert products;
        
        PricebookEntry[] pbes = new PricebookEntry[products.size()];
        Id pbId = Test.getStandardPricebookId();
        
        for (Integer i=0; i<products.size(); i++){
            pbes[i] = new PricebookEntry(product2Id = products[i].id, 
                                         IsActive = true, 
                                         unitPrice = 10, 
                                         pricebook2id = pbId, 
                                         useStandardPrice = false);
        }
        
        insert pbes;
        
        
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = pbId, 
                                                                      vlocity_cmt__IsActive__c = true, 
                                                                      vlocity_cmt__Code__c = 'TestPricebook5');
        insert pl1;
        
        Opportunity  opp = new Opportunity ();
        opp.name= 'EPC Deal AA';
        opp.accountId = accounts[0].id;
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
        
        PO_Group__c poGroup = new PO_Group__c();
        poGroup.ARTL_PO_Group_Number__c = '123';
        insert poGroup;
        
        PO_Group__c poGroup1 = new PO_Group__c();
        poGroup1.ARTL_PO_Group_Number__c = '1234';
        insert poGroup1;
        
        ARTL_Purchase_Order__c PurchaseOrder = new ARTL_Purchase_Order__c();
        PurchaseOrder.ARTL_PO_Number__c = '111111';
        PurchaseOrder.PO_Group__c = poGroup.id;
        insert PurchaseOrder;
        
        QuoteLineItem  quoteLine1 = new QuoteLineItem ();
        quoteLine1.UnitPrice = 1;
        quoteLine1.Quantity = 1;
        quoteLine1.Product2Id = products[1].Id;
        quoteLine1.vlocity_cmt__Product2Id__c = products[1].Id;
        quoteLine1.QuoteId =qtest.Id;
        quoteLine1.PricebookEntryId=pbes[0].Id;
        quoteLine1.vlocity_cmt__Action__c='Change';
        quoteLine1.ARTL_Purchase_Order__c = PurchaseOrder.Id;
        quoteLine1.vlocity_cmt__ServiceAccountId__c =accounts[2].id;
        quoteLine1.vlocity_cmt__BillingAccountId__c =accounts[1].id;
        
        insert quoteLine1;
        
        QuoteLineItem  quoteLine = new QuoteLineItem ();
        quoteLine.UnitPrice = 1;
        quoteLine.Quantity = 1;
        quoteLine.Product2Id = products[0].Id;
        quoteLine.vlocity_cmt__Product2Id__c = products[0].Id;
        quoteLine.QuoteId =qtest.Id;
        quoteLine.PricebookEntryId=pbes[0].Id;
        quoteLine.vlocity_cmt__Action__c='Add';
        quoteLine.ARTL_Purchase_Order__c =null;
        quoteLine.vlocity_cmt__ServiceAccountId__c =accounts[2].id;
        quoteLine.vlocity_cmt__BillingAccountId__c =accounts[1].id;
        
        PO_Group__c POGrp= new PO_Group__c();
        POGrp.ARTL_PO_Group_Number__c='123456';
        POGrp.ARTL_Legacy_No__c='123456';
        insert POGrp;
        
        
        
        ARTL_Billing_Staging__c stage = new ARTL_Billing_Staging__c();
        stage.Quote__c = qtest.Id;
        stage.Quote_Line_Item__c = quoteLine.Id;
        stage.Shipping_Street__c = 'Test';
        
        insert stage;
            List<ARTL_Billing_Staging__c> basaList=[SELECT Id,Shipping_Street__c FROM ARTL_Billing_Staging__c];
        for(ARTL_Billing_Staging__c BL : basaList)
        {
            BL.Quote__c = qtest.Id;
        BL.Status__c = 'Success';
            BL.ARTL_PO_Group_Id__c = POGrp.id;
            BL.PO__c='TEST';
            BL.Quote_Line_Item__c = quoteLine.id;
            BL.Shipping_Street__c = 'Test';
            BL.BCP_Last_Name__c = 'Test';
            BL.BCP_Id__c =Null;
             BL.DCP_Last_Name__c = 'test';
            BL.DCP_First_Name__c ='first';
            BL.DCP_Phone__c=  '1234567890';
            BL.DCP_Email__c = 'test_12@gmail.com';
            BL.Service_Account_Id__c = accounts[2].Id;
        } 
        
        update basaList;
        system.debug('baselist::' + basaList);
        Test.starttest();
            ARTL_BACreationPreProcessBatch testBatch = new ARTL_BACreationPreProcessBatch(new Set<Id>{qtest.Id});

        // Start the batch execution
       ID batchprocessid= Database.executeBatch(testBatch);
        system.debug('batchprocessid::' + batchprocessid);
            Test.stopTest();
    
    }     
    /* @isTest
    static void testGetOrderRelDetails3() {
        
            
         Account[] accounts =new Account[3];
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Id billingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        Id serviceAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        accounts[0] = new Account(Name = 'Test Business Account',RecordTypeId = businessAccountRecordTypeId);
        accounts[1] = new Account(Name = 'Test Billing Account',RecordTypeId  = billingAccountRecordTypeId);
        accounts[2] = new Account(Name = 'Test Service Account',RecordTypeId  = serviceAccountRecordTypeId);
        insert accounts;
        
        Product2[] products = new Product2[2];
        products[0]=new Product2(name='Test Product1', ProductCode='VEPC_ENTERPRISE_ICONNECTIVITY_ROUTERS');
        products[1]=new Product2(name='Test Product2', ProductCode='VEPC_PRIMARY_LINK');
        
        insert products;
        
        PricebookEntry[] pbes = new PricebookEntry[products.size()];
        Id pbId = Test.getStandardPricebookId();
        
        for (Integer i=0; i<products.size(); i++){
            pbes[i] = new PricebookEntry(product2Id = products[i].id, 
                                         IsActive = true, 
                                         unitPrice = 10, 
                                         pricebook2id = pbId, 
                                         useStandardPrice = false);
        }
        
        insert pbes;
        
        
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = pbId, 
                                                                      vlocity_cmt__IsActive__c = true, 
                                                                      vlocity_cmt__Code__c = 'TestPricebook5');
        insert pl1;
        
        Opportunity  opp = new Opportunity ();
        opp.name= 'EPC Deal AA';
        opp.accountId = accounts[0].id;
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
        
        PO_Group__c poGroup = new PO_Group__c();
        insert poGroup;
        
        PO_Group__c poGroup1 = new PO_Group__c();
        insert poGroup1;
        
        ARTL_Purchase_Order__c PurchaseOrder = new ARTL_Purchase_Order__c();
        PurchaseOrder.ARTL_PO_Number__c = '111111';
        PurchaseOrder.PO_Group__c = poGroup.id;
        insert PurchaseOrder;
        
        QuoteLineItem  quoteLine1 = new QuoteLineItem ();
        quoteLine1.UnitPrice = 1;
        quoteLine1.Quantity = 1;
        quoteLine1.Product2Id = products[1].Id;
        quoteLine1.vlocity_cmt__Product2Id__c = products[1].Id;
        quoteLine1.QuoteId =qtest.Id;
        quoteLine1.PricebookEntryId=pbes[0].Id;
        quoteLine1.vlocity_cmt__Action__c='Change';
        quoteLine1.ARTL_Purchase_Order__c = PurchaseOrder.Id;
        quoteLine1.vlocity_cmt__ServiceAccountId__c =accounts[2].id;
        quoteLine1.vlocity_cmt__BillingAccountId__c =accounts[1].id;
        
        insert quoteLine1;
        
        QuoteLineItem  quoteLine = new QuoteLineItem ();
        quoteLine.UnitPrice = 1;
        quoteLine.Quantity = 1;
        quoteLine.Product2Id = products[0].Id;
        quoteLine.vlocity_cmt__Product2Id__c = products[0].Id;
        quoteLine.QuoteId =qtest.Id;
        quoteLine.PricebookEntryId=pbes[0].Id;
        quoteLine.vlocity_cmt__Action__c='Add';
        quoteLine.ARTL_Purchase_Order__c =null;
        quoteLine.vlocity_cmt__ServiceAccountId__c =accounts[2].id;
        quoteLine.vlocity_cmt__BillingAccountId__c =accounts[1].id;
        
        
        
        ARTL_Billing_Staging__c stage = new ARTL_Billing_Staging__c();
        stage.Quote__c = qtest.Id;
        stage.Quote_Line_Item__c = quoteLine.Id;
        insert stage;
            
            List<ARTL_Billing_Staging__c> basaList=[SELECT Id FROM ARTL_Billing_Staging__c];
        for(ARTL_Billing_Staging__c BL : basaList)
        {
            BL.Quote__c = qtest.Id;
        BL.Status__c = 'Success';
            BL.ARTL_PO_Group_Id__c = Null;
            BL.Quote_Line_Item__c = quoteLine.id;
            BL.Shipping_Street__c = 'Test';
            BL.BCP_Last_Name__c = 'Test1';
            BL.BCP_First_Name__c = 'First1';
            BL.BCP_Phone__c= '1234567899';
             BL.BCP_Email__c = 'test_123@gmail.com';
            BL.Billing_Account_Id__c = accounts[2].Id;
            BL.BCP_Id__c =Null;
            BL.DCP_Last_Name__c = 'test';
            BL.DCP_First_Name__c ='first';
            BL.DCP_Phone__c=  '1234567890';
            BL.DCP_Email__c = 'test_12@gmail.com';
            BL.Service_Account_Id__c = accounts[2].Id;
            //String uniqueKey = obj.BCP_First_Name__c + obj.BCP_Last_Name__c + obj.BCP_Phone__c + obj.BCP_Email__c;
        } 
        
        update basaList;
        system.debug('baselist::' + basaList);
        test.starttest();
            ARTL_BACreationPreProcessBatchHelper.createDCPContacts(basaList);
        //ARTL_BACreationPreProcessBatchHelper.createBCPContacts(basaList);
        Test.stopTest();
    
    
    }*/
    
     @isTest
    static void testGetOrderRelDetails4() {
        
            
         Account[] accounts =new Account[3];
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Id billingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        Id serviceAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        accounts[0] = new Account(Name = 'Test Business Account',RecordTypeId = businessAccountRecordTypeId);
        accounts[1] = new Account(Name = 'Test Billing Account',RecordTypeId  = billingAccountRecordTypeId);
        accounts[2] = new Account(Name = 'Test Service Account',RecordTypeId  = serviceAccountRecordTypeId);
        insert accounts;
        
        Product2[] products = new Product2[2];
        products[0]=new Product2(name='Test Product1', ProductCode='VEPC_ENTERPRISE_ICONNECTIVITY_ROUTERS');
        products[1]=new Product2(name='Test Product2', ProductCode='VEPC_PRIMARY_LINK');
        
        insert products;
        
        PricebookEntry[] pbes = new PricebookEntry[products.size()];
        Id pbId = Test.getStandardPricebookId();
        
        for (Integer i=0; i<products.size(); i++){
            pbes[i] = new PricebookEntry(product2Id = products[i].id, 
                                         IsActive = true, 
                                         unitPrice = 10, 
                                         pricebook2id = pbId, 
                                         useStandardPrice = false);
        }
        
        insert pbes;
        
        
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = pbId, 
                                                                      vlocity_cmt__IsActive__c = true, 
                                                                      vlocity_cmt__Code__c = 'TestPricebook5');
        insert pl1;
        
        Opportunity  opp = new Opportunity ();
        opp.name= 'EPC Deal AA';
        opp.accountId = accounts[0].id;
        opp.vlocity_cmt__PriceListId__c = pl1.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Initial';
        opp.Pricebook2Id = pbId;
        insert opp;
        
        Quote qtest = new Quote();
        qtest.name = 'Quote - EPC Deal AA';
        qtest.Status = 'Draft';
       //s qtest.AccountId=accounts[0].id;
        qtest.OpportunityId = opp.Id;
        qtest.Pricebook2Id = pbId;
        qtest.vlocity_cmt__PriceListId__c = pl1.Id;
        qtest.vlocity_cmt__PoDate__c = Date.today();
        qtest.vlocity_cmt__PoNumber__c = '12345';
        qtest.PO_Term__c = '12';
        qtest.PO_Value__c = 1222;
        qtest.RecordTypeId =  [SELECT Id FROM RecordType WHERE DeveloperName= 'EnterpriseQuote' AND SobjectType= 'Quote' LIMIT 1].Id;
        insert qtest;
        
        PO_Group__c poGroup = new PO_Group__c();
        poGroup.ARTL_PO_Group_Number__c = '123';
        insert poGroup;
        
        PO_Group__c poGroup1 = new PO_Group__c();
        poGroup1.ARTL_PO_Group_Number__c = '1234';
        insert poGroup1;
        
        ARTL_Purchase_Order__c PurchaseOrder = new ARTL_Purchase_Order__c();
        PurchaseOrder.ARTL_PO_Number__c = '111111';
        PurchaseOrder.PO_Group__c = poGroup.id;
        insert PurchaseOrder;
        
        QuoteLineItem  quoteLine1 = new QuoteLineItem ();
        quoteLine1.UnitPrice = 1;
        quoteLine1.Quantity = 1;
        quoteLine1.Product2Id = products[1].Id;
        quoteLine1.vlocity_cmt__Product2Id__c = products[1].Id;
        quoteLine1.QuoteId =qtest.Id;
        quoteLine1.PricebookEntryId=pbes[0].Id;
        quoteLine1.vlocity_cmt__Action__c='Change';
        quoteLine1.ARTL_Purchase_Order__c = PurchaseOrder.Id;
        quoteLine1.vlocity_cmt__ServiceAccountId__c =accounts[2].id;
        quoteLine1.vlocity_cmt__BillingAccountId__c =accounts[1].id;
        
        insert quoteLine1;
        
        QuoteLineItem  quoteLine = new QuoteLineItem ();
        quoteLine.UnitPrice = 1;
        quoteLine.Quantity = 1;
        quoteLine.Product2Id = products[0].Id;
        quoteLine.vlocity_cmt__Product2Id__c = products[0].Id;
        quoteLine.QuoteId =qtest.Id;
        quoteLine.PricebookEntryId=pbes[0].Id;
        quoteLine.vlocity_cmt__Action__c='Add';
        quoteLine.ARTL_Purchase_Order__c =null;
        quoteLine.vlocity_cmt__ServiceAccountId__c =accounts[2].id;
       // quoteLine.vlocity_cmt__BillingAccountId__c =accounts[1].id;
        quoteLine.vlocity_cmt__BillingAccountId__c =Null;
        
        insert quoteLine;
        
         PO_Group__c POGrp= new PO_Group__c();
        POGrp.ARTL_PO_Group_Number__c='123456';
        POGrp.ARTL_Legacy_No__c='123456';
        insert POGrp;
        ARTL_Billing_Staging__c stage = new ARTL_Billing_Staging__c();
        stage.Quote__c = qtest.Id;
        stage.Quote_Line_Item__c = quoteLine.Id;
        stage.Shipping_Street__c = 'Test';
        insert stage;
            List<ARTL_Billing_Staging__c> basaList=[SELECT Id, Shipping_Street__c ,Quote_Line_Item__r.Quote.AccountId,Quote__c, Quote__r.Account.Name FROM ARTL_Billing_Staging__c];
        for(ARTL_Billing_Staging__c BL : basaList)
        {
            BL.Quote__c = qtest.Id;
           // BL.Quote__r= qtest.Id;
           Bl.Quote_Line_Item__c=quoteLine.id;
        BL.Status__c = 'Success';
           // BL.Quote__r.Account=accounts[2].id;
            BL.Quote__r.Account.Name='sds';
             BL.ARTL_PO_Group_Id__c = POGrp.id;
            BL.PO__c='TEST';
            BL.PO_Start_Date__c=Date.valueof('2024-01-06'); 
                BL.PO_End_Date__c=Date.valueof('2025-01-06'); 
           // BL.Quote_Line_Item__c = quoteLine.id;
            BL.Shipping_Street__c = 'Test';
            BL.BCP_Last_Name__c = 'Testtest';
            BL.BCP_First_Name__c = 'Firstfirst';
            BL.PO_Amount__c=123;
            BL.Billing_Address__c='TEST';
            Bl.Billing_State__c='test';
            bl.Billing_PinCode__c='440013';
            bl.Billing_City__c='Nagpur';
            BL.BCP_Phone__c= '1234567899';
            BL.Billing_Country__c='India';
            BL.Billing_Account_Number__c='122345';
             BL.BCP_Email__c = 'test_123@gmail.com';
            BL.Billing_Account_Id__c = accounts[1].Id;
            Bl.Billing_Street__c = 'MG Road';
            Bl.Billing_Level__c='Account Level';
            BL.Legal_Entity__c='Test';
            BL.CurrencyIsoCode ='INR';
            BL.License_Company__c='BAL Internet';
            BL.Bill_Format__c='AES - Services';
            BL.Taxation__c='';
            BL.Usage_Flag__c=Null;
            BL.Credit_Period__c = Null;
            BL.Bill_Franchise_Tax_Code__c='';
            BL.Billing_GST_Applicable_for_Billing__c=False;
            BL.StandardReasonforTaxExemption__c =Null;
             BL.Delivery_GST__c=null;
            Bl.NBA_Account_Number__c =Null;
            BL.BCP_Id__c = Null;
            Bl.Store__c= Null;
            BL.Bill_Type__c='Advance';
            BL.BCP_Id__c =Null;
            BL.DCP_Id__c=NULL;
            BL.DCP_Last_Name__c = 'test';
            BL.DCP_First_Name__c ='first';
            BL.DCP_Phone__c=  '1234567890';
            BL.DCP_Email__c = 'test_12@gmail.com';
            BL.Service_Account_Id__c = accounts[1].Id;
            //String uniqueKey = obj.BCP_First_Name__c + obj.BCP_Last_Name__c + obj.BCP_Phone__c + obj.BCP_Email__c;
        } 
        
        update basaList;
        system.debug('baselist::' + basaList);
        test.starttest();
        //ARTL_BACreationPreProcessBatchHelper BAClass = new ARTL_BACreationPreProcessBatchHelper();
           ARTL_BACreationPreProcessBatchHelper.createBillingAccounts(basaList,string.valueof(billingAccountRecordTypeId));
         ARTL_BACreationPreProcessBatchHelper.createBillingAccounts(basaList,string.valueof(serviceAccountRecordTypeId));
       // ARTL_BACreationPreProcessBatchHelper.getPOOrCreate(basaList);
        Test.stopTest();
        }
}