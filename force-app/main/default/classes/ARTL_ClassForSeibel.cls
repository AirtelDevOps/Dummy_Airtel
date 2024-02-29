global class ARTL_ClassForSeibel implements vlocity_cmt.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> outMap, Map<String,Object> options){
        try{
            if(methodName.equals('batchCallForOrderCreation')){
                batchCallForOrderCreation(input,outMap,options);
                return true;
            }
        }catch(Exception ex){            
        }
        return false;
    }
        public static void batchCallForOrderCreation(Map <String, Object> input, Map <String, Object> outMap, Map <String, Object> options){
        String caseNum = (String) input.get('CaseNum');
            system.debug('caseNum is : ' + caseNum);
        ARTL_SeibelCreationBatch batchJob = new ARTL_SeibelCreationBatch(caseNum);
          Database.executeBatch(batchJob);
            system.debug('batchJob is : ' + batchJob); 
            String jsonPayload = JSON.serialize(batchJob);
            system.debug('jsonPayload : '+jsonPayload);
            outMap.put('result ', jsonPayload) ;  
    }

 
}