@isTest
private class ARTL_PORenewalInterfaceTest {

    @isTest
    static void testExecuteBatch() {
        List<vlocity_cmt__OrchestrationItem__c> orchestrationItems = new List<vlocity_cmt__OrchestrationItem__c>();
        vlocity_cmt__OrchestrationItem__c targetorchItem1 = new vlocity_cmt__OrchestrationItem__c();
        targetorchItem1.Name = 'TestForCustomObjectRelationSource2';
        //targetorchItem1.vlocity_cmt__OrchestrationItemDefinitionId__c = oid3.Id;
        //targetorchItem1.vlocity_cmt__FulfilmentRequestLineId__c = targetFrl.Id; 
        //targetorchItem1.vlocity_cmt__OrchestrationPlanId__c = targetOrchPlan.Id; 
        targetorchItem1.vlocity_cmt__TimeoutMs__c = 1000.000;
        targetorchItem1.vlocity_cmt__State__c = 'Completed';
        orchestrationItems.add(targetorchItem1);
        

        Test.startTest();
        ARTL_PORenewalInterface renewalInterface = new ARTL_PORenewalInterface();
        renewalInterface.executeBatch(orchestrationItems);
        Test.stopTest();
    }    
}