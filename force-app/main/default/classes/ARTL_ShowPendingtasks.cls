public with sharing class ARTL_ShowPendingtasks {
    @AuraEnabled(cacheable=true)
    public static List<Task> getOpenTasks() {
        return [SELECT Id,Subject,ARTL_TaskType__c,Account.Name,WhatId,What.Name,Owner.Name, Status FROM Task WHERE ARTL_TaskType__c= 'Meeting Reminder' and OwnerId =:UserInfo.getUserId()];
    }
}