@isTest
private class DataRaptorHelperCallTest {

    @isTest
    static void testCallMethod() {
        // Test input data
        Map<String, Object> input = new Map<String, Object>{
            'key1' => 'value1',
            'key2' => 'Hello'
        };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>{
            'option1' => 'abc',
            'option2' => true
        };

        // Call the method
        Test.startTest();
        DataRaptorHelper helper = new DataRaptorHelper();
        Object result = helper.call('concatStrings', createArgsMap(input, output, options));
        Test.stopTest();

        // Perform assertions on the result if needed
        // Add assertions based on the expected behavior of your 'invokeMethod' method
        // For example, if 'concatStrings' is invoked, check that the 'result' in 'output' is as expected
    }

    @isTest
    static void testCallMethodWithInvalidAction() {
        // Test input data with an invalid action
        Map<String, Object> input = new Map<String, Object>{
            'key1' => 'value1',
            'key2' => 1
        };
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>{
            'option1' => 'abc',
            'option2' => true
        };

        // Call the method with an invalid action
        Test.startTest();
        DataRaptorHelper helper = new DataRaptorHelper();
        Object result = helper.call('invalidAction', createArgsMap(input, output, options));
        Test.stopTest();

        // Perform assertions on the result if needed
        // Add assertions based on the expected behavior for an invalid action
    }
    
    @isTest
    static void testConcatStrings() {
        // Test input data
        Map<String, Object> input = new Map<String, Object>();
        List<Object> arguments = new List<Object>{ 'Hello', 'World' };
        input.put('arguments', arguments);

        // Test output data
        Map<String, Object> output = new Map<String, Object>();

        // Call the method
        Test.startTest();
        DataRaptorHelper helper = new DataRaptorHelper();
        Boolean result = helper.invokeMethod('concatStrings', input, output, new Map<String, Object>());
        Test.stopTest();

        // Verify the result
        System.assertEquals(true, result, 'Method invocation failed');
        System.assertNotEquals(null, output.get('result'), 'Result is null');
        List<String> resultStrings = (List<String>)output.get('result');
        System.assertEquals(1, resultStrings.size(), 'Unexpected result size');
        System.assertEquals('Hello', resultStrings[0], 'Concatenation is incorrect');
    }
    
    @isTest
    static void testGetStateCode(){
        Map<String, Object> input = new Map<String, Object>();
        List<Object> arguments = new List<Object>{ 'Haryana'};
        input.put('arguments', arguments);
        
        // Test output data
        Map<String, Object> output = new Map<String, Object>();
        
        // Call the method
        Test.startTest();
        DataRaptorHelper helper = new DataRaptorHelper();
        Boolean result = helper.invokeMethod('gstGetStateCode', input, output, new Map<String, Object>());
        Test.stopTest();

    }

    // Helper method to create the args map
    private static Map<String, Object> createArgsMap(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        Map<String, Object> args = new Map<String, Object>();
        args.put('input', input);
        args.put('output', output);
        args.put('options', options);
        return args;
    }
}