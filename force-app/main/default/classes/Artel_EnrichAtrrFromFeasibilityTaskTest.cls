@isTest
global with sharing class Artel_EnrichAtrrFromFeasibilityTaskTest {
    
    @isTest static void enrichAttrFRLTest(){
        
        
        Id[] oiIds;
        Id orderId;
        Id[] FRLineIds;
        Id FRId;
        Product2[] products;
        
        vlocity_cmt__OrchestrationPlan__c plan = new vlocity_cmt__OrchestrationPlan__c();
        insert plan;
        
        vlocity_cmt__OrchestrationPlanDefinition__c planDef = new vlocity_cmt__OrchestrationPlanDefinition__c();
        insert planDef;
        
        vlocity_cmt__OrchestrationItemDefinition__c itemDef = new vlocity_cmt__OrchestrationItemDefinition__c(
            vlocity_cmt__orchestrationPlanDefinitionId__c = planDef.id);
        insert itemDef;
        
        Account grandParent = new Account(name='GrandparentTest');
        insert grandParent;
        
        Account parent = new Account(name='ParentTest', ParentId = grandParent.id);
        insert parent;
        
        Account acc = new Account(name='Test', ParentId = parent.id);
        insert acc;
        
        Id pbId = Test.getStandardPricebookId();
        
        products = new Product2[2];
        
        products[0]=new Product2(name='VEPC_PRIMARY_LINK', ProductCode='VEPC_PRIMARY_LINK ',vlocity_cmt__JSONAttribute__c = '');
        
        products[1]=new Product2(name='VEPC_PRIMARY_MPLS_LINK ', ProductCode='VEPC_PRIMARY_MPLS_LINK ', vlocity_cmt__JSONAttribute__c = '');
        
        insert products;
        
        PricebookEntry[] pbes = new PricebookEntry[products.size()];
        
        for (Integer i=0; i<products.size(); i++)
        {
            pbes[i] = new PricebookEntry(product2Id = products[i].id,IsActive=true, unitPrice = 10, pricebook2id = pbId, useStandardPrice = false);
        }
        
        insert pbes;
        
        
        vlocity_cmt__Subscription__c subs = new vlocity_cmt__Subscription__c(Name='TestSubs',vlocity_cmt__CurrentContractStartDate__c=Date.Today(), vlocity_cmt__CurrentContractEndDate__c = Date.Today(), vlocity_cmt__SubscriptionNumber__c = '123454321', vlocity_cmt__ServiceAccountId__c = acc.Id);    
        insert subs;
        //Id pbId = Test.getStandardPricebookId();
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
        vlocity_cmt__QuoteMember__c qM = new vlocity_cmt__QuoteMember__c();
        qM.Name = 'TestQuoteMembers';
        qM.vlocity_cmt__QuoteId__c = qtest.Id;
        qM.vlocity_cmt__ServiceabilityData__c = '{ "feasibilityId" : "DSLWORK3010232833637", "encryptedFeasibilityId" : "eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJEU0xXT1JLMzAxMDIzMjgzMzYzNyIsImlhdCI6MTY5ODY0OTkzOSwiZXhwIjoxNjk4NjY3OTM5fQ.DZIC8GK97AsG0gmKZccsEy3J7gSEUTOGVKvH_FKqtJ_C3u6lk9JE8yjIWFKIksXerJAPUXa-0bB6G1BaMFPLUg", "requestId" : "41-74898700702", "source" : "AIRTEL_WORK", "address" : { "_id" : "HR_MUMBAI_NB_5191", "originalAddressString" : "Satra Plaza , Vashi , MUMBAI", "addressString" : "Satra Plaza , Vashi , MUMBAI", "state" : "Maharashtra", "city" : "Mumbai", "pincode" : "400703", "latitude" : "19.0827", "longitude" : "73.00607", "townType" : "ANG", "highRise" : false, "errorMargin" : "0", "popCode" : "MUM/WIW/901", "popAddress" : "Bharti Airtel Limited , Ground , Pokhran Road Number 2,Opp. Maitri Garden Near Oswal Park,Thane-West , , MUMBAI - MUM , 400601 , MAHARASHTRA India ", "tngPopCode" : "MUM/MLD/189", "tngPopAddress" : "Bharti Airtel Limited , 4th Dim 4th , Mind Space,Link Road Near Toyota Showroom,Mumbai , MALAD(WEST) - MLD, MUMBAI - MUM , 400064 , MAHARASHTRA India", "primaryText" : "Satra Plaza", "secondaryText" : "Vashi, MUMBAI" }, "wirelineNetworkElement" : { "name" : "CAV03020301", "rsu" : "MUM/CAV/901", "rsuName" : "CAV", "spareTags" : "1", "maxspeed" : "1024", "category" : "NEF_HIGH_RISE", "latitude" : 19.0827, "longitude" : 73.00607, "aerialDistanceFromSite" : 0.0, "requestMatchingType" : "POOR", "technology" : "FTTH Own", "matchScore" : 20, "m6Code" : "MUM/CAV/901", "media" : "FTTH", "maxBandwidth" : "1024", "address" : "Satra Plaza (FAT 11/GND Flr):-58,59,60,61,62,63,64,65,66,", "isBestNe" : false, "cityType" : "Airtel-own", "city" : "MUMBAI", "type" : "S_OBD", "hubdistance" : "310.0", "neStatus" : "In Service", "localOperatorId" : "Airtel-own" }, "humanInterventionRequired" : false, "maxBandwidth" : 1024, "requestedBandwidth" : 2, "feasibleAtRequestedBandwidth" : true, "feasibilityType" : [ "WIRELINE" ], "feasibilityStatus" : "FEASIBLE", "feasibilitySubStatus" : { "WIRELINE" : "FEASIBLE" }, "interfaces" : "10 Gig(Optical)", "feasibilityConfidence" : "SELECTED_NE_AS_INPUT", "thirdPartyProviderList" : [], "airtelFeasibilityFound" : true, "intermediateResponse" : false, "dualLastMile" : false, "numberOfE1" : 0, "numberOfChannel" : 0, "product" : "DSL", "addressResolutionConfidence" : "HIGH", "lcoTown" : "false", "manualFeasibilityReason" : [], "testAccount" : "false", "requestCreateDate" : ISODate("2023-10-30T07:12:19.563Z"), "requestClosedDate" : ISODate("2023-10-30T07:12:19.585Z"), "modifiedDate" : ISODate("2023-10-30T07:12:19.585Z") }';
        insert qM;
        
        QuoteLineItem  qouteLine = new QuoteLineItem ();
        qouteLine.UnitPrice = 1;
        qouteLine.Quantity = 1;
        qouteLine.Product2Id = products[0].Id;
        qouteLine.vlocity_cmt__Product2Id__c = products[0].Id;
        qouteLine.QuoteId =qtest.Id;
        qouteLine.PricebookEntryId=pbes[0].Id;
        qouteLine.vlocity_cmt__QuoteMemberId__c = qM.Id;
        insert qouteLine;
        
        Order order = new Order(AccountId = acc.id, effectiveDate = Date.today(), pricebook2id = pbId, status = 'Draft');
        insert order;
        
        orderId = order.id;
        
        OrderItem[] ois = new OrderItem[2];
        ois[0] = new OrderItem(vlocity_cmt__lineNumber__c = '0001',Product2Id = products[0].Id, OrderId = order.id, pricebookEntryId = pbes[0].id, quantity = 1, vlocity_cmt__AssetReferenceId__c = '201',
                               ARTL_QuoteLineItemId__c=qouteLine.Id,unitPrice = 1, vlocity_cmt__provisioningStatus__c = 'New', vlocity_cmt__JSONAttribute__c = '', vlocity_cmt__PricingLogData__c = '' ,vlocity_cmt__Action__c= 'Add');
        ois[1] = new OrderItem(vlocity_cmt__lineNumber__c = '0002',Product2Id = products[1].Id, OrderId = order.id, pricebookEntryId = pbes[1].id, quantity = 1, vlocity_cmt__AssetReferenceId__c = '202',
                               ARTL_QuoteLineItemId__c=qouteLine.Id,unitPrice = 1, vlocity_cmt__provisioningStatus__c = 'New', vlocity_cmt__JSONAttribute__c = '', vlocity_cmt__PricingLogData__c ='');            
        
        insert ois;
        
        oiIds = new List<Id>();
        
        for (OrderItem oi: ois)
        {
            oiIds.add (oi.id);
        }
        
        plan.vlocity_cmt__OrderId__c = orderId;
        update plan;
        
        vlocity_cmt__fulfilmentRequest__c FR = new vlocity_cmt__FulfilmentRequest__c(vlocity_cmt__accountId__c = acc.id);
        insert FR;
        
        FRId = FR.id;
        
        vlocity_cmt__FulfilmentRequestLine__c[] FRLine = new vlocity_cmt__FulfilmentRequestLine__c[2];
        
        FRLine[0] = new vlocity_cmt__FulfilmentRequestLine__c(vlocity_cmt__lineNumber__c = '0001', vlocity_cmt__product2Id__c = products[0].id,
                                                              vlocity_cmt__fulfilmentRequestId__c = FR.id, vlocity_cmt__action__c = 'Add', vlocity_cmt__JSONAttribute__c = '');
        FRLine[1] = new vlocity_cmt__FulfilmentRequestLine__c(vlocity_cmt__lineNumber__c = '0002', vlocity_cmt__product2Id__c = products[1].id,
                                                              vlocity_cmt__fulfilmentRequestId__c = FR.id, vlocity_cmt__action__c = 'Add', vlocity_cmt__JSONAttribute__c = '');                                                     
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
        
        List <vlocity_cmt__OrchestrationItem__c> items1 = new List<vlocity_cmt__OrchestrationItem__c>();
        vlocity_cmt__OrchestrationItem__c item = new vlocity_cmt__OrchestrationItem__c(vlocity_cmt__orchestrationPlanId__c = plan.id,
                                                                                       vlocity_cmt__OrderItemId__c = ois[0].id,
                                                                                       vlocity_cmt__fulfilmentRequestLineId__c = FRLine[0].id,
                                                                                       vlocity_cmt__orchestrationItemDefinitionId__c = itemDef.id,
                                                                                       vlocity_cmt__State__c='Running',
                                                                                       vlocity_cmt__orchestrationItemType__c = 'Auto Task',
                                                                                       Name='Enrich attribute FRL');
        
        items1.add(item);
        insert items1;       
        
        Test.startTest();
        Artel_EnrichAtrrFromFeasibilityTask enrichAttr = new Artel_EnrichAtrrFromFeasibilityTask();        
        enrichAttr.executeBatch(items1);
        Test.stopTest();
    }
}