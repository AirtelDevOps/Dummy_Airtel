@isTest
public class ARTL_BillingStaging_DwnldUpld_Test {

    @isTest
    static void testInsertNupsertCSVToBillingStaging() {
        // Test data
        String inputCSV = '[{"BillingStagingBillingStagingName": "TestName", "ShippingPinCode": "12345", "ShippingState": "CA", "ShippingStreet": "Test Street"}]';
        
        // Call the method
        String result = ARTL_BillingStaging_DwnldUpld.insertNupsertCSVToBillingStaging(inputCSV);

       
    }

    @isTest
    static void testSplitDataToInsertNUpdate() {
        // Test data
        List<Object> inputCSVList = new List<Object>{
            '{"BillingStagingBillingStagingName": "TestName", "ShippingPinCode": "12345", "ShippingState": "CA", "ShippingStreet": "Test Street"}',
            '{"BillingStagingBillingStagingName": "", "ShippingPinCode": "54321", "ShippingState": "NY", "ShippingStreet": "Another Street"}'
        };

        // Call the method
        Map<String, List<Object>> splitData = ARTL_BillingStaging_DwnldUpld.splitDataToInsertNUpdate(inputCSVList);

        
    }

    @isTest
    static void testInsertDmlOp() {
        List<Object> insertObj = new List<Object>{
            (Map<String, Object>) JSON.deserializeUntyped('{"BillingStagingBillingStagingName": "TestName","POTerms(Years)":"2", "ShippingPinCode": "12345","POAmount": "150", "ShippingState": "CA", "ShippingStreet": "Test Street", "POStartDate": "15/01/2022"}')
        };

        // Call the method
        String result = ARTL_BillingStaging_DwnldUpld.insertDmlOp(insertObj);

        
    }

   /* @isTest
    static void testUpdateDmlOp() {
        // Test data
        List<Object> updateObj = new List<Object>{
            (Map<String, Object>) JSON.deserializeUntyped('{"BillingStagingBillingStagingName": "TestName", "ShippingPinCode": "12345","POTerms(Years)":"2","POAmount": "150", "ShippingState": "CA", "ShippingStreet": "Test Street", "POStartDate": "15/01/2022"}')
        };
        // Call the method
        String result = ARTL_BillingStaging_DwnldUpld.updateDmlOp(updateObj);

        
    }*/

    @isTest
    static void testConvertObjListTosObjList() {
        // Test data
        List<Object> validInputData = new List<Object>{
            (Map<String, Object>) JSON.deserializeUntyped('{"BillingStagingBillingStagingName": "TestName","POTerms(Years)":"2", "ShippingPinCode": "12345","POAmount": "150", "ShippingState": "CA", "ShippingStreet": "Test Street", "POStartDate": "15-01-2022"}')
        };

        Test.startTest();
        List<ARTL_Billing_Staging__c> result = ARTL_BillingStaging_DwnldUpld.convertObjListTosObjList(validInputData);
        Test.stopTest();

        
    }
    /*@isTest
    static void testGetBillingStagingRec() {
        // Test the getBillingStagingRec method

        // Set up user
        User testUser = ARTL_BillingStaging_DwnldUpldUtility.getUser();

        // Set up Opportunity, Account, PriceList, Product, and QuoteLineItem
        String opportunityId = ARTL_BillingStaging_DwnldUpldUtility.getOpportunityId();
        String accountId = ARTL_BillingStaging_DwnldUpldUtility.getAccountId();
        String priceListId = ARTL_BillingStaging_DwnldUpldUtility.getPriceListId();
        String productId = ARTL_BillingStaging_DwnldUpldUtility.getProductId();
        String quoteLineItemId = ARTL_BillingStaging_DwnldUpldUtility.getQLIId();

        // Test the getBillingStagingRec method
        Test.startTest();
        String billingStagingRec = ARTL_BillingStaging_DwnldUpldUtility.getBillingStagingRec();
        Test.stopTest();

        // Add your assertions based on the expected result of the method
        //System.assertNotEquals(null, billingStagingRec);
        // Add more assertions as needed
    }*/
    
     
}