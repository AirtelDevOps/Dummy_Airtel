public without sharing class ARTL_ATBValidationClass {
    
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
     @AuraEnabled(cacheable=true)
	 public static String generateJwt(String accountNumber) {
        
		User usr = [select id, email from User where Id =:UserInfo.getUserId()];
        Long rightNow = (dateTime.now().getTime()/1000)+1;
         Integer validFor =  Integer.valueOf(System.Label.Valid_For); // Put this number in Custom label
        String header = '{"alg":"HS256","typ":"JWT"}';
         System.debug('UsersId==>>'+UserInfo.getUserId());
         
        AuthSession sessionRecords = new AuthSession();
         if(!Test.isRunningTest()){
             sessionRecords = [Select Id,CreatedDate, UsersId, isCurrent,UserType, SourceIp, SessionType, 
                          SessionSecurityLevel, NumSecondsValid,
                          LoginType, LoginHistoryId, LastModifiedDate From AuthSession  
                          where LoginType = 'Application' and
                          UsersId = :UserInfo.getUserId()
                          //and SessionType = 'UI' and isCurrent = true
                          order by LastModifiedDate DESC LIMIT 1];
             
             
         }
         /*if(Test.isRunningTest()){
          * the fields on the AuthSession are only readable
             sessionRecords = new AuthSession(SessionType='UI', UsersId='0050T000003FguiQAC', SourceIp = '');
         }*/
            
         System.debug('sessionRecords --> '+sessionRecords.SessionType);
        String payload = '{';
        payload += '"iss": "SFDC",';
         if(!Test.isRunningTest()){
             payload += '"sfdcauthToken":"' + generateMD5Hash(sessionRecords.UsersId + sessionRecords.SourceIp + sessionRecords.SessionType + sessionRecords.SessionSecurityLevel + sessionRecords.LoginType ) + '",';
         }
         if(Test.isRunningTest()){
             payload +=  '"sfdcauthToken":"' + generateMD5Hash('00572000005r70YAAQ'+'223.233.85.250'+'UI'+'STANDARD'+'Application') + '",';
         }
        //payload += '"sfdcauthToken":"' + generateMD5Hash(sessionRecords.UsersId + sessionRecords.SourceIp + sessionRecords.SessionType + sessionRecords.SessionSecurityLevel + sessionRecords.LoginType ) + '",';
        payload += '"appId": "SFDC",';
        payload += '"partyId": "' + accountNumber + '",';//Please update the logic
        payload += '"emailID": "'+usr.email+'",'; 
        payload += '"iat": ' + rightNow + ',';
        payload += '"exp": ' + (rightNow + validFor);
        payload += '}';
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
    public static String decodeJWT(String str){
        List<String> jwtString = str.split('\\.');
        String header = base64URLdecode(jwtString[0]).toString();
        String payload = base64URLdecode(jwtString[1]).toString();
        System.debug('Decoded Payload --> '+ payload);
        return ('Header:: ' + header + ' || Payload:: ' + payload);
    }
     public static Blob base64URLdecode(String str){
        String output = str.replace('_', '/');
        output = output.replace('-', '+');
        Blob op = encodingUtil.base64Decode(output);
        return op;
    }
}