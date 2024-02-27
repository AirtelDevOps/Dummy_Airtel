@isTest
public class ARTL_LeadConversionTest {
    @testSetup
    public static void testData(){
        Account acc = new Account(Name = 'test');
        insert acc;
        
        Lead leadRec = new Lead(Salutation = 'Mr.',
                                FirstName = 'test', 
                                LastName = 'test',
                                Email = 'test@test.com',
                                MobilePhone = '9876543210',
                                Phone = '9876543210',
                                Company = 'test', 
                                Title = 'test',
                                Related_Account__c = acc.Id, 
                                Lead_Action_Remarks__c = 'Test remarks');
        insert leadRec;
    }
    
    @isTest
    public static void testLeadConversion(){
        Map<String, Object> input = new Map<String, Object>();
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        input.put('leadId', lead.Id);
        input.put('opportunityName', 'Test Opportunity');
        
        Map<String, Object> output = new Map<String, Object>();
        Test.startTest();
        ARTL_LeadConversion helper = new ARTL_LeadConversion();
        Boolean result = helper.invokeMethod('convertLead', input, output, new Map<String, Object>());
        Test.stopTest();
        System.assertEquals(true, result, 'Conversion should be successful');
        Object opportunityRecordIdObj = output.get('OpportunityId');
        Id opportunityRecordId = (Id)opportunityRecordIdObj;
        List<Opportunity> opportunities = [SELECT Id, Name FROM Opportunity WHERE Id = :opportunityRecordId LIMIT 1];
        if (!opportunities.isEmpty()) {
            Opportunity opp = opportunities[0];
            System.assertNotEquals(null, opp, 'Opportunity should exist in the database');
            System.assertEquals('Test Opportunity', opp.Name);
            
        } else {
          
            System.debug('No Opportunity records found with Id: ' + opportunityRecordId);
        }
    }
}