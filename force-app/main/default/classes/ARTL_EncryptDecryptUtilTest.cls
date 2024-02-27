@isTest
public class ARTL_EncryptDecryptUtilTest {
    
    @isTest
    static void testEncryptAndDecrypt() {
        String originalString = 'TestString123';
        
        String encryptedString = ARTL_EncryptDecryptUtil.encryptString(originalString);
        
        
        String sampleBase64URLencodedValue = 'VGhpcyBpcyBhIHNhbXBsZSBCbG9iIHZhbHVlIGZvciB0ZXN0aW5nIHBvcnpoZWxsaW5n';
        Blob sampleBase64URLdecodedValue = ARTL_EncryptDecryptUtil.base64URLdecode(sampleBase64URLencodedValue);
        //ARTL_EncryptDecryptUtil.BlobToBytes(blob.valueof(sampleBase64URLencodedValue));
        ARTL_EncryptDecryptUtil MainClass = new ARTL_EncryptDecryptUtil();
        String jwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
        
        string decodeJWTString = MainClass.decodeJWT(jwt);
    }
    /*@isTest
    static void testB64ToBytes() {
        // Test input string
        String inputString = 'SGVsbG8gd29ybGQ='; // "Hello world" in Base64
        
        // Create an instance of the class containing the B64ToBytes method
        //ARTL_EncryptDecryptUtil base64Converter = new ARTL_EncryptDecryptUtil();
        
        // Call the B64ToBytes method
        List<Integer> result = ARTL_EncryptDecryptUtil.B64ToBytes(inputString);
        
        // Verify the result against expected values
        System.assertEquals(72, result[0]); // ASCII code for 'H'
        System.assertEquals(101, result[1]); // ASCII code for 'e'
        System.assertEquals(108, result[2]); // ASCII code for 'l'
        System.assertEquals(108, result[3]); // ASCII code for 'l'
        System.assertEquals(111, result[4]); // ASCII code for 'o'
        System.assertEquals(32, result[5]);  // ASCII code for ' '
        System.assertEquals(119, result[6]); // ASCII code for 'w'
        System.assertEquals(111, result[7]); // ASCII code for 'o'
        System.assertEquals(114, result[8]); // ASCII code for 'r'
        System.assertEquals(108, result[9]); // ASCII code for 'l'
        System.assertEquals(100, result[10]); // ASCII code for 'd'
    }*/
    
    @isTest
    static void testGenerateMD5Hash() {
        String inputString = 'TestInputString';
        
        String md5Hash = ARTL_EncryptDecryptUtil.generateMD5Hash(inputString);
    }
    
    @isTest
    static void testGenerateJWT() {
        String jwt = ARTL_EncryptDecryptUtil.generateJWT();
        
    }
    
    @isTest
    static void testdecryptString() {
        
        test.startTest();
        String inputString = 'Test';
        
        
        String tempEncryptStr = ARTL_EncryptDecryptUtil.encryptString(inputString);
        system.debug('tempEncryptStr==>'+tempEncryptStr);
        String base64Content = string.valueOf(tempEncryptStr);// ( String ) JSON.deserialize( tempEncryptStr, String.class );
        //ARTL_EncryptDecryptUtil.decryptString(base64Content);
        
        test.stopTest();
        
    }
    
    
    
}