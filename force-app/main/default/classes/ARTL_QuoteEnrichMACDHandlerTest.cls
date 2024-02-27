@isTest
public class ARTL_QuoteEnrichMACDHandlerTest {
    
    @testSetup
    public static void testData(){
        try{
            Account[] accounts =new Account[3];
            Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
            Id billingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
            Id serviceAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
            accounts[0] = new Account(Name = 'Test Business Account', vlocity_cmt__Status__c='Active',RecordTypeId = businessAccountRecordTypeId, BillingStreet='Test Street', BillingCity='Mumbai', BillingState='Maharashtra', BillingPostalCode='120006',BillingCountry='India',ARTL_Category__c='A',ARTL_Customer_Segment__c='AB', ARTL_Business_Circle_Region__c='NCR',ARTL_Service_Segment__c='Bharti',ARTL_Vertical_Segment__c='BFI');		
            accounts[1] = new Account(Name = 'Test Billing Account',vlocity_cmt__Status__c='Active',RecordTypeId  = billingAccountRecordTypeId, BillingStreet='Test Street', BillingCity='Mumbai', BillingState='Maharashtra', BillingPostalCode='120006',BillingCountry='India',ARTL_Category__c='A',ARTL_Customer_Segment__c='AB', ARTL_Business_Circle_Region__c='NCR',ARTL_Service_Segment__c='Bharti',ARTL_Vertical_Segment__c='BFI');
            accounts[2] = new Account(Name = 'Test Service Account',vlocity_cmt__Status__c='Active',RecordTypeId  = serviceAccountRecordTypeId, BillingStreet='Test Street', BillingCity='Mumbai', BillingState='Maharashtra', BillingPostalCode='120006',BillingCountry='India',ARTL_Category__c='A',ARTL_Customer_Segment__c='AB', ARTL_Business_Circle_Region__c='NCR',ARTL_Service_Segment__c='Bharti',ARTL_Vertical_Segment__c='BFI');
            
            insert accounts;
            
            Product2[] products = new Product2[2];
            products[0]=new Product2(name='Test Product1', ProductCode='VEPC_ENTERPRISE_ICONNECTIVITY_ROUTERS');
            products[1]=new Product2(name='Primary Link', ProductCode='VEPC_PRIMARY_LINK');
            
            insert products;
            
            PricebookEntry[] pbes = new PricebookEntry[products.size()];
            Id pbId = Test.getStandardPricebookId();
            
            for (Integer i=0; i<products.size(); i++){
                pbes[i] = new PricebookEntry(product2Id = products[i].id, 
                                             IsActive = true, 
                                             unitPrice = 10, 
                                             pricebook2id = pbId, 
                                             useStandardPrice = false);
            }
            
            insert pbes;
            
            
            vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = pbId, 
                                                                          vlocity_cmt__IsActive__c = true, 
                                                                          vlocity_cmt__Code__c = 'TestPricebook5');
            insert pl1;
            
            Opportunity  opp = new Opportunity ();
            opp.name= 'EPC Deal AA';
            opp.accountId = accounts[0].id;
            opp.vlocity_cmt__PriceListId__c = pl1.Id;
            opp.CloseDate = System.today();
            opp.StageName = 'Initial';
            opp.Pricebook2Id = pbId;
            insert opp;
            
            Quote qtest = new Quote();
            qtest.name = 'Quote - EPC Deal AA';
            qtest.Status = 'Draft';
            qtest.OpportunityId = opp.Id;
            qtest.Pricebook2Id = pbId;
            qtest.vlocity_cmt__PriceListId__c = pl1.Id;
            qtest.vlocity_cmt__PoDate__c = Date.today();
            qtest.vlocity_cmt__PoNumber__c = '12345';
            qtest.PO_Term__c = '12';
            qtest.PO_Value__c = 1222;
            qtest.RecordTypeId =  [SELECT Id FROM RecordType WHERE DeveloperName= 'EnterpriseQuote' AND SobjectType= 'Quote' LIMIT 1].Id;
            insert qtest;
            
            PO_Group__c poGroup = new PO_Group__c();
            poGroup.ARTL_PO_Group_Number__c = '123';
            insert poGroup;
            
            PO_Group__c poGroup1 = new PO_Group__c();
            poGroup1.ARTL_PO_Group_Number__c = '1234';
            insert poGroup1;
            
            ARTL_Purchase_Order__c PurchaseOrder = new ARTL_Purchase_Order__c();
            PurchaseOrder.ARTL_PO_Number__c = '111111';
            PurchaseOrder.PO_Group__c = poGroup.id;
            insert PurchaseOrder;
            
            QuoteLineItem  quoteLine1 = new QuoteLineItem ();
            quoteLine1.UnitPrice = 1;
            quoteLine1.Quantity = 1;
            quoteLine1.Product2Id = products[1].Id;
            quoteLine1.vlocity_cmt__Product2Id__c = products[1].Id;
            quoteLine1.QuoteId =qtest.Id;
            quoteLine1.PricebookEntryId=pbes[0].Id;
            quoteLine1.vlocity_cmt__Action__c='Change';
            quoteLine1.ARTL_Purchase_Order__c = PurchaseOrder.Id;
            quoteLine1.vlocity_cmt__ServiceAccountId__c =accounts[2].id;
            quoteLine1.vlocity_cmt__BillingAccountId__c =accounts[1].id;
            
            insert quoteLine1;
            
            QuoteLineItem  quoteLine = new QuoteLineItem ();
            quoteLine.UnitPrice = 1;
            quoteLine.Quantity = 1;
            quoteLine.Product2Id = products[0].Id;
            quoteLine.vlocity_cmt__Product2Id__c = products[0].Id;
            quoteLine.QuoteId =qtest.Id;
            quoteLine.PricebookEntryId=pbes[0].Id;
            quoteLine.vlocity_cmt__Action__c='Add';
            quoteLine.ARTL_Purchase_Order__c =null;
            quoteLine.vlocity_cmt__ServiceAccountId__c =accounts[2].id;
            quoteLine.vlocity_cmt__BillingAccountId__c =accounts[1].id;
            
            ARTL_Billing_Staging__c stage = new ARTL_Billing_Staging__c();
            stage.Quote__c = qtest.Id;
            stage.Quote_Line_Item__c = quoteLine.Id;
            insert stage;
            
            ARTL_VAN_AccountNumbers__c vanAccno = new ARTL_VAN_AccountNumbers__c();
            vanAccno.ARTL_Legal_Entity_Name__c = 'AIDL';
            vanAccno.ARTL_Business_Account__c = accounts[0].id;
            vanAccno.Name = 'test van';
            insert vanAccno;     
        }
        catch(Exception e){
            System.debug('Exception in class::ARTL_QuoteEnrichMACDHandlerTest and method::testData @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
            
        }
    }
    
    @isTest
    static void createTestPODetails(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User user = new User(LastName = 'Jackson',FirstName='Michael', Alias = 'jl', Email = 'Michael.Jackson@testorg.com',
                             Username = 'Michael.Jackson@testorg.com', ProfileId = profileId.id,TimeZoneSidKey = 'GMT', 
                             LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',LocaleSidKey = 'en_US');
        // string userId = UserInfo.getUserId();
        insert user;
        
        List<Object> rowsListMap = new List<Object>();
        Map<String, String> billingStagingMap = new Map<String, String>();
        Map<String, Object> poDetailsBlockStrMap = new Map<String, Object>();
        Map<String, Object> poGroupBlockStrMap = new Map<String, Object>();
        System.runAs(user){
            {
                List<ARTL_Billing_Staging__c> bsList = [Select Id From ARTL_Billing_Staging__c LIMIT 1];
                System.debug('bsList '+bsList);
                billingStagingMap.put('BSId',bsList[0].Id);
                rowsListMap.add(billingStagingMap);
                poDetailsBlockStrMap.put('CreateNewPO',true);
                PO_Group__c poGrp = [Select Id, Name FROM PO_Group__c LIMIT 1];
                poGroupBlockStrMap.put('Id',poGrp.Id);
                poGroupBlockStrMap.put('Name',poGrp.Name);
                poGroupBlockStrMap.put('POGroup',poGrp.Name);
                poDetailsBlockStrMap.put('POGroup-Block',poGroupBlockStrMap);
                poDetailsBlockStrMap.put('PONumber','24259');
                poDetailsBlockStrMap.put('POStartDate','2024-01-03');
                poDetailsBlockStrMap.put('POTerms','2');
                poDetailsBlockStrMap.put('POAmount',2400);
                
                String quoteId;
                List<Quote> quote = [Select Id From Quote LIMIT 1];
                quoteId = String.valueOf(quote[0].Id);
                
                Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
                List<Account> accList=[SELECT Id FROM Account WHERE RecordTypeId=: businessAccountRecordTypeId LIMIT 1];
                system.debug('accList==>'+accList);
                
                Map<string,object> input = new Map<string,object>();
                input.put('ContextId',quoteId);
                input.put('businessAccountId',accList[0].Id);
                input.put('UpdatePODetails',true);
                input.put('PODetailsBlock',poDetailsBlockStrMap);
                input.put('rows',rowsListMap);
                
                Test.startTest();
                ARTL_QuoteEnrichMACDHandler qemh = new ARTL_QuoteEnrichMACDHandler();
                qemh.invokeMethod('CreatePODetails',input,new Map<string,Object>{},new Map<string,Object>{});
                Test.stopTest();
            }
        }
    }
    
    @isTest
    static void labelTestPOGroup(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User user = new User(LastName = 'Jackson1',FirstName='Michael', Alias = 'jl', Email = 'Michael.Jackson@testorg.com',
                             Username = 'Michael.Jackson1@testorg.com', ProfileId = profileId.id,TimeZoneSidKey = 'GMT', 
                             LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',LocaleSidKey = 'en_US');
        // string userId = UserInfo.getUserId();
        insert user;
        Map<String,Object> input = new Map<String,Object>();
        List<Object> poGroupObjList = new List<Object>();
        List<Object> legalEntityObjList = new List<object>();
        List<PO_Group__c> poGroupList =[SELECT id,name FROM PO_Group__c WHERE (Id != null) ORDER BY Name DESC  LIMIT 50000];
        List<Product2> prodTestList = [Select Id, Name FROM Product2 WHERE Name='Primary Link' Limit 1];
        System.debug('prodTestList '+prodTestList);
        
        List<ARTL_Legal_Entity__mdt> legalEntityTestList = [Select Id, ARTL_Legal_Entity__c, ARTL_Product__c FROM ARTL_Legal_Entity__mdt WHERE ARTL_Product__c=:prodTestList[0].Name];
        System.debug('legalEntityTestList '+legalEntityTestList);
        
        System.runAs(user){
            System.debug('poGroupList '+poGroupList);
            for(PO_Group__c poGroup :poGroupList){
                Map<String, String> nameIdMap = new Map<String, String>();
                nameIdMap.put('Name',poGroup.Name);
                nameIdMap.put('Id',poGroup.id);
                poGroupObjList.add(nameIdMap);
            }
            System.debug('poGroupObjList '+poGroupObjList);
            input.put('POGroup',poGroupObjList);
            
            for(ARTL_Legal_Entity__mdt legalEntity :legalEntityTestList){
                Map<String, String> nameIdLeMap = new Map<String, String>();
                nameIdLeMap.put('Name',legalEntity.ARTL_Legal_Entity__c);
                nameIdLeMap.put('Product',legalEntity.ARTL_Product__c);
                legalEntityObjList.add(nameIdLeMap);
            }
            System.debug('legalEntityObjList '+legalEntityObjList);
            input.put('LegalEntity',legalEntityObjList);
            
            System.debug('input '+input);
            Test.startTest();
            ARTL_QuoteEnrichMACDHandler qemh = new ARTL_QuoteEnrichMACDHandler();
            qemh.invokeMethod('LabelPOGroup',input,new Map<string,Object>{},new Map<string,Object>{});
            Test.stopTest();
        }
    }
    
    @isTest
    static void updateTestBASAForMACD(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User user = new User(LastName = 'Jackson2',FirstName='Michael', Alias = 'jl', Email = 'Michael.Jackson@testorg.com',
                             Username = 'Michael.Jackson2@testorg.com', ProfileId = profileId.id,TimeZoneSidKey = 'GMT', 
                             LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',LocaleSidKey = 'en_US');
        // string userId = UserInfo.getUserId();
        insert user;
        System.runAs(user){
            Test.startTest();
            
            List<Object> rowsListMap = new List<Object>();
            Map<String, String> billingStagingMap = new Map<String, String>();
            List<ARTL_Billing_Staging__c> bsList = [Select Id From ARTL_Billing_Staging__c LIMIT 1];
            System.debug('bsList '+bsList);
            billingStagingMap.put('BSId',bsList[0].Id);
            rowsListMap.add(billingStagingMap);
            
            Map<String,Object> gSTApplicableForBillingBlockMap=new Map<String,Object>{'GSTApplicableForBilling'=>'Billing GST'};
                Map<String,Object> legalEntityBlockMap = new Map<String,Object>{'LegalEntity'=>'Satcom Broadband Eqp Ltd'};
                Map<String,Object> billingDetailsBlockMap=new Map<String,Object>{'BillingLevel'=>'PO Level','Store'=>'BGL','CreditPeriod'=>'95 Percentile Carrier/BOD','BillType'=> 'Deemed','LegalEntity-Block'=>legalEntityBlockMap,'BillDispatchMethod'=>'CD','BillFrequency'=>'Daily'};  //              
                    Map<String,Object> billingContactPersonBlockMap=new Map<String,Object>{'BCPAltEmail' => 'iamsaurav9012@gmail.com',
                        'BCPFirstName' => 'Saurav',
                        'BCPEmail' => 'iamsaurav9012@gmail.com',
                        'BCPMobile' => '0807804529',
                        'BCPStreet' => 'delhi',
                        'BCPCity' => 'New Delhi',
                        'BCPCountry' => 'India',
                        'BCPLastName' => 'TV',
                        'BCPNumber' => 'BCP-00229',
                        'BCPState' => 'Delhi',
                        'BCPPostalCode' => '110031',
                        'BillingContactPerson' => 'BCP-00229 - Saurav TV - 0807804529 - iamsaurav9012@gmail.com - delhi - New Delhi - 110031 -'
                        };
                            Map<String,Object> billingContactsBlockMap=new Map<String,Object>{'CreateNewBillingContact'=> false,'BillingContactPerson-Block'=>billingContactPersonBlockMap};
                                
                                Map<String,Object> bsDetailsMap=new Map<String,Object>{'SelectGSTApplicableForBilling'=>true,'GSTApplicableForBillingBlock'=>gSTApplicableForBillingBlockMap,'UpdateBillingContacts'=>true,'BillingContactsBlock'=>billingContactsBlockMap,'UpdateBillingDetails'=>true,'BillingDetailsBlock'=>billingDetailsBlockMap};
                                    Map<String,Object> inputMap=new Map<String,Object>{'rows'=>rowsListMap,'bsDetails'=>bsDetailsMap};
                                        
                                        ARTL_QuoteEnrichMACDHandler qemh = new ARTL_QuoteEnrichMACDHandler();
            qemh.invokeMethod('UpdateBSDetials',inputMap,new Map<string,Object>{},new Map<string,Object>{});
            List<ARTL_Billing_Staging__c> basaList=[SELECT Id FROM ARTL_Billing_Staging__c];
            System.assertNotEquals(basaList.size(),0);
            Test.stopTest();
        }
    } 
}