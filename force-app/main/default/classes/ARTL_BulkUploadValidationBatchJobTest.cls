@isTest
public class ARTL_BulkUploadValidationBatchJobTest {
    
    @testSetup
    public static void testData(){
        List<ARTL_Bulk_Upload_Iteration__c> iteList = new List<ARTL_Bulk_Upload_Iteration__c>();
        ARTL_Bulk_Upload_Iteration__c  ite = NEW ARTL_Bulk_Upload_Iteration__c ();
        ite.Name = 'BUC';
        ite.File_Name__c = 'sample.csv';
        iteList.add(ite);
        
        ARTL_Bulk_Upload_Iteration__c  ite2 = NEW ARTL_Bulk_Upload_Iteration__c ();
        ite2.Name = 'Quota';
        ite2.File_Name__c = 'sample.csv';
        iteList.add(ite2);
        
        /*ARTL_Bulk_Upload_Iteration__c  ite3 = NEW ARTL_Bulk_Upload_Iteration__c ();
        ite3.Name = 'Party_Contact';
        ite3.File_Name__c = 'sample.csv';
        iteList.add(ite3);*/
        
        ARTL_Bulk_Upload_Iteration__c  ite4 = NEW ARTL_Bulk_Upload_Iteration__c ();
        ite4.Name = 'BCPDCP_Contact';
        ite4.File_Name__c = 'sample.csv';
        iteList.add(ite4);
        
        ARTL_Bulk_Upload_Iteration__c  ite5 = NEW ARTL_Bulk_Upload_Iteration__c ();
        ite5.Name = 'Party_Contact';
        ite5.File_Name__c = 'sample.csv';
        iteList.add(ite5);

        ARTL_Bulk_Upload_Iteration__c  ite6 = NEW ARTL_Bulk_Upload_Iteration__c ();
        ite6.Name = 'BCPDCP_Contact_Update';
        ite6.File_Name__c = 'sample.csv';
        iteList.add(ite6);
        
        ARTL_Bulk_Upload_Iteration__c  ite7 = NEW ARTL_Bulk_Upload_Iteration__c ();
        ite7.Name = 'Party_Contact_Update';
        ite7.File_Name__c = 'sample.csv';
        iteList.add(ite7);
        
        if(iteList.Size()>0)
            Insert iteList;
        
        List<ForecastingType> forType = [SELECT id FROM ForecastingType WHERE DeveloperName = 'Opportunity_Amount'];
        ARTL_Bulk_Upload_Staging__c quota = NEW ARTL_Bulk_Upload_Staging__c();
        quota.Forecast_Name__c = forType[0].id;
        quota.Quota_Amount__c = '1002';
        quota.OIMID__c = UserInfo.getUserId();
        quota.Type__c = 'Quota';
        quota.ARTL_Bulk_Upload_Iteration__c = ite2.id;
        quota.Start_Date__c  = '2023-09-11';
        insert quota;
                
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
		Account businessAcc = new Account(Name = 'Test Business Account', AccountNumber = 'BS-00000000' , RecordTypeId = businessAccountRecordTypeId, BillingCity = 'New Delhi', BillingStreet='test address', BillingPostalCode='110012',BillingState='Delhi',BillingCountry='India', ARTL_Category__c ='A', ARTL_Customer_Segment__c ='AB',ARTL_Service_Segment__c ='Key',ARTL_Vertical_Segment__c='BFI', ARTL_Business_Circle_Region__c ='AP');
        insert businessAcc;
        
        Id BARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
		Account baAcc = new Account(Name = 'Test BA Account' , RecordTypeId = BARecordTypeId, parentId = businessAcc.Id, BillingStreet='test address',BillingCity = 'New Delhi', BillingPostalCode='110012', BillingState='Delhi',BillingCountry='India', ARTL_Category__c ='A', ARTL_Customer_Segment__c ='AB',ARTL_Service_Segment__c ='Key',ARTL_Vertical_Segment__c='BFI', ARTL_Business_Circle_Region__c ='AP');
        insert baAcc;
        
        Id bcpdcpContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_BCP_DCP_Contact').getRecordTypeId();
        Id partyRecordRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_Party_Contact').getRecordTypeId();

        Contact contactRec = new Contact(FirstName 				= 'Test',
                                         LastName				= 'Test',
                                         Phone					= '9887654321', 
                                         Email					= 'test@test.com',
                                         ARTL_Designation__c 	= 'test', 
                                         ARTL_Contact_Role__c 	= 'Billing Contact', 
                                         AccountId 				= baAcc.Id,
                                         RecordTypeId			= bcpdcpContactRecordTypeId,
                                         Country_Code__c		= '91',
                                         Salutation				= 'Mr.');
        insert contactRec;
        
        Contact contactRec1 = new Contact(FirstName 			= 'Party',
                                         LastName				= 'Contact',
                                         Phone					= '9887654321', 
                                         Email					= 'test@test.com',
                                         ARTL_Designation__c 	= 'test', 
                                         ARTL_Contact_Role__c 	= 'Billing Contact', 
                                         AccountId 				= baAcc.Id,
                                         RecordTypeId			= partyRecordRecordTypeId,
                                         Country_Code__c		= '91',
                                         Salutation				= 'Mr.');
        insert contactRec1;
        
        vlocity_cmt__Premises__c premiseRecord = new vlocity_cmt__Premises__c(Name = 'test', 
                                                                              vlocity_cmt__StreetAddress__c = 'Panchkula',
                                                                              vlocity_cmt__City__c = 'Panchkula',
                                                                              vlocity_cmt__State__c = 'Haryana',
                                                                              vlocity_cmt__PostalCode__c = '134109',
                                                                              vlocity_cmt__Country__c = 'India');
        insert premiseRecord;
        
        ContactPremiseRelation__c contactPremiseRelationRecord = new ContactPremiseRelation__c(Contact__c = contactRec.Id, 
                                                                                               Premises__c = premiseRecord.Id,
                                                                                               ARTL_NBA_Account__c = baAcc.Id,
                                                                                               ARTL_GST_Applicable__c = 'Yes',
                                                                                               ARTL_Standard_Reason__c = 'Exempt',
                                                                                               Role__c = 'BCP');
        insert contactPremiseRelationRecord;
        
        Id 	ProducttRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId();
        Product2 prod = NEW Product2(Name = 'Multiplay', ProductCode = '001', RecordTypeId = ProducttRecordTypeId);
		insert prod;
        
        Account_Plan__c accPlan = NEW Account_Plan__c(Account_Name__c = businessAcc.id,Fiscal_Year__c = '2024');
        insert accPlan;
        
        ARTL_Pincode__c pincode = new ARTL_Pincode__c();
        pincode.Name = '110031';
        pincode.ARTL_City__c = 'Delhi';
        pincode.ARTL_Country__c = 'India';
        pincode.ARTL_State__c = 'Delhi';
        insert pincode;
        
        Bottom_Up_Construct__c buc1 = new Bottom_Up_Construct__c();
		buc1.Account_Name__c = businessAcc.id;
  		buc1.Fiscal_Year__c = '2024';
    	buc1.Product_Category__c = prod.id;
    	buc1.Total_Competitor_Spends__c =121;
    	buc1.Spends_with_Airtel__c =12121;
    	buc1.Key_Competitor_and_Comments__c ='test';
        buc1.Account_Plan__c = accPlan.id;
		insert buc1;
        
        Bottom_Up_Construct__c buc2 = new Bottom_Up_Construct__c();
		buc2.Account_Name__c = businessAcc.id;
  		buc2.Fiscal_Year__c = '2024';
    	buc2.Product_Category__c = prod.id;
    	buc2.Total_Competitor_Spends__c =121;
    	buc2.Spends_with_Airtel__c =12121;
    	buc2.Key_Competitor_and_Comments__c ='test';
        buc2.Account_Plan__c = accPlan.id;
		insert buc2;
        
        ARTL_Bulk_Upload_Staging__c buc = NEW ARTL_Bulk_Upload_Staging__c();
        buc.Account_Number__c = businessAcc.AccountNumber;
        buc.Fiscal_Year__c  = '2024';
        buc.Total_Competitor_Spends__c = '3223';
        buc.Spends_with_Airtel__c  = '3111';
        buc.Key_Competitor_and_Comments__c = 'test';
        buc.Type__c = 'BUC';
        buc.Product_Category__c = prod.id;
        buc.Account_Plan__c = accPlan.id;
        buc.ARTL_Bulk_Upload_Iteration__c = ite.Id;
        insert buc;
        
        Account acc = [select id,accountnumber from account where id=:businessAcc.Id limit 1];
        Account baAccount = [select id,accountnumber from account where id=:baAcc.Id limit 1];
        ContactPremiseRelation__c cpr = [select id,BCP_DCP_Number__c from ContactPremiseRelation__c limit 1];
        Contact contactRecord = [Select id,ARTL_External_Contact_Number__c from Contact where RecordTypeId=:partyRecordRecordTypeId limit 1];
        
        ARTL_Bulk_Upload_Staging__c buc4 = NEW ARTL_Bulk_Upload_Staging__c();
        buc4.ARTL_Bulk_Upload_Iteration__c = ite4.Id;
        buc4.Type__c = 'BCPDCP_Contact';
        buc4.NBA_Account__c  = baAccount.AccountNumber;
        buc4.Customer_Type__c = 'BCP';
        buc4.Standard_Reason__c  = 'Exempt';
        buc4.GST_Applicable__c = 'Yes';
        buc4.GST__c = '06AADCH5934N1Z8';
        buc4.Salutation__c = 'Mr.';
        buc4.First_Name__c = 'BCPDCPdctest';
        buc4.Middle_Name__c = 'MiddleNameBCPDCP';
        buc4.Last_Name__c = 'LastNameBCPDCPTest';
        buc4.Designation__c = 'Manager';
        buc4.Responsibility__c = 'Admin Contact';
        buc4.Phone_Code__c = '91';
        buc4.Phone__c = '9999111222';
        buc4.Email_Address__c = 'test.user@healthmapdiagnostics.com';
        buc4.Address_Line_1__c = 'Civil hospital new building ground floor room no 31-32 district jind haryan';
        buc4.Pincode__c = '110031';
        buc4.City__c = 'Delhi';
        insert buc4;
        
        ARTL_Bulk_Upload_Staging__c buc6 = NEW ARTL_Bulk_Upload_Staging__c();
        buc6.ARTL_Bulk_Upload_Iteration__c = ite4.Id;
        buc6.Type__c = 'BCPDCP_Contact';
        buc6.NBA_Account__c  = baAccount.AccountNumber;
        buc6.Customer_Type__c = 'BCP';
        buc6.Standard_Reason__c  = 'Exempt';
        buc6.GST_Applicable__c = 'No';
        buc6.GST__c = '06AADCH5934N1Z8';
        buc6.Salutation__c = 'Mr.';
        buc6.First_Name__c = 'BCPDCPdctest';
        buc6.Middle_Name__c = 'MiddleNameBCPDCP';
        buc6.Last_Name__c = 'LastNameBCPDCPTest';
        buc6.Designation__c = 'Manager';
        buc6.Responsibility__c = 'Admin Contact';
        buc6.Phone_Code__c = '91';
        buc6.Phone__c = '9999111222';
        buc6.Email_Address__c = 'test.user@healthmapdiagnostics.com';
        buc6.Address_Line_1__c = 'Civil hospital new building ground floor room no 31-32 district jind haryan';
        buc6.Pincode__c = '110031';
        buc6.City__c = 'Delhi';
        insert buc6;
        
        ARTL_Bulk_Upload_Staging__c buc7 = NEW ARTL_Bulk_Upload_Staging__c();
        buc7.ARTL_Bulk_Upload_Iteration__c = ite4.Id;
        buc7.Type__c = 'BCPDCP_Contact';
        buc7.NBA_Account__c  = baAccount.AccountNumber;
        buc7.Customer_Type__c = 'BCP';
        buc7.Standard_Reason__c  = 'Exempt';
        buc7.GST_Applicable__c = 'No';
        buc7.GST__c = '06AADCH5934N1Z8';
        buc7.Salutation__c = 'Mr.';
        buc7.First_Name__c = 'BCPDCPdctest$';
        buc7.Middle_Name__c = 'MiddleNameBCPDCP';
        buc7.Last_Name__c = 'LastNameBCPDCPTest';
        buc7.Designation__c = 'Manager';
        buc7.Responsibility__c = 'Admin Contact';
        buc7.Phone_Code__c = '91';
        buc7.Phone__c = '9999111222';
        buc7.Email_Address__c = 'test.user@healthmapdiagnostics.com';
        buc7.Address_Line_1__c = 'Civil hospital new building ground floor room no 31-32 district jind haryan';
        buc7.Pincode__c = '110031';
        buc7.City__c = 'Delhi';
        insert buc7;
        
        ARTL_Bulk_Upload_Staging__c buc13 = NEW ARTL_Bulk_Upload_Staging__c();
        buc13.ARTL_Bulk_Upload_Iteration__c = ite4.Id;
        buc13.Type__c = 'BCPDCP_Contact';
        buc13.NBA_Account__c  = baAccount.AccountNumber;
        buc13.Customer_Type__c = 'BCP';
        buc13.Standard_Reason__c  = 'Exempt';
        buc13.GST_Applicable__c = 'No';
        buc13.GST__c = '06AADCH5934N1Z8';
        buc13.Salutation__c = 'Mr.';
        buc13.First_Name__c = 'BCPDCPdctest$';
        buc13.Middle_Name__c = 'MiddleNameBCPDCP';
        buc13.Last_Name__c = 'LastNameBCPDCPTest';
        buc13.Designation__c = 'Manager';
        buc13.Responsibility__c = 'Admin Contact';
        buc13.Phone_Code__c = '91';
        buc13.Phone__c = '9999111222';
        buc13.Email_Address__c = 'test.user@healthmapdiagnostics.com';
        buc13.Address_Line_1__c = 'Civil hospital new building ground floor room no 31-32 district jind haryan';
        buc13.Pincode__c = '110031';
        buc13.City__c = 'New Delhi';
        insert buc13;
        
        ARTL_Bulk_Upload_Staging__c buc5 = NEW ARTL_Bulk_Upload_Staging__c();
        buc5.ARTL_Bulk_Upload_Iteration__c = ite5.Id;
        buc5.Type__c = 'Party_Contact';
        buc5.Parent_Account__c = acc.AccountNumber;
        buc5.Salutation__c = 'Mr.';
        buc5.First_Name__c = 'Partydctest';
        buc5.Middle_Name__c = 'MiddleNameParty';
        buc5.Last_Name__c = 'LastNamePartyTest';
        buc5.Designation__c = 'Manager';
        buc5.Responsibility__c = 'Admin Contact';
        buc5.Phone_Code__c = '91';
        buc5.Phone__c = '9999111222';
        buc5.Email_Address__c = 'party.contact@healthmapdiagnostics.com';
        insert buc5;
        
        ARTL_Bulk_Upload_Staging__c buc8 = NEW ARTL_Bulk_Upload_Staging__c();
        buc8.ARTL_Bulk_Upload_Iteration__c = ite5.Id;
        buc8.Type__c = 'Party_Contact';
        buc8.Parent_Account__c = 'BS-00000000';
        buc8.Salutation__c = 'Mr.';
        buc8.First_Name__c = 'Partydctest';
        buc8.Middle_Name__c = 'MiddleNameParty';
        buc8.Last_Name__c = 'LastNamePartyTest';
        buc8.Designation__c = 'Manager';
        buc8.Responsibility__c = 'Admin Contact';
        buc8.Phone_Code__c = '91';
        buc8.Phone__c = '9999111222';
        buc8.Email_Address__c = 'party.contact@healthmapdiagnostics.com';
        insert buc8;

        ARTL_Bulk_Upload_Staging__c buc9 = NEW ARTL_Bulk_Upload_Staging__c();
        buc9.ARTL_Bulk_Upload_Iteration__c = ite7.Id;
        buc9.Type__c = 'Party_Contact_Update';
        //buc9.Parent_Account__c = acc.AccountNumber;
        buc9.Contact_Number__c  = contactRecord.ARTL_External_Contact_Number__c;
        buc9.Salutation__c = 'Mr.';
        buc9.First_Name__c = 'Partydctest';
        buc9.Middle_Name__c = 'MiddleNameParty';
        buc9.Last_Name__c = 'LastNamePartyTest';
        buc9.Designation__c = 'Manager';
        buc9.Responsibility__c = 'Admin Contact';
        buc9.Phone_Code__c = '91';
        buc9.Phone__c = '9999111222';
        buc9.Email_Address__c = 'party.contact@healthmapdiagnostics.com';
        insert buc9;
        
        ARTL_Bulk_Upload_Staging__c buc10 = NEW ARTL_Bulk_Upload_Staging__c();
        buc10.ARTL_Bulk_Upload_Iteration__c = ite7.Id;
        buc10.Type__c = 'Party_Contact_Update';
        //buc10.Parent_Account__c = 'BS-00000000';
        buc10.Contact_Number__c  = contactRecord.ARTL_External_Contact_Number__c;
        buc10.Salutation__c = 'Mr.';
        buc10.First_Name__c = 'Partydctest';
        buc10.Middle_Name__c = 'MiddleNameParty';
        buc10.Last_Name__c = 'LastNamePartyTest';
        buc10.Designation__c = 'Manager';
        buc10.Responsibility__c = 'Admin Contact';
        buc10.Phone_Code__c = '91';
        buc10.Phone__c = '9999111222';
        buc10.Email_Address__c = 'party.contact@healthmapdiagnostics.com';
        insert buc10;

        ARTL_Bulk_Upload_Staging__c buc11 = NEW ARTL_Bulk_Upload_Staging__c();
        buc11.ARTL_Bulk_Upload_Iteration__c = ite6.Id;
        buc11.Type__c = 'BCPDCP_Contact_Update';
        buc11.BCP_DCP_Number__c  = cpr.BCP_DCP_Number__c;
        buc11.Customer_Type__c = 'BCP';
        buc11.Standard_Reason__c  = 'Exempt';
        buc11.GST_Applicable__c = 'No';
        buc11.GST__c = '06AADCH5934N1Z8';
        buc11.Salutation__c = 'Mr.';
        buc11.First_Name__c = 'BCPDCPdctest';
        buc11.Middle_Name__c = 'MiddleNameBCPDCP';
        buc11.Last_Name__c = 'LastNameBCPDCPTest';
        buc11.Designation__c = 'Manager';
        buc11.Responsibility__c = 'Admin Contact';
        buc11.Phone_Code__c = '91';
        buc11.Phone__c = '9999111222';
        buc11.Email_Address__c = 'test.user@healthmapdiagnostics.com';
        buc11.Address_Line_1__c = 'Civil hospital new building ground floor room no 31-32 district jind haryan';
        buc11.Pincode__c = '110031';
        buc11.City__c = 'Delhi';
        buc11.State__c = 'Draft';
        insert buc11;
        
        ARTL_Bulk_Upload_Staging__c buc12 = NEW ARTL_Bulk_Upload_Staging__c();
        buc12.ARTL_Bulk_Upload_Iteration__c = ite6.Id;
        buc12.Type__c = 'BCPDCP_Contact_Update';
        buc11.BCP_DCP_Number__c  = cpr.BCP_DCP_Number__c;
        buc12.Customer_Type__c = 'BCP';
        buc12.Standard_Reason__c  = 'Exempt';
        buc12.GST_Applicable__c = 'No';
        buc12.GST__c = '06AADCH5934N1Z8';
        buc12.Salutation__c = 'Mr.';
        buc12.First_Name__c = 'BCPDCPdctest$';
        buc12.Middle_Name__c = 'MiddleNameBCPDCP';
        buc12.Last_Name__c = 'LastNameBCPDCPTest';
        buc12.Designation__c = 'Manager';
        buc12.Responsibility__c = 'Admin Contact';
        buc12.Phone_Code__c = '91';
        buc12.Phone__c = '9999111222';
        buc12.Email_Address__c = 'test.user@healthmapdiagnostics.com';
        buc12.Address_Line_1__c = 'Civil hospital new building ground floor room no 31-32 district jind haryan';
        buc12.Pincode__c = '110031';
        buc12.City__c = 'Delhi';
        buc12.State__c = 'Draft';
        insert buc12;
        
    }

    @isTest
    public static void ARTL_BulkUploadValidationBatch(){
        
        List<ARTL_Bulk_Upload_Iteration__c> ite = [SELECT id FROM ARTL_Bulk_Upload_Iteration__c limit 1];
        String iteId = ite[0].Id;
        
        Test.startTest();

        string respBody = '[{"id":"a7K7200000D0l15EAB","success":true,"errors":[]}]';

        MockHttpResponseGenerator mock = new MockHttpResponseGenerator(200, respBody);
        Test.setMock(HttpCalloutMock.class, mock);

        ARTL_BulkUploadValidationBatchJob ba= new ARTL_BulkUploadValidationBatchJob(iteId,'BUC');
        Id jobid= Database.executeBatch(ba,5);
       
        List<ARTL_Bulk_Upload_Iteration__c> ite2 = [SELECT id FROM ARTL_Bulk_Upload_Iteration__c WHERE Name = 'Quota' limit 1];
        String iteId2 = ite2[0].Id;
        ARTL_BulkUploadValidationBatchJob ba2= new ARTL_BulkUploadValidationBatchJob(iteId2,'Quota');
        Id jobid2= Database.executeBatch(ba2,5);
        Test.stopTest();
        
        ARTL_Bulk_Upload_Staging__c testRecord = [SELECT id, Record_Id__c from ARTL_Bulk_Upload_Staging__c where Record_Id__c != '' LIMIT 1];
        System.assert(testRecord.Record_Id__c != null,'Record_Id__c should not be null');
    }
    @isTest
    public static void ARTL_BulkUploadValidationBatchBCPDCP_Contact(){
        List<ARTL_Bulk_Upload_Config__mdt> customMdt = [SELECT Field_API_Name__c FROM ARTL_Bulk_Upload_Config__mdt WHERE DeveloperName= 'BCPDCP_Contact']; 
        Test.startTest();
        List<ARTL_Bulk_Upload_Iteration__c> ite3 = [SELECT id FROM ARTL_Bulk_Upload_Iteration__c WHERE Name = 'BCPDCP_Contact' limit 1];
        String iteId3 = ite3[0].Id;
        System.debug('iteId3 120 -->>'+iteId3);
        ARTL_BulkUploadValidationBatchJob ba3= new ARTL_BulkUploadValidationBatchJob(iteId3,'BCPDCP_Contact');
        Id jobid3= Database.executeBatch(ba3,5);
        Test.stopTest();
    }
    
    @isTest
    public static void ARTL_BulkUploadValidationBatchBCPDCP_Contact_Update(){
        List<ARTL_Bulk_Upload_Config__mdt> customMdt = [SELECT Field_API_Name__c FROM ARTL_Bulk_Upload_Config__mdt WHERE DeveloperName= 'BCPDCP_Contact_Update']; 
        Test.startTest();
        List<ARTL_Bulk_Upload_Iteration__c> ite3 = [SELECT id FROM ARTL_Bulk_Upload_Iteration__c WHERE Name = 'BCPDCP_Contact_Update' limit 1];
        String iteId3 = ite3[0].Id;
        System.debug('iteId3 120 -->>'+iteId3);
        ARTL_BulkUploadValidationBatchJob ba3= new ARTL_BulkUploadValidationBatchJob(iteId3,'BCPDCP_Contact_Update');
        Id jobid3= Database.executeBatch(ba3,5);
        Test.stopTest();
    }
    
    @isTest
    public static void ARTL_BulkUploadValidationBatchParty_Contact(){
        List<ARTL_Bulk_Upload_Config__mdt> customMdt = [SELECT Field_API_Name__c FROM ARTL_Bulk_Upload_Config__mdt WHERE DeveloperName= 'Party_Contact']; 
        Test.startTest();
        List<ARTL_Bulk_Upload_Iteration__c> ite3 = [SELECT id FROM ARTL_Bulk_Upload_Iteration__c WHERE Name = 'Party_Contact' limit 1];
        String iteId3 = ite3[0].Id;
        System.debug('iteId3 120 -->>'+iteId3);
        ARTL_BulkUploadValidationBatchJob ba3= new ARTL_BulkUploadValidationBatchJob(iteId3,'Party_Contact');
        Id jobid3= Database.executeBatch(ba3,5);
        Test.stopTest();
    }
    
    @isTest
    public static void ARTL_BulkUploadValidationBatchParty_Contact_Update(){
        List<ARTL_Bulk_Upload_Config__mdt> customMdt = [SELECT Field_API_Name__c FROM ARTL_Bulk_Upload_Config__mdt WHERE DeveloperName= 'Party_Contact_Update']; 
        Test.startTest();
        List<ARTL_Bulk_Upload_Iteration__c> ite3 = [SELECT id FROM ARTL_Bulk_Upload_Iteration__c WHERE Name = 'Party_Contact_Update' limit 1];
        String iteId3 = ite3[0].Id;
        System.debug('iteId3 120 -->>'+iteId3);
        ARTL_BulkUploadValidationBatchJob ba3= new ARTL_BulkUploadValidationBatchJob(iteId3,'Party_Contact_Update');
        Id jobid3= Database.executeBatch(ba3,5);
        Test.stopTest();
    }
}