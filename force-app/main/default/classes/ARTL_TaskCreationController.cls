/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ARTL_CreatePMApprovalTaskController
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Abinash Barik    <abinash.barik@salesforce.com>
* @modifiedBy     Abinash Barik    <abinash.barik@salesforce.com>
* @maintainedBy   Abinash Barik    <abinash.barik@salesforce.com>
* @TestClass 	  ARTL_TaskCreationControllerTest
* @version        1.0
* @created        2023-10-26
* @modified       YYYY-MM-DD
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* Initial changes
* 1.0             abinash.barik@salesforce.com
* 2023-10-26	SFDC-997 : https://confluence.airtel.com/pages/viewpage.action?spaceKey=SFDC&title=Non-Deemed
*				
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
global  with sharing class ARTL_TaskCreationController{
	//Invocable Method to call from Flow To generate Welcome Letter and Send email to customer with Attachment
    @InvocableMethod(label='create Multiple Task')
    public static void CreateTaskFromFlow(List<FlowInput> flowInputs) {
        String recordId = flowInputs.get(0).recordId;
        List<Task> lstTasktobeCreated = new List<Task>();
        Task objTask = getTaskDetail(recordId);
        Map<String,ATRL_PM_Approval_SubTask__mdt> mapOfSubtask = new Map<String, ATRL_PM_Approval_SubTask__mdt>();
        mapOfSubtask = getSubtaskDetails();
        // this block is creating new Open Task
        if(mapOfSubtask.containsKey(objTask.ARTL_TaskType__c) && (objTask.ARTL_TaskType__c == 'LOC to customer' || objTask.ARTL_TaskType__c == 'PM Approval for LOC'
                                         || objTask.ARTL_TaskType__c == 'PM upload LOC')){
            List<String> lstSubtypes = mapOfSubtask.get(objTask.ARTL_TaskType__c).Subtask__c.Split(',');
            	if(lstSubtypes.size() > 0){
					for(String sType : lstSubtypes){
                        lstTasktobeCreated.add(preapreTaskrecord(sType,objTask));
						
					}
            	}
			}else{
                List<Task> lstExistingTask = getAllrelatedTask(objTask.WhatId); 
                // this block is updating 'PM upload LOC' Task to Re-Open
                if(objTask.ARTL_TaskType__c == 'LOC validation' && objTask.Status == 'Rejected'){
                    for(Task objExist : lstExistingTask){
                        if(objExist.ARTL_TaskType__c == 'PM upload LOC' && objExist.Status != 'Re-Open'){
                            objExist.Status='Re-Open';
                            lstTasktobeCreated.add(objExist);
                        }
                    }
                }// this block is updating all related Task to 'Closed' except 'PM approval for LOC'
                else if(objTask.ARTL_TaskType__c == 'IP Port Shut' && objTask.Status == 'Rejected'){
                    for(Task objExist : lstExistingTask){
                        if(objExist.ARTL_TaskType__c != 'PM approval for LOC' && objExist.Status != 'Closed'){
                            objExist.Status='Closed';
                            lstTasktobeCreated.add(objExist);
                        }
                    }
                }
                // this block is updating all related 'Open' task to 'Closed' and create a new Task 'Trouble shooting'
                else if(objTask.ARTL_TaskType__c == 'IP Port Shut' && objTask.Status == 'Accepted'){
                    	for(Task objExist : lstExistingTask){
                            if(objExist.Status == 'Open'){
                                objExist.Status='Closed';
                                lstTasktobeCreated.add(objExist);
                            }
                        }
                    	lstTasktobeCreated.add(preapreTaskrecord('Trouble shooting',objTask));
                }
			}
        if(!lstTasktobeCreated.isEmpty()){
            upsert lstTasktobeCreated;
        }
        
    }
    //Flow Inputs
    public class FlowInput{
        @InvocableVariable(required=true) public Id recordId;
        //@InvocableVariable(required=true) public Task objTask;
    }
    
    Public static Task preapreTaskrecord(String taskType, Task extrec){
        Task newobjtask = new Task();
        newobjtask.Subject = taskType;
        newobjtask.ARTL_TaskType__c = taskType;
        newobjtask.Quote_Line_Item__c = extrec.Quote_Line_Item__c;
        newobjtask.Status = 'Open';
        newobjtask.WhatId = extrec.WhatId;
        newobjtask.ARTL_locAcceptanceCriteria__c = extrec.ARTL_locAcceptanceCriteria__c;
        newobjtask.OwnerId = extrec.Quote_Line_Item__r.Quote.PM__c != null ? extrec.Quote_Line_Item__r.Quote.PM__c : userinfo.getuserid();
        newobjtask.ARTL_ParentTaskId__c = extrec.Id;
        return newobjtask;
    }
    
    Public static Task getTaskDetail(String recordId){
        return [Select Id, ARTL_TaskType__c, Quote_Line_Item__c, Quote_Line_Item__r.QuoteId,Quote_Line_Item__r.Quote.PM__c,
                 ARTL_locAcceptanceCriteria__c, OwnerId, Status,WhatId 
                FROM Task WHERE Id =: recordId];
    }
    
    Public static Map<String,ATRL_PM_Approval_SubTask__mdt> getSubtaskDetails(){
        Map<String,ATRL_PM_Approval_SubTask__mdt> mapOfSubtask = new Map<String, ATRL_PM_Approval_SubTask__mdt>();
        for(ATRL_PM_Approval_SubTask__mdt subtask: [Select Id,DeveloperName,Subtask__c, MasterLabel 
                                                    FROM ATRL_PM_Approval_SubTask__mdt]){
            mapOfSubtask.put(subtask.MasterLabel,subtask);
        }
        return mapOfSubtask;
    }
    
    Public Static List<Task> getAllrelatedTask(String objwhatId){
        return [Select Id, ARTL_TaskType__c, Quote_Line_Item__c, Quote_Line_Item__r.QuoteId,Quote_Line_Item__r.Quote.PM__c,
                 ARTL_locAcceptanceCriteria__c, OwnerId, Status,WhatId 
                FROM Task WHERE WhatId =:objwhatId];
    }
}