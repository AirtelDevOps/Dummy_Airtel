@isTest
public class ARTL_UpdateAttributesOnFRLTest {
    
    @isTest
    static void testUpdateAttributes() {
        
        String LSI = '800186756234';
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product CFS',
            ProductCode = 'TEST_PROD',
            ARTL_Hansen_Primary_Key__c = '1234',
            IsActive = true
        );
        insert testProduct;
        
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert testPricebookEntry;
        
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
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_PRIMARY_KEY":"","ATT_Rate_Revision": "SampleValue"}',
            vlocity_cmt__FulfilmentRequestID__c = testFR.Id,
            vlocity_cmt__Action__c = 'Add'
        );
        testFRL1.vlocity_cmt__LineNumber__c = testFRL1.Id +'.0001';
        insert testFRL1;
        
        Map<String, Object> input=new Map<String, Object>();
        Map<String, Object> output=new Map<String, Object>();
        Map<String, Object> options=new Map<String, Object>();
        
        input.put('FRLId',testFRL1.Id);
        input.put('LSI',LSI);
        string methodName='updateAttributes';
        ARTL_UpdateAttributesOnFRL updateObj = new ARTL_UpdateAttributesOnFRL();
        Test.startTest();
        updateObj.invokeMethod(methodName, input, output, options);
        Test.stopTest();
    }
}