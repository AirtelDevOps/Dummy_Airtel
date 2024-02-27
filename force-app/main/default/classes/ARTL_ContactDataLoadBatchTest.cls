@isTest
private class ARTL_ContactDataLoadBatchTest {

    @isTest
    static void testARTL_ContactDataLoadBatch() {
        //Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
         //String billingAggregatorRecorTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing Aggregator').getRecordTypeId();
        //Account testAcc = new Account(name = 'Test Accountabc', RecordTypeId = billingAggregatorRecorTypeid,BillingStreet='test street' , BillingCity='test city',BillingPostalCode='test pincode',BillingState='test state',BillingCountry='test country',ARTL_Business_Circle_Region__c='India International');
        //insert testAcc;
        Id BARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
		Account testAcc = new Account(Name = 'Test BA Account' , RecordTypeId = BARecordTypeId, BillingStreet='test address',BillingCity = 'New Delhi', BillingPostalCode='110012', BillingState='Delhi',BillingCountry='India', ARTL_Category__c ='A', ARTL_Customer_Segment__c ='AB',ARTL_Service_Segment__c ='Key',ARTL_Vertical_Segment__c='BFI', ARTL_Business_Circle_Region__c ='AP');
        insert testAcc;
        Contact contactRec = new Contact(FirstName = 'Test', 
                                         LastName = 'Test',
                                         ARTL_Designation__c = 'Test', 
                                         ARTL_Contact_Role__c = 'CEO', 
                                         Phone = '9876543210', 
                                         Country_Code__c='1',
                                         Email = 'test@test.com', 
                                         AccountId = testAcc.Id);
        insert contactRec;
        contact con = new contact();
        con.FirstName = 'John';
        con.LastName = 'testJohn';
        con.phone = '1234567890';
        con.Country_Code__c='1';
        con.Email = 'john.doe@example.com';
        con.ARTL_Designation__c = 'BCP';
        con.ARTL_Contact_Role__c='CEO';
        con.AccountId = testAcc.Id;
        insert con;
        Account acc = new account();
        acc.name='kumar';
        insert acc;
        system.debug('conidtest'+con.id);
        
        
        // Set up test data
        List<ARTL_ContactDataLoadAPI.conWrapper> conWrapperList = new List<ARTL_ContactDataLoadAPI.conWrapper>();
        ARTL_ContactDataLoadAPI.conWrapper conWrap = new ARTL_ContactDataLoadAPI.conWrapper();
        
        // Sample data mapping to the wrapper class
        conWrap.FirstName = 'nag';
        conWrap.LastName = 'arjun';
        conWrap.Mobile = '1234556690';
        conWrap.Email = 'nagarjun@gmail.com';
        conWrap.Pincode = '500084';
        conWrap.AddLine1 = 'Divya Sree Orion, Hyderabad';
        conWrap.channel='ATB';
        conWrap.IntegrationId='12234567';
        conWrap.Designation = 'BCP';
        conWrap.Role='Billing Contact';
        conWrap.NBAId=testAcc.id;
        
        
        conWrap.OpType='Create';
        ARTL_ContactDataLoadAPI.conWrapper conWrap2 = new ARTL_ContactDataLoadAPI.conWrapper();
        conWrap2.FirstName = 'John';
        conWrap2.LastName = 'DoQ';
        conWrap2.Mobile = '1234566890';
        conWrap2.Email = 'john.do@example.com';
        conWrap2.channel='ATB';
        conWrap2.IntegrationId='12234569';
        conWrap2.Designation = 'BCP';
        conWrap2.OpType='Update';
        conWrap2.Id=String.valueOf(con.id);
        //con create fail 
        ARTL_ContactDataLoadAPI.conWrapper conWrap3 = new ARTL_ContactDataLoadAPI.conWrapper();
        
        // Sample data mapping to the wrapper class
        conWrap3.FirstName = 'vijay';
        conWrap3.LastName = 'Nagarjuna';
        conWrap3.Mobile = '7234567890';
        conWrap3.Email='vijaynag@gmail.com';
        conWrap3.channel='ATB';
        conWrap3.IntegrationId='12234568';
        conWrap3.Designation='BCP';
        conWrap3.Role='Billing Contact';
        conWrap3.PartyId=acc.id;
        
        conWrap3.OpType='Create';
        
        //update with wrong id
		ARTL_ContactDataLoadAPI.conWrapper conWrap4 = new ARTL_ContactDataLoadAPI.conWrapper();
        conWrap4.FirstName = 'John';
        conWrap4.LastName = 'DoQ';
        conWrap4.Mobile = '1234566890';
        conWrap4.Email = 'john.do@example.com';
        conWrap4.Designation = 'BCP';
        conWrap4.OpType='Update';
        conWrap4.Id='0037110000LJXCZAA5';
        
        ARTL_ContactDataLoadAPI.conWrapper conWrap5 = new ARTL_ContactDataLoadAPI.conWrapper();
        conWrap5.FirstName = 'John';
        conWrap5.LastName = 'DoQ';
        conWrap5.Mobile = '1234566890';
        conWrap5.Email = 'john.do@example.com';
        conWrap5.Designation = 'BCP';
        conWrap5.OpType='Update';
        conWrap5.Id=null;
        ARTL_ContactDataLoadAPI.conWrapper conWrap6 = new ARTL_ContactDataLoadAPI.conWrapper();
        conWrap6.FirstName = 'John';
        conWrap6.LastName = 'DoQ';
        conWrap6.Mobile = '1234566890';
        conWrap6.Email = 'john.do@example.com';
        conWrap6.Designation = 'BCP';
        conWrap6.OpType='Update';
        conWrap6.Id='003711LJXA5';
        conWrapperList.add(conWrap);
        conWrapperList.add(conWrap2);
        conWrapperList.add(conWrap3);
        conWrapperList.add(conWrap4);
        conWrapperList.add(conWrap5);
        conWrapperList.add(conWrap6);
       // conWrapperList.add(conWrap7);

        Case testCase = new Case(Status = 'In-Progress', Origin = 'Web');
        insert testCase;

        ARTL_ContactDataLoadBatch batch = new ARTL_ContactDataLoadBatch(conWrapperList, testCase.Id);

        // Start the batch
        Test.startTest();
        Database.executeBatch(batch);
        Test.stopTest();

        // Add assertions based on your expected behavior
        
        Contact CreateTest = [Select Email from Contact where email = 'nagarjun@gmail.com'];
		System.AssertEquals('nagarjun@gmail.com',CreateTest.Email);
        
       
        
    }


}