@IsTest
private class ARTL_DRE_OpportunityOnAccountPlanTest {
    
    @testSetup static void testData() {
        
        User testUser = new User(FirstName = 'Test', LastName = 'User', Email = 'test.user@email.com', Username='test7864er@user.com',Alias = 'tuser', TimeZoneSidKey='Asia/Kolkata',
                                 ProfileId = '00e5j0000048gp8AAA', LocaleSidKey = 'en_IN', LanguageLocaleKey  = 'en_US', EmailEncodingKey='UTF-8');
        insert testUser;
        
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Account acc = new Account(Name = 'TestAccount',
                                              RecordTypeId = recordTypeIdAccount,
                                              BillingCity = 'Panchkula',
                                              BillingCountry = 'Haryana',
                                              BillingPostalCode = '134109',
                                              BillingState = 'India',
                                              BillingStreet = 'Panchkula', 
                                              ARTL_IntegrationId__c = 'test', 
                                              ARTL_Category__c = 'A', 
                                              ARTL_Customer_Segment__c = 'AB',
                                              ARTL_Service_Segment__c = 'BD',
                                              ARTL_Vertical_Segment__c = 'BFI',
                                              ARTL_Business_Circle_Region__c = 'AP',
                                              ARTL_PAN__c = 'ABCDE1234F');
        insert acc;
        
        List<Opportunity> lstOpps = new List<Opportunity>();
        lstOpps = new Opportunity[2];
        lstOpps[0] = new Opportunity(Name='TestOpp1', StageName='Initial', AccountId = acc.Id, Amount = 10, CloseDate = System.Today());
        lstOpps[1] = new Opportunity(Name='TestOpp2', AccountId = acc.Id, StageName='Initial', Amount = 20, CloseDate = System.Today());
        insert lstOpps;
        
        Id recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_Internal_Contact').getRecordTypeId();
        Contact con = new Contact(FirstName='Test', LastName='Contact', AccountId=acc.Id, OwnerId= testUser.Id, Phone='1234567890',Email='test@test.com',
                                  ARTL_Interaction_Level__c='Board Level', ARTL_Designation__c='TestDesgntn', ARTL_Contact_Role__c = 'Resident Engineer',
                                  ARTL_stakeholder_score__c='2.5', RecordTypeId=recordTypeIdContact,Country_Code__c  = '1',Salutation = 'Ms.'
                                 );
        insert con;
        
        Contact con1 = new Contact(FirstName='TestName', LastName='Contact', AccountId=acc.Id, OwnerId= testUser.Id, Phone='1224567899',Email='test11@test.com',
                                   ARTL_Interaction_Level__c='Board Level', ARTL_Designation__c='TestDesgntn',  ARTL_Contact_Role__c = 'Resident Engineer',
                                   ARTL_stakeholder_score__c='2.5', RecordTypeId=recordTypeIdContact
                                  );
        insert con1;
        
        Event testEvent = new Event(
            Subject = 'Test Event',
            DurationInMinutes = 10,
            vlocity_cmt__eventstatus__c = 'Error',
            ActivityDateTime = System.now(),
            WhoId= con.id,
            WhatId = acc.Id
        );
        insert testEvent;
        
        Account_Plan__c objAP = new Account_Plan__c(Account_Plan_Status__c = 'Draft', Account_Name__c = acc.Id, CE_Head__c = testUser.Id);
        insert objAP;
        
        List<Product2> products = new List<Product2>();
        //Id pbId = Test.getStandardPricebookId();
        products = new Product2[2];
        products[0]=new Product2(name='Test Prod1', Family='Multiplay', ProductCode='VEPC_PRIMARY_LINK ',vlocity_cmt__JSONAttribute__c = '');
        products[1]=new Product2(name='Test Prod2 ', Family='Internet', ProductCode='VEPC_PRIMARY_MPLS_LINK ', vlocity_cmt__JSONAttribute__c = '');
        insert products;
        
        List<Bottom_Up_Construct__c> lstBUCs = new List<Bottom_Up_Construct__c>();
        lstBUCs = new Bottom_Up_Construct__c[2];
        string dateValue = string.valueOf((Date.today()).year()); 
        lstBUCs[0] = new Bottom_Up_Construct__c(Product_Category__c=products[0].Id, Account_Plan__c = objAP.Id,  Account_Name__c = acc.Id, Fiscal_Year__c = dateValue, Total_Competitor_Spends__c=10, Spends_with_Airtel__c=20);
        lstBUCs[1] = new Bottom_Up_Construct__c(Product_Category__c=products[1].Id, Account_Plan__c = objAP.Id, Account_Name__c = acc.Id, Fiscal_Year__c = dateValue, Total_Competitor_Spends__c=10, Spends_with_Airtel__c=20);
        insert lstBUCs; 
    }
    
    static testMethod void testDefault(){
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        
        Map<String, Object> inputs = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        List<object> arguments = new List<object>();
        arguments.add(acc.Id);
        arguments.add(05);
        inputs.put('arguments', arguments);
        
        ARTL_DRE_OpportunityOnAccountPlan obj = new ARTL_DRE_OpportunityOnAccountPlan();
        Test.startTest();
        obj.invokeMethod('default', inputs, output, options);
        obj.invokeMethod('Test', inputs, output, options);
        Test.stopTest();
        
        List<Map<String, Object>> lstContacts = (List<Map<String, Object>>) output.get('result');
        System.assertEquals(lstContacts.size()>0, true);
    }
    
    static testMethod void testFetchBUC(){
        
        Account_Plan__c objAP = [SELECT Id, Name FROM Account_Plan__c WHERE Account_Plan_Status__c = 'Draft'];
        
        Map<String, Object> inputs = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        List<object> arguments = new List<object>();
        
        arguments.add(objAP.Id);
        inputs.put('arguments', arguments);
        
        ARTL_DRE_OpportunityOnAccountPlan obj = new ARTL_DRE_OpportunityOnAccountPlan();
        Test.startTest();
        obj.invokeMethod('fetchBUC', inputs, output, options);
        Test.stopTest();
        
        Map<String, Object> lstContacts = (Map<String, Object>) output.get('result');
        System.assertEquals(lstContacts.size()>0, true);
    }
    
    static testMethod void testFetchFiscalYrOpp(){
        
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];        
        
        Map<String, Object> inputs = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        List<object> arguments = new List<object>();
        arguments.add(acc.Id);
        arguments.add((Date.today()).year());
        inputs.put('arguments', arguments);
        
        ARTL_DRE_OpportunityOnAccountPlan obj = new ARTL_DRE_OpportunityOnAccountPlan();
        Test.startTest();
        obj.invokeMethod('fetchFiscalYrOpp', inputs, output, options);
        Test.stopTest(); 
        
        List<Map<String, Object>> lstContacts = (List<Map<String, Object>>) output.get('result');
        System.assertEquals(lstContacts.size()>0, true);
    }    
}