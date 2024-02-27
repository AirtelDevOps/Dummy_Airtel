@isTest
public class ARTL_GetSObjectDetailsTest {
    @testSetup
    public static void  ARTL_GetSObjectDetailsTestSetup(){
        Id BARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
        //Account acc = new Account(Name = 'Test Account',billingCity='pune',billingState = 'Maharastra', ARTL_Legal_Entity__c = 'NXTRA DATA LIMITED',artl_customer_segment__c = 'AB',
          //                        artl_business_circle_region__c = 'NCR' , artl_vertical_segment__c= 'BFI', RecordTypeId =BARecordTypeId );
          //                        ARTL_Business_Circle_Region__c='NCR',
          Account acc = new Account(Name = 'Test Account',BillingCity = 'Panchkula',BillingCountry = 'Haryana',BillingPostalCode = '134109',BillingState = 'India',BillingStreet = 'Panchkula',
                              ARTL_IntegrationId__c = 'test',ARTL_Category__c = 'A',ARTL_PAN__c = 'ABCDE1234F',
                              ARTL_Customer_Segment__c ='AB', ARTL_Vertical_Segment__c ='BFI',ARTL_Business_Circle_Region__c = 'AP',
                              ARTL_Service_Segment__c ='Bharti',ARTL_Legal_Entity__c = 'NXTRA DATA LIMITED',RecordTypeId =BARecordTypeId);
        insert acc; 
    }
    @isTest
    static void testGetDetails2(){
        Account acc = [Select Id from Account];
        Map<String, Object> RequestBodyMap = new Map<String,Object>{
                                'Id' => acc.Id,
                                'Status' => 'Success / Error',
                                'ErrorMessage' => 'Error Message'
                        };
    List<Map<String,Object>> RequestBodyMapList = new List<Map<String,Object>>{RequestBodyMap};
    Map<String,Object> requestMap = new Map<String,Object>{'RequestBody' => RequestBodyMapList};
    ARTL_GetSObjectDetails.GetDetails(requestMap, new Map<String,Object>(), new Map<String,Object>());
    }
    @isTest
    static void testGetDetails() {
        ARTL_GetSObjectDetails obj = new ARTL_GetSObjectDetails();
        obj.invokeMethod('GetDetails',null,null,null);
    }
}