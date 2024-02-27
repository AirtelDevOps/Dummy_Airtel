/**
 * This class contains unit tests for validating the behavior of the
 * CSVUtils Apex class.
 *
 * @author  Joe McMaster (jmcmaster@vlocity.com)
 * @version 1.0
 *
  * History
 * -------
 * v1.0 - Feb 18, 2020 - Initial Version tests 100% of CSVUtils v3.1
 *
 */
@isTest
private class CSVUtils_Test {

    // Simple CSV File with header
    private static final String FILE1 = 'data:text/csv;base64,TmFtZSxFbWFpbCBBZGRyZXNzLFBob25lIE51bWJlcixBZ2UKSmFjayBCbGFjayxqYmxhY2tAdmxvY2l0eS5jb20sNzEyLTY3OC0zODMwLDQwCk5hbmN5IFByaW5nbGUsbnByaW5nbGVAdmxvY2l0eS5jb20sNjkzLTIzOC0xMjM4LDMzClphayBNaWthLHptaWthQHZsb2NpdHkuY29tLDcwMS0yMTMtMzgxMCw1NQpKZXNzIE1jRG9uYWxkLGptY2RvbmFsZEB2bG9jaXR5LmNvbSw3OTAtMTIzLTEyMzgsMjQK';

    // Simple CSV File with no header
    private static final String FILE2 = 'data:text/csv;base64,SmFjayBCbGFjayxqYmxhY2tAdmxvY2l0eS5jb20sNzEyLTY3OC0zODMwLDQwCk5hbmN5IFByaW5nbGUsbnByaW5nbGVAdmxvY2l0eS5jb20sNjkzLTIzOC0xMjM4LDMzClphayBNaWthLHptaWthQHZsb2NpdHkuY29tLDcwMS0yMTMtMzgxMCw1NQpKZXNzIE1jRG9uYWxkLGptY2RvbmFsZEB2bG9jaXR5LmNvbSw3OTAtMTIzLTEyMzgsMjQK';

    // Simple CSV File with no encoding details
    private static final String FILE3 = 'data:text/csv;,Name,Email Address,Phone Number,Age\nJack Black,jblack@vlocity.com,712-678-3830,40\nNancy Pringle,npringle@vlocity.com,693-238-1238,33\nZak Mika,zmika@vlocity.com,701-213-3810,55\nJess McDonald,jmcdonald@vlocity.com,790-123-1238,24\n';

    // Bad CSV File (incorrect number of headers)
    private static final String BADFILE1 = 'data:text/csv;base64,TmFtZSxFbWFpbCBBZGRyZXNzLFBob25lIE51bWJlcgpKYWNrIEJsYWNrLGpibGFja0B2bG9jaXR5LmNvbSw3MTItNjc4LTM4MzAsNDAKTmFuY3kgUHJpbmdsZSxucHJpbmdsZUB2bG9jaXR5LmNvbSw2OTMtMjM4LTEyMzgsMzMKWmFrIE1pa2Esem1pa2FAdmxvY2l0eS5jb20sNzAxLTIxMy0zODEwLDU1Ckplc3MgTWNEb25hbGQsam1jZG9uYWxkQHZsb2NpdHkuY29tLDc5MC0xMjMtMTIzOCwyNA==';
    
    // Bad CSV File (incorrect encoding values)
    private static final String BADFILE2 = 'data:text/bad;base64,TmFtZSxFbWFpbCBBZGRyZXNzLFBob25lIE51bWJlcgpKYWNrIEJsYWNrLGpibGFja0B2bG9jaXR5LmNvbSw3MTItNjc4LTM4MzAsNDAKTmFuY3kgUHJpbmdsZSxucHJpbmdsZUB2bG9jaXR5LmNvbSw2OTMtMjM4LTEyMzgsMzMKWmFrIE1pa2Esem1pa2FAdmxvY2l0eS5jb20sNzAxLTIxMy0zODEwLDU1Ckplc3MgTWNEb25hbGQsam1jZG9uYWxkQHZsb2NpdHkuY29tLDc5MC0xMjMtMTIzOCwyNA==';

    /*
     * Test of a simple CSV file with a header
     *
     */
    @isTest
    static void test1() {

        Map<String, Object> inputMap  = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options   = new Map<String, Object>();
        options.put('header', true);
        options.put('delimiter', ',');

        Map<String, String> files = new Map<String, String>();
        files.put('file1', FILE1);
        options.put('vlcFilesMap', files);

        // Execute the Test
        CSVUtils myclass = new CSVUtils();
        Boolean result = myclass.invokeMethod('load', inputMap, outputMap, options);       
        
        // Validation
        System.assert(result, 'CSVUtils.invokeMethod() returned false when it should have returned true');
        System.assert(outputMap.containsKey('data'), 'CSVUtils failed to return data');

        Object obj = outputMap.get('data');
        System.assert(obj instanceof List<Object>, 'CSVUtils returned data, but expected a list');
        
        List<Object> data = (List<Object>)outputMap.get('data');
        System.assert(data.size() == 4, 'CSVUtils did not return the expected number of rows');
    }

    /*
     * Simple Test of a CSV file without a header
     *
     */
    @isTest
    static void test2() {

        Map<String, Object> inputMap  = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options   = new Map<String, Object>();
        options.put('header', false);
        options.put('delimiter', ',');

        Map<String, String> files = new Map<String, String>();
        files.put('file1', FILE2);
        options.put('vlcFilesMap', files);

        // Execute the Test
        CSVUtils myclass = new CSVUtils();
        Boolean result = myclass.invokeMethod('load', inputMap, outputMap, options);       
        
        // Validation
        System.assert(result, 'CSVUtils.invokeMethod() returned false when it should have returned true');
        System.assert(outputMap.containsKey('data'), 'CSVUtils failed to return data');

        Object obj = outputMap.get('data');
        System.assert(obj instanceof List<Object>, 'CSVUtils returned data, but expected a list');
        
        List<Object> data = (List<Object>)outputMap.get('data');
        System.assert(data.size() == 4, 'CSVUtils did not return the expected number of rows');

        Map<String, Object> row = (Map<String, Object>)data.get(0);
        System.assert(row.size() == 4, 'CSVUtils did not return the expected number of items in a row');
    }

    /*
     * Test call to invokeMethod without a valid method name
     * 
     */
    @isTest
    static void test3() {

        Map<String, Object> inputMap  = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options   = new Map<String, Object>();

        // Execute the Test
        CSVUtils myclass = new CSVUtils();
        Boolean result = myclass.invokeMethod('somemethod', inputMap, outputMap, options);       
        
        // Validation
        System.assert(!result, 'CSVUtils.invokeMethod() returned true when it should have returned false');
    }

    /*
     * Test error handling of a Bad CSV file where the number of headers do not align with the number of data points in each row
     *
     */
    @isTest
    static void test4() {

        Map<String, Object> inputMap  = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options   = new Map<String, Object>();
        options.put('header', true);
        options.put('delimiter', ',');

        Map<String, String> files = new Map<String, String>();
        files.put('file1', BADFILE1);
        options.put('vlcFilesMap', files);

        // Execute the Test
        CSVUtils myclass = new CSVUtils();

        try {
            Boolean result = myclass.invokeMethod('load', inputMap, outputMap, options);       
        }
        catch (CSVUtils.ParsingException e) {
            // We expect an exception to be thrown
            return;           
        }

        // If we make it here, an exception was not thrown during processing of the bad file
        System.assert(false, 'CSVUtils did not throw an exception while processing a bad CSV file');        
    }

    /*
     * Test a Bad CSV file where the encoding is incorrect
     *
     */
    @isTest
    static void test5() {

        Map<String, Object> inputMap  = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options   = new Map<String, Object>();
        options.put('header', true);
        options.put('delimiter', ',');

        Map<String, String> files = new Map<String, String>();
        files.put('file1', BADFILE2);
        options.put('vlcFilesMap', files);

        // Execute the Test
        CSVUtils myclass = new CSVUtils();

        try {
            Boolean result = myclass.invokeMethod('load', inputMap, outputMap, options);       
        }
        catch (CSVUtils.ParsingException e) {
            // We expect an exception to be thrown
            return;         
        }

        // If we make it here, an exception was not thrown during processing of the bad file
        System.assert(false, 'CSVUtils did not throw an exception while processing a bad CSV file');        
    }

    /*
     * Test a CSV file uploaded as Salesforce Content
     *
     */
    @isTest
    static void test6() {

        // Create the Test ContentVersion
        ContentVersion content = new ContentVersion();
        content.Title = 'Test';
        content.PathOnClient = 'contacts.csv';
        content.VersionData = Blob.valueOf('Name,Email Address,Phone Number,Age\nJack Black,jblack@vlocity.com,712-678-3830,40\nNancy Pringle,npringle@vlocity.com,693-238-1238,33\nZak Mika,zmika@vlocity.com,701-213-3810,55\nJess McDonald,jmcdonald@vlocity.com,790-123-1238,24\n');
        content.IsMajorVersion = true;
        insert(content);

        // Get the corresponding ContentDocument
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.assertEquals(documents.size(), 1);

        Map<String, Object> inputMap  = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options   = new Map<String, Object>();
        options.put('header', true);
        options.put('delimiter', ',');

        Map<String, String> files = new Map<String, String>();
        files.put('file1', documents.get(0).Id);
        options.put('vlcFilesMap', files);

        // Execute the Test
        CSVUtils myclass = new CSVUtils();
        Boolean result = myclass.invokeMethod('load', inputMap, outputMap, options);       
        
        // Validation
        System.assert(result, 'CSVUtils.invokeMethod() returned false when it should have returned true');
        System.assert(outputMap.containsKey('data'), 'CSVUtils failed to return data');

        Object obj = outputMap.get('data');
        System.assert(obj instanceof List<Object>, 'CSVUtils returned data, but expected a list');
        
        List<Object> data = (List<Object>)outputMap.get('data');
        System.assert(data.size() == 4, 'CSVUtils did not return the expected number of rows');

        Map<String, Object> row = (Map<String, Object>)data.get(0);
        System.assert(row.size() == 4, 'CSVUtils did not return the expected number of items in a row');
    }

  
    /*
     * Test error handling when Content cannot be found in Salesforce
     *
     */
    @isTest
    static void test8() {

        Map<String, Object> inputMap  = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options   = new Map<String, Object>();

        Map<String, String> files = new Map<String, String>();
        files.put('file1', '0691j0000004arwAAA');  // fake value
        options.put('vlcFilesMap', files);

        // Execute the Test
        CSVUtils myclass = new CSVUtils();
        try {
            Boolean result = myclass.invokeMethod('load', inputMap, outputMap, options);       
        }
        catch (CSVUtils.ParsingException e) {
            // We expect an exception to be thrown            
            return;
        }

        // If we make it here, an exception was not thrown during processing of the bad file
        System.assert(false, 'CSVUtils did not throw an exception when the Content Document was invalid/missing');
    }

    /*
     * Simple Test of a simple CSV file (non-base64 encoded)
     *
     */
    @isTest
    static void test9() {

        Map<String, Object> inputMap  = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options   = new Map<String, Object>();
        options.put('header', true);
        options.put('delimiter', ',');

        Map<String, String> files = new Map<String, String>();
        files.put('file1', FILE3);
        options.put('vlcFilesMap', files);

        // Execute the Test
        CSVUtils myclass = new CSVUtils();
        Boolean result = myclass.invokeMethod('load', inputMap, outputMap, options);       
        
        // Validation
        System.assert(result, 'CSVUtils.invokeMethod() returned false when it should have returned true');
        System.assert(outputMap.containsKey('data'), 'CSVUtils failed to return data');

        Object obj = outputMap.get('data');
        System.assert(obj instanceof List<Object>, 'CSVUtils returned data, but expected a list');
        
        List<Object> data = (List<Object>)outputMap.get('data');
        System.assert(data.size() == 4, 'CSVUtils did not return the expected number of rows');
    }    
}