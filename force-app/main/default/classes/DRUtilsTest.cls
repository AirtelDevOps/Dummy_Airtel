@isTest
private class DRUtilsTest {

    @isTest
    static void testInvokeMethod() {
        DRUtils drUtils = new DRUtils();

        Map<String, Object> inputMap = new Map<String, Object>{ 'dataRaptorName' => 'TestRaptor', 'parentProductCode' => '123' };
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>();

        Boolean result = (Boolean)drUtils.invokeMethod('invokeDataRaptorByName', inputMap, outputMap, optionsMap);

    }

    @isTest
    static void testCall() {
        DRUtils drUtils = new DRUtils();

        Map<String, Object> inputMap = new Map<String, Object>{ 'dataRaptorName' => 'TestRaptor', 'parentProductCode' => '123' };
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>();

        Object result = drUtils.call('invokeDataRaptorByName', new Map<String, Object>{ 'input' => inputMap, 'output' => outputMap, 'options' => optionsMap });

    }
}