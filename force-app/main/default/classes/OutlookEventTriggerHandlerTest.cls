@isTest
public class OutlookEventTriggerHandlerTest {

    @isTest
    static void testOutlookEventTriggerHandler() {
        
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account testAcc = new Account(name = 'Test Accountabc',BillingCity='Gurgaon', ARTL_Category__c='A',RecordTypeId = recordTypeId,
                                     BillingStreet = 'Panchkula',
                                         
                                         BillingState = 'Haryana',
                                         BillingPostalCode = '134109',
                                         BillingCountry = 'India', 
                                         ARTL_IntegrationId__c = 'test',
                                          
                                         ARTL_Customer_Segment__c = 'AB',
                                         ARTL_Service_Segment__c = 'BD',
                                         ARTL_Vertical_Segment__c = 'BFI',
                                         ARTL_Business_Circle_Region__c = 'AP');
        insert testAcc;
        
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAcc.Id, Email = 'test.contact@email.com', Phone= '1234567890', Salutation= 'Mr.', ARTL_Designation__c='TestDesgntn', ARTL_Contact_Role__c = 'COO', Country_Code__c = '91');
        insert testContact;
        
		Lead testLead = new Lead(FirstName = 'Test', LastName = 'Contact', Email = 'test.lead@email.com', Company='TEST',Salutation= 'Mr.',Lead_Action_Remarks__c='Lead creation');
        insert testLead;

        Lead testLeadName = new Lead(FirstName = 'Testing', LastName = 'Lead', Email = 'test.leads@email.com', Company='TEST1',Salutation= 'Mr.',Lead_Action_Remarks__c='Lead creation');
        insert testLeadName;
        
        Id p = [select id from profile where name='System Administrator'].id;

        User testUser = new User(FirstName = 'Test', LastName = 'User', Email = 'test.user@email.com', Username='test7864er@user.com',Alias = 'tuser', TimeZoneSidKey='Asia/Kolkata',
                                  ProfileId = p, LocaleSidKey = 'en_IN', LanguageLocaleKey  = 'en_US', EmailEncodingKey='UTF-8');
        insert testUser;
        
        Event testEvent = new Event(
            Subject = 'Test Event',
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().addHours(1),
            MS_Teams_Meeting__c = true,
            whoid= testLeadName.id,
            ARTL_Agenda__c='Test',
            CurrencyIsoCode='INR',
            External_Contacts__c='who@yah.com'
        );
        insert testEvent;

        EventRelation testEventRelation = new EventRelation(
            EventId = testEvent.Id,
            RelationId = testContact.Id
        );
        insert testEventRelation;
        EventRelation testEventRelation1 = new EventRelation(
            EventId = testEvent.Id,
            RelationId = testLead.Id
        );
        insert testEventRelation1;
        EventRelation testEventRelation2 = new EventRelation(
            EventId = testEvent.Id,
            RelationId = testUser.Id
        );
        insert testEventRelation2;
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"mockResponse": "success"}'));
		Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(400, '{"error": "bad request"}'));


        Test.startTest();
        OutlookEventTriggerHandler.handleAfterInsert(new List<Event>{testEvent});
        Test.stopTest();
        //Event updatedEvent = [SELECT Id, vlocity_cmt__EventStatus__c, System_Error__c FROM Event WHERE Id = :testEvent.Id];
       // System.assertEquals('Scheduling', updatedEvent.vlocity_cmt__EventStatus__c, 'Event status should be "Scheduling" after successful callout');
        
        Event erroredEvent = [SELECT Id, vlocity_cmt__EventStatus__c, System_Error__c FROM Event WHERE Id = :testEvent.Id];
        System.assertEquals('Error', erroredEvent.vlocity_cmt__EventStatus__c, 'Event status should be "Error" after callout error');
        System.assert(erroredEvent.System_Error__c.contains('400'), ' Should contain HTTP status code in System error');

    }
    
}