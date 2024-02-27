@isTest
public class ARTL_B2BCmexTestDataFactory 
{
    //get the namespace of the org
    private static String nsPrefix = 'vlocity_cmt__';
    
    //This method should be called to create the test data.
    public static void setupData() 
    {
        createCPQConfiguration('B2BCmexEnterprisePPForQuoteMemberQLIs', 'true');

        Product2 product1 = new Product2(Name='Test JSON SiteProduct 1', 
                                        vlocity_cmt__SpecificationSubType__c = 'Offer', 
                                        ProductCode='PROD-002', 
                                        Description='This is a test JSON Product 1 Generator',
                                        vlocity_cmt__IsLocationDependent__c = true);
        insert product1;

        Product2 product2 = new Product2(Name='Test JSON SiteProduct 2',
                                        ProductCode='PROD-003', 
                                        Description='This is a test JSON Product 2',
                                        vlocity_cmt__IsLocationDependent__c = true);
        insert product2;

        Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(), 
                                                Name = 'TestPricebook', 
                                                IsActive = true);
        
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                                                Product2Id = product1.Id, 
                                                UnitPrice = 10, 
                                                vlocity_cmt__RecurringPrice__c = 5, 
                                                IsActive = true, UseStandardPrice = false);
        insert pbe1;

        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                                                Product2Id = product2.Id, 
                                                UnitPrice = 10, 
                                                vlocity_cmt__RecurringPrice__c = 5, 
                                                IsActive = true, 
                                                UseStandardPrice = false);
        insert pbe2;

        vlocity_cmt__PriceList__c priceList = new vlocity_cmt__PriceList__c(Name = 'B2B PriceList', 
                                                                            vlocity_cmt__Code__c = 'ABCD', 
                                                                            vlocity_cmt__Pricebook2Id__c = standardBook.Id);
        insert priceList;

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contract cont = new Contract(Name='Contract1',Description = 'test dec',ContractTerm = 20,StartDate=System.today().addDays(-10), Status='Draft', AccountId=testAccount.Id, vlocity_cmt__IsFrameContract__c=true);  
        insert cont;
        cont.Status = 'Activated';
        update cont;
        
        List<vlocity_cmt__ContractLineItem__c> contlist = new List<vlocity_cmt__ContractLineItem__c>();
        contlist.add(new vlocity_cmt__ContractLineItem__c(vlocity_cmt__EffectiveStartDate__c = System.today().addDays(-8), vlocity_cmt__EffectiveEndDate__c = system.today().addDays(1),vlocity_cmt__ContractId__c=cont.Id, vlocity_cmt__PricebookEntryId__c = pbe1.Id, vlocity_cmt__Product2Id__c = product1.Id,vlocity_cmt__Quantity__c = 1,vlocity_cmt__OneTimeCharge__c = 100, vlocity_cmt__RecurringCharge__c = 10));
        contlist.add(new vlocity_cmt__ContractLineItem__c(vlocity_cmt__EffectiveStartDate__c = System.today().addDays(-7), vlocity_cmt__EffectiveEndDate__c = system.today().addDays(3),vlocity_cmt__ContractId__c=cont.Id, vlocity_cmt__PricebookEntryId__c = pbe1.Id, vlocity_cmt__Product2Id__c= product1.Id,vlocity_cmt__Quantity__c = 1, vlocity_cmt__OneTimeCharge__c = 40, vlocity_cmt__RecurringCharge__c =20));
        contlist.add(new vlocity_cmt__ContractLineItem__c(vlocity_cmt__EffectiveStartDate__c = System.today().addDays(-7), vlocity_cmt__EffectiveEndDate__c = system.today().addDays(3),vlocity_cmt__ContractId__c=cont.Id, vlocity_cmt__PricebookEntryId__c = pbe1.Id, vlocity_cmt__Product2Id__c= product1.Id,vlocity_cmt__Quantity__c = 1, vlocity_cmt__OneTimeCharge__c = 40, vlocity_cmt__RecurringCharge__c =15));
        contlist.add(new vlocity_cmt__ContractLineItem__c(vlocity_cmt__EffectiveStartDate__c = System.today().addDays(-6), vlocity_cmt__EffectiveEndDate__c = system.today().addDays(3),vlocity_cmt__ContractId__c=cont.Id, vlocity_cmt__PricebookEntryId__c = pbe1.Id, vlocity_cmt__Product2Id__c= product1.Id,vlocity_cmt__Quantity__c = 1, vlocity_cmt__OneTimeCharge__c = 20));
        contlist.add(new vlocity_cmt__ContractLineItem__c(vlocity_cmt__EffectiveStartDate__c = System.today().addDays(-5), vlocity_cmt__EffectiveEndDate__c = system.today().addDays(3),vlocity_cmt__ContractId__c=cont.Id, vlocity_cmt__PricebookEntryId__c = pbe1.Id, vlocity_cmt__Product2Id__c= product1.Id,vlocity_cmt__Quantity__c = 1, vlocity_cmt__OneTimeCharge__c = 40));
        insert contlist;

        Opportunity testOpportunity = new Opportunity(Name = 'Test Opporunity', 
                                                    AccountId = testAccount.Id, 
                                                    closeDate = Date.TODAY(), 
                                                    StageName = 'Prospecting', 
                                                    Pricebook2Id =  standardBook.Id);
        insert testOpportunity;

        Quote testQuote = new Quote(Status = 'Draft', 
                                    OpportunityId = testOpportunity.Id, 
                                    Name = 'Test Quote', 
                                    vlocity_cmt__OriginatingChannel__c = 'Retail', 
                                    vlocity_cmt__PriceListId__c = priceList.Id,
                                    RecordTypeId = getRecordTypeIdByName('Quote', 'EnterpriseQuote')
                                );
        insert testQuote;

        // creating quote to test testCalculateQPRollups
        Quote rollupQuote1 = new Quote(Status = 'Draft', 
                                    OpportunityId = testOpportunity.Id, 
                                    Name = 'Test Rollup Quote', 
                                    vlocity_cmt__OriginatingChannel__c = 'Retail', 
                                    vlocity_cmt__PriceListId__c = priceList.Id,
                                    RecordTypeId = getRecordTypeIdByName('Quote', 'EnterpriseQuote')
                                );
        insert rollupQuote1;
        
        Product2 testprod1 = new Product2 (Name='Triple Play Bundle Small', ProductCode = 'VLO-BUN-0001', vlocity_cmt__AttributeMetadata__c = 'TestAttributeMetadata1', vlocity_cmt__isLocationDependent__c = true);
        insert testprod1;

        vlocity_cmt__QuoteProductRollup__c rollupTest = new vlocity_cmt__QuoteProductRollup__c(
                                                                vlocity_cmt__TotalQuoteQuantity__c = 0,
                                                                vlocity_cmt__TotalAssetQuantity__c = 0,
                                                                vlocity_cmt__DiscountQuantity__c = 0,
                                                                vlocity_cmt__QuoteId__c = rollupQuote1.Id,
                                                                vlocity_cmt__RollupType__c = 'Total Quote Rollup',
                                                                vlocity_cmt__ProductId__c = testprod1.Id
                                                                );
        insert rollupTest;

        QuoteLineItem rollupTestQLI = new QuoteLineItem(QuoteId = rollupQuote1.Id,
                                                    vlocity_cmt__LineNumber__c = '1',
                                                    Quantity = 2,
                                                    vlocity_cmt__UsageUnitPrice__c = 200,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    UnitPrice = 200,
                                                    PricebookEntryId = pbe1.Id,
                                                    vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}'
                                                    );
        insert rollupTestQLI;

         //creating order item to test disconnect line item
        Order disconnectOrder = new Order(Status = 'Draft', 
                                    Name = 'Test Order', 
                                    AccountId = testAccount.Id,
                                    EffectiveDate = System.today(),
                                    Pricebook2Id =  standardBook.Id,
                                    vlocity_cmt__PriceListId__c = priceList.Id
                                );
        insert disconnectOrder;

        OrderItem disconnectOrderItem = new OrderItem(OrderId = disconnectOrder.Id, 
                                            vlocity_cmt__LineNumber__c = '1',
                                            Quantity = 1,
                                            vlocity_cmt__UsageUnitPrice__c = 200,
                                            vlocity_cmt__Action__c = 'Add',
                                            UnitPrice = 200,
                                            PricebookEntryId = pbe1.Id,
                                            vlocity_cmt__ParentItemId__c = NULL
                                        );

        insert disconnectOrderItem;

        // creating order to test testCalculateOPRollups
        Order rollupOrder1 = new Order(Status = 'Draft', 
                                    Name = 'Test Order Rollup', 
                                    AccountId = testAccount.Id,
                                    EffectiveDate = System.today(),
                                    Pricebook2Id =  standardBook.Id,
                                    vlocity_cmt__PriceListId__c = priceList.Id
                                );
        insert rollupOrder1;
        
        vlocity_cmt__OrderProductRollup__c orderRollupTest = new vlocity_cmt__OrderProductRollup__c(
                                                                vlocity_cmt__TotalOrderQuantity__c = 2,
                                                                vlocity_cmt__OrderId__c = rollupOrder1.Id,
                                                                vlocity_cmt__RollupType__c = 'Total Order Rollup',
                                                                vlocity_cmt__ProductId__c = testprod1.Id,
                                                                vlocity_cmt__TotalAssetQuantity__c = 0,
                                                                vlocity_cmt__DiscountQuantity__c = 5
                                                            );
        insert orderRollupTest;

        OrderItem rollupTestOLI = new OrderItem(OrderId = rollupOrder1.Id, 
                                                    vlocity_cmt__LineNumber__c = '1',
                                                    Quantity = 2,
                                                    vlocity_cmt__UsageUnitPrice__c = 200,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    UnitPrice = 200,
                                                    PricebookEntryId = pbe1.Id
                                                    );
        insert rollupTestOLI;

        Order testOrder = new Order(Status = 'Draft', 
                                    Name = 'Test CPQ Order', 
                                    AccountId = testAccount.Id,
                                    EffectiveDate = System.today(),
                                    Pricebook2Id =  standardBook.Id,
                                    vlocity_cmt__PriceListId__c = priceList.Id
                                );
        insert testOrder;

        Opportunity testCPQOpportunity = new Opportunity(Name = 'Test CPQ Opportunity', 
                                                    AccountId = testAccount.Id, 
                                                    closeDate = Date.TODAY(), 
                                                    StageName = 'Prospecting', 
                                                    Pricebook2Id =  standardBook.Id);
        insert testCPQOpportunity;

        vlocity_cmt__Promotion__c promotion = new vlocity_cmt__Promotion__c(Name = 'TestPromo', vlocity_cmt__Code__c = 'xxxx');
        Insert promotion;
        
        prepareQuoteDiscounts(testQuote.Id, null);

        vlocity_cmt__OrderDiscount__c approvedDiscount = new vlocity_cmt__OrderDiscount__c(
            vlocity_cmt__ApprovalStatus__c='Approved',
            Name='Approved Discount',
            vlocity_cmt__OrderId__c=testOrder.Id);
        insert approvedDiscount;

        vlocity_cmt__OpportunityDiscount__c approvedOpptDiscount = new vlocity_cmt__OpportunityDiscount__c(
            vlocity_cmt__ApprovalStatus__c='Approved',
            Name='Approved Discount',
            vlocity_cmt__OpportunityId__c=testCPQOpportunity.Id);
        insert approvedOpptDiscount;    

        OrderItem parentOLI = new OrderItem(OrderId = testOrder.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '1',
                                                    Quantity = 10,
                                                    vlocity_cmt__UsageUnitPrice__c = 200,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    UnitPrice = 200,
                                                    PricebookEntryId = pbe1.Id
                                                    );
        insert parentOLI;

        vlocity_cmt__OrderProductRollup__c orderRollup = new vlocity_cmt__OrderProductRollup__c(
                                                                vlocity_cmt__TotalOrderQuantity__c = 2,
                                                                vlocity_cmt__OrderId__c = testOrder.Id,
                                                                vlocity_cmt__RollupType__c = 'Total Order Rollup',
                                                                vlocity_cmt__ProductId__c = product2.Id,
                                                                vlocity_cmt__TotalAssetQuantity__c = 0,
                                                                vlocity_cmt__DiscountQuantity__c = 5
                                                            );
        insert orderRollup;

        vlocity_cmt__AttributeCategory__c attributeCategory1 = new vlocity_cmt__AttributeCategory__c(
            vlocity_cmt__isActive__c = true, vlocity_cmt__Code__c ='VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS', vlocity_cmt__ApplicableSubType__c ='Profile Attribute', 
            vlocity_cmt__ApplicableTypes__c = 'Any', vlocity_cmt__DisplaySequence__c =1
        );

        insert attributeCategory1;

        List<vlocity_cmt__Attribute__c> allAtts= new List<vlocity_cmt__Attribute__c>();
        allAtts.add(new vlocity_cmt__Attribute__c(Name='Test Attribute Name 1',vlocity_cmt__DisplaySequence__c = 1, vlocity_cmt__AttributeCategoryId__c = attributeCategory1.Id, vlocity_cmt__Code__c='VEPC_ATTR_UNI_DEPLOYMENT_OPTION'));
        allAtts.add(new vlocity_cmt__Attribute__c(Name='Test Attribute Name 2',vlocity_cmt__DisplaySequence__c = 2, vlocity_cmt__AttributeCategoryId__c = attributeCategory1.Id, vlocity_cmt__Code__c='VEPC_ATTR_UNI_HANDOVER_DETAILS'));
        insert allAtts; 

        QuoteLineItem parentQLI = new QuoteLineItem(QuoteId = testQuote.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    Product2Id = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '1',
                                                    Quantity = 2,
                                                    vlocity_cmt__UsageUnitPrice__c = 200,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    UnitPrice = 200,
                                                    PricebookEntryId = pbe1.Id,
                                                    vlocity_cmt__ConnectDate__c = System.now(),
                                                    vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}'
                                                    );
        insert parentQLI;

        QuoteLineItem childQLI = new QuoteLineItem(QuoteId = testQuote.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    Product2Id = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '2',
                                                    Quantity = 1,
                                                    vlocity_cmt__UsageUnitPrice__c = 50,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    vlocity_cmt__RootItemId__c = parentQLI.Id,
                                                    vlocity_cmt__ParentItemId__c = parentQLI.Id,
                                                    UnitPrice = 50,
                                                    PricebookEntryId = pbe1.Id,
                                                    vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}',
                                                    vlocity_cmt__ConnectDate__c = System.now()
                                                    );
        insert childQLI;

        QuoteLineItem childQLIProduct2 = new QuoteLineItem(QuoteId = testQuote.Id, 
                                                    vlocity_cmt__Product2Id__c = product1.Id,
                                                    Product2Id = product1.Id,
                                                    vlocity_cmt__LineNumber__c = '2',
                                                    Quantity = 1,
                                                    vlocity_cmt__UsageUnitPrice__c = 50,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    vlocity_cmt__RootItemId__c = parentQLI.Id,
                                                    vlocity_cmt__ParentItemId__c = parentQLI.Id,
                                                    UnitPrice = 50,
                                                    PricebookEntryId = pbe1.Id,
                                                    vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}',
                                                    vlocity_cmt__ConnectDate__c = System.now()
                                                    );
        insert childQLIProduct2;

        OrderItem childOLI = new OrderItem(OrderId = testOrder.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    Product2Id = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '2',
                                                    Quantity = 1,
                                                    vlocity_cmt__UsageUnitPrice__c = 50,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    vlocity_cmt__RootItemId__c = parentOLI.Id,
                                                    vlocity_cmt__ParentItemId__c = parentOLI.Id,
                                                    UnitPrice = 50,
                                                    PricebookEntryId = pbe1.Id
                                                    );
        insert childOLI;

        OpportunityLineItem parentOpptLI = new OpportunityLineItem(OpportunityId = testCPQOpportunity.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    Product2Id = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '1',
                                                    Quantity = 10,
                                                    vlocity_cmt__UsageUnitPrice__c = 200,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    UnitPrice = 200,
                                                    PricebookEntryId = pbe1.Id,
                                                    vlocity_cmt__ConnectDate__c = System.now()
                                                    );
        insert parentOpptLI;

        OpportunityLineItem childOpptLI = new OpportunityLineItem(OpportunityId = testCPQOpportunity.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    Product2Id = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '2',
                                                    Quantity = 1,
                                                    vlocity_cmt__UsageUnitPrice__c = 50,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    vlocity_cmt__RootItemId__c = parentOpptLI.Id,
                                                    vlocity_cmt__ParentItemId__c = parentOpptLI.Id,
                                                    UnitPrice = 50,
                                                    PricebookEntryId = pbe1.Id,
                                                    vlocity_cmt__ConnectDate__c = System.now()
                                                    );
        insert childOpptLI;

        OpportunityLineItem childOpptLI2 = new OpportunityLineItem(OpportunityId = testCPQOpportunity.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    Product2Id = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '2',
                                                    Quantity = 1,
                                                    vlocity_cmt__UsageUnitPrice__c = 50,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    vlocity_cmt__ParentItemId__c = parentOpptLI.Id,
                                                    vlocity_cmt__RootItemId__c = parentOpptLI.Id,
                                                    UnitPrice = 50,
                                                    PricebookEntryId = pbe1.Id,
                                                    vlocity_cmt__ConnectDate__c = System.now()
                                                    );
        insert childOpptLI2;

        vlocity_cmt__QuoteProductRollup__c rollup = new vlocity_cmt__QuoteProductRollup__c(
                                                                vlocity_cmt__TotalQuoteQuantity__c = 3,
                                                                vlocity_cmt__QuoteId__c = testQuote.Id,
                                                                vlocity_cmt__RollupType__c = 'Total Quote Rollup',
                                                                vlocity_cmt__ProductId__c = product2.Id,
                                                                vlocity_cmt__TotalAssetQuantity__c = 0,
                                                                vlocity_cmt__DiscountQuantity__c = 5
                                                            );
        insert rollup;

        vlocity_cmt__PriceList__c p1 = new vlocity_cmt__PriceList__c(Name = 'P1', vlocity_cmt__Code__c = 'P1');
        insert p1;

        vlocity_cmt__PriceListEntry__c pe1 = new vlocity_cmt__PriceListEntry__c(Name = p1.Name, vlocity_cmt__PriceListId__c = p1.Id, vlocity_cmt__ProductId__c = product2.Id);
        insert pe1;
        
        


        insert new vlocity_cmt__QuotePricingAdjustment__c(vlocity_cmt__QuoteId__c = testQuote.Id, vlocity_cmt__QuoteItemId__c = parentQLI.Id, vlocity_cmt__PriceListEntryId__c = pe1.Id);
        insert new vlocity_cmt__QuotePricingAdjustment__c(vlocity_cmt__QuoteId__c = testQuote.Id, vlocity_cmt__QuoteItemId__c = childQLI.Id, vlocity_cmt__PriceListEntryId__c = pe1.Id);
        
        Quote clonedQuote1 = testQuote.clone(false, false, false, false);
        clonedQuote1.Name = 'Group Cart 1';
        insert clonedQuote1;

        QuoteLineItem workingCartQLI = new QuoteLineItem(QuoteId = clonedQuote1.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    Product2Id = product2.Id,
                                                    Quantity = 2,
                                                    vlocity_cmt__UsageUnitPrice__c = 200,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    UnitPrice = 200,
                                                    PricebookEntryId = pbe1.Id,
                                                    vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}',
                                                    vlocity_cmt__ParentItemId__c = null
                                                    );
        insert workingCartQLI;
        

        vlocity_cmt__Promotion__c promotion2 = new vlocity_cmt__Promotion__c(Name = 'TestPromo2', vlocity_cmt__Code__c = 'xxxx');
        Insert promotion2;

        vlocity_cmt__QuoteDiscount__c quoteDiscount2 = new vlocity_cmt__QuoteDiscount__c(
                vlocity_cmt__QuoteId__c = clonedQuote1.Id,
                vlocity_cmt__Description__c = 'quote discount',
                vlocity_cmt__DiscountTemplateId__c = promotion2.Id,
                vlocity_cmt__EffectiveEndDate__c = System.today(),
                vlocity_cmt__EffectiveStartDate__c = System.today() - 1,
                vlocity_cmt__ReferenceNumber__c = '666666666',
                vlocity_cmt__Action__c = 'Deactivate'
        );
        insert quoteDiscount2;


        vlocity_cmt__QuoteAppliedPromotion__c clonedQuoteAppliedPromotion1 = new vlocity_cmt__QuoteAppliedPromotion__c(
            vlocity_cmt__QuoteId__c = clonedQuote1.Id, 
            Name = 'Test', 
            vlocity_cmt__Action__c = 'Add',
            vlocity_cmt__PromotionId__c=promotion2.Id
        );
        insert clonedQuoteAppliedPromotion1;

        insert new vlocity_cmt__QuotePricingAdjustment__c(
            vlocity_cmt__QuoteId__c = clonedQuote1.Id, 
            vlocity_cmt__QuoteItemId__c = workingCartQLI.Id, 
            vlocity_cmt__PriceListEntryId__c = pe1.Id,
            vlocity_cmt__QuoteAppliedPromotionId__c = clonedQuoteAppliedPromotion1.Id
        );

        vlocity_cmt__QuoteAppliedPromotionItem__c clonedQuoteAppliedPromotionAffected = new vlocity_cmt__QuoteAppliedPromotionItem__c(
            vlocity_cmt__QuoteAppliedPromotionId__c = clonedQuoteAppliedPromotion1.Id,
            vlocity_cmt__QuoteLineItemId__c = workingCartQLI.Id
        );
        
        insert clonedQuoteAppliedPromotionAffected;
        

        Order clonedOrder1 = testOrder.clone(false, false, false, false);
        clonedOrder1.Name = 'CPQ Group Cart Order1';
        insert clonedOrder1;

        Opportunity clonedOpportunity1 = testCPQOpportunity.clone(false, false, false, false);
        clonedOpportunity1.Name = 'CPQ Group Cart Opportunity1';
        insert clonedOpportunity1;

        vlocity_cmt__OrderDiscount__c approvedDiscount2 = new vlocity_cmt__OrderDiscount__c(
            vlocity_cmt__ApprovalStatus__c='Approved',
            Name='Approved Discount',
            vlocity_cmt__OrderId__c=clonedOrder1.Id);
        insert approvedDiscount2; 

        vlocity_cmt__OrderAppliedPromotion__c clonedOrderAppliedPromotion1 = new vlocity_cmt__OrderAppliedPromotion__c(
            vlocity_cmt__OrderId__c = clonedOrder1.Id, 
            Name = 'Test Order Promo', 
            vlocity_cmt__Action__c = 'Add',
            vlocity_cmt__PromotionId__c=promotion2.Id
        );
        insert clonedOrderAppliedPromotion1;

        OrderItem parentClonedOLI1 = new OrderItem(OrderId = clonedOrder1.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '1',
                                                    Quantity = 2,
                                                    vlocity_cmt__UsageUnitPrice__c = 200,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    UnitPrice = 200,
                                                    PricebookEntryId = pbe1.Id
                                                    );
        insert parentClonedOLI1;

        QuoteLineItem parentClonedQLI1 = new QuoteLineItem(QuoteId = clonedQuote1.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    Product2Id = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '1',
                                                    Quantity = 2,
                                                    vlocity_cmt__UsageUnitPrice__c = 200,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    UnitPrice = 200,
                                                    vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}',
                                                    PricebookEntryId = pbe1.Id
                                                    );
        insert parentClonedQLI1;

        QuoteLineItem childClonedQLI1 = new QuoteLineItem(QuoteId = clonedQuote1.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    Product2Id = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '2',
                                                    Quantity = 1,
                                                    vlocity_cmt__UsageUnitPrice__c = 50,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    vlocity_cmt__RootItemId__c = parentClonedQLI1.Id,
                                                    vlocity_cmt__ParentItemId__c = parentClonedQLI1.Id,
                                                    UnitPrice = 50,
                                                    vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}',
                                                    PricebookEntryId = pbe1.Id
                                                    );
        insert  childClonedQLI1;                                           

        QuoteLineItem childClonedQLI12 = new QuoteLineItem(QuoteId = clonedQuote1.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    Product2Id = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '3',
                                                    Quantity = 1,
                                                    vlocity_cmt__UsageUnitPrice__c = 50,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    UnitPrice = 50,
                                                    vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}',
                                                    PricebookEntryId = pbe1.Id
                                                    );
        insert childClonedQLI12;
        
        vlocity_cmt__Promotion__c promo1 = new vlocity_cmt__Promotion__c(Name='Promo1', vlocity_cmt__Code__c='Promo1');
        insert promo1;

        insert new vlocity_cmt__OrderPriceAdjustment__c(vlocity_cmt__OrderId__c = testOrder.Id, vlocity_cmt__OrderItemId__c = parentOLI.Id, vlocity_cmt__PriceListEntryId__c = pe1.Id);
        insert new vlocity_cmt__OrderPriceAdjustment__c(vlocity_cmt__OrderId__c = testOrder.Id, vlocity_cmt__OrderItemId__c = childOLI.Id, vlocity_cmt__PriceListEntryId__c = pe1.Id);
        insert new vlocity_cmt__OrderPriceAdjustment__c(vlocity_cmt__OrderId__c = clonedOrder1.Id, vlocity_cmt__OrderItemId__c = parentClonedOLI1.Id, vlocity_cmt__PriceListEntryId__c = pe1.Id);

        insert new vlocity_cmt__OpportunityPriceAdjustment__c(vlocity_cmt__OpportunityId__c = testCPQOpportunity.Id, vlocity_cmt__OpportunityLineItemId__c = parentOpptLI.Id, vlocity_cmt__PriceListEntryId__c = pe1.Id);
        insert new vlocity_cmt__OpportunityPriceAdjustment__c(vlocity_cmt__OpportunityId__c = testCPQOpportunity.Id, vlocity_cmt__OpportunityLineItemId__c = childOpptLI.Id, vlocity_cmt__PriceListEntryId__c = pe1.Id);

        Quote clonedQuote2 = testQuote.clone(false, false, false, false);
        clonedQuote2.Name = 'Group Cart 2';
        insert clonedQuote2;
        
        vlocity_cmt__QuoteAppliedPromotion__c quoteAppliedPromotion1 = new vlocity_cmt__QuoteAppliedPromotion__c(
            vlocity_cmt__QuoteId__c = testQuote.Id, 
            Name = 'Test', 
            vlocity_cmt__Action__c = 'Add',
            vlocity_cmt__PromotionId__c=promo1.Id
        );
        insert quoteAppliedPromotion1;
        
        vlocity_cmt__QuoteAppliedPromotionItem__c quoteAppliedPromotionItem1 = new vlocity_cmt__QuoteAppliedPromotionItem__c(
            vlocity_cmt__QuoteAppliedPromotionId__c = quoteAppliedPromotion1.Id, 
            Name = 'Test', 
            vlocity_cmt__QuoteLineItemId__c = parentQLI.Id);
        insert quoteAppliedPromotionItem1;
        
        vlocity_cmt__OrderAppliedPromotion__c orderAppliedPromotion1 = new vlocity_cmt__OrderAppliedPromotion__c(
            vlocity_cmt__OrderId__c = testOrder.Id, 
            Name = 'Test Order Promo', 
            vlocity_cmt__Action__c = 'Add',
            vlocity_cmt__PromotionId__c=promo1.Id
        );
        insert orderAppliedPromotion1;

        vlocity_cmt__OrderAppliedPromotionItem__c orderAppliedPromotionItem1 = new vlocity_cmt__OrderAppliedPromotionItem__c(
            vlocity_cmt__OrderAppliedPromotionId__c = orderAppliedPromotion1.Id, 
            Name = 'Test Order Promo', 
            vlocity_cmt__OrderItemId__c = parentOLI.Id);
        insert orderAppliedPromotionItem1;
        
        vlocity_cmt__QuoteGroup__c testGroup = new vlocity_cmt__QuoteGroup__c(Name = 'Test Group', vlocity_cmt__QuoteId__c = testQuote.Id, vlocity_cmt__ExpectedMemberCount__c = 4);
        insert testGroup;

        QuoteLineItem groupQLI = new QuoteLineItem(
                                                    QuoteId = testQuote.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    Product2Id = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '1',
                                                    Quantity = 2,
                                                    vlocity_cmt__UsageUnitPrice__c = 200,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    UnitPrice = 200,
                                                    PricebookEntryId = pbe1.Id,
                                                    vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}',
                                                    vlocity_cmt__QuoteGroupId__c = testGroup.Id
                                                );
        insert groupQLI;

        insert new vlocity_cmt__QuotePricingAdjustment__c(vlocity_cmt__QuoteId__c = testQuote.Id, vlocity_cmt__QuoteItemId__c = groupQLI.Id, vlocity_cmt__PriceListEntryId__c = pe1.Id);

        vlocity_cmt__Promotion__c promo2 = new vlocity_cmt__Promotion__c(Name='Promo2', vlocity_cmt__Code__c='Promo2');
        insert promo2;

        vlocity_cmt__QuoteAppliedPromotion__c quoteAppliedPromotion2 = new vlocity_cmt__QuoteAppliedPromotion__c(
            vlocity_cmt__QuoteId__c = testQuote.Id, 
            Name = 'Test2', 
            vlocity_cmt__Action__c = 'Add',
            vlocity_cmt__PromotionId__c=promo2.Id
        );
        insert quoteAppliedPromotion2;
        
        vlocity_cmt__QuoteAppliedPromotionItem__c quoteAppliedPromotionItem2 = new vlocity_cmt__QuoteAppliedPromotionItem__c(
            vlocity_cmt__QuoteAppliedPromotionId__c = quoteAppliedPromotion2.Id, 
            Name = 'Test', 
            vlocity_cmt__QuoteLineItemId__c = groupQLI.Id);
        insert quoteAppliedPromotionItem2;

        createQuoteMembers(testQuote.Id, 'Test Member', testGroup.Id, 2, 'Location');

        vlocity_cmt__OrderGroup__c testOrderGroup = new vlocity_cmt__OrderGroup__c(Name = 'Test Order Group', vlocity_cmt__OrderId__c = testOrder.Id);
        insert testOrderGroup;

        OrderItem groupOLI = new OrderItem(
                                                    OrderId = testOrder.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '1',
                                                    Quantity = 10,
                                                    vlocity_cmt__UsageUnitPrice__c = 200,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    UnitPrice = 200,
                                                    PricebookEntryId = pbe1.Id,
                                                    vlocity_cmt__OrderGroupId__c = testOrderGroup.Id
                                                );
        insert groupOLI;

        createOrderMembers(testOrder.Id, testOrderGroup.Id, 2, 'Location');

        vlocity_cmt__OpportunityGroup__c testOpptGroup = new vlocity_cmt__OpportunityGroup__c(Name = 'Test Oppt Group',vlocity_cmt__OpportunityId__c = testCPQOpportunity.Id);
        insert testOpptGroup;

        OpportunityLineItem groupOpptLI = new OpportunityLineItem(
                                                    OpportunityId = testCPQOpportunity.Id, 
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '1',
                                                    Quantity = 10,
                                                    vlocity_cmt__UsageUnitPrice__c = 200,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    UnitPrice = 200,
                                                    PricebookEntryId = pbe1.Id,
                                                    vlocity_cmt__OpportunityGroupId__c = testOpptGroup.Id
                                                );
        insert groupOpptLI;

        createOpptMembers(testCPQOpportunity.Id, testOpptGroup.Id, 2, 'Location');

        Order masterOrder = new Order(
            Name = 'Master Order',
            Pricebook2Id = standardBook.Id,
            AccountId = testAccount.Id,
            Status = 'Draft',
            EffectiveDate = date.today(),
            OpportunityId = testOpportunity.Id,
            vlocity_cmt__QuoteId__c = testQuote.Id,
            RecordTypeId = getRecordTypeIdByName('Order', 'MasterOrder')
        );
        insert masterOrder;

        createSubOrders(masterOrder, 1, testAccount, testQuote);

        // Creating asset test data
        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset(
            Name = 'Factory Test asset',
            AccountId = testAccount.Id,
            Product2Id = product1.Id,
            vlocity_cmt__PricebookEntryId__c = pbe1.Id,
            Quantity = 1,
            Price = 100.00,
            vlocity_cmt__LineNumber__c = '0001',
            vlocity_cmt__ProvisioningStatus__c = 'New',
            vlocity_cmt__ServiceAccountId__c = testAccount.Id,
            vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}'
        );
        Asset asset2 = new Asset(
            Name = 'Factory Test asset 2',
            AccountId = testAccount.Id,
            Product2Id = product1.Id,
            vlocity_cmt__PricebookEntryId__c = pbe1.Id,
            Quantity = 1,
            Price = 200.00,
            vlocity_cmt__LineNumber__c = '0002',
            vlocity_cmt__ProvisioningStatus__c = 'New',
            vlocity_cmt__ServiceAccountId__c = testAccount.Id,
            vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}'
        );
        Asset asset3 = new Asset(
            Name = 'Factory Test asset 3',
            AccountId = testAccount.Id,
            Product2Id = product1.Id,
            vlocity_cmt__PricebookEntryId__c = pbe1.Id,
            Quantity = 1,
            Price = 300.00,
            vlocity_cmt__LineNumber__c = '0003',
            vlocity_cmt__ProvisioningStatus__c = 'New',
            vlocity_cmt__ServiceAccountId__c = testAccount.Id,
            vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}'
        );
        assets.add(asset1);
        assets.add(asset2);
        assets.add(asset3);
        insert assets;

        //Test Data for Asset Relationships
        
        List<AssetRelationship> assetRelationships = new List<AssetRelationship>();

        AssetRelationship assetRelationship1 = new AssetRelationship(AssetId=asset1.Id, RelatedAssetId=asset2.Id,
                                            RelationshipType='ReliesOn');
        AssetRelationship assetRelationship2 = new AssetRelationship(AssetId=asset2.Id, RelatedAssetId=asset3.Id,
                                            RelationshipType='ReliesOn');

        assetRelationships.add(assetRelationship1);
        assetRelationships.add(assetRelationship2);       

        insert assetRelationships;

        //Added For Enterprise Order
        Id recordTypeId = getRecordTypeIdByName('Order', 'EnterpriseOrder');
        Order testEntOrder = new Order(Status = 'Draft', 
                      Name = 'Test Enterprise Order', 
                      AccountId = testAccount.Id,
                      EffectiveDate = System.today(),
                      Pricebook2Id =  standardBook.Id,
                      vlocity_cmt__PriceListId__c = priceList.Id,
                      RecordTypeId =recordTypeId
                  );
        insert testEntOrder;

        OrderItem testEntOrderOLI = new OrderItem(OrderId = testEntOrder.Id, 
                      vlocity_cmt__Product2Id__c = product2.Id,
                      vlocity_cmt__LineNumber__c = '1',
                      Quantity = 10,
                      vlocity_cmt__UsageUnitPrice__c = 200,
                      vlocity_cmt__Action__c = 'Add',
                      UnitPrice = 200,
                      PricebookEntryId = pbe1.Id
                      );
        insert testEntOrderOLI;

        OrderItem testEntOrderOLI2 = new OrderItem(OrderId = testEntOrder.Id, 
                      vlocity_cmt__Product2Id__c = product1.Id,
                      vlocity_cmt__LineNumber__c = '1',
                      Quantity = 10,
                      vlocity_cmt__UsageUnitPrice__c = 200,
                      vlocity_cmt__Action__c = 'Add',
                      UnitPrice = 200,
                      PricebookEntryId = pbe1.Id
                      );
        insert testEntOrderOLI2;

        vlocity_cmt__OrderGroup__c testEntOrderGroup = new vlocity_cmt__OrderGroup__c(Name = 'Test Enterprise Order Group', vlocity_cmt__OrderId__c = testEntOrder.Id);
        insert testEntOrderGroup;

        OrderItem entGroupOLI = new OrderItem(
                      OrderId = testEntOrder.Id, 
                      vlocity_cmt__Product2Id__c = product2.Id,
                      vlocity_cmt__LineNumber__c = '1',
                      Quantity = 10,
                      vlocity_cmt__UsageUnitPrice__c = 200,
                      vlocity_cmt__Action__c = 'Add',
                      UnitPrice = 200,
                      PricebookEntryId = pbe1.Id,
                      vlocity_cmt__OrderGroupId__c = testEntOrderGroup.Id
                  );
        insert entGroupOLI;

        createOrderMembers(testEntOrder.Id, testEntOrderGroup.Id, 2, 'Location');
        createOrderMembers('EOrderMember', testEntOrder.Id, null, 2, 'Location');
 }

    public static void createSubOrders(Order masterOrder, Integer num, Account account, Quote quote)
    {
        List<Order> orders = new List<Order>();
        Id recordTypeId = getRecordTypeIdByName('Order', 'SubOrder');
        for(Integer i=1; i <=num; i++)
        {
            Order subOrder = new Order(
                AccountId = account.Id,
                Name = quote.Name,
                vlocity_cmt__PriceListId__c = quote.vlocity_cmt__PriceListId__c,
                Pricebook2Id = masterOrder.PriceBook2Id,
                EffectiveDate = System.today(),
                Status = 'Draft',
                vlocity_cmt__QuoteId__c = quote.Id,
                vlocity_cmt__ParentOrderId__c = masterOrder.Id,
                RecordTypeId = recordTypeId
            );
            orders.add(subOrder);
        }
        insert orders;
    }

    public static void prepareQuoteDiscounts(String QuoteId, String ProductId) 
    {
        vlocity_cmt__QuoteDiscount__c discount = new vlocity_cmt__QuoteDiscount__c
        (
            vlocity_cmt__ApprovalStatus__c = 'Approved',
            Name = 'Test Discount',
            vlocity_cmt__DiscountType__c = 'Order',
            vlocity_cmt__Action__c = 'New',
            vlocity_cmt__QuoteId__c = QuoteId
        );
        insert discount;

        if(String.isEmpty(ProductId))
        {
            vlocity_cmt__QuoteDiscountItem__c discountItem = new vlocity_cmt__QuoteDiscountItem__c
            (
                Name = 'Test Discount Item',
                vlocity_cmt__QuoteDiscountId__c = discount.Id,
                vlocity_cmt__ProductId__c = ProductId
            );
            insert discountItem;

            vlocity_cmt__PricingVariable__c pricingVariable = new vlocity_cmt__PricingVariable__c
            (
                Name='One Time Std Price',
                vlocity_cmt__Code__c='OT_STD_PRC',
                vlocity_cmt__AdjustmentMethod__c='Percent',
                vlocity_cmt__IsActive__c=True,
                vlocity_cmt__Aggregation__c='Unit',
                vlocity_cmt__ChargeType__c='One-time',
                vlocity_cmt__ValueType__c='Pricing Element',
                vlocity_cmt__Type__c='Price',
                vlocity_cmt__SubType__c='Standard',
                vlocity_cmt__Scope__c='Line',
                vlocity_cmt__CurrencyType__c='Currency'
            );
            insert pricingVariable;

            vlocity_cmt__QuoteDiscountPricing__c pricing = new vlocity_cmt__QuoteDiscountPricing__c
            (
                Name = '5% off monthly',
                vlocity_cmt__AdjustmentValue__c = -5.00,
                vlocity_cmt__PricingVariableId__c = pricingVariable.Id,
                vlocity_cmt__QuoteDiscountId__c = discount.Id
            );
            insert pricing;
        }
    }

    public static void createEligibilityMatrix() 
    {
        String calMatrixName = 'ProductEligibilityMatrix';
        createCPQConfiguration('B2BCmexEligibilityMatrixName', calMatrixName);

        vlocity_cmt__CalculationMatrix__c parent = new vlocity_cmt__CalculationMatrix__c(Name = 'ProductEligibilityMatrix');
        insert parent;

        vlocity_cmt__CalculationMatrixVersion__c version = new vlocity_cmt__CalculationMatrixVersion__c
        (
            Name='Version',
            vlocity_cmt__VersionNumber__c = 2,
            vlocity_cmt__IsEnabled__c=false,
            vlocity_cmt__CalculationMatrixId__c=parent.Id,
            vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-20),
            vlocity_cmt__EndDateTime__c = DateTime.now().addDays(20),
            vlocity_cmt__Priority__c=2
        );
        insert version;
        
        List<vlocity_cmt__CalculationMatrixRow__c> lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();

        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
            vlocity_cmt__InputData__c = '{"columnKey":"2095dd","dataType":"Text","displayOrder":3,"headerType":"Output","label":null,"lineItemId":"a1r4x000000UQiZAAW","listValues":null,"name":"Result"}'
        ));

        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
            vlocity_cmt__InputData__c = '{"columnKey":"4acc9a","dataType":"Text","displayOrder":2,"headerType":"Output","label":null,"lineItemId":"a1r4x000000UQiXAAW","listValues":null,"name":"Expression"}'
        ));

        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
            vlocity_cmt__InputData__c = '{"columnKey":"63405e","dataType":"Text","displayOrder":1,"headerType":"Input","label":null,"lineItemId":"a1r4x000000UQiYAAW","listValues":null,"name":"ProductCode"}'
        ));
        
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
            vlocity_cmt__InputData__c = '{"columnKey":"faf6f5","dataType":"Text","displayOrder":4,"headerType":"Output","label":null,"lineItemId":"a1r4x000000UQicAAG","listValues":null,"name":"ErrorMessage"}    '
        ));

        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
            vlocity_cmt__InputData__c = '{"ProductCode" : "VLO-BUN-0001"}',
            vlocity_cmt__OutputData__c = '{ "ErrorMessage" : "Business Internet Premium can be only deliverable to Zipcode 123456", "Result" : "true", "Expression" : "Zip INCLUDES \'123456\'" }'
        ));
        insert lineItems;
        
        update new vlocity_cmt__CalculationMatrixVersion__c(Id = version.Id, vlocity_cmt__IsEnabled__c = true);
    }

    public static void createCalculationProcedure() 
    {
        createCPQConfiguration('B2BCmexQtyDiscountCalculationProcedure', 'B2BQuantityBasedDiscountsProcedure');

        vlocity_cmt__CalculationMatrix__c parent = new vlocity_cmt__CalculationMatrix__c(Name = 'B2BQuantityBasedDiscounts');
        insert parent;

        vlocity_cmt__CalculationMatrixVersion__c version = new vlocity_cmt__CalculationMatrixVersion__c
        (
            Name='Version',
            vlocity_cmt__VersionNumber__c=2,
            vlocity_cmt__IsEnabled__c=false,
            vlocity_cmt__CalculationMatrixId__c=parent.Id,
            vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-20),
            vlocity_cmt__EndDateTime__c = DateTime.now().addDays(20),
            vlocity_cmt__Priority__c=2
        );
        insert version;
        
        List<vlocity_cmt__CalculationMatrixRow__c> lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();

        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c=version.Id, Name='Header',
            vlocity_cmt__InputData__c='{\"columnKey\":\"4172d0\",\"dataType\":\"Percent\",\"displayOrder\":4,\"headerType\":\"Output\",\"label\":null,\"listValues\":null,\"name\":\"MRC Discount (%)\"}'
        ));

        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c=version.Id, Name='Header',
            vlocity_cmt__InputData__c='{\"columnKey\":\"6caea6\",\"dataType\":\"Text\",\"displayOrder\":3,\"headerType\":\"Input\",\"label\":null,\"listValues\":null,\"name\":\"Quantity\"}'
        ));

        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c=version.Id, Name='Header',
            vlocity_cmt__InputData__c='{\"columnKey\":\"b685f\",\"dataType\":\"Text\",\"displayOrder\":2,\"headerType\":\"Input\",\"label\":null,\"listValues\":null,\"name\":\"Source Product Code\"}'
        ));
        
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c=version.Id, Name='Header',
            vlocity_cmt__InputData__c='{\"columnKey\":\"f4a4e9\",\"dataType\":\"Text\",\"displayOrder\":1,\"headerType\":\"Input\",\"label\":null,\"listValues\":null,\"name\":\"Source Product Name\"}'
        ));

        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c=version.Id,
            vlocity_cmt__InputData__c='{\"Quantity\":\"1-20\",\"Source Product Code\":\"PROD-002\",\"Source Product Name\":\"Test JSON SiteProduct 2\"}',
            vlocity_cmt__OutputData__c='{\"MRC Discount (%)\":5}'
        ));
        insert lineItems;
        
        update new vlocity_cmt__CalculationMatrixVersion__c(Id = version.Id, vlocity_cmt__IsEnabled__c = true);

        //service
        vlocity_cmt__CalculationProcedure__c newconfig1 = new vlocity_cmt__CalculationProcedure__c(Name='B2BQuantityBasedDiscountsProcedure');
        insert newConfig1;

        vlocity_cmt__CalculationProcedureVersion__c newversion = new vlocity_cmt__CalculationProcedureVersion__c(Name='Version', vlocity_cmt__VersionNumber__c=2, vlocity_cmt__IsEnabled__c=false, vlocity_cmt__CalculationProcedureId__c=newConfig1.Id, vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-10), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(10), vlocity_cmt__Priority__c=2,
        vlocity_cmt__Constants__c='{\"name":\"Rate 2\",\"alias\":\"Rate2\",\"value\":100,\"dataType\":\"Percent\"}',
           vlocity_cmt__Variables__c ='{\"name":\"Value\",\"alias\":\"Value\",\"dataType\":\"Percent\"}' );
        insert newversion;

        List<vlocity_cmt__CalculationProcedureStep__c> steps = new List<vlocity_cmt__CalculationProcedureStep__c> ();

        vlocity_cmt__CalculationProcedureStep__c step1 = new vlocity_cmt__CalculationProcedureStep__c (Name='Lookup Rate', vlocity_cmt__Sequence__c=1,vlocity_cmt__Function__c='Matrix Lookup', vlocity_cmt__CalculationMatrixId__c=parent.Id, vlocity_cmt__IsIncludedInResult__c=false, vlocity_cmt__CalculationProcedureVersionId__c= newversion.Id);
        vlocity_cmt__CalculationProcedureStep__c step2 = new vlocity_cmt__CalculationProcedureStep__c (Name='Calculate', vlocity_cmt__Sequence__c=2,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= newversion.Id, vlocity_cmt__CalculationFormula__c='Value * Rate2 + 2', vlocity_cmt__OutputJSON__c='{\"name\":\"Annual Premium\",\"dataType\":\"Number\"}', vlocity_cmt__OutputMappingJSON__c = '{\"Annual Premium\":\"AnnualPremium\"}');
        steps.add(step1);
        steps.add(step2);
        insert steps;

        update new vlocity_cmt__CalculationProcedureVersion__c(Id = newversion.Id, vlocity_cmt__IsEnabled__c = true);
    }

    public static void createQuoteMembers(String quoteId, String prefixName, String groupId, Integer num, String memberType) 
    {
        List<vlocity_cmt__QuoteMember__c> memberList = new List<vlocity_cmt__QuoteMember__c>();
        for(Integer i=0; i <= num; i++) {
            memberList.add(new vlocity_cmt__QuoteMember__c(
                                                Name = prefixName + ' ' + i, 
                                                vlocity_cmt__PostalCode__c = '123456',
                                                vlocity_cmt__FirstName__c = 'Test', 
                                                vlocity_cmt__LastName__c = 'Member ' + i,
                                                vlocity_cmt__QuoteId__c = quoteId,
                                                vlocity_cmt__MemberType__c = memberType,
                                                vlocity_cmt__QuoteGroupId__c = groupId));
        }
        insert memberList;
    }

    public static void createOpptMembers(String opptId, String groupId, Integer num, String memberType) 
    {
        List<vlocity_cmt__OpportunityMember__c> memberList = new List<vlocity_cmt__OpportunityMember__c>();
        for(Integer i=0; i <= num; i++) {
            memberList.add(new vlocity_cmt__OpportunityMember__c(
                                                Name = 'Test Member ' + i, 
                                                vlocity_cmt__PostalCode__c = '123456',
                                                vlocity_cmt__FirstName__c = 'Test', 
                                                vlocity_cmt__LastName__c = 'Member ' + i,
                                                vlocity_cmt__OpportunityId__c = opptId,
                                                vlocity_cmt__MemberType__c = memberType,
                                                vlocity_cmt__OpportunityGroupId__c = groupId));
        }
        insert memberList;
    }

    public static void createOrderMembers(String orderId, String groupId, Integer num, String memberType) 
    {
        List<vlocity_cmt__OrderMember__c> memberList = new List<vlocity_cmt__OrderMember__c>();
        for(Integer i=0; i <= num; i++) {
            memberList.add(new vlocity_cmt__OrderMember__c(
                                                Name = 'Test Member ' + i, 
                                                vlocity_cmt__FirstName__c = 'Test', 
                                                vlocity_cmt__LastName__c = 'Member ' + i,
                                                vlocity_cmt__OrderId__c = orderId,
                                                vlocity_cmt__MemberType__c = memberType,
                                                vlocity_cmt__OrderGroupId__c = groupId));
        }
        insert memberList;
    }

    public static void createOrderMembers(String name, String orderId, String groupId, Integer num, String memberType) 
    {
        List<vlocity_cmt__OrderMember__c> memberList = new List<vlocity_cmt__OrderMember__c>();
        for(Integer i=0; i <= num; i++) {
            memberList.add(new vlocity_cmt__OrderMember__c(
                                                Name = name+' ' + i, 
                                                vlocity_cmt__FirstName__c = name, 
                                                vlocity_cmt__LastName__c = 'Member ' + i,
                                                vlocity_cmt__OrderId__c = orderId,
                                                vlocity_cmt__MemberType__c = memberType,
                                                vlocity_cmt__OrderGroupId__c = groupId));
        }
        insert memberList;
    }

    public static void createCPQConfiguration(String name, String setupValue) 
    {
        insert new vlocity_cmt__CpqConfigurationSetup__c(Name = name, vlocity_cmt__SetupValue__c = setupValue);
    }

    public static void createTriggerSetup() 
    {
        insert new vlocity_cmt__TriggerSetup__c(Name = 'AllTriggers',vlocity_cmt__IsTriggerOn__c = true);
    }

    public static List<Map<String, Object>> convertToListMap(String Id) 
    {
        return new List<Map<String, Object>>{new Map<String, Object>{'Id' => Id}};
    }
    
    public static void productSetup() 
    {
        List<vlocity_cmt__CpqConfigurationSetup__c> configList = new List<vlocity_cmt__CpqConfigurationSetup__c>();
        configList.add(new vlocity_cmt__CpqConfigurationSetup__c(Name = 'ABPDiscountPricingPlanStepLogging', vlocity_cmt__SetupValue__c = 'True'));
        configList.add(new vlocity_cmt__CpqConfigurationSetup__c(Name = 'PricingPlanService', vlocity_cmt__SetupValue__c = 'True'));
        configList.add(new vlocity_cmt__CpqConfigurationSetup__c(Name = 'DefaultPricingPlan', vlocity_cmt__SetupValue__c = 'DEFAULT_PRICING_PLAN'));
        configList.add(new vlocity_cmt__CpqConfigurationSetup__c(Name = 'DeltaPrice', vlocity_cmt__SetupValue__c = 'True'));
        configList.add(new vlocity_cmt__CpqConfigurationSetup__c(Name = 'AttrMatrixInfoCachePartition', vlocity_cmt__SetupValue__c = 'CPQPartition'));
        insert configList;

        List<SObject> sObjList = new List<sObject>();

        //Create Products
        Product2 prod1 = new Product2 (Name='Triple Play Bundle Small', ProductCode = 'VLO-BUN-0001', vlocity_cmt__AttributeMetadata__c = 'TestAttributeMetadata1', vlocity_cmt__isLocationDependent__c = true);
        sObjList.add(prod1);

        Product2 prod2 = new Product2 (Name='Consumer Landline', ProductCode = 'VLO-PHN-0005', vlocity_cmt__AttributeMetadata__c = 'TestAttributeMetadata2', vlocity_cmt__isLocationDependent__c = true);
        sObjList.add(prod2);

        Product2 prod3 = new Product2 (Name='Broadband Internet Small', ProductCode = 'VLO-INT-0001', vlocity_cmt__AttributeMetadata__c = 'TestAttributeMetadata3', vlocity_cmt__isLocationDependent__c = true);
        sObjList.add(prod3);

        insert sObjList;
        sObjList.clear();

        // Create Product Child Item
        vlocity_cmt__ProductChildItem__c pci1 = new vlocity_cmt__ProductChildItem__c();
        pci1.vlocity_cmt__ParentProductId__c = prod1.Id;
        pci1.vlocity_cmt__ChildProductId__c = prod2.Id;
        pci1.Name = 'Test PCI1';
        pci1.vlocity_cmt__Quantity__c = 1.0;
        pci1.vlocity_cmt__MinQuantity__c = 1.0;
        pci1.vlocity_cmt__MaxQuantity__c = 25.0;
        pci1.vlocity_cmt__IsRootProductChildItem__c = false;
        pci1.vlocity_cmt__IsOverride__c = false;
        pci1.vlocity_cmt__ChildLineNumber__c = '0001';
        pci1.vlocity_cmt__IsVirtualItem__c = false;
        sObjList.add(pci1);

        vlocity_cmt__ProductChildItem__c pci2 = new vlocity_cmt__ProductChildItem__c();
        pci2.vlocity_cmt__ParentProductId__c = prod1.Id;
        pci2.vlocity_cmt__ChildProductId__c = prod3.Id;
        pci2.Name = 'Test PCI2';
        pci2.vlocity_cmt__Quantity__c = 1.0;
        pci2.vlocity_cmt__MinQuantity__c = 1.0;
        pci2.vlocity_cmt__MaxQuantity__c = 1.0;
        pci2.vlocity_cmt__IsRootProductChildItem__c = false;
        pci2.vlocity_cmt__IsOverride__c = false;
        pci2.vlocity_cmt__ChildLineNumber__c = '0002';
        pci2.vlocity_cmt__IsVirtualItem__c = false;
        sObjList.add(pci2);

        insert sObjList;
        sObjList.clear();

        Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(), Name = 'TestPricebook5', IsActive = true);
        Pricebook2 testPricebook = new Pricebook2(Name = 'TestPricebook7', IsActive = true);
        insert testPricebook;

        //Inserting into standard Pricebook
        PricebookEntry pbe11 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true);
        sObjList.add(pbe11);

        PricebookEntry pbe12 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                Product2Id = prod2.Id, UnitPrice = 20, vlocity_cmt__RecurringPrice__c = 10, IsActive = true);
        sObjList.add(pbe12);

        PricebookEntry pbe13 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                Product2Id = prod3.Id, UnitPrice = 30, vlocity_cmt__RecurringPrice__c = 15, IsActive = true);
        sObjList.add(pbe13);

        //Inserting into Custom Pricebook
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe1);

        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                Product2Id = prod2.Id, UnitPrice = 20, vlocity_cmt__RecurringPrice__c = 10, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe2);

        PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                Product2Id = prod3.Id, UnitPrice = 30, vlocity_cmt__RecurringPrice__c = 15, IsActive = true, UseStandardPrice = false);
        sObjList.add(pbe3);

        insert sObjList;
        sObjList.clear();

        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = testPricebook.Id, vlocity_cmt__IsActive__c = true, vlocity_cmt__Code__c = 'TestPricebook5');
        insert pl1;

        // Create Object Type
        SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = :nsPrefix + 'ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];
        vlocity_cmt__ObjectClass__c chargeObjType = new vlocity_cmt__ObjectClass__c(Name = 'Charge', vlocity_cmt__ObjectApiName__c = 'vlocity_cmt__PricingElement__c', RecordTypeId = sObj.Id);
        vlocity_cmt__ObjectClass__c discObjType = new vlocity_cmt__ObjectClass__c(Name = 'Discount', vlocity_cmt__ObjectApiName__c = 'vlocity_cmt__PricingElement__c', RecordTypeId = sObj.Id);

        sObjList.add(chargeObjType);
        sObjList.add(discObjType);
        insert sObjList;
        sObjList.clear();

        vlocity_cmt__PricingVariable__c oneTimeStdPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'One Time Std Price', vlocity_cmt__Code__c = 'OT_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='One-time',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(oneTimeStdPriceVar);

        vlocity_cmt__PricingVariable__c mrcPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'Recurring Monthly Std Price', vlocity_cmt__Code__c = 'REC_MNTH_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='Recurring', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(mrcPriceVar);

        vlocity_cmt__PricingVariable__c uPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'Usage Std Price', vlocity_cmt__Code__c = 'USAGE_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                vlocity_cmt__ChargeType__c='Usage', vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
        sObjList.add(uPriceVar);

        insert sObjList;
        sObjList.clear();

        // Create Pricing Element
        vlocity_cmt__PricingElement__c pElem1 = new vlocity_cmt__PricingElement__c(Name = 'One Time $100 Standalone Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 100.00,
                vlocity_cmt__Code__c = 'PELEM1', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem2 = new vlocity_cmt__PricingElement__c(Name = 'MRC $20 Standalone Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 20.00,
                vlocity_cmt__Code__c = 'PELEM2', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem4 = new vlocity_cmt__PricingElement__c(Name = 'One Time $400 Local Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 400.00,
                vlocity_cmt__Code__c = 'PELEM4', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = false, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        vlocity_cmt__PricingElement__c pElem5 = new vlocity_cmt__PricingElement__c(Name = 'MRC $50 Local Price', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 50.00,
                vlocity_cmt__Code__c = 'PELEM5', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = false, vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
        sObjList.clear();
        sObjList.add(pElem1);
        sObjList.add(pElem2);
        sObjList.add(pElem4);
        sObjList.add(pElem5);

        insert sObjList;
        sObjList.clear();


        List<vlocity_cmt__PricingElement__c> pricingElement = [SELECT Id, Name FROM vlocity_cmt__PricingElement__c];
        vlocity_cmt__PriceListEntry__c ple1 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod1.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.add(ple1);
        vlocity_cmt__PriceListEntry__c ple2 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod2.Id, vlocity_cmt__PricingElementId__c = pElem4.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.add(ple2);
        vlocity_cmt__PriceListEntry__c ple5 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod3.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
        sObjList.add(ple5);
        insert sObjList;
        sObjList.clear();

        //Creating PricingVariableBinding
        vlocity_cmt__PricingVariableBinding__c pvb1 = new vlocity_cmt__PricingVariableBinding__c(Name='One Time Std Price - OrderItem',vlocity_cmt__DestinationSObjectType__c='OrderItem',
                vlocity_cmt__DestinationFieldApiName__c = 'vlocity_cmt__OneTimeCharge__c', vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id);
        sObjList.add(pvb1);
        vlocity_cmt__PricingVariableBinding__c pvb2 = new vlocity_cmt__PricingVariableBinding__c(Name='Recurring Monthly Std Price - OrderItem',vlocity_cmt__DestinationSObjectType__c='OrderItem',
                vlocity_cmt__DestinationFieldApiName__c = 'vlocity_cmt__RecurringCharge__c', vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id);
        sObjList.add(pvb2);

        insert sObjList;
        sObjList.clear();

        Account a = new Account(Name='Account Test');
        insert a;

        Opportunity opp = new Opportunity(Name = 'Test Opporunity', 
                                                    AccountId = a.Id, 
                                                    closeDate = Date.TODAY(), 
                                                    StageName = 'Prospecting', 
                                                    Pricebook2Id =  standardBook.Id);
        insert opp;

        Quote q = new Quote(Status = 'Draft', 
                                    OpportunityId = opp.Id, 
                                    Name = 'Test Quote', 
                                    vlocity_cmt__OriginatingChannel__c = 'Retail', 
                                    vlocity_cmt__PriceListId__c = pl1.Id,
                                    RecordTypeId = getRecordTypeIdByName('Quote', 'EnterpriseQuote')
                                );
        insert q;

        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, 
                                                    vlocity_cmt__Product2Id__c = prod1.Id,
                                                    vlocity_cmt__LineNumber__c = '1',
                                                    Quantity = 2,
                                                    vlocity_cmt__UsageUnitPrice__c = 200,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    UnitPrice = 200,
                                                    PricebookEntryId = pbe1.Id,
                                                    vlocity_cmt__ProvisioningStatus__c = 'Test Status',
                                                    vlocity_cmt__PricingLogData__c = '{"LogData":{"REC_MNTH_STD_PRC_TOTAL":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"[Recurring Calculated Price (150.00) + Rollup Recurring Total (0.00)] x Quantity (2.00)"}],"REC_MNTH_STD_PRC_CALC":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"Recurring Charge (150.00000) - Recurring Manual Discount (0.00%)"}],"OT_STD_PRC_TOTAL":[{"ChargeTiming":"One-Time","LogSequence":0,"DisplayText":"[One Time Calculated Price (0.00) + Rollup One Time Total (0.00)] x Quantity (2.00)"}],"OT_STD_PRC_CALC":[{"ChargeTiming":null,"LogSequence":0,"DisplayText":"One Time Charge (0.00) - One Time Manual Discount (0.00%)"}],"REC_MNTH_STD_PRC":[{"LogSequence":0,"IsEffective":true,"EndDate":null,"StartDate":null,"AdjustmentType":"None","LoyaltyCode":"PTS","CurrencyCode":"EUR","CurrencyType":"Currency","Amount":150.00000,"AdjustmentValue":0.00,"AdjustmentMethod":null,"BaseValue":150.00000,"BaseAdjustment":null,"PriceListId":"a3Z4W000002hIHUUA2","OfferId":null,"PromotionId":null,"PricingElementId":"a3c4W000007KvOEQA0","PricingVariableCode":"REC_MNTH_STD_PRC","DisplayText":"150","EndValue":150.00000,"ChargeTiming":"Recurring","Frequency":"Monthly","SubType":"Standard","StartValue":150.00000,"PricingElementGlobalKey":"ecee6095-7f80-7a7b-cf15-31edba3a83d2","LogType":"PRICE","PriceListEntryId":"a3Y4W000000BnX2UAK"}]},"PricingVariableCodeFieldBinding":{"RecurringManualDiscount__c":"REC_MNTH_STD_PRC_DISC_PCT_MAN","OneTimeManualDiscount__c":"OT_STD_PRC_DISC_PCT_MAN","EffectiveQuantity__c":"EFFECTIVE_QUANTITY","Quantity":"LINE_QUANTITY","EffectiveRecurringTotal__c":"EFF_REC_MNTH_STD_PRC_TOTAL","RecurringTotal__c":"REC_MNTH_STD_PRC_TOTAL","RecurringCalculatedPrice__c":"REC_MNTH_STD_PRC_CALC","RecurringCharge__c":"REC_MNTH_STD_PRC","EffectiveOneTimeTotal__c":"EFF_OT_STD_PRC_TOTAL","OneTimeTotal__c":"OT_STD_PRC_TOTAL","OneTimeCalculatedPrice__c":"OT_STD_PRC_CALC","OneTimeCharge__c":"OT_STD_PRC"},"PriceAdjustmentPromoKeys":[],"PricingVariableCodeValues":{"DISP_OT_STD_PRC":0.00,"ROLLUP_OT_STD_PRC_TOTAL":0.00,"ROLLUP_REC_MNTH_STD_PRC_TOTAL":0.00,"REC_MNTH_STD_PRC_DISC_PCT_MAN":0.00,"OT_STD_PRC_DISC_PCT_MAN":0.00,"EFFECTIVE_QUANTITY":2.00,"LINE_QUANTITY":2.00,"EFF_REC_MNTH_STD_PRC_TOTAL":300.00,"REC_MNTH_STD_PRC_TOTAL":300.00,"REC_MNTH_STD_PRC_CALC":150.00,"REC_MNTH_STD_PRC":150.00000,"EFF_OT_STD_PRC_TOTAL":0.00,"OT_STD_PRC_TOTAL":0.00,"OT_STD_PRC_CALC":0.00,"OT_STD_PRC":0.00},"PricingVariableCodeBaseValues":{"REC_MNTH_STD_PRC":150.00000},"LogVersion":"3.0","PriceAsOfDateTime":"2020-10-31T04:18:19.843Z","LastPricingTime":"2020-10-31T04:18:19.843Z"}',
                                                    vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}'
                                                );
        insert qli;

        vlocity_cmt__QuoteProductRollup__c rollup = new vlocity_cmt__QuoteProductRollup__c
        (
            vlocity_cmt__TotalQuoteQuantity__c = 0,
            vlocity_cmt__TotalAssetQuantity__c = 0,
            vlocity_cmt__DiscountQuantity__c = 0,
            vlocity_cmt__QuoteId__c = q.Id,
            vlocity_cmt__RollupType__c = 'Total Quote Rollup',
            vlocity_cmt__ProductId__c = prod1.Id
        );
        insert rollup;

        //insert new vlocity_cmt__QuotePricingAdjustment__c(vlocity_cmt__QuoteId__c = q.Id, vlocity_cmt__QuoteItemId__c = qli.Id, vlocity_cmt__PriceListEntryId__c = ple1.Id, vlocity_cmt__Action__c = 'Add', vlocity_cmt__Source__c = QBPDiscountPricingPlanStepImpl.ADJSOURCE, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id , vlocity_cmt__PricingElementVersionId__c = pElem1.Id);

        vlocity_cmt__Promotion__c promo1 = new vlocity_cmt__Promotion__c(Name='Promo1', vlocity_cmt__Code__c='Promo1');
        insert promo1;

        vlocity_cmt__QuoteLineItemPricingAdjustment__c qliAdjustment = new vlocity_cmt__QuoteLineItemPricingAdjustment__c(
                Name = 'QLIPA1', vlocity_cmt__EstimatedEndDate__c = DateTime.now().addDays(+10), vlocity_cmt__EstimatedStartDate__c = DateTime.now().addDays(-10), vlocity_cmt__PromotionId__c = promo1.Id,
                vlocity_cmt__QuoteId__c = q.Id, vlocity_cmt__QuoteLineItemId__c = qli.Id, vlocity_cmt__Sequence__c = 10
        );
        insert qliAdjustment;


        // Create Pricing Plan
        vlocity_cmt__PricingPlan__c plan = new vlocity_cmt__PricingPlan__c(Name = 'Default Pricing Plan', vlocity_cmt__Code__c = 'DEFAULT_PRICING_PLAN', vlocity_cmt__IsActive__c = true);
        insert plan;

        String initPriceContextParams = '{"CreateBaseAdjustments":"true"}';
        vlocity_cmt__PricingPlanStep__c planStep13 = new vlocity_cmt__PricingPlanStep__c(Name = 'Calculate Qty Based Pricing', vlocity_cmt__ImplementationName__c = 'QBPDiscountPricingPlanStepImpl', vlocity_cmt__IsActive__c = true, vlocity_cmt__MethodName__c = 'GetMatrixPrice', vlocity_cmt__Sequence__c = 8, vlocity_cmt__PricingPlanId__c = plan.Id, vlocity_cmt__Parameters__c = '{"ProcedureName":"B2BQuantityBasedDiscountsProcedure","MatrixName":"B2BQuantityBasedDiscounts","RangeFields":"Quantity","UseDisplayTextForValuesDefault":"False"}');
        sObjList.add(planStep13);
        insert sObjList;
        sObjList.clear();
        
        vlocity_cmt__TimePolicy__c timePolicy1 = new vlocity_cmt__TimePolicy__c(Name='First of Month to plan end', vlocity_cmt__StartTimePolicy__c='First Day of Month', vlocity_cmt__EndTimePolicy__c='End of Plan Duration');
        sObjList.add(timePolicy1);
        vlocity_cmt__TimePolicy__c timePolicy2 = new vlocity_cmt__TimePolicy__c(Name='Purchase Date to plan end', vlocity_cmt__StartTimePolicy__c='Purchase Date', vlocity_cmt__EndTimePolicy__c='End of Plan Duration');
        sObjList.add(timePolicy2);
        vlocity_cmt__TimePolicy__c timePolicy3 = new vlocity_cmt__TimePolicy__c(Name='Purchase Date to plan end delay 1 Week', vlocity_cmt__StartTimePolicy__c='Purchase Date', vlocity_cmt__EndTimePolicy__c='End of Plan Duration', vlocity_cmt__IsStartTimeDelayed__c=true, vlocity_cmt__StartTimeDelayOffset__c=1, vlocity_cmt__StartTimeDelayOffsetUoM__c='Week');
        sObjList.add(timePolicy3);
        vlocity_cmt__TimePolicy__c timePolicy4 = new vlocity_cmt__TimePolicy__c(Name='Cycle Start Date to Cycle End Date', vlocity_cmt__StartTimePolicy__c='Cycle Start Date', vlocity_cmt__EndTimePolicy__c='Cycle End Date');
        sObjList.add(timePolicy4);
        vlocity_cmt__TimePolicy__c timePolicy5 = new vlocity_cmt__TimePolicy__c(Name='Cycle Start Date to Cycle End Date', vlocity_cmt__StartTimePolicy__c='First Day of Month', vlocity_cmt__EndTimePolicy__c='Last Day of Month');
        sObjList.add(timePolicy5);
        insert sObjList;
        sObjList.clear();
    } 

    public static Id getRecordTypeIdByName(String objectName, String DeveloperName)
    {
        //return ObjectDescriberV2.getRecordTypeIdByDeveloperName(objectName, DeveloperName);    
        List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE DeveloperName=:DeveloperName AND SobjectType=:objectName LIMIT 1];
       	return recordTypeList[0].Id;
    }

    
    public static vlocity_cmt__DocumentTemplate__c createDocumentTemplate(String documentName)
    {
        vlocity_cmt__DocumentTemplate__c template = new vlocity_cmt__DocumentTemplate__c(Name = documentName);
        insert template;
        return template;
    }
/*
    public static void createCustomFieldMaps()
    {
        List<CustomFieldMap__c> settings = new List<CustomFieldMap__c>();

        settings.add(new CustomFieldMap__c(
            Name = 'QuoteToOrder1',
            SourceFieldName__c = 'Name',
            SourceSObjectType__c = 'Quote',
            DestinationFieldName__c = 'Name',
            DestinationSObjectType__c = 'Order'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QGToOG',
            SourceFieldName__c = 'Name',
            SourceSObjectType__c = nsPrefix + 'QuoteGroup__c',
            DestinationFieldName__c = 'Name',
            DestinationSObjectType__c = nsPrefix + 'OrderGroup__c'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QliToOli1',
            SourceFieldName__c = 'Description',
            SourceSObjectType__c = 'QuoteLineItem',
            DestinationFieldName__c = 'Description',
            DestinationSObjectType__c = 'OrderItem'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QliToOli2',
            SourceFieldName__c = 'PricebookEntryId',
            SourceSObjectType__c = 'QuoteLineItem',
            DestinationFieldName__c = 'PricebookEntryId',
            DestinationSObjectType__c = 'OrderItem'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QliToOli3',
            SourceFieldName__c = 'UnitPrice',
            SourceSObjectType__c = 'QuoteLineItem',
            DestinationFieldName__c = 'UnitPrice',
            DestinationSObjectType__c = 'OrderItem'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QliToOli4',
            SourceFieldName__c = 'Quantity',
            SourceSObjectType__c = 'QuoteLineItem',
            DestinationFieldName__c = 'Quantity',
            DestinationSObjectType__c = 'OrderItem'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QliToOli5',
            SourceFieldName__c = nsPrefix + 'AssetReferenceId__c',
            SourceSObjectType__c = 'QuoteLineItem',
            DestinationFieldName__c = nsPrefix + 'AssetReferenceId__c',
            DestinationSObjectType__c = 'OrderItem'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QapToOap',
            SourceFieldName__c = 'Name',
            SourceSObjectType__c = nsPrefix + 'QuoteAppliedPromotion__c',
            DestinationFieldName__c = 'Name',
            DestinationSObjectType__c = nsPrefix + 'OrderAppliedPromotion__c'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QapliToOapli1',
            SourceFieldName__c = 'Name',
            SourceSObjectType__c = nsPrefix + 'QuoteAppliedPromotionItem__c',
            DestinationFieldName__c = 'Name',
            DestinationSObjectType__c = nsPrefix + 'OrderAppliedPromotionItem__c'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QapliToOapli2',
            SourceFieldName__c = nsPrefix + 'QuoteAppliedPromotionId__c',
            SourceSObjectType__c = nsPrefix + 'QuoteAppliedPromotionItem__c',
            DestinationFieldName__c = nsPrefix + 'OrderAppliedPromotionId__c',
            DestinationSObjectType__c = nsPrefix + 'OrderAppliedPromotionItem__c'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QdToOd',
            SourceFieldName__c = 'Name',
            SourceSObjectType__c = nsPrefix + 'QuoteDiscount__c',
            DestinationFieldName__c = 'Name',
            DestinationSObjectType__c = nsPrefix + 'OrderDiscount__c'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QdpToOdp',
            SourceFieldName__c = 'Name',
            SourceSObjectType__c = nsPrefix + 'QuoteDiscountPricing__c',
            DestinationFieldName__c = 'Name',
            DestinationSObjectType__c = nsPrefix + 'OrderDiscountPricing__c'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QdiToOdi',
            SourceFieldName__c = 'Name',
            SourceSObjectType__c = nsPrefix + 'QuoteDiscountItem__c',
            DestinationFieldName__c = 'Name',
            DestinationSObjectType__c = nsPrefix + 'OrderDiscountItem__c'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QpaToOpa',
            SourceFieldName__c = 'Name',
            SourceSObjectType__c = nsPrefix + 'QuotePricingAdjustment__c',
            DestinationFieldName__c = 'Name',
            DestinationSObjectType__c = nsPrefix + 'OrderPriceAdjustment__c'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QmToOli',
            SourceFieldName__c = nsPrefix + 'MSISDN__c',
            SourceSObjectType__c = nsPrefix + 'QuoteMember__c',
            DestinationFieldName__c = nsPrefix + 'ServiceIdentifier__c',
            DestinationSObjectType__c = 'OrderItem'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QmToOm',
            SourceFieldName__c = nsPrefix + 'ServiceAccountId__c',
            SourceSObjectType__c = nsPrefix + 'QuoteMember__c',
            DestinationFieldName__c = nsPrefix + 'ServiceAccountId__c',
            DestinationSObjectType__c = nsPrefix + 'OrderMember__c'
        ));

        settings.add(new CustomFieldMap__c(
            Name = 'QprToOpr',
            SourceFieldName__c = nsPrefix + 'RelationshipType__c',
            SourceSObjectType__c = nsPrefix + 'QuoteLineItemRelationship__c',
            DestinationFieldName__c = nsPrefix + 'RelationshipType__c',
            DestinationSObjectType__c = nsPrefix + 'OrderItemRelationship__c'
        ));
        
        insert settings; 
    }


    public static void createFieldMapperForAssetToOrderLineItem()
    {
        List<CustomFieldMap__c> mappers = new List<CustomFieldMap__c>();

        mappers.add(new CustomFieldMap__c(
            Name='setting 1',
            SourceFieldName__c = 'ProvisioningStatus__c',
            DestinationFieldName__c ='ProvisioningStatus__c',
            DestinationSObjectType__c='OrderItem',
            SourceSObjectType__c='Asset'
        ));

        mappers.add(new CustomFieldMap__c(
            Name='setting 2',
            SourceFieldName__c = 'Product2Id',
            DestinationFieldName__c ='Product2Id__c',
            DestinationSObjectType__c='OrderItem',
            SourceSObjectType__c='Asset'
        ));

        mappers.add(new CustomFieldMap__c(
            Name='setting 3',
            SourceFieldName__c = 'Quantity',
            DestinationFieldName__c ='Quantity',
            DestinationSObjectType__c='OrderItem',
            SourceSObjectType__c='Asset'
        ));

        mappers.add(new CustomFieldMap__c(
            Name='setting 4',
            SourceFieldName__c = 'Price',
            DestinationFieldName__c ='UnitPrice',
            DestinationSObjectType__c='OrderItem',
            SourceSObjectType__c='Asset'
        ));

        mappers.add(new CustomFieldMap__c(
            Name='setting 5',
            SourceFieldName__c = 'LineNumber__c',
            DestinationFieldName__c ='LineNumber__c',
            DestinationSObjectType__c='OrderItem',
            SourceSObjectType__c='Asset'
        ));

        mappers.add(new CustomFieldMap__c(
            Name='setting 6',
            SourceFieldName__c = 'RootItemId__c',
            DestinationFieldName__c ='RootItemId__c',
            DestinationSObjectType__c='OrderItem',
            SourceSObjectType__c='Asset'
        ));

        mappers.add(new CustomFieldMap__c(
            Name='setting 7',
            SourceFieldName__c = 'PricebookEntryId__c',
            DestinationFieldName__c = 'PricebookEntryId',
            DestinationSObjectType__c='OrderItem',
            SourceSObjectType__c='Asset'
        ));

        mappers.add(new CustomFieldMap__c(
            Name='setting 8',
            SourceFieldName__c = 'ProvisioningStatus__c',
            DestinationFieldName__c ='ProvisioningStatus__c',
            DestinationSObjectType__c='QuoteLineItem',
            SourceSObjectType__c='Asset'
        ));
        
        mappers.add(new CustomFieldMap__c(
            Name='setting 9',
            SourceFieldName__c = 'Product2Id',
            DestinationFieldName__c ='Product2Id__c',
            DestinationSObjectType__c='QuoteLineItem',
            SourceSObjectType__c='Asset'
        ));
        
        mappers.add(new CustomFieldMap__c(
            Name='setting 10',
            SourceFieldName__c = 'Quantity',
            DestinationFieldName__c ='Quantity',
            DestinationSObjectType__c='QuoteLineItem',
            SourceSObjectType__c='Asset'
        ));

        mappers.add(new CustomFieldMap__c(
            Name='setting 11',
            SourceFieldName__c = 'Price',
            DestinationFieldName__c ='UnitPrice',
            DestinationSObjectType__c='QuoteLineItem',
            SourceSObjectType__c='Asset'
        ));
        
        mappers.add(new CustomFieldMap__c(
            Name='setting 12',
            SourceFieldName__c = 'LineNumber__c',
            DestinationFieldName__c ='LineNumber__c',
            DestinationSObjectType__c='QuoteLineItem',
            SourceSObjectType__c='Asset'
        ));
        
        mappers.add(new vlocity_cmt__CustomFieldMap__c(
            Name='setting 13',
            SourceFieldName__c = 'RootItemId__c',
            DestinationFieldName__c ='RootItemId__c',
            DestinationSObjectType__c='QuoteLineItem',
            SourceSObjectType__c='Asset'
        ));
        
        mappers.add(new vlocity_cmt__CustomFieldMap__c(
            Name='setting 14',
            vlocity_cmt__SourceFieldName__c = 'PricebookEntryId__c',
            vlocity_cmt__DestinationFieldName__c = 'PricebookEntryId',
            vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
            vlocity_cmt__SourceSObjectType__c='Asset'
        ));
        
        insert mappers;
    }
*/
    //mock payload to perform serviceability
    public static String payloadForServiceabilityCheck()
    {
        return '{\"@type\":\"CheckServiceQualification\",\"serviceQualificationItem\":[{\"@type\":\"ServiceQualificationItem\",\"service\":{\"@type\":\"Service\",\"serviceSpecification\":{\"@type\":\"ServiceSpecification\",\"name\":\"TVAccess\",\"href\":\"string\",\"id\":\"23\"},\"serviceCharacteristic\":[{\"value\":\"4K\",\"valueType\":\"string\",\"name\":\"BroadcastQuality\",\"id\":\"1\"},{\"value\":\"Fiber\",\"valueType\":\"string\",\"name\":\"BroadcastConnectiontype\"},{\"value\":\"1Mbps\",\"name\":\"upstreamSpeed\"},{\"value\":\"100Mbps\",\"name\":\"downstreamSpeed\"}],\"place\":[{\"@referredType\":\"GeographicSite\",\"role\":\"Installation place\",\"name\":\"Jean Pontus home\",\"href\":\"http://serverlocation:port/geographicSiteManagement/v4/geographicSite/11\",\"id\":\"11\"}]},\"expectedServiceAvailabilityDate\":\"2020-04-11T19:20:39.239Z\",\"id\":\"1\"}],\"relatedParty\":[{\"@referredType\":\"Individual\",\"@type\":\"RelatedParty\",\"role\":\"Buyer contact\",\"name\":\"Jean Pontus\",\"href\":\"http://serverlocation:port/partyManagement/v4/party/456\",\"id\":\"456\"}],\"instantSyncQualification\":false,\"provideUnavailabilityReason\":true,\"provideAlternative\":true,\"externalId\":\"CSQ1-001\",\"expectedQualificationDate\":\"2020-04-15T15:20:39.239Z\",\"description\":\"check service qualification illustration\",\"checkServiceQualificationDate\":\"2020-04-10T19:20:39.239Z\",\"id\":\"44\"}';
    }

    public static vlocity_cmt__QuoteGroup__c createQuoteGroup(String name, Id quoteId, Integer expectedMemberCount)
    {
        vlocity_cmt__QuoteGroup__c quoteGroup = new vlocity_cmt__QuoteGroup__c(Name = name,
                    vlocity_cmt__QuoteId__c = quoteId,
                    vlocity_cmt__ExpectedMemberCount__c = expectedMemberCount);
        insert quoteGroup;
        return quoteGroup;
    }

    public static vlocity_cmt__QuoteMember__c createQuoteMember(String name, Id quoteId, Id groupId, String memberType)
    {
        vlocity_cmt__QuoteMember__c quoteMember = new vlocity_cmt__QuoteMember__c(
                            Name =name, 
                            vlocity_cmt__PostalCode__c = '123456',
                            vlocity_cmt__FirstName__c = 'Test', 
                            vlocity_cmt__LastName__c = name,
                            vlocity_cmt__QuoteId__c = quoteId,
                            vlocity_cmt__MemberType__c = memberType,
                            vlocity_cmt__QuoteGroupId__c = groupId);
        insert quoteMember;
        return quoteMember;
    }

    public static QuoteLineItem createQuoteLineItem(Id quoteId, Id productId, String lineNumber, Id priceBookId, Id groupId, Id quoteMemberId) {
        QuoteLineItem quoteLineItem = new QuoteLineItem(
                        QuoteId = quoteId, 
                        vlocity_cmt__Product2Id__c = productId,
                        Product2Id = productId,
                        vlocity_cmt__LineNumber__c = lineNumber,
                        Quantity = 2,
                        vlocity_cmt__UsageUnitPrice__c = 200,
                        vlocity_cmt__Action__c = 'Add',
                        UnitPrice = 200,
                        PricebookEntryId = priceBookId,
                        vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option 2","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details 2","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}',
                        vlocity_cmt__QuoteGroupId__c = groupId,
                        vlocity_cmt__QuoteMemberId__c = quoteMemberId
                    );
        insert quoteLineItem;
        return quoteLineItem;
    }

    public static Opportunity getOpportunityByName(List<Opportunity> opportunityList, String name)
    {
        for(Opportunity obj: opportunityList)
        {
            if(obj.Name == Name)
            {
                return obj;
            }
        }
        return null;
    }

    /*
    *********************************************************
    @description       : This is method is used to create order group record for test class
    @Mandatory Input   : orderId, groupId, expectedMemberCount
    @Return            : Order group record 
    *********************************************************
    */
    public static vlocity_cmt__OrderGroup__c createOrderGroup(String name, Id orderId, Integer expectedMemberCount)
    {
        vlocity_cmt__OrderGroup__c orderGroup = new vlocity_cmt__OrderGroup__c(Name = name,
                    vlocity_cmt__OrderId__c = orderId,
                    vlocity_cmt__ExpectedMemberCount__c = expectedMemberCount);
        insert orderGroup;
        return orderGroup;
    }

    /*
    *********************************************************
    @description       : This is method is used to create order members record for test class
    @Mandatory Input   : orderId, groupId, name, memberType
    @Return            : Order member record 
    *********************************************************
    */
    public static vlocity_cmt__OrderMember__c createOrderMember(String name, Id orderId, Id groupId, String memberType)
    {
        vlocity_cmt__OrderMember__c orderMember = new vlocity_cmt__OrderMember__c(
                            Name =name, 
                            vlocity_cmt__PostalCode__c = '123456',
                            vlocity_cmt__FirstName__c = 'Test', 
                            vlocity_cmt__LastName__c = name,
                            vlocity_cmt__OrderId__c = orderId,
                            vlocity_cmt__MemberType__c = memberType,
                            vlocity_cmt__OrderGroupId__c = groupId);
        insert orderMember;
        return orderMember;
    }

    /*
    *********************************************************
    @description       : This is method is used to create order line item record for test class
    @Mandatory Input   : orderId, productId, lineNumber, priceBookId, groupId, orderMemberId
    @Return            : OrderItem record 
    *********************************************************
    */
    public static OrderItem createOrderLineItem(Id orderId, Id productId, String lineNumber, Id priceBookId, Id groupId, Id orderMemberId) {
        OrderItem orderLineItem = new OrderItem(
                        OrderId = orderId, 
                        vlocity_cmt__Product2Id__c = productId,
                        Product2Id = productId,
                        vlocity_cmt__LineNumber__c = lineNumber,
                        Quantity = 2,
                        vlocity_cmt__UsageUnitPrice__c = 200,
                        vlocity_cmt__Action__c = 'Add',
                        UnitPrice = 200,
                        PricebookEntryId = priceBookId,
                        vlocity_cmt__JSONAttribute__c = '{"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS":[{"$$AttributeDefinitionStart$$":null,"categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_DEPLOYMENT_OPTION","attributeconfigurable__c":true,"attributedisplaysequence__c":"120","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Deployment Option 2","displaysequence__c":"120","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":"Indicates either a new UNI-N port is required or an existing UNI-N port can be re-used","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":null,"sequence":1,"id":null,"displayText":"New UNI"},{"value":null,"sequence":2,"id":null,"displayText":"Reuse Existing UNI"}],"selectedItem":{"displayText":"New UNI"}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t4x000001jEYkAAM","attributeid__c":"a094x000000zcePAAQ","attributecategoryid__c":"a084x000000lhpzAAA","categorycode__c":"VEPC_ATTRIBUTE_CATEGORY_UNI_DETAILS","categoryname__c":"UNI Details","attributeuniquecode__c":"VEPC_ATTR_UNI_HANDOVER_DETAILS","attributeconfigurable__c":true,"attributedisplaysequence__c":"130","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"UNI Handover Details 2","displaysequence__c":"130","categorydisplaysequence__c":7090,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a204x000000gbwQAAQ","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":"Test value read only","valuedatatype__c":"Text","valuedescription__c":"Additional details about the UNI handoff (e.g. 2 fibers, 2 patch panel ports, etc.)","attributegrouptype__c":null,"isnotassetizable__c":true,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","default":"Test value read only","value":"Test value read only"},"$$AttributeDefinitionEnd$$":null}]}',
                        vlocity_cmt__OrderGroupId__c = groupId,
                        vlocity_cmt__OrderMemberId__c = orderMemberId
                    );
        insert orderLineItem;
        return orderLineItem;
    }

    public static void prepareOrderDiscounts(String OrderId, String ProductId) 
    {
        vlocity_cmt__OrderDiscount__c discount = new vlocity_cmt__OrderDiscount__c
        (
            vlocity_cmt__ApprovalStatus__c = 'Approved',
            Name = 'Test Discount',
            vlocity_cmt__DiscountType__c = 'Order',
            vlocity_cmt__Action__c = 'New',
            vlocity_cmt__OrderId__c = OrderId
        );
        insert discount;

        if(String.isEmpty(ProductId))
        {
            vlocity_cmt__OrderDiscountItem__c discountItem = new vlocity_cmt__OrderDiscountItem__c
            (
                Name = 'Test Discount Item',
                vlocity_cmt__OrderDiscountId__c = discount.Id,
                vlocity_cmt__ProductId__c = ProductId
            );
            insert discountItem;

            vlocity_cmt__PricingVariable__c pricingVariable = new vlocity_cmt__PricingVariable__c
            (
                Name='One Time Std Price',
                vlocity_cmt__Code__c='OT_STD_PRC',
                vlocity_cmt__AdjustmentMethod__c='Percent',
                vlocity_cmt__IsActive__c=True,
                vlocity_cmt__Aggregation__c='Unit',
                vlocity_cmt__ChargeType__c='One-time',
                vlocity_cmt__ValueType__c='Pricing Element',
                vlocity_cmt__Type__c='Price',
                vlocity_cmt__SubType__c='Standard',
                vlocity_cmt__Scope__c='Line',
                vlocity_cmt__CurrencyType__c='Currency'
            );
            insert pricingVariable;

           vlocity_cmt__OrderDiscountPricing__c pricing = new vlocity_cmt__OrderDiscountPricing__c
            (
                Name = '5% off monthly',
                vlocity_cmt__AdjustmentValue__c = -5.00,
                vlocity_cmt__PricingVariableId__c = pricingVariable.Id,
                vlocity_cmt__OrderDiscountId__c = discount.Id
            );
            insert pricing;
        }
    }

    public static void prepareDataForWCToEntepriseOrderCart()
    {
        Order testOrder = [SELECT Id, Name, AccountId, Pricebook2Id, vlocity_cmt__PriceListId__c, EffectiveDate, Status FROM Order WHERE Name = 'Test CPQ Order' LIMIT 1];
        Order enterpriseWCOrder1 = testOrder.clone(false, false, false, false);
        enterpriseWCOrder1.Name = 'CPQ Group Cart Order2';
        insert enterpriseWCOrder1;

        vlocity_cmt__OrderDiscount__c enterpriseWCOrderAD = new vlocity_cmt__OrderDiscount__c(
            vlocity_cmt__ApprovalStatus__c='Approved',
            Name='Approved Discount',
            vlocity_cmt__OrderId__c=enterpriseWCOrder1.Id);
        insert enterpriseWCOrderAD;

        vlocity_cmt__Promotion__c promotion2 = [Select Id from  vlocity_cmt__Promotion__c where Name = 'TestPromo2' LIMIT 1];
        Product2 product1 = [Select Id from  Product2 where Name='Test JSON SiteProduct 1' LIMIT 1];
        Product2 product2 = [Select Id from  Product2 where Name='Test JSON SiteProduct 2' LIMIT 1];
        vlocity_cmt__PriceList__c p1 = [Select Id , Name from   vlocity_cmt__PriceList__c where Name = 'P1' and  vlocity_cmt__Code__c = 'P1' LIMIT 1];
        vlocity_cmt__PriceListEntry__c pe1 = [Select Id from vlocity_cmt__PriceListEntry__c where Name = :p1.Name and vlocity_cmt__PriceListId__c = :p1.Id and vlocity_cmt__ProductId__c = :product2.Id limit 1];
        Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(),
                                                Name = 'TestPricebook',
                                                IsActive = true);
        PricebookEntry pbe1 = [Select Id from  PricebookEntry where Pricebook2Id = :standardBook.Id AND Product2Id = :product1.Id LIMIT 1];

        vlocity_cmt__OrderAppliedPromotion__c enterpriseWCOrderAP = new vlocity_cmt__OrderAppliedPromotion__c(
            vlocity_cmt__OrderId__c = enterpriseWCOrder1.Id,
            Name = 'Test Order Promo',
            vlocity_cmt__Action__c = 'Add',
            vlocity_cmt__PromotionId__c=promotion2.Id
        );
        insert enterpriseWCOrderAP;

        OrderItem enterpriseWCOrderOI = new OrderItem(OrderId = enterpriseWCOrder1.Id,
                                                    vlocity_cmt__Product2Id__c = product2.Id,
                                                    vlocity_cmt__LineNumber__c = '1',
                                                    Quantity = 2,
                                                    vlocity_cmt__UsageUnitPrice__c = 200,
                                                    vlocity_cmt__Action__c = 'Add',
                                                    UnitPrice = 200,
                                                    PricebookEntryId = pbe1.Id
                                                    );
        insert enterpriseWCOrderOI;
        insert new vlocity_cmt__OrderPriceAdjustment__c(vlocity_cmt__OrderId__c = enterpriseWCOrder1.Id, vlocity_cmt__OrderItemId__c = enterpriseWCOrderOI.Id, vlocity_cmt__PriceListEntryId__c = pe1.Id);
    }

    public static void prepareOrderProductRelationship(Id orderId, Id orderItemId, Id relatedOrderItemId, String relatedAssetRef) 
    {
        String ruleId = '1cde0152-4f3e-665f-fafd-dfdfea5e6920';
        vlocity_cmt__OrderItemRelationship__c opr1 = new vlocity_cmt__OrderItemRelationship__c(Name='Test', vlocity_cmt__ProductRelationshipIdentifier__c = ruleId, 
        vlocity_cmt__OrderId__c=orderId, vlocity_cmt__OrderItemId__c=orderItemId, vlocity_cmt__RelatedOrderItemId__c=relatedOrderItemId,
                                                            vlocity_cmt__RelationshipType__c ='ReliesOn', vlocity_cmt__RelatedAssetReferenceId__c = relatedAssetRef);
        insert opr1;      
    }

    public static void preparePromotionDataForEntepriseOrder()
    {
        Order enterpriseOrder = [SELECT Id, Name, AccountId, Pricebook2Id, vlocity_cmt__PriceListId__c, EffectiveDate, Status FROM Order WHERE Name = 'Test Enterprise Order' LIMIT 1];
        
        Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(),
                                                Name = 'TestPricebook',
                                                IsActive = true);
        vlocity_cmt__Promotion__c promotion2 = [Select Id from  vlocity_cmt__Promotion__c where Name = 'TestPromo2' LIMIT 1];
        Product2 product1 = [Select Id from  Product2 where Name='Test JSON SiteProduct 1' LIMIT 1];
        Product2 product2 = [Select Id from  Product2 where Name='Test JSON SiteProduct 2' LIMIT 1];
        PricebookEntry pbe1 = [Select Id from  PricebookEntry where Pricebook2Id = :standardBook.Id AND Product2Id = :product1.Id LIMIT 1];
        vlocity_cmt__PriceList__c p1 = [Select Id , Name from   vlocity_cmt__PriceList__c where Name = 'P1' and  vlocity_cmt__Code__c = 'P1' LIMIT 1];
        vlocity_cmt__PriceListEntry__c pe1 = [Select Id from vlocity_cmt__PriceListEntry__c where Name = :p1.Name and vlocity_cmt__PriceListId__c = :p1.Id and vlocity_cmt__ProductId__c = :product2.Id limit 1];
        OrderItem enterpriseOrderOI = new OrderItem(OrderId = enterpriseOrder.Id,
            vlocity_cmt__Product2Id__c = product2.Id,
            vlocity_cmt__LineNumber__c = '1',
            Quantity = 2,
            vlocity_cmt__UsageUnitPrice__c = 200,
            vlocity_cmt__Action__c = 'Add',
            UnitPrice = 200,
            PricebookEntryId = pbe1.Id
            );
        insert enterpriseOrderOI;

        vlocity_cmt__OrderDiscount__c enterpriseOrderAD = new vlocity_cmt__OrderDiscount__c(
            vlocity_cmt__ApprovalStatus__c='Approved',
            Name='Approved Discount',
            vlocity_cmt__OrderId__c=enterpriseOrder.Id);
        insert enterpriseOrderAD;

        vlocity_cmt__OrderAppliedPromotion__c enterpriseOrderAP = new vlocity_cmt__OrderAppliedPromotion__c(
            vlocity_cmt__OrderId__c = enterpriseOrder.Id,
            Name = 'Test Order Promo',
            vlocity_cmt__Action__c = 'Add',
            vlocity_cmt__PromotionId__c=promotion2.Id
        );
        insert enterpriseOrderAP;

        vlocity_cmt__OrderAppliedPromotionItem__c orderAppliedPromotionItem = new vlocity_cmt__OrderAppliedPromotionItem__c(
            vlocity_cmt__OrderAppliedPromotionId__c = enterpriseOrderAP.Id, 
            Name = 'Test Order Promo', 
            vlocity_cmt__OrderItemId__c = enterpriseOrderOI.Id);
        insert orderAppliedPromotionItem;

       
        insert new vlocity_cmt__OrderPriceAdjustment__c(vlocity_cmt__OrderId__c = enterpriseOrder.Id, vlocity_cmt__OrderItemId__c = enterpriseOrderOI.Id, vlocity_cmt__PriceListEntryId__c = pe1.Id);
    }
}