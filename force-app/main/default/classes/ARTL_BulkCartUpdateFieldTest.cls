@isTest
private class ARTL_BulkCartUpdateFieldTest {
    @isTest
    static void testInvokeMethod() {
        ARTL_BulkCartUpdate__c objRec = new ARTL_BulkCartUpdate__c();
        objRec.Name = 'Test Record Name';
        insert objRec;
        // Test data
        Map<String, Object> inputData = new Map<String, Object>{
            'Record_ID__c' => objRec.Id, //test record ID
            'DataRaptorPostAction1' => new Map<String, Object>{
                'errorsAsJson' => new Map<String, Object>{
                    'DRError' => 'testing for error',
                    'Status' => '',
                    'TaskId' => ''
                }
            }
        };
        
        // Call the method to be tested
        ARTL_BulkCartUpdateField obj = new ARTL_BulkCartUpdateField();
        Map<String, Object> outputData = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        obj.invokeMethod('SendTaskUpdate', inputData, outputData, options);
        obj.invokeMethod('SendTask', null, outputData, options);
        obj.invokeMethod('SendTaskUpdate', null, outputData, options);

       
    }
}