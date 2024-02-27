@isTest
public class ARTL_gstDetailsInBcpDcpTest {
    @testSetup
    public static void testData(){
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Id nbaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
        Account businessAcc = new Account(Name = 'Test Business Account', 
                                          RecordTypeId = businessAccountRecordTypeId,
                                          //BillingLatitude = 38.8951, 
                                          //BillingLongitude = -77.0364
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
        System.debug('DEBUGG '+ businessAcc.BillingStreet + businessAcc.BillingCity);
        System.debug('DEBUGG '+ businessAcc.BillingAddress);
        insert businessAcc;
        
        Account nba = new Account(Name = 'Test NBA',
                                  RecordTypeId = nbaRecordTypeId, 
                                  ParentId = businessAcc.Id, 
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
        insert nba;
        
        GST__c gstRecord = new GST__c(Name = '06ABCDE1234F1Z1',
                                      ARTL_Address__Street__s = 'Test',
                                      ARTL_Address__City__s = 'Panchkula',
                                      ARTL_Address__StateCode__s = 'HR',
                                      ARTL_Address__CountryCode__s = 'IN', 
                                      ARTL_Dty_GST_API_Response__c = 'Regular', 
                                      Account__c = businessAcc.Id, 
                                      Status__c = 'Active');
        insert gstRecord;

    }
    
    @isTest 
    public static void testGetGstDetails(){
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account businessAccount = [Select Id from Account where RecordTypeId = :businessAccountRecordTypeId];
        Account nba = [Select Id from Account where ParentId = :businessAccount.Id];
        Test.startTest();
        ARTL_gstDetailsInBcpDcp.getGstDetails('Haryana', nba.Id, 'Non-SEZ');
        Test.stopTest();
        
    }
    
    @isTest
    public static void testCreateBCP(){
        Id nbaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
        Account nba = [Select Id from Account where RecordTypeId = :nbaRecordTypeId];
        Map<String, Object> addressDetails = new Map<String, Object>{
            'street' => 'test',
                'city' => 'Panchkula',
                'state' => 'Haryana',
                'country' => 'India',
                'TApincode'=> '134109',
                'pincode' => '134109'
                };
        Map<String, Object> pincodeBlock = new Map<String, Object>{
             'TApincode-Block' => addressDetails,
                 
                 'Messaging1' => null,
                 'pincodeExistFormula' => true,
                 'errorMessage' => 'Please select a GST number.',
                 'gstNumber' => null,
                 'Messaging2' => null,
                 'Select_Salutation' =>'Mr.',
                 'TXT_FirstName' => 'test',
                 'TXT_LastName' => 'test',
                 'TXT_Email' => 'test@test.com',
                 'Number_Mobile' => '0987654321',
                 'Select_Role' => 'DCP',
                 'alternateEmail' => null,
                 'fax' => null,
                 'gstApplicable' => 'Yes',
                 'standardReason' => 'Non-SEZ',
                 'gstType' => 'Non-SEZ',
                 'lwcError' => 'Please select a GST number.', 
                 'designation'=> 'test'
                 };
        Map<String, Object> input = new Map<String, Object>{
            'ContextId' => nba.Id, 
                'Step_ContactDetails' => pincodeBlock
                
        };
            Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
            System.debug('DEBUGG '+ input);
        Test.startTest();
        ARTL_gstDetailsInBcpDcp helper = new ARTL_gstDetailsInBcpDcp();
        Boolean result = helper.invokeMethod('createBcp', input, output, options);
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateBCP2(){
        Id nbaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
        Account nba = [Select Id from Account where RecordTypeId = :nbaRecordTypeId];
        Map<String, Object> addressDetails = new Map<String, Object>{
            'street' => 'test',
                'city' => 'Panchkula',
                'state' => 'Haryana',
                'country' => 'India',
                'TApincode'=> '134109',
                'pincode' => '134109'
                };
        Map<String, Object> pincodeBlock = new Map<String, Object>{
             'TApincode-Block' => addressDetails,
                 
                 'Messaging1' => null,
                 'pincodeExistFormula' => true,
                 'errorMessage' => 'Please select a GST number.',
                 'gstNumber' => null,
                 'Messaging2' => null,
                 'Select_Salutation' =>'Mr.',
                 'TXT_FirstName' => 'test',
                 'TXT_LastName' => 'test',
                 'TXT_Email' => 'test@test.com',
                 'Number_Mobile' => '0987654321',
                 'Select_Role' => 'BCPandDCP',
                 'alternateEmail' => null,
                 'fax' => null,
                 'gstApplicable' => 'Yes',
                 'standardReason' => 'Non-SEZ',
                 'gstType' => 'Non-SEZ',
                 'lwcError' => 'Please select a GST number.', 
                 'designation'=> 'test'
                 };
        Map<String, Object> input = new Map<String, Object>{
            'ContextId' => nba.Id, 
                'Step_ContactDetails' => pincodeBlock
                
        };
            Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
            System.debug('DEBUGG '+ input);
        Test.startTest();
        ARTL_gstDetailsInBcpDcp helper = new ARTL_gstDetailsInBcpDcp();
        Boolean result = helper.invokeMethod('createBcp', input, output, options);
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateBCP3(){
        Id nbaRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
        Account nba = [Select Id from Account where RecordTypeId = :nbaRecordTypeId];
        Map<String, Object> addressDetails = new Map<String, Object>{
            'street' => 'test',
                'city' => 'Panchkula',
                'state' => 'Haryana',
                'country' => 'India',
                'TApincode'=> '134109',
                'pincode' => '134109'
                };
        Map<String, Object> pincodeBlock = new Map<String, Object>{
             'TApincode-Block' => addressDetails,
                 
                 'Messaging1' => null,
                 'pincodeExistFormula' => true,
                 'errorMessage' => 'Please select a GST number.',
                 'gstNumber' => null,
                 'Messaging2' => null,
                 'Select_Salutation' =>'Mr.',
                 'TXT_FirstName' => 'test',
                 'TXT_LastName' => 'test',
                 'TXT_Email' => 'test@test.com',
                 'Number_Mobile' => '0987654321',
                 'Select_Role' => 'BCP',
                 'alternateEmail' => null,
                 'fax' => null,
                 'gstApplicable' => 'Yes',
                 'standardReason' => 'Non-SEZ',
                 'gstType' => 'Non-SEZ',
                 'lwcError' => 'Please select a GST number.', 
                 'designation'=> 'test'
                 };
        Map<String, Object> input = new Map<String, Object>{
            'ContextId' => nba.Id, 
                'Step_ContactDetails' => pincodeBlock
                
        };
            Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
            System.debug('DEBUGG '+ input);
        Test.startTest();
        ARTL_gstDetailsInBcpDcp helper = new ARTL_gstDetailsInBcpDcp();
        Boolean result = helper.invokeMethod('createBcp', input, output, options);
        Test.stopTest();
    }


}