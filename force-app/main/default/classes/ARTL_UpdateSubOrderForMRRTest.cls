@isTest
public class ARTL_UpdateSubOrderForMRRTest {
	 @isTest
    public static void testIntegrationMethod() {
        
       
            Id[] oiIds;
            Id orderId;
            Id[] FRLineIds;
            Id FRId;
            Product2[] products;
        vlocity_cmt__OrchestrationPlan__c plan = new vlocity_cmt__OrchestrationPlan__c();
        insert plan;
        
        vlocity_cmt__OrchestrationPlanDefinition__c planDef = new vlocity_cmt__OrchestrationPlanDefinition__c();
        insert planDef;
        
        vlocity_cmt__OrchestrationItemDefinition__c itemDef = new vlocity_cmt__OrchestrationItemDefinition__c(vlocity_cmt__orchestrationPlanDefinitionId__c = planDef.id
                                                                                                              );
        insert itemDef;
        
        Account grandParent = new Account(name='GrandparentTest');
        insert grandParent;
        
        Account parent = new Account(name='ParentTest', ParentId = grandParent.id);
        insert parent;
        
        Account acc = new Account(name='Test', ParentId = parent.id, ARTL_Business_Unit__c='EGB');
        insert acc;
        
        Id pbId = Test.getStandardPricebookId();
        
        products = new Product2[2];
        
        products[0]=new Product2(name='NIPS HARDWARE CFS', ProductCode='VEPC_NIPS_HARDWARE_CFS ',vlocity_cmt__JSONAttribute__c = '');
        
        products[1]=new Product2(name='NIPS COMPOSITE CFS ', ProductCode='VEPC_NIPS_COMPOSITE_CFS ', vlocity_cmt__JSONAttribute__c = '');
       
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
        Order order = new Order(AccountId = acc.id, effectiveDate = Date.today(), pricebook2id = pbId, status = 'Draft',vlocity_cmt__QuoteId__c = qtest.Id ,QuoteId = qtest.Id,ARTL_Root_ProductCode__c='Internet');
        insert order;
        Order order1 = new Order(AccountId = acc.id, effectiveDate = Date.today(), pricebook2id = pbId, status = 'Draft',vlocity_cmt__QuoteId__c = qtest.Id ,QuoteId = qtest.Id,ARTL_Root_ProductCode__c='Internet',vlocity_cmt__OrderStatus__c='In Progress',vlocity_cmt__ParentOrderId__c = order.id);
        insert order1;
        orderId = order.id;
        
        OrderItem[] ois = new OrderItem[2];
        ois[0] = new OrderItem(vlocity_cmt__lineNumber__c = '0001',Product2Id = products[0].Id, OrderId = order.id, pricebookEntryId = pbes[0].id, quantity = 1, vlocity_cmt__AssetReferenceId__c = '201',ARTL_ItemCode__c = '12345668',
                               ARTL_QuoteLineItemId__c=qouteLine.Id ,unitPrice = 1, vlocity_cmt__provisioningStatus__c = 'New', vlocity_cmt__JSONAttribute__c = '', vlocity_cmt__PricingLogData__c = '' ,vlocity_cmt__Action__c= 'Add');
        ois[1] = new OrderItem(vlocity_cmt__lineNumber__c = '0002',Product2Id = products[1].Id, OrderId = order.id, pricebookEntryId = pbes[1].id, quantity = 1, vlocity_cmt__AssetReferenceId__c = '202',ARTL_ItemCode__c = '12345668',
                                ARTL_QuoteLineItemId__c=qouteLine.Id,unitPrice = 1, vlocity_cmt__provisioningStatus__c = 'New', vlocity_cmt__JSONAttribute__c = '', vlocity_cmt__PricingLogData__c ='');            
       
        insert ois;
        
        oiIds = new List<Id>();
        
        for (OrderItem oi: ois)
        {
            oiIds.add (oi.id);
        }
        
        plan.vlocity_cmt__OrderId__c = orderId;
        update plan;
        
        vlocity_cmt__fulfilmentRequest__c FR = new vlocity_cmt__FulfilmentRequest__c(vlocity_cmt__accountId__c = acc.id, vlocity_cmt__OrderId__c = order1.Id);
        insert FR;
        
        FRId = FR.id;
        
        vlocity_cmt__FulfilmentRequestLine__c[] FRLine = new vlocity_cmt__FulfilmentRequestLine__c[2];
        
        FRLine[0] = new vlocity_cmt__FulfilmentRequestLine__c(vlocity_cmt__lineNumber__c = '0001', vlocity_cmt__product2Id__c = products[0].id,
                                                              vlocity_cmt__fulfilmentRequestId__c = FR.id, vlocity_cmt__action__c = 'Add', vlocity_cmt__JSONAttribute__c = '',vlocity_cmt__AttributeSelectedValues__c = '{"ATT_SUPPLIER_NAME":"45 Mbps","ATT_SUPPLIER_ADDRESS":"Partially Managed","ATT_MEDIA":null,"ATT_INTERFACE":null}');
        FRLine[1] = new vlocity_cmt__FulfilmentRequestLine__c(vlocity_cmt__lineNumber__c = '0002', vlocity_cmt__product2Id__c = products[1].id,
                                                              vlocity_cmt__fulfilmentRequestId__c = FR.id, vlocity_cmt__action__c = 'Add', vlocity_cmt__JSONAttribute__c = '',vlocity_cmt__AttributeSelectedValues__c = '{"ATT_VENDOR_PO_NUMBER":"45 Mbps","ATT_VENDOR_PR_NUMBER":"Partially Managed","ATT_VENDOR_NAME":null,"ATT_INTERFACE":null}');                                                     
        insert FRLine;
        
        vlocity_cmt__FulfilmentRequestLineDecompRelationship__c[] DecompRel = new vlocity_cmt__FulfilmentRequestLineDecompRelationship__c[2];
        
        DecompRel[0] = new vlocity_cmt__FulfilmentRequestLineDecompRelationship__c(Name = 'DecompRel1',vlocity_cmt__DestinationFulfilmentRequestLineId__c = FRLine[0].Id, vlocity_cmt__SourceOrderItemId__c = ois[0].Id);
        
         DecompRel[1] = new vlocity_cmt__FulfilmentRequestLineDecompRelationship__c(Name = 'DecompRel12',vlocity_cmt__DestinationFulfilmentRequestLineId__c = FRLine[1].Id, vlocity_cmt__SourceOrderItemId__c = ois[1].Id);
        
        insert DecompRel;
        
        
        FRLineIds = new List<Id>();
        
        for (vlocity_cmt__FulfilmentRequestLine__c FRI: FRLine)
        {
            FRLineIds.add (FRI.id);
        }
        
        item=new vlocity_cmt__OrchestrationItem__c(vlocity_cmt__orchestrationPlanId__c = plan.id,
                                                   vlocity_cmt__orderItemId__c = ois[0].id,vlocity_cmt__fulfilmentRequestLineId__c = FRLine[0].id,
                                                   vlocity_cmt__orchestrationItemDefinitionId__c = itemDef.id,
                                                   vlocity_cmt__State__c='Running',
                                                   vlocity_cmt__orchestrationItemType__c = 'Auto Task',Name='Generate OSSJ Task Test');
        
        
        insert item;
        List<ARTL_Purchase_Request__c> pRTestList = new List<ARTL_Purchase_Request__c>();
        ARTL_Purchase_Request__c pRTest = new ARTL_Purchase_Request__c();
        pRTest.Requisition_Number__c = '12345';
        pRTest.Master_Order__c = orderId;
        pRTest.Item_Code__c= '12345668';
        pRTest.Quote_Line_Item__c = [select Id from QuoteLineItem limit 1].Id;
        pRTestList.add(pRTest);
        insert pRTestList;
         List<Purchase_Order__c> pOTestList = new List<Purchase_Order__c>();
        Purchase_Order__c pOTest = new Purchase_Order__c();
        pOTest.PRID__c = pRTest.Id;
        pOTest.MasterOrder__c = orderId;
        pOTest.PONumber__c = 'B12345';
        pOTest.ItemCode__c = '12345668';
        pOTestList.add(pOTest);
        insert pOTestList;
        Material_Received_Request__c mrr = new Material_Received_Request__c();
        mrr.ItemCode__c = '12345668';
        mrr.MRRNumber__c = '1234';
        mrr.Master_Order__c = orderId;
        insert mrr;
        ARTL_CreateTaskForNIPS.UpdateSubOrderInput NewObject = new ARTL_CreateTaskForNIPS.UpdateSubOrderInput();
        List < ARTL_CreateTaskForNIPS.UpdateSubOrderInput > testinput = new List < ARTL_CreateTaskForNIPS.UpdateSubOrderInput >();
        NewObject.MrrId = mrr.Id;
        testinput.add(NewObject);
        Test.startTest();
        ARTL_CreateTaskForNIPS.updateOLIforMRR(testinput);
 		Test.stopTest();
    }
}