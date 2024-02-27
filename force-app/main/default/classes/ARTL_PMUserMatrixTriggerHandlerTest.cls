@isTest
public with sharing class ARTL_PMUserMatrixTriggerHandlerTest {

    @testSetup    
    static void setupData() {
        Profile p = [SELECT id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];  
        User adminUser = new User(firstname= 'Samuel',
                                  lastname='Oak',
                                  Alias='Samuel',
                                  email = 'testemail665411@email.com',
                                  username= 'testemail665411@email.com', 
                                  profileId= p.id, 
                                  emailencodingkey='UTF-8',
                                  languagelocalekey='en_US',
                                  localesidkey='en_US',
                                  timezonesidkey='America/Los_Angeles');
        System.runAs(adminUser){
           
        }
    }

    @isTest
    static void updatePMMatrix() {
        List<Account> accList = ARTL_TestDataFactory.createAccount('Business', true, 1);
        PM_User_Matrix__c pm = new PM_User_Matrix__c();
        pm.Business_Account__c = accList[0].Id;
        pm.PM__c = UserInfo.getUserId();
        pm.TL__c = UserInfo.getUserId();
        pm.CPH__c = UserInfo.getUserId();
        pm.CCE__c = UserInfo.getUserId();
        pm.Circle__c = 'KK';
        insert pm;

        Task t = new Task();
        t.OwnerId = UserInfo.getUserId();
        t.Subject = 'PM Approval';
        insert t;

        User u1 = [SELECT Id from User where username = 'testemail665411@email.com'];
        pm.PM__c = u1.Id;
        update pm;
    }
}