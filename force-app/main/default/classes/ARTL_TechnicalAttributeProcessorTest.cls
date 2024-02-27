@IsTest
private class ARTL_TechnicalAttributeProcessorTest {
    
    @testSetup static void testData() {
        
        User testUser = new User(FirstName = 'Test', LastName = 'User', Email = 'test.user@email.com', Username='test7864er@user.com',Alias = 'tuser', TimeZoneSidKey='Asia/Kolkata',
                                 ProfileId = '00e5j0000048gp8AAA', LocaleSidKey = 'en_IN', LanguageLocaleKey  = 'en_US', EmailEncodingKey='UTF-8');
        insert testUser;
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account acc = new Account(Name='TestAccount', RecordTypeId = recordTypeIdAccount, ARTL_Business_Circle_Region__c='NCR',BillingCity = 'Panchkula',
                                  BillingCountry = 'Haryana',BillingPostalCode = '134109',BillingState = 'India',BillingStreet = 'Panchkula',
                                  ARTL_Category__c = 'A',ARTL_Customer_Segment__c ='AB', ARTL_Vertical_Segment__c ='BFI',
                                 ARTL_Service_Segment__c ='Bharti'); 
        insert acc;
        
        List<Opportunity> lstOpps = new List<Opportunity>();
        lstOpps = new Opportunity[2];
        lstOpps[0] = new Opportunity(Name='TestOpp1', StageName='Initial', AccountId = acc.Id, Amount = 10, CloseDate = System.Today());
        lstOpps[1] = new Opportunity(Name='TestOpp2', AccountId = acc.Id, StageName='Initial', Amount = 20, CloseDate = System.Today());
        insert lstOpps;
        
        Id recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_Internal_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName='Test', LastName='Contact', AccountId=acc.Id, OwnerId= testUser.Id, Phone = '1234567890', Email='test@test.com',
                                  ARTL_Interaction_Level__c='Board Level', ARTL_Designation__c='TestDesgntn', ARTL_Contact_Role__c ='Resident Engineer',
                                  ARTL_stakeholder_score__c='2.5', RecordTypeId=recordTypeIdContact, Country_Code__c='41'
                                 );
        insert con;
        
        Contact con1 = new Contact(FirstName='Test', LastName='Contact', AccountId=acc.Id, OwnerId= testUser.Id, Phone = '0987654332', Email='test11@test.com',
                                   ARTL_Interaction_Level__c='Board Level', ARTL_Designation__c='TestDesgntn', ARTL_Contact_Role__c ='Resident Engineer',
                                   ARTL_stakeholder_score__c='2.5', RecordTypeId=recordTypeIdContact, Country_Code__c='41'
                                  );
        insert con1;
        
        Event testEvent = new Event(
            Subject = 'Test Event',
            DurationInMinutes = 10,
            vlocity_cmt__eventstatus__c = 'Error',
            ActivityDateTime = System.now(),
            WhoId= con.id,
            WhatId = acc.Id
        );
        insert testEvent;
        
        Account_Plan__c objAP = new Account_Plan__c(Account_Plan_Status__c = 'Draft', Account_Name__c = acc.Id, CE_Head__c = testUser.Id);
        insert objAP;
        
        Task t=new Task(subject='test_test',description='Account info on Task',Whatid=acc.Id,status='open',priority='normal', ARTL_TaskType__c='Meeting Reminder');
        insert t;
        
        vlocity_cmt__PriceList__c priceList = new 	vlocity_cmt__PriceList__c();
        priceList.Name ='Pricelist For Test class';
        priceList.vlocity_cmt__Code__c='PricelistForTestclass';
        priceList.vlocity_cmt__Pricebook2Id__c =Test.getStandardPricebookId();
        insert priceList;
        
        Quote q = new Quote();
        q.OpportunityId = lstOpps[0].Id;
        q.Name = 'Quote Test';
        q.vlocity_cmt__PriceListId__c=priceList.Id;
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.Status ='Draft';
        insert q;
        
        Product2 objProduct = new Product2(Name = 'Test product1', family = 'Cafe',ProductCode='XYZ_1',
                                           ARTL_TechnicalProduct__c='ABC_x');
        insert objProduct;
        Product2 objProduct2 = new Product2(Name = 'Test product11', family = 'Cafe',ProductCode='ABC_x',
                                           vlocity_cmt__AttributeMetadata__c = '{"totalSize" : 1,"messages" : [ ],"records" : [ {"messages" : [ ],"displaySequence" : 9,"Code__c" : "VLO-PRO-0001","Name" : "TV Channels","id" : "a0I5e000000XdtTEAS","productAttributes" : {"totalSize" : 1,"messages" : [ ],"records" : [ {"messages" : [ ],"code" : "ATTRIBUTE-021","dataType" : "text","inputType" : "text","multiselect" : false,"required" : false,"readonly" : true,"disabled" : true,"filterable" : false,"attributeId" : "a0J5e000000TTDVEA4","label" : "Genre","displaySequence" : 2,"hasRules" : false,"description" : "The type of genres that are included in this package","hidden" : false,"cloneable" : false,"isNotTranslatable" : false,"values" : [ {"readonly" : true,"disabled" : true,"defaultValue" : "Kids, Adventure"} ],"userValues" : null} ]}} ]}'
                                           );
        insert objProduct2;
        
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),Product2Id = objProduct.Id, IsActive = true);
        insert objPBE;
        List<Quote> qList=[select id,name,AccountId,Status,Pricebook2Id from Quote];
        List<Quotelineitem> Listqli = new List<Quotelineitem>();
        for(Quote qa:qList){
            Quotelineitem qli1 = new QuoteLineItem(QuoteId = qa.id, PriceBookentryId = objPBE.id, Quantity = 1, UnitPrice = 1,
                                                   Product2Id=objProduct.Id);
            Listqli.add(qli1); 
        }
        insert Listqli;
        
        XLI_Technical_Attribute__c  techAttr = new XLI_Technical_Attribute__c();
        techAttr.Technical_Product__c = objProduct2.Id;
        techAttr.Quote_Line_Item__c = Listqli[0].Id;
        techAttr.Technical_Attribute__c = '{"ATT_TIMERS_KEEPALIVE_HOLDTIME":null,"ATT_BGP-REPLACE_AS":null,"ATT_AS_SET":null}';
        techAttr.Technical_Attribute_Metadata__c  = objProduct2.vlocity_cmt__AttributeMetadata__c;
        techAttr.Technical_Attribute__c = objProduct2.vlocity_cmt__JSONAttribute__c;
        
        insert techAttr;
    }
    
    static testMethod void testDefault(){
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Task tsk = [SELECT Id from Task limit 1];
        Quotelineitem qli = [select id from Quotelineitem limit 1];
        
        Map<String, Object> inputs = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        Map<String,Object> payload = new Map<String,Object>();
        payload.put('accessNetworkLocationCode', (Object)'Access POP Network Location Code');
        inputs.put('taskType', 'PM_NW_Jeopardy');
        inputs.put('isFetchTechAttrMap', true);
        inputs.put('taskId',tsk.Id);
        inputs.put('QLI_Id',qli.Id);
        inputs.put('requestPL',new List<Object>{payload});
        
        ARTL_TechnicalAttributeProcessor obj = new ARTL_TechnicalAttributeProcessor();
        Test.startTest();
        Boolean result = obj.invokeMethod('extractAttributesFromJSON', inputs, output, options);
        Test.stopTest();
        
        System.assertEquals(result, true);
    }
    
}