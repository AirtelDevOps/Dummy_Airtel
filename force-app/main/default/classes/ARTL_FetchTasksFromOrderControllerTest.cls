@isTest
public with sharing class ARTL_FetchTasksFromOrderControllerTest {
    @isTest
    static void testGetTasks() {
        // Create test data: Master Order Record Type
        RecordType masterOrderRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Order' AND DeveloperName = 'MasterOrder' LIMIT 1];
		Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
       
		Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = recordTypeId;
        acc.BillingStreet = 'Test Street';
        acc.BillingState  = 'Karnataka';
        acc.BillingCity   = 'Bengaluru';
        acc.BillingCountry= 'India';
        acc.BillingPostalCode = '560087';
        acc.ARTL_Category__c ='A';
        acc.ARTL_Customer_Segment__c ='AB';
        acc.ARTL_Vertical_Segment__c ='BFI';
        acc.ARTL_Service_Segment__c ='Bharti';
        acc.ARTL_Business_Circle_Region__c='NCR';
        insert acc;
        // Create test data: Master Order
        Order masterOrder = new Order(
            RecordTypeId = masterOrderRecordType.Id,AccountId = acc.Id,effectiveDate = Date.today(),status = 'Draft');
        insert masterOrder;

        // Create test data: Sub Order Record Type
        RecordType subOrderRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Order' AND DeveloperName = 'SubOrder' LIMIT 1];

        // Create test data: Sub Order
        Order subOrder = new Order(
            RecordTypeId = subOrderRecordType.Id,
            vlocity_cmt__ParentOrderId__c = masterOrder.Id,AccountId = acc.Id,effectiveDate = Date.today(),status = 'Draft'
           
        );
        insert subOrder;

        // Create test data: Task for Master Order
        Task taskForMasterOrder = new Task(
            Subject = 'Task for Master Order',
            WhatId = masterOrder.Id
            
        );
        insert taskForMasterOrder;

        // Create test data: Task for Sub Order
        Task taskForSubOrder = new Task(
            Subject = 'Task for Sub Order',
            WhatId = subOrder.Id
            
        );
        insert taskForSubOrder;
        
        // Call the method in the controller
        List<Task> resultMasterOrder = ARTL_FetchTasksFromOrderController.getTasks(masterOrder.Id);
        List<Task> resultSubOrder = ARTL_FetchTasksFromOrderController.getTasks(subOrder.Id);

    }
}