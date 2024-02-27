@isTest
global with sharing class Artel_EnrichAtrributeFromFeasibilityTest {
    @isTest
    static void enrichAttrFRLTest() {
        Account testAccount = new Account(Name = 'Test Account');
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
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            ProductCode = 'VEPC_DSL_CFS',
            IsActive = true
        );
        insert testProduct;
        
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert testPricebookEntry;
        
        Product2 testProduct2 = new Product2(
            Name = 'Test Product2',
            ProductCode = 'TEST_PROD_2',
            IsActive = true
        );
        insert testProduct2;
        
        // Create Test Pricebook Entry for Test Product 2
        PricebookEntry testPricebookEntry2 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct2.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert testPricebookEntry2;
        
        Product2 testProduct3 = new Product2(
            Name = 'Test Product3',
            ProductCode = 'VEPC_Voice_CFS',
            IsActive = true
        );
        insert testProduct3;
        
        PricebookEntry testPricebookEntry3 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct3.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert testPricebookEntry3;
        
        Product2 testProduct4 = new Product2(
            Name = 'Test Product4',
            ProductCode = 'TEST_PROD_4',
            IsActive = true
        );
        insert testProduct4;
        
        PricebookEntry testPricebookEntry4 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct4.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert testPricebookEntry4;
        
        // Create Test Price List
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(
            vlocity_cmt__Pricebook2Id__c = Test.getStandardPricebookId(),
            vlocity_cmt__IsActive__c = true,
            vlocity_cmt__Code__c = 'TestPricebook5'
        );
        insert pl1;
        
        // Create Test Opportunity
        Opportunity opp = new Opportunity(
            Name = 'EPC Deal AA',
            AccountId = testAccount.Id,
            vlocity_cmt__PriceListId__c = pl1.Id,
            CloseDate = System.today(),
            StageName = 'Initial',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert opp;
        
        // Create Test Quote
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
        
                QuoteLineItem  qouteLine1 = new QuoteLineItem (UnitPrice = 1, Quantity = 1, Product2Id = [select id from Product2 where Name = 'Test Product Root' Limit 1].Id,
                                                      vlocity_cmt__Product2Id__c = [select id from Product2 where Name = 'Test Product Root' Limit 1].Id,
                                                      QuoteId =qtest.Id, PricebookEntryId=testPricebookEntry1.Id,
                                                      vlocity_cmt__LineNumber__c = '0001');
        insert qouteLine1;
        ARTL_Feasibility__c feasibilityRecord = new ARTL_Feasibility__c(
            ARTL_QLI__c = qouteLine1.Id, 
            ARTL_Feasibility_ID__c = 'DSLWORK3010232833637', 
            ARTL_Feasibility_Status__c = 'Feasible'
        );
        insert feasibilityRecord;
        qouteLine1.ARTL_Feasibility__c = feasibilityRecord.Id;
        update qouteLine1;
        
        QuoteLineItem  qouteLine = new QuoteLineItem (UnitPrice = 1, Quantity = 1, Product2Id = [select id from Product2 where Name = 'Test Product' Limit 1].Id,
                                                      vlocity_cmt__Product2Id__c = [select id from Product2 where Name = 'Test Product' Limit 1].Id,
                                                      QuoteId =qtest.Id,ARTL_Feasibility__c = feasibilityRecord.Id,PricebookEntryId=testPricebookEntry.Id,
                                                      vlocity_cmt__LineNumber__c = '0001.0001');
        insert qouteLine;
        
        QuoteLineItem qouteLine2 = new QuoteLineItem(UnitPrice = 1, Quantity = 1, Product2Id = [select id from Product2 where Name = 'Test Product2' Limit 1].Id,
                                                     vlocity_cmt__Product2Id__c = [select id from Product2 where Name = 'Test Product2' Limit 1].Id,
                                                     QuoteId =qtest.Id,ARTL_Feasibility__c = feasibilityRecord.Id,PricebookEntryId=testPricebookEntry2.Id,
                                                     vlocity_cmt__LineNumber__c = '0001.0001.0001'
                                                    );
        insert qouteLine2;
        
        QuoteLineItem qouteLine3 = new QuoteLineItem(
            UnitPrice = 1,
            Quantity = 1,
            Product2Id = [select id from Product2 where Name = 'Test Product3' Limit 1].Id,
            vlocity_cmt__Product2Id__c = [select id from Product2 where Name = 'Test Product3' Limit 1].Id,
            QuoteId = qtest.Id,
            ARTL_Feasibility__c = feasibilityRecord.Id,
            PricebookEntryId = testPricebookEntry2.Id,
            vlocity_cmt__LineNumber__c = '0001.0002'
        );
        insert qouteLine3;
        
        QuoteLineItem qouteLine4 = new QuoteLineItem(
            UnitPrice = 1,
            Quantity = 1,
            Product2Id = [select id from Product2 where Name = 'Test Product4' Limit 1].Id,
            vlocity_cmt__Product2Id__c = [select id from Product2 where Name = 'Test Product4' Limit 1].Id,
            QuoteId = qtest.Id,
            ARTL_Feasibility__c = feasibilityRecord.Id,
            PricebookEntryId = testPricebookEntry4.Id,
            vlocity_cmt__LineNumber__c = '0001.0002.0001'
        );
        insert qouteLine4;
        
        // Create Test Order
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            QuoteId = qtest.Id,
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert testOrder;
        
                OrderItem testOrderItem1 = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = testPricebookEntry1.Id,
            Quantity = 1,
            UnitPrice = 10,
            QuoteLineItemId = qouteLine1.Id,
            vlocity_cmt__BillingAccountId__c = testAccount.Id,
            vlocity_cmt__LineNumber__c = '0001',
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_PLAN_SPEED": "SampleSpeedValue","ATT_ RSU": "SampleValue","ATT_STD_Code": "SampleValue2","ATT_MSU": "SampleValue3"}'
        );
        insert testOrderItem1;
        
        OrderItem testOrderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = testPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 10,
            QuoteLineItemId = qouteLine.Id,
            vlocity_cmt__BillingAccountId__c = testAccount.Id,
            vlocity_cmt__LineNumber__c = '0001.0001',
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_ RSU": "SampleValue","ATT_STD_Code": "SampleValue2","ATT_MSU": "SampleValue3"}'
        );
        insert testOrderItem;
        
        OrderItem testOrderItem2 = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = testPricebookEntry2.Id,
            Quantity = 1,
            UnitPrice = 10,
            QuoteLineItemId = qouteLine2.Id,
            vlocity_cmt__BillingAccountId__c = testAccount.Id,
            vlocity_cmt__LineNumber__c = '0001.0001.0001',
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_ RSU": "SampleValue","ATT_STD_Code": "SampleValue2","ATT_MSU": "SampleValue3"}'
        );
        insert testOrderItem2;
        
        OrderItem testOrderItem3 = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = testPricebookEntry3.Id,
            Quantity = 1,
            UnitPrice = 10,
            QuoteLineItemId = qouteLine3.Id,
            vlocity_cmt__BillingAccountId__c = testAccount.Id,
            vlocity_cmt__LineNumber__c = '0001.0002',
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_ RSU": "SampleValue","ATT_STD_Code": "SampleValue2","ATT_MSU": "SampleValue3"}'
        );
        insert testOrderItem3;
        
        OrderItem testOrderItem4 = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = testPricebookEntry4.Id,
            Quantity = 1,
            UnitPrice = 10,
            QuoteLineItemId = qouteLine4.Id,
            vlocity_cmt__BillingAccountId__c = testAccount.Id,
            vlocity_cmt__LineNumber__c = '0001.0002.0001',
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_ RSU": "SampleValue","ATT_STD_Code": "SampleValue2","ATT_MSU": "SampleValue3"}'
        );
        insert testOrderItem4;

        // Create Test ARTL Feasibility Line Item record
        ARTL_Feasibility_Line_Item__c LineItemRecord = new ARTL_Feasibility_Line_Item__c(
            ARTL_Feasibility__c = feasibilityRecord.Id,
            Name = 'wirelineNetworkElement'
        );
        insert LineItemRecord;
        
        // Create Test ARTL Feasibility Attribute record
        ARTL_Feasibility_Attribute__c attributeRecord = new ARTL_Feasibility_Attribute__c(
            ARTL_Feasibility__c = feasibilityRecord.Id,
            Name = 'rsuName',
            Value__c = 'TestRSU',
            ARTL_QLI__c = qouteLine1.Id,
            ARTL_Feasibility_Line_Item__c = LineItemRecord.Id
        );
        insert attributeRecord;
        
        ARTL_Feasibility_Attribute__c attributeRecord2 = new ARTL_Feasibility_Attribute__c(
            ARTL_Feasibility__c = feasibilityRecord.Id,
            Name = 'maxspeed',
            Value__c = '1024',
            ARTL_QLI__c = qouteLine1.Id,
            ARTL_Feasibility_Line_Item__c = LineItemRecord.Id
        );
        insert attributeRecord2;
        
        ARTL_Feasibility_Attribute__c attributeRecord3 = new ARTL_Feasibility_Attribute__c(
            ARTL_Feasibility__c = feasibilityRecord.Id,
            Name = 'maxspeedrsu',
            Value__c = '1024',
            ARTL_QLI__c = qouteLine1.Id,
            ARTL_Feasibility_Line_Item__c = LineItemRecord.Id
        );
        insert attributeRecord3;
        
        ARTL_Feasibility_Attribute__c attributeRecord4 = new ARTL_Feasibility_Attribute__c(
            ARTL_Feasibility__c = feasibilityRecord.Id,
            Name = 'maxspeedtechnology',
            Value__c = 'value1',
            ARTL_QLI__c = qouteLine1.Id,
            ARTL_Feasibility_Line_Item__c = LineItemRecord.Id
        );
        insert attributeRecord4;
        
        ARTL_Feasibility_Attribute__c attributeRecord5 = new ARTL_Feasibility_Attribute__c(
            ARTL_Feasibility__c = feasibilityRecord.Id,
            Name = 'city',
            Value__c = 'value2',
            ARTL_QLI__c = qouteLine1.Id,
            ARTL_Feasibility_Line_Item__c = LineItemRecord.Id
        );
        insert attributeRecord5;
        
        ARTL_Feasibility_Attribute__c attributeRecord6 = new ARTL_Feasibility_Attribute__c(
            ARTL_Feasibility__c = feasibilityRecord.Id,
            Name = 'technology',
            Value__c = 'value3',
            ARTL_QLI__c = qouteLine1.Id,
            ARTL_Feasibility_Line_Item__c = LineItemRecord.Id
        );
        insert attributeRecord6;
        
        // Create Test Fulfilment Request
        vlocity_cmt__FulfilmentRequest__c testFR = new vlocity_cmt__FulfilmentRequest__c(
            vlocity_cmt__OrderId__c = [select id from order Limit 1].Id,
            vlocity_cmt__AccountId__c = [select id from Account Limit 1].Id
        );
        insert testFR;
        
        vlocity_cmt__FulfilmentRequestLine__c testFRL = new vlocity_cmt__FulfilmentRequestLine__c(
            vlocity_cmt__Product2Id__c = [select id from Product2 where ProductCode = 'VEPC_AOI_Combo' Limit 1].Id,
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_ RSU": "SampleValue","ATT_STD_Code": "SampleValue2","ATT_MSU": "SampleValue3"}',
            vlocity_cmt__FulfilmentRequestID__c = [select id from vlocity_cmt__FulfilmentRequest__c Limit 1].Id
        );
        insert testFRL;
        testFRL.vlocity_cmt__LineNumber__c = testFRL.Id + '.0001';
        update testFRL;
        
        vlocity_cmt__FulfilmentRequestLine__c testFRL1 = new vlocity_cmt__FulfilmentRequestLine__c(
            vlocity_cmt__Product2Id__c = [select id from Product2 where Name = 'Test Product' Limit 1].Id,
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_ RSU": "SampleValue","ATT_STD_Code": "SampleValue2","ATT_MSU": "SampleValue3"}',
            vlocity_cmt__FulfilmentRequestID__c = [select id from vlocity_cmt__FulfilmentRequest__c Limit 1].Id,
            vlocity_cmt__LineNumber__c = testFRL.vlocity_cmt__LineNumber__c + '.0001',
            vlocity_cmt__MainOrderItemId__c = testFRL.Id
        );
        insert testFRL1;
        
        vlocity_cmt__FulfilmentRequestLine__c testFRL2 = new vlocity_cmt__FulfilmentRequestLine__c(
            vlocity_cmt__Product2Id__c = [select id from Product2 where Name = 'Test Product2' Limit 1].Id,
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_ RSU": "SampleValue","ATT_STD_Code": "SampleValue2","ATT_MSU": "SampleValue3"}',
            vlocity_cmt__FulfilmentRequestID__c = [select id from vlocity_cmt__FulfilmentRequest__c Limit 1].Id,
            vlocity_cmt__LineNumber__c = testFRL1.vlocity_cmt__LineNumber__c + '.0001',
            vlocity_cmt__MainOrderItemId__c = testFRL.Id
        );
        insert testFRL2;
        
        vlocity_cmt__FulfilmentRequestLine__c testFRL3 = new vlocity_cmt__FulfilmentRequestLine__c(
            vlocity_cmt__Product2Id__c = [select id from Product2 where Name = 'Test Product3' Limit 1].Id,
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_ RSU": "SampleValue","ATT_STD_Code": "SampleValue2","ATT_MSU": "SampleValue3"}',
            vlocity_cmt__FulfilmentRequestID__c = [select id from vlocity_cmt__FulfilmentRequest__c Limit 1].Id,
            vlocity_cmt__LineNumber__c = testFRL.vlocity_cmt__LineNumber__c + '.0002',
            vlocity_cmt__MainOrderItemId__c = testFRL.Id
        );
        insert testFRL3;
        
        vlocity_cmt__FulfilmentRequestLine__c testFRL4 = new vlocity_cmt__FulfilmentRequestLine__c(
            vlocity_cmt__Product2Id__c = [select id from Product2 where Name = 'Test Product4' Limit 1].Id,
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_ RSU": "SampleValue","ATT_STD_Code": "SampleValue2","ATT_MSU": "SampleValue3"}',
            vlocity_cmt__FulfilmentRequestID__c = [select id from vlocity_cmt__FulfilmentRequest__c Limit 1].Id,
            vlocity_cmt__LineNumber__c = testFRL3.vlocity_cmt__LineNumber__c + '.0001',
            vlocity_cmt__MainOrderItemId__c = testFRL.Id
        );
        insert testFRL4;
        
        // Create Test Orchestration Plan
        vlocity_cmt__OrchestrationPlan__c plan = new vlocity_cmt__OrchestrationPlan__c(vlocity_cmt__OrderId__c =[select id from order Limit 1].Id);
        insert plan;
        
        // Create Test Orchestration Plan Definition
        vlocity_cmt__OrchestrationPlanDefinition__c planDef = new vlocity_cmt__OrchestrationPlanDefinition__c();
        insert planDef;
        
        // Create Test Orchestration Item Definition
        vlocity_cmt__OrchestrationItemDefinition__c itemDef = new vlocity_cmt__OrchestrationItemDefinition__c(
            vlocity_cmt__orchestrationPlanDefinitionId__c = [select id from vlocity_cmt__OrchestrationPlanDefinition__c Limit 1].Id
        );
        insert itemDef;
        
        vlocity_cmt__OrchestrationItem__c item0 = new vlocity_cmt__OrchestrationItem__c(
            vlocity_cmt__OrchestrationPlanId__c = plan.Id,
            vlocity_cmt__OrderItemId__c = testOrderItem1.Id,
            vlocity_cmt__fulfilmentRequestLineId__c = testFRL.Id,
            vlocity_cmt__orchestrationItemDefinitionId__c = itemDef.Id,
            vlocity_cmt__State__c = 'Running',
            vlocity_cmt__orchestrationItemType__c = 'Auto Task',
            Name = 'Enrich attribute FRL'
        );
        insert item0;
        
        testFR.vlocity_cmt__orchestrationPlanId__c = plan.Id;
        update testFR;
        
        Test.startTest();
        Artel_EnrichAtrributeFromFeasibility enrichAttr = new Artel_EnrichAtrributeFromFeasibility();
        List<vlocity_cmt__OrchestrationItem__c> items = new List<vlocity_cmt__OrchestrationItem__c>();
        items.add(new vlocity_cmt__OrchestrationItem__c(Id = item0.Id));
        enrichAttr.executeBatch(items);
        Test.stopTest();
    }
}