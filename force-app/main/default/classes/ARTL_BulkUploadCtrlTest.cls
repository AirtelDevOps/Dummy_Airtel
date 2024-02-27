@isTest
public class ARTL_BulkUploadCtrlTest {
        
    @testSetup
    public static void testData(){
        ARTL_Bulk_Upload_Config__mdt obj = NEW ARTL_Bulk_Upload_Config__mdt();
        obj.Field_API_Name__c = 'Account Number,Fiscal Year,Product Category,Total Competitor Spend,Spends with Airtel,Key Competitor and Comments,Account Plan';
        obj.File_Header_CSV__c = 'Account_Number__c,Fiscal_Year__c,Product_Category__c,Total_Competitor_Spends__c,Spends_with_Airtel__c,Key_Competitor_and_Comments__c,Account_Plan__c';
        obj.Object_Fields__c = 'Account_Number__c,Fiscal_Year__c,Product_Category__c,Total_Competitor_Spends__c,Spends_with_Airtel__c,Key_Competitor_and_Comments__c,Account_Plan__c,Account_Name__c';
        obj.DeveloperName = 'BUC';
        obj.Template_URL__c = 'www.google.com';
        //insert obj;
        
        ARTL_Bulk_Upload_Iteration__c  ite = NEW ARTL_Bulk_Upload_Iteration__c ();
        ite.Name = 'BUC';
        ite.File_Name__c = 'sample.csv';
        insert ite;
        
    }

    @isTest
    public static void getMetadataConfigTest(){
        Test.startTest();
        Map<String,Object> res = ARTL_BulkUploadCtrl.getMetadataConfig();
        Test.stopTest();
    }
    
    @isTest
    public static void createIterationTest(){
        String fileName = 'test.csv';
        String typeIs = 'BUC';
        Test.startTest();
        string iteId = ARTL_BulkUploadCtrl.createIteration(fileName,typeIs);
        Test.stopTest();
    }
    
    @isTest
    public static void inititeValidationBatchTest(){
        String typeIs = 'BUC';
        List<ARTL_Bulk_Upload_Iteration__c> ite = [SELECT id FROM ARTL_Bulk_Upload_Iteration__c limit 1];
        Test.startTest();
        ARTL_BulkUploadCtrl.inititeValidationBatch(ite[0].Id,typeIs);
        Test.stopTest();
    }
    
    @isTest
    public static void uploadDataTest(){
        List<Object> csv = new List<Object>();
        Object str = 'BS-00000050,2023,Multiplay,7643,3336,testtest1,AP-0000022, BS-00000050,2023,Multiplay,7646,333,testtest2,';
        csv.add(str);
        String header = 'Account Number,Fiscal Year,Product Category,Total Competitor Spends,Spends with Airtel,Key Competitor and Comments,Account Plan';
        String typeObj = 'BUC';
        List<ARTL_Bulk_Upload_Iteration__c> ite = [SELECT id FROM ARTL_Bulk_Upload_Iteration__c limit 1];
        Test.startTest();
        ARTL_BulkUploadCtrl.uploadData(csv,header,typeObj,ite[0].Id);
        Test.stopTest();
    }
    
    @isTest
    public static void getTemplateTest(){
        Test.startTest();
        ARTL_BulkUploadCtrl.getTemplate('BUC');
        Test.stopTest() ;
    }
}