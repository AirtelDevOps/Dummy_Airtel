global class ARTL_PD_OrderValidation implements vlocity_cmt.VlocityOpenInterface {
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
                system.debug('LSI is not present');
                outMap.put('StatusCode','Error');
                outMap.put('Error' , 'LSI is not present');
            }
            if(assetList.size()>0){
               List<OrderItem> OrderItemList =[select id,ARTL_OL_LSI_Formula__c, Order.Status,Order.Id from OrderItem Where ARTL_OL_LSI_Formula__c =:LSINum AND (Order.vlocity_cmt__OrderStatus__c ='In Progres' OR Order.vlocity_cmt__OrderStatus__c ='Ready for Submit')];
                if(OrderItemList.size()>0){
                    system.debug('Open Order is Present under this LSI ' +LSINum );
                    outMap.put('StatusCode','Error');
                    outMap.put('Error','Open Order exist under this LSI - ' +LSINum );
                }
            }
            //Checking the secondry link for LSI
            if(assetList.size()>0){
               List<OrderItem> OrderItemList =[select id,ARTL_OL_LSI_Formula__c, Order.Status,Order.Id from OrderItem Where ARTL_OL_LSI_Formula__c =:LSINum AND Order.Status !='Cancelled'];
                if(OrderItemList.size()>0){
                    system.debug('Open Order is Present under this LSI ' +LSINum );
                    outMap.put('StatusCode','Error');
                    outMap.put('Error','Open Order exist under this LSI - ' +LSINum );
                }
            }
            
    }
}