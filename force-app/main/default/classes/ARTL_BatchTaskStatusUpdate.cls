/************************************************************************************************************************************************************************************************************
* @Author       : Abinash Barik <abinash.barik@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 25/11/2023
* @Test Class   : ARTL_BatchTaskStatusUpdateTest
* @Description  : LOC Acceptance Criteria : Deemed, Compare LOC Bill Start Date + ARTL Number of Days for Deemed LOC = Todays date
* Update the Task Status = Accepted
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1. SFDC-330              Abinash Barik         25/11/2023     Initial Dev
******************************************************************************************************************************************************************************************************************/

public class ARTL_BatchTaskStatusUpdate implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT ID, ARTL_locAcceptanceCriteria__c,ARTL_LOC_Bill_Start_Date__c, Number_of_days_for_Deemed_LOC__c ,' +
            'Status  FROM Task ' +
            'Where ARTL_locAcceptanceCriteria__c = \'Deemed\' AND Status != \'Accepted\' AND RecordType.Name=\'LOC\''
        );
    }
    public void execute(Database.BatchableContext bc, List<Task> records){
         // process each batch of records
        List<Task> lstTasktobeUpdated = new List<Task>();
        for(Task objtask: records){
            System.debug('Today>>>'+Date.Today());
            //System.debug('>>>'+Date.valueOf(objtask.ARTL_LOC_Bill_Start_Date__c.addDays(Integer.valueOf(objtask.Number_of_days_for_Deemed_LOC__c))));
            if(objtask.ARTL_LOC_Bill_Start_Date__c != null && objtask.Number_of_days_for_Deemed_LOC__c != null && Date.valueOf(objtask.ARTL_LOC_Bill_Start_Date__c.addDays(Integer.valueOf(objtask.Number_of_days_for_Deemed_LOC__c))) == Date.Today()){
                objtask.Status = 'Accepted';
                lstTasktobeUpdated.add(objtask);
            }
        }
        System.debug('lstTasktobeUpdated>>>'+lstTasktobeUpdated);
        if(!lstTasktobeUpdated.isEmpty()){
            update lstTasktobeUpdated;
        }
       
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}