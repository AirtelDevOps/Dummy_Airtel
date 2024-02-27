@isTest
public with sharing class ARTL_ProposalTemplateClass_Test {
    @isTest
    static void testInvokeMethod() {
     
            // Create a test Account
            Account testAccount = new Account(Name='Test Account');
            insert testAccount;
            
            // Create a test Contact
            Contact testContact = new Contact(
                FirstName = 'John',
                LastName = 'Doe',
                Email ='hhh@hhh.com',
                ARTL_Designation__c ='test',
                ARTL_Contact_Role__c ='Billing Contact',
                phone='1234567890998',
                AccountId = testAccount.Id
            );
            insert testContact;
            
            //Create an Opportunity
            Opportunity opp = new Opportunity();
            opp.Name = 'Test Opp';
            opp.StageName= 'Initial';
            opp.CloseDate=System.today()+10;
            insert opp;
            
            // Create a test Pricebook
            Pricebook2 testPricebook = new Pricebook2(
                Name = 'Test Pricebook',
                IsActive = true
            );
            insert testPricebook;
            
            // Create a test Quote
            Quote testQuote = new Quote(
                Name = 'Test Quote',
                OpportunityId = opp.Id,
                Pricebook2Id = testPricebook.Id
                //AccountId = testAccount.Id,
                //  QuoteNumber = 'Q0001',
                // vlocity_cmt__OneTimeTotal__c = 1000.00,
                // vlocity_cmt__RecurringTotal__c = 2000.00
            );
            insert testQuote;
            
            // Create a test Quote Member
            vlocity_cmt__QuoteMember__c testQuoteMember = new vlocity_cmt__QuoteMember__c(
                vlocity_cmt__QuoteId__c = testQuote.Id,
                vlocity_cmt__StreetAddress__c = 'Marathalli'
            );
            insert testQuoteMember;   
            
            // Create a test Product
            Product2 testProduct = new Product2(
                Name = 'Test Product',
                ProductCode = 'P001',
                vlocity_cmt__IsLocationDependent__c = false
            );
            insert testProduct;
            Product2 testProduct2 = new Product2(
                Name = 'Test Product2',
                ProductCode = 'P002',
                vlocity_cmt__IsLocationDependent__c = false
            );
            insert testProduct2;
            
            vlocity_cmt__ProductChildItem__c pcI = new vlocity_cmt__ProductChildItem__c();
            pcI.vlocity_cmt__ParentProductId__c = testProduct.Id;
            pcI.vlocity_cmt__ChildProductId__c = testProduct2.Id;
            pcI.vlocity_cmt__MaxQuantity__c = 1;
            pcI.vlocity_cmt__MinQuantity__c = 1;
            pcI.vlocity_cmt__ChildLineNumber__c = '60';
            //pcI.vlocity_cmt__MinMaxDefaultQty__c = 1;
            insert pcI;
                 
            
            // Create a standard price for the product
            PricebookEntry standardPrice = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
                Product2Id = testProduct.Id,
                UnitPrice = 100.00,
                IsActive = true
            );
            insert standardPrice;
            
            // Create a Pricebook Entry
            PricebookEntry testPricebookEntry = new PricebookEntry(
                Pricebook2Id = testPricebook.Id,
                Product2Id = testProduct.Id,
                UnitPrice = 100.00,
                IsActive = true
            );
            insert testPricebookEntry;
            
            
            // Create a test Quote Line Item
            QuoteLineItem testLineItem = new QuoteLineItem(
                QuoteId = testQuote.Id,
                Product2Id = testProduct.Id,
                Quantity = 2,
                PricebookEntryId =  testPricebookEntry.Id,
                UnitPrice = 100.00,
                vlocity_cmt__OneTimeTotal__c = 500.00,
                vlocity_cmt__RecurringTotal__c = 1000.00,
                Annual_Recurring_Total__c = 2000.00,
                vlocity_cmt__AssetReferenceId__c = 'parent1',
                vlocity_cmt__QuoteMemberId__c = testQuoteMember.Id // Custom field to hold Quote Member Id
                // QuoteMemberFirstName__c = testContact.FirstName, // Custom field to hold Quote Member First Name
                //  QuoteMemberLastName__c = testContact.LastName // Custom field to hold Quote Member Last Name
            );
            insert testLineItem;
                        
            QuoteLineItem testLineItem1 = new QuoteLineItem(
                QuoteId = testQuote.Id,
                Product2Id = testProduct.Id,
                Quantity = 2,
                PricebookEntryId =  testPricebookEntry.Id,
                UnitPrice = 100.00,
                vlocity_cmt__OneTimeTotal__c = 500.00,
                vlocity_cmt__RecurringTotal__c = 1000.00,
                Annual_Recurring_Total__c = 2000.00,
                vlocity_cmt__AssetReferenceId__c = 'parent2',
                vlocity_cmt__ParentItemId__c = 'parent1',
                vlocity_cmt__QuoteMemberId__c = testQuoteMember.Id // Custom field to hold Quote Member Id
                // QuoteMemberFirstName__c = testContact.FirstName, // Custom field to hold Quote Member First Name
                //  QuoteMemberLastName__c = testContact.LastName // Custom field to hold Quote Member Last Name
            );
            insert testLineItem1;
            
            
            QuoteLineItem testLineItem2 = new QuoteLineItem(
                QuoteId = testQuote.Id,
                Product2Id = testProduct.Id,
                Quantity = 2,
                PricebookEntryId =  testPricebookEntry.Id,
                UnitPrice = 100.00,
                vlocity_cmt__OneTimeTotal__c = 500.00,
                vlocity_cmt__RecurringTotal__c = 1000.00,
                Annual_Recurring_Total__c = 2000.00,
                vlocity_cmt__AssetReferenceId__c = 'parent3',
                vlocity_cmt__ParentItemId__c = 'parent2',
                vlocity_cmt__QuoteMemberId__c = testQuoteMember.Id // Custom field to hold Quote Member Id
                // QuoteMemberFirstName__c = testContact.FirstName, // Custom field to hold Quote Member First Name
                //  QuoteMemberLastName__c = testContact.LastName // Custom field to hold Quote Member Last Name
            );
            insert testLineItem2;
    
            
            // Create a test Document Template
            vlocity_cmt__DocumentTemplate__c testTemplate = new vlocity_cmt__DocumentTemplate__c(
                Name = 'Test Template'
            );
            insert testTemplate;
            
            // Prepare input data
            Map<String, Object> input = new Map<String, Object>();
            input.put('contextId', testQuote.Id);
            input.put('templateId', testTemplate.Id);
            Map<String, Object> output = new Map<String, Object>();
            Map<String, Object> options = new Map<String, Object>();
            
            // Call the invokeMethod and assert the result
            ARTL_ProposalTemplateClass pTC = new ARTL_ProposalTemplateClass();
            Object result = pTC.invokeMethod('getTokenData', input, output, options);
            
      
        
    }
}