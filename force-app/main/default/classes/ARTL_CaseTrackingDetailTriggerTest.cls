@isTest
public with sharing class ARTL_CaseTrackingDetailTriggerTest {
    public ARTL_CaseTrackingDetailTriggerTest() {
        
    }
    @TestSetup
    public static void testData(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account testAcc = new Account(name = 'Test Accountabc', RecordTypeId = recordTypeId);
        insert testAcc;
        Contact contactRec = new Contact(FirstName = 'Test', 
                                         LastName = 'Test',
                                         ARTL_Designation__c = 'Test', 
                                         ARTL_Contact_Role__c = 'CEO', 
                                         Phone = '9876543210', 
                                         Email = 'test@test.com',
                                         AccountId = testAcc.Id);
        insert contactRec;
        
        Case caseRec = new Case (Status = 'In-Progress', 
                                 Origin = 'Web');
        insert caseRec;
        
        Case_Tracking_Detail__c caseTrackingRec = new Case_Tracking_Detail__c(Name = 'test', 
                                                                              Case__c = caseRec.Id, 
                                                                              SF_Record_ID__c = contactRec.Id, 
                                                                              Step1__c = 'Success', 
                                                                              Step_1_Description__c = 'created'); 
        insert caseTrackingRec;
        
    }
    
    @isTest
    public static void testCaseTrackingCreation(){
        Case_Tracking_Detail__c ctdRecord = [Select Id, Name, Step_2_Status__c, Step_3_Status__c from Case_Tracking_Detail__c];
        ctdRecord.Step_2_Status__c = 'Success';
        ctdRecord.Step_3_Status__c = 'Success';
        update ctdRecord;
        
    }

    @isTest
    public static void testInvokeIntegrationProcedure1(){
        Case_Tracking_Detail__c ctdRecord = [Select Id, Name, Step_2_Status__c, Step_3_Status__c, Case__c, SF_Record_ID__c from Case_Tracking_Detail__c];
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('recordId', ctdRecord.SF_Record_ID__c);
        inputMap.put('caseId', ctdRecord.Case__c);
        Test.startTest();
        CaseTrackingDetailStep4Handler.invokeIntegrationProcedure(JSON.serialize(inputMap), 'ARTL_Step4InvokeSolace', ctdRecord.Id);
        ARTL_CaseTrackingDetailTriggerHandler.invokeIntegrationProcedure(JSON.serialize(inputMap), 'ARTL_BCPDCPSolaceQueue', ctdRecord.Id);

        Test.stopTest();
    }
    
    @isTest
    public static void testInvokeIntegrationProcedure2(){
        Case_Tracking_Detail__c ctdRecord = [Select Id, Name, Step1__c, Step_2_Status__c, Step_3_Status__c, Case__c, SF_Record_ID__c from Case_Tracking_Detail__c];
        ctdRecord.Step1__c = 'Error';
        update ctdRecord;
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('recordId', ctdRecord.SF_Record_ID__c);
        inputMap.put('caseId', ctdRecord.Case__c);
        Test.startTest();
        CaseTrackingDetailStep4Handler.invokeIntegrationProcedure(JSON.serialize(inputMap), 'ARTL_Step4InvokeSolace', ctdRecord.Id);
        ARTL_CaseTrackingDetailTriggerHandler.invokeIntegrationProcedure(JSON.serialize(inputMap), 'ARTL_BCPDCPSolaceQueue', ctdRecord.Id);

        Test.stopTest();
    }


    
    
}