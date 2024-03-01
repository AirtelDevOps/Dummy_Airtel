@isTest
public class ARTL_AfterLOCCreationCalloutTest {
    static testMethod void testTaskHandler(){
         
        Id recordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account acc = new Account(Name = 'Test Account',ARTL_Business_Circle_Region__c='NCR',BillingCity = 'Panchkula',
                                  BillingCountry = 'Haryana',BillingPostalCode = '134109',BillingState = 'India',BillingStreet = 'Panchkula',
                                  ARTL_Category__c = 'A',RecordTypeId = recordTypeId1, ARTL_Customer_Segment__c ='AB', 
                                  ARTL_Vertical_Segment__c ='BFI',ARTL_Service_Segment__c ='Bharti');
        insert acc;
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = acc.Id, Email = 'test.contact@email.com', Phone= '1234567890', Salutation= 'Mr.', ARTL_Designation__c='TestDesgntn', ARTL_Contact_Role__c = 'Delivery Contact', Country_Code__c = '91');
        insert testContact;
        List<Product2> products = new List<Product2>();        
        Id pbId = Test.getStandardPricebookId();
        products = new Product2[2];
        products[0]=new Product2(name='VEPC_PRIMARY_LINK', ProductCode='VEPC_PRIMARY_LINK ',vlocity_cmt__JSONAttribute__c = '');
        products[1]=new Product2(name='VEPC_PRIMARY_MPLS_LINK ', ProductCode='VEPC_PRIMARY_MPLS_LINK ', vlocity_cmt__JSONAttribute__c = '');
        insert products;
        
        PricebookEntry[] pbes = new PricebookEntry[products.size()];
        for (Integer i=0; i<products.size(); i++)        {
            pbes[i] = new PricebookEntry(product2Id = products[i].id, isActive=true,unitPrice = 10, pricebook2id = pbId, useStandardPrice = false);
        }
        insert pbes;
        
        Order order = new Order(AccountId = acc.id, effectiveDate = Date.today(), pricebook2id = pbId, status = 'Draft');
        insert order;
        OrderItem testOrderItem1 = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = pbes[0].Id,
            Quantity = 3,
            UnitPrice = 10,
            vlocity_cmt__BillingAccountId__c = acc.Id,
            vlocity_cmt__LineNumber__c = '0003',
            vlocity_cmt__AssetReferenceId__c ='5678',
            vlocity_cmt__RootItemId__c = '5678'
        );
        insert testOrderItem1;
        Id recordTypeId2 = Schema.SObjectType.Task.getRecordTypeInfosByName().get('LOC').getRecordTypeId();
        List<Task> tlist = new List<Task>();
        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.recordTypeId = recordTypeId2;
        t.WhatId = order.Id;
        t.ARTL_Rejection_Category__c = 'Valid';
        t.ARTL_locRejectionReason__c = 'Customer End Hardware Pending-NSG';
        t.Subject='LOC Customer';
        t.Status='Not Started';
        t.Priority='Normal';
        tlist.add(t);
        insert tlist;
        
        ARTL_LOC_Task_Approval__c objTA = new ARTL_LOC_Task_Approval__c(TaskId__c=tlist[0].Id,Comments__c='Test Task Approval');
        insert objTA;
        
        map<Id,task> taskMapNew = new map<Id, task>();
        taskMapNew.put(t.Id, t);
        
        map<Id,task> taskMapOld = new  map<Id,task>([SELECT Id, ARTL_Rejection_Category__c from task]);
        
        List<Task> tempTasks = [SELECT Id, ARTL_Rejection_Category__c from task];
        tempTasks[0].ARTL_Rejection_Category__c = 'InValid';
        tempTasks[0].ARTL_LOC_Task_Approval__c = objTA.Id;
        //update tempTasks;
        
        taskMapOld.put(tempTasks[0].Id, tempTasks[0]);
         ARTL_AfterLOCCreationCallout.taskLOC NewObject = new ARTL_AfterLOCCreationCallout.taskLOC();
        List < ARTL_AfterLOCCreationCallout.taskLOC > testinput = new List < ARTL_AfterLOCCreationCallout.taskLOC >();
        NewObject.taskLOCId = tlist[0].Id;
        NewObject.orderRecId = order.Id;
        testinput.add(NewObject);
        Test.startTest();
        ARTL_AfterLOCCreationCallout.jsonPrepareForLOC(testinput);
        Test.stopTest();
    }

}