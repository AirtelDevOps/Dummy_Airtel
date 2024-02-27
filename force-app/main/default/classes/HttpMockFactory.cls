@isTest
public class HttpMockFactory implements HttpCalloutMock{
    protected integer code;
    protected string status;
    protected string body;
    protected List<Object> body2;
    protected map<string,string> responseHeaders;
    
    public HttpMockFactory(Integer code,String status,String body){
        this.code=code;
        this.status=status;
        this.body=body;
        this.responseHeaders=responseHeaders;
    }
    
    public HttpMockFactory(Integer code,String status,List<Object> body){
        this.code=code;
        this.status=status;
        this.body2=body;
        //this.responseHeaders=responseHeaders;
    }
    
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');     
        response.setBody(this.body);
        response.setStatusCode(this.code);
        response.setStatus(this.status);
        return response; 
    }
}