/******************************************************************************************************
* @Author       : arka.bhattacharjee@salesforce.com
* @Company      : Salesforce
* @Date         : 27-Dec-2023
* @Test Class   :
* @Description  : Test Class for ARTL_DocumentUploadController
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date             Comment
*                         Arka Bhattacharjee    27-Dec-2023      Initial Dev
*******************************************************************************************************/
@isTest
public class ARTL_DocumentUploadControllerTest {
/******************************************************************************************************
 * Method Name        : setup
 * Method Description : Test Data 
*******************************************************************************************************/
    @testSetup 
    static void setup() {
         Account[] accounts =new Account[3];
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
        Id billingAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Billing').getRecordTypeId();
        Id serviceAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Service').getRecordTypeId();
        accounts[0] = new Account(Name = 'Test Business Account',RecordTypeId = businessAccountRecordTypeId);
        accounts[1] = new Account(Name = 'Test Billing Account',RecordTypeId  = billingAccountRecordTypeId);
        accounts[2] = new Account(Name = 'Test Service Account',RecordTypeId  = serviceAccountRecordTypeId);
        insert accounts;
        
        Product2[] products = new Product2[2];
        products[0]=new Product2(name='Test Product1', ProductCode='VEPC_ENTERPRISE_ICONNECTIVITY_ROUTERS');
        products[1]=new Product2(name='Test Product2', ProductCode='VEPC_PRIMARY_LINK');
        
        insert products;
        
        PricebookEntry[] pbes = new PricebookEntry[products.size()];
        Id pbId = Test.getStandardPricebookId();
        
        for (Integer i=0; i<products.size(); i++){
            pbes[i] = new PricebookEntry(product2Id = products[i].id, 
                                         IsActive = true, 
                                         unitPrice = 10, 
                                         pricebook2id = pbId, 
                                         useStandardPrice = false);
        }
        
        insert pbes;
        
        
        vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = pbId, 
                                                                      vlocity_cmt__IsActive__c = true, 
                                                                      vlocity_cmt__Code__c = 'TestPricebook5');
        insert pl1;
        
        Opportunity  opp = new Opportunity ();
        opp.name= 'EPC Deal AA';
        opp.accountId = accounts[0].id;
        opp.vlocity_cmt__PriceListId__c = pl1.Id;
        opp.CloseDate = System.today();
        opp.StageName = 'Initial';
        opp.Pricebook2Id = pbId;
        insert opp;
        
        Quote qtest = new Quote();
        qtest.name = 'Quote - EPC Deal AA';
        qtest.Status = 'Draft';
        qtest.OpportunityId = opp.Id;
        qtest.Pricebook2Id = pbId;
        qtest.vlocity_cmt__PriceListId__c = pl1.Id;
        qtest.vlocity_cmt__PoDate__c = Date.today();
        qtest.vlocity_cmt__PoNumber__c = '12345';
        qtest.PO_Term__c = '12';
        qtest.PO_Value__c = 1222;
        qtest.RecordTypeId =  [SELECT Id FROM RecordType WHERE DeveloperName= 'EnterpriseQuote' AND SobjectType= 'Quote' LIMIT 1].Id;
        insert qtest;
        
        PO_Group__c poGroup = new PO_Group__c();
        poGroup.ARTL_PO_Group_Number__c = '123';
        insert poGroup;
        
        PO_Group__c poGroup1 = new PO_Group__c();
        poGroup1.ARTL_PO_Group_Number__c = '1234';
        insert poGroup1;
        
        ARTL_Purchase_Order__c PurchaseOrder = new ARTL_Purchase_Order__c();
        PurchaseOrder.ARTL_PO_Number__c = '111111';
        PurchaseOrder.PO_Group__c = poGroup.id;
        insert PurchaseOrder;
        
        QuoteLineItem  quoteLine1 = new QuoteLineItem ();
        quoteLine1.UnitPrice = 1;
        quoteLine1.Quantity = 1;
        quoteLine1.Product2Id = products[1].Id;
        quoteLine1.vlocity_cmt__Product2Id__c = products[1].Id;
        quoteLine1.QuoteId =qtest.Id;
        quoteLine1.PricebookEntryId=pbes[0].Id;
        quoteLine1.vlocity_cmt__Action__c='Change';
        quoteLine1.ARTL_Purchase_Order__c = PurchaseOrder.Id;
        quoteLine1.vlocity_cmt__ServiceAccountId__c =accounts[2].id;
        quoteLine1.vlocity_cmt__BillingAccountId__c =accounts[1].id;
        
        insert quoteLine1;
        
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'GST certificate';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        
        insert cv;
        
        ARTL_Document__c doc = new ARTL_Document__c();
        doc.Category__c = 'organizationDocument';
        doc.Type__c = 'poe';
        doc.Document_Name__c = 'PAN';
        doc.quote__c=qtest.id;
        insert doc;
        
       /* Document_Upload_Config__mdt DConfig= new Document_Upload_Config__mdt();
		
		DConfig.MasterLabel='GST certificate';
		Dconfig.DeveloperName='GST_certificate_Internet';
		Dconfig.Mandatory_for_OV_Approval__c=true;
		Dconfig.Object_Level__c='Quote';
		Dconfig.Product_Codes__c='3c6df3ca-4424-4131-bde3-c3ea5d5b5925';
		insert Dconfig;*/
        
       
    }
/******************************************************************************************************
 * Class Name        : UploadMockCallout
 * Class Description : Creating Mock Callout and HTTP Response for Test Class 
*******************************************************************************************************/
    public class UploadMockCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"identifier":"00000","source":"leo","document":{"name":"Test","urls":[{"url":"www.example.com"}]}}');
            response.setStatusCode(200);
            return response; 
        }
    }
/******************************************************************************************************
 * Method Name        : testDocUpload
 * Method Description : Testing Doc Upload Callout method
*******************************************************************************************************/
    @isTest
    public static void testDocUpload(){
        ARTL_Document__c doc = [Select Id From ARTL_Document__c Limit 1];
        ContentVersion cv = [SELECT Id, Title, ContentDocumentId FROM ContentVersion Limit 1];
        Test.setMock(HttpCalloutMock.class, new UploadMockCallout());
        Test.startTest();
        ARTL_DocumentUploadController.makeDocUploadCallout(doc.Id,cv.Id);
        Test.stopTest();
    }
/******************************************************************************************************
 * Method Name        : testDocUploadErr
 * Method Description : Testing Doc Upload Callout catch method
*******************************************************************************************************/
    @isTest
    public static void testDocUploadErr(){
        Test.startTest();
        ARTL_DocumentUploadController.makeDocUploadCallout('','');
        ARTL_DocumentUploadController.makeAPICallout(null);
        Test.stopTest();
    }
    @isTest
    public static void testValidateDoc(){
        Test.startTest();
        ARTL_DocumentUploadController.validateDoc([select id from quote limit 1].Id,'Quote');
        Test.stopTest();
    }
}