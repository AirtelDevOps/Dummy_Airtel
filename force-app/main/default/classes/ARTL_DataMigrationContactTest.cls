@isTest
private class ARTL_DataMigrationContactTest {

    @isTest
    static void testBatchExecution() {
        Map<Id, String> errorMap = new Map<Id, String>();
        ARTL_Pincode__c pin = new ARTL_Pincode__c();
        pin.name='523356';
        insert pin;
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account testAcc = new Account(name = 'Test Accountabc', 
                                      RecordTypeId = recordTypeId,
                                      BillingCity = 'Panchkula',
                                      BillingCountry = 'Haryana',
                                      BillingPostalCode = '134109',
                                      BillingState = 'India',
                                      BillingStreet = 'Panchkula', 
                                      ARTL_IntegrationId__c = 'test', 
                                      ARTL_Category__c = 'A', 
                                      ARTL_Customer_Segment__c = 'AB',
                                      ARTL_Service_Segment__c = 'BD',
                                      ARTL_Vertical_Segment__c = 'BFI',
                                      ARTL_Business_Circle_Region__c = 'AP',
                                      ARTL_PAN__c = 'ABCDE1234F');
        insert testAcc;
        contact con = new contact();
		con.lastname= 'aarrjjunnaa';
		con.firstname='naggg';
		con.email='arjun1234@gmail.com';
		con.ARTL_Contact_Role__c='CEO';
		con.ARTL_Designation__c='randomm';
		con.phone='1234577897';
        con.AccountId = testAcc.Id;
        con.Country_Code__c		= '91';
		Database.saveResult result = database.insert(con) ;
		system.debug(con.id);
        errorMap.put(con.id,'contact inserted');
                     // Created test data
        //account Nba = new account();
        String billingAggregatorRecorTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing Aggregator').getRecordTypeId();
        account nba = new account(name = 'Test Accountabc', 
                                      RecordTypeId = billingAggregatorRecorTypeid,
                                  	AccountNumber='31-123456',
                                  Parentid = testAcc.Id,
                                      BillingCity = 'Panchkula',
                                      BillingCountry = 'Haryana',
                                      BillingPostalCode = '134109',
                                      BillingState = 'India',
                                      BillingStreet = 'Panchkula', 
                                      ARTL_IntegrationId__c = 'test', 
                                      ARTL_Category__c = 'A', 
                                      ARTL_Customer_Segment__c = 'AB',
                                      ARTL_Service_Segment__c = 'BD',
                                      ARTL_Vertical_Segment__c = 'BFI',
                                      ARTL_Business_Circle_Region__c = 'AP',
                                      ARTL_PAN__c = 'ABCDE1234F');
        //nba.recordTypeid=billingAggregatorRecorTypeid;
        //nba.AccountNumber='31-123456';
        //nba.Parentid = testAcc.Id;
        insert nba;
        String businessRecorTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        account Ba = new account();
        Ba.RecordTypeId=businessRecorTypeid;
        Ba.AccountNumber='11-123456';
        //sert Ba;
        List<ARTL_DataMigrationStaging__c> testData = new List<ARTL_DataMigrationStaging__c>();
        ARTL_DataMigrationStaging__c stagingRecord = new ARTL_DataMigrationStaging__c();
        stagingRecord.type__c='Contact';
        stagingRecord.Contact_Last_Name__c='testcon';
        stagingRecord.Responsibility__c='Testres';
        stagingRecord.designation__c='BCP';
        stagingRecord.Alternate_Email_Addr__c=''; 
        stagingRecord.Contact_Cell_Phone__c='';
        stagingRecord.Contact_Email_Address__c='';
        stagingRecord.Fax_Phone__c='';
        stagingRecord.Contact_Middle_Name__c='';
      	stagingRecord.Contact_Parent_Account__c=nba.id;
      	stagingRecord.NBA_Account__c=Nba.id;
        stagingRecord.Contact_Number__c='1-123456';
        stagingRecord.Contact_Phn_Code__c='91';
        stagingRecord.Responsibility__c='CEO';
        stagingRecord.Designation__c='BCP';
        stagingRecord.Active__c ='true';
        
        testData.add(stagingRecord);
        

        // Insert test data
        insert testData;

        // Start the batch
        Test.startTest();
        ARTL_DataMigrationContact batchInstance = new ARTL_DataMigrationContact();
        Database.executeBatch(batchInstance);
        Test.stopTest();

        // Perform assertions based on the expected behavior of your batch logic
        // Verify that the data has been processed as expected

        // Example assertion:
        System.assertEquals(0, batchInstance.errorMap.size(), 'No errors should be present');
    }
}