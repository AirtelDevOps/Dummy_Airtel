@isTest
public class ARTL_AccountTriggerTest {
  @isTest
    static void testAfterInsertTrigger() {
         Id BARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
		
        // Create test data
        Account testAccount = new Account(Name = 'Test Account', recordTypeId=BARecordTypeId);
		testAccount.BillingCity = 'Delhi';
        testAccount.BillingCountry = 'India';
        testAccount.BillingState = 'Delhi';
        testAccount.BillingStreet = 'Test Street';
        testAccount.BillingPostalCode = '110011';
        testAccount.ARTL_Customer_Segment__c = 'AB';
        testAccount.ARTL_Business_Circle_Region__c = 'AP';
        testAccount.ARTL_Service_Segment__c = 'BD';
        testAccount.ARTL_Vertical_Segment__c ='BFI';
        testAccount.ARTL_Category__c = 'A';
        // Perform the insert operation
        Test.startTest();
        insert testAccount;
        Test.stopTest();

        // Verify the results
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];

        // Assert that the trigger logic has been applied after insert
        System.assertEquals(1, insertedAccounts.size(), 'Only one account should be inserted');
        Account insertedAccount = insertedAccounts[0];
        System.assertNotEquals(null, insertedAccount.Id, 'Account Id should not be null');
    }
    
    @isTest
    static void testAfterInsertTrigger1() {
         Id BusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

        // Create test data
        Account testAccount = new Account(Name = 'Test Account', recordTypeId=BusinessRecordTypeId);
		testAccount.vlocity_cmt__Status__c = 'Unapproved';
        testAccount.vlocity_cmt__CustomerClass__c = 'EGB';
        testAccount.ARTL_PAN__c = 'AAAAA1234A';
        testAccount.BillingCity = 'Delhi';
        testAccount.BillingCountry = 'India';
        testAccount.BillingState = 'Delhi';
        testAccount.BillingStreet = 'Test Street';
        testAccount.BillingPostalCode = '110011';
        testAccount.ARTL_Customer_Segment__c = 'AB';
        testAccount.ARTL_Business_Circle_Region__c = 'AP';
        testAccount.ARTL_Service_Segment__c = 'BD';
        testAccount.ARTL_Vertical_Segment__c ='BFI';
        testAccount.ARTL_Category__c = 'A';
        insert testAccount;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User(Alias = 'test', Email='samtest@airtel.com', 
                             EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='samtest@airtel.com');
        insert user;
        AccountTeamMember atm = new AccountTeamMember(AccountId = testAccount.Id, 
        UserId = user.Id, 
        TeamMemberRole = 'Secondary KAM');
        insert atm;
        // Perform the insert operation
        Test.startTest();
        ARTL_AccountTriggerHandler.GetAccountTeamJSON(testAccount.Id);
        testAccount.vlocity_cmt__Status__c = 'Unapproved';
        update testAccount;
        Test.stopTest();

        // Verify the results
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];

        // Assert that the trigger logic has been applied after insert
        System.assertEquals(1, insertedAccounts.size(), 'Only one account should be inserted');
        Account insertedAccount = insertedAccounts[0];
        System.assertNotEquals(null, insertedAccount.Id, 'Account Id should not be null');
    }
    
    @isTest
    static void testAfterInsertTrigger2() {
         Id BusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

        // Create test data
        Account testAccount = new Account(Name = 'Test', recordTypeId=BusinessRecordTypeId);
		testAccount.ARTL_PAN__c = 'AAAAA1234A';
        testAccount.BillingCity = 'Delhi';
        testAccount.BillingCountry = 'India';
        testAccount.BillingState = 'Delhi';
        testAccount.BillingStreet = 'Test Street';
        testAccount.BillingPostalCode = '110011';
        testAccount.ARTL_Customer_Segment__c = 'AB';
        testAccount.ARTL_Business_Circle_Region__c = 'AP';
        testAccount.ARTL_Service_Segment__c = 'BD';
        testAccount.ARTL_Vertical_Segment__c ='BFI';
        testAccount.ARTL_Category__c = 'A';
        insert testAccount;
        // Perform the insert operation
        Id BARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
        // Create test data
        Account baTestAccount = new Account(Name = 'Billing', recordTypeId=BARecordTypeId);
		baTestAccount.ARTL_PAN__c = 'BBBBB1234A';
        baTestAccount.BillingCity = 'Delhi';
        baTestAccount.BillingCountry = 'India';
        baTestAccount.BillingState = 'Delhi';
        baTestAccount.BillingStreet = 'Test Street';
        baTestAccount.BillingPostalCode = '110011';
        baTestAccount.ARTL_Customer_Segment__c = 'AB';
        baTestAccount.ARTL_Business_Circle_Region__c = 'AP';
        baTestAccount.ARTL_Service_Segment__c = 'BD';
        baTestAccount.ARTL_Vertical_Segment__c ='BFI';
        baTestAccount.ARTL_Category__c = 'A';
        insert baTestAccount;
        
        // Perform the insert operation
        Test.startTest();
        testAccount.Step_1_Status__c = 'Error';
        baTestAccount.Step_1_Status__c = 'Error';
        update testAccount;
        update baTestAccount;
        Test.stopTest();

        // Verify the results
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Test'];

        // Assert that the trigger logic has been applied after insert
        System.assertEquals(1, insertedAccounts.size(), 'Only one account should be inserted');
        Account insertedAccount = insertedAccounts[0];
        System.assertNotEquals(null, insertedAccount.Id, 'Account Id should not be null');
    }
    
    @isTest
    static void testAfterInsertTrigger3() {
         Id BusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

        // Create test data
        Account testAccount = new Account(Name = 'Test', recordTypeId=BusinessRecordTypeId);
		testAccount.ARTL_PAN__c = 'AAAAA1234A';
        testAccount.BillingCity = 'Delhi';
        testAccount.BillingCountry = 'India';
        testAccount.BillingState = 'Delhi';
        testAccount.BillingStreet = 'Test Street';
        testAccount.BillingPostalCode = '110011';
        testAccount.ARTL_Customer_Segment__c = 'AB';
        testAccount.ARTL_Business_Circle_Region__c = 'AP';
        testAccount.ARTL_Service_Segment__c = 'BD';
        testAccount.ARTL_Vertical_Segment__c ='BFI';
        testAccount.ARTL_Category__c = 'A';
        insert testAccount;
        // Perform the insert operation
        Id BARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
        // Create test data
        Account baTestAccount = new Account(Name = 'Billing', recordTypeId=BARecordTypeId);
		baTestAccount.ARTL_PAN__c = 'BBBBB1234A';
        baTestAccount.BillingCity = 'Delhi';
        baTestAccount.BillingCountry = 'India';
        baTestAccount.BillingState = 'Delhi';
        baTestAccount.BillingStreet = 'Test Street';
        baTestAccount.BillingPostalCode = '110011';
        baTestAccount.ARTL_Customer_Segment__c = 'AB';
        baTestAccount.ARTL_Business_Circle_Region__c = 'AP';
        baTestAccount.ARTL_Service_Segment__c = 'BD';
        baTestAccount.ARTL_Vertical_Segment__c ='BFI';
        baTestAccount.ARTL_Category__c = 'A';
        insert baTestAccount;
        
        // Perform the insert operation
        Test.startTest();
        testAccount.Step_2_Status__c = 'Error';
        baTestAccount.Step_2_Status__c = 'Error';
        update testAccount;
        update baTestAccount;
        Test.stopTest();

        // Verify the results
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Test'];

        // Assert that the trigger logic has been applied after insert
        System.assertEquals(1, insertedAccounts.size(), 'Only one account should be inserted');
        Account insertedAccount = insertedAccounts[0];
        System.assertNotEquals(null, insertedAccount.Id, 'Account Id should not be null');
    }
    @isTest
    static void testAfterInsertTrigger4() {
         Id BusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

        // Create test data
        Account testAccount = new Account(Name = 'Test', recordTypeId=BusinessRecordTypeId);
		testAccount.ARTL_PAN__c = 'AAAAA1234A';
        testAccount.BillingCity = 'Delhi';
        testAccount.BillingCountry = 'India';
        testAccount.BillingState = 'Delhi';
        testAccount.BillingStreet = 'Test Street';
        testAccount.BillingPostalCode = '110011';
        testAccount.ARTL_Customer_Segment__c = 'AB';
        testAccount.ARTL_Business_Circle_Region__c = 'AP';
        testAccount.ARTL_Service_Segment__c = 'BD';
        testAccount.ARTL_Vertical_Segment__c ='BFI';
        testAccount.ARTL_Category__c = 'A';
        insert testAccount;
        Id BARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
        // Create test data
        Account baTestAccount = new Account(Name = 'Billing', recordTypeId=BARecordTypeId);
		baTestAccount.ARTL_PAN__c = 'BBBBB1234A';
        baTestAccount.BillingCity = 'Delhi';
        baTestAccount.BillingCountry = 'India';
        baTestAccount.BillingState = 'Delhi';
        baTestAccount.BillingStreet = 'Test Street';
        baTestAccount.BillingPostalCode = '110011';
        baTestAccount.ARTL_Customer_Segment__c = 'AB';
        baTestAccount.ARTL_Business_Circle_Region__c = 'AP';
        baTestAccount.ARTL_Service_Segment__c = 'BD';
        baTestAccount.ARTL_Vertical_Segment__c ='BFI';
        baTestAccount.ARTL_Category__c = 'A';
        insert baTestAccount;
        
        // Perform the insert operation
        Test.startTest();
        testAccount.Step_3_Status__c = 'Error';
        baTestAccount.Step_3_Status__c = 'Error';
        update testAccount;
        update baTestAccount;
        Test.stopTest();

        // Verify the results
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Test'];

        // Assert that the trigger logic has been applied after insert
        System.assertEquals(1, insertedAccounts.size(), 'Only one account should be inserted');
        Account insertedAccount = insertedAccounts[0];
        System.assertNotEquals(null, insertedAccount.Id, 'Account Id should not be null');
    }
    @isTest
    static void testAfterInsertTrigger5() {
         Id BusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

        // Create test data
        Account testAccount = new Account(Name = 'Test', recordTypeId=BusinessRecordTypeId);
		testAccount.ARTL_PAN__c = 'AAAAA1234A';
        testAccount.BillingCity = 'Delhi';
        testAccount.BillingCountry = 'India';
        testAccount.BillingState = 'Delhi';
        testAccount.BillingStreet = 'Test Street';
        testAccount.BillingPostalCode = '110011';
        testAccount.ARTL_Customer_Segment__c = 'AB';
        testAccount.ARTL_Business_Circle_Region__c = 'AP';
        testAccount.ARTL_Service_Segment__c = 'BD';
        testAccount.ARTL_Vertical_Segment__c ='BFI';
        testAccount.ARTL_Category__c = 'A';
        insert testAccount;
        
        Id BARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
        // Create test data
        Account baTestAccount = new Account(Name = 'Billing', recordTypeId=BARecordTypeId);
		baTestAccount.ARTL_PAN__c = 'BBBBB1234A';
        baTestAccount.BillingCity = 'Delhi';
        baTestAccount.BillingCountry = 'India';
        baTestAccount.BillingState = 'Delhi';
        baTestAccount.BillingStreet = 'Test Street';
        baTestAccount.BillingPostalCode = '110011';
        baTestAccount.ARTL_Customer_Segment__c = 'AB';
        baTestAccount.ARTL_Business_Circle_Region__c = 'AP';
        baTestAccount.ARTL_Service_Segment__c = 'BD';
        baTestAccount.ARTL_Vertical_Segment__c ='BFI';
        baTestAccount.ARTL_Category__c = 'A';
        insert baTestAccount;
        
        // Perform the insert operation
        Test.startTest();
        testAccount.Step_4_Status__c = 'Error';
        baTestAccount.Step_4_Status__c = 'Error';
        update testAccount;
        update baTestAccount;
        Test.stopTest();

        // Verify the results
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Test'];

        // Assert that the trigger logic has been applied after insert
        System.assertEquals(1, insertedAccounts.size(), 'Only one account should be inserted');
        Account insertedAccount = insertedAccounts[0];
        System.assertNotEquals(null, insertedAccount.Id, 'Account Id should not be null');
    }
    @isTest
    static void testAfterInsertTrigger6() {
        Id BusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

        // Create test data
        Account testAccount = new Account(Name = 'Test', recordTypeId=BusinessRecordTypeId);
		testAccount.ARTL_PAN__c = 'AAAAA1234A';
        testAccount.Step_1_Status__c = 'Success';
        testAccount.Step_2_Status__c = 'Success';
        testAccount.Step_3_Status__c = 'Success';
        testAccount.BillingCity = 'Delhi';
        testAccount.BillingCountry = 'India';
        testAccount.BillingState = 'Delhi';
        testAccount.BillingStreet = 'Test Street';
        testAccount.BillingPostalCode = '110011';
        testAccount.ARTL_Customer_Segment__c = 'AB';
        testAccount.ARTL_Business_Circle_Region__c = 'AP';
        testAccount.ARTL_Service_Segment__c = 'BD';
        testAccount.ARTL_Vertical_Segment__c ='BFI';
        testAccount.ARTL_Category__c = 'A';
        insert testAccount;
        
        Id BARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
        // Create test data
        Account baTestAccount = new Account(Name = 'Billing', recordTypeId=BARecordTypeId);
		baTestAccount.ARTL_PAN__c = 'BBBBB1234A';
        baTestAccount.Step_1_Status__c = 'Success';
        baTestAccount.Step_2_Status__c = 'Success';
        baTestAccount.Step_3_Status__c = 'Success';
        baTestAccount.BillingCity = 'Delhi';
        baTestAccount.BillingCountry = 'India';
        baTestAccount.BillingState = 'Delhi';
        baTestAccount.BillingStreet = 'Test Street';
        baTestAccount.BillingPostalCode = '110011';
        baTestAccount.ARTL_Customer_Segment__c = 'AB';
        baTestAccount.ARTL_Business_Circle_Region__c = 'AP';
        baTestAccount.ARTL_Service_Segment__c = 'BD';
        baTestAccount.ARTL_Vertical_Segment__c ='BFI';
        baTestAccount.ARTL_Category__c = 'A';
        insert baTestAccount;
        // Perform the insert operation
        Test.startTest();
        testAccount.Step_4_Status__c = 'Success';
        baTestAccount.Step_4_Status__c = 'Success';
        update testAccount;
        update baTestAccount;
        Test.stopTest();

        // Verify the results
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Test'];

        // Assert that the trigger logic has been applied after insert
        System.assertEquals(1, insertedAccounts.size(), 'Only one account should be inserted');
        Account insertedAccount = insertedAccounts[0];
        System.assertNotEquals(null, insertedAccount.Id, 'Account Id should not be null');
    }
    @isTest
    static void testAfterInsertTrigger7() {
        Id BusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

        // Create test data
        Account testAccount = new Account(Name = 'Test', recordTypeId=BusinessRecordTypeId);
		testAccount.ARTL_PAN__c = 'AAAAA1234A';
        testAccount.Step_1_Status__c = 'Success';
        testAccount.Step_2_Status__c = 'Success';
        testAccount.Step_3_Status__c = 'Success';
        testAccount.BillingCity = 'Delhi';
        testAccount.BillingCountry = 'India';
        testAccount.BillingState = 'Delhi';
        testAccount.BillingStreet = 'Test Street';
        testAccount.BillingPostalCode = '110011';
        testAccount.ARTL_Customer_Segment__c = 'AB';
        testAccount.ARTL_Business_Circle_Region__c = 'AP';
        testAccount.ARTL_Service_Segment__c = 'BD';
        testAccount.ARTL_Vertical_Segment__c ='BFI';
        testAccount.ARTL_Category__c = 'A';
        insert testAccount;
        
        Id BARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
        // Create test data
        Account baTestAccount = new Account(Name = 'FRESH', recordTypeId=BARecordTypeId);
		    baTestAccount.ARTL_PAN__c = 'BBBBB1234A';
        baTestAccount.Step_1_Status__c = 'Success';
        baTestAccount.Step_2_Status__c = 'Success';
        baTestAccount.Step_3_Status__c = 'Success';
        baTestAccount.BillingCity = 'Delhi';
        baTestAccount.BillingCountry = 'India';
        baTestAccount.BillingState = 'Delhi';
        baTestAccount.BillingStreet = 'Test Street';
        baTestAccount.BillingPostalCode = '110011';
        baTestAccount.ARTL_Customer_Segment__c = 'AB';
        baTestAccount.ARTL_Business_Circle_Region__c = 'AP';
        baTestAccount.ARTL_Service_Segment__c = 'BD';
        baTestAccount.ARTL_Vertical_Segment__c ='BFI';
        baTestAccount.ARTL_Category__c = 'A';
        insert baTestAccount;
        Account baTestAccount2 = new Account(Name = 'FRESH ONES', recordTypeId=BARecordTypeId);
		    baTestAccount2.ARTL_PAN__c = 'BBBBB1234A';
        baTestAccount2.Step_1_Status__c = 'Success';
        baTestAccount2.Step_2_Status__c = 'Success';
        baTestAccount2.Step_3_Status__c = 'Success';
        baTestAccount2.BillingCity = 'Delhi';
        baTestAccount2.BillingCountry = 'India';
        baTestAccount2.BillingState = 'Delhi';
        baTestAccount2.BillingStreet = 'Test Street';
        baTestAccount2.BillingPostalCode = '110011';
        baTestAccount2.ARTL_Customer_Segment__c = 'AB';
        baTestAccount2.ARTL_Business_Circle_Region__c = 'AP';
        baTestAccount2.ARTL_Service_Segment__c = 'BD';
        baTestAccount2.ARTL_Vertical_Segment__c ='BFI';
        baTestAccount2.ARTL_Category__c = 'A';
        insert baTestAccount2;
        // Perform the insert operation
        Test.startTest();
        testAccount.Step_4_Status__c = 'Success';
        baTestAccount.Step_4_Status__c = 'Success';
        update testAccount;
        update baTestAccount;
        Test.stopTest();

        // Verify the results
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Test'];

        // Assert that the trigger logic has been applied after insert
        System.assertEquals(1, insertedAccounts.size(), 'Only one account should be inserted');
        Account insertedAccount = insertedAccounts[0];
        System.assertNotEquals(null, insertedAccount.Id, 'Account Id should not be null');
    }
    @isTest
    static void testAfterInsertTrigger8() {
         Id BusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

        // Create test data
        Account testAccount = new Account(Name = 'Test Account', recordTypeId=BusinessRecordTypeId);
		testAccount.vlocity_cmt__Status__c = 'Unapproved';
        testAccount.vlocity_cmt__CustomerClass__c = 'EGB';
        testAccount.ARTL_PAN__c = 'AAAAA1234A';
        testAccount.BillingCity = 'Delhi';
        testAccount.BillingCountry = 'India';
        testAccount.BillingState = 'Delhi';
        testAccount.BillingStreet = 'Test Street';
        testAccount.BillingPostalCode = '110011';
        testAccount.ARTL_Customer_Segment__c = 'AB';
        testAccount.ARTL_Business_Circle_Region__c = 'AP';
        testAccount.ARTL_Service_Segment__c = 'BD';
        testAccount.ARTL_Vertical_Segment__c ='BFI';
        testAccount.ARTL_Category__c = 'A';
        insert testAccount;
        // Perform the insert operation
        Test.startTest();
        ARTL_AccountTriggerHandler.GetAccountTeamJSON(testAccount.Id);
        testAccount.vlocity_cmt__Status__c = 'Unapproved';
        update testAccount;
        Test.stopTest();

        // Verify the results
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];

        // Assert that the trigger logic has been applied after insert
        System.assertEquals(1, insertedAccounts.size(), 'Only one account should be inserted');
        Account insertedAccount = insertedAccounts[0];
        System.assertNotEquals(null, insertedAccount.Id, 'Account Id should not be null');
    }
    @isTest
    static void testAfterInsertTrigger9() {
         Id BusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

        // Create test data
        Account testAccount = new Account(Name = 'Test Account', recordTypeId=BusinessRecordTypeId);
		testAccount.vlocity_cmt__Status__c = 'Unapproved';
        testAccount.vlocity_cmt__CustomerClass__c = 'EGB';
        testAccount.ARTL_PAN__c = 'AAAAA1234A';
        testAccount.BillingCity = 'Delhi';
        testAccount.BillingCountry = 'India';
        testAccount.BillingState = 'Delhi';
        testAccount.BillingStreet = 'Test Street';
        testAccount.BillingPostalCode = '110011';
        testAccount.ARTL_Customer_Segment__c = 'AB';
        testAccount.ARTL_Business_Circle_Region__c = 'AP';
        testAccount.ARTL_Service_Segment__c = 'BD';
        testAccount.ARTL_Vertical_Segment__c ='BFI';
        testAccount.ARTL_Category__c = 'A';
        insert testAccount;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User(Alias = 'test', Email='samtest@airtel.com', 
                             EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='samtest@airtel.com');
        insert user;
        User user2 = new User(Alias = 'test2', Email='samtest2@airtel.com', 
                             EmailEncodingKey='UTF-8', LastName='Test2', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='samtest2@airtel.com');
        insert user2;
        AccountTeamMember atm = new AccountTeamMember(AccountId = testAccount.Id, 
        UserId = user.Id, 
        TeamMemberRole = 'Secondary KAM');
        insert atm;
        AccountTeamMember atm2 = new AccountTeamMember(AccountId = testAccount.Id, 
        UserId = user2.Id, 
        TeamMemberRole = 'Secondary KAM');
        insert atm2;
        // Perform the insert operation
        Test.startTest();
        ARTL_AccountTriggerHandler.GetAccountTeamJSON(testAccount.Id);
        testAccount.vlocity_cmt__Status__c = 'Unapproved';
        update testAccount;
        Test.stopTest();

        // Verify the results
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];

        // Assert that the trigger logic has been applied after insert
        System.assertEquals(1, insertedAccounts.size(), 'Only one account should be inserted');
        Account insertedAccount = insertedAccounts[0];
        System.assertNotEquals(null, insertedAccount.Id, 'Account Id should not be null');
    }
    @isTest
    static void testAfterInsertTrigger10() {
         Id BusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();

        // Create test data
        Account testAccount = new Account(Name = 'Test Account', recordTypeId=BusinessRecordTypeId);
		testAccount.vlocity_cmt__Status__c = 'Unapproved';
        testAccount.vlocity_cmt__CustomerClass__c = 'EGB';
        testAccount.ARTL_PAN__c = 'AAAAA1234A';
        testAccount.BillingCity = 'Delhi';
        testAccount.BillingCountry = 'India';
        testAccount.BillingState = 'Delhi';
        testAccount.BillingStreet = 'Test Street';
        testAccount.BillingPostalCode = '110011';
        testAccount.ARTL_Customer_Segment__c = 'AB';
        testAccount.ARTL_Business_Circle_Region__c = 'AP';
        testAccount.ARTL_Service_Segment__c = 'BD';
        testAccount.ARTL_Vertical_Segment__c ='BFI';
        testAccount.ARTL_Category__c = 'A';
        insert testAccount;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User(Alias = 'test', Email='samtest@airtel.com', 
                             EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, 
                             TimeZoneSidKey='America/Los_Angeles', UserName='samtest@airtel.com');
        insert user;
        AccountTeamMember atm = new AccountTeamMember(AccountId = testAccount.Id, 
        UserId = user.Id, 
        TeamMemberRole = 'Secondary KAM');
        insert atm;
        AccountTeamMember atm2 = new AccountTeamMember(AccountId = testAccount.Id, 
        UserId = user.Id, 
        TeamMemberRole = 'Secondary KAM');
        insert atm2;
        AccountTeamMember atm3 = new AccountTeamMember(AccountId = testAccount.Id, 
        UserId = user.Id, 
        TeamMemberRole = 'Secondary KAM');
        insert atm3;
        // Perform the insert operation
        Test.startTest();
        ARTL_AccountTriggerHandler.GetAccountTeamJSON(testAccount.Id);
        testAccount.vlocity_cmt__Status__c = 'Unapproved';
        update testAccount;
        Test.stopTest();

        // Verify the results
        List<Account> insertedAccounts = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];

        // Assert that the trigger logic has been applied after insert
        System.assertEquals(1, insertedAccounts.size(), 'Only one account should be inserted');
        Account insertedAccount = insertedAccounts[0];
        System.assertNotEquals(null, insertedAccount.Id, 'Account Id should not be null');
    }
}