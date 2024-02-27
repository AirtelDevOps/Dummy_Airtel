/**
 * Test class for ARTL_FindDuplicate
 */
@isTest
public class ARTL_FindDuplicateTest {
	@TestSetup
    static void createTestData(){
        List<Account> accList = ARTL_TestDataFactory.createAccount('Business',true,1);
        Account acc = accList.get(0);
        acc.BillingStreet = 'Test Street';
        acc.BillingState  = 'Karnataka';
        acc.BillingCity   = 'Bengaluru';
        acc.BillingCountry= 'India';
        acc.BillingPostalCode = '560087';
        update acc;
        
        ARTL_Pincode__c pincode = new ARTL_Pincode__c ();
        pincode.Name 				= '560087';
        pincode.ARTL_City__c  		= 'Bengaluru';
        pincode.ARTL_State__c  		= 'Karnataka';
        pincode.ARTL_Country__c 	= 'India';
        insert pincode;
    }
    
    @IsTest
    static void testFindAccountDuplicate(){
        Test.startTest();
        List<Account> accList = ARTL_TestDataFactory.createAccount('Business',false,1);
        String pincodeId = [SELECT Id from ARTL_Pincode__c LIMIT 1]?.Id;
        Account acc = [Select Id,Name from Account LIMIT 1];
        Map<String,Object> input = new Map<String,Object>();
        input.put('AccountName',acc.Name);
        Map<String,Object> accMap = new Map<String,Object>();
        accMap.put('Phone','8976054321');
        accMap.put('TApincode-Block',new Map<String,Object>{'pincodeId'=>pincodeId,'street'=>'Test Street','city'=> 'Bengaluru','country'=>'India','state'=>'Karnataka','pincode'=>'560087'});
        input.put('AccountDetails',accMap);
        ARTL_FindDuplicate obj = new ARTL_FindDuplicate();
        obj.invokeMethod('findAccountDuplicate',input, new Map<String,Object>(),new Map<String,Object>());
        obj.invokeMethod('insertAccount',input, new Map<String,Object>(),new Map<String,Object>());
        Test.stopTest();
    }
    
    @IsTest
    static void testInsertLead(){
        Test.startTest();
        Map<String,Object> input = new Map<String,Object>();
        Map<String,Object> leadMap = new Map<String,Object>();
        leadMap.put('FirstName','Test');
        leadMap.put('LastName', 'Lead');
        leadMap.put('Salutation', 'Ms.');
        leadMap.put('Company', 'Test');
        leadMap.put('Phone', '9087654321');
        leadMap.put('ARC', '12345');
        leadMap.put('Description', '12345');
        input.put('LeadCreation',leadMap);
        ARTL_FindDuplicate obj = new ARTL_FindDuplicate();
        obj.invokeMethod('insertLead',input,new Map<String,Object>(),new Map<String,Object>());
        Test.stopTest();
    }
    
    @IsTest
    static void testCheckEditAccess(){
		Test.startTest(); 
        String accId = [SELECT Id from Account LIMIT 1]?.Id;
        ARTL_FindDuplicate obj = new ARTL_FindDuplicate();
        Map<String,Object> input = new Map<String,Object>();
        input.put('ContextId',accId);
        obj.invokeMethod('checkEditAccess',input,new Map<String,Object>(),new Map<String,Object>());
        Test.stopTest();
    }
}