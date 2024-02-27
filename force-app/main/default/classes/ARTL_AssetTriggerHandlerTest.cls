@IsTest
private class ARTL_AssetTriggerHandlerTest {
    
    @testSetup static void testData() {
        
        User testUser = new User(FirstName = 'Test', LastName = 'User', Email = 'test.user@email.com', Username='test7864er@user.com',Alias = 'tuser', TimeZoneSidKey='Asia/Kolkata',
                                 ProfileId = '00e5j0000048gp8AAA', LocaleSidKey = 'en_IN', LanguageLocaleKey  = 'en_US', EmailEncodingKey='UTF-8');
        insert testUser;
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account acc = new Account(Name='TestAccount', RecordTypeId = recordTypeIdAccount, ownerId=testUser.Id, ARTL_Business_Circle_Region__c='NCR',BillingCity = 'Panchkula',
                                  BillingCountry = 'Haryana',BillingPostalCode = '134109',BillingState = 'India',BillingStreet = 'Panchkula',
                                  ARTL_Category__c = 'A', ARTL_Customer_Segment__c ='AB', ARTL_Vertical_Segment__c ='BFI',
                                 ARTL_Service_Segment__c ='Bharti'); 
        insert acc;
        
        Account acc1 = new Account(Name='TestAccount1', RecordTypeId = recordTypeIdAccount, ownerId=testUser.Id, ARTL_Business_Circle_Region__c='NCR',BillingCity = 'Panchkula',
                                  BillingCountry = 'Haryana',BillingPostalCode = '134109',BillingState = 'India',BillingStreet = 'Panchkula',
                                  ARTL_Category__c = 'A',ARTL_Customer_Segment__c ='AB', ARTL_Vertical_Segment__c ='BFI',
                                 ARTL_Service_Segment__c ='Bharti'); 
        insert acc1;
        
    }
    
    static testMethod void testInsert() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1];
        Test.startTest();
        Asset ast = new Asset();
        ast.Name = 'MyNewAssetforTestClass';
        ast.AccountId = acc.Id;
        ast.vlocity_cmt__AssetReferenceId__c = '123';
        ast.vlocity_cmt__BillingAccountId__c  = acc.Id;
        ast.vlocity_cmt__ServiceAccountId__c   = acc.Id;
        insert ast;
        Test.stopTest();
    }
    
    static testMethod void testUpdate() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1];
        Account acc1 = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount1' limit 1];
        Asset ast = new Asset();
        ast.Name = 'MyNewAssetforTestClass';
        ast.AccountId = acc.Id;
        ast.vlocity_cmt__AssetReferenceId__c = '123';
        ast.vlocity_cmt__BillingAccountId__c  = acc.Id;
        ast.vlocity_cmt__ServiceAccountId__c   = acc.Id;
        insert ast;
        Test.startTest();
        ast.AccountId = acc1.Id;
        update ast;
        Test.stopTest();
    }
    
    static testMethod void testDelete() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount' limit 1];
        Asset ast = new Asset();
        ast.Name = 'MyNewAssetforTestClass';
        ast.AccountId = acc.Id;
        ast.vlocity_cmt__AssetReferenceId__c = '123';
        ast.vlocity_cmt__BillingAccountId__c  = acc.Id;
        ast.vlocity_cmt__ServiceAccountId__c   = acc.Id;
        insert ast;
        Test.startTest();
        delete ast;
        Test.stopTest();
    }
}