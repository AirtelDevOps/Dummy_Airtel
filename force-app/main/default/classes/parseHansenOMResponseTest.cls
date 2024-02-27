@isTest
public class parseHansenOMResponseTest {
    
    @isTest
    static void parseXML() {
        
        String XMLString = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><som:OrderResponse xmlns:cmn="http://ossj.org/xml/Common/v1-5" xmlns:bi="http://ossj.org/xml/Common-CBEBi/v1-5" xmlns:cbe="http://ossj.org/xml/Common-CBECore/v1-5" xmlns:cbe-service="http://ossj.org/xml/Common-CBEService/v1-5" xmlns:cbe-location="http://ossj.org/xml/Common-CBELocation/v1-5" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:som="http://som.sigma.com" xmlns:cbe-product-offering="http://ossj.org/xml/Common-CBEProductOffering/v1-5" xmlns:cbe-product="http://ossj.org/xml/Common-CBEProduct/v1-5" xmlns:cbe-datatype="http://ossj.org/xml/Common-CBEDatatypes/v1-5" xmlns:cbe-resource="http://ossj.org/xml/Common-CBEResource/v1-5" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cbe-party="http://ossj.org/xml/Common-CBEParty/v1-5" xmlns:om="http://ossj.org/xml/OrderManagement/v1-0"><som:status>OK</som:status><som:orderId>710228</som:orderId><som:type>Submit Order</som:type></som:OrderResponse>';
		Map<String, Object> input=new Map<String, Object>();
        input.put('response',XMLString);
        Map<String, Object> output=new Map<String, Object>();
        Map<String, Object> options=new Map<String, Object>();
        
  		string methodName='parseXML';        
       	parseHansenOMResponse parseObj = new parseHansenOMResponse();
        Test.startTest();
        parseObj.invokeMethod(methodName, input, output, options);
        Test.stopTest();
    }
}