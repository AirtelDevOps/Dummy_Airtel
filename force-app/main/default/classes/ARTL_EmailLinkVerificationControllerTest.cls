@isTest
private class ARTL_EmailLinkVerificationControllerTest {
    
    static testmethod void testEmailLinkVerification() {
        
        Account acc = new Account(Name='Test Account', phone='9080785768'); 
        insert acc;
        
        Contact con = new Contact(Firstname = 'Test', Lastname = 'Contact', ARTL_Contact_Role__c = 'Authorized Signatory',
                                  accountId=acc.Id, ARTL_Designation__c = 'Test Designation', 
                                  phone = '908006040', email='tst@gmail.com');
        insert con;
        
        ARTL_EmailLinkVerificationController obj = new ARTL_EmailLinkVerificationController();
        
        test.startTest();
        
        
        obj.updateContact();
        pageReference tempreturn = obj.updateContact();
        System.assertEquals(null, tempreturn);

        ARTL_EmailLinkVerificationController.queryContactRecord(con.AccountId, con.Email);

        ARTL_EmailLinkVerificationController.createVerificationUrl(con);
        
        ARTL_EmailLinkVerificationController.sendEmail(con, 'httpstest@gmail.com');
        
        test.stopTest();
        
    }
}