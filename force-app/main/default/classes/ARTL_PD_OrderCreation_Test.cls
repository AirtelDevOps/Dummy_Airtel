@isTest
private class ARTL_PD_OrderCreation_Test {
    @testSetup
    static void testSetupMethod(){
        Case caseRec = new Case (Status = 'In-Progress', 
                                 Origin = 'Web');
        insert caseRec;
    }
    
    @isTest
    static void testInvokeMethod() {
		Case caseobj = [Select id, CaseNumber from Case];
        ARTL_PD_OrderCreation orderCreation = new ARTL_PD_OrderCreation();

        Map<String, Object> input = new Map<String, Object>{
            'CaseNum' => caseobj.CaseNumber
        };
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        Boolean result = orderCreation.invokeMethod('batchCallForOrderCreation', input, outMap, options);

        System.assertEquals(true, result, 'Expected result to be true');
    }
}