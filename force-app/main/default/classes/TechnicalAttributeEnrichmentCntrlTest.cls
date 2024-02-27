@isTest
public class TechnicalAttributeEnrichmentCntrlTest {
    
    @testSetup
    static void dataCreation() {
        vlocity_cmt__PriceList__c priceList = new 	vlocity_cmt__PriceList__c();
        priceList.Name ='Pricelist For Test class';
        priceList.vlocity_cmt__Code__c='PricelistForTestclass';
        priceList.vlocity_cmt__Pricebook2Id__c =Test.getStandardPricebookId();
        insert priceList;
        
        List<product2> productList = new List<product2>();
        Product2 objProduct = new Product2(Name = 'Test product1', family = 'Internet',ProductCode='3c6df3ca-4424-4131-bde3-c3ea5d5b5925',
                                           ARTL_TechnicalProduct__c='ABC_x',
                                           vlocity_cmt__AttributeMetadata__c = '{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":300,"Code__c":"ATC_ENTERPRISE_DETAILS","Name":"Details","id":"a0Z72000000v9Y2EAI","productAttributes":{"totalSize":1,"messages":[],"records":[{"messages":[],"code":"ATT_SubProductName","multiselect":false,"dataType":"text","inputType":"text","required":true,"readonly":true,"disabled":true,"filterable":false,"attributeId":"a0a72000006EcjVAAS","label":"Sub Product Name","displaySequence":570,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":true,"disabled":true,"defaultValue":"Enterprise ILL"}],"userValues":null}]}}]}',
                                           vlocity_cmt__AttributeDefaultValues__c = '{"ATT_SubProductName":"Enterprise ILL"}',ARTL_SubProductName__c = 'Enterprise ILL' , ARTL_LSIRequired__c=true,
                                           vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_CPE_DETAILS":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0T000001YRpeQAG","attributeid__c":"a0a0T000001bLn9QAE","attributecategoryid__c":"a0Z0T0000023iSyUAI","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_CPE_DETAILS","categoryname__c":"CPE Details","attributeuniquecode__c":"VEPC_ATTR_SDWAN_DEVICE_MODEL","attributeconfigurable__c":true,"attributedisplaysequence__c":"40","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"SD WAN Device Model","displaysequence__c":"null","categorydisplaysequence__c":6230,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0X0T00000CPPX4UAP","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"MX67C","valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"MX67C","sequence":10,"id":"fcc73ca9-63b9-affd-b89b-b806caa9e456","displayText":"MX67C"}],"values":[{"value":"MX67C","sequence":10,"id":"fcc73ca9-63b9-affd-b89b-b806caa9e456","displayText":"MX67C"},{"value":"MX68CW","sequence":20,"id":"23405c41-9880-d9c1-8ce2-fff7e1bd8de5","displayText":"MX68CW"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0T000001YRpeQAG","attributeid__c":"a0a0T000001bLnAQAU","attributecategoryid__c":"a0Z0T0000023iSyUAI","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_CPE_DETAILS","categoryname__c":"CPE Details","attributeuniquecode__c":"VEPC_ATTR_SDWAN_LICENSE_TYPE","attributeconfigurable__c":true,"attributedisplaysequence__c":"50","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"SD WAN License Type","displaysequence__c":"null","categorydisplaysequence__c":6230,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0X0T00000CPPX5UAP","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Enterprise","valuedatatype__c":"Picklist","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Enterprise","sequence":10,"id":"f5b6ebec-b4df-c3a4-7a13-62aae7ee2a5b","displayText":"Enterprise"}],"values":[{"value":"Enterprise","sequence":10,"id":"f5b6ebec-b4df-c3a4-7a13-62aae7ee2a5b","displayText":"Enterprise"},{"value":"Advanced Security","sequence":20,"id":"f88b390f-e7d5-20ad-18b5-2bbdf98095a9","displayText":"Advanced Security"},{"value":"Secure SD-WAN Plus","sequence":30,"id":"5d07e8d4-4e54-087e-921d-75610f61f7f7","displayText":"Secure SD-WAN Plus"}]},"$$AttributeDefinitionEnd$$":null}]}'
                                          );
        productList.add(objProduct);
        Insert productList;
        // Create a Pricebook Entry
        List<PricebookEntry> pbEntryList = new List<PricebookEntry>();
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = productList[0].Id,
            UnitPrice = 100.00, 	// Set the unit price as needed
            IsActive = true
        );
        pbEntryList.add(pbEntry);
        insert pbEntryList;
        
        List<user> userList = new List<user>();
        Profile p = [SELECT id, Name FROM Profile WHERE Name = 'Sales' LIMIT 1];  
        Profile admin = [SELECT id, Name FROM Profile WHERE Name = 'System administrator' LIMIT 1];  
        User KAM = new User(firstname= 'Samuel',
                            lastname='Oak',
                            Alias='Samuel',
                            email = 'testemail665411@email.com',
                            username= 'testemail665411@email.com', 
                            profileId= p.id, 
                            emailencodingkey='UTF-8',
                            languagelocalekey='en_US',
                            localesidkey='en_US',
                            timezonesidkey='America/Los_Angeles');
        userList.add(KAM);    
        User testUser2 = new User(
            FirstName = 'Test2test',
            LastName = 'User2test',
            Alias = 'tuserest',
            Email = 'testuser2test@example.com',
            Username = 'testuser2test@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Project Manager'].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            phone = '1234567890'
        );
        userList.add(testUser2);       
        insert userList;
        Id recordtypeid=[select id from recordtype where name='Business' limit 1].Id;
        Account acc = new Account(Name = 'Test Account',BillingCity = 'Panchkula',
                                  BillingCountry = 'Haryana',BillingPostalCode = '134109',BillingState = 'India',BillingStreet = 'Panchkula',
                                  ARTL_Category__c = 'A', ARTL_Legal_Entity__c = 'NXTRA DATA LIMITED',artl_customer_segment__c = 'AB',
                                  artl_business_circle_region__c = 'NCR' , artl_vertical_segment__c= 'BFI' ,recordtypeid=recordtypeid);
        insert acc; 
        Contact contactRec = new Contact(FirstName 				= 'Test',
                                         LastName				= 'Test',
                                         Phone					= '9887654321', 
                                         Email					= 'test@test.com',
                                         ARTL_Designation__c 	= 'test', 
                                         ARTL_Contact_Role__c 	= 'Billing Contact',
                                         Country_Code__c = '41',
                                         AccountId 				= acc.Id);
        insert contactRec;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.Opportunity_Type__c = 'Rate Revision';
        opp.PM__c = testUser2.id; 
        insert opp;
        
        Quote q = new Quote();
        q.OpportunityId = opp.Id;
        q.Name = 'Quote Test';
        //q.AccountId = acc.id;
        q.vlocity_cmt__PriceListId__c=priceList.Id;
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.Status ='Draft';
        q.artl_demo_duration__c = '15';
        insert q;
        
        QuoteLineItem qli = new QuoteLineItem(
            Product2Id = productList[0].Id,
            QuoteId = q.Id,
            PricebookEntryId = pbEntryList[0].Id,
            UnitPrice = pbEntryList[0].UnitPrice,
            Quantity=1,
            Capex__c=10000,
            Annual_Recurring_Charge__c=25000,
            vlocity_cmt__OneTimeCharge__c=20000,
            ARTL_ARCFloorRate__c=50000,
            ARTL_NRCFloorRate__c=50000,
            vlocity_cmt__LineNumber__c = '',
            CND__c = system.today()-7,
            RFS__c = system.today()-7,
            vlocity_cmt__RootItemId__c = '5dcd5d9e-cbe4-7390-d1e5-f532a3ae539d',
            vlocity_cmt__AssetReferenceId__c = '5dcd5d9e-cbe4-7390-d1e5-f532a3ae539d',
            vlocity_cmt__AttributeSelectedValues__c	= '{"ATT_SubProductName":"Enterprise ILL"}'
        );
        insert qli;
        
        Order o = new order();
        o.AccountId = acc.Id;
        o.QuoteId = q.Id;
        o.OpportunityId = opp.Id;
        o.Pricebook2Id = Test.getStandardPricebookId();
        o.ARTL_Order_Type__c = 'New';
        o.PoNumber = '123456789';
        o.artl_demo_duration__c = '15';
        o.PoDate = system.today() - 7;
        o.Status = 'Draft';
        o.EffectiveDate = system.today();
        Insert o;
        
        OrderItem testOrderItem1 = new OrderItem(
            OrderId = o.Id,
            PricebookEntryId = pbEntryList[0].Id,
            Product2Id = productList[0].Id,
            Quantity = 1,
            UnitPrice = 10, 
            QuoteLineItemId = qli.Id,
            CND__c = system.today()-7,
            RFS__c = system.today()-7,
            vlocity_cmt__RootItemId__c = '5dcd5d9e-cbe4-7390-d1e5-f532a3ae539d',
            vlocity_cmt__JSONAttribute__c = '',
            vlocity_cmt__AssetReferenceId__c = '5dcd5d9e-cbe4-7390-d1e5-f532a3ae539d',
            vlocity_cmt__AttributeMetadataChanges__c ='{"VEPC_ATTR_CPE_DELIVERY_OPTION":{"required":true}}',
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_ACCESS_BANDWIDTH":null,"ATT_CONTRACT_TERM":null,"ATT_CPE":null,"ATT_DEPENDENT_LINK_MEDIA":null,"ATT_LAST_MILE":null,"ATT_MEDIA":null,"ATT_PORT_BANDWIDTH":null,"ATT_SERVICE_TYPE":null,"ATT_CHARGE_SELECTION":null,"ATT_OFFNET_CAPEX":null}'
        );
        insert testOrderItem1;
        
    }
    
    
    @isTest
    static void testQuoteTrigger() {
        Test.startTest();
        
        Product2 objProduct = new Product2(Name = 'Test product1', family = 'Cafe',ProductCode='XYZ_1',
                                           ARTL_TechnicalProduct__c='ABC_x',
                                           vlocity_cmt__AttributeMetadata__c = '{"totalSize":1,"messages":[],"records":[{"messages":[],"displaySequence":300,"Code__c":"ATC_ENTERPRISE_DETAILS","Name":"Details","id":"a0Z72000000v9Y2EAI","productAttributes":{"totalSize":1,"messages":[],"records":[{"messages":[],"code":"ATT_SubProductName","multiselect":false,"dataType":"text","inputType":"text","required":true,"readonly":true,"disabled":true,"filterable":false,"attributeId":"a0a72000006EcjVAAS","label":"Sub Product Name","displaySequence":570,"hasRules":false,"hidden":false,"cloneable":true,"isNotTranslatable":false,"values":[{"readonly":true,"disabled":true,"defaultValue":"Enterprise ILL"}],"userValues":null}]}}]}',
                                           vlocity_cmt__AttributeDefaultValues__c = '{"ATT_SubProductName":"Enterprise ILL"}'
                                          );
        insert objProduct;
        Product2 objProduct2 = new Product2(Name = 'Test product11', family = 'Cafe',ProductCode='ABC_x');
        insert objProduct2;
        
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),Product2Id = objProduct.Id, IsActive = true);
        insert objPBE;
        List<Quote> qList=[select id,name,AccountId,Status,Pricebook2Id from Quote];
        List<Quotelineitem> Listqli = [SELECT id, quoteId,vlocity_cmt__RootItemId__c FROM QuoteLineItem   WHERE vlocity_cmt__RootItemId__c= '5dcd5d9e-cbe4-7390-d1e5-f532a3ae539d'];
        system.debug('Listqli :::' + Listqli);
        ARTL_Feasibility__c f = new ARTL_Feasibility__c();
        f.ARTL_Feasibility_ID__c = 'DSLWORK3010232833637';
        f.ARTL_QLI__c = Listqli[0].Id;
        Insert f;
        
        List<orderItem> ol = [SELECT id,orderId ,product2.Id ,product2.vlocity_cmt__JSONAttribute__c, vlocity_cmt__RootItemId__c,QuoteLineItemId FROM OrderItem WHERE vlocity_cmt__RootItemId__c = '5dcd5d9e-cbe4-7390-d1e5-f532a3ae539d' ];
        system.debug('ol[0].orderId ::' + ol);
        
        // for qli
        TechnicalAttributeHelperTest.v2Attribute = true; 
        {
            TechnicalAttributeEnrichmentController.JSONAttribute jsonAttribute = TechnicalAttributeEnrichmentController.getJSONAttribute(Listqli[0].id);
            TechnicalAttributeEnrichmentController.JSONAttribute jsonAttributes = TechnicalAttributeEnrichmentController.getJSONAttribute(ol[0].id);
        }
        
        string modifiedAttributeOnUIQLI = '[{"Id":"' + Listqli[0].Id + '","fieldVal":{"Customer Needed By Date":"2024-01-25"},"vlocity_cmt__AttributeSelectedValues__c":{"RFS":"2024-02-15","Customer Needed By Date":"2024-01-01","ATT_ACCESS_BANDWIDTH":"4 Mbps","ATT_PORT_BANDWIDTH":"4 Mbps","ATT_MEDIA":"Fiber Off-Net","ATT_INTERFACE":"10 Gig(Optical)","ATT_CONTRACT_TERM":"12 Months","ATT_POP":"Single POP","ATT_LAST_MILE":"Single Last Mile","ATT_REDUNDANCY":"No","ATT_SERVICE_TYPE":"Unmanaged","ATT_UPTIME_SLA":"99.5%","ATT_IP_REQUIRED":"IPv4","ATT_DDOS_REQUIRED":"No","ATT_CROSS_CONNECT_REQD":"No","ATT_ENTERPRISE_CONNECTIVITY_TYPE":"Primary","ATT_MTU_SIZE":"1500","ATT_THIRD_PARTY_TYPE":"Third Party Cross Connect","ATT_DDOS_TYPE":"Arbor","ATT_ROUTING_TYPE":"Private BGP","ATT_ROUTING_TABLE_BGP":"Bharti+Customer BGP","ATT_KEEPALIVE_BGPHYD":"12","ATT_BGP_PREFIX_LIMIT_BGPHYD":"4000"}}]';
        // string modifiedAttributeOnUIOLI = '[{"Id":"' + ol[0].Id + '","fieldVal":{"Customer Needed By Date":"2024-01-25"},"vlocity_cmt__AttributeSelectedValues__c":{"RFS":"2024-02-23","Customer Needed By Date":"2024-01-24","ATT_ACCESS_BANDWIDTH":"4 Mbps","ATT_PORT_BANDWIDTH":"6 Mbps","ATT_MEDIA":"FTTH","ATT_CONTRACT_TERM":"12 Months","ATT_POP":"Single POP","ATT_LAST_MILE":"Single Last Mile","ATT_REDUNDANCY":"No","ATT_SERVICE_TYPE":"Unmanaged","ATT_UPTIME_SLA":"99%","ATT_IP_REQUIRED":"IPv4","ATT_DDOS_REQUIRED":"No","ATT_CROSS_CONNECT_REQD":"No","ATT_ENTERPRISE_CONNECTIVITY_TYPE":"Primary","ATT_MTU_SIZE":"1472","ATT_THIRD_PARTY_TYPE":"Third Party Cross Connect","ATT_DDOS_TYPE":"Arbor"}},{"Id":"80272000009tScpAAE","fieldVal":{},"vlocity_cmt__AttributeSelectedValues__c":{"ATT_SubProductName":"Enterprise ILL"}},{"Id":"80272000009tScsAAE","fieldVal":{},"vlocity_cmt__AttributeSelectedValues__c":{"ATT_IP_Type":"IPv4","ATT_LAN_IPV4_SUBNET_MASK":"/32","ATT_LAN_IPV6_SUBNET_MASK":"/88"}}]';
        
        TechnicalAttributeEnrichmentController.setAttributeValues(modifiedAttributeOnUIQLI , 'QuoteLineItem');
        
        // TechnicalAttributeEnrichmentController.setAttributeValues(modifiedAttributeOnUIOLI , 'OrderItem');
        
        Test.stopTest();
    }
    
    
    
    
}