@isTest
private class ARTL_verifyInputPatternTest {
    
    static testmethod void testVerifyRegexPattern1() {
        
        Map<String,Object> input = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>();
        
        input.put('namePattern', 'TestName');
        input.put('streetPattern', 'TestStreet');
        
        ARTL_verifyInputPattern obj = new ARTL_verifyInputPattern();
        obj.invokeMethod('verifyRegexPattern', input, outMap, options);
    }
    
	static testmethod void testVerifyRegexPattern2() {
        
        Map<String,Object> input = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>();
        
        input.put('namePattern', '');
        input.put('streetPattern', '');
        
        ARTL_verifyInputPattern obj = new ARTL_verifyInputPattern();
        Test.startTest();
        obj.invokeMethod('verifyRegexPattern', input, outMap, options);
        Test.stopTest();
        System.assertEquals(true, outMap.get('isNamePatternMatched'));
        System.assertEquals(true, outMap.get('isStreetPatternMatched'));
    }    

    @isTest
    static void testRegexPatternValidation(){

        Map<String,Object> input = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>();
        
        input.put('regexPattern', 'test');
        input.put('inputString', 'test');

        ARTL_verifyInputPattern obj = new ARTL_verifyInputPattern();
        Test.startTest();
        obj.invokeMethod('regexPatternValidation', input, outMap, options);
        Test.stopTest();
        System.assertEquals(true, outMap.get('isMatched'));
    }

     @isTest
    static void testVerifyLeadTitleRegexPattern(){

        Map<String,Object> input = new  Map<String,Object>();
        Map<String,Object> outMap = new  Map<String,Object>();
        Map<String,Object> options = new  Map<String,Object>();
        
        input.put('title', 'test');

        ARTL_verifyInputPattern obj = new ARTL_verifyInputPattern();
        Test.startTest();
        obj.invokeMethod('verifyLeadTitleRegexPattern', input, outMap, options);
        Test.stopTest();
        System.assertEquals(true, outMap.get('isTitlePatternMatched'));
    }

    @isTest
    static void testRegexPatternValidationLwc(){
        String pattern = '[a-zA-Z0-9 ./\']*';
        Test.startTest();
        Boolean matched = ARTL_verifyInputPattern.regexPatternValidationLwc('test', pattern);
        Test.stopTest();
        System.assertEquals(true, matched);
    }
}