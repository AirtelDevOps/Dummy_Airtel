@isTest
public class ARTL_SAMJourneyAutomatedTaskBatchTest {
    @testSetup
    static void dataSetup(){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account acc = new Account(Name = 'test account', 
                                  ARTL_SAM_Account_Visit_Frequency__c = 3,
                                  RecordTypeId = recordTypeId,
                                  BillingCity = 'New Delhi', BillingStreet='test address', BillingPostalCode='110012',BillingState='Delhi',BillingCountry='India', ARTL_Category__c ='A', ARTL_Customer_Segment__c ='AB',ARTL_Service_Segment__c ='Key',ARTL_Vertical_Segment__c='BFI', ARTL_Business_Circle_Region__c ='AP');
        insert acc;

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User(Alias = 'test', Email='samtest@airtel.com', 
                             EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='samtest@airtel.com');
        insert user;
        AccountTeamMember atm = new AccountTeamMember(AccountId = acc.Id, 
                                                     UserId = user.Id, 
                                                     TeamMemberRole = 'SAM');
        insert atm;
    }
    
    
    @isTest
    static void testAutomatedTaskBatch(){
        String cron = '0 0 23 * * ?';
        ARTL_SAMAutomatedTaskScheduler scheduledClass = new ARTL_SAMAutomatedTaskScheduler();
        Test.startTest();
        String jobId = System.schedule('New', cron, scheduledClass);
        Test.stopTest();
    }
}