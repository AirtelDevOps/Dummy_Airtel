@IsTest
public class TriggerHandlerTest extends TriggerHandler{
    //start
    private static final String BUSINESS = 'Business';
    private static final String AT_WORK_D_Series_ADL = 'At Work D-Series ADSL2+ 200GB';
    private static final String AT_WORK_D_Series_ADL_UNLIMITED = 'At Work D-Series ADSL2+ Unlimited';
    private static final String INITIAL_STAGE = 'Initial';
    private static final String NOT_FEASIBLE = 'Not Feasible';
    private static final Id standardBookId =  Test.getStandardPricebookId();
   
    
    @testSetup
    static void setupTestData() {
        //List<Account> testAccounts = ARTL_TestDataFactory.createAccount(BUSINESS, true, 1);
        
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
                                              ARTL_PAN__c = 'ABCDE1234F'
                                              );
        insert businessAccount;
        
        Set<String> productNames = new Set<String>{AT_WORK_D_Series_ADL, AT_WORK_D_Series_ADL_UNLIMITED};
        Set<String> productCodes = new Set<String>{AT_WORK_D_Series_ADL,AT_WORK_D_Series_ADL_UNLIMITED};
        List<Product2> testProducts = ARTL_TestDataFactory.createProduct(productNames,productCodes, true, 2);
        Map<Id, Product2> productMap = new Map<Id, Product2>(testProducts);
        Set<Id> productIds = new Set<Id>(productMap.KeySet());
        List<PriceBookEntry> testPriceBookEntries = ARTL_TestDataFactory.createPricebookEntry(productIds, standardBookId, true, 2);
        List<vlocity_cmt__PriceList__c> testVlocityPLs = ARTL_TestDataFactory.createVlocityPriceList(standardBookId, true, 1);
        List<Opportunity> testopportunities = ARTL_TestDataFactory.createOpportunity(new Set<Id>{businessAccount.Id},INITIAL_STAGE, testVlocityPLs[0].Id, true, 1);
        List<Quote> testQuotes = ARTL_TestDataFactory.createQuote(testopportunities[0].Id, testVlocityPLs[0].Id, standardBookId, true, 1);
        ARTL_Pincode__c pc= new ARTL_Pincode__c(Name='110031',
                                               ARTL_City__c='New Delhi',
                                                ARTL_State__c='Delhi',
                                                ARTL_Country__c='India'
                                               );
        insert pc;
    }
    //end
	@isTest
    static void testIntegrationMethod() {
    	Test.startTest();
     
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Account testAccount1 = new Account(Name = 'Test Accountabc');
        insert testAccount1;
        delete testAccount1;
        
        //testAccount.Name = 'Test Accountxyz';
        //update testAccount;
        
        
        TriggerHandler trggrHanler = new TriggerHandler();
       	trggrHanler.setTriggerContext('before insert', true);
        trggrHanler.setTriggerContext('before update', true);
        trggrHanler.setTriggerContext('before delete', true);
        trggrHanler.setTriggerContext('after insert', true);
        trggrHanler.setTriggerContext('after update', true);
        trggrHanler.setTriggerContext('after delete', true);
        trggrHanler.setTriggerContext('after undelete', true);
        
        trggrHanler.addToLoopCount();
        
        
        TriggerHandler.LoopCount lpCnt = new TriggerHandler.LoopCount();
        TriggerHandler.LoopCount lpCnt1 = new TriggerHandler.LoopCount(10);
        lpCnt.increment();
        lpCnt.exceeded();
        lpCnt.getMax();
        lpCnt.getCount();
        lpCnt.setMax(7);
        trggrHanler.setMaxLoopCount(10);
        trggrHanler.clearMaxLoopCount();
        
        TriggerHandler.bypass('ARTL_AccountTriggerHandler');
        TriggerHandler.isBypassed('ARTL_AccountTriggerHandler');
        TriggerHandler.clearBypass('ARTL_AccountTriggerHandler');
        TriggerHandler.clearAllBypasses();
       /* 
       public override void beforeInsert() {
       		System.debug('test class');
    	}
   		protected override void afterInsert() {
       
    	}
    	protected override void afterupdate() {
        
    	}*/
        
        
        
        
 		Test.stopTest();
    }
    
     @isTest
    static void qmUpdateFeasilbilityErrorMarginTest(){
        List<Quote> quoteList=[SELECT Id FROM Quote LIMIT 1];
        Test.startTest();
        vlocity_cmt__QuoteMember__c testRecord = new vlocity_cmt__QuoteMember__c(vlocity_cmt__QuoteId__c = quoteList[0].Id,
                                                                                    Name = 'Test Quote Member',
                                                                                    Feasibility_Status__c  = NOT_FEASIBLE,
                                                                                vlocity_cmt__PostalCode__c='110031',
                                                                                 vlocity_cmt__City__c='New Delhi',
                                                                                 vlocity_cmt__State__c='Delhi',
                                                                                 ARTL_Feasibility_Error_Margin__c=30
                                                                                );
        insert testRecord;
        testRecord.vlocity_cmt__State__c='Kerala';
        testRecord.ARTL_Feasibility_Error_Margin__c=10;
        update testRecord;
        
    	Test.stopTest();

    }
}