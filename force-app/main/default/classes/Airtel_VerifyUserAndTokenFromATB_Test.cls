@isTest(SeeAlldata=false)
public class Airtel_VerifyUserAndTokenFromATB_Test {
    
    @isTest
    static void testVerifyCreds() {
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        
        System.debug('DEBUGG email '+UserInfo.getUserEmail() );
        System.debug('DEBUGG Id '+UserInfo.getUserId() );
        inputMap.put('email',  UserInfo.getUserEmail());
        String encodedString = ARTL_ATBValidationClass.generateJwt('122445');
        inputMap.put('token', encodedString);
        Test.StartTest();
        Airtel_VerifyUserAndTokenFromATB instance = new Airtel_VerifyUserAndTokenFromATB();
        Boolean result = instance.invokeMethod('verifyCreds', inputMap, outMap, new Map<String, Object>());
        String decodedString = ARTL_ATBValidationClass.decodeJWT(encodedString);
        Test.StopTest();
        System.assertEquals(true, result, 'Verification should be successful');
    }
}