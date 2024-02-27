@isTest
public class ARTLOMCreateExternalDepTest {
    
    @isTest static void testExceuteItem(){
        
        
        Id[] oiIds;
        Id orderId;
        Id[] FRLineIds;
        Id FRId;
        Product2[] products;
        vlocity_cmt__OrchestrationPlan__c plan = new vlocity_cmt__OrchestrationPlan__c();
        insert plan;
        
        vlocity_cmt__OrchestrationPlanDefinition__c planDef = new vlocity_cmt__OrchestrationPlanDefinition__c();
        insert planDef;
        
        vlocity_cmt__OrchestrationItemDefinition__c itemDef = new vlocity_cmt__OrchestrationItemDefinition__c(vlocity_cmt__orchestrationPlanDefinitionId__c = planDef.id, vlocity_cmt__GlobalKey__c='df7d8d38-f037-3978-af07-a61ad47f2eec'                                                                                                             );
        vlocity_cmt__OrchestrationItemDefinition__c itemDef1 = new vlocity_cmt__OrchestrationItemDefinition__c(vlocity_cmt__orchestrationPlanDefinitionId__c = planDef.id, vlocity_cmt__GlobalKey__c='d26c1b6d-a570-1ca9-9c55-17021c2a995c');
        List<vlocity_cmt__OrchestrationItemDefinition__c> lstOID = new List<vlocity_cmt__OrchestrationItemDefinition__c>();
        lstOID.add(itemDef);
        lstOID.add(itemDef1);
        insert lstOID;
        
        Account grandParent = new Account(name='GrandparentTest');
        insert grandParent;
        
        Account parent = new Account(name='ParentTest', ParentId = grandParent.id);
        insert parent;
        
        Account acc = new Account(name='Test', ParentId = parent.id, ARTL_Business_Unit__c='EGB');
        insert acc;
        
        Id pbId = Test.getStandardPricebookId();
        
        products = new Product2[2];
        
        products[0]=new Product2(name='Internet_on_NIPS_Hardware', ProductCode='3c6df3ca-4424-4131-bde3-c3ea5d5b5925',vlocity_cmt__JSONAttribute__c = '');
        
        products[1]=new Product2(name='MPLS_on_NIPS_Hardware', ProductCode='dac49a09-9b41-4999-b7c4-cf6319ad5b44', vlocity_cmt__JSONAttribute__c = '');
        
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
        
        Order parentOrder = new Order(AccountId = acc.id, effectiveDate = Date.today(), pricebook2id = pbId, status = 'Draft',vlocity_cmt__QuoteId__c = qtest.Id ,QuoteId = qtest.Id);
        insert parentOrder;
        
        Order order = new Order(AccountId = acc.id, effectiveDate = Date.today(), pricebook2id = pbId, status = 'Draft',vlocity_cmt__QuoteId__c = qtest.Id ,QuoteId = qtest.Id, Order_with_ReliesOn__c = parentOrder.Id);
        insert order;
        
        orderId = order.id;
        
        OrderItem[] ois = new OrderItem[2];
        ois[0] = new OrderItem(vlocity_cmt__lineNumber__c = '0001',Product2Id = products[0].Id, OrderId = order.id, pricebookEntryId = pbes[0].id, quantity = 1, vlocity_cmt__AssetReferenceId__c = '201',
                               ARTL_QuoteLineItemId__c=qouteLine.Id ,unitPrice = 1, vlocity_cmt__provisioningStatus__c = 'New', vlocity_cmt__JSONAttribute__c = '', vlocity_cmt__PricingLogData__c = '' ,vlocity_cmt__Action__c= 'Add');
        ois[1] = new OrderItem(vlocity_cmt__lineNumber__c = '0002',Product2Id = products[1].Id, OrderId = order.id, pricebookEntryId = pbes[1].id, quantity = 1, vlocity_cmt__AssetReferenceId__c = '202',
                               ARTL_QuoteLineItemId__c=qouteLine.Id,unitPrice = 1, vlocity_cmt__provisioningStatus__c = 'New', vlocity_cmt__JSONAttribute__c = '', vlocity_cmt__PricingLogData__c ='');            
        
        insert ois;
        
        
        vlocity_cmt__OrderItemRelationship__c oir = new vlocity_cmt__OrderItemRelationship__c(vlocity_cmt__OrderItemId__c = ois[0].id,vlocity_cmt__RelatedOrderItemId__c = ois[1].id, vlocity_cmt__OrderId__c=order.id);
        insert oir;
        oiIds = new List<Id>();
        
        for (OrderItem oi: ois)
        {
            oiIds.add (oi.id);
        }
        
        plan.vlocity_cmt__OrderId__c = orderId;
        update plan;
        
        vlocity_cmt__fulfilmentRequest__c FR = new vlocity_cmt__FulfilmentRequest__c(vlocity_cmt__accountId__c = acc.id, vlocity_cmt__OrderId__c = orderId);
        insert FR;
        
        FRId = FR.id;
        
        vlocity_cmt__FulfilmentRequestLine__c[] FRLine = new vlocity_cmt__FulfilmentRequestLine__c[2];
        
        FRLine[0] = new vlocity_cmt__FulfilmentRequestLine__c(vlocity_cmt__lineNumber__c = '0001', vlocity_cmt__product2Id__c = products[0].id,
                                                              vlocity_cmt__fulfilmentRequestId__c = FR.id, vlocity_cmt__action__c = 'Add', vlocity_cmt__JSONAttribute__c = '',vlocity_cmt__AttributeSelectedValues__c = '{"ATT_TECH_ACCESS_BANDWIDTH":"45 Mbps","ATT_TECH_SERVICE_TYPE":"Partially Managed","ATT_MEDIA":null,"ATT_INTERFACE":null}');
        FRLine[1] = new vlocity_cmt__FulfilmentRequestLine__c(vlocity_cmt__lineNumber__c = '0002', vlocity_cmt__product2Id__c = products[1].id,
                                                              vlocity_cmt__fulfilmentRequestId__c = FR.id, vlocity_cmt__action__c = 'Add', vlocity_cmt__JSONAttribute__c = '',vlocity_cmt__AttributeSelectedValues__c = '{"ATT_TECH_ACCESS_BANDWIDTH":"45 Mbps","ATT_TECH_SERVICE_TYPE":"Partially Managed","ATT_MEDIA":null,"ATT_INTERFACE":null}');                                                     
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
        
        item=new vlocity_cmt__OrchestrationItem__c(vlocity_cmt__OrchestrationPlanId__c = plan.id,
                                                   vlocity_cmt__orderItemId__c = ois[0].id,vlocity_cmt__fulfilmentRequestLineId__c = FRLine[0].id,
                                                   vlocity_cmt__orchestrationItemDefinitionId__c = lstOID[0].id,
                                                   vlocity_cmt__State__c='Running',
                                                   vlocity_cmt__orchestrationItemType__c = 'Auto Task',Name='Generate OSSJ Task Test');
        
        vlocity_cmt__OrchestrationItem__c item1=new vlocity_cmt__OrchestrationItem__c(vlocity_cmt__OrchestrationPlanId__c = plan.id,
                                                   vlocity_cmt__orderItemId__c = ois[0].id,vlocity_cmt__fulfilmentRequestLineId__c = FRLine[0].id,
                                                   vlocity_cmt__orchestrationItemDefinitionId__c = lstOID[1].id,
                                                   vlocity_cmt__State__c='Running',
                                                   vlocity_cmt__orchestrationItemType__c = 'Auto Task',Name='Generate OSSJ Task Test');
        
        List <vlocity_cmt__OrchestrationItem__c> items1 = new List<vlocity_cmt__OrchestrationItem__c>();
        items1.add(item);
        items1.add(item1);
        insert items1;        
        
        vlocity_cmt__OrchestrationDependencyDefinition__c tempODD = new vlocity_cmt__OrchestrationDependencyDefinition__c(vlocity_cmt__OrchestrationItemDefinitionId__c=lstOID[0].Id, vlocity_cmt__DependencyItemDefinitionId__c=lstOID[1].Id, vlocity_cmt__GlobalKey__c='cce7ea47-8db3-140f-a3ba-d939d7021db8');
        insert tempODD;
        
        parentOrder.vlocity_cmt__OrchestrationPlanId__c = plan.Id;
        update parentOrder;
        
        Test.startTest();
        List<ARTL_Dynamic_Dependency__mdt> tempList = [Select Id,DeveloperName, Dependency__c, Dependent_Item__c, Item__c  
                                                       FROM ARTL_Dynamic_Dependency__mdt 
                                                       WHERE ARTL_Product_Code__c='3c6df3ca-4424-4131-bde3-c3ea5d5b5925' AND 
                                                       ARTL_Related_Product_Code__c= 'dac49a09-9b41-4999-b7c4-cf6319ad5b44'];
        
        /*ARTL_Dynamic_Dependency__mdt dyna = new ARTL_Dynamic_Dependency__mdt();
        dyna.DeveloperName='Internet_on_NIPS_Hardware';
        dyna.Dependency__c='cce7ea47-8db3-140f-a3ba-d939d7021db8';
        dyna.Dependent_Item__c ='d26c1b6d-a570-1ca9-9c55-17021c2a995c'; 
        dyna.Item__c = 'df7d8d38-f037-3978-af07-a61ad47f2eec';
        dyna.ARTL_Related_Product_Code__c = 'dac49a09-9b41-4999-b7c4-cf6319ad5b44';
        dyna.ARTL_Product_Code__c ='3c6df3ca-4424-4131-bde3-c3ea5d5b5925';
        insert dyna;*/   
        
        ARTLOMCreateExternalDep xmObj=new ARTLOMCreateExternalDep();
        xmObj.executeBatch(items1);
        Test.stopTest();
    }
}