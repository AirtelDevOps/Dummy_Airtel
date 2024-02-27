@isTest
private class ARTL_FeasibilityUtilityTest {

    @isTest
   private static void testTransformRequestAndUpdateQLI() {
          Profile p = [SELECT id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];  
        User adminUser = new User(firstname= 'Samuel',
                                  lastname='Oak',
                                  Alias='Samuel',
                                  email = 'testemail665411@email.com',
                                  username= 'testemail665411@email.com', 
                                  profileId= p.id, 
                                  emailencodingkey='UTF-8',
                                  languagelocalekey='en_US',
                                  localesidkey='en_US',
                                  timezonesidkey='America/Los_Angeles');
        System.runAs(adminUser){
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
            
            
           ARTL_Feasibility__c fea = new ARTL_Feasibility__c(ARTL_Feasibility_Status__c='Feasible');
        insert fea;
            ARTL_Feasibility_Line_Item__c FeasibilityParentLineItem = new ARTL_Feasibility_Line_Item__c(
            ARTL_Feasibility__c = fea.Id, Name= 'Test');
            insert FeasibilityParentLineItem;
            
            List<ARTL_Feasibility_Line_Item__c> FeasibilityParentLineItemList = new list<ARTL_Feasibility_Line_Item__c>();
            FeasibilityParentLineItemList.add(FeasibilityParentLineItem);
            
             ARTL_Feasibility_Line_Item__c FeasibilityLineItem2 = new ARTL_Feasibility_Line_Item__c(
            ARTL_Feasibility__c = fea.Id, Name= 'Test',ParentId__c=FeasibilityParentLineItem.id);
            insert FeasibilityLineItem2;
            
              ARTL_Feasibility_Attribute__c attributeRecord5 = new ARTL_Feasibility_Attribute__c(
            ARTL_Feasibility__c = fea.Id,
            Name = 'city',
            Value__c = 'value2',
            ARTL_QLI__c = qouteLine.Id,
            ARTL_Feasibility_Line_Item__c = FeasibilityParentLineItem.id
        );
        insert attributeRecord5;
            
            list<ARTL_Feasibility_Attribute__c> fAttrInsertList = new list<ARTL_Feasibility_Attribute__c>();
            fAttrInsertList.add(attributeRecord5);
            
            
              ARTL_Purchase_Order__c PurchaseOrder = new ARTL_Purchase_Order__c();
            PurchaseOrder.ARTL_PO_Number__c = '111111';
            PurchaseOrder.Quote_Line_Item__c = qouteLine.id;
            insert PurchaseOrder;
            
             Asset ast = new Asset();
            ast.Name = 'MyNewAssetforTestClass';
            ast.AccountId = acc.Id;
            ast.vlocity_cmt__AssetReferenceId__c = '123';
            ast.vlocity_cmt__BillingAccountId__c  = acc.Id;
             ast.vlocity_cmt__ServiceAccountId__c   = acc.Id;
            ast.ARTL_Purchase_Order__c = PurchaseOrder.id;
            insert ast;  
        QuoteLineItem  qouteLine2 = new QuoteLineItem ();
        qouteLine2.UnitPrice = 1;
        qouteLine2.Quantity = 1;
        qouteLine2.vlocity_cmt__AssetId__c = ast.id;
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
        
              
        
         Map<String, Object> inputMap = new Map<String, Object>{
            'request' => new List<Object>{
                new Map<String, Object>{
                    'requestId' => qtest.Id
                    // Add other required fields as needed
                }
            }
        };

        Map<String, Object> outputMap = new Map<String, Object>();

        Test.startTest(); 
        ARTL_FeasibilityUtility utility = new ARTL_FeasibilityUtility();
            
          String longString = '{' + '"RootAttribute": "' + 'This is a long string with more than 255 characters. '.repeat(10) + '"}';

        // Parse the JSON string into a nested map
        Map<String, Object> longStringMap = (Map<String, Object>)JSON.deserializeUntyped(longString);

        // Create test data for resultMap
        Map<String, Object> resultMap = new Map<String, Object>{
            'RootAttribute' => longStringMap,
            'ObjectAttribute' => '{"NestedAttribute1": "NestedValue1", "NestedAttribute2": "NestedValue2"}',
            'Attribute2' => 'Value2'
        };

        // Create lists to store inserted records
     // Call the method
     //   ARTL_FeasibilityUtility.parseInfiniteData(resultMap, 'RootAttribute', fea, FeasibilityParentLineItemList, fAttrInsertList, FeasibilityParentLineItem);
        
          //  Map<String,Object> resultMap, String level1Attr, ARTL_Feasibility__c feasibilityObj, List< ARTL_Feasibility_Line_Item__c> fLIInsertList, List< ARTL_Feasibility_Attribute__c> fAttrInsertList, ARTL_Feasibility_Line_Item__c parentFLI
            
            
          
       ARTL_FeasibilityUtility.getReportId(' ');
        utility.invokeMethod('requestTransform',inputMap, outputMap, new Map<String, Object>());
         utility.invokeMethod('addressVerificationForQuote',inputMap, outputMap, new Map<String, Object>());
        Test.stopTest();
        
        
        }}
        
    
}