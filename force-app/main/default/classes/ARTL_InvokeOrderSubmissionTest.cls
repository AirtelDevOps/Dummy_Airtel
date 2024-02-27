@isTest
public class ARTL_InvokeOrderSubmissionTest {
@testSetup
   static void dataCreation() {
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.RecordTypeId = recordTypeId;
        acc.BillingStreet = 'Test Street';
        acc.BillingState  = 'Karnataka';
        acc.BillingCity   = 'Bengaluru';
        acc.BillingCountry= 'India';
        acc.BillingPostalCode = '560087';
        acc.ARTL_Category__c ='A';
        acc.ARTL_Customer_Segment__c ='AB';
        acc.ARTL_Vertical_Segment__c ='BFI';
        acc.ARTL_Service_Segment__c ='Bharti';
        acc.ARTL_Business_Circle_Region__c='NCR';
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
        insert q;
    }
    @isTest static void generateOSSJClassTest(){
        Account acc = [Select id from Account limit 1];
        List<Product2> products = new List<Product2>();
        
        
        Id pbId = Test.getStandardPricebookId();
        
        products = new Product2[2];
        
        products[0]=new Product2(name='VEPC_PRIMARY_LINK', ProductCode='VEPC_PRIMARY_LINK ',vlocity_cmt__JSONAttribute__c = '');
        
        products[1]=new Product2(name='VEPC_PRIMARY_MPLS_LINK ', ProductCode='VEPC_PRIMARY_MPLS_LINK ', vlocity_cmt__JSONAttribute__c = '');
       
        insert products;
        
        PricebookEntry[] pbes = new PricebookEntry[products.size()];
        
        for (Integer i=0; i<products.size(); i++)
        {
            pbes[i] = new PricebookEntry(product2Id = products[i].id, unitPrice = 10, pricebook2id = pbId, useStandardPrice = false,isActive=true);
        }
        
        insert pbes;
        

        
        Quote q1 = [Select id FROM Quote limit 1];
        List<Quote> qList=[select id,name,AccountId,Status,Pricebook2Id from Quote];
        List<Quotelineitem> Listqli = new List<Quotelineitem>();
        for(Quote q:qList){
            Quotelineitem qli1 = new QuoteLineItem(QuoteId = q1.id, PriceBookentryId = pbes[0].id, Quantity = 1, UnitPrice = 1,
                                                   Product2Id=products[0].Id);
       		Listqli.add(qli1); 
        }
        insert Listqli;

        
        
        Order order = new Order(AccountId = acc.id, effectiveDate = Date.today(), pricebook2id = pbId, status = 'Draft',QuoteId=q1.Id);
        insert order;
        
        OrderItem[] ois = new OrderItem[2];
        ois[0] = new OrderItem(vlocity_cmt__lineNumber__c = '0001',Product2Id = products[0].Id, OrderId = order.id, pricebookEntryId = pbes[0].id, quantity = 1, vlocity_cmt__AssetReferenceId__c = '201',
                               unitPrice = 1, vlocity_cmt__provisioningStatus__c = 'New', 
                               vlocity_cmt__JSONAttribute__c = '', vlocity_cmt__PricingLogData__c = '' ,
                               vlocity_cmt__Action__c= 'Add',QuoteLineItemId=Listqli[0].Id, ARTL_QuoteLineItemId__c = Listqli[0].Id);
        ois[1] = new OrderItem(vlocity_cmt__lineNumber__c = '0002',Product2Id = products[1].Id, OrderId = order.id, pricebookEntryId = pbes[1].id, quantity = 1, vlocity_cmt__AssetReferenceId__c = '202',
                                unitPrice = 1, vlocity_cmt__provisioningStatus__c = 'New', vlocity_cmt__JSONAttribute__c = '', 
                               vlocity_cmt__PricingLogData__c ='',ARTL_QuoteLineItemId__c = Listqli[0].Id);            
       
        insert ois;
        ARTL_InvokeOrderSubmission.IntegrationProcedureInput input = new ARTL_InvokeOrderSubmission.IntegrationProcedureInput();
        input.recordId = order.Id;
        List <ARTL_InvokeOrderSubmission.IntegrationProcedureInput> flowinput = 
            new List<ARTL_InvokeOrderSubmission.IntegrationProcedureInput>();
        flowinput.add(input);
        ARTL_InvokeOrderSubmission.runIntegrationServiceInvocable(flowinput);
    }
}