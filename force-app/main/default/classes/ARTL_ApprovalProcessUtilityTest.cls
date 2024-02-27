@isTest
public class ARTL_ApprovalProcessUtilityTest {
    
	@testSetup
    static void dataCreation() {
        Account acc = new Account(Name = 'Test Account');
        insert acc; 
        
        Product2 prod = new Product2(Name = 'Test product1', family = 'Internet',ProductCode='VEPC_PRIMARY_LINK', ARTL_LSIRequired__c=true);
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
        q.Status ='Draft';
        q.ARTL_QNeedCapexApproval__c=True;
        insert q;
        system.debug('q=>'+q);
        
        
        QuoteLineItem qli = new QuoteLineItem(
            Product2Id = prod.Id,
            QuoteId = q.Id,
            PricebookEntryId = pbEntry.Id,
            UnitPrice = pbEntry.UnitPrice,
            Quantity=1,
            Capex__c=10000,
            Annual_Recurring_Charge__c=25000,
            vlocity_cmt__OneTimeCharge__c=20000,
            ARTL_ARCFloorRate__c=50000,
            ARTL_NRCFloorRate__c=50000
        );
        insert qli;
        system.debug('qli=>'+qli);
        
        
        system.debug('start invokeCapexApprovalTest');
        CalculationMatrix dOAMatrix = new CalculationMatrix(
            Name = 'DOA Matrix test',
            Type = 'Standard'
        );
        system.debug('invokeCapexApprovalTest CalculationMatrix created'+dOAMatrix);
        
        insert dOAMatrix;
        
        CalculationMatrixColumn inputColumn1 = new CalculationMatrixColumn(
            CalculationMatrixId = dOAMatrix.Id,
            Name = 'ProductCode',
            ColumnType = 'Input',
            DataType = 'Text'
        );
        insert inputColumn1;
        system.debug('invokeCapexApprovalTest inputColumn created'+inputColumn1);
        
        CalculationMatrixColumn inputColumn2 = new CalculationMatrixColumn(
            CalculationMatrixId = dOAMatrix.Id,
            Name = 'PriceRange',
            ColumnType = 'Input',
            DataType = 'NumberRange',
            RangeValues='10000,20000,30000,40000,50000'
        );
        insert inputColumn2;
        system.debug('invokeCapexApprovalTest inputColumn created'+inputColumn2);
        
     
        
        CalculationMatrixColumn outputColumn1 = new CalculationMatrixColumn(
            CalculationMatrixId = dOAMatrix.Id,
            Name = 'Approver',
            ColumnType = 'Output',
            DataType = 'Text'
        );
        insert outputColumn1;
        system.debug('invokeCapexApprovalTest outputColumn created'+outputColumn1);
        
        CalculationMatrixColumn outputColumn2 = new CalculationMatrixColumn(
            CalculationMatrixId = dOAMatrix.Id,
            Name = 'Level',
            ColumnType = 'Output',
            DataType = 'Text'
        );
        insert outputColumn2;
        system.debug('invokeCapexApprovalTest outputColumn created'+outputColumn2);
        
        
        // Create a Calculation Matrix Version
        CalculationMatrixVersion doaMatrixv1 = new CalculationMatrixVersion(
            Name = 'DOA Matrix Test Version',
            CalculationMatrixId = dOAMatrix.Id
        );
        insert doaMatrixv1;
        system.debug('invokeCapexApprovalTest capexMatrixv1 created'+doaMatrixv1);
        
        
        CalculationMatrixRow doaRecord1=new CalculationMatrixRow();
        doaRecord1.CalculationMatrixVersionId=doaMatrixv1.Id;
        doaRecord1.InputData='{  "ProductCode": "VEPC_PRIMARY_LINK","PriceRange":"50000"}';
        doaRecord1.OutputData='{  "Approver": "none",  "Level": "1"}';
        insert doaRecord1;
        system.debug('invokeCapexApprovalTest doa matrix rec'+doaRecord1);
        
        
        // Create Calculation Matrix Columns (Input and Output)
        
        // Create Calculation Matrix Rows
        
        CalculationMatrixRow doaMatrixRecords2 = new CalculationMatrixRow(
            CalculationMatrixVersionId = doaMatrixv1.Id,
            InputData = '{"ProductCode": "VEPC_PRIMARY_LINK","PriceRange":"40000"}',
            OutputData = '{  "Approver": "none",  "Level": "2"}'
        );
        insert doaMatrixRecords2;
        system.debug('invokeCapexApprovalTest capexMatrixRecords2 created'+doaMatrixRecords2);
        
        CalculationMatrixRow doaMatrixRecords3 = new CalculationMatrixRow(
            CalculationMatrixVersionId = doaMatrixv1.Id,
            InputData = '{"ProductCode": "VEPC_PRIMARY_LINK","PriceRange":"30000"}',
            OutputData = '{  "Approver": "Shishir Bansal",  "Level": "3"}'
        );
        insert doaMatrixRecords3;
        system.debug('invokeCapexApprovalTest capexMatrixRecords3 created'+doaMatrixRecords3);
        
        CalculationMatrixRow doaMatrixRecords4 = new CalculationMatrixRow(
            CalculationMatrixVersionId = doaMatrixv1.Id,
            InputData = '{"ProductCode": "VEPC_PRIMARY_LINK",  "PriceRange":"20000"}',
            OutputData = '{  "Approver": "Sujay Dey",  "Level": "4"}'
        );
        insert doaMatrixRecords4;
        
        CalculationMatrixRow doaMatrixRecords5 = new CalculationMatrixRow(
            CalculationMatrixVersionId = doaMatrixv1.Id,
            InputData = '{"ProductCode": "VEPC_PRIMARY_LINK",  "PriceRange":"10000"}',
            OutputData = '{  "Approver": "Siddhartha Mitra",  "Level": "5"}'
        );
        insert doaMatrixRecords5;
        

    }
    
    
    @isTest
    static void constructProductCodeToApproverMapTest() {
        
        Test.startTest();
        String matrixVersionName='DOA Matrix Test Version';
        List<CalculationMatrixVersion> matrixVersionRec=[SELECT Id FROM CalculationMatrixVersion WHERE name=:matrixVersionName LIMIT 1];
        
        List<CalculationMatrixRow> matrixRecords = [SELECT Id, InputData, OutputData FROM CalculationMatrixRow WHERE calculationMatrixVersionId=: matrixVersionRec[0].Id];
		Map<String,Map<Double,String>> productCodeToApproverMap=ARTL_ApprovalProcessUtility.constructProductCodeToApproverMap(matrixRecords);	
        
		System.assertNotEquals(matrixRecords, null);
        Test.stopTest();
        
    }

 
        
    
    
    @isTest
    static void invokeApprovalProcessTest() {
        Test.startTest();
        
        
        
        User testUser1 = new User(
            FirstName = 'Test1test',
            LastName = 'User1test',
            Alias = 'tusetest',
            Email = 'testuser1test@example.com',
            Username = 'testuser1test@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser1;
        system.debug('testUser1=>'+testUser1);
        User testUser2 = new User(
            FirstName = 'Test2test',
            LastName = 'User2test',
            Alias = 'tuserest',
            Email = 'testuser2test@example.com',
            Username = 'testuser2test@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser2;
        system.debug('testUser2=>'+testUser2);
        
        List<Quote> q=[SELECT Id FROM Quote LIMIT 1];
        system.debug('quote'+q);
        Id quoteId=q[0].Id;
		ARTL_ApprovalProcessUtility.invokeApprovalProcess(quoteId,'testing',testUser1.Id,testUser2.Id,'DOA_Quote_Approval',True);
        //System.assertNotEquals(null,result);
        Test.stopTest();
    }

}