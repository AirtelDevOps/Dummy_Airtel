@isTest
public class ARTL_ProcessApprovalRequestTest {
    @isTest
    static void testOVApprovalMethod() {
        String quoteId       = ARTL_ValidateStagingDataHelper.getQuoteIdPos();
        String publicGroupId = ARTL_ValidateStagingDataHelper.getGroupId();
        String opportunityId = ARTL_ValidateStagingDataHelper.getOpportunityId();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>{'QuoteId' => quoteId,'PublicGroupId'=> publicGroupId,'OpportunityId'=> opportunityId};
        ARTL_ProcessApprovalRequest approvalRequest = new ARTL_ProcessApprovalRequest();
        Test.startTest();
        Boolean result = approvalRequest.invokeMethod('submitForOVApproval', inputMap,outputMap,optionsMap);
        Boolean result1 = approvalRequest.invokeMethod('approveOVApproval', inputMap,outputMap,optionsMap);
        Test.stopTest();
        system.assertEquals(true, result);
        system.assertEquals(true, result1);
    }
}