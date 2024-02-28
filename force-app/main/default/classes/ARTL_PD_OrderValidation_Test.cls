@isTest
private class ARTL_PD_OrderValidation_Test {
    
    @isTest
    static void testInvokeMethod_ValidInput() {
        // Create test data if needed
        
        // Create an instance of ARTL_PD_OrderValidation
        ARTL_PD_OrderValidation orderValidation = new ARTL_PD_OrderValidation();
        
        // Test invoking ValidateCheck method with valid input
        Map<String, Object> input = new Map<String, Object>{
            'LSI' => 'TestLSI123'
            // Add other required input fields if any
        };
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        Boolean result = orderValidation.invokeMethod('ValidateCheck', input, outMap, options);
        
        // Verify the result
        System.assertEquals(true, result, 'Expected result to be true');
        
        // Add more assertions based on the expected behavior of the method
    } 
}