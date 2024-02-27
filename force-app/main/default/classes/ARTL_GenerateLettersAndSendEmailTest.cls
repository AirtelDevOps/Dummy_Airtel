@isTest
public class ARTL_GenerateLettersAndSendEmailTest {
    
    @testSetup static void createData() {
    List<Quote> lstQuote = new List<Quote>();
    Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
                                     BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                     BillingCountry = 'Test Country');
    insert objAccount;
    Product2 objProduct = new Product2(Name = 'Test product1', family = 'Cafe');
    insert objProduct;
        
    PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),Product2Id = objProduct.Id, IsActive = true);
    insert objPBE;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'dgcuyjv', Email='standarduser@testorg1.com', 
            EmailEncodingKey='UTF-8', LastName='Testingfhg', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com.test');
        insert u;
    Opportunity objOpp = new Opportunity(Name = 'Test Opp', AccountId = objAccount.Id, StageName = 'Verbal Confirmation', CloseDate = Date.today()+1);
    insert objOpp;
        
    Quote objQuo = new Quote(OpportunityId = objOpp.Id, Name = 'Test Quote' , Pricebook2Id = Test.getStandardPricebookId(), Status = 'Review Pending');
    insert objQuo;
    
        
        List<Quotelineitem> Listqli = new List<Quotelineitem>();
         Quotelineitem qli1 = new QuoteLineItem(QuoteId = objQuo.id, PriceBookentryId = objPBE.Id, Quantity = 1, UnitPrice = 1);
       Listqli.add(qli1); 
        Quotelineitem qli2 = new QuoteLineItem(QuoteId = objQuo.id, PriceBookentryId = objPBE.Id, Quantity = 1, UnitPrice = 1);
       Listqli.add(qli2);
        insert Listqli; 
        
        Order o = new Order();
    	o.Name = 'Test Order';
        o.vlocity_cmt__QuoteId__c = objQuo.id;
    	o.Status = 'Draft';
    	o.EffectiveDate = system.today();
    	o.EndDate = system.today() + 4;
    	o.AccountId = objAccount.id;
    	o.Pricebook2Id =  Test.getStandardPricebookId() ;
        insert o;
        OrderItem oi = new OrderItem(OrderId=o.Id,UnitPrice = 0 ,Quantity=decimal.valueof('1'),PricebookEntryId=objPBE.Id,ARTL_QuoteLineItemId__c = qli1.id);
            insert oi;
    
    
    }
    @istest
    public static void CreateCSVTestMethod(){
        List<Quote> Listquo = [select id from quote where name = 'Test Quote'];
        List<Order> Listord = [select id from order where name = 'Test Order'];
        id quoteid = Listquo[0].id;
        id orderid = Listord[0].id;
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        inputMap.put('OrderId',orderid);
        Test.startTest();
 		//CreateWelcomeLetterCSV createcsvclass = new CreateWelcomeLetterCSV();
        List<ARTL_GenerateLettersAndSendEmail.FlowInput> FlowInputtestlist = new  List<ARTL_GenerateLettersAndSendEmail.FlowInput>();
        ARTL_GenerateLettersAndSendEmail.FlowInput FlowInputtest = new  ARTL_GenerateLettersAndSendEmail.FlowInput();
         FlowInputtest.recordId = quoteid;
      FlowInputtestlist.add(FlowInputtest);
       ARTL_GenerateLettersAndSendEmail testclass = new ARTL_GenerateLettersAndSendEmail();
        testclass.invokeMethod('CreateAndSendKickOffEmail',inputMap,outMap,options);
        ARTL_GenerateLettersAndSendEmail.CreateAndSendWelcomeLetter(FlowInputtestlist);
        ARTL_NonDeemedLOCEmail testclass2 = new ARTL_NonDeemedLOCEmail();
        testclass2.generateAttachmentForNonDeemedLOCILLnewCircuitID(inputMap,outMap,options);
        testclass2.generateAttachmentForNonDeemedLOCMPLSnewCircuitID(inputMap,outMap,options);
 		Test.stopTest();
    }
    
    
}