@isTest
private class ARTL_MPLS4GControllerTest {
    
    @testSetup static void setup() {
        
        Id pbId = Test.getStandardPricebookId();
        Id recTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        
        Account acc = new Account(Name = 'Test Business Account', 
                                  RecordTypeId = recTypeId1,
                                  //BillingLatitude = 38.8951, 
                                  //BillingLongitude = -77.0364
                                  BillingCity = 'Panchkula',
                                  BillingCountry = 'Haryana',
                                  BillingPostalCode = '134109',
                                  BillingState = 'India',
                                  BillingStreet = 'Panchkula', 
                                  ARTL_IntegrationId__c = 'test', 
                                  ARTL_Category__c = 'A', 
                                  ARTL_Customer_Segment__c = 'AB',
                                  ARTL_Service_Segment__c = 'BD',
                                  ARTL_Vertical_Segment__c = 'BFI',
                                  ARTL_Business_Circle_Region__c = 'AP',
                                  ARTL_PAN__c = 'ABCDE1234F');
        insert acc;
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Account serviceAccount = new Account(Name = 'Service Account');
        insert serviceAccount;

        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today()+1;
        opp.StageName = 'Qualification';
        opp.currencyIsoCode = 'INR';
        opp.Pricebook2Id = pbId; 
        insert opp;
        
        //Creating Target & Source Orders               
        List<Order> orderList = new List<Order>();
        Order targetOrder = new Order();
        targetOrder.name = 'Target Order';
        targetOrder.AccountId = acc.Id;
        targetOrder.Pricebook2Id = pbId;
        targetOrder.status = 'Draft';
        targetOrder.vlocity_cmt__OrderStatus__c = 'In Progress';
        targetOrder.EffectiveDate=System.today();                
        orderList.add(targetOrder);
        
        Order sourceOrder = new Order();
        sourceOrder.name = 'Source Order';
        sourceOrder.AccountId = acc.Id;
        sourceOrder.Pricebook2Id = pbId;
        sourceOrder.status = 'Draft';
        sourceOrder.vlocity_cmt__OrderStatus__c = 'In Progress';
        sourceOrder.EffectiveDate=System.today();
        orderList.add(sourceOrder);
        insert orderList;
       
        // Creating Commercial & Technical Products
        List<Product2> prodList = new List<Product2>();
        
        Product2 testCommProd1 = new Product2();
        testCommProd1.name = 'Test Commercial Product1';
        testCommProd1.vlocity_cmt__SpecificationType__c = 'Product';
        testCommProd1.productcode = 'c28fb5dd-d072-4c1c-b7da-80046db82cf0';
        testCommProd1.vlocity_cmt__IsOrderable__c = true;
        prodList.add(testCommProd1);
        
        Product2 testCommProd2 = new Product2();
        testCommProd2.name = 'Test Commercial Product2';
        testCommProd2.vlocity_cmt__SpecificationType__c = 'Product';
        testCommProd2.productcode = 'c9958738-b03b-4ca7-b122-d732cf1e0f40';
        testCommProd2.vlocity_cmt__IsOrderable__c = true;
        prodList.add(testCommProd2);
        
        insert prodList;
       
        // Creating PriceBook Entry
        List<PricebookEntry> pBEntryList = new List<PricebookEntry>();
        PricebookEntry pe = new PricebookEntry();
        pe.Pricebook2Id = pbId;
        pe.Product2Id = prodList[0].Id;
        pe.UnitPrice = 100;
        pe.IsActive = true;
        pBEntryList.add(pe);
        
        PricebookEntry pe1 = new PricebookEntry();
        pe1.Pricebook2Id = pbId;
        pe1.Product2Id = prodList[1].Id;
        pe1.UnitPrice = 100;
        pe1.IsActive = true;
        pBEntryList.add(pe1);
        
        insert pBEntryList;
        
        //Creating Target & Source OrderItems
        List<OrderItem> olList = new List<OrderItem>();
        
        OrderItem targetOrderItem = new OrderItem();
        targetOrderItem.OrderId = targetOrder.Id;
        targetOrderItem.PricebookEntryId = pe.Id;
        targetOrderItem.Quantity = 1;
        targetOrderItem.vlocity_cmt__LineNumber__c = '0001';
        targetOrderItem.UnitPrice = 100;
        targetOrderItem.Product2Id = testCommProd2.Id;
        targetOrderItem.vlocity_cmt__Product2Id__c = testCommProd2.Id;
        targetOrderItem.ARTL_4GUniqueKey__c = 'Test Key';
        targetOrderItem.vlocity_cmt__RootItemId__c = 'Test-Id';
        targetOrderItem.vlocity_cmt__AssetReferenceId__c = 'akshay-test-ref2';
        targetOrderItem.vlocity_cmt__ProvisioningStatus__c = 'New';   
        targetOrderItem.vlocity_cmt__AttributeSelectedValues__c = '{"Colour":"Target Comm2 Colour","Model":"Target Comm2 Model"}';
        olList.add(targetOrderItem);
       /* OrderItem targetOrderItem1 = new OrderItem();
        targetOrderItem1.OrderId = sourceOrder.Id;
        targetOrderItem1.PricebookEntryId = pe.Id;
        targetOrderItem1.Quantity = 1;
        targetOrderItem1.vlocity_cmt__LineNumber__c = '0001';
        targetOrderItem1.UnitPrice = 100;
        targetOrderItem1.Product2Id = testCommProd2.Id;
        targetOrderItem1.vlocity_cmt__Product2Id__c = testCommProd2.Id;
        targetOrderItem1.ARTL_4GUniqueKey__c = 'Test Key';
        targetOrderItem1.vlocity_cmt__RootItemId__c = 'Test-Id';
        targetOrderItem1.vlocity_cmt__AssetReferenceId__c = 'akshay-test-ref2';
        targetOrderItem1.vlocity_cmt__ProvisioningStatus__c = 'New';   
        targetOrderItem1.vlocity_cmt__AttributeSelectedValues__c = '{"Colour":"Target Comm2 Colour","Model":"Target Comm2 Model"}';
        olList.add(targetOrderItem1);
        */
        OrderItem sourceOrderItem = new OrderItem();
        sourceOrderItem.OrderId = sourceOrder.Id;
        sourceOrderItem.PricebookEntryId = pe.Id;
        sourceOrderItem.Quantity = 1;
        sourceOrderItem.vlocity_cmt__LineNumber__c = '0001';
        sourceOrderItem.UnitPrice = 100;
        sourceOrderItem.Product2Id = testCommProd1.Id;
        sourceOrderItem.ARTL_Media__c = '4G';
        sourceOrderItem.ARTL_4GUniqueKey__c = 'Test Key';
        sourceOrderItem.vlocity_cmt__Product2Id__c = testCommProd1.Id;
        sourceOrderItem.vlocity_cmt__RootItemId__c = 'Test-Id';
        sourceOrderItem.vlocity_cmt__AssetReferenceId__c = 'akshay-test-ref';
        sourceOrderItem.vlocity_cmt__AttributeSelectedValues__c = '{"Colour":"Target Comm2 Colour","Model":"Target Comm2 Model"}';
        sourceOrderItem.vlocity_cmt__ProvisioningStatus__c = 'New';                
        olList.add(sourceOrderItem);
        insert olList;
        
        vlocity_cmt__OrderItemRelationship__c testrelationship = new vlocity_cmt__OrderItemRelationship__c();
        testrelationship.vlocity_cmt__OrderItemId__c = sourceOrderItem.id;
        testrelationship.vlocity_cmt__RelatedOrderItemId__c = targetOrderItem.id;
        testrelationship.vlocity_cmt__RelationshipType__c = 'Relies-On';
        testrelationship.vlocity_cmt__OrderId__c = sourceOrder.id;
        
        //Creating ReliesOn OrderProductRelationship between Source & Target OrderItem
        vlocity_cmt__OrderItemRelationship__c orderProdRel = new vlocity_cmt__OrderItemRelationship__c();
        orderProdRel.Name = 'ReliesOn-345345';
        orderProdRel.vlocity_cmt__OrderId__c = sourceOrder.Id;
        orderProdRel.vlocity_cmt__OrderItemId__c = sourceOrderItem.Id;
        orderProdRel.vlocity_cmt__RelatedOrderItemId__c = targetOrderItem.Id;
        orderProdRel.vlocity_cmt__RelationshipType__c = 'ReliesOn';
        insert orderProdRel;
        
        //Creating Orchestration Plans                
        List<vlocity_cmt__OrchestrationPlan__c> orchList = new List<vlocity_cmt__OrchestrationPlan__c>();
        
        vlocity_cmt__OrchestrationPlan__c targetOrchPlan = new vlocity_cmt__OrchestrationPlan__c();
        targetOrchPlan.vlocity_cmt__OrderId__c = targetOrder.Id;
        orchList.add(targetOrchPlan);
        
        vlocity_cmt__OrchestrationPlan__c sourceOrchPlan = new vlocity_cmt__OrchestrationPlan__c();
        sourceOrchPlan.vlocity_cmt__OrderId__c = sourceOrder.Id;            
        orchList.add(sourceOrchPlan);
        
        insert orchList;

        
        //Creating Target Orchestration Items
        List<vlocity_cmt__OrchestrationItem__c> orchItems = new List<vlocity_cmt__OrchestrationItem__c>();
        
        vlocity_cmt__OrchestrationItem__c testOrchItem = new vlocity_cmt__OrchestrationItem__c();
        //testOrchItem.vlocity_cmt__OrchestrationItemDefinitionId__c = sourceoid4.Id;
        testOrchItem.Name = 'TestForCustomObjectRelationSource11';
        testOrchItem.vlocity_cmt__OrderItemId__c = sourceOrderItem.Id; 
        testOrchItem.vlocity_cmt__OrchestrationPlanId__c = sourceOrchPlan.Id; 
        testOrchItem.vlocity_cmt__TimeoutMs__c = 1000.000;
        orchItems.add(testOrchItem);  
        insert orchItems;
        
        Asset dummyasset = new Asset();
        dummyasset.AccountId = acc.id;
        dummyasset.vlocity_cmt__OrderProductId__c = targetOrderItem.id;
        dummyasset.vlocity_cmt__ReliesOnItemId__c = 'Test-Id';
        dummyasset.vlocity_cmt__RootItemId__c = 'Test-Id';
        dummyasset.vlocity_cmt__ProvisioningStatus__c = 'Active';
        dummyasset.vlocity_cmt__BillingAccountId__c = testAccount.Id;
        dummyasset.vlocity_cmt__BillingAccountId__c = testAccount.Id;
        dummyasset.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        dummyasset.ARTL_4GUniqueKey__c = 'Test Key';
        dummyasset.Product2Id = testCommProd2.Id;
        dummyasset.name = 'Admin Asset';
        insert dummyasset;
        
        Asset sourceproductasset = new Asset();
        sourceproductasset.AccountId = acc.id;
        sourceproductasset.vlocity_cmt__OrderProductId__c = targetOrderItem.id;
        sourceproductasset.vlocity_cmt__AssetReferenceId__c = targetOrderItem.id;
        sourceproductasset.vlocity_cmt__ReliesOnItemId__c = 'Test-Id';
        sourceproductasset.vlocity_cmt__RootItemId__c = 'Test-Id';
        sourceproductasset.vlocity_cmt__BillingAccountId__c = testAccount.Id;
        sourceproductasset.vlocity_cmt__BillingAccountId__c = testAccount.Id;
        sourceproductasset.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        sourceproductasset.name = 'Source Product';
        sourceproductasset.vlocity_cmt__AssetReferenceId__c = 'akshay-test-ref2';
        insert sourceproductasset;
        
        Asset targetproductasset = new Asset();
        targetproductasset.AccountId = acc.id;
        targetproductasset.vlocity_cmt__OrderProductId__c = targetOrderItem.id;
        targetproductasset.vlocity_cmt__AssetReferenceId__c = targetOrderItem.id;
        targetproductasset.vlocity_cmt__AssetReferenceId__c = 'akshay-test-ref';
        targetproductasset.vlocity_cmt__BillingAccountId__c = testAccount.Id;
        targetproductasset.vlocity_cmt__ServiceAccountId__c = serviceAccount.Id;
        targetproductasset.name = 'target Product';
        insert targetproductasset;
    }
    
    @isTest static void testExecuteBatch(){
        
        List<vlocity_cmt__OrchestrationItem__c> lstOIs = [SELECT Id,vlocity_cmt__OrderItemId__c,vlocity_cmt__OrderItemId__r.OrderId FROM vlocity_cmt__OrchestrationItem__c WHERE Name= 'TestForCustomObjectRelationSource11'];
        Test.startTest();
        ARTL_MPLS4GController obj = new ARTL_MPLS4GController();
        obj.executeBatch(lstOIs);
        Test.stopTest();
    }
    
    @isTest static void testExecuteBatch1(){
        
        List<Asset> tempAssets = [SELECT Id, vlocity_cmt__ProvisioningStatus__c FROM Asset WHERE Name = 'Admin Asset'];
        tempAssets[0].vlocity_cmt__ProvisioningStatus__c = 'New';
        update tempAssets;
        
        List<vlocity_cmt__OrchestrationItem__c> lstOIs = [SELECT Id,vlocity_cmt__OrderItemId__c,vlocity_cmt__OrderItemId__r.OrderId FROM vlocity_cmt__OrchestrationItem__c WHERE Name= 'TestForCustomObjectRelationSource11'];
        Test.startTest();
        ARTL_MPLS4GController obj = new ARTL_MPLS4GController();
        obj.executeBatch(lstOIs);
        Test.stopTest();
    }
    
}