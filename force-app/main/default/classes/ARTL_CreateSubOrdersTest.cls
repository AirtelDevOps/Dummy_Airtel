@isTest
global with sharing class ARTL_CreateSubOrdersTest {
@isTest
    static void testCallSubOrderCreationBatch() {
        
     
            
         Account testAccount = new Account(Name = 'Test Account',vlocity_cmt__Status__c ='Active ');
        insert testAccount;
        
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
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            
            EffectiveDate = Date.today(),
            Status = 'Draft',
            QuoteId = qtest.Id,
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert testOrder;
        
        Order testOrder1 = new Order(
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            name = 'testOrder',
            Status = 'Draft',
            QuoteId = qtest.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            vlocity_cmt__ParentOrderId__c = testOrder.Id
        );
        insert testOrder1;
        


           
            
        OrderItem testOrderItem1 = new OrderItem(
            OrderId = testOrder1.Id,
            PricebookEntryId = testPricebookEntry1.Id,
            Quantity = 1,
            UnitPrice = 10,
            QuoteLineItemId = qouteLine1.Id,
            vlocity_cmt__BillingAccountId__c = testAccount.Id,
            vlocity_cmt__LineNumber__c = '0001',
            vlocity_cmt__AssetReferenceId__c ='1234',
            vlocity_cmt__RootItemId__c = '1234'
        );
        insert testOrderItem1;
        
        OrderItem testOrderItem2 = new OrderItem(
            OrderId = testOrder1.Id,
            PricebookEntryId = testPricebookEntry1.Id,
            Quantity = 2,
            UnitPrice = 10,
            QuoteLineItemId = qouteLine2.Id,
            vlocity_cmt__BillingAccountId__c = testAccount.Id,
            vlocity_cmt__LineNumber__c = '0002',
            vlocity_cmt__AssetReferenceId__c ='4567',
            vlocity_cmt__RootItemId__c = '4567'
        );
        insert testOrderItem2;
        
        vlocity_cmt__OrderItemRelationship__c orderItemRel = new vlocity_cmt__OrderItemRelationship__c(
            vlocity_cmt__OrderId__c = testOrder1.Id,
            vlocity_cmt__OrderItemId__c = testOrderItem1.Id,
            vlocity_cmt__RelatedOrderItemId__c = testOrderItem2.Id,
            vlocity_cmt__RelationshipType__c = 'ReliesOn'
        );
        insert orderItemRel;
            
            vlocity_cmt__OrderDiscount__c[] orderDiscount = new vlocity_cmt__OrderDiscount__c[1];
        orderDiscount[0] = new vlocity_cmt__OrderDiscount__c(Name = testOrder1.id,vlocity_cmt__OrderId__c = testOrder1.id,vlocity_cmt__AppliesToAllItems__c= true, vlocity_cmt__EffectiveEndDate__c = DateTime.now().addDays(30), vlocity_cmt__EffectiveStartDate__c = DateTime.now());
        insert orderDiscount;
         vlocity_cmt__OrderDiscountPricing__c orderdiscountpricing = new vlocity_cmt__OrderDiscountPricing__c(
            vlocity_cmt__OrderDiscountId__c = orderDiscount[0].id
            );
        
        		insert orderdiscountpricing;
                 List<order> orderlist = [select id from order where name ='testOrder'];
        String orderid = orderlist[0].id;
        Test.startTest();
        ARTL_CreateSubOrderCustomLogic testclass = new ARTL_CreateSubOrderCustomLogic(orderid,null);
        Id batchJobId = Database.executeBatch(testclass, 200);
        
        }
    }