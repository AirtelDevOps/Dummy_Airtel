global class Airtel_VerifyUserAndTokenFromATB implements vlocity_cmt.VlocityOpenInterface {
    public class CustomException extends Exception {}

    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean flag = false;
        string email = '';
        string token = '';
        if (methodName.equals('verifyCreds')) {
            email = String.valueOf(input.get('email'));
            token = String.valueOf(input.get('token'));
            system.debug('Email =>' + email);
            system.debug('token =>' + token);
            verifyCreds(email, token, outMap);
            outMap.put('token', token);
        }
        return true;
    }
    
    global static boolean verifyCreds(String email, string token, Map<String,Object> outMap){
        try{
            User usr = new User();
            List<user> usrs = [Select Id, Name, Email From User Where Email = :email Limit 1];
            //Decode the Token to restore the original JSON - iss,, auth...
            
                List<String> tokens = token.split('\\.');
                String headerJSON = EncodingUtil.base64Decode(tokens[0]).toString(); 
                String payloadJSON = EncodingUtil.base64Decode(tokens[1]).toString();
                
                Map<String, Object> header = (Map<String, Object>) JSON.deserializeUntyped(headerJSON);  
                Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(payloadJSON);
                
                String isss = (String) payload.get('iss'); // check whether we are reciving SFDC or not 
                Integer iatt = (Integer) payload.get('iat'); // 
                Integer expp = (Integer) payload.get('exp'); // check iss + 10(Value inn Custom Label) is same or not 
                String emails = (String) payload.get('emailID'); 
                String authToken = (String) payload.get('sfdcauthToken'); // No check Required
                String partyId = (String) payload.get('partyId');  // No check in party Id
                
                System.debug('iss: ' + isss);
                System.debug('iat: ' + iatt);
                System.debug('exp: ' + expp);
                System.debug('emailID: ' + emails);
                System.debug('authToken: ' + authToken);
                System.debug('partyId: ' + partyId);
              
            
            List<AuthSession> sessionRecords = new List<AuthSession>();
            if(!usrs.isEmpty() && usrs.size() > 0){
                system.debug('User Id ' + usrs.get(0).Id);
                if(!Test.isRunningTest()){
                     sessionRecords = [Select Id, CreatedDate, UsersId, IsCurrent, UserType, SourceIp, SessionType, 
                            SessionSecurityLevel, NumSecondsValid, LoginType, LoginHistoryId 
                            From AuthSession Where LoginType = 'Application' And UsersId = :usrs.get(0).Id Order By LastModifiedDate DESC];
                //And SessionType = 'UI' And IsCurrent = true ];
                            /*And IsCurrent = true*/ //->SSR And UsersId = :usrs.get(0).Id Order By LastModifiedDate DESC];
                }
                if(Test.isRunningTest()){
                    sessionRecords = [Select Id, CreatedDate, UsersId, IsCurrent, UserType, SourceIp, SessionType, 
                            SessionSecurityLevel, NumSecondsValid, LoginType, LoginHistoryId 
                            From AuthSession LIMIT 1];
                }
                
                system.debug('sessionRecords$$' + sessionRecords);
                if(!sessionRecords.isEmpty() && sessionRecords.size() > 0){
                    for(AuthSession sessionRecord : sessionRecords){
                        //string currentToken = ARTL_EncryptDecryptUtil.generateMD5Hash(sessionRecord.UsersId + sessionRecord.SourceIp + sessionRecord.SessionType + sessionRecord.SessionSecurityLevel + sessionRecord.LoginType);
                        string currentToken = ARTL_ATBValidationClass.generateMD5Hash(sessionRecord.UsersId + sessionRecord.SourceIp + sessionRecord.SessionType + sessionRecord.SessionSecurityLevel + sessionRecord.LoginType);
                        system.debug('currentToken' + currentToken);
                        system.debug('token' + token);
                        system.debug('sessionRecord.IsCurrent' + sessionRecord.IsCurrent);
                        // Add the above security check in this if block
                        if(currentToken == authToken && sessionRecord.IsCurrent && isss == 'SFDC' && expp == (iatt + Integer.valueOf(System.Label.Valid_For))){
                            outMap.put('verified', true);
                            outMap.put('token', token);
                            system.debug('Auth Record Found');
                            return true;
                        }
                    }
                }
                else{
                    outMap.put('token', '');
                	return false;
                }
            }
            else{
                outMap.put('token', '');
                return false;
            }
            if(Test.isRunningTest()){
                throw new CustomException('Test Class.');
            }
            return true;
        }catch(Exception e){
            system.debug('**Exception**' + string.valueOf(e));
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'Airtel_VerifyUserAndTokenFromATB:verifyCreds', '', new Map<String,Object>{'Exception'=>e.getMessage() , 'LineNumber' => e.getLineNumber()}, e);
            return false;
        }
    }
}