@isTest
private class ARTL_IPCallToUpdateTest {
    @isTest
    static void testInvokeMethod_updateRRorRbDate() {
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        
        Account acc = new Account(Name = 'Test Account quote trigger tst',billingCity='pune',billingState = 'Maharastra', ARTL_Legal_Entity__c = 'NXTRA DATA LIMITED',artl_customer_segment__c = 'AB',
                                  artl_business_circle_region__c = 'NCR' , artl_vertical_segment__c= 'BFI');
        insert acc;
        
        Product2 prod = new Product2(Name = 'Test product1', family = 'Internet',ProductCode='VEPC_PRIMARY_LINK', ARTL_LSIRequired__c=true);
        insert prod;
        
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100.00, // Set the unit price as needed
            IsActive = true
        );
        insert pbEntry;    
            
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
        
        ARTL_Purchase_Order__c  po = new ARTL_Purchase_Order__c();
        po.ARTL_Account__c = acc.id;
        po.Amount__c = 10000;
        //po.ARTL_PO_Date__c = system.today();
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
        qliList.add(qli);
        insert qliList;
        
        Map<String, Object> inputs = new Map<String, Object>{
            'QLIId' => new List<Id>{qliList[0].Id}
        };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        ARTL_IPCallToUpdate call = new ARTL_IPCallToUpdate();
        Boolean result = call.invokeMethod('updateRRorRbDate', inputs, output, options);
        
    }
    }