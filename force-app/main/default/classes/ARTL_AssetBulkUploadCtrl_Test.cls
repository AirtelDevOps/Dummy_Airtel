@isTest
public with sharing class ARTL_AssetBulkUploadCtrl_Test {
    
    @testSetup 
    static void setup() {
        try{
            // Create common test Iteration
            List<ARTL_Bulk_Upload_Iteration__c> testIterations = new List<ARTL_Bulk_Upload_Iteration__c>();
            
            ARTL_Bulk_Upload_Iteration__c iterationRecord = new ARTL_Bulk_Upload_Iteration__c();
            iterationRecord.Name = 'Test 1';
            iterationRecord.Journey_Type__c = 'Upgrade';
            testIterations.add(iterationRecord);

            insert testIterations;   
        }
        catch (Exception e){
            System.assert(false, 'Error in creating test setup records = ' + e.getMessage());
        }     
    }

    @isTest
    public static void test_checkLsi(){
        List<Decimal> lsiNumbers = new List<Decimal>{12345678900.0, 12345678901.0};
        List<ARTL_Bulk_Upload_Iteration__c> iterationList = [Select Id From ARTL_Bulk_Upload_Iteration__c];
        String iterationId = iterationList[0].Id;

        Test.StartTest();
            try {
                ARTL_AssetBulkUploadCtrl.checkLsi(lsiNumbers, iterationId);
            } catch (Exception e) {
                
            }
        Test.StopTest();
    }

    @isTest
    public static void test_checkLsi2(){
        List<Decimal> lsiNumbers = new List<Decimal>{12345678900.0, 12345678901.0};
        //List<ARTL_Bulk_Upload_Iteration__c> iterationList = [Select Id From ARTL_Bulk_Upload_Iteration__c];
        String iterationId = '';

        Test.StartTest();
            ARTL_AssetBulkUploadCtrl.checkLsi(lsiNumbers, iterationId);
        Test.StopTest();
    }

    @isTest
    public static void test_createStagingRecords(){
        List<Decimal> lsiNumbers = new List<Decimal>{12345678900.0, 12345678901.0};
        List<ARTL_Bulk_Upload_Iteration__c> iterationList = [Select Id From ARTL_Bulk_Upload_Iteration__c];
        String iterationId = iterationList[0].Id;

        Test.StartTest();
            ARTL_AssetBulkUploadCtrl.createStagingRecords(lsiNumbers, iterationId);
        Test.StopTest();
    }
}