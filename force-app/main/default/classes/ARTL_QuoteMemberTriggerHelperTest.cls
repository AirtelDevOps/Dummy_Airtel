@isTest
public class ARTL_QuoteMemberTriggerHelperTest {
    private static final String BUSINESS = 'Business';
    private static final String AT_WORK_D_Series_ADL = 'At Work D-Series ADSL2+ 200GB';
    private static final String AT_WORK_D_Series_ADL_UNLIMITED = 'At Work D-Series ADSL2+ Unlimited';
    private static final String INITIAL_STAGE = 'Initial';
    private static final String NOT_FEASIBLE = 'Not Feasible';
    private static final Id standardBookId =  Test.getStandardPricebookId();
 	@testSetup
    static void setupTestData() {
        List<Account> testAccounts = ARTL_TestDataFactory.createAccount(BUSINESS, true, 1);
        
        Set<String> productNames = new Set<String>{AT_WORK_D_Series_ADL, AT_WORK_D_Series_ADL_UNLIMITED};
        Set<String> productCodes = new Set<String>{AT_WORK_D_Series_ADL,AT_WORK_D_Series_ADL_UNLIMITED};
        List<Product2> testProducts = ARTL_TestDataFactory.createProduct(productNames,productCodes, true, 2);
        Map<Id, Product2> productMap = new Map<Id, Product2>(testProducts);
        Set<Id> productIds = new Set<Id>(productMap.KeySet());
        List<PriceBookEntry> testPriceBookEntries = ARTL_TestDataFactory.createPricebookEntry(productIds, standardBookId, true, 2);
        List<vlocity_cmt__PriceList__c> testVlocityPLs = ARTL_TestDataFactory.createVlocityPriceList(standardBookId, true, 1);
        List<Opportunity> testopportunities = ARTL_TestDataFactory.createOpportunity(new Set<Id>{testAccounts[0].Id},INITIAL_STAGE, testVlocityPLs[0].Id, true, 1);
        List<Quote> testQuotes = ARTL_TestDataFactory.createQuote(testopportunities[0].Id, testVlocityPLs[0].Id, standardBookId, true, 1);
        ARTL_Pincode__c pc= new ARTL_Pincode__c(Name='110031',
                                               ARTL_City__c='New Delhi',
                                                ARTL_State__c='Delhi',
                                                ARTL_Country__c='India'
                                               );
        insert pc;
    }
    @isTest
    static void qmInsertTest(){
        
        List<Quote> quoteList=[SELECT Id FROM Quote LIMIT 1];
        Test.startTest();
        vlocity_cmt__QuoteMember__c testRecord = new vlocity_cmt__QuoteMember__c(vlocity_cmt__QuoteId__c = quoteList[0].Id,
                                                                                    Name = 'Test Quote Member',
                                                                                    Feasibility_Status__c  = NOT_FEASIBLE,
                                                                                vlocity_cmt__PostalCode__c='110031',
                                                                                 vlocity_cmt__City__c='New Delhi',
                                                                                 vlocity_cmt__State__c='Delhi'
                                                                                );
        insert testRecord;
    	Test.stopTest();

    }
    @isTest
    static void qmUpdateTest1(){
        
        List<Quote> quoteList=[SELECT Id FROM Quote LIMIT 1];
        Test.startTest();
        vlocity_cmt__QuoteMember__c testRecord = new vlocity_cmt__QuoteMember__c(vlocity_cmt__QuoteId__c = quoteList[0].Id,
                                                                                    Name = 'Test Quote Member',
                                                                                    Feasibility_Status__c  = NOT_FEASIBLE,
                                                                                vlocity_cmt__PostalCode__c='110031',
                                                                                 vlocity_cmt__City__c='New Delhi',
                                                                                 vlocity_cmt__State__c='Delhi'
                                                                                );
        insert testRecord;
        testRecord.vlocity_cmt__PostalCode__c='120006';
        update testRecord;
        
    	Test.stopTest();

    }
    
    @isTest
    static void qmUpdateTest2(){
        
        List<Quote> quoteList=[SELECT Id FROM Quote LIMIT 1];
        Test.startTest();
        vlocity_cmt__QuoteMember__c testRecord = new vlocity_cmt__QuoteMember__c(vlocity_cmt__QuoteId__c = quoteList[0].Id,
                                                                                    Name = 'Test Quote Member',
                                                                                    Feasibility_Status__c  = NOT_FEASIBLE,
                                                                                vlocity_cmt__PostalCode__c='110031',
                                                                                 vlocity_cmt__City__c='New Delhi',
                                                                                 vlocity_cmt__State__c='Delhi'
                                                                                );
        insert testRecord;
        testRecord.vlocity_cmt__City__c='Mumbai';
        update testRecord;
        
    	Test.stopTest();

    }
    @isTest
    static void qmUpdateTest3(){
        
        List<Quote> quoteList=[SELECT Id FROM Quote LIMIT 1];
        Test.startTest();
        vlocity_cmt__QuoteMember__c testRecord = new vlocity_cmt__QuoteMember__c(vlocity_cmt__QuoteId__c = quoteList[0].Id,
                                                                                    Name = 'Test Quote Member',
                                                                                    Feasibility_Status__c  = NOT_FEASIBLE,
                                                                                vlocity_cmt__PostalCode__c='110031',
                                                                                 vlocity_cmt__City__c='New Delhi',
                                                                                 vlocity_cmt__State__c='Delhi'
                                                                                );
        insert testRecord;
        testRecord.vlocity_cmt__State__c='Kerala';
        update testRecord;
        
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