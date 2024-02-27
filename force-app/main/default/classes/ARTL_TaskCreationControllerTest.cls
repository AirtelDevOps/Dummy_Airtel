@isTest
public class ARTL_TaskCreationControllerTest {
@testSetup
   static void dataCreation() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account acc = new Account(Name = 'Test Account',ARTL_Business_Circle_Region__c='NCR',BillingCity = 'Panchkula',
                                  BillingCountry = 'Haryana',BillingPostalCode = '134109',BillingState = 'India',BillingStreet = 'Panchkula',
                                  ARTL_Category__c = 'A',RecordTypeId = recordTypeId, ARTL_Customer_Segment__c ='AB', ARTL_Vertical_Segment__c ='BFI',
                                 ARTL_Service_Segment__c ='Bharti');
        insert acc; 

        vlocity_cmt__PriceList__c priceList = new 	vlocity_cmt__PriceList__c();
        priceList.Name ='Pricelist For Test class';
        priceList.vlocity_cmt__Code__c='PricelistForTestclass';
        priceList.vlocity_cmt__Pricebook2Id__c =Test.getStandardPricebookId();
        insert priceList;
		
       PM_User_Matrix__c  userMatrix = new PM_User_Matrix__c();
       userMatrix.Circle__c = 'NCR';
       userMatrix.Business_Account__c = acc.Id;
       userMatrix.CCE__c = Userinfo.getUserId();
       userMatrix.CPH__c = Userinfo.getUserId();
       //userMatrix.PM__c = Userinfo.getUserId();
       userMatrix.TL__c = Userinfo.getUserId();
       insert userMatrix;
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
        q.PM__c = Userinfo.getuserId();
        insert q;
       
       
        List<Product2> products = new List<Product2>();
        
        
        Id pbId = Test.getStandardPricebookId();
        
        products = new Product2[2];
        
        products[0]=new Product2(name='VEPC_PRIMARY_LINK', ProductCode='VEPC_PRIMARY_LINK ',vlocity_cmt__JSONAttribute__c = '');
        
        products[1]=new Product2(name='VEPC_PRIMARY_MPLS_LINK ', ProductCode='VEPC_PRIMARY_MPLS_LINK ', vlocity_cmt__JSONAttribute__c = '');
       
        insert products;
        
        PricebookEntry[] pbes = new PricebookEntry[products.size()];
        
        for (Integer i=0; i<products.size(); i++)
        {
            pbes[i] = new PricebookEntry(product2Id = products[i].id, isActive=true,unitPrice = 10, pricebook2id = pbId, useStandardPrice = false);
        }
        
        insert pbes;
        
            
        
        Order order = new Order(AccountId = acc.id, effectiveDate = Date.today(), pricebook2id = pbId, status = 'Draft');
        insert order;
        List<QuoteLineItem> lstQli = new List<QuoteLineItem>();
        QuoteLineItem qli = new QuoteLineItem(
            Product2Id = products[0].Id,
            QuoteId = q.Id,
            PricebookEntryId = pbes[0].Id,
            UnitPrice = pbes[0].UnitPrice,
            Quantity=1,
            Capex__c=100000,
            Annual_Recurring_Charge__c=225000,
            vlocity_cmt__OneTimeCharge__c=220000,
            ARTL_ARCFloorRate__c=50000,
            ARTL_NRCFloorRate__c=50000
        );
        lstQli.add(qli);
        QuoteLineItem qli2 = new QuoteLineItem(
            Product2Id = products[1].Id,
            QuoteId = q.Id,
            PricebookEntryId = pbes[1].Id,
            UnitPrice = pbes[1].UnitPrice,
            Quantity=1,
            Capex__c=100000,
            Annual_Recurring_Charge__c=225000,
            vlocity_cmt__OneTimeCharge__c=220000,
            ARTL_ARCFloorRate__c=50000,
            ARTL_NRCFloorRate__c=50000
        );
        lstQli.add(qli2);
        insert lstQli;
        
        
        OrderItem[] ois = new OrderItem[2];
        ois[0] = new OrderItem(vlocity_cmt__lineNumber__c = '0001',Product2Id = products[0].Id, OrderId = order.id, pricebookEntryId = pbes[0].id, quantity = 1, vlocity_cmt__AssetReferenceId__c = '201',
                               unitPrice = 1, vlocity_cmt__provisioningStatus__c = 'New', 
                               vlocity_cmt__JSONAttribute__c = '', vlocity_cmt__PricingLogData__c = '' ,
                               vlocity_cmt__Action__c= 'Add',ARTL_QuoteLineItemId__c = lstQli[0].Id);
        ois[1] = new OrderItem(vlocity_cmt__lineNumber__c = '0002',Product2Id = products[1].Id, OrderId = order.id, pricebookEntryId = pbes[1].id, quantity = 1, vlocity_cmt__AssetReferenceId__c = '202',
                                unitPrice = 1, vlocity_cmt__provisioningStatus__c = 'New', vlocity_cmt__JSONAttribute__c = '', 
                               vlocity_cmt__PricingLogData__c ='',ARTL_QuoteLineItemId__c = lstQli[1].Id);            
       
        insert ois;
       
       
    }
    @isTest static void CreateTaskFromFlowTest(){
        Order order = [Select Id FROm Order limit 1];
        
        Task newobjtask = new Task();
        newobjtask.Subject = 'LOC to customer';
        newobjtask.ARTL_TaskType__c = 'LOC to customer';
        //newobjtask.Quote_Line_Item__c = extrec.Quote_Line_Item__c;
        newobjtask.Status = 'Open';
        newobjtask.WhatId = order.Id;
        newobjtask.OwnerId = Userinfo.getUserId();
        insert newobjtask;
        
        List<ARTL_TaskCreationController.FlowInput> lstinput = new List<ARTL_TaskCreationController.FlowInput>();
        ARTL_TaskCreationController.FlowInput input = new ARTL_TaskCreationController.FlowInput();
        input.recordId = newobjtask.Id;
        lstinput.add(input);
        
        ARTL_TaskCreationController.CreateTaskFromFlow(lstinput);
    }
    @isTest static void CreateTaskFromFlowTest2(){
        Order order = [Select Id FROm Order limit 1];
        Task[] lasttask = new Task[2];
        Task newobjtask = new Task();
        newobjtask.Subject = 'LOC validation';
        newobjtask.ARTL_TaskType__c = 'LOC validation';
        //newobjtask.Quote_Line_Item__c = extrec.Quote_Line_Item__c;
        newobjtask.Status = 'Rejected';
        newobjtask.WhatId = order.Id;
        newobjtask.OwnerId = Userinfo.getUserId();
        lasttask.add(newobjtask);
        
        Task newobjtask2 = new Task();
        newobjtask2.Subject = 'PM upload LOC';
        newobjtask2.ARTL_TaskType__c = 'PM upload LOC';
        //newobjtask.Quote_Line_Item__c = extrec.Quote_Line_Item__c;
        newobjtask2.Status = 'Rejected';
        newobjtask2.WhatId = order.Id;
        newobjtask2.OwnerId = Userinfo.getUserId();
        lasttask.add(newobjtask2);
        
        insert newobjtask;
        
        List<ARTL_TaskCreationController.FlowInput> lstinput = new List<ARTL_TaskCreationController.FlowInput>();
        ARTL_TaskCreationController.FlowInput input = new ARTL_TaskCreationController.FlowInput();
        input.recordId = newobjtask.Id;
        lstinput.add(input);
        
        ARTL_TaskCreationController.CreateTaskFromFlow(lstinput);
    }
    
    @isTest static void CreateTaskFromFlowTest3(){
        Order order = [Select Id FROm Order limit 1];
        Task[] lasttask = new Task[2];
        Task newobjtask = new Task();
        newobjtask.Subject = 'IP Port Shut';
        newobjtask.ARTL_TaskType__c = 'IP Port Shut';
        //newobjtask.Quote_Line_Item__c = extrec.Quote_Line_Item__c;
        newobjtask.Status = 'Rejected';
        newobjtask.WhatId = order.Id;
        newobjtask.OwnerId = Userinfo.getUserId();
        lasttask.add(newobjtask);
        
        Task newobjtask2 = new Task();
        newobjtask2.Subject = 'PM approval for LOC';
        newobjtask2.ARTL_TaskType__c = 'PM approval for LOC';
        //newobjtask.Quote_Line_Item__c = extrec.Quote_Line_Item__c;
        newobjtask2.Status = 'Rejected';
        newobjtask2.WhatId = order.Id;
        newobjtask2.OwnerId = Userinfo.getUserId();
        lasttask.add(newobjtask2);
        
        insert newobjtask;
        
        List<ARTL_TaskCreationController.FlowInput> lstinput = new List<ARTL_TaskCreationController.FlowInput>();
        ARTL_TaskCreationController.FlowInput input = new ARTL_TaskCreationController.FlowInput();
        input.recordId = newobjtask.Id;
        lstinput.add(input);
        
        ARTL_TaskCreationController.CreateTaskFromFlow(lstinput);
    }
    @isTest static void CreateTaskFromFlowTest4(){
        Order order = [Select Id FROm Order limit 1];
        Task[] lasttask = new Task[2];
        Task newobjtask = new Task();
        newobjtask.Subject = 'IP Port Shut';
        newobjtask.ARTL_TaskType__c = 'IP Port Shut';
        //newobjtask.Quote_Line_Item__c = extrec.Quote_Line_Item__c;
        newobjtask.Status = 'Accepted';
        newobjtask.WhatId = order.Id;
        newobjtask.OwnerId = Userinfo.getUserId();
        lasttask.add(newobjtask);
        
        Task newobjtask2 = new Task();
        newobjtask2.Subject = 'PM approval for LOC';
        newobjtask2.ARTL_TaskType__c = 'PM approval for LOC';
        //newobjtask.Quote_Line_Item__c = extrec.Quote_Line_Item__c;
        newobjtask2.Status = 'Open';
        newobjtask2.WhatId = order.Id;
        newobjtask2.OwnerId = Userinfo.getUserId();
        lasttask.add(newobjtask2);
        
        insert newobjtask;
        
        List<ARTL_TaskCreationController.FlowInput> lstinput = new List<ARTL_TaskCreationController.FlowInput>();
        ARTL_TaskCreationController.FlowInput input = new ARTL_TaskCreationController.FlowInput();
        input.recordId = newobjtask.Id;
        lstinput.add(input);
        
        ARTL_TaskCreationController.CreateTaskFromFlow(lstinput);
    }
}