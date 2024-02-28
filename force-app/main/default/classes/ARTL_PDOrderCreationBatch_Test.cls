@isTest
private class ARTL_PDOrderCreationBatch_Test {
     @testSetup
    static void testSetupMethod(){
        Case caseRec = new Case (Status = 'In-Progress', 
                                 Origin = 'Web');
        insert caseRec;
    }
    @isTest
    static void testBatchExecution() {
        Case caseobj = [Select id, CaseNumber from Case];
        ARTL_PDOrderCreationBatch batchInstance = new ARTL_PDOrderCreationBatch(caseobj.CaseNumber);
        Test.startTest();
        ID batchProcessId = Database.executeBatch(batchInstance);
        Test.stopTest();
        
        System.assertNotEquals(null, batchProcessId, 'Batch job should have been queued');
        
    }
}