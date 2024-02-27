global class DataRaptorHelper implements Callable {
    public Object call(String action, Map<String,Object>args){
        
        Map<String,Object>input=(Map<String,Object>)args.get('input');
        Map<String,Object>output=(Map<String,Object>)args.get('output');
        Map<String,Object>options=(Map<String,Object>)args.get('options');
        return invokeMethod(action,input,output,options);
    }
    
    Global boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        try {
            if (methodName.equalsIgnoreCase('concatStrings')) {
                List<Object> rawArguments = (List<Object>) input.get('arguments');
                // Check and convert each element to String
                List<String> stringArguments = new List<String>();
                for (Object rawArgument : rawArguments) {
                    stringArguments.add(String.valueOf(rawArgument));
                }
                List<String> splitString = divideStringIntoParts(stringArguments[0]); // Concatenate strings without any separator
                System.debug('splitString 20 DRH-->>'+splitString);
                output.put('result', splitString);
            } else if(methodName.equalsIgnoreCase('randomGenerator')){
                Long rightNow = (dateTime.now().getTime()/1000)+Integer.valueof(Math.random());
                output.put('result', rightNow);
            }
            else if(methodName.equalsIgnoreCase('gstGetStateCode')){
                List<Object> arguments = (List<Object>)input.get('arguments');
                String stateName = (String)arguments[0];
                System.debug('DEBUGG arguments '+ arguments);
                String stateCode = gstGetStateCode(stateName);
                System.debug('stateCode '+ stateName);
                System.debug('stateCode '+ stateCode);
                output.put('result', stateCode);

            }
        } catch (Exception e) {
            system.debug('DRH catch 1');
            // Handle exceptions appropriately, log or return an error
            return false;
        }
        return true;
    }
    
    public List<String> divideStringIntoParts(String inputString) {
        List<String> parts = new List<String>();
        Integer partSize = 74;
        
        // Check if the input string is not empty
        if (String.isNotBlank(inputString)) {
            // Check if the length of the input string is less than the specified part size
            if (inputString.length() <= partSize) {
                parts.add(inputString);
            } else {
                // Loop through the input string in parts
                for (Integer i = 0; i < inputString.length(); i += partSize) {
                    // Get a part of the specified size
                    String part = inputString.substring(i, Math.min(i + partSize, inputString.length()));
                    parts.add(part);
                }
            }
        } else {
            // If input string is empty, add an empty string to the parts
            parts.add('');
        }
        system.debug(parts);
        return parts;
    }
    
    /**
    * @description : Get State code from State. Used in Dataraptor - ARTL_DRL_UpdateGSTDetails
    * @author Rishab Kalra | 20-12-2023 
    * @param stateName
    **/
    public static String gstGetStateCode(String stateName){
        System.debug('DEBUGG gstGetStateCode '+ stateName);
        Schema.DescribeFieldResult fieldResult = GST__c.ARTL_Address__StateCode__s.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        System.debug('Picklist::'+ple);
        for( Schema.PicklistEntry f : ple){
            if(f.getLabel() == stateName){
                return f.getValue();
            }
        }
        return null;
    }
        
}