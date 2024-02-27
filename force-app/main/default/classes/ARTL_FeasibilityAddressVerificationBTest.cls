/******************************************************************************************************
* @Author:      Saurav Madhusoodanan TV  <smadhusoodanantv@salesforce.com >
* @Company:     Salesforce
* @Date:        21/12/2023
* @Reviewer:
* @Review Date:
* @Description: Test class for ARTL_FeasibilityAddressVerificationBatch
* ++++++++++++++++++++++ Changes Implemented / Modification Log ++++++++++++++++++++++++++++++++++++++
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 
*******************************************************************************************************/
@isTest
public class ARTL_FeasibilityAddressVerificationBTest {

    @isTest
    static void positiveTest() {
        // Get a user for test execution context
        User usr = ARTL_ValidateStagingDataHelper.getUser();

        // Run test as the specified user
        System.runAs(usr) {
            // Start test execution
            Test.startTest();

            // Create test data for Accounts, PriceLists, Opportunities, Quotes, QuoteGroups, PinCodes, Integration Details, and QuoteMembers
            List<Account> accountList = ARTL_TestDataFactory.createAccount('Business', true, 1);
            Set<Id> accountIdSet = new Set<Id>{accountList[0].Id};

            List<vlocity_cmt__PriceList__c> vlocityPriceList = ARTL_TestDataFactory.createVlocityPriceList(Test.getStandardPricebookId(), true, 1);

            List<Opportunity> opportunityList = ARTL_TestDataFactory.createOpportunity(accountIdSet, 'Prospecting', vlocityPriceList[0].Id, true, 1);

            List<Quote> quoteList = ARTL_TestDataFactory.createQuote(opportunityList[0].Id, vlocityPriceList[0].Id, Test.getStandardPricebookId(), true, 1);

            vlocity_cmt__QuoteGroup__c testGroup = new vlocity_cmt__QuoteGroup__c(Name = 'Test Group', vlocity_cmt__QuoteId__c = quoteList[0].Id, vlocity_cmt__ExpectedMemberCount__c = 4);
            insert testGroup;

            ARTL_Pincode__c pinCodeRecord = new ARTL_Pincode__c(Name = '110031', ARTL_City__c = 'New Delhi', ARTL_State__c = 'Delhi', ARTL_State_Code__c = '7', ARTL_Country__c = 'India');
            insert pinCodeRecord;

            ARTL_Integration_Details__c integrationDetails = new ARTL_Integration_Details__c(
                Name = 'AddressVerification',
                ARTL_Endpoint__c = 'https://b2benterprisebusiness.airtel.com/b2b-oft/feasibility/map/address',
                ARTL_API_Key__c = 'YWZjMWM0NTgtN2JiMi01ZWYzLThjNzMtZTBkMDEyNTA4ODQz'
            );
            insert integrationDetails;

            ARTL_TestDataFactory.createQuoteMembers2(quoteList[0].Id, 'Durant Avenue', testGroup.Id, 3, 'Location');

            // Create a mock HTTP response with sample data
            HttpMockFactory mock = new HttpMockFactory(
                200,
                'Success',
                '{"requestId":"10192781055999244191703129660372","data":{"address":{"id":"TPT1027600654-2113830758TPT_GIS","originalAddressString":"Mumbai,India","addressString":"barca zindia house, parel, mumbai","locality":"parel","sublocality":"barca zindia house","state":"maharashtra","city":"Mumbai","pincode":"400012","latitude":"18.996425","longitude":"72.840438","highRise":false,"errorMargin":"50","source":"GIS","pinCode":"400012"}}}'
            );

            // Set up the mock HTTP callout
            Test.setMock(HttpCalloutMock.class, mock);

            // Execute the batch job and get the batch process ID
            String batchProcessId = Database.executeBatch(new ARTL_FeasibilityAddressVerificationBatch(quoteList[0].Id));

            // Assert that the batch process ID is not null, indicating a successful execution
            System.assertNotEquals(null, batchProcessId);

            // Stop test execution
            Test.stopTest();
        }
    }
}