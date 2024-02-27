public without sharing class ARTL_EncryptDecryptUtil {
    public static string encryptString(string str){
        System.debug('DEBUGG encryptString '+ str);
        Blob key = Blob.valueOf(System.Label.ARTL_EncryptionKey);
        string encodedCipherText = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(str)));
        string encryptedString = encodingUtil.URLEncode(encodedCipherText,'UTF-8');
        return encryptedString;
    }
    
    public static string decryptString(string encryptedStr){
        Blob key = Blob.valueOf(System.Label.ARTL_EncryptionKey);
        Blob blobData = EncodingUtil.base64Decode(encryptedStr);    
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES128', key, blobData);    
        string decryptedString = decryptedBlob.toString();
        return decryptedString;
    }
    public static string generateMD5Hash(string requestInput){
        String key = 'hgdhdhhdjfh12ehsn';
        String secret = 'DNf32sdsj747dhkjd8893jjjdjds7jjk';
        //Generating current Unix timestamp (in seconds)
        String getTime = string.valueOf(Datetime.Now().getTime()/1000);
        Blob requestBlob = Blob.valueOf(requestInput); 
        Blob hash = Crypto.generateDigest('MD5', requestBlob);     
        //Need to convert into hex to generate the equivalent of md5(string) method of PHP.
        String requestSignature = EncodingUtil.convertToHex(hash);
        return requestSignature;
    }
    /*
    public static String generateJWT_Old(){
        String header = '{"alg": "HS256","typ":"jwt"}';
        String payload = '{ "iss": "SFDC","sfdcauthToken": "8fea8259-82db-3c89-ac8e-2be02d3d201e","appId": "SFDC","emailID": "test@gmail.com","exp": 1699543278,"iat": 1699528878}';
        string jwt = base64URLencode(blob.valueof(header)) + '.' +base64URLencode(blob.valueof(payload));
        
        Blob key = blob.valueof('secret key provided');
        blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
        
        String jwtFinalString = jwt+'.'+base64URLencode(signature);
        return jwtFinalString;  
    }
	*/
    public static String generateJWT(){
        //Create Header
        String header = '{"alg": "HS256","typ":"jwt"}';
        //Prepare the element required forJWT payload creation
        User usr = [select id, email from User where Id =:UserInfo.getUserId()];
        Integer validFor = 10;
        Long rightNow = (dateTime.now().getTime()/1000)+1;
        //Create Session Token from AuthSession Table
        AuthSession sessionRecords = new AuthSession();
        if(!Test.isRunningTest()){
        sessionRecords = [Select Id,CreatedDate, UsersId, isCurrent,UserType, SourceIp, SessionType, 
                          SessionSecurityLevel, NumSecondsValid,
                          LoginType, LoginHistoryId, LastModifiedDate From AuthSession 
                          where LoginType = 'Application' and
                          UsersId = :UserInfo.getUserId() and 
                          SessionType = 'UI' and
                          isCurrent = true order by LastModifiedDate DESC LIMIT 1];
        }
        String payload = '{';
        payload += '"iss": "SFDC",';
        if(Test.isRunningTest()){
            payload += '"sfdcauthToken":"' + generateMD5Hash('00572000005r70YAAQ'+'223.233.85.250'+'UI'+'STANDARD'+'Application') + '",';
        }
        
        if(!Test.isRunningTest()){
            payload += '"sfdcauthToken":"' + generateMD5Hash(sessionRecords.UsersId + sessionRecords.SourceIp + sessionRecords.SessionType + sessionRecords.SessionSecurityLevel + sessionRecords.LoginType ) + '",';
        }
        //payload += '"sfdcauthToken":"' + generateMD5Hash(sessionRecords.UsersId + sessionRecords.SourceIp + sessionRecords.SessionType + sessionRecords.SessionSecurityLevel + sessionRecords.LoginType ) + '",';
        payload += '"appId": "SFDC",';
        payload += '"partyId ": "<current SFDC Account Id>",';//Please update the logic
        //payload += '"partyId": "2285375",';//Please update the logic
        payload += '"emailID": "' + usr.email + '",';
        //payload += '"emailID": "test@gmail.com",';
        payload += '"iat": ' + rightNow + ',';
        payload += '"exp": ' + (rightNow + validFor);
        payload += '}';
		system.debug('payload ' + payload);
        string jwt = base64URLencode(blob.valueof(header)) + '.' +base64URLencode(blob.valueof(payload));
        
        Blob key = blob.valueof('YWZjMWM0NTgtN2JiMi01ZWYzLThjNzMtZTBkMDEyNTA4ODQz');
        blob signature = Crypto.generateMac('hmacSHA256',Blob.valueof(jwt),key);
        
        String jwtFinalString = jwt+'.'+base64URLencode(signature);
        system.debug('jwtFinalString --> '+jwtFinalString);
        return jwtFinalString;  
    }
    
    public static String base64URLencode(Blob input){ 
        String output = encodingUtil.base64Encode(input);
         output = output.replace('+', '-');
        output = output.replace('/', '_');
        while (output.endsWith('=')){
            output = output.subString(0,output.length()-1);
        }
        return output;
    }
    
    public static Blob base64URLdecode(String str){
        String output = str.replace('_', '/');
        output = output.replace('-', '+');
        Blob op = encodingUtil.base64Decode(output);
        return op;
    }
    
    public String decodeJWT(String str){
        List<String> jwtString = str.split('\\.');
        String header = base64URLdecode(jwtString[0]).toString();
        String payload = base64URLdecode(jwtString[1]).toString();
        return ('Header:: ' + header + ' || Payload:: ' + payload);
    }
    // Converts a base64 string into a list of integers representing the encoded bytes
    /*public static List<Integer> B64ToBytes (String sIn) {
        Map<Integer,Integer> base64 = new Map<Integer,Integer>{65=>0,66=>1,67=>2,68=>3,69=>4,70=>5,71=>6,72=>7,73=>8,74=>9,75=>10,76=>11,77=>12,78=>13,79=>14,80=>15,81=>16,82=>17,83=>18,84=>19,85=>20,86=>21,87=>22,88=>23,89=>24,90=>25,97=>26,98=>27,99=>28,100=>29,101=>30,102=>31,103=>32,104=>33,105=>34,106=>35,107=>36,108=>37,109=>38,110=>39,111=>40,112=>41,113=>42,114=>43,115=>44,116=>45,117=>46,118=>47,119=>48,120=>49,121=>50,122=>51,48=>52,49=>53,50=>54,51=>55,52=>56,53=>57,54=>58,55=>59,56=>60,57=>61,43=>62,47=>63};

        List<Integer> lstOut = new List<Integer>();
        if ( sIn == null || sIn == '' ) return lstOut;
        
        sIn += '='.repeat( 4 - Math.mod( sIn.length(), 4) );

        for ( Integer idx=0; idx < sIn.length(); idx += 4 ) {
            if ( base64.get(sIn.charAt(idx+1)) != null ) lstOut.add( (base64.get(sIn.charAt(idx)) << 2) | (base64.get(sIn.charAt(idx+1)) >>> 4) );
            if ( base64.get(sIn.charAt(idx+2)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+1)) & 15)<<4) | (base64.get(sIn.charAt(idx+2)) >>> 2) );
            if ( base64.get(sIn.charAt(idx+3)) != null ) lstOut.add( ((base64.get(sIn.charAt(idx+2)) & 3)<<6) | base64.get(sIn.charAt(idx+3)) );
        }

        System.Debug('B64ToBytes: [' + sIn + '] = ' + lstOut);
        return lstOut;
    }//B64ToBytes

    public static List<Integer> BlobToBytes (Blob input) {
        return B64ToBytes( EncodingUtil.base64Encode(input) );
    }//BlobToBytes */
}