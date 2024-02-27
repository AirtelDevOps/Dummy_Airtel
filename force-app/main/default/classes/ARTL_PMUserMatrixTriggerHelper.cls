/**
* Class to implement the trigger helper for PM User Matrix Object
*
* @Author  Salesforce
*
*/
public with sharing class ARTL_PMUserMatrixTriggerHelper {
    
    public static void assignPM(Map<Id,PM_User_Matrix__c> newPMMatrixMap){
        //Insert new Account Team Member
        List<AccountTeamMember> newAccTeamList = new  List<AccountTeamMember>();
        for(PM_User_Matrix__c newPM : newPMMatrixMap.values()){
            AccountTeamMember accTeam = new AccountTeamMember();
            accTeam.UserId = newPM.PM__c;
            accTeam.AccountId = newPM.Business_Account__c;
            accTeam.AccountAccessLevel = 'Read';
            accTeam.ContactAccessLevel = 'Read';
            accTeam.OpportunityAccessLevel = 'Edit';
            accTeam.TeamMemberRole = 'PM';
            newAccTeamList.add(accTeam);
        }
        Database.insert(newAccTeamList, false);

        //Enhancement - Update Existing Opp/Quote?
    }

    public static void reassignPM (Map<Id,PM_User_Matrix__c> newPMMatrixMap, Map<Id,PM_User_Matrix__c> oldPMMatrixMap){
        //Insert new Account Team Member
        List<AccountTeamMember> newAccTeamList = new  List<AccountTeamMember>();
        for(PM_User_Matrix__c newPM : newPMMatrixMap.values()){
            AccountTeamMember accTeam = new AccountTeamMember();
            accTeam.UserId = newPM.PM__c;
            accTeam.AccountId = newPM.Business_Account__c;
            accTeam.AccountAccessLevel = 'Read';
            accTeam.ContactAccessLevel = 'Read';
            accTeam.OpportunityAccessLevel = 'Edit';
            accTeam.TeamMemberRole = 'PM';
            newAccTeamList.add(accTeam);
        }
        Database.insert(newAccTeamList, false);

        //Delete Existing PM
        List<String> oldAccId = new List<String>();
        Map<String, String> oldPMNewPMId = new  Map<String, String>();
        List<String> accIdPMId = new List<String>();
        for(PM_User_Matrix__c oldPM : oldPMMatrixMap.values()){
            oldAccId.add(oldPM.Business_Account__c);
            oldPMNewPMId.put(oldPM.PM__c, newPMMatrixMap.get(oldPM.Id).PM__c);
            accIdPMId.add(oldPM.Business_Account__c+'_'+oldPM.PM__c);
        }

        //Reassign Opp
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        for(Opportunity opp:[SELECT Id, PM__c FROM Opportunity WHERE PM__c IN :oldPMNewPMId.keySet() AND AccountId IN :oldAccId]){
            Opportunity oppinstance = new Opportunity();
            oppinstance.Id = opp.Id;
            oppinstance.PM__c = oldPMNewPMId.get(opp.PM__c);
            oppToUpdate.add(oppinstance);
        }
        //Do not run Opportunity Triggers
        TriggerHandler.bypass('ARTL_OpportunityTriggerHandler');
        Database.update(oppToUpdate, false);
        //update oppToUpdate;

        //Reassign Quote
        List<Quote> quoteToUpdate = new List<Quote>();
        for(Quote quote:[SELECT Id, PM__c FROM Quote WHERE PM__c IN :oldPMNewPMId.keySet() AND AccountId IN :oldAccId]){
            Quote quoteinstance = new Quote();
            quoteinstance.Id = quote.Id;
            quoteinstance.PM__c = oldPMNewPMId.get(quote.PM__c);
            quoteToUpdate.add(quoteinstance);
        }
        //Do not run Quote Triggers
        TriggerHandler.bypass('QuoteTriggerHandler');
        Database.update(quoteToUpdate, false);

        //Reassign Task
        List<Task> taskToUpdate = new List<Task>();
        for(Task t:[SELECT Id, OwnerId FROM Task WHERE OwnerId IN :oldPMNewPMId.keySet() AND AccountId IN :oldAccId]){
            Task taskinstance = new Task();
            taskinstance.Id = t.Id;
            taskinstance.OwnerId = oldPMNewPMId.get(t.OwnerId);
            taskToUpdate.add(taskinstance);
        }
        Database.update(taskToUpdate, false);




    }
    
    public static PM_User_Matrix__Share createPMUserMatrixShare(Id parentId, Id userOrGroupId) {
        PM_User_Matrix__Share sharingRecord = new PM_User_Matrix__Share();
        sharingRecord.ParentId = parentId;
        sharingRecord.UserOrGroupId = userOrGroupId;
        sharingRecord.AccessLevel = 'Edit';
        return sharingRecord;
    }
	//TL should be able to edit only those records that he is assigned to in the TL__c field 
	public static void assignTL(Map<Id, PM_User_Matrix__c> pmRecordsMap) {
        List<PM_User_Matrix__Share> sharingRecordsToInsert = new List<PM_User_Matrix__Share>();

        for (Id recordId : pmRecordsMap.keySet()) {
            PM_User_Matrix__c pmRecord = pmRecordsMap.get(recordId);

            if (pmRecord.TL__c != null) {
                PM_User_Matrix__Share sharingRecord = createPMUserMatrixShare(recordId, pmRecord.TL__c);
            	sharingRecordsToInsert.add(sharingRecord);
            }
        }

        if (!sharingRecordsToInsert.isEmpty()) {
             Database.insert(sharingRecordsToInsert,false);
        }
    }
    //TL should be able to edit only those records that he is assigned to in the TL__c field 
    //when the TL field user is changed
    public static void reassignTL(Map<Id, PM_User_Matrix__c> newPMMatrixMap, Map<Id, PM_User_Matrix__c> oldPMMatrixMap) {
        List<PM_User_Matrix__Share> sharingRecordsToInsert = new List<PM_User_Matrix__Share>();
		List<PM_User_Matrix__Share> sharingRecordsToDelete = new List<PM_User_Matrix__Share>();
        //Create a map to store old sharing records by ParentId
        Map<Id, PM_User_Matrix__Share> oldShareRecordsMap = new Map<Id, PM_User_Matrix__Share>();
        for (PM_User_Matrix__Share oldShareRecord : [
            SELECT Id, ParentId, RowCause
            FROM PM_User_Matrix__Share
            WHERE ParentId IN :newPMMatrixMap.keySet() AND RowCause = 'Manual'
        ]) {
            oldShareRecordsMap.put(oldShareRecord.ParentId, oldShareRecord);
        }
        for (Id recordId : newPMMatrixMap.keySet()) {
            PM_User_Matrix__c newPMRecord = newPMMatrixMap.get(recordId);
            PM_User_Matrix__c oldPMRecord = oldPMMatrixMap.get(recordId);

            if (newPMRecord.TL__c != null && (newPMRecord.TL__c != oldPMRecord.TL__c)) {
				// Delete the old sharing record
                PM_User_Matrix__Share oldShareRecord = oldShareRecordsMap.get(recordId);
                if (oldShareRecord != null) {
                    sharingRecordsToDelete.add(oldShareRecord);
                }
				
				//Create a new sharing record
                PM_User_Matrix__Share sharingRecord = createPMUserMatrixShare(recordId, newPMRecord.TL__c);
                sharingRecordsToInsert.add(sharingRecord);
            }
        }

		if (!sharingRecordsToDelete.isEmpty()) {
            database.delete(sharingRecordsToDelete, false);
        }

        if (!sharingRecordsToInsert.isEmpty()) {
             Database.insert(sharingRecordsToInsert,false);
        }
	}
}