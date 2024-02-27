/******************************************************************************************************
* @Author       : arka.bhattacharjee@salesforce.com
* @Company      : Salesforce
* @Date         : 27-Dec-2023
* @Test Class   :
* @Description  : Test Class for ARTL_DocumentDownloadController
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date             Comment
*                         Arka Bhattacharjee    27-Dec-2023      Initial Dev
*******************************************************************************************************/
@isTest
public class ARTL_DocumentDownloadControllerTest {
/******************************************************************************************************
 * Method Name        : setup
 * Method Description : Test Data 
*******************************************************************************************************/
    @testSetup 
    static void setup() {
        
    }
/******************************************************************************************************
 * Method Name        : testDocDownload
 * Method Description : Testing Doc Download Callout method
*******************************************************************************************************/
    @isTest
    public static void testDocDownload(){
        Test.startTest();
        ARTL_DocumentDownloadController.makeDocDownloadloadCallout('');
        Test.stopTest();
    }
/******************************************************************************************************
 * Method Name        : testGetDoc
 * Method Description : Testing Get Doc method
*******************************************************************************************************/
    @isTest
    public static void testGetDoc(){
		Test.startTest();
        ARTL_DocumentDownloadController.getDocuments('Test','Account');
        ARTL_DocumentDownloadController.getDocuments('Test','Contact');
        ARTL_DocumentDownloadController.getDocuments('Test','Opportunity');
        ARTL_DocumentDownloadController.getDocuments('Test','Quote');
        ARTL_DocumentDownloadController.getDocuments('Test','Order');
        ARTL_DocumentDownloadController.getDocumentsWire('Test','Test');
        Test.stopTest();        
    }
}