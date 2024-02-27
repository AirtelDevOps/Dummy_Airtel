@isTest
private class ARTL_UserUpdaterTest {
    
    static testMethod void testEncryptAndDecrypt() {
        
        List<UserRole> lstUR = new List<UserRole>();
        UserRole ur = new UserRole(Name = 'CEO');        
        lstUR.add(ur);
        insert lstUR;
        
        User usr = new User(
            FirstName = 'Test1test',
            LastName = 'User1test',
            Alias = 'tusetest',
            UserRoleId = ur.Id,
            Email = 'testuser1test@example.com',
            Username = 'testuser1test@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert usr;
        
        
        Test.startTest();
        
        ARTL_UserUpdater.getAllRoles();
        system.assertEquals(1, lstUR.size());
        
        ARTL_UserUpdater.getCurrentUserRole(usr.Id);
        system.assertEquals('CEO', lstUR[0].Name);
        
        ARTL_UserUpdater.updateUserRole(usr.Id, usr.UserRoleId);
        
        ARTL_UserUpdater.getRoleOptions();
        
        Test.stopTest();
    }
}