@isTest
public class ARTL_ValidateChangeEffectiveDateTest {
    @testSetup
    static void dataCreation() {
    Account acc = new Account(Name = 'Test Account');
        insert acc; 
        
        Product2 prod = new Product2(Name = 'Test product1', family = 'Internet',ProductCode='XYZ_1', ARTL_LSIRequired__c=true,ARTL_Component_Id__c='28001');
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
        insert q;
        system.debug('q=>'+q);
        
        
        QuoteLineItem qli = new QuoteLineItem(
            Product2Id = prod.Id,
            QuoteId = q.Id,
            PricebookEntryId = pbEntry.Id,
            UnitPrice = pbEntry.UnitPrice,
            Quantity=1,
            Capex__c=10000,
            Annual_Recurring_Charge__c=500000,
            ARTL_LSI__c=Double.valueOf('2108027002187'),
            ARTL_LSI_Installed_Date__c=DateTime.newInstance(2023,12,26,12, 30, 0)
            //DateTime myDateTime = DateTime.newInstance(2023,12,26,12, 30, 0);
            
        );
        insert qli;
        system.debug('qli=>'+qli);
        
    
    }
    @isTest
    static void checkFXvalidatedDateTest() {
        Test.startTest();
        List<Quote> quoteList=[SELECT Id,Name FROM Quote];
		Id quoteId= quoteList[0].Id;
        Boolean needFXValidation=ARTL_ValidateChangeEffectiveDate.checkFXvalidatedDate(quoteId);
        System.assertEquals(needFXValidation, true);
        Test.stopTest();
    }
    
    @isTest
    static void invokeFXValidationAPITest() {
        Test.startTest();
        List<Quote> quoteList=[SELECT Id,Name FROM Quote];
		Id quoteId= quoteList[0].Id;
        Map <String, Object> outputMap=ARTL_ValidateChangeEffectiveDate.invokeFXValidationAPI(quoteId);
        system.debug('outputMAp outputMap=>'+JSON.serializePretty(outputMap));
        //System.assertNotEquals(outputMap, true);
        Test.stopTest();
    }
    
    @isTest
    static void invokeDateValidationTest() {
        Test.startTest();
        String responseJSON='[{"effectiveStartDate":"2021-08-05T00:00:00.000+05:30","ServiceActiveDate":"2021-08-04T23:59:59.000+05:30","ComponentId":"28001"},{"effectiveStartDate":"2021-08-04T23:59:55.000+05:30","ServiceActiveDate":"2021-08-04T23:59:55.000+05:30","ComponentId":"28006"},{"effectiveStartDate":"2021-08-05T00:00:00.000+05:30","ServiceActiveDate":"2021-08-04T23:59:55.000+05:30","ComponentId":"28006"}]';
        List<Object> responseList=(List<Object>)JSON.deserializeUntyped(responseJSON);
        
        Map<String,Object> jsonMap=new Map<String,Object>{'QuoteLineItemId'=>'567876543456gfd'};
        
		List<Quote> quoteList=[SELECT Id,Name FROM Quote];
		Id quoteId= quoteList[0].Id;  
        
        string finalJSON = '{ "LSI" : "2108027002187",'+'"QuoteId" : "'+string.valueof(quoteId)+'",'+'"Response" : '+responseJSON+'}';
                            System.debug('finalJSON --->>'+finalJSON);
        System.debug('finalJSON string=>'+JSON.serializePretty(finalJSON));
        ARTL_ValidateChangeEffectiveDate.invokeDateValidation(finalJSON);
        List<QuoteLineItem> qliList=[Select Id,ARTL_FXValidationMessage__c  FROM QuoteLineItem];
        System.assertNotEquals(qliList[0].ARTL_FXValidationMessage__c, null);
        Test.stopTest();
    }
    

}