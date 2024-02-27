@isTest
public class ARTL_InvokeIP_Test {

    @isTest
    static void testInvokeIPOnAccCreation() {
        // Test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        ARTL_InvokeIP.invokeIPOnAccCreation(acc.Id, 'ARTL_FXCreateVANAccount');
    }

    @isTest
    static void testIntegrationProcedureQueueable() {
        // Test data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        List<Id> accIds = new List<Id>{acc.Id};
 
        Test.startTest();
        ARTL_InvokeIP.IntegrationProcedureQueueable queueable = new ARTL_InvokeIP.IntegrationProcedureQueueable(
            accIds, 'TestIPName', new Map<String, Object>(), new Map<String, Object>(), new Map<String, Object>());
        System.enqueueJob(queueable);
        Test.stopTest();
    }
}