@isTest
public class ARTL_BulkApplyAdjustmentBatchTest {
    @isTest
    static void testBatchExecution() {
        String response =  '{"adjustmentValues":[{"Field":"Annual_Recurring_Charge__c","AdjustmentValue":55555,"PricingVariableCode":"REC_YRLY_STD_PRC","cartId":"0Q0720000006atdCAA","id":"0QL720000007KziGAE"}],"SobjectType":"Quote","WorkingCartId":"0Q0720000006atdCAA","GroupCartId":"0Q0720000006atdCAA","callBatch":"123","WorkingCartInput":{"SalesQuoteId":"","RootItemIds":""},"cloneSourceIdMap":{"567":"4567"},"CartId":"435678"}';
        Map<String,Object> fullAdjustmentInputMap = (Map<String,Object>)JSON.deserializeUntyped(response);

        ARTL_BulkApplyAdjustmentBatch batchInstance = new ARTL_BulkApplyAdjustmentBatch(fullAdjustmentInputMap);

        // Execute the batch
        Test.startTest();
        Database.executeBatch(batchInstance,1);
        Test.stopTest();

    }
}