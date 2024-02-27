@isTest
public class ARTL_QuoteValidationControllerTest {
    @testSetup
    public static void makeData(){
        Account acc = new Account(Name = 'Test Account quote trigger tst',billingCity='pune',billingState = 'Maharastra', ARTL_Legal_Entity__c = 'NXTRA DATA LIMITED',artl_customer_segment__c = 'AB',
                                  artl_business_circle_region__c = 'NCR' , artl_vertical_segment__c= 'BFI');
        insert acc; 
        
		Contact contactRec = new Contact(FirstName 				= 'Test',
                                         LastName				= 'Test',
                                         Phone					= '9887654321', 
                                         Email					= 'test@test.com',
                                         ARTL_Designation__c 	= 'test', 
                                         ARTL_Contact_Role__c 	= 'Billing Contact', 
                                         country_code__c='1',
                                         AccountId 				= acc.Id);
        insert contactRec;  
        
        Product2 prod = new Product2(Name = 'Test product1', family = 'Internet',ProductCode='VEPC_PRIMARY_LINK', ARTL_LSIRequired__c=true);
        insert prod;
        
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
        q.ARTL_QNeedCapexApproval__c=True;
        q.ARTL_PO_Total__c = 0;
        q.ARTL_LSI_Count__c = 0;    
        insert q;
        system.debug('q=>'+q);
            
        Asset ast = new Asset();
        ast.Name = 'Test3';
        ast.AccountId = acc.Id;
        ast.vlocity_cmt__AssetReferenceId__c = '123';
        ast.vlocity_cmt__BillingAccountId__c  = acc.Id;
        ast.vlocity_cmt__ServiceAccountId__c   = acc.Id;
        
        insert ast;
       ARTL_Purchase_Order__c  po = new ARTL_Purchase_Order__c();
        po.ARTL_Account__c = acc.id;
        po.Amount__c = 10000;
        //   po.ARTL_PO_Date__c = system.today();
        po.End_Date__c = system.today() + 30 ;
        po.ARTL_PO_Number__c = '123133';
        
        Insert po;
            
        
        QuoteLineItem qli = new QuoteLineItem(
            vlocity_cmt__Product2Id__c = prod.Id,
            QuoteId = q.Id,
            PricebookEntryId = pbEntry.Id,
            UnitPrice = pbEntry.UnitPrice,
            Quantity=1,
            Capex__c=50000,
            Annual_Recurring_Charge__c=225000,
            vlocity_cmt__OneTimeCharge__c=220000,
            ARTL_ARCFloorRate__c=50000,
            ARTL_NRCFloorRate__c=50000,
            vlocity_cmt__AssetReferenceId__c = '123',
            ARTL_Purchase_Order__c = po.Id,
            ARTL_Validation_Status__c='Failed'
			            
        );
               
            insert qli;
    }
    
    @isTest
    public static void checkQuoteValidationTest(){
        Test.startTest();
        Quote currentQuote=[SELECT Id,vlocity_cmt__Type__c FROM Quote LIMIT 1];
        currentQuote.vlocity_cmt__Type__c='Rate Revision';
        update currentQuote;
        QuoteLineItem currentQLI=[SELECT Id,ARTL_Validation_Status__c FROM QuoteLineItem WHERE QuoteId=:currentQuote.id];
        ARTL_QuoteValidationController.checkQuoteValidation(currentQuote.Id);
        currentQLI.ARTL_Validation_Status__c='Passed';
        update currentQLI;
        ARTL_QuoteValidationController.checkQuoteValidation(currentQuote.Id);
        
        Test.stopTest();
    }
    
    @isTest
    public static void getReportIdTest(){
        Test.startTest();
            //Report newReport=[SELECT Id FROM Report WHERE Name='ARTL QLI Validation'];
        	ARTL_QuoteValidationController.getReportId();
        Test.stopTest();
    }
}