global class ARTL_PD_OrderValidation implements vlocity_cmt.VlocityOpenInterface {
    public static String INTERNET = '3c6df3ca-4424-4131-bde3-c3ea5d5b5925';
    public static String PRIMARY_LINK = 'f14f570c-32cf-42b3-9e5c-c29a8e6132c2';
    public static String SECONDARY_INTERNET_LINK = '4488fd77-6d78-4719-b93e-101e19d6e44e';
    public static String MPLS = '6c24fdd7-4f71-4806-b7eb-62837fe6571e';
    public static String PRIMARY_MPLS_LINK = 'c28fb5dd-d072-4c1c-b7da-80046db82cf0';
    public static String SECONDARY_MPLS_LINK = '0c8bc86e-c30b-41dd-9077-13c1d2c54ed2';
    public static String SDWAN_CONTROLLER = 'beb3d29d-c914-43d1-8082-81ccfd7b6223';
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
            List<Asset> assetList = [Select ARTL_LSI_FText__c,Product2.ProductCode,vlocity_cmt__RootItemId__c  FROM Asset WHERE ARTL_LSI_FText__c =:LSINum]; 
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
                if(assetList[0].Product2.ProductCode == PRIMARY_LINK || assetList[0].Product2.ProductCode == PRIMARY_MPLS_LINK){
                    List<Asset> parentAsset = [select id,Name from asset where vlocity_cmt__RootItemId__c  =: assetList[0].vlocity_cmt__RootItemId__c
                                               and (Product2.ProductCode =: INTERNET OR Product2.ProductCode =: MPLS) ];
                    List<AssetRelationship> assetRelRec = [select id,Asset.Product2.ProductCode,RelatedAsset.Product2.ProductCode from 
                                                           AssetRelationship where (Asset.Product2.ProductCode =: SECONDARY_MPLS_LINK OR  Asset.Product2.ProductCode =: SECONDARY_INTERNET_LINK)
                                                           AND (RelatedAsset.Product2.ProductCode =: INTERNET OR RelatedAsset.Product2.ProductCode =: MPLS)
                                                           AND RelatedAssetId =:parentAsset[0].Id];
                    if(assetRelRec.size()>0){
                    system.debug('Dependent LSIs exists on LSI ' +LSINum );
                    outMap.put('StatusCode','Error');
                    outMap.put('Error','Dependent LSIs exists on LSI - ' +LSINum );
                }
                }
                if(assetList[0].Product2.ProductCode == SDWAN_CONTROLLER){
                    system.debug('SDWAN can not be disconnected ' +LSINum );
                    outMap.put('StatusCode','Error');
                    outMap.put('Error','SDWAN can not be disconnected - ' +LSINum );
                }
            }
            //Checking the secondry link for LSI
          /*  if(assetList.size()>0){
               List<OrderItem> OrderItemList =[select id,ARTL_OL_LSI_Formula__c, Order.Status,Order.Id from OrderItem Where ARTL_OL_LSI_Formula__c =:LSINum AND Order.Status !='Cancelled'];
                if(OrderItemList.size()>0){
                    system.debug('Open Order is Present under this LSI ' +LSINum );
                    outMap.put('StatusCode','Error');
                    outMap.put('Error','Open Order exist under this LSI - ' +LSINum );
                }
            }*/
            
    }
}