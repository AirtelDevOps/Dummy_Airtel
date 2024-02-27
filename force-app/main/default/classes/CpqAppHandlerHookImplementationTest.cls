@isTest
public class CpqAppHandlerHookImplementationTest {
    @isTest
    static void checkoutPostInvokeTest() {
        //List<Product2> prodList=[SELECT Id FROM Product2];
        //List<vlocity_cmt__AttributeAssignment__c> attAssignmentList=[SELECT Id,vlocity_cmt__ObjectId__c FROM vlocity_cmt__AttributeAssignment__c];
        Test.startTest();
        
        
        Account acc = new Account(Name = 'Test Account');
        insert acc; 
        
        Product2 prod = new Product2(Name = 'Test product1', family = 'Internet',ProductCode='XYZ_1', ARTL_LSIRequired__c=true);
        insert prod;
        system.debug('product=>'+prod);
        // Create a Pricebook
        
        // Create a Pricebook Entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100.00, // Set the unit price as needed
            IsActive = true
        );
        insert pbEntry;
        system.debug('pbEntry=>'+pbEntry);
        
        vlocity_cmt__PriceList__c priceList = new 	vlocity_cmt__PriceList__c();
        priceList.Name ='Pricelist For Test class';
        priceList.vlocity_cmt__Code__c='PricelistForTestclass';
        priceList.vlocity_cmt__Pricebook2Id__c =Test.getStandardPricebookId();
        insert priceList;
        system.debug('priceList=>'+priceList);
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;
        system.debug('opp=>'+opp);
        
        
        Quote q = new Quote();
        q.OpportunityId = opp.Id;
        q.Name = 'Quote Test';
        q.vlocity_cmt__PriceListId__c=priceList.Id;
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.Status ='Draft';
        q.ARTL_QNeedCapexApproval__c=True;
        q.vlocity_cmt__ValidationStatus__c = 'Ready for Order';
        insert q;
        system.debug('q=>'+q);
        
        
        QuoteLineItem qli = new QuoteLineItem(
            Product2Id = prod.Id,
            QuoteId = q.Id,
            PricebookEntryId = pbEntry.Id,
            UnitPrice = pbEntry.UnitPrice,
            Quantity=1,
            Capex__c=10000,
            Annual_Recurring_Charge__c=500000 
        );
        insert qli;
        system.debug('qli=>'+qli);
        
        
        //FixPicklistValuesUpdateJSON.FixPicklistValuesUpdateJSON(new List<Id>{prodList[0].Id},true);
        Map<String,Object> inputMap=new Map<String,Object>{'cartId'=>opp.Id};
           
            Map<string,object> objectMap=new Map<String,Object>{'id'=>q.Id,'objectType'=>'Quote'};
            Map<string,object> fieldMap=new Map<String,Object>{'fields'=>objectMap};
                Map<string,object> recordsMap=new Map<String,Object>{'records'=>new List<object>{fieldMap}};
                
        Map<String,Object> outputMap=new Map<String,Object>{'result'=>recordsMap};
        Map<String,Object> optionMap=new Map<String,Object>();
        CpqAppHandlerHookImplementation fpvu=new CpqAppHandlerHookImplementation();
        fpvu.invokeMethod('checkout.PostInvoke',inputMap,outputMap,optionMap);
        Test.stopTest();
    }  
    
    @isTest
    static void FixPicklistValuesUpdateJSONTest() {
        Test.startTest();
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> optionMap=new Map<String,Object>();  
        
        CpqAppHandlerHookImplementation fpvu=new CpqAppHandlerHookImplementation();
        fpvu.invokeMethod('postCartsItems.PreInvoke',inputMap,outputMap,optionMap);
        Test.stopTest();
    }
}