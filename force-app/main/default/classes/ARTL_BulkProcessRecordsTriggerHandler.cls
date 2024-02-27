/******************************************************************************************************
* @Author       : bijaya.dutta@salesforce.com
* @Company      : Salesforce
* @Date         : 30-Jan-2024
* @Test Class   : ARTL_BulkProcessRecordsHandlerTest
* @Description  : platformEventTrigger Handler to process the bulk records stored in that event.
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date             Comment
*  SFDC-3180             Bijaya Dutta        30-Jan-2024      Initial Dev
*******************************************************************************************************/
public class ARTL_BulkProcessRecordsTriggerHandler {
    public static void processAfterInsert(List<ARTL_Bulk_Process_Records__e> platformEventRecords){
        try{
    	for(ARTL_Bulk_Process_Records__e platformEventRec : platformEventRecords){
            Map<String,Object> payload = (Map<String,Object>) JSON.deserializeUntyped(platformEventRec.Request_JSON_Payload__c);
            Map<String, Object> ipInput = new Map<String, Object>();
            Map<String, Object> ipOutput = new Map<String, Object>();
            Map<String, Object> ipOptions = new Map<String, Object>();
            
            ipOptions.put('isDebug',false);
            ipInput.put('payload', payload);
            ipInput.put('Record_ID__c', platformEventRec.Record_ID__c );
            ipInput.put('Transaction_Type__c', platformEventRec.Transaction_Type__c );
            string ipInputString = JSON.serialize(ipInput);
            ipOutput = (Map<String,Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService('ARTL_BulkTaskUpdate', ipInput, ipOptions);
        }
        }
        catch (Exception e) {
            System.debug('error msg### ' + e.getMessage());
        }
    }

}