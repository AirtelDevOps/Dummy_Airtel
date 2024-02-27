/******************************************************************************************************
* @Author       : bijaya.dutta@salesforce.com
* @Company      : Salesforce
* @Date         : 30-Jan-2024
* @Test Class   : ARTL_TasksBulkUploadCtrlTest
* @Description  : Controller for ArtlFileUploadModal LWC
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date             Comment
*  SFDC-3180             Bijaya Dutta        30-Jan-2024      Initial Dev
*******************************************************************************************************/
public with sharing class ARTL_TasksBulkUploadCtrl {
    

    @AuraEnabled
    public static string createTaskRecordsOnBulkCartUpdate(List<String> taskIds ,List<Object> objList){
        List<sObject> lstStageToInsert = new List<sObject>();
        List<ARTL_Bulk_Process_Records__e> lstBulkProcessRecords = new List<ARTL_Bulk_Process_Records__e>();
        Map<String,String> taskStatusMap = new Map<String,String>();
       
        try {
            if(!(objList.isEmpty())){       
                for(Object obj : objList){
                    Map<String, Object> objRow = new Map<String, Object>();
                    objRow = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                    String taskId=(String)objRow.get('TaskId');
                    String taskStatus=(String)objRow.get('Status');
                    taskStatusMap.put(taskId,taskStatus);
                }
            }
        if(!taskIds.isEmpty()) {
            for(Task taskRecord : [SELECT Id, AccountId FROM Task WHERE Id IN :taskIds]) {
                String taskId15Char = String.valueOf(taskRecord.Id).substring(0, 15);
                if (taskStatusMap.containsKey(taskId15Char)) {
                    // Retrieve the status from the map
                    String status = taskStatusMap.get(taskId15Char);

                ARTL_BulkCartUpdate__c objRec = new ARTL_BulkCartUpdate__c();
                objRec.Transaction_Id__c = taskRecord.Id;
                objRec.Business_Account_Id__c = taskRecord.AccountId;
                String jsonPayload = '{"TaskId":"' + taskRecord.Id + '","Status":"' + status + '"}';
                objRec.put('Request_JSON_Payload__c', jsonPayload);
                objRec.Status__c = 'In progress';
                objRec.Transaction_Type__c = 'Task Update';
                lstStageToInsert.add(objRec);

                ARTL_Bulk_Process_Records__e bulkProcessRecord = new ARTL_Bulk_Process_Records__e(
                        Transaction_Type__c = 'Task Update',
                        Request_JSON_Payload__c = jsonPayload
                    );
                    lstBulkProcessRecords.add(bulkProcessRecord);
            }
        }
        }
        if (!lstStageToInsert.isEmpty()) {
            // Insert the ARTL_BulkCartUpdate__c records
            Database.insert(lstStageToInsert);
            
            //Update Bulk Process Records with Transaction Record IDs
            for (Integer i = 0; i < lstStageToInsert.size(); i++) {
                ARTL_Bulk_Process_Records__e bulkProcessRecord = lstBulkProcessRecords[i];
                bulkProcessRecord.Record_Id__c = lstStageToInsert[i].Id;
                
            }
            EventBus.publish(lstBulkProcessRecords) ;

            return 'success';
        }
        return 'No records to process';
        } catch (Exception e) {
            System.debug('error msg=' + e.getMessage());
            return 'error = ' + e.getMessage();
        }
    }
}