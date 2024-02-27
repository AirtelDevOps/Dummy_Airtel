/**
 * @description       : SFDC-1110 - SAM Automated task to be created, if appointment on account has not been made within the set duration
 * @test class        : ARTL_SAMJourneyAutomatedTaskBatchTest
 * @author            : Rishab Kalra
 * @last modified on  : 12-11-2023
**/
public without sharing class ARTL_SAMJourneyAutomatedTaskBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc)
    {   
        return Database.getQueryLocator([SELECT Id, Name, ARTL_SAM_Account_Visit_Frequency__c,
                                         (SELECT Id, AccountId, ActivityDate, CreatedDate, Owner.UserRole.DeveloperName
                                          FROM Events 
                                          WHERE Owner.UserRole.DeveloperName LIKE '%SAM%'
                                          order by createdDate desc LIMIT 1),
                                         (SELECT Id, AccountId 
                                          FROM Tasks
                                          WHERE ARTL_TaskType__c = 'Meeting Reminder'
                                          AND Status NOT IN ('Completed', 'Closed', 'Rejected') 
                                          order by createdDate desc LIMIT 1),
                                         (SELECT Id, UserId, User.Name, TeamMemberRole 
                                          FROM AccountTeamMembers 
                                          WHERE TeamMemberRole = 'SAM' 
                                          order by CreatedDate desc LIMIT 1)
                                         FROM Account WHERE ARTL_SAM_Account_Visit_Frequency__c != null
                                         AND RecordType.Name = 'Business']);
    }
    public void execute(Database.BatchableContext bc, List<Account> scope)
    {
        try{
            Map<Id, Account> mapOfAccount = new Map<Id, Account>();
            Map<Id, Event> mapOfAccountIdEvent = new Map<Id, Event>();
            Map<Id, Task> mapOfAccountIdTask = new Map<Id, Task>();
            String meetingReminder = 'Meeting Reminder';
            String samUserId;
            for(Account acc: scope){
                mapOfAccount.put(acc.Id, acc);
                if(!acc.Events.isEmpty()){
                    mapOfAccountIdEvent.put(acc.Id, acc.Events[0]);
                }
                if(!acc.Tasks.isEmpty()){
                    mapOfAccountIdTask.put(acc.Id, acc.Tasks[0]);
                    
                }
                if(!acc.AccountTeamMembers.isEmpty()){
                    samUserId = acc.AccountTeamMembers[0].UserId;
                }
            }
            List<Task> createTask = new List<Task>();
            for(Id accId: mapOfAccount.keySet()){
                Event event = mapOfAccountIdEvent.get(accId);
                Date dateToday = Date.Today();
                Integer samAccountVisitFrequency = Integer.valueOf(mapOfAccount.get(accId).get('ARTL_SAM_Account_Visit_Frequency__c'));
                Datetime reminderDate = Datetime.now().addMinutes(15);
                Integer activityDate;                
                if(event != null){
                    activityDate = dateToday.daysBetween(event?.ActivityDate);
                    if(activityDate < 0){
                        activityDate = activityDate * -1;
                    }
                } 
                
                if(event == null || (event != null && (activityDate > samAccountVisitFrequency))){
                    if(!mapOfAccountIdTask.containsKey(accId) && !String.isBlank(samUserId)){
                        //create task
                        Task newTask = new Task(WhatId = accId,
                                                ARTL_TaskType__c = meetingReminder,
                                                Subject = 'Airtel Service Assurance Meeting Task - '+ mapOfAccount.get(accId).get('Name'),
                                                IsReminderSet = true,
                                                ReminderDateTime = reminderDate,
                                                ActivityDate = Date.Today().addDays(2),
                                                OwnerId = samUserId);
                        createTask.add(newTask);
                    }
                }
            }
            insert createTask;
        }
        catch(Exception ex){
            System.debug('DEBUGG Exception '+ ex.getLineNumber() + ex.getMessage());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_SAMJourneyAutomatedTaskBatch', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);

        }
    }
    public void finish(Database.BatchableContext bc) {
    }
}