@isTest
public with sharing class ARTL_UpdatePMUserMatrixTest {

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
            List<Account> accList = ARTL_TestDataFactory.createAccount('Business', true, 1);
            PM_User_Matrix__c pm = new PM_User_Matrix__c();
            pm.Business_Account__c = accList[0].Id;
            pm.PM__c = UserInfo.getUserId();
            pm.TL__c = UserInfo.getUserId();
            pm.CPH__c = UserInfo.getUserId();
            pm.CCE__c = UserInfo.getUserId();
            pm.Circle__c = 'KK';
            insert pm;
        }
    }

    @isTest
    static void updatePMMatrix() {
        User u1 = [SELECT Id from User where username = 'testemail665411@email.com'];
        List<List<ARTL_PMUserMatrixWrapper>> userWrapperList = new List<List<ARTL_PMUserMatrixWrapper>>();
        ARTL_PMUserMatrixWrapper wrapper1 = new ARTL_PMUserMatrixWrapper();
        wrapper1.oldUser = u1.Id;
        wrapper1.newUser = UserInfo.getUserId();
        wrapper1.userType = 'PM';

        ARTL_PMUserMatrixWrapper wrapper2 = new ARTL_PMUserMatrixWrapper();
        wrapper2.oldUser = u1.Id;
        wrapper2.newUser = UserInfo.getUserId();
        wrapper2.userType = 'TL';

        ARTL_PMUserMatrixWrapper wrapper3 = new ARTL_PMUserMatrixWrapper();
        wrapper3.oldUser = u1.Id;
        wrapper3.newUser = UserInfo.getUserId();
        wrapper3.userType = 'CPH';

        ARTL_PMUserMatrixWrapper wrapper4 = new ARTL_PMUserMatrixWrapper();
        wrapper4.oldUser = u1.Id;
        wrapper4.newUser = UserInfo.getUserId();
        wrapper4.userType = 'CCE';

        userWrapperList.add(new List<ARTL_PMUserMatrixWrapper>{wrapper1, wrapper2, wrapper3, wrapper4});
        ARTL_UpdatePMUserMatrix.updateMatrix(userWrapperList);
    }
}