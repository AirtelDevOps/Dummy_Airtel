@isTest
public class QuoteTriggerHelperTest {
    
    @testSetup
    static void dataCreation() {
        Account acc = ARTL_TestDataFactory.createAccount('Business', false, 1)[0];
        //Account acc = new Account(Name = 'Test Account');
        acc.Name = 'Test Account';
        insert acc; 
        
        Product2 prod = new Product2(Name = 'Test product1', family = 'Internet',ProductCode='XYZ_1', ARTL_LSIRequired__c=true);
        insert prod;
        system.debug('product=>'+prod);
        // Create a Pricebook
        
        // Create a Pricebook Entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100.00, // Set the unit price as needed
            IsActive = true
        );
        insert pbEntry;
        system.debug('pbEntry=>'+pbEntry);
        
        vlocity_cmt__PriceList__c priceList = new 	vlocity_cmt__PriceList__c();
        priceList.Name ='Pricelist For Test class';
        priceList.vlocity_cmt__Code__c='PricelistForTestclass';
        priceList.vlocity_cmt__Pricebook2Id__c =Test.getStandardPricebookId();
        insert priceList;
        system.debug('priceList=>'+priceList);
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        insert opp;
        system.debug('opp=>'+opp);
        
        Quote q = new Quote();
        q.OpportunityId = opp.Id;
        q.Name = 'Quote Test';
        q.vlocity_cmt__PriceListId__c=priceList.Id;
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.Status ='CUSTOMER_SIGNED';
        q.vlocity_cmt__Type__c = 'New';
        q.ARTL_QNeedCapexApproval__c=True;
        q.vlocity_cmt__ValidationStatus__c = 'Billing Sync Successful';
        insert q;
        system.debug('q=>'+q);
        
        
        QuoteLineItem qli = new QuoteLineItem(
            Product2Id = prod.Id,
            QuoteId = q.Id,
            PricebookEntryId = pbEntry.Id,
            UnitPrice = pbEntry.UnitPrice,
            Quantity=1,
            Capex__c=10000,
            Annual_Recurring_Charge__c=500000 
        );
        insert qli;
        system.debug('qli=>'+qli);
        
        system.debug('start invokeCapexApprovalTest');
        CalculationMatrix capexMatrix = new CalculationMatrix(
            Name = 'Capex Matrix test',
            Type = 'Standard'
        );
        system.debug('invokeCapexApprovalTest CalculationMatrix created'+capexMatrix);
        
        insert capexMatrix;
        CalculationMatrixColumn inputColumn = new CalculationMatrixColumn(
            CalculationMatrixId = capexMatrix.Id,
            Name = 'ProductCode',
            ColumnType = 'Input',
            DataType = 'Text'
        );
        insert inputColumn;
        system.debug('invokeCapexApprovalTest inputColumn created'+inputColumn);
        
        CalculationMatrixColumn outputColumn = new CalculationMatrixColumn(
            CalculationMatrixId = capexMatrix.Id,
            Name = 'ApproverName',
            ColumnType = 'Output',
            DataType = 'Text'
        );
        insert outputColumn;
        system.debug('invokeCapexApprovalTest outputColumn created'+outputColumn);
        
        // Create a Calculation Matrix Version
        CalculationMatrixVersion capexMatrixv1 = new CalculationMatrixVersion(
            Name = 'Capex Matrix Version',
            CalculationMatrixId = capexMatrix.Id
        );
        insert capexMatrixv1;
        system.debug('invokeCapexApprovalTest capexMatrixv1 created'+capexMatrixv1);
        
        // Create Calculation Matrix Columns (Input and Output)
        
        // Create Calculation Matrix Rows
        CalculationMatrixRow capexMatrixRecords1 = new CalculationMatrixRow(
            CalculationMatrixVersionId = capexMatrixv1.Id,
            InputData = '{"InputColumn": "VEPC_E_IIL"}',
            OutputData = '{"OutputColumn": "Shishir Bansal"}'
        );
        insert capexMatrixRecords1;
        system.debug('invokeCapexApprovalTest capexMatrixRecords1 created'+capexMatrixRecords1);
        
        CalculationMatrixRow capexMatrixRecords2 = new CalculationMatrixRow(
            CalculationMatrixVersionId = capexMatrixv1.Id,
            InputData = '{  "ProductCode": "VEPC_ACCESS_LAST_MILE"}',
            OutputData = '{  "ApproverName": "Prakash Sahu"}'
        );
        insert capexMatrixRecords2;
        system.debug('invokeCapexApprovalTest capexMatrixRecords2 created'+capexMatrixRecords2);
        
        CalculationMatrixRow capexMatrixRecords3 = new CalculationMatrixRow(
            CalculationMatrixVersionId = capexMatrixv1.Id,
            InputData = '{  "ProductCode": "VEPC_ICONNECTIVITY_ROUTING_TYPE"}',
            OutputData = '{  "ApproverName": "Vishnu Pankaj"}'
        );
        insert capexMatrixRecords3;
        system.debug('invokeCapexApprovalTest capexMatrixRecords3 created'+capexMatrixRecords3);
        
        CalculationMatrixRow capexMatrixRecords4 = new CalculationMatrixRow(
            CalculationMatrixVersionId = capexMatrixv1.Id,
            InputData = '{  "ProductCode": "VEPC_PRIMARY_LINK"}',
            OutputData = '{  "ApproverName": "Sujay Dey"}'
        );
        insert capexMatrixRecords4;
    }
    //cover LSI generation part
    //
    //saurav
    @isTest
    static void generateLSINumbers() {
        Test.startTest();
        List<Quote> qList=[select id, name, AccountId, Status from Quote];
        system.debug('quote list'+qList);
        for (Quote q : qList) {
            q.put('Status', 'Proposal Sent');
        }
        update qList;
        
        List<Quote> qList2=[select id, name, AccountId, Status from Quote];
        for (Quote q : qList2) {
            System.assertEquals('Proposal Sent', q.Status);
        }
        Test.stopTest();
    }
    //Generate sub-orders and master order
    @isTest
    static void generateSubMasterOrders() {
        Test.startTest();
        List<Quote> qList=[select id, name, AccountId, Status,vlocity_cmt__ValidationStatus__c from Quote];
        system.debug('quote list'+qList);
        for (Quote q : qList) {
            q.put('vlocity_cmt__ValidationStatus__c', 'Billing Sync Successful');
        }
        update qList;
        
        List<Quote> qList2=[select id, name, AccountId, Status,vlocity_cmt__ValidationStatus__c from Quote];
        for (Quote q : qList2) {
            System.assertEquals('Billing Sync Successful', q.vlocity_cmt__ValidationStatus__c);
        }
        Test.stopTest();
    }
    
    @isTest
    static void invokeCapexApprovalTest() {
        Test.startTest();
        
        List<Quote> qList=[select id, name, AccountId, Status,ARTL_DOAApproved__c , ARTL_OV_Assigned_Date__c ,vlocity_cmt__ValidationStatus__c from Quote];
        system.debug('quote list'+qList);
        for (Quote q : qList) {
            q.put('ARTL_DOAApproved__c', True);
            q.put('status' , 'Assigned to OV');
            q.put('vlocity_cmt__ValidationStatus__c' , 'Ready for Order');
        }
        update qList;
        
        Test.stopTest();
    }
    //fetchMatrixRecords
    @isTest
    static void fetchMatrixRecordsTest() {
        Test.startTest();
        
        Map<String,String> matrixRecords=QuoteTriggerHelper.fetchMatrixRecords('Capex Matrix Version');
        System.assertNotEquals(matrixRecords, null);
        Test.stopTest();
    }
    
    @isTest
    static void createBASABatchTest(){
        Set<Id> quoteIdSet = new Set<Id>();
        User usr = ARTL_ValidateStagingDataHelper.getUser();
        quoteIdSet = ARTL_ValidateStagingDataHelper.getQuoteIdSet();
        System.runAs(usr){
            Test.startTest();
           		QuoteTriggerHelper.createBASABatch(quoteIdSet);
            Test.stopTest();
        }
    }
    static testMethod void sendCustomNotificationTestDOARejected(){
        
        List<Quote> qList=[select id, name, AccountId, Status,ARTL_DOAApproved__c , OwnerId, ARTL_OV_Assigned_Date__c ,vlocity_cmt__ValidationStatus__c from Quote];
        qList[0].Status = 'DOA Rejected';
        update qlist;
        QuoteTriggerHelper.sendCustomNotification(qList);
    }
    
    static testMethod void testOVApproved(){
        
        List<Quote> qList=[select id, name, AccountId, Status,ARTL_DOAApproved__c , OwnerId, ARTL_OV_Assigned_Date__c ,vlocity_cmt__ValidationStatus__c from Quote];
        qList[0].Status = 'OV Approved';
        update qlist;
        QuoteTriggerHelper.sendCustomNotification(qList);
    }
    
    static testMethod void testOVRejected(){
        
        List<Quote> qList=[select id, name, AccountId, Status,ARTL_DOAApproved__c , OwnerId, ARTL_OV_Assigned_Date__c ,vlocity_cmt__ValidationStatus__c from Quote];
        qList[0].Status = 'OV Rejected';
        update qlist;
        QuoteTriggerHelper.sendCustomNotification(qList);
    }
}