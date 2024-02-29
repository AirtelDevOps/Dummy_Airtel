@isTest
public class ARTL_GenerateLettersAndSendEmailTest {
    
    @testSetup static void createData() {
        List<Quote> lstQuote = new List<Quote>();
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                         BillingCountry = 'Test Country');
        insert objAccount;
        Product2 objProduct1 = new Product2(Name = 'Test product1', family = 'Cafe',ProductCode = 'VEPC_E_IIL');
        insert objProduct1;
        Product2 objProduct2 = new Product2(Name = 'Test product2', family = 'Cafe',ProductCode = 'VEPC_PRIMARY_LINK');
        insert objProduct2;
        Product2 objProduct3 = new Product2(Name = 'Test product3', family = 'Cafe',ProductCode = 'VEPC_ENTERPRISE_ICONNECTIVITY_ROUTERS');
        insert objProduct3;
        Product2 objProduct4 = new Product2(Name = 'Test product4', family = 'Cafe',ProductCode = 'VEPC_ICONNECTIVTY_LAN_IP');
        insert objProduct4;
        Product2 objProduct5 = new Product2(Name = 'Test product5', family = 'Cafe',ProductCode = 'VEPC_ICONNECTIVITY_WAN_IP');
        insert objProduct5;
        
        
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),Product2Id = objProduct1.Id, IsActive = true);
        insert objPBE;
        PriceBookEntry objPBE1 = new PriceBookEntry(UnitPrice = 200, PriceBook2Id = Test.getStandardPricebookId(),Product2Id = objProduct2.Id, IsActive = true);
        insert objPBE1;
        PriceBookEntry objPBE2 = new PriceBookEntry(UnitPrice = 350, PriceBook2Id = Test.getStandardPricebookId(),Product2Id = objProduct3.Id, IsActive = true);
        insert objPBE2;
        PriceBookEntry objPBE3 = new PriceBookEntry(UnitPrice = 340, PriceBook2Id = Test.getStandardPricebookId(),Product2Id = objProduct4.Id, IsActive = true);
        insert objPBE3;
        PriceBookEntry objPBE4 = new PriceBookEntry(UnitPrice = 330, PriceBook2Id = Test.getStandardPricebookId(),Product2Id = objProduct5.Id, IsActive = true);
        insert objPBE4;
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
        Quotelineitem qli1 = new QuoteLineItem(QuoteId = objQuo.id, vlocity_cmt__AttributeSelectedValues__c = '{"VEPC_ATTR_SDWAN_LICENSE_TYPE":"Enterprise","VEPC_ATTR_SDWAN_DEVICE_MODEL":"MX68CW"}', vlocity_cmt__Product2Id__c=objProduct1.Id, PriceBookentryId = objPBE.Id, Quantity = 1, UnitPrice = 1);
        Listqli.add(qli1); 
        Quotelineitem qli2 = new QuoteLineItem(QuoteId = objQuo.id, vlocity_cmt__AttributeSelectedValues__c = '{"VEPC_ATTR_SDWAN_LICENSE_TYPE":"Enterprise","VEPC_ATTR_SDWAN_DEVICE_MODEL":"MX68CW"}', vlocity_cmt__Product2Id__c=objProduct2.Id, PriceBookentryId = objPBE1.Id, Quantity = 1, UnitPrice = 1);
        Listqli.add(qli2);
        
        Quotelineitem qli3 = new QuoteLineItem(QuoteId = objQuo.id, vlocity_cmt__AttributeSelectedValues__c = '{"VEPC_ATTR_SDWAN_LICENSE_TYPE":"Enterprise","VEPC_ATTR_SDWAN_DEVICE_MODEL":"MX68CW"}', vlocity_cmt__Product2Id__c=objProduct3.Id, PriceBookentryId = objPBE2.Id, Quantity = 1, UnitPrice = 1);
        Listqli.add(qli3); 
        Quotelineitem qli4 = new QuoteLineItem(QuoteId = objQuo.id, vlocity_cmt__AttributeSelectedValues__c = '{"VEPC_ATTR_SDWAN_LICENSE_TYPE":"Enterprise","VEPC_ATTR_SDWAN_DEVICE_MODEL":"MX68CW"}', vlocity_cmt__Product2Id__c=objProduct4.Id, PriceBookentryId = objPBE3.Id, Quantity = 1, UnitPrice = 1);
        Listqli.add(qli4);
        
        Quotelineitem qli5 = new QuoteLineItem(QuoteId = objQuo.id, vlocity_cmt__AttributeSelectedValues__c = '{"VEPC_ATTR_SDWAN_LICENSE_TYPE":"Enterprise","VEPC_ATTR_SDWAN_DEVICE_MODEL":"MX68CW"}', vlocity_cmt__Product2Id__c=objProduct5.Id, PriceBookentryId = objPBE4.Id, Quantity = 1, UnitPrice = 1);
        Listqli.add(qli5); 
        
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
        OrderItem oi1 = new OrderItem(OrderId=o.Id,UnitPrice = 0 ,Quantity=decimal.valueof('1'),PricebookEntryId=objPBE1.Id,ARTL_QuoteLineItemId__c = qli2.id);
        insert oi1;
        OrderItem oi2 = new OrderItem(OrderId=o.Id,UnitPrice = 0 ,Quantity=decimal.valueof('1'),PricebookEntryId=objPBE2.Id,ARTL_QuoteLineItemId__c = qli3.id);
        insert oi2;
        OrderItem oi3 = new OrderItem(OrderId=o.Id,UnitPrice = 0 ,Quantity=decimal.valueof('1'),PricebookEntryId=objPBE3.Id,ARTL_QuoteLineItemId__c = qli4.id);
        insert oi3;
        OrderItem oi4 = new OrderItem(OrderId=o.Id,UnitPrice = 0 ,Quantity=decimal.valueof('1'),PricebookEntryId=objPBE4.Id,ARTL_QuoteLineItemId__c = qli5.id);
        insert oi4;
        
        
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
        //ARTL_GenerateLettersAndSendEmail.CreateAndSendWelcomeLetter(FlowInputtestlist);
        ARTL_NonDeemedLOCEmail testclass2 = new ARTL_NonDeemedLOCEmail();
        testclass2.generateAttachmentForNonDeemedLOCILLnewCircuitID(inputMap,outMap,options);
        testclass2.generateAttachmentForNonDeemedLOCMPLSnewCircuitID(inputMap,outMap,options);
        Test.stopTest();
    }
    
    
}