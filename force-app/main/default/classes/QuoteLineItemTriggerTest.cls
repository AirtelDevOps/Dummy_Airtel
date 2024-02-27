@isTest
public class QuoteLineItemTriggerTest {
    @testSetup
    static void dataCreation() {
        try{
            
       
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
        system.debug('product=>'+prod);    
            
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
            ARTL_Purchase_Order__c = po.Id
			            
        );
               
            insert qli;
            system.debug('qli=>'+qli);

         
        
        }catch(exception e){
            System.debug('Exception in data createation @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
        
    }
    
    /*
    @isTest
    static void testQuoteTrigger() {
        Test.startTest();
        
        Product2 objProduct = new Product2(Name = 'Test product1', family = 'Cafe',ProductCode='XYZ_1',
                                           ARTL_TechnicalProduct__c='ABC_x');
        insert objProduct;
        Product2 objProduct2 = new Product2(Name = 'Test product11', family = 'Cafe',ProductCode='ABC_x');
        insert objProduct2;
        
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),Product2Id = objProduct.Id, IsActive = true);
        insert objPBE;
        List<Quote> qList=[select id,name,AccountId,Status,Pricebook2Id from Quote];
        List<Quotelineitem> Listqli = new List<Quotelineitem>();
        for(Quote q:qList){
            Quotelineitem qli1 = new QuoteLineItem(QuoteId = q.id, PriceBookentryId = objPBE.id, Quantity = 1, UnitPrice = 1,
                                                   Product2Id=objProduct.Id);
            Listqli.add(qli1); 
        }
        insert Listqli;
        
        
        Test.stopTest();
    }
    */
        
   
    @isTest
    static void updateDOACapexFieldsFUpdateTest1() {
            
        Test.StartTest();
        
        Product2 prod = new Product2(Name = 'Test product2', family = 'Internet',ProductCode='VEPC_PRIMARY_LINK', ARTL_LSIRequired__c=true);
        insert prod;
        
        ARTL_Purchase_Order__c  po = new ARTL_Purchase_Order__c();
        po.ARTL_Account__c = [SELECT id FROM Account LIMIT 1].Id ; 
        po.Amount__c = 10000;
        //   po.ARTL_PO_Date__c = system.today();
        po.End_Date__c = system.today() + 30 ;
        po.ARTL_PO_Number__c = '12555533';
        
        Insert po;
        
        QuoteLineItem qliRet=[SELECT Id,Capex__c,Annual_Recurring_Charge__c,vlocity_cmt__OneTimeCharge__c,ARTL_Purchase_Order__c,vlocity_cmt__Product2Id__c FROM QuoteLineItem  ];
        system.debug('qliRet new =>'+qliRet);
        qliRet.Capex__c=10000000;
        qliRet.Annual_Recurring_Charge__c=100;
        qliRet.vlocity_cmt__OneTimeCharge__c=100;
        qliRet.ARTL_ARCFloorRate__c=500000;
        qliRet.ARTL_NRCFloorRate__c=500000;
        qliRet.ARTL_Purchase_Order__c = po.Id;
        qliRet.vlocity_cmt__Product2Id__c = prod.Id;
        update qliRet;
        
        Test.stopTest();
        
    }
    
     /*
    @isTest
    static void updateDOACapexFieldsFUpdateTest2() {
        try{
        Test.startTest();
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
            IsActive = true`
        );
        insert pbEntry;
        system.debug('pbEntry=>'+pbEntry);
        
        vlocity_cmt__PriceList__c priceList=[select id from vlocity_cmt__PriceList__c limit 1];
        
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
        //q.ARTL_QNeedCapexApproval__c=True;
        insert q;
        system.debug('q=>'+q);
        
        
        QuoteLineItem qli = new QuoteLineItem(
            Product2Id = prod.Id,
            QuoteId = q.Id,
            PricebookEntryId = pbEntry.Id,
            UnitPrice = pbEntry.UnitPrice,
            Quantity=1,
            Capex__c=1000000,
            Annual_Recurring_Charge__c=225000,
            vlocity_cmt__OneTimeCharge__c=220000,
            ARTL_ARCFloorRate__c=50000,
            ARTL_NRCFloorRate__c=50000
        );
        insert qli;
        system.debug('qli=>'+qli);
        QuoteLineItem qliCheck=[SELECT Id,Capex__c,Annual_Recurring_Charge__c,vlocity_cmt__OneTimeCharge__c,ARTL_NeedCapexApproval__c,ARTL_NeedDOAApproval__c FROM QuoteLineItem WHERE Id=:qli.Id];
        system.debug('qli check=>'+JSON.serializePretty(qliCheck));
        
        QuoteLineItem qliRet=[SELECT Id,Capex__c,Annual_Recurring_Charge__c,vlocity_cmt__OneTimeCharge__c FROM QuoteLineItem WHERE Id=:qli.Id];
        system.debug('qliRet=>'+qliRet);
        qliRet.Capex__c=10;
        qliRet.Annual_Recurring_Charge__c=100;
        qliRet.vlocity_cmt__OneTimeCharge__c=100;
        qliRet.ARTL_ARCFloorRate__c=500000;
        qliRet.ARTL_NRCFloorRate__c=500000;
        update qliRet;
        
        Test.stopTest();
            }catch(exception e){
            System.debug('Exception in  method::updateDOACapexFieldsFUpdateTest2 @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
    }
   
    @isTest
    static void updateDOACapexFieldsFUpdateTest3() {
        try{
        Test.startTest();
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
        
        vlocity_cmt__PriceList__c priceList=[select id from vlocity_cmt__PriceList__c limit 1];
        
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
        q.ARTL_QNeedDOAApproval__c=True;
        insert q;
        system.debug('q=>'+q);
        
      	      
        
        QuoteLineItem qli = new QuoteLineItem(
            Product2Id = prod.Id,
            QuoteId = q.Id,
            PricebookEntryId = pbEntry.Id,
            UnitPrice = pbEntry.UnitPrice,
            Quantity=1,
            Capex__c=1000,
            Annual_Recurring_Charge__c=225000,
            vlocity_cmt__OneTimeCharge__c=220000,
            ARTL_ARCFloorRate__c=500000,
            ARTL_NRCFloorRate__c=500000
        );
        insert qli; 
            
       ARTL_Purchase_Order__c  po = new ARTL_Purchase_Order__c();
            po.ARTL_Account__c = acc.id;
            po.Amount__c = 10000;
         //   po.ARTL_PO_Date__c = system.today();
            po.End_Date__c = system.today() + 30 ;
            po.ARTL_PO_Number__c = '123133';
            po.Quote_Line_Item__c = qli.Id;
            
            Insert po;
            
        system.debug('qli=>'+qli);
        QuoteLineItem qliCheck=[SELECT Id,Capex__c,Annual_Recurring_Charge__c,vlocity_cmt__OneTimeCharge__c,ARTL_NeedCapexApproval__c,ARTL_NeedDOAApproval__c FROM QuoteLineItem WHERE Id=:qli.Id];
        system.debug('qli check=>'+JSON.serializePretty(qliCheck));
        
        QuoteLineItem qliRet=[SELECT Id,Capex__c,Annual_Recurring_Charge__c,vlocity_cmt__OneTimeCharge__c FROM QuoteLineItem WHERE Id=:qli.Id];
        system.debug('qliRet=>'+qliRet);
        qliRet.Capex__c=10000000;
        qliRet.Annual_Recurring_Charge__c=2250000;
        qliRet.vlocity_cmt__OneTimeCharge__c=2250000;
        qliRet.ARTL_ARCFloorRate__c=500000;
        qliRet.ARTL_NRCFloorRate__c=500000;
        update qliRet;
        
        Test.stopTest();
            }catch(exception e){
            System.debug('Exception in class:: method::updateDOACapexFieldsFUpdateTest3 @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
    }
*/    
    /*
  
    @isTest
    static void testCreateBillingStaging() {
        
            Test.startTest();
            Account acc = new Account(Name = 'Test Account');
            insert acc; 
           
            Contact contactRec = new Contact(FirstName 				= 'Test',
                                         LastName				= 'Test',
                                         Phone					= '9887654321', 
                                         Email					= 'test@test.com',
                                         ARTL_Designation__c 	= 'test', 
                                         ARTL_Contact_Role__c 	= 'Billing Contact', 
                                         AccountId 				= acc.Id);
        insert contactRec;
            
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
            
            vlocity_cmt__PriceList__c priceList=[select id from vlocity_cmt__PriceList__c limit 1];
            
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
            q.ARTL_QNeedDOAApproval__c=True;
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
           // po.Quote_Line_Item__c = qli.Id;
            
            Insert po;
            
            QuoteLineItem qli = new QuoteLineItem(
                Product2Id = prod.Id,
                QuoteId = q.Id,
                PricebookEntryId = pbEntry.Id,
                UnitPrice = pbEntry.UnitPrice,
                Quantity=1,
                vlocity_cmt__AssetId__c = ast.Id,
                Capex__c=1000,
                vlocity_cmt__AssetReferenceId__c = '123',
                Annual_Recurring_Charge__c=225000,
                vlocity_cmt__OneTimeCharge__c=220000,
                ARTL_ARCFloorRate__c=500000,
                ARTL_NRCFloorRate__c=500000,
                ARTL_Purchase_Order__c = po.Id
            );
            insert qli;
            
            
            
            
            system.debug('qli=>'+qli);
            QuoteLineItem qliCheck=[SELECT Id,Capex__c,Annual_Recurring_Charge__c,vlocity_cmt__OneTimeCharge__c,ARTL_NeedCapexApproval__c,ARTL_NeedDOAApproval__c FROM QuoteLineItem WHERE Id=:qli.Id];
            system.debug('qli check=>'+JSON.serializePretty(qliCheck));
            
            /*
            QuoteLineItem qliRet=[SELECT Id,Capex__c,Annual_Recurring_Charge__c,vlocity_cmt__OneTimeCharge__c,ARTL_Purchase_Order__c FROM QuoteLineItem WHERE Id=:qli.Id];
            system.debug('qliRet=>'+qliRet);
            qliRet.Capex__c=10000000;
            qliRet.Annual_Recurring_Charge__c=2250000;
            qliRet.vlocity_cmt__OneTimeCharge__c=2250000;
            qliRet.ARTL_ARCFloorRate__c=500000;
            qliRet.ARTL_NRCFloorRate__c=500000;
            update qliRet;
            
            Test.stopTest();
        }catch( Exception ex){
        //    System.debug('Exception createBillingStaging ex -'+ex.getMessage()+' LNo '+ex.getLineNumber());
        //}
        
    }
   */
    
    
}