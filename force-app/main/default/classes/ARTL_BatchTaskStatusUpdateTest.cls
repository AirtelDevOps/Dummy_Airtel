@isTest
private class ARTL_BatchTaskStatusUpdateTest {
    
    static testMethod void testBatchTaskUpdate(){
        
        Id recordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
         Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = recordTypeId1;
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
        
        List<Product2> products = new List<Product2>();
        
        Id pbId = Test.getStandardPricebookId();
        products = new Product2[2];
        products[0]=new Product2(name='VEPC_PRIMARY_LINK', ProductCode='VEPC_PRIMARY_LINK ',vlocity_cmt__JSONAttribute__c = '');
        products[1]=new Product2(name='VEPC_PRIMARY_MPLS_LINK ', ProductCode='VEPC_PRIMARY_MPLS_LINK ', vlocity_cmt__JSONAttribute__c = '');
        insert products;
        
        PricebookEntry[] pbes = new PricebookEntry[products.size()];
        
        for (Integer i=0; i<products.size(); i++)
        {
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
        t.ARTL_LOC_Bill_Start_Date__c = system.today().addDays(-2);
        t.Number_of_days_for_Deemed_LOC__c = 2;
        t.ARTL_locAcceptanceCriteria__c = 'Deemed';
        t.Subject='LOC Customer';
        t.Status='Not Started';
        t.Priority='Normal';
        tlist.add(t);
        insert tlist;
        
        Test.startTest();
        ARTL_BatchTaskStatusUpdate obj = new ARTL_BatchTaskStatusUpdate();
        Id jobid= Database.executeBatch(obj);
        Test.stopTest();
    }
}