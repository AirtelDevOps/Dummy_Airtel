@isTest
private class ARTL_ContactDataLoadAPITest {

    @isTest
    static void testDoPostMethod() {
        // Mock the request
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/v1/ContactDataLoad';
        request.httpMethod = 'POST';

        // Mock JSON payload
        String requestBody = '{"Payload": [{"First Name": "John", "Last Name": "Doe", "Mobile": "1234567890"}]}';
        request.requestBody = Blob.valueOf(requestBody);

        // Set the request and response in RestContext
        RestContext.request = request;
        RestContext.response = response;

        // Execute the REST call
        Test.startTest();
        ARTL_ContactDataLoadAPI.doPostMethod();
        Test.stopTest();

        // Check the response
        String responseBody = response.responseBody.toString();
        System.assertEquals(200, response.statusCode, 'Expected a successful response');

        
    }

}