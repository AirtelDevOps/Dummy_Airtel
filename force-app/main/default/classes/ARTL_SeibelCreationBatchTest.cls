@isTest
private class ARTL_SeibelCreationBatchTest {
    @testSetup
    static void testSetupMethod(){
        Case caseRec = new Case (Status = 'In-Progress', 
                                 Origin = 'Web');
        insert caseRec;
    }
    @isTest
    static void testBatchExecution() {
        Case caseobj = [Select id, CaseNumber from Case];

        // Start the batch job
        Test.startTest();
        ARTL_SeibelCreationBatch batchJob = new ARTL_SeibelCreationBatch(caseobj.CaseNumber);
        Database.executeBatch(batchJob);
        Test.stopTest();   
    }
}