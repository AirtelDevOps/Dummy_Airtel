@isTest
public with sharing class ARTL_AssetControllerTest {
    public ARTL_AssetControllerTest() {

    }
    @TestSetup
    static void setup(){
        Account acc = new Account(Name = 'Test Account',billingCity='pune',billingState = 'Maharastra', ARTL_Legal_Entity__c = 'NXTRA DATA LIMITED',artl_customer_segment__c = 'AB',
        artl_business_circle_region__c = 'NCR' , artl_vertical_segment__c= 'BFI' );
        Database.insert(acc);

        Opportunity oppRecNew = new Opportunity(Name = 'Opp Record', StageName = 'Initial', CloseDate = Date.Today(), Amount = 1200000, AccountId = acc.Id);
        Database.insert(oppRecNew);

        Quote quoteRecNew = new Quote(Name = 'Quote Record', OpportunityId = oppRecNew.Id);
        Database.insert(quoteRecNew);

        ARTL_Bulk_Upload_Iteration__c iterationRecNew = new ARTL_Bulk_Upload_Iteration__c( Name = 'Test Iteration Record New Opp Quote', Opportunity_Name__c = 'Test Opp Record', Opportunity_Stage__c = 'Initial',
        Opportunity_Close_Date__c = Date.Today(), Amount__c = 1200000, Quote_Name__c = 'Test Quote Record');
        Database.insert(iterationRecNew);

        ARTL_Bulk_Upload_Iteration__c iterationRecExisting = new ARTL_Bulk_Upload_Iteration__c( Name = 'Test Iteration Record Existing Opp Quote',
        Opportunity_Id__c = oppRecNew.Id, Quote_Id__c = quoteRecNew.Id);
        Database.insert(iterationRecExisting);

        Asset assetRec = new Asset(Name = 'Asset Rec Test', AccountId = acc.Id, ARTL_LSI__c = 12345678 );
        Database.insert(assetRec);
        Asset assetRec2 = new Asset(Name = 'Asset Rec Test 2', AccountId = acc.Id, ARTL_LSI__c = 12345679 );
        Database.insert(assetRec2);

        ARTL_Bulk_Upload_Staging__c stagingRecNew = new ARTL_Bulk_Upload_Staging__c(Name = 'Test Staging Rec new', ARTL_Bulk_Upload_Iteration__c = iterationRecNew.Id, Record_Id__c = String.ValueOf(assetRec.ARTL_LSI__c));
        Database.insert(stagingRecNew);

        ARTL_Bulk_Upload_Staging__c stagingRecExisting = new ARTL_Bulk_Upload_Staging__c(Name = 'Test Staging Rec existing', ARTL_Bulk_Upload_Iteration__c = iterationRecExisting.Id, Record_Id__c = String.ValueOf(assetRec.ARTL_LSI__c));
        Database.insert(stagingRecExisting);
  ARTL_Bulk_Upload_Staging__c stagingRecExisting2 = new ARTL_Bulk_Upload_Staging__c(Name = 'Test Staging Rec again', ARTL_Bulk_Upload_Iteration__c = iterationRecExisting.Id, Errors__c ='Uploading an mismatch asset', Record_Id__c = String.ValueOf(assetRec.ARTL_LSI__c));
        Database.insert(stagingRecExisting2);
    }

    @isTest
    public static void getAssetRecordsFromIterationIdNewTest () {
        ARTL_AssetController assetController = new ARTL_AssetController();
        Map<String, Object> inputs = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        List<ARTL_Bulk_Upload_Iteration__c> iterationRecNewList = [SELECT Id FROM ARTL_Bulk_Upload_Iteration__c WHERE Name = 'Test Iteration Record New Opp Quote' LIMIT 1];
        List<Account> accountList = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        inputs.put('iterationId',iterationRecNewList.get(0));
        inputs.put('contextId',accountList.get(0));
        Test.startTest();
        assetController.invokeMethod('BulkUploadValidationAndUpdation',inputs,output,options);
        Test.stopTest();
    }

    /* @isTest
    public static void getAssetRecordsFromIterationIdExistingTest () {
        ARTL_AssetController assetController = new ARTL_AssetController();
        Map<String, Object> inputs = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        List<ARTL_Bulk_Upload_Iteration__c> iterationRecNewList = [SELECT Id FROM ARTL_Bulk_Upload_Iteration__c WHERE Name = 'Test Iteration Record Existing Opp Quote' LIMIT 1];
        List<Account> accountList = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        inputs.put('iterationId',iterationRecNewList.get(0));
        inputs.put('contextId',accountList.get(0));
        Test.startTest();
        assetController.invokeMethod('BulkUploadValidationAndUpdation',inputs,output,options);
        Test.stopTest();
    }*/


    @isTest
    public static void createQuoteAndOpportunityExistingTest () {
        ARTL_AssetController assetController = new ARTL_AssetController();
        Map<String, Object> inputs = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        List<ARTL_Bulk_Upload_Iteration__c> iterationRecNewList = [SELECT Id, Opportunity_Name__c, Opportunity_Stage__c,Opportunity_Close_Date__c, 
        Quote_Name__c, Quote_Id__c,Opportunity_Id__c, Amount__c FROM ARTL_Bulk_Upload_Iteration__c WHERE Name = 'Test Iteration Record Existing Opp Quote' LIMIT 1];
        List<ARTL_Bulk_Upload_Staging__c> StagingValidatedList = [SELECT Id, Errors__c, ARTL_Bulk_Upload_Iteration__c, Record_Id__c FROM ARTL_Bulk_Upload_Staging__c WHERE Name = 'Test Staging Rec new' LIMIT 1];
        List<Asset> assetList = [SELECT Id, AccountId ,RootAssetId, vlocity_cmt__RootItemId__c, vlocity_cmt__ParentItemId__c, ARTL_LSI__c,
        vlocity_cmt__AssetReferenceId__c,  vlocity_cmt__LineNumber__c FROM Asset WHERE Name = 'Asset Rec Test' LIMIT 1];
        List<Id> rootAssetIds = new List<Id>();
        for(Asset assetRec : assetList) {
            rootAssetIds.add(assetRec.Id);
        }
        List<Account> accountList = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        inputs.put('accountId',accountList.get(0).Id);
        Test.startTest();
        ARTL_AssetController.createQuoteAndOpportunity(StagingValidatedList, iterationRecNewList.get(0), inputs, rootAssetIds);
        Test.stopTest();
    }

    @isTest
    public static void createQuoteAndOpportunityNewTest () {
        ARTL_AssetController assetController = new ARTL_AssetController();
        Map<String, Object> inputs = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        List<ARTL_Bulk_Upload_Iteration__c> iterationRecNewList = [SELECT Id, Opportunity_Name__c, Opportunity_Stage__c,Opportunity_Close_Date__c, 
        Quote_Name__c, Quote_Id__c,Opportunity_Id__c, Amount__c FROM ARTL_Bulk_Upload_Iteration__c WHERE Name = 'Test Iteration Record New Opp Quote' LIMIT 1];
        List<ARTL_Bulk_Upload_Staging__c> StagingValidatedList = [SELECT Id, Errors__c, ARTL_Bulk_Upload_Iteration__c, Record_Id__c FROM ARTL_Bulk_Upload_Staging__c WHERE Name = 'Test Staging Rec new' LIMIT 1];
        List<Asset> assetList = [SELECT Id, AccountId ,RootAssetId, vlocity_cmt__RootItemId__c, vlocity_cmt__ParentItemId__c, ARTL_LSI__c,
        vlocity_cmt__AssetReferenceId__c,  vlocity_cmt__LineNumber__c FROM Asset WHERE Name = 'Asset Rec Test' LIMIT 1];
        List<Id> rootAssetIds = new List<Id>();
        for(Asset assetRec : assetList) {
            rootAssetIds.add(assetRec.Id);
        }
        List<Account> accountList = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        inputs.put('accountId',accountList.get(0).Id);
        Test.startTest();
        ARTL_AssetController.createQuoteAndOpportunity(StagingValidatedList, iterationRecNewList.get(0), inputs, rootAssetIds);
        Test.stopTest();
    }
@isTest
    public static void InvokeAssetToQuoteAPITest () {
        ARTL_AssetController assetController = new ARTL_AssetController();
        Map<String, Object> inputs = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        Test.startTest();
        assetController.invokeMethod('invokeAssettoQuoteAPI',inputs,output,options);
        Test.stopTest();
    }
   @isTest
    public static void sendNotificationTest () {
        ARTL_AssetController assetController = new ARTL_AssetController();
        Map<String, Object> inputs = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        Test.startTest();
        assetController.invokeMethod('sendNotification',inputs,output,options);
        Test.stopTest();
    }
}