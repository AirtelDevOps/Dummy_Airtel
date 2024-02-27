@isTest
private class ARTL_POExpiryBatchTest {
    
    @isTest
    static void testARTL_POExpiryBatch() {
        // Create test data
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        List<User> userList = new List<User>();
        User user = new User(LastName = 'Jack',FirstName='Dan', Alias = 'jk', Email = 'Jack.Dan@testorg.com',
                             Username = 'Jack.Dan@testorg.com', ProfileId = profileId.id,TimeZoneSidKey = 'GMT', 
                             LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',LocaleSidKey = 'en_US');
        userList.add(user);
        
        User user1 = new User(LastName = 'Jack1',FirstName='Dan1', Alias = 'jk', Email = 'Jack.Dan1@testorg.com',
                              Username = 'Jack.Dan1@testorg.com', ProfileId = profileId.id,TimeZoneSidKey = 'GMT', 
                              LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',LocaleSidKey = 'en_US');
        userList.add(user1);
        
        insert userList;
        
        Account[] accounts =new Account[3];
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Id billingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        Id serviceAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        accounts[0] = new Account(Name = 'Test Business Account',RecordTypeId = businessAccountRecordTypeId, BillingStreet='Test Street', BillingCity='Mumbai', BillingState='Maharashtra', BillingPostalCode='120006',BillingCountry='India',ARTL_Category__c='A',ARTL_Customer_Segment__c='AB', ARTL_Business_Circle_Region__c='NCR',ARTL_Service_Segment__c='Bharti',ARTL_Vertical_Segment__c='BFI');		
        accounts[1] = new Account(Name = 'Test Billing Account',RecordTypeId  = billingAccountRecordTypeId, BillingStreet='Test Street', BillingCity='Mumbai', BillingState='Maharashtra', BillingPostalCode='120006',BillingCountry='India',ARTL_Category__c='A',ARTL_Customer_Segment__c='AB', ARTL_Business_Circle_Region__c='NCR',ARTL_Service_Segment__c='Bharti',ARTL_Vertical_Segment__c='BFI');
        accounts[2] = new Account(Name = 'Test Service Account',RecordTypeId  = serviceAccountRecordTypeId, BillingStreet='Test Street', BillingCity='Mumbai', BillingState='Maharashtra', BillingPostalCode='120006',BillingCountry='India',ARTL_Category__c='A',ARTL_Customer_Segment__c='AB', ARTL_Business_Circle_Region__c='NCR',ARTL_Service_Segment__c='Bharti',ARTL_Vertical_Segment__c='BFI');
        
        if(accounts.size()>0)	{
            insert accounts;    
        }																																																												
        
        
        List<AccountTeamMember> atmTestList = new List<AccountTeamMember>();
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.UserId         = userList[0].Id;
        atm.User           = userList[0];
        atm.TeamMemberRole = 'Collection Manager';
        atm.AccountId      = accounts[0].Id;
        atmTestList.add(atm);
        
        AccountTeamMember atm1 = new AccountTeamMember();
        atm1.UserId         = userList[1].Id;
        atm1.User           = userList[1];
        atm1.TeamMemberRole = 'Secondary KAM';
        atm1.AccountId      = accounts[0].Id;
        atmTestList.add(atm1);
        
        if(atmTestList.size()>0){
            insert atmTestList;    
        }
        
        
        
        List<ARTL_Purchase_Order__c> purchaseOrders = new List<ARTL_Purchase_Order__c>();
        for (Integer i = 0; i < 10; i++) {
            ARTL_Purchase_Order__c po = new ARTL_Purchase_Order__c(
                ARTL_PO_Number__c = 'Test PO ' + i,
                Start_Date__c = Date.today().addDays(-10),
                End_Date__c = Date.today().addDays(30),
                ARTL_Account__c = accounts[0].Id,
                OwnerId = UserInfo.getUserId()
            );
            purchaseOrders.add(po);
        }
        insert purchaseOrders;
        Test.startTest();
        // Start the batch
        ARTL_POExpiryBatch batch = new ARTL_POExpiryBatch();
        Database.executeBatch(batch);
        // Perform assertions based on your requirements
        // For example, check if emails were sent or records were processed as expected
        // You can query the AsyncApexJob object to get information about the batch execution
        Test.stopTest();
        System.assertEquals(0, Limits.getEmailInvocations());
    }
}