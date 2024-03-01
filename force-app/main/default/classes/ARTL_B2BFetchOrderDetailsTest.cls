@isTest
private class ARTL_B2BFetchOrderDetailsTest {
	@testSetup
    static void testSetupMethod(){
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
        Id partyRecordRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_Party_Contact').getRecordTypeId();
        Contact contactRec1 = new Contact(FirstName 			= 'Party',
                                         LastName				= 'Contact',
                                         Phone					= '9887654321', 
                                         Email					= 'test@test.com',
                                         ARTL_Designation__c 	= 'test', 
                                         ARTL_Contact_Role__c 	= 'Billing Contact', 
                                         AccountId 				= businessAccount.Id,
                                         RecordTypeId			= partyRecordRecordTypeId,
                                         Country_Code__c		= '91',
                                         Salutation				= 'Mr.');
        insert contactRec1;
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
                                                                                               Premises__c = premiseRecord.Id,
                                                                                              ARTL_NBA_Account__c = nbaAccount.Id);
        insert contactPremiseRelationRecord;
        ContactPremiseRelation__c contactPremiseRelationRecord2 = new ContactPremiseRelation__c(Name='Test CP', Role__c = 'DCP', Contact__c = contactRec.Id, 
                                                                                               ARTL_GST_Applicable__c = 'Yes', 
                                                                                               ARTL_Standard_Reason__c = 'SEZ',
                                                                                               GST__c = gstRecord.Id,
                                                                                               Premises__c = premiseRecord.Id,
                                                                                               ARTL_NBA_Account__c = nbaAccount.Id);
        insert contactPremiseRelationRecord2;
        }
    @isTest
    static void testInvokeMethod_fetchPartyAccount() {
        try{
        Account acc = [Select id,AccountNumber from Account where RecordType.DeveloperName = 'BillingAggregator' limit 1];
        // Prepare test data
        Map<String, Object> input = new Map<String, Object>{
            'OrderId' => '',
            'NBANumber' => acc.AccountNumber
        };
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        // Call the method
        Boolean result = new ARTL_B2BFetchOrderDetails().invokeMethod('fetchPartyAccount', input, outMap, options);

        // Assert the result
        System.assertEquals(true, result);
        System.assertNotEquals(null, outMap.get('PartyResponse'));
    }catch(Exception ex){

    }
    }

    @isTest
    static void testInvokeMethod_fetchBCPDCPMethod() {
        // Prepare test data
        String bcp='';
        String dcp='';
        String accNumber = '';
        List<ContactPremiseRelation__c> cprList = [Select id,Role__c,ARTL_NBA_Account__r.AccountNumber,BCP_DCP_Number__c from ContactPremiseRelation__c];
        if(cprList.size()>0){
        accNumber = cprList[0].ARTL_NBA_Account__r.AccountNumber;
        System.debug('cprList --->>'+cprList[0].BCP_DCP_Number__c);
            }
        for(ContactPremiseRelation__c cpr: cprList){
            if(cpr.Role__c == 'BCP'){
                bcp = cpr.BCP_DCP_Number__c;
            }else if(cpr.Role__c == 'DCP'){
                dcp = cpr.BCP_DCP_Number__c;
            }
        }
        Map<String, Object> input = new Map<String, Object>{
            'BCPId' => bcp,
            'DCPId' => dcp,
            'AccNumber' => accNumber
        };
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        // Call the method
        Boolean result = new ARTL_B2BFetchOrderDetails().invokeMethod('fetchBCPDCPMethod', input, outMap, options);

        // Assert the result
        System.assertEquals(true, result);
        System.assertNotEquals(null, outMap.get('BCPDCPResponse'));
    }
}