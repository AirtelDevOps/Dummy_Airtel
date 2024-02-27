/***********************************************************************************************************************************
 * @Author       : Aliya Ameer 
 * @Date         : 25/10/2023
 * @Description  : Test class for GenerateXMLForMACD class
 ***********************************************************************************************************************************/
@isTest
public class GenerateXMLForMACDTest {
    
    @isTest
    static void testGenerateXML() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product CFS',
            ProductCode = 'TEST_PROD',
            ARTL_Hansen_Primary_Key__c = '1234',
            IsActive = true
        );
        insert testProduct;
        
        Product2 testProduct2 = new Product2(
            Name = 'Bandwidth OTC CFS',
            ProductCode = 'TEST_PROD_2',
            ARTL_Hansen_Primary_Key__c = '4567',
            IsActive = true
        );
        insert testProduct2;
        
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert testPricebookEntry;
        
        PricebookEntry testPricebookEntry2 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct2.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert testPricebookEntry2;
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert testOrder;
        
        OrderItem testOrderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = testPricebookEntry.Id,
            Quantity = 1,
            UnitPrice = 10,
            vlocity_cmt__BillingAccountId__c = testAccount.Id
        );
        insert testOrderItem;
        
        vlocity_cmt__FulfilmentRequest__c testFR = new vlocity_cmt__FulfilmentRequest__c(
            vlocity_cmt__OrderId__c =testOrder.Id, 
            vlocity_cmt__AccountId__c = testAccount.Id
        );
        insert testFR;
        
        vlocity_cmt__FulfilmentRequestLine__c testFRL1 = new vlocity_cmt__FulfilmentRequestLine__c(
            vlocity_cmt__Product2Id__c = testProduct.Id,
            ARTL_Updated_Attributes__c = '{"ATT_Rate_Revision": "SampleValue"}',
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_Rate_Revision": "SampleValue","ATT_PRIMARY_KEY":"0000-1111"}',
            vlocity_cmt__FulfilmentRequestID__c = testFR.Id,
            vlocity_cmt__Action__c = 'Modify'
        );
        insert testFRL1;
        testFRL1.vlocity_cmt__LineNumber__c = testFRL1.Id +'.0001';
        update testFRL1;
        
        vlocity_cmt__FulfilmentRequestLine__c testFRL2 = new vlocity_cmt__FulfilmentRequestLine__c(
            vlocity_cmt__Product2Id__c = testProduct2.Id,
            ARTL_Updated_Attributes__c = '{"ATT_Rate_Revision": "SampleValue"}',
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_Rate_Revision": "SampleValue","ATT_PRIMARY_KEY":"0000-1111"}',
            vlocity_cmt__FulfilmentRequestID__c = testFR.Id,
            vlocity_cmt__LineNumber__c = testFRL1.vlocity_cmt__LineNumber__c +'.0001',
            vlocity_cmt__Action__c = 'Add'
        );
        insert testFRL2;
        
        Test.startTest();
        GenerateXMLForMACD generatedXml = new GenerateXMLForMACD();
        generatedXml.generateXML(testOrderItem.Id);
        System.assertNotEquals(null, generatedXml, 'Generated XML should not be null');
        Test.stopTest();
    }
}