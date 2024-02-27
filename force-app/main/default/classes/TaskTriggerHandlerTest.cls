@isTest
private class TaskTriggerHandlerTest {
    
    static testMethod void testTaskHandlerHelper(){
        
        Id recordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account acc = new Account(Name = 'Test Account',ARTL_Business_Circle_Region__c='NCR',BillingCity = 'Panchkula',
                                  BillingCountry = 'Haryana',BillingPostalCode = '134109',BillingState = 'India',BillingStreet = 'Panchkula',
                                  ARTL_Category__c = 'A',RecordTypeId = recordTypeId1, ARTL_Customer_Segment__c ='AB', 
                                  ARTL_Vertical_Segment__c ='BFI',ARTL_Service_Segment__c ='Bharti');
        insert acc;
        
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
        
        //Attaching CSV With Quote Record
        List<ContentVersion> ListOfDocuments = new List<ContentVersion>();
        String csvFile = 'ksjdhfks skjdnfkjsd';
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Welcome Letter';
        cv.PathOnClient = 'Welcome Letter.csv';
        cv.IsMajorVersion = true;
        cv.VersionData = Blob.valueOf(csvFile);
        ListOfDocuments.add(cv);
        Insert ListOfDocuments;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        List<ContentDocumentLink> ListofContentDocumentLink = new List<ContentDocumentLink>();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = tlist[0].Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        ListofContentDocumentLink.add(cdl);
        Insert ListofContentDocumentLink;
        
        ARTL_LOC_Task_Approval__c objTA = new ARTL_LOC_Task_Approval__c(TaskId__c=tlist[0].Id,Comments__c='Test Task Approval');
        insert objTA;
        
        map<Id,task> taskMapNew = new map<Id, task>();
        taskMapNew.put(t.Id, t);
        
        map<Id,task> taskMapOld = new  map<Id,task>([SELECT Id, ARTL_Rejection_Category__c from task]);
        
        List<Task> tempTasks = [SELECT Id, ARTL_Rejection_Category__c from task];
        tempTasks[0].ARTL_Rejection_Category__c = 'InValid';
        tempTasks[0].ARTL_LOC_Task_Approval__c = objTA.Id;
        update tempTasks;
        
        taskMapOld.put(tempTasks[0].Id, tempTasks[0]);
        
        Test.startTest();
        TaskTriggerHandler obj = new TaskTriggerHandler(tlist, taskMapNew, taskMapOld);
        Test.stopTest();
    }
    
    static testMethod void testTaskHandlerHelper2(){
        
        Id recordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account acc = new Account(Name = 'Test Account',ARTL_Business_Circle_Region__c='NCR',
                                  RecordTypeId = recordTypeId1,BillingCity = 'Panchkula',
                                  BillingCountry = 'Haryana',BillingPostalCode = '134109',BillingState = 'India',BillingStreet = 'Panchkula',
                                  ARTL_Category__c = 'A', ARTL_Customer_Segment__c ='AB', ARTL_Vertical_Segment__c ='BFI',
                                  ARTL_Service_Segment__c ='Bharti');
        insert acc;
        
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
        
        //Attaching CSV With Quote Record
        List<ContentVersion> ListOfDocuments = new List<ContentVersion>();
        String csvFile = 'ksjdhfks skjdnfkjsd';
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Welcome Letter';
        cv.PathOnClient = 'Welcome Letter.csv';
        cv.IsMajorVersion = true;
        cv.VersionData = Blob.valueOf(csvFile);
        ListOfDocuments.add(cv);
        Insert ListOfDocuments;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        List<ContentDocumentLink> ListofContentDocumentLink = new List<ContentDocumentLink>();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = tlist[0].Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        ListofContentDocumentLink.add(cdl);
        Insert ListofContentDocumentLink;
        
        
        
        Test.startTest();
        t.Status = 'Rejected by PM';
        update t;
        Test.stopTest();
    }
}