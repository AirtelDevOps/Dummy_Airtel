global class ARTL_SeibelValidate implements vlocity_cmt.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName, Map<String,Object> input, Map<String,Object> outMap, Map<String,Object> options){
        try{
            if(methodName.equals('ValidateCheck')){
                ValidateCheck(input,outMap,options);
                return true;
            }
        }catch(Exception ex){            
        }
        return false;
    }
        public static void ValidateCheck(Map <String, Object> input, Map <String, Object> outMap, Map <String, Object> options){
       // Id orderId = (Id) input.get('OrderId');
        String LSINum = (String)input.get('LSI');
            system.debug('LSINum is : ' + LSINum);
            List<Asset> assetList = [Select ARTL_LSI_FText__c  FROM Asset WHERE ARTL_LSI_FText__c =:LSINum]; 
            system.debug('assetLIst : ' +assetList);
            if(assetList.size()==0){
                system.debug('assetList.size 19 ' + assetList.size());
                system.debug('LSI is not present');
                outMap.put('StatusCode','Error');
                outMap.put('Error' , 'LSI is not present');
            }
       }
}