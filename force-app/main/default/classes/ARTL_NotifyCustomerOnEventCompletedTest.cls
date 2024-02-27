@isTest
public class ARTL_NotifyCustomerOnEventCompletedTest {
    
    @testSetup
    public static void testData(){
        
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
		Account businessAcc = new Account(Name = 'Test Business Account', RecordTypeId = businessAccountRecordTypeId, BillingStreet='Test Street',BillingState  = 'Karnataka',BillingCity   = 'Bengaluru',BillingCountry= 'India',BillingPostalCode = '560087',ARTL_Category__c = 'A',ARTL_Customer_Segment__c = 'AB',ARTL_Service_Segment__c = 'BD',ARTL_Vertical_Segment__c = 'BFI',ARTL_Business_Circle_Region__c = 'AP');
        insert businessAcc;
        Id MobilePhoneContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('MobilePhoneContact').getRecordTypeId();
        Contact con = New Contact(FirstName='Test', LastName = 'Roy',Phone='1234567890', Email = 'roy@test.com', ARTL_Designation__c='TestDesgntn', ARTL_Contact_Role__c = 'COO', RecordTypeId = MobilePhoneContactRecordTypeId, AccountId = businessAcc.Id, Country_Code__c = '90');
        insert con;
        
            Id mobilePhoneEventEventRecordTypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('MobilePhoneEvent').getRecordTypeId();
            Event eve = New Event(Subject='Email',RecordTypeId = mobilePhoneEventEventRecordTypeId);
            eve.StartDateTime = system.today()+3;
            eve.EndDateTime = system.today()+5;
            eve.WhatId = businessAcc.id;
            eve.WhoId = con.id;
            eve.vlocity_cmt__EventStatus__c ='Completed';
            eve.Next_Steps__c = 'Call';
            eve.Meeting_Notes_External__c = 'Discussion';
            eve.ARTL_Agenda__c  = 'Test Email';
            insert eve;
            
            EventRelation eveRe = NEW EventRelation();
            eveRe.EventId = eve.Id;
        
            User user = ARTL_TestDataFactory.createUser('Service');
            insert user;
            eveRe.RelationId = user.id;
            insert eveRe;
            
            System.debug('Event'+eve.id);
   
                
    }
    
    @isTest
    public static void FlowInputTest(){
        
        ARTL_NotifyCustomerOnEventCompleted.FlowInput obj = new ARTL_NotifyCustomerOnEventCompleted.FlowInput();
       
        Event eve = [SELECT id from Event limit 1];
        EventRelation eveRe = [SELECT id,RelationId,Relation.Email from EventRelation WHERE Relation.Email != NULL limit 1];
         
        obj.toList = new List<String>{eveRe.Relation.Email};
        obj.templateName = 'ARTL_Event_Completed_Without_SRNumber';
        obj.eventId = eve.id;
        Test.startTest();
        ARTL_NotifyCustomerOnEventCompleted.emailCustomerOnEventCompletion(new List<ARTL_NotifyCustomerOnEventCompleted.FlowInput>{obj});
        Test.stopTest();
    }
}