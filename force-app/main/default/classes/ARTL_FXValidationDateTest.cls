@isTest
public class ARTL_FXValidationDateTest {
@testSetup
public static void makeData(){
    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
    Account acc = new Account(Name = 'Test Account',ARTL_Business_Circle_Region__c='NCR',
                              BillingCity = 'Panchkula',BillingCountry = 'Haryana',BillingPostalCode = '134109',BillingState = 'India',BillingStreet = 'Panchkula',
                              ARTL_IntegrationId__c = 'test',ARTL_Category__c = 'A',ARTL_PAN__c = 'ABCDE1234F',
                              RecordTypeId = recordTypeId, ARTL_Customer_Segment__c ='AB', ARTL_Vertical_Segment__c ='BFI',
                              ARTL_Service_Segment__c ='Bharti');
        insert acc; 
        vlocity_cmt__PriceList__c priceList = new 	vlocity_cmt__PriceList__c();
        priceList.Name ='Pricelist For Test class';
        priceList.vlocity_cmt__Code__c='PricelistForTestclass';
        priceList.vlocity_cmt__Pricebook2Id__c =Test.getStandardPricebookId();
        insert priceList; 

    Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;

    Quote q = new Quote();
    q.OpportunityId = opp.Id;
    q.Name = 'Quote Test';
    q.vlocity_cmt__PriceListId__c=priceList.Id;
    q.Pricebook2Id = Test.getStandardPricebookId();
    q.Status ='Draft';
    insert q;
}
@isTest
 public static void invokeMethodTest(){
    ARTL_FXValidationDate obj =new ARTL_FXValidationDate();
    obj.invokeMethod('ARTL_FXValidation', null, null, null);
 }
 @isTest
 public static void ARTL_FXValidationDateIPTest(){
    List<ARTL_Callout_Event_Configs__mdt>  Callout_Event_Configs = [SELECT MasterLabel, ARTL_Type__c, ARTL_EndPointURL__c,ARTL_IntegrationProcedureName__c,
                             ARTL_NameCredentials__c,ARTL_Operation__c,ARTL_Pattern__c,ARTL_Retry__c,ARTL_API_Key__c
                             FROM ARTL_Callout_Event_Configs__mdt];
    Map<String,Object> newMap = new Map<String,Object>();
    List<Quote> quoteList = [Select Id from Quote];
    Map<String,Object> input = new Map<String,Object>{
        'processName' => 'FXValidate',
        'endpoint' => 'Test',
        'namedCredentials' => 'Test',
        'apiKey' => 'Test',
        'quoteId' => quoteList[0].Id
    };
    ARTL_FXValidationDate.ARTL_FXValidationDateIP(input,newMap,newMap);
 }
 @isTest
 public static void fetchConfigDetailsTest(){
    List<ARTL_Callout_Event_Configs__mdt>  Callout_Event_Configs = [SELECT MasterLabel, ARTL_Type__c, ARTL_EndPointURL__c,ARTL_IntegrationProcedureName__c,
    ARTL_NameCredentials__c,ARTL_Operation__c,ARTL_Pattern__c,ARTL_Retry__c,ARTL_API_Key__c
    FROM ARTL_Callout_Event_Configs__mdt];
        ARTL_FXValidationDate.fetchConfigDetails('FXValidateAPI');
 }
 @isTest
 public static void parseJsonTest(){
    String JSONstring = '{"getCustomerPlanOldNewMappingResMsg":{"ebmHeader":{"consumerTransactionId":null},"dataArea":{"getCustomerPlanOldNewMapping":{"customerOrder":{"customerOrderItem":[{"product":{"description":null,"productStatus":"1","productSerialNumber":null,"productConfiguration":[{"productConfigSpec":{"value":"NA","name":"DISC_OVERRIDE"}}],"productLine":{"type":"Component"},"externalIdentification":[{"id":"68884","name":"LegacyCompInstId"},{"id":"3","name":"LegacyCompInstIdServ"},{"id":"28158","name":"LegacyCompId"},{"id":"2909","name":"LegacyPkgId"},{"id":"195843","name":"ParentAccountNumber"},{"id":"22420","name":"ParentSubscriberNumber"},{"id":"0","name":"ParentSubscriberNumberResets"},{"id":"1","name":"ConnectReason"},{"id":"desc","name":"Property1"},{"id":"Nxtra DC Colocation","name":"Property2"},{"id":"DC Space","name":"Property3"},{"id":"2023-04-11T18:01:41.000+05:30","name":"ServiceActiveDate"}]},"effectiveStartDate":"2023-04-11T18:01:41.000+05:30","effectiveEndDate":null},{"product":{"productLine":{"type":"Package"},"externalIdentification":[{"id":"20892","name":"LegacyPkgInstId"},{"id":"3","name":"LegacyPkgInstIdServ"},{"id":"2909","name":"LegacyPkgId"}]}}]},"status":{"statusCode":"GetCustomerPlanOldNewMapping-0000-S","statusDescription":"Request Processed Successfully"}}}}}';
    Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(JSONstring);
    ARTL_FXValidationDate.parseJson(resultMap);
 }
 @istest
 public static void FXValidationDateIPTestmethod(){
    try{
    ARTL_FXValidationDate.FXValidationDateIP(null,null,null);
     }catch(Exception e){

     }
 }
 @isTest
 public static void IntegrationProcedureQueueableTest(){
    try{
    Map<String,Object> ipInput = new Map<String,Object>{
        'LSI' =>'1234567'
    };
    Test.startTest();
    ARTL_FXValidationDate.IntegrationProcedureQueueable ipq = new ARTL_FXValidationDate.IntegrationProcedureQueueable(null, null, null);
    System.enqueueJob(ipq);
    Test.stopTest();
}catch(Exception e){

}
 }
}