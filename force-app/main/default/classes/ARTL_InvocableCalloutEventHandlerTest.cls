@isTest
private class ARTL_InvocableCalloutEventHandlerTest {
    
    static testMethod void testMethod1(){        
        ARTL_InvocableCalloutEventHandler.FlowInput obj = new ARTL_InvocableCalloutEventHandler.FlowInput();
        ARTL_InvocableCalloutEventHandler.initiateCalloutTrigger(new List<ARTL_InvocableCalloutEventHandler.FlowInput>{obj});
    }
    
    static testMethod void testMethod2(){ 
        Test.startTest();
        try {
            ARTL_InvocableCalloutEventHandler.initiateCalloutTrigger(null);
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage());
            System.assertEquals('Your expected exception message', e.getMessage());
        Test.stopTest();
    }
  }
}