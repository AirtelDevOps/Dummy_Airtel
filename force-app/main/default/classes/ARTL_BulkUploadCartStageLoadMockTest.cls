public class ARTL_BulkUploadCartStageLoadMockTest implements HttpCalloutMock{
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint().contains('https://business-force-5632--artldevp2.sandbox.my.salesforce.com/services/apexrest/api/getQuoteLineItems')){
			res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
        }else if(req.getEndpoint().contains('https://b2benterprisebusiness.airtel.com/app/v1/excels/DownloadSfdc')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
        }
        else if(req.getEndpoint().contains('https://b2benterprisebusiness.airtel.com/app/v1/excels/ExcelToJsonSfdc')){
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
        }
        
        return res;
    }

}