/**
 * Test class for ARTL_OmniActionUtil
 */
@isTest
public class ARTL_OmniActionUtilTest {
    @TestSetup
    static void makeData(){
        
    }

    @IsTest
    static void testlogInfo(){
        
        Test.startTest();   
        Map<String,Object> inPutMap = new Map<String,Object>();
        Map<String,Object> outPutMap = new Map<String,Object>();
        Map<String,Object> optionsMap = new Map<String,Object>();
        Map<String,Object> args = new Map<String,Object>();
        
        inPutMap.put('type','debug');
        inPutMap.put('name','test error debug');
        inPutMap.put('message','This is a test message');
        inPutMap.put('logData','Test');
        inPutMap.put('errorMessage','Test');

        ARTL_OmniActionUtil obj = new ARTL_OmniActionUtil();
		
        args.put('input',inPutMap);
        args.put('output',outPutMap);
        args.put('options',optionsMap);
        obj.call('logInfo',args);
        ARTL_Logger.info('debug', 'test error debug', 'This is a test message', new Map<String,Object>{'logData'=>'Test'});
        Test.stopTest();
        
    }

    @IsTest
    static void testlogError(){
        
        Test.startTest();   
        Map<String,Object> inPutMap = new Map<String,Object>();
        Map<String,Object> outPutMap = new Map<String,Object>();
        Map<String,Object> optionsMap = new Map<String,Object>();
        
        
        inPutMap.put('type','debug');
        inPutMap.put('name','Credit Life error debug');
        inPutMap.put('message','This is a test message');
        inPutMap.put('logData','Test');
        inPutMap.put('errorMessage','Test');

        ARTL_OmniActionUtil obj = new ARTL_OmniActionUtil();

        obj.invokeMethod('logError',inPutMap,outPutMap,optionsMap);
        Test.stopTest();
        
    }

    @IsTest
    static void testlogDebug(){
        
        Test.startTest();   
        Map<String,Object> inPutMap = new Map<String,Object>();
        Map<String,Object> outPutMap = new Map<String,Object>();
        Map<String,Object> optionsMap = new Map<String,Object>();
        
         
        inPutMap.put('type','debug');
        inPutMap.put('name','Credit Life error debug');
        inPutMap.put('message','This is a test message');
        inPutMap.put('logData','Test');
        inPutMap.put('errorMessage','Test');

        ARTL_OmniActionUtil obj = new ARTL_OmniActionUtil();
        obj.invokeMethod('logDebug',inPutMap,outPutMap,optionsMap);
		ARTL_Logger.debug('debug', 'test error debug', 'This is a test message', new Map<String,Object>{'logData'=>'Test'});
        Test.stopTest();
        
    }
}