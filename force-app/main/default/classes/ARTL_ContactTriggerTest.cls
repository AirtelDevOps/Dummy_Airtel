@isTest
public class ARTL_ContactTriggerTest {
    @isTest
    public static void testContactUpdate(){
        List<Account> accountList 	= ARTL_TestDataFactory.createAccount('Business', true, 1);
        Id ContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_BCP_DCP_Contact').getRecordTypeId();
        Contact contactRecord = new Contact(Firstname 		= 'Test',
                                            LastName 		= 'Contact', 
                                            Email 			= 'testcontact@test.com',
                                            AccountId		= accountList[0].Id, 
                                            RecordTypeId 	= ContactRecordTypeId, 
                                            Phone 			= '8765337890',
                                            ARTL_Designation__c = 'Test', 
                                            ARTL_Contact_Role__c='Sales Contact',
                                            Country_Code__c  = '1',
                                            Salutation = 'Ms.');
        insert contactRecord;
        contactRecord.MiddleName = 'Test'; 
        Boolean expectedExceptionThrown;
        test.startTest();
        try{
            update contactRecord;
        }
        catch(Exception ex){
            expectedExceptionThrown = ex.getMessage().contains('BCP/DCP contact') ? true : false;
        }
        test.stopTest();
        System.assertEquals(expectedExceptionThrown, true);
        
    }
}