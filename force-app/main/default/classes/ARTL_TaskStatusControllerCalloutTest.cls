@isTest
private class ARTL_TaskStatusControllerCalloutTest {
    
    static testMethod void testSuspendOrder() {
        
        List<ARTL_TaskStatusControllerCallout.IntegrationProcedureInput> inputList = new List<ARTL_TaskStatusControllerCallout.IntegrationProcedureInput>();
        ARTL_TaskStatusControllerCallout.IntegrationProcedureInput input = new ARTL_TaskStatusControllerCallout.IntegrationProcedureInput();
        input.procedureAPIName = 'TestProcedure';
        input.recordId = 'TestRecordId';
        input.OrderType = 'SUSPEND_ORDER';
        inputList.add(input);
        
        Test.startTest();
        List<ARTL_TaskStatusControllerCallout.IntegrationProcedureOutput> result = ARTL_TaskStatusControllerCallout.runIntegrationServiceInvocable(inputList);
        Test.stopTest();
        
        System.assertEquals(1, result.size());
    }
    
    static testMethod void testResumeOrder() {
        
        List<ARTL_TaskStatusControllerCallout.IntegrationProcedureInput> inputList = new List<ARTL_TaskStatusControllerCallout.IntegrationProcedureInput>();
        ARTL_TaskStatusControllerCallout.IntegrationProcedureInput input = new ARTL_TaskStatusControllerCallout.IntegrationProcedureInput();
        input.procedureAPIName = 'TestProcedure';
        input.recordId = 'TestRecordId';
        input.OrderType = 'RESUME_ORDER';
        inputList.add(input);
        
        Test.startTest();
        List<ARTL_TaskStatusControllerCallout.IntegrationProcedureOutput> result = ARTL_TaskStatusControllerCallout.runIntegrationServiceInvocable(inputList);
        Test.stopTest();
        
        System.assertEquals(1, result.size());
    }
    
    static testMethod void testOrder() {
        
        List<ARTL_TaskStatusControllerCallout.IntegrationProcedureInput> inputList = new List<ARTL_TaskStatusControllerCallout.IntegrationProcedureInput>();
        ARTL_TaskStatusControllerCallout.IntegrationProcedureInput input = new ARTL_TaskStatusControllerCallout.IntegrationProcedureInput();
        input.procedureAPIName = 'TestProcedure';
        input.recordId = 'TestRecordId';
        input.OrderType = 'Test_ORDER';
        inputList.add(input);
        
        Test.startTest();
        List<ARTL_TaskStatusControllerCallout.IntegrationProcedureOutput> result = ARTL_TaskStatusControllerCallout.runIntegrationServiceInvocable(inputList);
        Test.stopTest();
        
        System.assertEquals(1, result.size());
    }
}