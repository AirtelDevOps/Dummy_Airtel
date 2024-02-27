@isTest
public with sharing class Artl_BcpDcpCtrlTest {
    
    @testSetup
    public static void testData(){
        System.debug('DEBUGG testData ');
        try{
            List<String> conRoleList = new List<String>{'Billing Contact', 'Delivery Contact'};

            List<Account> accRecords = ARTL_TestDataFactory.createAccount('Billing Aggregator', true, 1);

            List<Contact> conRecords = ARTL_TestDataFactory.createContact('BCP/DCP Contact', accRecords[0].Id, false, 1);
            for (Contact con : conRecords) {
                con.ARTL_Contact_Role__c = conRoleList[0];
                con.Salutation = 'Mr.';
            }
            insert conRecords;
            
            vlocity_cmt__Premises__c premiseRecord = new vlocity_cmt__Premises__c(Name = 'test', 
                                                                                vlocity_cmt__StreetAddress__c = 'Panchkula',
                                                                                vlocity_cmt__City__c = 'Panchkula',
                                                                                vlocity_cmt__State__c = 'Haryana',
                                                                                vlocity_cmt__PostalCode__c = '134109',
                                                                                vlocity_cmt__Country__c = 'India');
            insert premiseRecord;
            
            ContactPremiseRelation__c contactPremiseRelationRecord = new ContactPremiseRelation__c(Contact__c = conRecords[0].Id, 
                                                                                                Premises__c = premiseRecord.Id,
                                                                                                //ARTL_NBA_Account__c = nbaAccount.Id,
                                                                                                ARTL_GST_Applicable__c = 'No',
                                                                                                ARTL_Standard_Reason__c = 'Others',
                                                                                                Role__c = 'BCP');
            insert contactPremiseRelationRecord;
            System.debug('Finish testData ');
        }
        catch(Exception e){
            System.debug('ss e.msg()=' + e.getMessage());
            System.debug('e.cause=' + e.getCause());
            System.debug('e.getLineNumber=' + e.getLineNumber());
            System.debug('e.getStackTraceString=' + e.getStackTraceString());
            System.debug('e.getTypeName=' + e.getTypeName());
        }
    }
    
    @isTest
    public static void test_getBcpDcpByAccId(){
        List<Account> accRecords = [Select Id From Account];
        System.assert(!accRecords.isEmpty(), 'No account record found');
        Artl_BcpDcpCtrl.getBcpDcpByAccId(accRecords[0].Id);
    }

    @isTest
    public static void test_handleNotification(){
        
        Artl_BcpDcpCtrl.handleNotification('someRandomId');
    }
}