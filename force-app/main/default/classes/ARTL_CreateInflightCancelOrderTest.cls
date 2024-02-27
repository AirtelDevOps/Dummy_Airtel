@isTest
public class ARTL_CreateInflightCancelOrderTest {
	static testMethod void testTaskHandlerHelper(){
        
        Id recordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account acc = new Account(Name = 'Test Account',ARTL_Business_Circle_Region__c='NCR',BillingCity = 'Panchkula',
                                  BillingCountry = 'Haryana',BillingPostalCode = '134109',BillingState = 'India',BillingStreet = 'Panchkula',
                                  ARTL_Category__c = 'A',RecordTypeId = recordTypeId1, ARTL_Customer_Segment__c ='AB', ARTL_Vertical_Segment__c ='BFI',
                                  ARTL_Service_Segment__c ='Bharti');
        insert acc;
        
        List<Product2> products = new List<Product2>();        
        Id pbId = Test.getStandardPricebookId();
        products = new Product2[2];
        products[0]=new Product2(name='NIPS_HARDWARE', ProductCode='dac49a09-9b41-4999-b7c4-cf6319ad5b44',vlocity_cmt__JSONAttribute__c = '');
        products[1]=new Product2(name='NIPS_SERVICE ', ProductCode='c09a2e70-64af-4ad6-8427-06c8489234d7', vlocity_cmt__JSONAttribute__c = '');
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
        
        /*map<Id,task> taskMapNew = new map<Id, task>();
        taskMapNew.put(t.Id, t);
        
        map<Id,task> taskMapOld = new  map<Id,task>([SELECT Id, ARTL_Rejection_Category__c from task]);
        
        List<Task> tempTasks = [SELECT Id, ARTL_Rejection_Category__c from task];
        tempTasks[0].ARTL_Rejection_Category__c = 'InValid';
        update tempTasks;
        
        taskMapOld.put(tempTasks[0].Id, tempTasks[0]);*/
        List<ARTL_CreateInflightCancelOrder.IntegrationProcedureInput> lstflowinput = new List<ARTL_CreateInflightCancelOrder.IntegrationProcedureInput>();
        ARTL_CreateInflightCancelOrder.IntegrationProcedureInput flowinput = new ARTL_CreateInflightCancelOrder.IntegrationProcedureInput();
        flowinput.Input = order.Id;
        flowinput.procedureAPIName='b2bExpress_CancelSubOrder';
        lstflowinput.add(flowinput);
        Test.startTest();
        ARTL_CreateInflightCancelOrder.runIntegrationServiceInvocable(lstflowinput);
        Test.stopTest();
    }
}