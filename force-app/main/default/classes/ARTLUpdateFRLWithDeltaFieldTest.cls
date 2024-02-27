/*****************************************************************************************************************
Name : ARTLUpdateFRLWithDeltaFieldTest 
==================================================================================================================
Purpose: 1.To cover Test Cases for Updating Delta Field (F4)
==================================================================================================================
History
---------------
Version      Author               Date         Detail      Features/CSR/TTP
1.0       Akshay(SFI)  		    18.12.2023    Created   
*********/

/**
* @description Testing Data Setup
*/
@isTest
public class ARTLUpdateFRLWithDeltaFieldTest {
    
    @testSetup 
    static void setup() {
        
        Id pbId = Test.getStandardPricebookId();
        Id recTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();    
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
        
        
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = recTypeId1;
        acc.BillingStreet = 'Test Street';
        acc.BillingState  = 'Karnataka';
        acc.BillingCity   = 'Bengaluru';
        acc.BillingCountry= 'India';
        acc.BillingPostalCode = '560087';
        acc.ARTL_Category__c ='A';
        acc.ARTL_Customer_Segment__c ='AB';
        acc.ARTL_Vertical_Segment__c ='BFI';
        acc.ARTL_Service_Segment__c ='Bharti';
        acc.ARTL_Business_Circle_Region__c='NCR';
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
        targetOrder.EffectiveDate=System.today();                
        orderList.add(targetOrder);
        
        Order sourceOrder = new Order();
        sourceOrder.name = 'Source Order';
        sourceOrder.AccountId = acc.Id;
        sourceOrder.Pricebook2Id = pbId;
        sourceOrder.status = 'Draft';
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
        testCommProd1.name = 'Test Commercial Product1';
        testCommProd1.vlocity_cmt__SpecificationType__c = 'Product';
        testCommProd1.productcode = 'Test ParentProd';
        testCommProd1.ARTL_Parent_Products__c = 'Test ParentProd';
        testCommProd1.vlocity_cmt__IsOrderable__c = true;
        testCommProd1.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(testCommProd1);
        
        Product2 testCommProd2 = new Product2();
        testCommProd2.name = 'Test Commercial Product2';
        testCommProd2.vlocity_cmt__SpecificationType__c = 'Product';
        testCommProd2.productcode = 'Test ParentProd';
        testCommProd2.ARTL_Parent_Products__c = 'Test ParentProd';
        testCommProd2.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        testCommProd2.vlocity_cmt__IsOrderable__c = true;
        prodList.add(testCommProd2);
        
        Product2 testTechProd1 = new Product2();
        testTechProd1.name = 'ARC2';
        testTechProd1.vlocity_cmt__SpecificationType__c = 'Product';
        testTechProd1.productcode = 'Test ParentProd';
        testTechProd1.ARTL_Parent_Products__c = 'Test ParentProd';
        testTechProd1.vlocity_cmt__IsOrderable__c = false;
        testTechProd1.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(testTechProd1);
        
        Product2 testTechProd2 = new Product2();
        testTechProd2.name = 'ARC';
        testTechProd2.vlocity_cmt__SpecificationType__c = 'Product';
        testTechProd2.productcode = 'Test ParentProd';
        testTechProd2.vlocity_cmt__IsOrderable__c = false;
        testTechProd2.ARTL_Parent_Products__c = 'Test ParentProd';
        testTechProd2.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
        prodList.add(testTechProd2);
        
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
        targetOrderItem.vlocity_cmt__LineNumber__c = '.0001.0001';
        targetOrderItem.UnitPrice = 100;
        targetOrderItem.Product2Id = testCommProd2.Id;
        targetOrderItem.vlocity_cmt__AssetReferenceId__c = 'akshay-test-ref2';
        targetOrderItem.vlocity_cmt__ProvisioningStatus__c = 'New';   
        targetOrderItem.vlocity_cmt__AttributeSelectedValues__c = '{"Colour":"Target Comm2 Colour","Model":"Target Comm2 Model"}';
        olList.add(targetOrderItem);
        
        
        OrderItem sourceOrderItem = new OrderItem();
        sourceOrderItem.OrderId = sourceOrder.Id;
        sourceOrderItem.PricebookEntryId = pe.Id;
        sourceOrderItem.Quantity = 1;
        sourceOrderItem.vlocity_cmt__LineNumber__c = '.0001.0001';
        sourceOrderItem.UnitPrice = 100;
        sourceOrderItem.Product2Id = testCommProd1.Id;
        sourceOrderItem.vlocity_cmt__AssetReferenceId__c = 'akshay-test-ref';
        sourceOrderItem.vlocity_cmt__ProvisioningStatus__c = 'New';                
        olList.add(sourceOrderItem);
        
        insert olList;
        
        vlocity_cmt__OrderItemRelationship__c testrelationship = new vlocity_cmt__OrderItemRelationship__c();
        testrelationship.vlocity_cmt__OrderItemId__c = sourceOrderItem.id;
        testrelationship.vlocity_cmt__RelatedOrderItemId__c = targetOrderItem.id;
        testrelationship.vlocity_cmt__RelationshipType__c = 'Relies-On';
        testrelationship.vlocity_cmt__OrderId__c = sourceOrder.id;
        
        //Creating ReliesOn OrderProductRelationship between Source & Target OrderItem
        vlocity_cmt__OrderItemRelationship__c orderProdRel = new vlocity_cmt__OrderItemRelationship__c();
        orderProdRel.Name = 'ReliesOn-345345';
        orderProdRel.vlocity_cmt__OrderId__c = sourceOrder.Id;
        orderProdRel.vlocity_cmt__OrderItemId__c = sourceOrderItem.Id;
        orderProdRel.vlocity_cmt__RelatedOrderItemId__c = targetOrderItem.Id;
        orderProdRel.vlocity_cmt__RelationshipType__c = 'ReliesOn';
        insert orderProdRel;
        
        
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
        sourceFR.vlocity_cmt__AccountId__c = acc.Id;
        targetFR.vlocity_cmt__OrderId__c = sourceOrder.Id;
        insert sourceFR;
        
        vlocity_cmt__InventoryItem__c inventoryitem = new vlocity_cmt__InventoryItem__c();
        inventoryitem.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_Display_Modified_Charges":"5","ATT_Billing_Component_ID":null,"ATT_Floor_Rate":null,"ATT_StartDate":null,"ATT_Type":null}';
        insert inventoryitem;                    
        
        //Creating Fulfilment Request Lines for Target & Source Orders  
        List<vlocity_cmt__FulfilmentRequestLine__c> frlList = new List<vlocity_cmt__FulfilmentRequestLine__c>();
        
        vlocity_cmt__FulfilmentRequestLine__c tempFrl = new vlocity_cmt__FulfilmentRequestLine__c();
        tempFrl.vlocity_cmt__FulfilmentRequestID__c = sourceFR.Id;
        tempFrl.vlocity_cmt__Product2Id__c = testTechProd1.id;
        tempFrl.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000k8NOUAY","attributeuniquecode__c":"ParentsFulfilled","attributedisplayname__c":"Parents Fulfilled","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":false},"Name":"Parents Fulfilled","Code":"ParentsFulfilled","Filterable":false,"SegmentValue":"false","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHgUAI","attributeuniquecode__c":"Model","attributedisplayname__c":"Model","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Colour"},"Name":"Model","Code":"Model","Filterable":false,"SegmentValue":"Target Comm4 Colour","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHbUAI","attributeuniquecode__c":"Colour","attributedisplayname__c":"Colour","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Model"},"Name":"Colour","Code":"Colour","Filterable":false,"SegmentValue":"Target Comm4 Model","$$AttributeDefinitionEnd$$":null}]}';
        frlList.add(tempFrl);
        
        vlocity_cmt__FulfilmentRequestLine__c targetFrl = new vlocity_cmt__FulfilmentRequestLine__c();
        
        targetFrl.vlocity_cmt__FulfilmentRequestID__c = targetFR.Id;
        targetFrl.vlocity_cmt__FulfilmentStatus__c = 'Activated';
        targetFrl.vlocity_cmt__Product2Id__c = testTechProd1.id;
        targetFrl.vlocity_cmt__LineNumber__c = '.0001.0001';
        targetFrl.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_Display_Modified_Charges":"15","ATT_Billing_Component_ID":null,"ATT_Floor_Rate":null,"ATT_StartDate":null,"ATT_Type":null}';
        targetFrl.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000k8NOUAY","attributeuniquecode__c":"ParentsFulfilled","attributedisplayname__c":"Parents Fulfilled","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":false},"Name":"Parents Fulfilled","Code":"ParentsFulfilled","Filterable":false,"SegmentValue":"false","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHgUAI","attributeuniquecode__c":"Model","attributedisplayname__c":"Model","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Colour"},"Name":"Model","Code":"Model","Filterable":false,"SegmentValue":"Target Comm4 Colour","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHbUAI","attributeuniquecode__c":"Colour","attributedisplayname__c":"Colour","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Model"},"Name":"Colour","Code":"Colour","Filterable":false,"SegmentValue":"Target Comm4 Model","$$AttributeDefinitionEnd$$":null}]}';
        targetFrl.vlocity_cmt__InventoryItemId__c = inventoryitem.id;
        frlList.add(targetFrl);
        
        
        vlocity_cmt__FulfilmentRequestLine__c sourceFrl = new vlocity_cmt__FulfilmentRequestLine__c();
        sourceFrl.vlocity_cmt__FulfilmentRequestID__c = sourceFR.Id;
        sourceFrl.vlocity_cmt__Product2Id__c = testTechProd1.id;
        sourceFrl.vlocity_cmt__MainOrderItemId__c = targetFrl.Id;
        sourceFrl.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000k8NOUAY","attributeuniquecode__c":"ParentsFulfilled","attributedisplayname__c":"Parents Fulfilled","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":false},"Name":"Parents Fulfilled","Code":"ParentsFulfilled","Filterable":false,"SegmentValue":"false","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHgUAI","attributeuniquecode__c":"Model","attributedisplayname__c":"Model","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Colour"},"Name":"Model","Code":"Model","Filterable":false,"SegmentValue":"Target Comm4 Colour","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHbUAI","attributeuniquecode__c":"Colour","attributedisplayname__c":"Colour","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Model"},"Name":"Colour","Code":"Colour","Filterable":false,"SegmentValue":"Target Comm4 Model","$$AttributeDefinitionEnd$$":null}]}';
        frlList.add(sourceFrl);
        
        insert frlList;
        
        frlList[1].vlocity_cmt__MainOrderItemId__c = frlList[0].Id;
        frlList[1].vlocity_cmt__LineNumber__c = frlList[1].vlocity_cmt__MainOrderItemId__c+frlList[1].vlocity_cmt__LineNumber__c;
        update frlList;
        
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
        
        vlocity_cmt__OrchestrationItem__c testOrchItem = new vlocity_cmt__OrchestrationItem__c();
        testOrchItem.vlocity_cmt__OrchestrationItemDefinitionId__c = sourceoid4.Id;
        testOrchItem.Name = 'TestForCustomObjectRelationSource11';
        testOrchItem.vlocity_cmt__OrderItemId__c = sourceOrderItem.Id; 
        testOrchItem.vlocity_cmt__OrchestrationPlanId__c = sourceOrchPlan.Id; 
        testOrchItem.vlocity_cmt__TimeoutMs__c = 1000.000;
        orchItems.add(testOrchItem);
        
        insert orchItems;
        
        Asset dummyasset = new Asset();
        dummyasset.AccountId = acc.id;
        dummyasset.vlocity_cmt__OrderProductId__c = targetOrderItem.id;
        dummyasset.name = 'Admin Asset';
        insert dummyasset;
        Asset sourceproductasset = new Asset();
        sourceproductasset.AccountId = acc.id;
        sourceproductasset.vlocity_cmt__OrderProductId__c = targetOrderItem.id;
        sourceproductasset.vlocity_cmt__AssetReferenceId__c = targetOrderItem.id;
        sourceproductasset.name = 'Source Product';
        sourceproductasset.vlocity_cmt__AssetReferenceId__c = 'akshay-test-ref2';
        insert sourceproductasset;
        Asset targetproductasset = new Asset();
        targetproductasset.AccountId = acc.id;
        targetproductasset.vlocity_cmt__OrderProductId__c = targetOrderItem.id;
        targetproductasset.vlocity_cmt__AssetReferenceId__c = targetOrderItem.id;
        targetproductasset.vlocity_cmt__AssetReferenceId__c = 'akshay-test-ref';
        targetproductasset.name = 'target Product';
        insert targetproductasset;
    }
    @isTest static void callDeltaAttributeclass(){
        
        Test.startTest();
        List<vlocity_cmt__OrchestrationItem__c> orchItem = [SELECT Id FROM vlocity_cmt__OrchestrationItem__c WHERE Name= 'TestForCustomObjectRelationSource2'];
        
        ARTLUpdateFRLWithDeltaField testobj = new ARTLUpdateFRLWithDeltaField();
        testobj.executeBatch(orchItem);
        
        
        /*ARTLUpdateRateValues testobj1 = new ARTLUpdateRateValues();
        testobj1.executeBatch(orchItem);
            
List<vlocity_cmt__OrchestrationItem__c> orchItem2 = [SELECT Id,vlocity_cmt__OrderItemId__c,vlocity_cmt__OrderItemId__r.OrderId FROM vlocity_cmt__OrchestrationItem__c WHERE Name= 'TestForCustomObjectRelationSource11'];
ARTL_CreateAssetRelationship testobj2 = new ARTL_CreateAssetRelationship();
testobj2.executeBatch(orchItem2);
Test.stopTest();
*/
            
            
            }
}