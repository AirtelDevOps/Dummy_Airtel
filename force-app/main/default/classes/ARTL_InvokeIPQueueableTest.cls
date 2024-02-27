@isTest
public class ARTL_InvokeIPQueueableTest {
    @testSetup
    public static void setupMethod(){
        Id BARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
        Account acc = new Account(Name = 'TestAccount',
                                              RecordTypeId = BARecordTypeId,
                                              BillingCity = 'Panchkula',
                                              BillingCountry = 'Haryana',
                                              BillingPostalCode = '134109',
                                              BillingState = 'India',
                                              BillingStreet = 'Panchkula', 
                                              ARTL_IntegrationId__c = 'test', 
                                              ARTL_Category__c = 'A', 
                                              ARTL_Customer_Segment__c = 'AB',
                                              ARTL_Service_Segment__c = 'BD',
                                              ARTL_Vertical_Segment__c = 'BFI',
                                              ARTL_Business_Circle_Region__c = 'AP',
                                              ARTL_PAN__c = 'ABCDE1234F');
        insert acc; 
    }
    @isTest
    public static void testQueueableExecution() {
        Account acc = [Select Id from Account];
        
        String recordId = acc.Id;
        String ipName = 'ARTL_NBASolaceQueue';
        
        
        Test.startTest();
        ARTL_InvokeIPQueueable queueable = new ARTL_InvokeIPQueueable(recordId, ipName);
        System.enqueueJob(queueable);
        Test.stopTest();
    }
    
    @isTest
    public static void testQueueableExecution2() {
        Account acc = [Select Id from Account];
        
        String recordId = acc.Id;
        String ipName = 'ARTL_NBASolaceQueue';
        Map<String,Object> ipInput = new Map<String,Object>();
        
        Test.startTest();
        ARTL_InvokeIPQueueable queueable = new ARTL_InvokeIPQueueable(recordId, ipName,ipInput);
        System.enqueueJob(queueable);
        Test.stopTest();
    }
}