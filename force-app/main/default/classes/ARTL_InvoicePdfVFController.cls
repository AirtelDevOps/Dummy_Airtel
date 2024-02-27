public class ARTL_InvoicePdfVFController {
    Public String pdfString;
    public string reference;
    public class CustomException extends Exception {}
    
    public ARTL_InvoicePdfVFController(){
        System.debug('DEBUGG reference id '+ApexPages.currentPage().getParameters().get('reference'));
        reference = ApexPages.currentPage().getParameters().get('reference');
    }
    
    public String pdf {
        get {
            try{
                ARTL_Integration_Details__c integrationDetail = ARTL_Integration_Details__c.getInstance('GetInvoicePdf');
                String billNumber = reference; //'1-4FU3SZK';
                String acceptedFormat = 'application/pdf';
                
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http();
                request.setHeader('api-key', integrationDetail.ARTL_API_Key__c);
                request.setHeader('accept', acceptedFormat);
                request.setEndpoint(integrationDetail.ARTL_Endpoint__c+'?billNumber='+billNumber);
                request.setMethod('GET');
                
                response = http.send(request);
                System.debug('DEBUGG response.getBodyAsBlob'+ response.getBodyAsBlob());
                if(response.getStatusCode() == 200){
                    pdfString = EncodingUtil.base64Encode(response.getBodyAsBlob());
                    return 'data:application/pdf;base64,'+EncodingUtil.Base64Encode(response.getBodyAsBlob());
                } 
                else if (response.getStatusCode() == 500){
                    throw new CustomException('No Bill Found.');
                }
                return null;
            }
            catch(Exception ex){
                System.debug('DEBUGG catch '+ ex.getMessage());
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage());
                ApexPages.addMessage(msg);
                return null;
            }
        }
    }
    
}