/******************************************************************************************************
* @Author:      Prabanch  <prabhanch.nath@salesforce.com >
* @Company:     Salesforce
* @Date:        13th Feb 2024
* @Reviewer:
* @Review Date:
* @Description: This  is used for Attribute Validation feature.
* ++++++++++++++++++++++ Changes Implemented / Modification Log ++++++++++++++++++++++++++++++++++++++
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1. SFDC-                              
*******************************************************************************************************/

@isTest(SeeAllData=false)
public class ARTL_ValidateESMQuoteAttFieldTest {



    /*

        Normal Scenario : When Source and Target Products are in Same Quote
    */ 
    @isTest
    static void invokeMethodTest() {
        //User usr = [Select Id from user limit 1];

        // Run test as the specified user
       // System.runAs(usr) {

            Test.startTest();

            Quote qRec = [Select Id from Quote where Name='Test Quote0' Limit 1];

            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> optionsMap = new Map<String, Object>();
            Map<String, Object> inputMap = new Map<String, Object>{'quoteId' => qRec.Id};



            ARTL_ValidateESMQuoteAttField invokeAttValidationIp = new ARTL_ValidateESMQuoteAttField();
            Boolean result = invokeAttValidationIp.invokeMethod('validateAttribute', inputMap,outputMap,optionsMap);



            //System.assertEquals(result, true);
            Test.stopTest();
        //}
    }


    /*

        Scenario : When Source is in asset list and Target Products is in MAcd Quote
    */ 
    @isTest
    static void invokeAssetMehodTest() {
       // User usr = [Select Id from user limit 1];

        // Run test as the specified user
        //System.runAs(usr) {

            Test.startTest();

            Quote qRec = [Select Id from Quote where Name ='Test Quote2' Limit 1];

            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> optionsMap = new Map<String, Object>();
            Map<String, Object> inputMap = new Map<String, Object>{'quoteId' => qRec.Id};

            List<Asset> assetList = new List<Asset>();
            assetList=[Select Id, Product2.Name, vlocity_cmt__AssetReferenceId__c,product2Id, vlocity_cmt__RootItemId__c , vlocity_cmt__ParentItemId__c,vlocity_cmt__LineNumber__c, Price from Asset];

            system.debug('assetList **'+JSON.serializePretty(assetList));
            system.debug('assetList Product **'+JSON.serializePretty(assetList[0].Product2.Name));
            system.debug('assetList Product **'+assetList[0].Product2.Name);
           

            ARTL_ValidateESMQuoteAttField invokeAttValidationIp = new ARTL_ValidateESMQuoteAttField();
            Boolean result = invokeAttValidationIp.invokeMethod('validateAttribute', inputMap,outputMap,optionsMap);

            //System.assertEquals('');
            Test.stopTest();

       // }
    }


     /*

        Scenario : When Source  and Target Products are in different Quote
    */ 

    @isTest
    static void invokeDifferentCartMethodTest() {
        //User usr = [Select Id from user limit 1];

        // Run test as the specified user
        //System.runAs(usr) {

            Test.startTest();

            Quote qRec = [Select Id from Quote where Name ='Test Quote1' Limit 1];

            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> optionsMap = new Map<String, Object>();
            Map<String, Object> inputMap = new Map<String, Object>{'quoteId' => qRec.Id};
            //Map<String, Object> inputMap = new Map<String, Object>{'quoteId' => quoteList[0].Id};

            ARTL_ValidateESMQuoteAttField invokeAttValidationIp = new ARTL_ValidateESMQuoteAttField();
            Boolean result = invokeAttValidationIp.invokeMethod('validateAttribute', inputMap,outputMap,optionsMap);

            //System.assertEquals('');
            Test.stopTest();

        //}
    }

    /*

        Scenario : Trying Negative Scenarios 
    */ 

    @isTest
    static void invokeNegativeMethodTestv1() {
       // User usr = [Select Id from user limit 1];

        // Run test as the specified user
        //System.runAs(usr) {

            Test.startTest();

            //Quote qRec = [Select Id from Quote Name ='Test Quote2' Limit 1];

            Map<String, Object> outputMap = new Map<String, Object>();
            Map<String, Object> optionsMap = new Map<String, Object>();
            Map<String, Object> inputMap = new Map<String, Object>{'quoteId' => ''};
            //Map<String, Object> inputMap = new Map<String, Object>{'quoteId' => quoteList[0].Id};

            ARTL_ValidateESMQuoteAttField invokeAttValidationIp = new ARTL_ValidateESMQuoteAttField();
            Boolean result = invokeAttValidationIp.invokeMethod('validateAttribute', inputMap,outputMap,optionsMap);

            //System.assertEquals('');
            Test.stopTest();
       // }

        
    }


    @testSetup
    static void setup() {
            User usr = ARTL_TestDataFactory.getUser();

            /*Account[] accounts =new Account[3];
            Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
            //Id billingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
            //Id serviceAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
            accounts[0] = new Account(Name = 'Test Business Account',RecordTypeId = businessAccountRecordTypeId , vlocity_cmt__Active__c='Yes' , vlocity_cmt__Status__c ='Active');
            //accounts[1] = new Account(Name = 'Test Billing Account',RecordTypeId  = billingAccountRecordTypeId, vlocity_cmt__Active__c='Yes' , vlocity_cmt__Status__c ='Active');
            //accounts[2] = new Account(Name = 'Test Service Account',RecordTypeId  = serviceAccountRecordTypeId, vlocity_cmt__Active__c='Yes' , vlocity_cmt__Status__c ='Active');
            insert accounts;*/

            //Set<Id> accountIdSet = new Set<Id>{accounts[0].Id};

            List<Account> accountList = ARTL_TestDataFactory.createAccount('Business', true, 1);
            accountList[0].vlocity_cmt__Active__c ='Yes';
            accountList[0].vlocity_cmt__Status__c ='Active';
            update accountList;

            Set<Id> accountIdSet = new Set<Id>{accountList[0].Id};

            

            List<vlocity_cmt__PriceList__c> vlocityPriceList = ARTL_TestDataFactory.createVlocityPriceList(Test.getStandardPricebookId(), true, 1);

            List<Opportunity> opportunityList = ARTL_TestDataFactory.createOpportunity(accountIdSet, 'Prospecting', vlocityPriceList[0].Id, true, 1);

            /*List<Quote> quoteList = ARTL_TestDataFactory.createQuote(opportunityList[0].Id, vlocityPriceList[0].Id, Test.getStandardPricebookId(), true, 1); */

            List<Quote> quoteList = ARTL_TestDataFactory.createQuote(opportunityList[0].Id, vlocityPriceList[0].Id, Test.getStandardPricebookId(), true, 4);


            List<String> randomStrings = new List<String>();

            for (Integer i = 0; i < 15; i++) {
                randomStrings.add(String.valueOf(Crypto.getRandomLong()));
            }
        
            /*Set<String> productNames = new Set<String>{
                'Internet',
                'Primary Link',
                'Enterprise Connectivity Routers',
                'Secondary Internet Link'
            };

            Set<String> productCodes = new Set<String>{
                'Internet',
                'Primary_Link',
                'Enterprise_Connectivity_Routers',
                'Secondary_Internet_Link'
            };*/


            String productNamesCustomLabel = System.Label.ProductNameForValidation;

            Set<String> productNames = new Set<String>();

            String[] nameParts = productNamesCustomLabel.split(',');

            for(String part : nameParts) {
                productNames.add(part.trim()); 
            }

            String productCodesCustomLabel = System.Label.ProductCodesForValidation;

            Set<String> productCodes = new Set<String>();

            String[] codeParts = productCodesCustomLabel.split(',');

            for(String part : codeParts) {
                productCodes.add(part.trim()); 
            }


            List<Product2> productList = ARTL_TestDataFactory.createProduct(productNames, productCodes, true, 4);

            //system.debug('productList **'+JSON.serializePretty(productList));


            Set<Id> productIdSet = new Set<Id>();

            for(Product2 product : productList) {
                productIdSet.add((Id)product.Id);
            }



            Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(), 
                                                        Name = 'TestPricebook', 
                                                        IsActive = true);

            List<PricebookEntry> pbeEntries = ARTL_TestDataFactory.createPricebookEntry(productIdSet, standardBook.Id, true, 4);

            List<QuoteLineItem> qliListFinal = new List<QuoteLineItem>();

            qliListFinal = createSameQuoteQliData(quoteList, randomStrings, pbeEntries , productList,accountList);

            List<vlocity_cmt__QuoteLineItemRelationship__c> qliR = new List<vlocity_cmt__QuoteLineItemRelationship__c>{
                new vlocity_cmt__QuoteLineItemRelationship__c(
                    vlocity_cmt__QuoteId__c = quoteList[0].Id,
                    vlocity_cmt__QuoteLineItemId__c = qliListFinal[1].Id,
                    vlocity_cmt__RelatedAssetReferenceId__c = randomStrings[0],
                    vlocity_cmt__RelatedQuoteLineItemId__c = qliListFinal[0].Id,
                    vlocity_cmt__RelationshipType__c = 'ReliesOn',
                    Name = 'SameQuoteScenario'
                ),
                new vlocity_cmt__QuoteLineItemRelationship__c(
                    vlocity_cmt__QuoteId__c = quoteList[1].Id,
                    vlocity_cmt__QuoteLineItemId__c = qliListFinal[2].Id,     // secondary link of different quote 
                    vlocity_cmt__RelatedAssetReferenceId__c = randomStrings[0],
                    vlocity_cmt__RelatedQuoteLineItemId__c = qliListFinal[0].Id,  // internet of first quote
                    vlocity_cmt__RelationshipType__c = 'ReliesOn',
                    Name = 'DifferentQuoteScenario'
                ),
                new vlocity_cmt__QuoteLineItemRelationship__c(
                    vlocity_cmt__QuoteId__c = quoteList[2].Id,
                    vlocity_cmt__QuoteLineItemId__c = qliListFinal[3].Id,
                    vlocity_cmt__RelatedAssetReferenceId__c = randomStrings[5],
                    vlocity_cmt__RelatedQuoteLineItemId__c = null,
                    vlocity_cmt__RelationshipType__c = 'ReliesOn',
                    Name = 'AssetScenario'
                )
            };

            insert qliR;

    }


    public static List<QuoteLineItem> createSameQuoteQliData(List<Quote> quoteList, List<String> randomStrings, List<PricebookEntry> pbeEntries ,List<Product2> prodList , List<Account> accountList) {


        

        Map<Id,PricebookEntry> mapList = new Map<Id,PricebookEntry>();
        for(PricebookEntry peRec : pbeEntries){
            mapList.put(peRec.Product2Id,peRec);
        }
        

        Product2 internetRec = new Product2();
        Product2 primaryRec = new Product2();
        Product2 enterpriseRec = new Product2();
        Product2 secondaryRec = new Product2();
        List<QuoteLineItem> result = new List<QuoteLineItem>();

        for(Product2 pRec :prodList){

            if(pRec.Name == 'Internet'){
                internetRec = pRec;
            }
            else if(pRec.Name == 'Primary Link'){
                primaryRec = pRec;
            }
            else if(pRec.Name == 'Enterprise Connectivity Routers'){
                enterpriseRec = pRec;
            }
            else if(pRec.Name == 'Secondary Internet Link'){
                secondaryRec = pRec;
            }
        }

       
        QuoteLineItem qli1;// = new QuoteLineItem();
        qli1 = new QuoteLineItem(
                QuoteId = quoteList[0].Id,
                vlocity_cmt__Product2Id__c = internetRec.Id,
                Product2 = internetRec,
                vlocity_cmt__AttributeSelectedValues__c='{"ATT_RATIO":"1:1","ATT_SubProductName":"Enterprise ILL","ATT_HANDOVER_TYPE":"NNI"}',
                vlocity_cmt__RootItemId__c = randomStrings[0],
                vlocity_cmt__ParentItemId__c = null,
                vlocity_cmt__LineNumber__c='0001',
                UnitPrice = 0,
                vlocity_cmt__AssetReferenceId__c = randomStrings[0],
                //PricebookEntryId = pbeEntries[0].Id,
                PricebookEntryId = ((PricebookEntry)mapList.get(internetRec.Id)).Id ,
                Quantity = 1
        );

        insert qli1;

       

        result.add(qli1);// internet

        //qli= new QuoteLineItem();
        QuoteLineItem qli2;
        qli2 = new QuoteLineItem(
            QuoteId = quoteList[0].Id,
            vlocity_cmt__Product2Id__c = primaryRec.Id,
            Product2 = primaryRec,
            vlocity_cmt__AttributeSelectedValues__c='{"ATT_ROUTING_TYPE":"Static","ATT_DDOS_TYPE":"No","ATT_ROUTING_PROTOCOL":"Static","ATT_MTU_SIZE":"1472","ATT_ENTERPRISE_CONNECTIVITY_TYPE":"Primary","ATT_CROSS_CONNECT_REQD":"No","ATT_DDOS_REQUIRED":"No","ATT_IP_REQUIRED":"IPv4","ATT_UPTIME_SLA":"99%","ATT_CPE":"Single CPE","ATT_SERVICE_TYPE":"Fully Managed","ATT_REDUNDANCY":"Yes","ATT_LAST_MILE":"Single Last Mile","ATT_POP":"Single POP","ATT_CONTRACT_TERM":"12 Months","ATT_INTERFACE":"Fast Ethernet","ATT_MEDIA":"FTTH","ATT_PORT_BANDWIDTH":"2 Mbps","ATT_ACCESS_BANDWIDTH":"2 Mbps"}',
            vlocity_cmt__RootItemId__c = randomStrings[0],
            vlocity_cmt__ParentItemId__c = randomStrings[0],
            vlocity_cmt__LineNumber__c='0001.0001',
            UnitPrice = 0,
            vlocity_cmt__AssetReferenceId__c = randomStrings[1],
            //PricebookEntryId = pbeEntries[1].Id,
            PricebookEntryId = ((PricebookEntry)mapList.get(primaryRec.Id)).Id ,
            Quantity = 1
        );

        insert qli2;

       

        //qli= new QuoteLineItem();
        QuoteLineItem qli3;
        qli3 = new QuoteLineItem(
            QuoteId = quoteList[0].Id,
            vlocity_cmt__Product2Id__c = enterpriseRec.Id,
            Product2 = enterpriseRec,
            vlocity_cmt__AttributeSelectedValues__c='{"ATT_Is_UTM":"No","ATT_HardwareRedundancyRequired":"No","ATT_ROUTER_MODEL":"FG_40F","ATT_ROUTER_MAKE":"Fort iGate","ATT_ROUTER_TYPE":"Standard","ATT_ROUTER_LEASE_TYPE":"Operation Lease"}',
            vlocity_cmt__RootItemId__c = randomStrings[0],
            vlocity_cmt__ParentItemId__c = randomStrings[1],
            vlocity_cmt__LineNumber__c='0001.0001.0001',
            UnitPrice = 0,
            vlocity_cmt__AssetReferenceId__c = randomStrings[2],
            //PricebookEntryId = pbeEntries[2].Id,
            PricebookEntryId = ((PricebookEntry)mapList.get(enterpriseRec.Id)).Id ,
            Quantity = 1
        );

        insert qli3;

       

       // qli= new QuoteLineItem();
       QuoteLineItem qli4;
       qli4 = new QuoteLineItem(
            QuoteId = quoteList[0].Id,
            Product2 = secondaryRec,
            //Product2.Name = secondaryRec.Name,
            vlocity_cmt__AttributeSelectedValues__c='{"ATT_ACCESS_BANDWIDTH":"2 Mbps","ATT_PORT_BANDWIDTH":"2 Mbps","ATT_MEDIA":"FTTH","ATT_INTERFACE":"Fast Ethernet","ATT_CONTRACT_TERM":"12 Months","ATT_LAST_MILE":"Single Last Mile","ATT_POP":"Single POP","ATT_REDUNDANCY":"Yes","ATT_SERVICE_TYPE":"Fully Managed","ATT_CPE":"Single CPE","ATT_UPTIME_SLA":"99%","ATT_IP_REQUIRED":"IPv4","ATT_DDOS_REQUIRED":"No","ATT_CROSS_CONNECT_REQD":"No","ATT_ENTERPRISE_CONNECTIVITY_TYPE":"Secondary","ATT_ROUTING_PROTOCOL":"Static","ATT_MTU_SIZE":"1472","ATT_DDOS_TYPE":"No","ATT_ROUTING_TYPE":"Private BGP","ATT_HANDOVER_TYPE":"NNI","ATT_BUSINESS_UNIT":"EGB"}',
            vlocity_cmt__Product2Id__c = secondaryRec.Id,
            vlocity_cmt__RootItemId__c = randomStrings[3],
            vlocity_cmt__ParentItemId__c = null,
            vlocity_cmt__LineNumber__c='0002',
            UnitPrice = 0,
            vlocity_cmt__AssetReferenceId__c = randomStrings[3],
            //PricebookEntryId = pbeEntries[3].Id,
            PricebookEntryId = ((PricebookEntry)mapList.get(secondaryRec.Id)).Id ,
            Quantity = 1
        );

        insert qli4;

       

        result.add(qli4);// Secondary Internet Link

        


        QuoteLineItem qli5;
        qli5 = new QuoteLineItem(
            QuoteId = quoteList[0].Id,
            Product2 = enterpriseRec,
            vlocity_cmt__AttributeSelectedValues__c='{"ATT_Is_UTM":"No","ATT_HardwareRedundancyRequired":"No","ATT_ROUTER_MODEL":"FG_40F","ATT_ROUTER_MAKE":"Fort iGate","ATT_ROUTER_TYPE":"Standard","ATT_ROUTER_LEASE_TYPE":"Operation Lease"}',
            vlocity_cmt__Product2Id__c = enterpriseRec.Id,
            vlocity_cmt__RootItemId__c = randomStrings[3],
            vlocity_cmt__ParentItemId__c = randomStrings[3],
            UnitPrice = 0,
            vlocity_cmt__LineNumber__c='0002.0002',
            vlocity_cmt__AssetReferenceId__c = randomStrings[4],
            //PricebookEntryId = pbeEntries[3].Id,
            PricebookEntryId = ((PricebookEntry)mapList.get(enterpriseRec.Id)).Id ,
            Quantity = 1
        );

        insert qli5;

       
        system.debug('result '+JSON.serializePretty(result));



        /* trying scneraio 3 where we are working in different cart where primary quote will be will be Secondary Link 



        */

       QuoteLineItem qli6;
       qli6 = new QuoteLineItem(
            QuoteId = quoteList[1].Id,
            Product2 = secondaryRec,
            //Product2.Name = secondaryRec.Name,
            vlocity_cmt__AttributeSelectedValues__c='{"ATT_ACCESS_BANDWIDTH":"2 Mbps","ATT_PORT_BANDWIDTH":"2 Mbps","ATT_MEDIA":"FTTH","ATT_INTERFACE":"Fast Ethernet","ATT_CONTRACT_TERM":"12 Months","ATT_LAST_MILE":"Single Last Mile","ATT_POP":"Single POP","ATT_REDUNDANCY":"Yes","ATT_SERVICE_TYPE":"Fully Managed","ATT_CPE":"Single CPE","ATT_UPTIME_SLA":"99%","ATT_IP_REQUIRED":"IPv4","ATT_DDOS_REQUIRED":"No","ATT_CROSS_CONNECT_REQD":"No","ATT_ENTERPRISE_CONNECTIVITY_TYPE":"Secondary","ATT_ROUTING_PROTOCOL":"Static","ATT_MTU_SIZE":"1472","ATT_DDOS_TYPE":"No","ATT_ROUTING_TYPE":"Private BGP","ATT_HANDOVER_TYPE":"NNI","ATT_BUSINESS_UNIT":"EGB"}',
            vlocity_cmt__Product2Id__c = secondaryRec.Id,
            vlocity_cmt__RootItemId__c = randomStrings[3],
            vlocity_cmt__ParentItemId__c = null,
            vlocity_cmt__LineNumber__c='0002',
            UnitPrice = 0,
            vlocity_cmt__AssetReferenceId__c = randomStrings[3],
            //PricebookEntryId = pbeEntries[3].Id,
            PricebookEntryId = ((PricebookEntry)mapList.get(secondaryRec.Id)).Id ,
            Quantity = 1
        );

        insert qli6;

       
        result.add(qli6);
       


        QuoteLineItem qli7;
        qli7 = new QuoteLineItem(
            QuoteId = quoteList[1].Id,
            Product2 = enterpriseRec,
            vlocity_cmt__AttributeSelectedValues__c='{"ATT_Is_UTM":"No","ATT_HardwareRedundancyRequired":"No","ATT_ROUTER_MODEL":"FG_40F","ATT_ROUTER_MAKE":"Fort iGate","ATT_ROUTER_TYPE":"Standard","ATT_ROUTER_LEASE_TYPE":"Operation Lease"}',
            vlocity_cmt__Product2Id__c = enterpriseRec.Id,
            vlocity_cmt__RootItemId__c = randomStrings[3],
            vlocity_cmt__ParentItemId__c = randomStrings[3],
            UnitPrice = 0,
            vlocity_cmt__LineNumber__c='0002.0002',
            vlocity_cmt__AssetReferenceId__c = randomStrings[4],
            //PricebookEntryId = pbeEntries[3].Id,
            PricebookEntryId = ((PricebookEntry)mapList.get(enterpriseRec.Id)).Id ,
            Quantity = 1
        );

        insert qli7;

        Asset ast = new Asset();
        ast.Name = internetRec.Name;
        ast.Product2 = internetRec;
        ast.Product2Id= internetRec.Id;
        ast.AccountId = accountList[0].Id;
        ast.vlocity_cmt__AssetReferenceId__c = randomStrings[5];
        ast.vlocity_cmt__BillingAccountId__c  = accountList[0].Id;
        ast.vlocity_cmt__ServiceAccountId__c   =accountList[0].Id;
        //ast.vlocity_cmt__Product2Id__c = internetRec.Id;
        ast.vlocity_cmt__AttributeSelectedValues__c='{"ATT_RATIO":"1:1","ATT_SubProductName":"Enterprise ILL","ATT_HANDOVER_TYPE":"NNI"}';
        ast.vlocity_cmt__RootItemId__c = randomStrings[5];
        ast.vlocity_cmt__ParentItemId__c = null;
        ast.vlocity_cmt__LineNumber__c ='0003';
        ast.vlocity_cmt__PricebookEntryId__c = ((PricebookEntry)mapList.get(internetRec.Id)).Id;
        ast.price =0;
        //ast.vlocity_cmt__OrderProductId__c=ois[0].Id;
        

        insert ast;


        Asset ast1 = new Asset();
        ast1.Name = primaryRec.Name;
        ast1.Product2 = primaryRec;
        ast1.Product2Id= primaryRec.Id;
        ast1.AccountId = accountList[0].Id;
        ast1.vlocity_cmt__AssetReferenceId__c = randomStrings[6];
        ast1.vlocity_cmt__BillingAccountId__c  = accountList[0].Id;
        ast1.vlocity_cmt__ServiceAccountId__c   =accountList[0].Id;
        //ast1.vlocity_cmt__Product2Id__c = primaryRec.Id;
        ast1.vlocity_cmt__AttributeSelectedValues__c='{"ATT_ROUTING_TYPE":"Static","ATT_DDOS_TYPE":"No","ATT_ROUTING_PROTOCOL":"Static","ATT_MTU_SIZE":"1472","ATT_ENTERPRISE_CONNECTIVITY_TYPE":"Primary","ATT_CROSS_CONNECT_REQD":"No","ATT_DDOS_REQUIRED":"No","ATT_IP_REQUIRED":"IPv4","ATT_UPTIME_SLA":"99%","ATT_CPE":"Single CPE","ATT_SERVICE_TYPE":"Fully Managed","ATT_REDUNDANCY":"Yes","ATT_LAST_MILE":"Single Last Mile","ATT_POP":"Single POP","ATT_CONTRACT_TERM":"12 Months","ATT_INTERFACE":"Fast Ethernet","ATT_MEDIA":"FTTH","ATT_PORT_BANDWIDTH":"2 Mbps","ATT_ACCESS_BANDWIDTH":"2 Mbps"}';
        ast1.vlocity_cmt__RootItemId__c = randomStrings[5];
        ast1.vlocity_cmt__ParentItemId__c = randomStrings[5];
        ast1.vlocity_cmt__LineNumber__c ='0003.0001';
        ast1.vlocity_cmt__PricebookEntryId__c = ((PricebookEntry)mapList.get(primaryRec.Id)).Id;
        ast1.price =0;
        //ast.vlocity_cmt__OrderProductId__c=ois[1].Id;
        

        insert ast1;


        Asset ast2 = new Asset();
        ast2.Name = enterpriseRec.Name;
        ast2.Product2 = enterpriseRec;
        ast2.Product2Id= enterpriseRec.Id;
        ast2.AccountId = accountList[0].Id;
        ast2.vlocity_cmt__AssetReferenceId__c = randomStrings[7];
        ast2.vlocity_cmt__BillingAccountId__c  = accountList[0].Id;
        ast2.vlocity_cmt__ServiceAccountId__c   =accountList[0].Id;
       // ast2.vlocity_cmt__Product2Id__c = enterpriseRec.Id;
        ast2.vlocity_cmt__AttributeSelectedValues__c='{"ATT_Is_UTM":"No","ATT_HardwareRedundancyRequired":"No","ATT_ROUTER_MODEL":"FG_40F","ATT_ROUTER_MAKE":"Fort iGate","ATT_ROUTER_TYPE":"Standard","ATT_ROUTER_LEASE_TYPE":"Operation Lease"}';
        ast2.vlocity_cmt__RootItemId__c = randomStrings[5];
        ast2.vlocity_cmt__ParentItemId__c = randomStrings[6];
        ast2.vlocity_cmt__LineNumber__c ='0003.0001.0001';
        ast2.vlocity_cmt__PricebookEntryId__c = ((PricebookEntry)mapList.get(enterpriseRec.Id)).Id;
        ast2.price =0;
       
        insert ast2;



       QuoteLineItem qli8;
       qli8 = new QuoteLineItem(
            QuoteId = quoteList[2].Id,
            Product2 = secondaryRec,
            //Product2.Name = secondaryRec.Name,
            vlocity_cmt__AttributeSelectedValues__c='{"ATT_ACCESS_BANDWIDTH":"2 Mbps","ATT_PORT_BANDWIDTH":"2 Mbps","ATT_MEDIA":"FTTH","ATT_INTERFACE":"Fast Ethernet","ATT_CONTRACT_TERM":"12 Months","ATT_LAST_MILE":"Single Last Mile","ATT_POP":"Single POP","ATT_REDUNDANCY":"Yes","ATT_SERVICE_TYPE":"Fully Managed","ATT_CPE":"Single CPE","ATT_UPTIME_SLA":"99%","ATT_IP_REQUIRED":"IPv4","ATT_DDOS_REQUIRED":"No","ATT_CROSS_CONNECT_REQD":"No","ATT_ENTERPRISE_CONNECTIVITY_TYPE":"Secondary","ATT_ROUTING_PROTOCOL":"Static","ATT_MTU_SIZE":"1472","ATT_DDOS_TYPE":"No","ATT_ROUTING_TYPE":"Private BGP","ATT_HANDOVER_TYPE":"NNI","ATT_BUSINESS_UNIT":"EGB"}',
            vlocity_cmt__Product2Id__c = secondaryRec.Id,
            vlocity_cmt__RootItemId__c = randomStrings[3],
            vlocity_cmt__ParentItemId__c = null,
            vlocity_cmt__LineNumber__c='0002',
            UnitPrice = 0,
            vlocity_cmt__AssetReferenceId__c = randomStrings[3],
            //PricebookEntryId = pbeEntries[3].Id,
            PricebookEntryId = ((PricebookEntry)mapList.get(secondaryRec.Id)).Id ,
            Quantity = 1
        );

        insert qli8;

       
        result.add(qli8);
       


        QuoteLineItem qli9;
        qli9 = new QuoteLineItem(
            QuoteId = quoteList[2].Id,
            Product2 = enterpriseRec,
            vlocity_cmt__AttributeSelectedValues__c='{"ATT_Is_UTM":"No","ATT_HardwareRedundancyRequired":"No","ATT_ROUTER_MODEL":"FG_40F","ATT_ROUTER_MAKE":"Fort iGate","ATT_ROUTER_TYPE":"Standard","ATT_ROUTER_LEASE_TYPE":"Operation Lease"}',
            vlocity_cmt__Product2Id__c = enterpriseRec.Id,
            vlocity_cmt__RootItemId__c = randomStrings[3],
            vlocity_cmt__ParentItemId__c = randomStrings[3],
            UnitPrice = 0,
            vlocity_cmt__LineNumber__c='0002.0002',
            vlocity_cmt__AssetReferenceId__c = randomStrings[4],
            //PricebookEntryId = pbeEntries[3].Id,
            PricebookEntryId = ((PricebookEntry)mapList.get(enterpriseRec.Id)).Id ,
            Quantity = 1
        );

        insert qli9;
       
        return result;

    }
}