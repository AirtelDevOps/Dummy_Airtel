@isTest
public class ARTL_JeopardyManagementCalloutTest {

    @isTest
    static void testIntegrationMethod() {
        ARTL_JeopardyManagementCallout.IntegrationProcedureInput NewObject = new ARTL_JeopardyManagementCallout.IntegrationProcedureInput();
        List < ARTL_JeopardyManagementCallout.IntegrationProcedureInput > testinput = new List < ARTL_JeopardyManagementCallout.IntegrationProcedureInput >();
        NewObject.procedureAPIName = 'test_IP';
        NewObject.input = '123456';
        testinput.add(NewObject);
        Test.startTest();
        ARTL_JeopardyManagementCallout.runIntegrationServiceInvocable(testinput);
 		Test.stopTest();
    }
}