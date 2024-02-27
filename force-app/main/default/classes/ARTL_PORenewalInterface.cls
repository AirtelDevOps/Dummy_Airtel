global class ARTL_PORenewalInterface implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
    global void executeBatch(List < vlocity_cmt__OrchestrationItem__c > items) {
        for (vlocity_cmt__OrchestrationItem__c item: items) {
            ARTL_OrchestrationItemInterface autoTaskCall = new ARTL_OrchestrationItemInterface();
            autoTaskCall.executeItem('','',item);
        }
    }
}