@isTest
private class ContactPremiseRelationTriggerHandlerTest {
    @testSetup
    private static void testData(){
        
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account businessAccount = new Account(Name = 'Test Business Account', 
                                              RecordTypeId = businessAccountRecordTypeId,
                                              BillingCity = 'Panchkula',
                                              BillingCountry = 'Haryana',
                                              BillingPostalCode = '134109',
                                              BillingState = 'India',
                                              BillingStreet = 'Panchkula',
                                              ARTL_Category__c = 'A', 
                                              ARTL_Customer_Segment__c = 'AB',
                                              ARTL_Service_Segment__c = 'BD',
                                              ARTL_Vertical_Segment__c = 'BFI',
                                              ARTL_Business_Circle_Region__c = 'AP',
                                              ARTL_PAN__c= 'KBNOF1234T');
        insert businessAccount;
        
        Id nbaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
        Account nbaAccount = new Account(Name 		= 'Test NBA', 
                                         ParentId 	= businessAccount.Id, 
                                         RecordTypeId = nbaRecordTypeId,
                                         BillingCity = 'Panchkula',
                                         BillingCountry = 'Haryana',
                                         BillingPostalCode = '134109',
                                         BillingState = 'India',
                                         BillingStreet = 'Panchkula',
                                         ARTL_Category__c = 'A', 
                                         ARTL_Customer_Segment__c = 'AB',
                                         ARTL_Service_Segment__c = 'BD',
                                         ARTL_Vertical_Segment__c = 'BFI',
                                         ARTL_Business_Circle_Region__c = 'AP');
        insert nbaAccount;
        
        Contact contactRec = new Contact(FirstName 				= 'Test',
                                         LastName				= 'Test',
                                         Phone					= '9887654321', 
                                         Email					= 'test@test.com',
                                         ARTL_Designation__c 	= 'test', 
                                         ARTL_Contact_Role__c 	= 'Billing Contact', 
                                         AccountId 				= nbaAccount.Id,
                                         Country_Code__c		= '91');
        insert contactRec;
        ARTL_Pincode__c pincode = new ARTL_Pincode__c();
        pincode.Name = '110031';
        pincode.ARTL_City__c = 'Delhi';
        pincode.ARTL_Country__c = 'India';
        pincode.ARTL_State__c = 'Delhi';
        pincode.ARTL_State_Code__c = '6';
        insert pincode;
        
        vlocity_cmt__Premises__c premiseRecord = new vlocity_cmt__Premises__c(Name = 'test class', 
                                                                              vlocity_cmt__StreetAddress__c = 'test class',
                                                                              vlocity_cmt__City__c = 'Panchkula',
                                                                              vlocity_cmt__State__c = 'Delhi',
                                                                              vlocity_cmt__PostalCode__c = '134109',
                                                                              vlocity_cmt__Country__c = 'India',
                                                                              ARTL_Pincode__c = pincode.Id);
        insert premiseRecord;
        
        vlocity_cmt__Premises__c premiseRecord2 = new vlocity_cmt__Premises__c(Name = 'test class2', 
                                                                              vlocity_cmt__StreetAddress__c = 'test class',
                                                                              vlocity_cmt__City__c = 'Panchkula',
                                                                              vlocity_cmt__State__c = 'Maharashtra',
                                                                              vlocity_cmt__PostalCode__c = '120006',
                                                                              vlocity_cmt__Country__c = 'India',
                                                                              ARTL_Pincode__c = pincode.Id);
        insert premiseRecord2;
        
        GST__c gstRecord = new GST__c(Name = '06KBNOF1234T1Z1',
                                      ARTL_Address__Street__s = 'Test',
                                      ARTL_Address__City__s = 'Panchkula',
                                      ARTL_Address__StateCode__s = 'DL',
                                      ARTL_Address__CountryCode__s = 'IN', 
                                      ARTL_Dty_GST_API_Response__c = 'SEZ', 
                                      Account__c = businessAccount.Id, 
                                      Status__c = 'Active',
                                      ARTL_GST_State_Code__c = '6');
        insert gstRecord;
        ContactPremiseRelation__c contactPremiseRelationRecord = new ContactPremiseRelation__c(Name='Test CP', Role__c = 'BCP', Contact__c = contactRec.Id, 
                                                                                               ARTL_GST_Applicable__c = 'Yes', 
                                                                                               ARTL_Standard_Reason__c = 'SEZ',
                                                                                               GST__c = gstRecord.Id,
                                                                                               Premises__c = premiseRecord.Id);
        insert contactPremiseRelationRecord;
    }
    
    @isTest
    static void testStandardReasonUpdate(){
        List<ContactPremiseRelation__c> contactPremiseRelationList = [Select Id, ARTL_Standard_Reason__c from ContactPremiseRelation__c];
        contactPremiseRelationList[0].ARTL_Standard_Reason__c = 'SEZ with taxes';
        Boolean expectedExceptionThrown;

        Test.startTest();
        try{
            update contactPremiseRelationList;
        }
        catch(Exception ex){
            System.debug('DEBUGG '+ ex.getMessage());
            expectedExceptionThrown = ex.getMessage().containsIgnoreCase('BCP/DCP Contact') ? true : false;
        }
        Test.stopTest();
        System.assertEquals(expectedExceptionThrown, true);

    }
    
    @isTest
    static void testContactPremiseRelationTriggerHandler(){
        
        List<Contact> contactRec = [SELECT id FROM Contact WHERE Email = 'test@test.com'];
        List<Account> businessAccount = [SELECT id FROM Account WHERE Name = 'Test Business Account'];
        List<vlocity_cmt__Premises__c> premiseRecord2 = [SELECT id FROM vlocity_cmt__Premises__c WHERE Name = 'test class2'];
        List<GST__c> gstRecord = [SELECT id FROM GST__c WHERE Name = '06KBNOF1234T1Z1'];
        
        ContactPremiseRelation__c contactPremiseRelationRecord2 = new ContactPremiseRelation__c(Name='CPR Test', Role__c = 'BCP', Contact__c = contactRec[0].Id, 
                                                                                               ARTL_GST_Applicable__c = 'Yes', 
                                                                                               ARTL_Standard_Reason__c = 'SEZ',
                                                                                               GST__c = gstRecord[0].Id,
                                                                                               Premises__c = premiseRecord2[0].Id);
        Boolean expectedExceptionThrown;
        Test.startTest();
        try{
            insert contactPremiseRelationRecord2;
        }
        catch(Exception ex){
            System.debug('DEBUGG#'+ ex.getMessage());
            expectedExceptionThrown = ex.getMessage().containsIgnoreCase('State on Premise') ? true : false;
        }
        Test.stopTest();
		//System.assertEquals(expectedExceptionThrown, true);
    }
}