global with sharing class ARTL_BulkCartUpdateField implements vlocity_cmt.VlocityOpenInterface2{
	global Object invokeMethod(String methodName, Map<String,Object> inputs, Map<String,Object> output, Map<String,Object> options) {
        try {
            Boolean success = false;
        if(methodName=='SendTaskUpdate'){
             SendTaskUpdateResponse(inputs,output,options);
        }
        
        return success;
        }
        catch(Exception ex){
            System.debug('Exception invokeMethod ------------- '+ex.getMessage()+'L No- '+ex.getLineNumber());
            return ex;
        }   
        
    }
     public static void SendTaskUpdateResponse(Map<String,Object> inputs, Map<String,Object> output, Map<String,Object> options){
        Id recordId = (Id)inputs.get('Record_ID__c');
    // Access the error message directly from the specified path
    String error = (String) ((Map<String, Object>) ((Map<String, Object>) inputs.get('DataRaptorPostAction1')).get('errorsAsJson')).get('DRError');
    
        ARTL_BulkCartUpdate__c objRec = new ARTL_BulkCartUpdate__c();
         objRec.Id = recordId;
        objRec.Errors__c = error;
        update objRec;
    }
}