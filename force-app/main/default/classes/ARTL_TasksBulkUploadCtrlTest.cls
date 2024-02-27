/******************************************************************************************************
* @Author       : bijaya.dutta@salesforce.com
* @Company      : Salesforce
* @Date         : 30-Jan-2024
* @Description  : Test class for ARTL_TasksBulkUploadCtrl 
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect        Developer             Date             Comment
* SFDC-3180                Bijaya Dutta        30-Jan-2024      Initial Dev
*******************************************************************************************************/
@isTest
public class ARTL_TasksBulkUploadCtrlTest {
	@testSetup 
    static void setup() {
        Account acc = new Account(Name = 'Test Account',billingCity='pune',billingState = 'Maharastra', ARTL_Legal_Entity__c = 'NXTRA DATA LIMITED',artl_customer_segment__c = 'AB',
                                  artl_business_circle_region__c = 'NCR' , artl_vertical_segment__c= 'BFI' );
        insert acc;
        Task newobjtask1 = new Task(Subject = 'PM approval task',Status = 'Completed',OwnerId =Userinfo.getUserId());
        insert newobjtask1;
        
        Task newobjtask2 = new Task(Subject = 'LOC to customer',Status = 'Open',OwnerId =Userinfo.getUserId());
        insert newobjtask2;
    }
    @isTest
    public static void testMethods() {
        List<Task> tasks = [SELECT Id, Status FROM Task];

        List<String> taskIds = new List<String>();
        List<String> emptyIds = new List<String>();
        List<Object> objList = new List<Object>();
        List<Object> emptyobjList = new List<Object>();

        for (Task task : tasks) {
            String taskId15Char = String.valueOf(task.Id).substring(0, 15);
            taskIds.add(taskId15Char);
            objList.add(new Map<String, Object>{'TaskId' => taskId15Char, 'Status' => task.Status});
        }

        //Test the method
        Test.startTest();
        String result = ARTL_TasksBulkUploadCtrl.createTaskRecordsOnBulkCartUpdate(taskIds, objList);
        String nullResult = ARTL_TasksBulkUploadCtrl.createTaskRecordsOnBulkCartUpdate(null, null);
        String emptyResult = ARTL_TasksBulkUploadCtrl.createTaskRecordsOnBulkCartUpdate(emptyIds, emptyobjList);
        Test.stopTest();
        
    }
}