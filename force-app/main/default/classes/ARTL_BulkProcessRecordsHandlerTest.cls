/******************************************************************************************************
* @Author       : bijaya.dutta@salesforce.com
* @Company      : Salesforce
* @Date         : 30-Jan-2024
* @Description  : Test class for ARTL_BulkProcessRecordsTriggerHandler 
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date             Comment
*  SFDC-3180             Bijaya Dutta        30-Jan-2024      Initial Dev
*******************************************************************************************************/
@isTest
public class ARTL_BulkProcessRecordsHandlerTest {

    @IsTest
    static void myUnitTest1() {
        // Create test data for platform event
        ARTL_Bulk_Process_Records__e e = new ARTL_Bulk_Process_Records__e();
        e.Request_JSON_Payload__c = '{"TaskId":"00T720000059JBtEAM","Status":"Completed"}';
        e.Record_ID__c = '0Q0720000006atdCAA';    
        e.Transaction_Type__c = 'Task Update';
        // Publish test event
        Test.startTest();
        Database.SaveResult sr = EventBus.publish(e);  
        // Process the published event in the trigger handler
        List<ARTL_Bulk_Process_Records__e> eventList = new List<ARTL_Bulk_Process_Records__e>{e};
        List<ARTL_Bulk_Process_Records__e> emptyEventList = new List<ARTL_Bulk_Process_Records__e>{null};
        ARTL_BulkProcessRecordsTriggerHandler.processAfterInsert(eventList);
        ARTL_BulkProcessRecordsTriggerHandler.processAfterInsert(emptyEventList);
        Test.stopTest();
    }
}