@isTest
public class ARTL_VANTriggerTest {
 @isTest
    static void testAfterUpdateTrigger1() {
         Id BusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

        // Create test data 1
        Account testAccount1 = new Account(Name = 'Test Account', recordTypeId=BusinessRecordTypeId);
		testAccount1.vlocity_cmt__Status__c = 'Unapproved';
        testAccount1.vlocity_cmt__CustomerClass__c = 'EGB';
        testAccount1.ARTL_PAN__c = 'AAAAA1234A';
        insert testAccount1;
       
        Test.startTest();
		testAccount1.vlocity_cmt__Status__c = 'Active';
        update testAccount1;
        Test.stopTest();
        
    }
     @isTest
    static void testAfterUpdateTrigger2() {
         Id BusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

        // Create test data 1
        Account testAccount1 = new Account(Name = 'Test Account', recordTypeId=BusinessRecordTypeId);
		testAccount1.vlocity_cmt__Status__c = 'Active';
        testAccount1.vlocity_cmt__CustomerClass__c = 'EGB';
        testAccount1.ARTL_PAN__c = 'AAAAA1234A';
        insert testAccount1;
       
        Test.startTest();
		testAccount1.ARTL_PAN__c = 'ABAAA1234A';
        update testAccount1;
        Test.stopTest();
        
    }
}