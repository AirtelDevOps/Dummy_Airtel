@isTest
    public class ARTL_TaskEmailControllerTest {
        Public Static final String JSONTechnicalAttr = '{"ATT_TIMERS_KEEPALIVE_HOLDTIME":null,"ATT_BGP-REPLACE_AS":null,"ATT_AS_SET":null}';
        public static SObject getLineItemMock(Id recordId) {
            Product2 p = new Product2(
                Id = '01t7j000002UElHAAW',
                vlocity_cmt__JSONAttribute__c = '{"VLO-PRO-0001":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t5e000000LD9MAAW","attributeid__c":"a0J5e000000TTDVEA4","attributecategoryid__c":"a0I5e000000XdtTEAS","categorycode__c":"VLO-PRO-0001","categoryname__c":"TV Channels","attributeuniquecode__c":"ATTRIBUTE-021","attributeconfigurable__c":true,"attributedisplaysequence__c":"2","attributefilterable__c":false,"isactive__c":true,"attributedisplayname__c":"Genre","displaysequence__c":"9","formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a0H5e000001QJehEAG","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Kids, Adventure","valuedatatype__c":"Text","valuedescription__c":"The type of genres that are included in this package","attributecloneable__c":false,"customconfiguitemplate__c":null,"categorydisplaysequence__c":9,"isnottranslatable__c":false,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Kids, Adventure"},"$$AttributeDefinitionEnd$$":null}]}',
                vlocity_cmt__AttributeMetadata__c = '{"totalSize" : 1,"messages" : [ ],"records" : [ {"messages" : [ ],"displaySequence" : 9,"Code__c" : "VLO-PRO-0001","Name" : "TV Channels","id" : "a0I5e000000XdtTEAS","productAttributes" : {"totalSize" : 1,"messages" : [ ],"records" : [ {"messages" : [ ],"code" : "ATTRIBUTE-021","dataType" : "text","inputType" : "text","multiselect" : false,"required" : false,"readonly" : true,"disabled" : true,"filterable" : false,"attributeId" : "a0J5e000000TTDVEA4","label" : "Genre","displaySequence" : 2,"hasRules" : false,"description" : "The type of genres that are included in this package","hidden" : false,"cloneable" : false,"isNotTranslatable" : false,"values" : [ {"readonly" : true,"disabled" : true,"defaultValue" : "Kids, Adventure"} ],"userValues" : null} ]}} ]}',
                vlocity_cmt__AttributeDefaultValues__c = '{"ATTRIBUTE-021":"Kids, Adventure"}'
            );
    
            
            OrderItem lineItem = new OrderItem(
                Id = recordId,
                Product2 = p,
                vlocity_cmt__JSONAttribute__c = '{"VLO-PRO-0001":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t36000001CmNdAAK","attributeid__c":"a0J36000000rXqKEAU","attributecategoryid__c":"a0I36000001YsHHEA0","categorycode__c":"VLO-PRO-0001","categoryname__c":"TV Channels","attributeuniquecode__c":"ATTRIBUTE-021","attributeconfigurable__c":true,"attributedisplaysequence__c":"2","attributefilterable__c":false,"isactive__c":true,"attributedisplayname__c":"Genre","displaysequence__c":"9","formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a0H36000002rZqDEAU","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":"Kids, Adventure","valuedatatype__c":"Text","valuedescription__c":"The type of genres that are included in this package","attributeRunTimeInfo":{"dataType":"Text","default":"Kids, Adventure","value":"Kids, Adventure"},"$$AttributeDefinitionEnd$$":null}]}',
                vlocity_cmt__AttributeMetadataChanges__c = '{"ATTRIBUTE-021":{"isNotTranslatable":null}}',
                vlocity_cmt__AttributeSelectedValues__c = '{"ATTRIBUTE-021":"Kids, Adventure"}'
            );
    
            return lineItem;
        }
    
     @testSetup static void setup() {
        
        // create test data for order, Account, Quote, Opportunity
        Account acc = new Account();
        acc.name='Parent Test';
        acc.BillingStreet = '3022  Strother Street';
        acc.BillingCity = 'Into';
        acc.BillingState = 'Alabama';
        acc.BillingPostalCode = '35222';
        acc.BillingCountry = 'US';
        acc.ARTL_IntegrationId__c = '2342'; 
        acc.ARTL_Category__c = 'A';
        acc.ARTL_Customer_Segment__c ='AB';
         acc.ARTL_Service_Segment__c ='Bharti';
         acc.ARTL_Vertical_Segment__c ='BFI';
         acc.ARTL_Business_Circle_Region__c ='NCR';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        acc.vlocity_cmt__BillingEmailAddress__c = 'xyz@gmail.com';
        
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
        opp.PM__c = Userinfo.getUserId();
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
        qtest.PM__c = Userinfo.getUserId();
       	qtest.RecordTypeId =  [SELECT Id FROM RecordType WHERE DeveloperName= 'EnterpriseQuote' AND SobjectType= 'Quote' LIMIT 1].Id;
        insert qtest;
         
        QuoteLineItem  qouteLine = new QuoteLineItem ();
        qouteLine.UnitPrice = 1;
        qouteLine.Quantity = 1;
        qouteLine.Product2Id = products[0].Id;
        qouteLine.vlocity_cmt__Product2Id__c = products[0].Id;
        qouteLine.QuoteId =qtest.Id;
        qouteLine.PricebookEntryId=pbes[0].Id;
        insert qouteLine;
        QuoteLineItem  qouteLine2 = new QuoteLineItem ();
        qouteLine2.UnitPrice = 1;
        qouteLine2.Quantity = 1;
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
         List<OrderItem> orderitemlst = new List<OrderItem>();
         OrderItem testOrderItem1 = new OrderItem(
            OrderId = orderList[0].Id,
            PricebookEntryId = pbes[0].Id,
            Product2Id = products[1].Id,
            Quantity = 1,
            UnitPrice = 10, 
            //QuoteLineItemId = qouteLine2.Id,
            CND__c = system.today()-7,
            RFS__c = system.today()-7,
            vlocity_cmt__RootItemId__c = '5dcd5d9e-cbe4-7390-d1e5-f532a3ae539d',
            vlocity_cmt__JSONAttribute__c = '',
            vlocity_cmt__AssetReferenceId__c = '5dcd5d9e-cbe4-7390-d1e5-f532a3ae539d',
            vlocity_cmt__AttributeMetadataChanges__c ='{"VEPC_ATTR_CPE_DELIVERY_OPTION":{"required":true}}',
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_ACCESS_BANDWIDTH":null,"ATT_CONTRACT_TERM":null,"ATT_CPE":null,"ATT_DEPENDENT_LINK_MEDIA":null,"ATT_LAST_MILE":null,"ATT_MEDIA":null,"ATT_PORT_BANDWIDTH":null,"ATT_SERVICE_TYPE":null,"ATT_CHARGE_SELECTION":null,"ATT_OFFNET_CAPEX":null}'
        );
         
         orderitemlst.add(testOrderItem1);
         insert orderitemlst;
         ARTL_Document__c doc = new ARTL_Document__c();
         doc.Document_Name__c = 'LOC_Email';
         doc.Category__c = 'EMAIL';
         doc.Type__c = 'LOC';
         doc.Quote__c =qtest.Id;
         doc.Order__c = orderList[0].Id;
        system.debug('orderList###'+orderList);
        
    }
	@isTest
    private static void testAll() {
        Order objord = [Select Id FROM Order limit 1];
        List<ARTL_TaskEmailController.FlowInput> lstinput = new List<ARTL_TaskEmailController.FlowInput>();
        ARTL_TaskEmailController.FlowInput input = new ARTL_TaskEmailController.FlowInput();
        input.recordId = objord.Id;
        input.templateName = 'Welcome_Kickoff';
        input.emailType = 'CreateAndSendKickOffEmail';
        lstinput.add(input);
        
        if(!lstinput.isEmpty()){
            ARTL_TaskEmailController.sendWelcomeEmail(lstinput);
        }
    }
        @isTest
    private static void welcometest() {
        Quote objord = [Select Id FROM Quote limit 1];
        List<ARTL_TaskEmailController.FlowInput> lstinput = new List<ARTL_TaskEmailController.FlowInput>();
        ARTL_TaskEmailController.FlowInput input = new ARTL_TaskEmailController.FlowInput();
        input.recordId = objord.Id;
        input.templateName = 'Welcome_Email1';
        input.emailType = 'welcome';
        lstinput.add(input);
        
        if(!lstinput.isEmpty()){
            ARTL_TaskEmailController.sendWelcomeEmail(lstinput);
        }
    }
        @isTest
    private static void ServiceHandoverTest() {
        Order objord = [Select Id FROM Order limit 1];
        List<ARTL_TaskEmailController.FlowInput> lstinput = new List<ARTL_TaskEmailController.FlowInput>();
        ARTL_TaskEmailController.FlowInput input = new ARTL_TaskEmailController.FlowInput();
        input.recordId = objord.Id;
        input.templateName = 'ARTL_Service_Handover_Template';
        input.emailType = 'ServiceHandover';
        lstinput.add(input);
        
        if(!lstinput.isEmpty()){
            ARTL_TaskEmailController.sendWelcomeEmail(lstinput);
        }
    }
        @isTest
    private static void LOCRejectTest() {
        Order objord = [Select Id FROM Order limit 1];
        List<ARTL_TaskEmailController.FlowInput> lstinput = new List<ARTL_TaskEmailController.FlowInput>();
        ARTL_TaskEmailController.FlowInput input = new ARTL_TaskEmailController.FlowInput();
        input.recordId = objord.Id;
        input.templateName = 'ARTL_LOC_Reject_Acknowledgment';
        input.emailType = 'LOCReject';
        lstinput.add(input);
        
        if(!lstinput.isEmpty()){
            ARTL_TaskEmailController.sendWelcomeEmail(lstinput);
        }
    }
            @isTest
    private static void NonDeemedTest() {
        Order objord = [Select Id FROM Order limit 1];
        List<ARTL_TaskEmailController.FlowInput> lstinput = new List<ARTL_TaskEmailController.FlowInput>();
        ARTL_TaskEmailController.FlowInput input = new ARTL_TaskEmailController.FlowInput();
        input.recordId = objord.Id;
        input.templateName = 'Non_Deemed_LOC';
        input.emailType = 'NonDeemedEmail';
        lstinput.add(input);
        
        if(!lstinput.isEmpty()){
            ARTL_TaskEmailController.sendWelcomeEmail(lstinput);
        }
    }
               @isTest
    private static void DeemedTest() {
        Order objord = [Select Id FROM Order limit 1];
        List<ARTL_TaskEmailController.FlowInput> lstinput = new List<ARTL_TaskEmailController.FlowInput>();
        ARTL_TaskEmailController.FlowInput input = new ARTL_TaskEmailController.FlowInput();
        input.recordId = objord.Id;
        input.templateName = 'LOC_Deemed_acceptance_mail_Primary_Sec';
        input.emailType = 'DeemedEmail';
        lstinput.add(input);
        
        if(!lstinput.isEmpty()){
            ARTL_TaskEmailController.sendEmailtoDIRS(lstinput);
        }
    }
}