@isTest
public class ARTL_UpdateBcpDcpLwcControllerTest {
    @testSetup
    public static void testData(){
        System.debug('DEBUGG testData ');
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account businessAccount = new Account(Name = 'Test Business Account',
                                              RecordTypeId = businessAccountRecordTypeId,
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
        insert businessAccount;
        
        Id nbaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
        Account nbaAccount = new Account(Name = 'Test NBA',
                                         RecordTypeId = nbaRecordTypeId, 
                                         ParentId = businessAccount.Id, 
                                         BillingStreet = 'Panchkula',
                                         BillingCity = 'Panchkula',
                                         BillingState = 'Haryana',
                                         BillingPostalCode = '134109',
                                         BillingCountry = 'India', 
                                         ARTL_IntegrationId__c = 'test',
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
        
        vlocity_cmt__Premises__c premiseRecord = new vlocity_cmt__Premises__c(Name = 'test', 
                                                                              vlocity_cmt__StreetAddress__c = 'Panchkula',
                                                                              vlocity_cmt__City__c = 'Panchkula',
                                                                              vlocity_cmt__State__c = 'Haryana',
                                                                              vlocity_cmt__PostalCode__c = '134109',
                                                                              vlocity_cmt__Country__c = 'India');
        insert premiseRecord;
        
        ContactPremiseRelation__c contactPremiseRelationRecord = new ContactPremiseRelation__c(Contact__c = contactRec.Id, 
                                                                                               Premises__c = premiseRecord.Id,
                                                                                               ARTL_NBA_Account__c = nbaAccount.Id,
                                                                                               ARTL_GST_Applicable__c = 'Yes',
                                                                                               ARTL_Standard_Reason__c = 'Exempt',
                                                                                               Role__c = 'BCP');
        insert contactPremiseRelationRecord;
        
    }
    
    @isTest
    public static void testGetRecords(){
        Account nbaAcc = [Select Id from Account where Name = 'Test NBA'];
        List<ContactPremiseRelation__c> returnList = new List<ContactPremiseRelation__c>();
        Test.startTest();
        returnList = ARTL_UpdateBcpDcpLwcController.getContactRecords(nbaAcc.Id);
        Test.stopTest();
        System.assertEquals(returnList.size()>0, true);
    }
    
    @isTest
    public static void testGetRecords2(){
        Account nbaAcc = [Select Id from Account where Name = 'Test NBA'];
        List<ContactPremiseRelation__c> returnList = new List<ContactPremiseRelation__c>();
        Test.startTest();
        returnList = ARTL_UpdateBcpDcpLwcController.getContactRecords('');
        System.debug('DEBUGG Test '+ returnList);
        Test.stopTest();
        System.assertEquals(returnList==null, true);
    }
    
    @isTest
    public static void testGetRecordDetails(){
        List<ContactPremiseRelation__c> returnList = new List<ContactPremiseRelation__c>();
        ContactPremiseRelation__c contactPremiseRelation = [Select Id from ContactPremiseRelation__c];
        Test.startTest();
        returnList = ARTL_UpdateBcpDcpLwcController.getRecordDetails(contactPremiseRelation.Id);
        Test.stopTest();
        System.assertEquals(returnList.size()>0, true);
    }
    
    @isTest
    public static void testUpdateRecords(){
        Contact contRec = [Select Id from Contact];
        ContactPremiseRelation__c contactPremiseRelation = [Select Id from ContactPremiseRelation__c];
        vlocity_cmt__Premises__c premise = [Select Id from vlocity_cmt__Premises__c];
        Account businessAcc = [Select Id from Account where Name = 'Test Business Account'];
        Account nbaAccount = [Select Id from Account where Name = 'Test NBA'];
        Map<String, String> inputMap = new Map<String, String>();
        
        inputMap.put('Id', contRec.Id);
        inputMap.put('Role__c', 'BCP');
        inputMap.put('ContactPremiseId',contactPremiseRelation.Id);
        inputMap.put('ARTL_GST_Applicable__c', 'Yes');
        inputMap.put('Salutation', 'Mr');
        inputMap.put('FirstName', 'Test');
        inputMap.put('MiddleName', 'Test');
        inputMap.put('LastName', 'Test');
        inputMap.put('Email', 'test');
        inputMap.put('Phone', '9876543210');
        inputMap.put('vlocity_cmt__Status__c', 'Active');
        inputMap.put('ARTL_Alternate_Email__c', 'test');
        inputMap.put('Fax', '3423423423');
        inputMap.put('ARTL_Standard_Reason__c', 'Non-SEZ');
        inputMap.put('ARTL_Designation__c', 'Test');
        inputMap.put('Premises__c', premise.Id);
        inputMap.put('ARTL_NBA_Account__c', nbaAccount.Id);
        inputMap.put('BusinessAccountId', businessAcc.Id);
        
        Map<String, String> inputMapNew = new Map<String, String>();
        inputMapNew.put('Id', contRec.Id);
        inputMapNew.put('Role__c', 'BCPandDCP');
        inputMapNew.put('ContactPremiseId',contactPremiseRelation.Id);
        inputMapNew.put('ARTL_GST_Applicable__c', 'Yes');
        inputMapNew.put('Salutation', 'Mr');
        inputMapNew.put('FirstName', 'Test');
        inputMapNew.put('MiddleName', 'Test');
        inputMapNew.put('LastName', 'Test');
        inputMapNew.put('Email', 'test@test.com');
        inputMapNew.put('Phone', '9876543210');
        inputMapNew.put('vlocity_cmt__Status__c', 'Active');
        inputMapNew.put('ARTL_Alternate_Email__c', 'test@test.com');
        inputMapNew.put('Fax', '3423423423');
        inputMapNew.put('ARTL_Standard_Reason__c', 'Exempt');
        inputMapNew.put('ARTL_Designation__c', 'Test');
        inputMapNew.put('Premises__c', premise.Id);
        inputMapNew.put('ARTL_NBA_Account__c', nbaAccount.Id);
        inputMapNew.put('BusinessAccountId', businessAcc.Id);
        Test.startTest();
        ARTL_UpdateBcpDcpLwcController.updateRecords(inputMap, inputMapNew);
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateRecords2(){
        Contact contRec = [Select Id from Contact];
        ContactPremiseRelation__c contactPremiseRelation = [Select Id from ContactPremiseRelation__c];
        vlocity_cmt__Premises__c premise = [Select Id from vlocity_cmt__Premises__c];
        Account businessAcc = [Select Id from Account where Name = 'Test Business Account'];
        Account nbaAccount = [Select Id from Account where Name = 'Test NBA'];
        Map<String, String> inputMap = new Map<String, String>();
        
        inputMap.put('Id', contRec.Id);
        inputMap.put('Role__c', 'BCP');
        inputMap.put('ContactPremiseId',contactPremiseRelation.Id);
        inputMap.put('ARTL_GST_Applicable__c', 'Yes');
        inputMap.put('Salutation', 'Mr');
        inputMap.put('FirstName', 'Test');
        inputMap.put('MiddleName', 'Test');
        inputMap.put('LastName', 'Test');
        inputMap.put('Email', 'test');
        inputMap.put('Phone', '9876543210');
        inputMap.put('vlocity_cmt__Status__c', 'Active');
        inputMap.put('ARTL_Alternate_Email__c', 'test');
        inputMap.put('Fax', '3423423423');
        inputMap.put('ARTL_Standard_Reason__c', 'Exempt');
        inputMap.put('ARTL_Designation__c', 'Test');
        inputMap.put('Premises__c', premise.Id);
        inputMap.put('ARTL_NBA_Account__c', nbaAccount.Id);
        inputMap.put('BusinessAccountId', businessAcc.Id);
        inputMap.put('StreetAddress', 'Panchkula');
        inputMap.put('City', 'Panchkula');
        inputMap.put('State', 'Haryana');
        inputMap.put('PostalCode', '134109');
        inputMap.put('Country', 'India');
        
        Map<String, String> inputMapNew = new Map<String, String>();
        inputMapNew.put('Id', contRec.Id);
        inputMapNew.put('Role__c', 'DCP');
        inputMapNew.put('ContactPremiseId',contactPremiseRelation.Id);
        inputMapNew.put('ARTL_GST_Applicable__c', 'Yes');
        inputMapNew.put('Salutation', 'Mr');
        inputMapNew.put('FirstName', 'Test');
        inputMapNew.put('MiddleName', 'Test');
        inputMapNew.put('LastName', 'Test');
        inputMapNew.put('Email', 'test@test.com');
        inputMapNew.put('Phone', '9876543210');
        inputMapNew.put('vlocity_cmt__Status__c', 'Active');
        inputMapNew.put('ARTL_Alternate_Email__c', 'test@test.com');
        inputMapNew.put('Fax', '3423423423');
        inputMapNew.put('ARTL_Standard_Reason__c', 'Exempt');
        inputMapNew.put('ARTL_Designation__c', 'Test');
        inputMapNew.put('Premises__c', premise.Id);
        inputMapNew.put('ARTL_NBA_Account__c', nbaAccount.Id);
        inputMapNew.put('BusinessAccountId', businessAcc.Id);
        inputMapNew.put('StreetAddress', 'Gurgaon');
        inputMapNew.put('City', 'Gurgaon');
        inputMapNew.put('State', 'Haryana');
        inputMapNew.put('PostalCode', '121001');
        inputMapNew.put('Country', 'India');
        Test.startTest();
        ARTL_UpdateBcpDcpLwcController.updateRecords(inputMap, inputMapNew);
        Test.stopTest();
    }
    
    @isTest
    public static void testPincodeData(){
        Test.startTest();
        ARTL_UpdateBcpDcpLwcController.getPincodeDetails('Panchkula');
        Test.stopTest();
    }
}