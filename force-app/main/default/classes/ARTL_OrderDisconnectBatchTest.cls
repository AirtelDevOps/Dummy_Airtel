@isTest
public class ARTL_OrderDisconnectBatchTest {
    @testSetup
    static void testdataCreation(){
        Profile salesProf = [select id from profile where name = 'sales' limit 1];
        User u = new User(
            Alias = 'standt', Email='systemadminuser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = salesProf.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='systemadminuserbalic@testorg.com'
        );
        insert u;
        Account testAccount = new Account(Name = 'Test Account',OwnerId = u.Id);
        insert testAccount;
        Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('MobilePhoneContact').getRecordTypeId();
        Contact con = new Contact(Firstname = 'Test',LastName = 'Contact', Email = 'testcontact@test.com',AccountId= testAccount.id, RecordTypeId = recordTypeId, Phone = '8765337890',ARTL_Designation__c = 'Test', ARTL_Contact_Role__c='Sales Contact');
        insert con;
        Product2 testProduct1 = new Product2(
            Name = 'Test Product Root',
            ProductCode = 'Test_cancellation_Product',
            IsActive = true
        );
        insert testProduct1;
        
        PricebookEntry testPricebookEntry1 = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = testProduct1.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert testPricebookEntry1;
        
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(
            vlocity_cmt__Pricebook2Id__c = Test.getStandardPricebookId(),
            vlocity_cmt__IsActive__c = true,
            vlocity_cmt__Code__c = 'TestPricebook5'
        );
        insert pl1;
        
        Opportunity opp = new Opportunity(
            Name = 'EPC Deal AA',
            AccountId = testAccount.Id,
            vlocity_cmt__PriceListId__c = pl1.Id,
            CloseDate = System.today(),
            StageName = 'Initial',
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert opp;
        
        Quote qtest = new Quote(
            Name = 'Quote - EPC Deal AA',
            Status = 'Draft',
            OpportunityId = opp.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            vlocity_cmt__PriceListId__c = pl1.Id,
            vlocity_cmt__PoDate__c = Date.today(),
            vlocity_cmt__PoNumber__c = '12345',
            PO_Term__c = '12',
            PO_Value__c = 1222,
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'EnterpriseQuote' AND SobjectType = 'Quote' LIMIT 1].Id
        );
        insert qtest;
        
        QuoteLineItem  qouteLine1 = new QuoteLineItem (UnitPrice = 1, Quantity = 1, Product2Id = testProduct1.Id,
                                                       vlocity_cmt__Product2Id__c = testProduct1.Id,
                                                       QuoteId =qtest.Id, PricebookEntryId=testPricebookEntry1.Id,
                                                       vlocity_cmt__LineNumber__c = '0001');
        insert qouteLine1;
        
        QuoteLineItem  qouteLine2 = new QuoteLineItem (UnitPrice = 1, Quantity = 1, Product2Id = testProduct1.Id,
                                                       vlocity_cmt__Product2Id__c = testProduct1.Id,
                                                       QuoteId =qtest.Id, PricebookEntryId=testPricebookEntry1.Id,
                                                       vlocity_cmt__LineNumber__c = '0002');
        insert qouteLine2;
        
        Order testOrder = new Order(
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            QuoteId = qtest.Id,
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert testOrder;
        
        Order testOrder1 = new Order(
            AccountId = testAccount.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            QuoteId = qtest.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            vlocity_cmt__ParentOrderId__c = testOrder.Id
        );
        insert testOrder1;
        // Creating asset test data
        List<Asset> assets = new List<Asset>();
        Asset asset1 = new Asset(
            Name = 'Factory Test asset',
            AccountId = testAccount.Id,
            Product2Id = testProduct1.Id,
            vlocity_cmt__PricebookEntryId__c = testPricebookEntry1.Id,
            Quantity = 1,
            Price = 100.00,
            vlocity_cmt__ParentItemId__c = 'testt',
            vlocity_cmt__RootItemId__c = 'testt',
            vlocity_cmt__AssetReferenceId__c ='123',
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_NUMBER_OF_SITES":2,"ATT_CONTRACT_TERM":"3 Months","ATT_CONTROLLER_TYPE":"CISCO SD-WAN","ATT_SubProductName":"SDWAN", "attName":1}',
            vlocity_cmt__LineNumber__c = '0001',
            vlocity_cmt__ProvisioningStatus__c = 'New',
            vlocity_cmt__ServiceAccountId__c = testAccount.Id);
        Asset asset2 = new Asset(
            Name = 'Factory Test asset 2',
            AccountId = testAccount.Id,
            Product2Id = testProduct1.Id,
            vlocity_cmt__PricebookEntryId__c = testPricebookEntry1.Id,
            Quantity = 1,
            Price = 200.00,
            ARTL_LSI__c = 123456789,
            vlocity_cmt__ParentItemId__c = 'testt',
            vlocity_cmt__RootItemId__c = 'testt',
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_NUMBER_OF_SITES":2,"ATT_CONTRACT_TERM":"3 Months","ATT_CONTROLLER_TYPE":"CISCO SD-WAN","ATT_SubProductName":"SDWAN", "attName":2}',
            vlocity_cmt__AssetReferenceId__c ='123',
            vlocity_cmt__LineNumber__c = '0002',
            vlocity_cmt__ProvisioningStatus__c = 'New',
            vlocity_cmt__ServiceAccountId__c = testAccount.Id);
        Asset asset3 = new Asset(
            Name = 'Factory Test asset 3',
            AccountId = testAccount.Id,
            Product2Id = testProduct1.Id,
            vlocity_cmt__ParentItemId__c = 'testt',
            vlocity_cmt__RootItemId__c = 'testt',
            vlocity_cmt__PricebookEntryId__c = testPricebookEntry1.Id,
            Quantity = 1,
            Price = 300.00,
            vlocity_cmt__AttributeSelectedValues__c = '{"ATT_NUMBER_OF_LICENCES":2,"ATT_CONTRACT_TERM":"3 Months","ATT_CONTROLLER_TYPE":"CISCO SD-WAN","ATT_SubProductName":"SDWAN", "attName":3}',            
            vlocity_cmt__AssetReferenceId__c ='123',
            vlocity_cmt__LineNumber__c = '0003',
            vlocity_cmt__ProvisioningStatus__c = 'New',
            vlocity_cmt__ServiceAccountId__c = testAccount.Id );
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
        Case caseObj = new Case(
            //  ContactId = con.ID,
            AccountId = testAccount.Id,
            Status = 'Working',
            ARTL_LSI__c = '123456789',
            ARTL_PTC__c = 12,
            Origin = 'Phone');
        
        insert caseObj;
        
    }
    @isTest
    static void testCallOrderDisconnectBatch1() {
        Case caseRec = [select Id,ARTL_LSI__c, ARTL_PTC__c from case limit 1];
        
        Test.startTest();
        ARTL_OrderDisconnectBatch batchJob = new ARTL_OrderDisconnectBatch(String.valueof(caseRec.Id));
        Id batchJobId = Database.executeBatch(batchJob, 200);
        Test.stopTest();
    }
}