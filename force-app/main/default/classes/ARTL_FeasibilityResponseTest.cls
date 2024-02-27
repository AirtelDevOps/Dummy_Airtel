@isTest
public class ARTL_FeasibilityResponseTest {
	@isTest
    static void positiveTest(){
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
        
        User usr = ARTL_ValidateStagingDataHelper.getUser();
        System.runAs(usr){
            Test.startTest();
            String apiKey = 'YWZjMWM0NTgtN2JiMi01ZWYzLThjNzMtZTBkMDEyNTA4ODQz';
            ARTL_Integration_Details__c integrationDetails= new ARTL_Integration_Details__c(Name='FeasibilityResponseSFDC',
                                                                                            ARTL_API_Key__c= apiKey);
            insert integrationDetails;
            
            RestRequest req = new RestRequest();
            req.addHeader('api-key', apiKey);
            RestResponse res = new RestResponse();
            req.requestURI = '/services/apexrest/feasibilityResponse'; //Request URL
            req.httpMethod = 'POST';
            String resBody = [SELECT body FROM StaticResource WHERE Name = 'feasibilityResponseDummy'].Body.toString();
            resBody = resBody.replace('"result": {', '"result": { "requestId": "' + qouteLine.id + '",');
            req.requestBody = Blob.valueOf(resBody);
            
            //"requestId": "0QL720000004XryGAE",
            //    "result": {
			            
            RestContext.request = req;
            RestContext.response= res;
			            
            ARTL_FeasibilityResponse.handlePost();
            Test.stopTest();
        }
    }
}