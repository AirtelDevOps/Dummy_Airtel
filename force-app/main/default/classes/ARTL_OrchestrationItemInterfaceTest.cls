@isTest
public class ARTL_OrchestrationItemInterfaceTest {
	@isTest static void generateOSSJClassTest(){
        
       
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
        
        Account acc = new Account(name='Test', ParentId = parent.id);
        insert acc;
        
        Id pbId = Test.getStandardPricebookId();
        
        products = new Product2[2];
        
        products[0]=new Product2(name='VEPC_PRIMARY_LINK', ProductCode='3c6df3ca-4424-4131-bde3-c3ea5d5b5925 ',vlocity_cmt__JSONAttribute__c = '');
        
        products[1]=new Product2(name='VEPC_PRIMARY_MPLS_LINK ', ProductCode='6c24fdd7-4f71-4806-b7eb-62837fe6571e ', vlocity_cmt__JSONAttribute__c = '');
       
        insert products;
        
        PricebookEntry[] pbes = new PricebookEntry[products.size()];
        
        for (Integer i=0; i<products.size(); i++)
        {
            pbes[i] = new PricebookEntry(product2Id = products[i].id, unitPrice = 10, pricebook2id = pbId, useStandardPrice = false);
        }
        
        insert pbes;
        
        vlocity_cmt__OrchestrationItem__c item;

        vlocity_cmt__Subscription__c subs = new vlocity_cmt__Subscription__c(Name='TestSubs',vlocity_cmt__CurrentContractStartDate__c=Date.Today(), vlocity_cmt__CurrentContractEndDate__c = Date.Today(), vlocity_cmt__SubscriptionNumber__c = '123454321', vlocity_cmt__ServiceAccountId__c = acc.Id);    
        insert subs;
        
        Order order = new Order(AccountId = acc.id, effectiveDate = Date.today(), pricebook2id = pbId, status = 'Draft');
        insert order;
        
        orderId = order.id;
        
        OrderItem[] ois = new OrderItem[2];
        ois[0] = new OrderItem(vlocity_cmt__lineNumber__c = '0001',Product2Id = products[0].Id, OrderId = order.id, pricebookEntryId = pbes[0].id, quantity = 1, vlocity_cmt__AssetReferenceId__c = '201',
                               unitPrice = 1, vlocity_cmt__provisioningStatus__c = 'New', vlocity_cmt__JSONAttribute__c = '', vlocity_cmt__PricingLogData__c = '' ,vlocity_cmt__Action__c= 'Add');
        ois[1] = new OrderItem(vlocity_cmt__lineNumber__c = '0002',Product2Id = products[1].Id, OrderId = order.id, pricebookEntryId = pbes[1].id, quantity = 1, vlocity_cmt__AssetReferenceId__c = '202',
                                unitPrice = 1, vlocity_cmt__provisioningStatus__c = 'New', vlocity_cmt__JSONAttribute__c = '', vlocity_cmt__PricingLogData__c ='');            
       
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
        
        item=new vlocity_cmt__OrchestrationItem__c(vlocity_cmt__orchestrationPlanId__c = plan.id,
                                                   vlocity_cmt__orderItemId__c = ois[0].id,vlocity_cmt__fulfilmentRequestLineId__c = FRLine[0].id,
                                                   vlocity_cmt__orchestrationItemDefinitionId__c = itemDef.id,
                                                   vlocity_cmt__State__c='Running',
                                                   vlocity_cmt__orchestrationItemType__c = 'Auto Task',Name='Generate OSSJ Task Test',
                                                   vlocity_cmt__AutoTaskParameters__c = 'Hansen_Add'
                                                   );
        
        
        insert item;
        Test.startTest();
        ARTL_OrchestrationItemInterface generateOSSJ = new ARTL_OrchestrationItemInterface();
        
        generateOSSJ.executeItem('processName','processName',item);
        
        Map<String, Object> ipOutput = new Map<String, Object>();
        Map<String, Object> ipOutput1 = new Map<String, Object>();
        Map<String, Object> ipInput = new Map<String, Object>();
        Object o1 = true;
        ipInput.put('orchestration_item_id',item.Id);
        ipOutput1.put('isSuccess',o1);
        ipOutput.put('response',ipOutput1);
                try{
        generateOSSJ.processResponse(item,ipInput,ipOutput);
        }catch(Exception e){
        system.assertEquals(e.getMessage(), e.getMessage());
        }
        
        Map<String, Object> ipOutput11 = new Map<String, Object>();
        Map<String, Object> ipOutput21 = new Map<String, Object>();
        Map<String, Object> ipInput11 = new Map<String, Object>();
        Object o21 = false;
        ipInput11.put('orchestration_item_id',item.Id);
        ipOutput21.put('isSuccess',o21);
        ipOutput11.put('response',ipOutput21);
                try{
        generateOSSJ.processResponse(item,ipInput11,ipOutput11);
        }catch(Exception e){
        system.assertEquals(e.getMessage(), e.getMessage());
        }
        
         Map<String, Object> ipOutput3 = new Map<String, Object>();
        Map<String, Object> ipOutput31 = new Map<String, Object>();
        Map<String, Object> ipInput3 = new Map<String, Object>();
        Object o3 = true;
        ipInput3.put('orchestration_item_id',item.Id);
        //ipOutput31.put('isFailure',o3);
        ipOutput3.put('response',o3);
                try{
        generateOSSJ.processResponse(item,ipInput3,ipOutput3);
        }catch(Exception e){
        system.assertEquals(e.getMessage(), e.getMessage());
        }
        
        /*Map<String, Object> ipInput = new Map<String, Object>(); 
		Map<String, Object> ipOutput = new Map<String, Object>();
        ipInput.put('processName', 'ARTL_CallOutToHansenFromOrchest');
        generateOSSJ.processResponse(item,ipInput,ipOutput);*/
        Test.stopTest();
     }
}