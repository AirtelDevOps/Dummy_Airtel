/*****************************************************************************************************************
Name : ARTLUpdateRateValuesTest 
==================================================================================================================
Purpose: 1.To cover Test Cases for Updating Rate Values
==================================================================================================================
History
---------------
Version      Author               Date         Detail      Features/CSR/TTP
1.0       Swapnil(SFI)  		    04.01.2024    Created   
*********/

/**
* @description Testing Data Setup
*/
@isTest
public class ARTLUpdateRateValuesTest{
    
    @testSetup 
    static void setup() {
        
        Id pbId = Test.getStandardPricebookId();
        
        //List<User> uList = BT_TestDataFactoryClass.createUser('Sales Agent',1,'User11','newuser11@testorg.com','UTF-8',
        //                                                      'UserfName','UserlName','en_US','en_US','America/Los_Angeles');
        //User testUser = uList[0];
        //insert testUser;
        //System.RunAs(testUser){
        
        Id recTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();    
        
        // Creating Account hierarchy
        //List<Account> accList = BT_TestDataFactoryClass.createActiveParentAccounts(1, recTypeId1, testUser.Id, 'GMA');
        //insert accList;
        
        
        
        //Creating Pricebook
        //Pricebook2 pbId = BT_TestDataFactoryClass.createPriceBook('B2B INR Pricebook');
        
        
        
        //Creating Attribute Category - Test Attrib Categ
        vlocity_cmt__AttributeCategory__c attrCategory = new vlocity_cmt__AttributeCategory__c();
        attrCategory.vlocity_cmt__IsActive__c = true;
        attrCategory.vlocity_cmt__Code__c = 'TEST_ATTRIB_CATEG';
        attrCategory.Name = 'Test Attrib Categ';
        attrCategory.vlocity_cmt__DisplaySequence__c = 20;
        insert attrCategory;
        
        //Creating Attributes : Model & Colour under above Attribute Category
        List<vlocity_cmt__Attribute__c> attrs = new List<vlocity_cmt__Attribute__c>();
        vlocity_cmt__Attribute__c modelAttr = new vlocity_cmt__Attribute__c();
        modelAttr.vlocity_cmt__Code__c = 'Model';   
        modelAttr.vlocity_cmt__AttributeCategoryId__c = attrCategory.Id;
        modelAttr.vlocity_cmt__ActiveFlg__c = true;
        modelAttr.Name = 'Model';
        attrs.add(modelAttr);
        
        vlocity_cmt__Attribute__c colourAttr = new vlocity_cmt__Attribute__c();
        colourAttr.vlocity_cmt__Code__c = 'Colour';   
        colourAttr.vlocity_cmt__AttributeCategoryId__c = attrCategory.Id;
        colourAttr.vlocity_cmt__ActiveFlg__c = true;
        colourAttr.Name = 'Colour';
        attrs.add(colourAttr);
        
        insert attrs;
        
        
        /*Creating Opportunity
//Map<Id,List<Opportunity>> oppMap = BT_TestDataFactoryClass.createOpportunity(1, accList, 'Qualification', 'INR', pbId.Id);
//List<Opportunity> oppList = oppMap.values()[0];
//System.debug('oppList:' +oppList);
//insert oppList;
//System.debug('No. of Opportunities created:' +oppList.size());
Account acc = new Account();
acc.Name='TestAccount';
acc.AccountNumber = 'A10189908';
acc.RecordTypeId = recTypeId1; 
//acc.OwnerId = userId;
//acc.Scope__c = scope;
//acc.Account_Status__c = 'Active';
insert acc;*/
        
        Account acc = new Account(Name = 'Test Business Account', 
                                  RecordTypeId = recTypeId1,
                                  //BillingLatitude = 38.8951, 
                                  //BillingLongitude = -77.0364
                                  BillingCity = 'Panchkula',
                                  BillingCountry = 'Haryana',
                                  BillingPostalCode = '134109',
                                  BillingState = 'India',
                                  BillingStreet = 'Panchkula', 
                                  ARTL_IntegrationId__c = 'test', 
                                  ARTL_Category__c = 'A', 
                                  ARTL_Customer_Segment__c = 'AB',
                                  ARTL_Service_Segment__c = 'BD',
                                  ARTL_Vertical_Segment__c = 'BFI',
                                  ARTL_Business_Circle_Region__c = 'AP',
                                  ARTL_PAN__c = 'ABCDE1234F',
                                 vlocity_cmt__Status__c = 'Active');
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today()+1;
        opp.StageName = 'Qualification';
        opp.currencyIsoCode = 'INR';
        opp.Pricebook2Id = pbId; 
        insert opp;
        
        
        
        //Creating Target & Source Orders               
        List<Order> orderList = new List<Order>();
        Order targetOrder = new Order();
        targetOrder.name = 'Target Order';
        targetOrder.AccountId = acc.Id;
        targetOrder.Pricebook2Id = pbId;
        targetOrder.status = 'Draft';
        targetOrder.vlocity_cmt__OrderStatus__c = 'In Progress';
        targetOrder.EffectiveDate=System.today();                
        orderList.add(targetOrder);
        
        Order sourceOrder = new Order();
        sourceOrder.name = 'Source Order';
        sourceOrder.AccountId = acc.Id;
        sourceOrder.Pricebook2Id = pbId;
        sourceOrder.status = 'Draft';
        sourceOrder.vlocity_cmt__OrderStatus__c = 'In Progress'; 
        sourceOrder.EffectiveDate=System.today();
        orderList.add(sourceOrder);
        
        insert orderList;
        
        
        //Creating Target & Source Orchestration Plan Definitions
        vlocity_cmt__OrchestrationPlanDefinition__c opd = new vlocity_cmt__OrchestrationPlanDefinition__c(Name = 'Test Commercial Product 2 Orch Plan');
        insert opd;
        
        vlocity_cmt__OrchestrationPlanDefinition__c Sourceopd = new vlocity_cmt__OrchestrationPlanDefinition__c(Name = 'Test Orchestration');
        insert Sourceopd;
        
        
        //Creating Orchestration Item Definitions for Target Orchestration Plan Definition
        List<Vlocity_cmt__orchestrationitemdefinition__c> orchItemDefs = new List<Vlocity_cmt__orchestrationitemdefinition__c>();
        Vlocity_cmt__orchestrationitemdefinition__c oid = new Vlocity_cmt__orchestrationitemdefinition__c();
        oid.Name = 'Start Task';
        oid.vlocity_cmt__OrchestrationPlanDefinitionId__c = opd.Id;
        orchItemDefs.add(oid);
        
        Vlocity_cmt__orchestrationitemdefinition__c oid2 = new Vlocity_cmt__orchestrationitemdefinition__c();
        oid2.Name = 'End Task';
        oid2.vlocity_cmt__OrchestrationPlanDefinitionId__c = opd.Id;
        orchItemDefs.add(oid2);
        
        Vlocity_cmt__orchestrationitemdefinition__c oid3 = new Vlocity_cmt__orchestrationitemdefinition__c();
        oid3.Name = 'TestForCustomObjectRelationSource2';
        oid3.vlocity_cmt__OrchestrationPlanDefinitionId__c = opd.Id;
        orchItemDefs.add(oid3);
        
        insert orchItemDefs;
        
        
        //Creating Orchestration Item Definitions for Source Orchestration Plan Definition
        Id pushEventRecordTypeId = Schema.SObjectType.Vlocity_cmt__orchestrationitemdefinition__c.getRecordTypeInfosByName().get('Push Event').getRecordTypeId();
        
        List<Vlocity_cmt__orchestrationitemdefinition__c> SourceorchItemDefs = new List<Vlocity_cmt__orchestrationitemdefinition__c>();
        Vlocity_cmt__orchestrationitemdefinition__c sourceoid = new Vlocity_cmt__orchestrationitemdefinition__c();
        sourceoid.Name = 'Start Task';
        sourceoid.vlocity_cmt__OrchestrationPlanDefinitionId__c = Sourceopd.Id;
        SourceorchItemDefs.add(sourceoid);
        
        Vlocity_cmt__orchestrationitemdefinition__c sourceoid2 = new Vlocity_cmt__orchestrationitemdefinition__c();
        sourceoid2.Name = 'End Task';
        sourceoid2.vlocity_cmt__OrchestrationPlanDefinitionId__c = Sourceopd.Id;
        SourceorchItemDefs.add(sourceoid2);
        
        Vlocity_cmt__orchestrationitemdefinition__c sourceoid3 = new Vlocity_cmt__orchestrationitemdefinition__c();
        sourceoid3.Name = 'Check Parent Fulfilled';
        sourceoid3.RecordTypeId = pushEventRecordTypeId;
        sourceoid3.vlocity_cmt__OrchestrationPlanDefinitionId__c = Sourceopd.Id;
        sourceoid3.vlocity_cmt__EventConditionData__c = '{"type":"AND","singleconditions":[{"type":"SIMPLE","left-side":"BT_All_Target_FRLs_Fulfilled__c","left-side-datatype":"boolean","left-side-type":"field-FRLine","op":"=","right-side":"True","right-side-type":"value"}]}';
        SourceorchItemDefs.add(sourceoid3);
        
        Vlocity_cmt__orchestrationitemdefinition__c sourceoid4 = new Vlocity_cmt__orchestrationitemdefinition__c();
        sourceoid4.Name = 'TestForCustomObjectRelationSource1 ';
        sourceoid4.vlocity_cmt__OrchestrationPlanDefinitionId__c = Sourceopd.Id;
        SourceorchItemDefs.add(sourceoid4);
        
        insert SourceorchItemDefs;
        
        
        
        
        // Creating Commercial & Technical Products
        List<Product2> prodList = new List<Product2>();
        
        Product2 testCommProd1 = new Product2();
        testCommProd1.name = 'Primary Link';
        testCommProd1.vlocity_cmt__SpecificationType__c = 'Product';
        testCommProd1.productcode = 'V0000001';
        testCommProd1.vlocity_cmt__IsOrderable__c = true;
        testCommProd1.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(testCommProd1);
        
        Product2 testCommProd2 = new Product2();
        testCommProd2.name = 'Dual POP Charge';
        testCommProd2.vlocity_cmt__SpecificationType__c = 'Product';
        testCommProd2.productcode = 'V0000002';
        testCommProd2.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        testCommProd2.vlocity_cmt__IsOrderable__c = true;
        prodList.add(testCommProd2);
        
        Product2 testTechProd1 = new Product2();
        testTechProd1.name = 'Primary Link CFS';
        testTechProd1.vlocity_cmt__SpecificationType__c = 'Product';
        testTechProd1.productcode = 'V0000003';
        testTechProd1.vlocity_cmt__IsOrderable__c = false;
        testTechProd1.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(testTechProd1);
        
        Product2 testTechProd2 = new Product2();
        testTechProd2.name = 'Cross Connect ARC CFS';
        testTechProd2.vlocity_cmt__SpecificationType__c = 'Product';
        testTechProd2.productcode = 'D0000430 ';
        testTechProd2.vlocity_cmt__IsOrderable__c = false;
        testTechProd2.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(testTechProd2);
        
        Product2 prodInternet = new Product2();
        prodInternet.name = 'Internet';
        prodInternet.vlocity_cmt__SpecificationType__c = 'Product';
        prodInternet.productcode = 'D0000430 ';
        prodInternet.vlocity_cmt__IsOrderable__c = false;
        //testTechProd2.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(prodInternet);
        
        Product2 prodInternet1 = new Product2();
        prodInternet1.name = 'Secondary Internet Link';
        prodInternet1.vlocity_cmt__SpecificationType__c = 'Product';
        prodInternet1.productcode = 'D0000430 ';
        prodInternet1.vlocity_cmt__IsOrderable__c = false;
        //testTechProd2.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(prodInternet1);
        
        Product2 prodBandwidth = new Product2();
        prodBandwidth.name = 'Bandwidth OTC CFS';
        prodBandwidth.vlocity_cmt__SpecificationType__c = 'Product';
        prodBandwidth.productcode = 'D0000430 ';
        prodBandwidth.vlocity_cmt__IsOrderable__c = false;
        //testTechProd2.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(prodBandwidth);
        
        Product2 prodInfra = new Product2();
        prodInfra.name = '4G Infra';
        prodInfra.vlocity_cmt__SpecificationType__c = 'Product';
        prodInfra.productcode = 'D0000430 ';
        prodInfra.vlocity_cmt__IsOrderable__c = false;
        //testTechProd2.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(prodInfra);
        
        Product2 prodPrimary = new Product2();
        prodPrimary.name = 'Primary MPLS Link';
        prodPrimary.vlocity_cmt__SpecificationType__c = 'Product';
        prodPrimary.productcode = 'D0000430 ';
        prodPrimary.vlocity_cmt__IsOrderable__c = false;
        //testTechProd2.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(prodPrimary);
        
        Product2 prodRouters = new Product2();
        prodRouters.name = 'Enterprise Connectivity Routers';
        prodRouters.vlocity_cmt__SpecificationType__c = 'Product';
        prodRouters.productcode = 'D0000430 ';
        prodRouters.vlocity_cmt__IsOrderable__c = false;
        //testTechProd2.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(prodRouters);
        
        Product2 prodRoutersCFS = new Product2();
        prodRoutersCFS.name = 'Enterprise iconnectivity Routers CFS';
        prodRoutersCFS.vlocity_cmt__SpecificationType__c = 'Product';
        prodRoutersCFS.productcode = 'D0000430 ';
        prodRoutersCFS.vlocity_cmt__IsOrderable__c = false;
        //testTechProd2.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(prodRoutersCFS);
        
        Product2 prodEMPLS = new Product2();
        prodEMPLS.name = 'EMPLS Product Specification CFS';
        prodEMPLS.vlocity_cmt__SpecificationType__c = 'Product';
        prodEMPLS.productcode = 'D0000430 ';
        prodEMPLS.vlocity_cmt__IsOrderable__c = false;
        //testTechProd2.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(prodEMPLS);
        
        insert prodList;
        
        
        //Creating Orchestration Scenerios
        List<vlocity_cmt__OrchestrationScenario__c> orchScenerios = new List<vlocity_cmt__OrchestrationScenario__c>();
        vlocity_cmt__OrchestrationScenario__c targetOrchScenerio = new vlocity_cmt__OrchestrationScenario__c();
        targetOrchScenerio.vlocity_cmt__Product2Id__c = testTechProd2.Id;
        targetOrchScenerio.vlocity_cmt__OrchestrationPlanDefinitionId__c = opd.Id;
        targetOrchScenerio.vlocity_cmt__Action__c = 'Add';
        targetOrchScenerio.Name = 'Add Test Technical Product 2';
        orchScenerios.add(targetOrchScenerio);
        
        vlocity_cmt__OrchestrationScenario__c sourceOrchScenerio = new vlocity_cmt__OrchestrationScenario__c();
        sourceOrchScenerio.vlocity_cmt__Product2Id__c = testTechProd1.Id;
        sourceOrchScenerio.vlocity_cmt__OrchestrationPlanDefinitionId__c = Sourceopd.Id;
        sourceOrchScenerio.vlocity_cmt__Action__c = 'Add';
        sourceOrchScenerio.Name = 'Add Test Technical Product 1';
        orchScenerios.add(sourceOrchScenerio);
        
        insert orchScenerios;
        
        // Creating PriceBook Entry
        //List<PricebookEntry> pBEntryList = BT_TestDataFactoryClass.createPBEntry(prodList, pbId);
        PricebookEntry pe = new PricebookEntry();
        pe.Pricebook2Id = pbId;
        pe.Product2Id = prodList[0].Id;
        pe.UnitPrice = 100;
        pe.IsActive = true;
        insert pe;
        
        vlocity_cmt__PriceList__c priceList = new 	vlocity_cmt__PriceList__c();
        priceList.Name ='Pricelist For Test class';
        priceList.vlocity_cmt__Code__c='PricelistForTestclass';
        priceList.vlocity_cmt__Pricebook2Id__c =Test.getStandardPricebookId();
        insert priceList;
        
        Quote q = new Quote();
        q.OpportunityId = opp.Id;
        q.Name = 'Quote Test';
        q.vlocity_cmt__PriceListId__c=priceList.Id;
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.Status ='CUSTOMER_SIGNED';
        q.vlocity_cmt__Type__c = 'New';
        q.ARTL_QNeedCapexApproval__c=True;
        q.vlocity_cmt__ValidationStatus__c = 'Billing Sync Successful';
        insert q;
        system.debug('q=>'+q);
        
        QuoteLineItem qli = new QuoteLineItem(
            Product2Id = prodList[0].Id,
            QuoteId = q.Id,
            PricebookEntryId = pe.Id,
            UnitPrice = pe.UnitPrice,
            Quantity=1,
            Capex__c=10000,
            Annual_Recurring_Charge__c=500000 
        );
        
        //Creating Decomposition Relationships
        List<vlocity_cmt__DecompositionRelationship__c> decompRels = new List<vlocity_cmt__DecompositionRelationship__c>();
        
        vlocity_cmt__DecompositionRelationship__c commProd2TechProd2 = new vlocity_cmt__DecompositionRelationship__c();
        commProd2TechProd2.Name = 'CommercialProd2 -> TechnicalProd2';
        commProd2TechProd2.vlocity_cmt__SourceProductId__c = testCommProd2.Id;
        commProd2TechProd2.vlocity_cmt__DestinationProductId__c = testTechProd2.Id;
        commProd2TechProd2.vlocity_cmt__MappingsData__c = '[{"source_attr_name":"Model","mapping_type":"ad-verbatim","destination_attr_name":"Model","destination_attr_code":"Model","source_attr_code":"Model","source_type":"Attribute"},{"source_attr_name":"Colour","mapping_type":"ad-verbatim","destination_attr_name":"Colour","destination_attr_code":"Colour","source_attr_code":"Colour","source_type":"Attribute"}]' ;                 
        decompRels.add(commProd2TechProd2);
        
        vlocity_cmt__DecompositionRelationship__c commProd1TechProd1 = new vlocity_cmt__DecompositionRelationship__c();
        commProd1TechProd1.Name = 'CommercialProd1 -> TechnicalProd1';
        commProd1TechProd1.vlocity_cmt__SourceProductId__c = testCommProd1.Id;
        commProd1TechProd1.vlocity_cmt__DestinationProductId__c = testTechProd1.Id;
        commProd1TechProd1.vlocity_cmt__MappingsData__c = '[{"source_attr_name":"Model","mapping_type":"ad-verbatim","destination_attr_name":"Model","destination_attr_code":"Model","source_attr_code":"Model","source_type":"Attribute"},{"source_attr_name":"Colour","mapping_type":"ad-verbatim","destination_attr_name":"Colour","destination_attr_code":"Colour","source_attr_code":"Colour","source_type":"Attribute"}]';                
        decompRels.add(commProd1TechProd1);
        
        insert decompRels;
        
        
        //Creating Target & Source OrderItems
        List<OrderItem> olList = new List<OrderItem>();
        
        OrderItem targetOrderItem = new OrderItem();
        targetOrderItem.OrderId = targetOrder.Id;
        targetOrderItem.PricebookEntryId = pe.Id;
        targetOrderItem.Quantity = 1;
        targetOrderItem.vlocity_cmt__LineNumber__c = '0001';
        targetOrderItem.UnitPrice = 100;
        targetOrderItem.vlocity_cmt__Product2Id__c = testCommProd2.Id;
        targetOrderItem.vlocity_cmt__ProvisioningStatus__c = 'New';   
        targetOrderItem.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_Delete_LAN_IPv6":null,"ATT_Delete_LAN_IPv4":null,"ATT_Additional_LAN_IPv6":null,"ATT_Additional_LAN_IPv4":null,"ATT_Add_LAN_IPV6_Subnet":null,"ATT_Add_LAN_IPv6":null,"ATT_Add_LAN_IPV4_Subnet":null,"ATT_Add_LAN_IPv4":null,"ATT_LAN_IPV6":"123.32.3.3","ATT_LAN_IPV4":"321.21.1.1","ATT_ADDITIONAL_IP_BLOCK":null,"ATT_LAN_IPV6_SUBNET_MASK":"/50","ATT_LAN_IPV4_SUBNET_MASK":"/2","ATT_IP_Type":"IPv4"}';
        olList.add(targetOrderItem);
        
        
        OrderItem sourceOrderItem = new OrderItem();
        sourceOrderItem.OrderId = sourceOrder.Id;
        sourceOrderItem.PricebookEntryId = pe.Id;
        sourceOrderItem.Quantity = 1;
        sourceOrderItem.vlocity_cmt__LineNumber__c = '0001';
        sourceOrderItem.UnitPrice = 50;
        sourceOrderItem.vlocity_cmt__Product2Id__c = testCommProd1.Id;
        sourceOrderItem.vlocity_cmt__ProvisioningStatus__c = 'New';                
        olList.add(sourceOrderItem);
        
        OrderItem orderItem5 = new OrderItem();
        orderItem5.OrderId = targetOrder.Id;
        orderItem5.PricebookEntryId = pe.Id;
        orderItem5.Quantity = 1;
        orderItem5.vlocity_cmt__LineNumber__c = '0001';
        orderItem5.UnitPrice = 100;
        orderItem5.vlocity_cmt__Product2Id__c = prodRouters.Id;
        orderItem5.vlocity_cmt__ProvisioningStatus__c = 'New';   
        orderItem5.vlocity_cmt__AttributeSelectedValues__c = '{"Colour":"Target Comm2 Colour","Model":"Target Comm2 Model"}';
        olList.add(orderItem5);
        
        OrderItem orderItem1 = new OrderItem();
        orderItem1.OrderId = targetOrder.Id;
        orderItem1.PricebookEntryId = pe.Id;
        orderItem1.Quantity = 1;
        orderItem1.vlocity_cmt__LineNumber__c = '0001';
        orderItem1.UnitPrice = 150;
        orderItem1.vlocity_cmt__Product2Id__c = prodInternet.Id;
        orderItem1.vlocity_cmt__ProvisioningStatus__c = 'New';   
        orderItem1.vlocity_cmt__AttributeSelectedValues__c = '{"Colour":"Target Comm2 Colour","Model":"Target Comm2 Model"}';
        olList.add(orderItem1);
        
        OrderItem orderItem2 = new OrderItem();
        orderItem2.OrderId = targetOrder.Id;
        orderItem2.PricebookEntryId = pe.Id;
        orderItem2.Quantity = 1;
        orderItem2.vlocity_cmt__LineNumber__c = '0001';
        orderItem2.UnitPrice = 200;
        orderItem2.vlocity_cmt__Product2Id__c = prodInternet1.Id;
        orderItem2.vlocity_cmt__ProvisioningStatus__c = 'New';   
        orderItem2.vlocity_cmt__AttributeSelectedValues__c = '{"Colour":"Target Comm2 Colour","Model":"Target Comm2 Model"}';
        olList.add(orderItem2);
        
        OrderItem orderItem3 = new OrderItem();
        orderItem3.OrderId = targetOrder.Id;
        orderItem3.PricebookEntryId = pe.Id;
        orderItem3.Quantity = 1;
        orderItem3.vlocity_cmt__LineNumber__c = '0001';
        orderItem3.UnitPrice = 250;
        orderItem3.vlocity_cmt__Product2Id__c = prodInfra.Id;
        orderItem3.vlocity_cmt__ProvisioningStatus__c = 'New';   
        orderItem3.vlocity_cmt__AttributeSelectedValues__c = '{"Colour":"Target Comm2 Colour","Model":"Target Comm2 Model"}';
        olList.add(orderItem3);
        
        OrderItem orderItem4 = new OrderItem();
        orderItem4.OrderId = targetOrder.Id;
        orderItem4.PricebookEntryId = pe.Id;
        orderItem4.Quantity = 1;
        orderItem4.vlocity_cmt__LineNumber__c = '0001';
        orderItem4.UnitPrice = 300;
        orderItem4.QuoteLineItemId = qli.Id;
        orderItem4.vlocity_cmt__Product2Id__c = prodPrimary.Id;
        orderItem4.vlocity_cmt__ProvisioningStatus__c = 'New';   
        orderItem4.vlocity_cmt__AttributeSelectedValues__c = '{"Colour":"Target Comm2 Colour","Model":"Target Comm2 Model"}';
        olList.add(orderItem4);
        
        insert olList;
        
        
        //Creating ReliesOn OrderProductRelationship between Source & Target OrderItem
        List<vlocity_cmt__OrderItemRelationship__c> lstOIR = new List<vlocity_cmt__OrderItemRelationship__c>();
        vlocity_cmt__OrderItemRelationship__c orderProdRel = new vlocity_cmt__OrderItemRelationship__c();
        orderProdRel.Name = 'ReliesOn-345345';
        orderProdRel.vlocity_cmt__OrderId__c = sourceOrder.Id;
        orderProdRel.vlocity_cmt__OrderItemId__c = sourceOrderItem.Id;
        orderProdRel.vlocity_cmt__RelatedOrderItemId__c = sourceOrderItem.Id;
        orderProdRel.vlocity_cmt__RelationshipType__c = 'ReliesOn';
        lstOIR.add(orderProdRel);
        
        vlocity_cmt__OrderItemRelationship__c orderProdRel1 = new vlocity_cmt__OrderItemRelationship__c();
        orderProdRel1.Name = 'ReliesOn-345345';
        orderProdRel1.vlocity_cmt__OrderId__c = targetOrder.Id;
        orderProdRel1.vlocity_cmt__OrderItemId__c = targetOrderItem.Id;
        orderProdRel1.vlocity_cmt__RelatedOrderItemId__c = orderItem3.Id;
        orderProdRel1.vlocity_cmt__RelationshipType__c = 'ReliesOn';
        lstOIR.add(orderProdRel1);
        
        vlocity_cmt__OrderItemRelationship__c orderProdRel2 = new vlocity_cmt__OrderItemRelationship__c();
        orderProdRel2.Name = 'ReliesOn-345345';
        orderProdRel2.vlocity_cmt__OrderId__c = targetOrder.Id;
        orderProdRel2.vlocity_cmt__OrderItemId__c = targetOrderItem.Id;
        orderProdRel2.vlocity_cmt__RelatedOrderItemId__c = orderItem2.Id;
        orderProdRel2.vlocity_cmt__RelationshipType__c = 'ReliesOn';
        lstOIR.add(orderProdRel2);
        
        vlocity_cmt__OrderItemRelationship__c orderProdRel3 = new vlocity_cmt__OrderItemRelationship__c();
        orderProdRel3.Name = 'ReliesOn-345346';
        orderProdRel3.vlocity_cmt__OrderId__c = targetOrder.Id;
        orderProdRel3.vlocity_cmt__OrderItemId__c = targetOrderItem.Id;
        orderProdRel3.vlocity_cmt__RelatedOrderItemId__c = orderItem1.Id;
        orderProdRel3.vlocity_cmt__RelationshipType__c = 'ReliesOn';
        lstOIR.add(orderProdRel3);
        
        vlocity_cmt__OrderItemRelationship__c orderProdRel4 = new vlocity_cmt__OrderItemRelationship__c();
        orderProdRel4.Name = 'ReliesOn-345346';
        orderProdRel4.vlocity_cmt__OrderId__c = targetOrder.Id;
        orderProdRel4.vlocity_cmt__OrderItemId__c = orderItem2.Id;
        orderProdRel4.vlocity_cmt__RelatedOrderItemId__c = orderItem1.Id;
        orderProdRel4.vlocity_cmt__RelationshipType__c = 'ReliesOn';
        lstOIR.add(orderProdRel4);
        
        insert lstOIR;
        
        
        //Creating Orchestration Plans                
        List<vlocity_cmt__OrchestrationPlan__c> orchList = new List<vlocity_cmt__OrchestrationPlan__c>();
        
        vlocity_cmt__OrchestrationPlan__c targetOrchPlan = new vlocity_cmt__OrchestrationPlan__c();
        targetOrchPlan.vlocity_cmt__OrderId__c = targetOrder.Id;
        orchList.add(targetOrchPlan);
        
        vlocity_cmt__OrchestrationPlan__c sourceOrchPlan = new vlocity_cmt__OrchestrationPlan__c();
        sourceOrchPlan.vlocity_cmt__OrderId__c = sourceOrder.Id;            
        orchList.add(sourceOrchPlan);
        
        insert orchList;
        
        //Creating Fulfilment Requests for Target & Source Orders  
        vlocity_cmt__FulfilmentRequest__c targetFR = new vlocity_cmt__FulfilmentRequest__c();
        targetFR.vlocity_cmt__orchestrationPlanId__c = targetOrchPlan.Id;
        targetFR.vlocity_cmt__AccountId__c = acc.Id;
        targetFR.vlocity_cmt__OrderId__c = targetOrder.Id;
        insert targetFR;
        
        vlocity_cmt__FulfilmentRequest__c sourceFR = new vlocity_cmt__FulfilmentRequest__c();
        sourceFR.vlocity_cmt__orchestrationPlanId__c = sourceOrchPlan.Id;
        sourceFR.vlocity_cmt__OrderId__c = sourceOrder.Id;
        sourceFR.vlocity_cmt__AccountId__c = acc.Id;
        insert sourceFR;
        
        vlocity_cmt__InventoryItem__c inventoryitem = new vlocity_cmt__InventoryItem__c();
        inventoryitem.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_Display_Modified_Charges":"5","ATT_Billing_Component_ID":null,"ATT_Floor_Rate":null,"ATT_StartDate":null,"ATT_Type":null}';
        insert inventoryitem;                    
        
        //Creating Fulfilment Request Lines for Target & Source Orders  
        List<vlocity_cmt__FulfilmentRequestLine__c> frlList = new List<vlocity_cmt__FulfilmentRequestLine__c>();
        
        vlocity_cmt__FulfilmentRequestLine__c targetFrl = new vlocity_cmt__FulfilmentRequestLine__c();
        targetFrl.vlocity_cmt__FulfilmentRequestID__c = targetFR.Id;
        targetFrl.vlocity_cmt__FulfilmentStatus__c = 'Activated';
        targetFrl.vlocity_cmt__Product2Id__c = prodRoutersCFS.id;
        targetFrl.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_Display_Modified_Charges":"15","ATT_Billing_Component_ID":null,"ATT_Floor_Rate":null,"ATT_StartDate":null,"ATT_Type":null}';
        targetFrl.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000k8NOUAY","attributeuniquecode__c":"ParentsFulfilled","attributedisplayname__c":"Parents Fulfilled","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":false},"Name":"Parents Fulfilled","Code":"ParentsFulfilled","Filterable":false,"SegmentValue":"false","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHgUAI","attributeuniquecode__c":"Model","attributedisplayname__c":"Model","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Colour"},"Name":"Model","Code":"Model","Filterable":false,"SegmentValue":"Target Comm4 Colour","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHbUAI","attributeuniquecode__c":"Colour","attributedisplayname__c":"Colour","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Model"},"Name":"Colour","Code":"Colour","Filterable":false,"SegmentValue":"Target Comm4 Model","$$AttributeDefinitionEnd$$":null}]}';
        targetFrl.vlocity_cmt__InventoryItemId__c = inventoryitem.id;
        frlList.add(targetFrl);
        
        vlocity_cmt__FulfilmentRequestLine__c targetFrl1 = new vlocity_cmt__FulfilmentRequestLine__c();
        targetFrl1.vlocity_cmt__FulfilmentRequestID__c = targetFR.Id;
        targetFrl1.vlocity_cmt__FulfilmentStatus__c = 'Activated';
        targetFrl1.vlocity_cmt__Product2Id__c = prodEMPLS.id;
        targetFrl1.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_Display_Modified_Charges":"15","ATT_Billing_Component_ID":null,"ATT_Floor_Rate":null,"ATT_StartDate":null,"ATT_Type":null}';
        targetFrl1.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000k8NOUAY","attributeuniquecode__c":"ParentsFulfilled","attributedisplayname__c":"Parents Fulfilled","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":false},"Name":"Parents Fulfilled","Code":"ParentsFulfilled","Filterable":false,"SegmentValue":"false","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHgUAI","attributeuniquecode__c":"Model","attributedisplayname__c":"Model","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Colour"},"Name":"Model","Code":"Model","Filterable":false,"SegmentValue":"Target Comm4 Colour","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHbUAI","attributeuniquecode__c":"Colour","attributedisplayname__c":"Colour","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Model"},"Name":"Colour","Code":"Colour","Filterable":false,"SegmentValue":"Target Comm4 Model","$$AttributeDefinitionEnd$$":null}]}';
        targetFrl1.vlocity_cmt__InventoryItemId__c = inventoryitem.id;
        frlList.add(targetFrl1);
        
        vlocity_cmt__FulfilmentRequestLine__c sourceFrl = new vlocity_cmt__FulfilmentRequestLine__c();
        sourceFrl.vlocity_cmt__FulfilmentRequestID__c = sourceFR.Id;
        sourceFrl.vlocity_cmt__Product2Id__c = prodRoutersCFS.id;
        sourceFrl.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000k8NOUAY","attributeuniquecode__c":"ParentsFulfilled","attributedisplayname__c":"Parents Fulfilled","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":false},"Name":"Parents Fulfilled","Code":"ParentsFulfilled","Filterable":false,"SegmentValue":"false","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHgUAI","attributeuniquecode__c":"Model","attributedisplayname__c":"Model","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Colour"},"Name":"Model","Code":"Model","Filterable":false,"SegmentValue":"Target Comm4 Colour","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHbUAI","attributeuniquecode__c":"Colour","attributedisplayname__c":"Colour","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Model"},"Name":"Colour","Code":"Colour","Filterable":false,"SegmentValue":"Target Comm4 Model","$$AttributeDefinitionEnd$$":null}]}';
        sourceFrl.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_Display_Modified_Charges":"15","ATT_Billing_Component_ID":null,"ATT_Floor_Rate":null,"ATT_StartDate":null,"ATT_Type":null}';
        frlList.add(sourceFrl);
        
        vlocity_cmt__FulfilmentRequestLine__c sourceFrl1 = new vlocity_cmt__FulfilmentRequestLine__c();
        sourceFrl1.vlocity_cmt__FulfilmentRequestID__c = sourceFR.Id;
        sourceFrl1.vlocity_cmt__Product2Id__c = prodBandwidth.id;
        sourceFrl1.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000k8NOUAY","attributeuniquecode__c":"ParentsFulfilled","attributedisplayname__c":"Parents Fulfilled","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":false},"Name":"Parents Fulfilled","Code":"ParentsFulfilled","Filterable":false,"SegmentValue":"false","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHgUAI","attributeuniquecode__c":"Model","attributedisplayname__c":"Model","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Colour"},"Name":"Model","Code":"Model","Filterable":false,"SegmentValue":"Target Comm4 Colour","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHbUAI","attributeuniquecode__c":"Colour","attributedisplayname__c":"Colour","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Model"},"Name":"Colour","Code":"Colour","Filterable":false,"SegmentValue":"Target Comm4 Model","$$AttributeDefinitionEnd$$":null}]}';
        sourceFrl1.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_Display_Modified_Charges":"15","ATT_Billing_Component_ID":null,"ATT_Floor_Rate":null,"ATT_StartDate":null,"ATT_Type":null}';
        
        insert frlList;
        
        
        //Creating vlocity_cmt__FulfilmentRequestLineDecompRelationship__c for Target & Source Orders  
        List<vlocity_cmt__FulfilmentRequestLineDecompRelationship__c> frldecompRels = new List<vlocity_cmt__FulfilmentRequestLineDecompRelationship__c>();
        
        vlocity_cmt__FulfilmentRequestLineDecompRelationship__c targetDecompRel = new vlocity_cmt__FulfilmentRequestLineDecompRelationship__c();
        targetDecompRel.vlocity_cmt__SourceOrderItemId__c = targetOrderItem.Id;
        targetDecompRel.vlocity_cmt__DestinationFulfilmentRequestLineId__c = targetFrl.Id;
        frldecompRels.add(targetDecompRel) ;   
        
        vlocity_cmt__FulfilmentRequestLineDecompRelationship__c sourceDecompRel = new vlocity_cmt__FulfilmentRequestLineDecompRelationship__c();
        sourceDecompRel.vlocity_cmt__SourceOrderItemId__c = sourceOrderItem.Id;
        sourceDecompRel.vlocity_cmt__DestinationFulfilmentRequestLineId__c = sourceFrl.Id;
        frldecompRels.add(sourceDecompRel) ; 
        
        insert  frldecompRels;    
        
        
        //Creating Target Orchestration Items
        List<vlocity_cmt__OrchestrationItem__c> orchItems = new List<vlocity_cmt__OrchestrationItem__c>();
        vlocity_cmt__OrchestrationItem__c targetorchItem1 = new vlocity_cmt__OrchestrationItem__c();
        targetorchItem1.Name = 'TestForCustomObjectRelationSource2';
        targetorchItem1.vlocity_cmt__OrchestrationItemDefinitionId__c = oid3.Id;
        targetorchItem1.vlocity_cmt__FulfilmentRequestLineId__c = targetFrl.Id; 
        targetorchItem1.vlocity_cmt__OrchestrationPlanId__c = targetOrchPlan.Id; 
        targetorchItem1.vlocity_cmt__TimeoutMs__c = 1000.000;
        targetorchItem1.vlocity_cmt__State__c = 'Completed';
        orchItems.add(targetorchItem1);
        
        
        vlocity_cmt__OrchestrationItem__c sourceOrchItem = new vlocity_cmt__OrchestrationItem__c();
        sourceOrchItem.vlocity_cmt__OrchestrationItemDefinitionId__c = sourceoid4.Id;
        sourceOrchItem.Name = 'TestForCustomObjectRelationSource1';
        sourceOrchItem.vlocity_cmt__FulfilmentRequestLineId__c = sourceFrl.Id; 
        sourceOrchItem.vlocity_cmt__OrchestrationPlanId__c = sourceOrchPlan.Id; 
        sourceOrchItem.vlocity_cmt__TimeoutMs__c = 1000.000;
        orchItems.add(sourceOrchItem);
        
        insert orchItems;
        
        ARTL_Billing_Staging__c billStage = new ARTL_Billing_Staging__c();
        billStage.Quote_Line_Item__c = qli.Id;
        //billStage.BCP_Id__c = '7321877875987';
        //billStage.DCP_Id__c = '2189850958190';
        insert billStage;
        
    }
    @isTest static void callDeltaAttributeclass(){
        
        Test.startTest();
        List<vlocity_cmt__OrchestrationItem__c> orchItem = [SELECT Id, vlocity_cmt__State__c, vlocity_cmt__OrchestrationPlanId__c, 
                                                            vlocity_cmt__FulfilmentRequestLineId__c,vlocity_cmt__OrchestrationItemDefinitionId__c 
                                                            FROM vlocity_cmt__OrchestrationItem__c];
        
        ARTLUpdateRateValues testobj1 = new ARTLUpdateRateValues();
        testobj1.executeBatch(orchItem);
        Test.stopTest();
        
    }
}