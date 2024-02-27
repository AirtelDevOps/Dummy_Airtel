@isTest
private class ARTL_CalloutEventHandlerTest {
    
    static testmethod void testRunIntegrationProcedure(){
        
        Map<String,Object> input = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        input.put('processName', 'PAN_Validation');
        
        ARTL_CalloutEventHandler obj = new ARTL_CalloutEventHandler();
        obj.invokeMethod('initiateCallout', input, outMap, options); 
        ARTL_CalloutEventHandler.IntegrationProcedureQueueable objQueable = new ARTL_CalloutEventHandler.IntegrationProcedureQueueable(input, outMap, options);
        //ARTL_CalloutEventHandler.CalloutConfigWrapper objQueable1 = new ARTL_CalloutEventHandler.CalloutConfigWrapper();
        //objQueable1.Authorization = 'TestAuth';
    }
    @isTest
    public static void testQueueable(){
        Map<String,Object> input = new Map<String,Object>();
        Map<String,Object> outMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        ARTL_CalloutEventHandler.IntegrationProcedureQueueable objQueable = new ARTL_CalloutEventHandler.IntegrationProcedureQueueable(input, outMap, options);
        System.enqueueJob(objQueable);
    }
}