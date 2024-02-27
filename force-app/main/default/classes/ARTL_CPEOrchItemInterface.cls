global class ARTL_CPEOrchItemInterface extends vlocity_cmt.DefaultSystemInterface {
    global override void executeItem(String url, String path, vlocity_cmt__OrchestrationItem__c item) {
        String procedureName = 'ARTL_CPEwithSingleOrder';
        Map <String, Object> ipInput = new Map <String, Object> {'OrchItemId' => item.Id};
        Map <String, Object> ipOutput = new Map <String, Object> ();
        Map <String, Object> ipOptions = new Map <String, Object> ();
          
        ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
    }
}