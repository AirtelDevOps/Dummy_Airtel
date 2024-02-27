/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-08-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public with sharing class ARTL_BCPDCPBulkUpdateBatchTest {
    
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

            ARTL_Bulk_Upload_Iteration__c iterationRecNew = new ARTL_Bulk_Upload_Iteration__c( Name = 'ARTL_BCPDCPBulkUpdateBatch' );
            Database.insert(iterationRecNew);

            ARTL_Bulk_Upload_Staging__c stagingRecNew = new ARTL_Bulk_Upload_Staging__c(Name = 'Test Staging Rec new', ARTL_Bulk_Upload_Iteration__c = iterationRecNew.Id, Record_Id__c = String.ValueOf(contactPremiseRelationRecord.Id), First_Name__c = 'Test class');
            Database.insert(stagingRecNew);

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
        List<ARTL_Bulk_Upload_Iteration__c> itrRecords = [Select Id From ARTL_Bulk_Upload_Iteration__c];
        System.assert(!itrRecords.isEmpty(), 'No Iteration record found');
        Id batchJobId = Database.executeBatch(new ARTL_BCPDCPBulkUpdateBatch(itrRecords[0].Id), 200); 
    }
}