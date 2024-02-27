@isTest
public class ARTL_InvoicePdfVFControllerTest {
    
    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('www.test.com')){
                String jsonBody = 'hello';
                res.setBody(jsonBody);
                res.setStatusCode(200);
                return res;
            }
            else if(req.getEndpoint().contains('www.test1.com')){
                res.setHeader('Content-Type', 'application/json');
                String jsonBody = 'hello';
                res.setBody(jsonBody);
                res.setStatusCode(500);
                return res;
            }
            return res;
        }
    }
    @TestSetup
    static void createData(){
        ARTL_Integration_Details__c integrationDetails = new ARTL_Integration_Details__c();
        integrationDetails.Name = 'GetInvoicePdf';
        integrationDetails.ARTL_API_Key__c = 'test';
        integrationDetails.ARTL_Endpoint__c = 'www.test.com';
        insert integrationDetails;
    }

    @IsTest
    static void abc() {
        ARTL_Integration_Details__c integrationDetails = new ARTL_Integration_Details__c();
        integrationDetails.Name = 'GetInvoicePdf';
        integrationDetails.ARTL_API_Key__c = 'test';
        integrationDetails.ARTL_Endpoint__c = 'www.test.com';
        insert integrationDetails;
        
        Test.setMock(HttpCalloutMock.class, new Mock());
        ARTL_InvoicePdfVFController controller = new ARTL_InvoicePdfVFController();
        Test.startTest();
        PageReference pageRef = Page.ARTL_FetchPdf;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('reference', '1-4FU3SZK');
        String pdf = controller.pdf;
        Test.stopTest();
        
    }

    @IsTest
    static void xyz() {
        ARTL_Integration_Details__c integrationDetails = new ARTL_Integration_Details__c();
        integrationDetails.Name = 'GetInvoicePdf';
        integrationDetails.ARTL_API_Key__c = 'test1';
        integrationDetails.ARTL_Endpoint__c = 'www.test1.com';
        insert integrationDetails;
        
        Test.setMock(HttpCalloutMock.class, new Mock());
        ARTL_InvoicePdfVFController controller = new ARTL_InvoicePdfVFController();
        Test.startTest();
        PageReference pageRef = Page.ARTL_FetchPdf;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('reference', '1-4FU3SZK');
        String pdf = controller.pdf;
        Test.stopTest();
    }
    
    

}