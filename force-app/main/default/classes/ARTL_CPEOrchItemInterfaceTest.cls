@isTest
private class ARTL_CPEOrchItemInterfaceTest {

    @isTest
    static void testBatchExecution() {
        		vlocity_cmt__FulfilmentRequestLine__c targetFrl = new vlocity_cmt__FulfilmentRequestLine__c();
                //targetFrl.vlocity_cmt__FulfilmentRequestID__c = targetFR.Id;
                targetFrl.vlocity_cmt__FulfilmentStatus__c = 'Activated';
        		targetFrl.vlocity_cmt__AttributeSelectedValues__c = '{"ATT_Display_Modified_Charges":"15","ATT_Billing_Component_ID":null,"ATT_Floor_Rate":null,"ATT_StartDate":null,"ATT_Type":null}';
                targetFrl.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000k8NOUAY","attributeuniquecode__c":"ParentsFulfilled","attributedisplayname__c":"Parents Fulfilled","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Checkbox","default":false,"value":false},"Name":"Parents Fulfilled","Code":"ParentsFulfilled","Filterable":false,"SegmentValue":"false","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHgUAI","attributeuniquecode__c":"Model","attributedisplayname__c":"Model","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Colour"},"Name":"Model","Code":"Model","Filterable":false,"SegmentValue":"Target Comm4 Colour","$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"categorycode__c":"TEST_ATTRIB_CATEG","attributeid__c":"a0X3H000000sdHbUAI","attributeuniquecode__c":"Colour","attributedisplayname__c":"Colour","id":"","objectid__c":"","objecttype__c":null,"categoryname__c":"Category","valuedatatype__c":"Text","displaysequence__c":null,"attributecategoryid__c":"","attributedisplaysequence__c":null,"hasrule__c":false,"isactive__c":true,"ishidden__c":false,"isnotassetizable__c":false,"isreadonly__c":false,"isquerydriven__c":false,"isconfigurable__c":true,"attributefilterable__c":true,"attributeconfigurable__c":true,"isrequired__c":false,"formatmask__c":null,"valueinnumber__c":null,"querycode__c":null,"querylabel__c":null,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Text","default":"","value":"Target Comm4 Model"},"Name":"Colour","Code":"Colour","Filterable":false,"SegmentValue":"Target Comm4 Model","$$AttributeDefinitionEnd$$":null}]}';
                insert targetFrl;
        
        		vlocity_cmt__OrchestrationPlanDefinition__c opd = new vlocity_cmt__OrchestrationPlanDefinition__c(Name = 'Test Commercial Product 2 Orch Plan');
                insert opd;
        		
        		vlocity_cmt__OrchestrationPlan__c targetOrchPlan = new vlocity_cmt__OrchestrationPlan__c();
                //targetOrchPlan.vlocity_cmt__OrderId__c = targetOrder.Id;
        		insert targetOrchPlan;
        
        		Vlocity_cmt__orchestrationitemdefinition__c oid3 = new Vlocity_cmt__orchestrationitemdefinition__c();
                oid3.Name = 'TestForCustomObjectRelationSource2';
                oid3.vlocity_cmt__OrchestrationPlanDefinitionId__c = opd.Id;
        		insert oid3;
        
               vlocity_cmt__OrchestrationItem__c targetorchItem1 = new vlocity_cmt__OrchestrationItem__c();
               targetorchItem1.Name = 'TestForCustomObjectRelationSource2';
               targetorchItem1.vlocity_cmt__OrchestrationItemDefinitionId__c = oid3.Id;
               targetorchItem1.vlocity_cmt__FulfilmentRequestLineId__c = targetFrl.Id; 
               targetorchItem1.vlocity_cmt__OrchestrationPlanId__c = targetOrchPlan.Id; 
               targetorchItem1.vlocity_cmt__TimeoutMs__c = 1000.000;
               targetorchItem1.vlocity_cmt__State__c = 'Completed';
               insert targetorchItem1;
        Test.startTest();
        ARTL_CPEOrchItemInterface batchInstance = new ARTL_CPEOrchItemInterface();
        batchInstance.executeItem('sampleUrl', 'samplePath', targetorchItem1);
        Test.stopTest();
    }
}