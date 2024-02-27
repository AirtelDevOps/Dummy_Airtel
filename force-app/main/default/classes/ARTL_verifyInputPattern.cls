global without sharing class ARTL_verifyInputPattern implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> outMap, Map<String,Object> options){
        Boolean isSuccess = false; 
        try{
            if(methodName.equals('verifyRegexPattern')){
                verifyRegexPattern(input, outMap, options);
                isSuccess = true;
            }else if(methodName.equals('verifyLeadTitleRegexPattern')){
                verifyLeadTitleRegexPattern(input, outMap, options);
                isSuccess = true;
            }
            else if(methodName.equals('regexPatternValidation')){
                regexPatternValidation(input, outMap, options);
                isSuccess = true;
            }
        }catch(Exception ex){
            isSuccess = false;
        }
        return isSuccess;
    }
    
    public static void verifyRegexPattern(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options){
        
        string namePattern = (String)input.get('namePattern');
        string streetPattern = (String)input.get('streetPattern');
        boolean finalResult1 = false; 
        boolean finalResult2 = false;
        
        try{
            // Define the regex pattern
            String samplePattern =  '[a-zA-Z0-9 &./\',_()-]*';
            //String sampleNamePattern = '[a-zA-Z0-9 &./\',_()-]*';
            //String sampleStreetPattern = '[a-zA-Z0-9 &./\',_()-]*';
            // Compile the pattern
            Pattern regex = Pattern.compile(samplePattern);
            //Pattern nameRegex = Pattern.compile(samplePattern);
            //Pattern streetRegex = Pattern.compile(samplePattern);
            
            if(String.isNotBlank(namePattern)){
                // Create a matcher with the input string
                Matcher matcher = regex.matcher(namePattern);
                // Check if the input matches the pattern
                finalResult1 = matcher.matches();
            }
            else{
                finalResult1 = true;
            }
            
            if(String.isNotBlank(streetPattern)){
                // Create a matcher with the input string
                Matcher matcher = regex.matcher(streetPattern);
                // Check if the input matches the pattern
                finalResult2 = matcher.matches();
            }
            else{
                finalResult2 = true;
            }
            
            outmap.put('isNamePatternMatched',finalResult1);
            outmap.put('isStreetPatternMatched',finalResult2);
            
        }catch(Exception ex){
            system.debug('Exception Message==>'+ex.getMessage());
        }
        
    }
    
    public static void verifyLeadTitleRegexPattern(Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options){
        
        string leadTitle = (String)input.get('title');
        boolean finalResult1 = true;  
        
        try{
            // Define the regex pattern
            String sampleTitlePattern = '[a-zA-Z0-9 \\-.&/\']*';
            // Compile the pattern
            Pattern regex = Pattern.compile(sampleTitlePattern);
            
            if(String.isNotBlank(leadTitle)){
                // Create a matcher with the input string
                Matcher matcher = regex.matcher(leadTitle);
                // Check if the input matches the pattern
                finalResult1 = matcher.matches();
            }
            
            outmap.put('isTitlePatternMatched',finalResult1);
            
        }catch(Exception ex){
            system.debug('Exception Message==>'+ex.getMessage());
        }
        
    }

    public static void regexPatternValidation(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options){
        try{
            String regexPattern = (String)input.get('regexPattern');
            String inputString = (String)input.get('inputString');
            Boolean finalResult = false;
            Pattern regex;
            if(String.isNotBlank(regexPattern)){
                regex = Pattern.compile(regexPattern);
            }
            if(String.isNotBlank(inputString)){
                Matcher matcher = regex.matcher(inputString);
                finalResult = matcher.matches();
            }
            outmap.put('isMatched',finalResult);

        }
        catch(Exception ex){
            system.debug('Exception Message==>'+ex.getMessage());
        }
        
    }

    @AuraEnabled
    public static Boolean regexPatternValidationLwc(String inputString, String regexPattern){
        try {
            Boolean finalResult = false;
            Pattern regex;
            if(String.isNotBlank(regexPattern)){
                regex = Pattern.compile(regexPattern);
            }
            if(String.isNotBlank(inputString)){
                Matcher matcher = regex.matcher(inputString);
                finalResult = matcher.matches();
            }
            return finalResult;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}