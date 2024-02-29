@isTest
private class ARTL_SeibelValidateTest {

    @isTest
    static void testInvokeMethod() {
        // Test data setup
        Map<String, Object> input = new Map<String, Object>();
        input.put('LSI', 'TestLSI123');

        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        // Invoke the method
        Boolean result = new ARTL_SeibelValidate().invokeMethod('ValidateCheck', input, outMap, options);

        // Assert the result
        System.assertEquals(true, result, 'Method invocation should return true');
        System.assertEquals('Error', outMap.get('StatusCode'), 'StatusCode should be "Error"');
        System.assertEquals('LSI is not present', outMap.get('Error'), 'Error message should be "LSI is not present"');
    }

    @isTest
    static void testValidateCheck() {
        // Test data setup
        Map<String, Object> input = new Map<String, Object>();
        input.put('LSI', 'TestLSI123');

        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        // Invoke the method
        ARTL_SeibelValidate.ValidateCheck(input, outMap, options);

        // Assert the result
        System.assertEquals('Error', outMap.get('StatusCode'), 'StatusCode should be "Error"');
        System.assertEquals('LSI is not present', outMap.get('Error'), 'Error message should be "LSI is not present"');
    }
}