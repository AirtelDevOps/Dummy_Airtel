@isTest
private class ARTL_POExpiryScheduleBatchTest {

    @isTest
    static void testARTL_POExpiryScheduleBatch() {
        // Ensure the schedulable class is covered by test
        Test.startTest();
        ARTL_POExpiryScheduleBatch scheduleBatch = new ARTL_POExpiryScheduleBatch();
        String jobId = System.schedule('TestARTLSchedule', '0 0 0 15 3 ? 2024', scheduleBatch); // Schedule for a specific time
        System.debug('jobId '+jobId);
        Test.stopTest();

        // Assert that the job was scheduled successfully
        //System.assertNotEquals(null, jobId);

       
    }
}