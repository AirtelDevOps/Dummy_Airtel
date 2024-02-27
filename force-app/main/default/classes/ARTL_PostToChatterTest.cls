@isTest
public class ARTL_PostToChatterTest {
    @testSetup
    public static void testData(){
        
        Lead led = New Lead(Salutation = 'Mr.',FirstName = 'Roy',LastName = 'Associates', Company = 'Test', Email = 'roy@test.com');
        insert led;
        Lead led2 = New Lead(Salutation = 'Mr.',FirstName = 'Tom',LastName = 'Associates', Company = 'Test', Email = 'tom@test.com');
        insert led2;
    }
	@isTest
    public static void chatterPostToLeadOwner(){
        
        List<Id> leads = New List<Id>();
        for(Lead ld :[SELECT id from LEAD limit 2] ){
            leads.add(ld.id);
        }
        
        Test.startTest();
        ARTL_PostToChatter.chatterPostToLeadOwner(leads);
        Test.stopTest();
    }

}