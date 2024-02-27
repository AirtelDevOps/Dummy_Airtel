@isTest
public class ARTL_ShowPendingtasks_Test {
    
    @testSetup static void testData() {
        Account a=new Account(name='Testdata',phone='8885856208',billingstate='California',billingcity='anah',billingcountry='United States',billingpostalcode='92801',billingstreet='ls');
        insert a;
        Lead l=new Lead(Salutation='Mr',Company='kavokerr',FirstName='Test',LastName='Lead',LeadSource='Marketing',status='open',phone='8978645100',country='United States',street='James street',city='texas',state='devar',postalcode='98568');      
        insert l;
        Task t=new Task(subject='test_test',description='Account info on Task',Whatid=a.Id,status='open',priority='normal', ARTL_TaskType__c='Meeting Reminder');
        insert t;
    }
    
    static testMethod void testShowPendingTasks(){
        
        Test.startTest();
        ARTL_ShowPendingtasks.getOpenTasks();
        Test.stopTest();
        
        List<Task> lstTasks = ARTL_ShowPendingtasks.getOpenTasks();  
        System.assertEquals(lstTasks.size()>0, true);
    }
}