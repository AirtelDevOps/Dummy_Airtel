/**
 * Test class for ARTL_UpdateOnsiteAttendance
 */
@isTest
public class ARTL_UpdateOnsiteAttendanceTest {
	@TestSetup
    static void createTestData(){
        List<Account> accList = ARTL_TestDataFactory.createAccount('Business',true,1);
       // List<Contact> conList = ARTL_TestDataFactory.createContact('MobilePhoneContact',(accList.get(0)).Id, true, 1);
       Contact testContact = new Contact(Firstname = 'Test',LastName = 'Contact', Email = 'testcontact@test.com',AccountId= (accList.get(0)).Id, Phone = '8765337890',ARTL_Designation__c = 'Test', ARTL_Contact_Role__c='Sales Contact', Country_Code__c = '91');
       insert testContact;
        
        Event eventObj = new Event();
        eventObj.WhatId = (accList.get(0)).Id;
        eventObj.WhoId = testContact.Id;
        eventObj.DurationInMinutes = 1;
        eventObj.ActivityDateTime = System.now();
        insert eventObj;
        
    }
    @IsTest
    static void updateAttendanceTest(){
        Test.startTest();
        Event eventObj = [SELECT Id, Meeting_Location__Latitude__s, Meeting_Location__Longitude__s from Event LIMIT 1];
        ARTL_UpdateOnsiteAttendance.updateAttendance(eventObj.Id,12.0,12.0);
        
        Test.stopTest();
        Event eventObj1 = [SELECT Id, Meeting_Location__Latitude__s, Meeting_Location__Longitude__s from Event LIMIT 1];
        
        System.assertEquals(12.0, eventObj1.Meeting_Location__Latitude__s);
        System.assertEquals(12.0, eventObj1.Meeting_Location__Longitude__s);
    }
}