/*****************************************************************************************************************
Name : ARTL_CreateAssetRelationship
==================================================================================================================
Purpose: 1.Creating Asset Relationship after assets are created
==================================================================================================================
History
---------------
Version      Author               Date         Detail      Features/CSR/TTP
1.0       Akshay(SFI)  		    14.01.2024    Created   
*********/

global class ARTL_CreateAssetRelationship implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
    
    public void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items){
        System.debug('OrderId'+items[0].vlocity_cmt__OrderItemId__c);
        //Getting Order ID and OrderItems AssetRefId
        if(items[0].vlocity_cmt__OrderItemId__c!=null){
            id orderid = items[0].vlocity_cmt__OrderItemId__r.OrderId;
            String OrderItemId = items[0].vlocity_cmt__OrderItemId__c;
            List<Orderitem> CheckAssetRefId = [select vlocity_cmt__RootItemId__c from orderitem where id =:OrderItemId];
            String OrderItemAssetRefId = CheckAssetRefId[0].vlocity_cmt__RootItemId__c;
            Set<String> assetrefId = new Set<String>();
            List<vlocity_cmt__OrderItemRelationship__c> orderitemrelationships = [select vlocity_cmt__OrderItemId__c, vlocity_cmt__RelatedOrderItemId__c,vlocity_cmt__OrderItemId__r.vlocity_cmt__AssetReferenceId__c, vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__AssetReferenceId__c, vlocity_cmt__RelationshipType__c, vlocity_cmt__Action__c, vlocity_cmt__ProductRelationshipIdentifier__c from vlocity_cmt__OrderItemRelationship__c  where vlocity_cmt__OrderId__c =:orderid];
            if(!orderitemrelationships.isEmpty()){
                for(vlocity_cmt__OrderItemRelationship__c orderitemrelationshiprec:orderitemrelationships){
                    assetrefId.add(orderitemrelationshiprec.vlocity_cmt__OrderItemId__r.vlocity_cmt__AssetReferenceId__c);
                    assetrefId.add(orderitemrelationshiprec.vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__AssetReferenceId__c);
                }
                List<String> assetrefIdlist = new List<String>(assetrefId);
                String AdminAssetId;
                Map<String,id> mapOfAssetRefIdWithAssetId = new Map<String,id>();
                for(Asset assetrec: [select id,name,vlocity_cmt__AssetReferenceId__c from asset where vlocity_cmt__AssetReferenceId__c in :assetrefIdlist]){
                    mapOfAssetRefIdWithAssetId.put(assetrec.vlocity_cmt__AssetReferenceId__c,assetrec.Id);
                }
                List<AssetRelationship> listassetrelationship = new List<AssetRelationship>();
                for(vlocity_cmt__OrderItemRelationship__c orderitemrelationshiprec:orderitemrelationships){
                    AssetRelationship AssetRelationshiprec = new AssetRelationship();
                    String AssetID = mapOfAssetRefIdWithAssetId.get(orderitemrelationshiprec.vlocity_cmt__OrderItemId__r.vlocity_cmt__AssetReferenceId__c);
                    if(mapOfAssetRefIdWithAssetId.get(orderitemrelationshiprec.vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__AssetReferenceId__c)!=null){
                        AssetRelationshiprec.AssetId = AssetID;
                        AssetRelationshiprec.RelatedAssetId = mapOfAssetRefIdWithAssetId.get(orderitemrelationshiprec.vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__AssetReferenceId__c);
                        AssetRelationshiprec.RelationshipType = orderitemrelationshiprec.vlocity_cmt__RelationshipType__c;
                        AssetRelationshiprec.vlocity_cmt__ProductRelationshipIdentifier__c = orderitemrelationshiprec.vlocity_cmt__ProductRelationshipIdentifier__c;
                        listassetrelationship.add(AssetRelationshiprec);
                    }
                    else{
                        Asset assetrec = new Asset();
                        assetrec.id = AssetID;
                        assetrec.vlocity_cmt__ReliesOnItemId__c = orderitemrelationshiprec.vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__AssetReferenceId__c;
                        update assetrec;
                        //AssetRelationshiprec.RelatedAssetId = AdminAssetId;
                        //AssetRelationshiprec.ARTL_Related_Asset_Reference_Id__c = ;
                    }
                    
                }
                if(listassetrelationship.size()>0){
                    insert listassetrelationship;
                }
            }
            map<string,String>  assetidwithAssetRefID= new map<string,String>();
            List<String> sourceProductAssetRefID=new List<String>();
            List<id> sourceassetids = new List<id>();
            for(Asset relatedAssetList:[select id,vlocity_cmt__AssetReferenceId__c,vlocity_cmt__ReliesOnItemId__c from asset where vlocity_cmt__ReliesOnItemId__c  =:OrderItemAssetRefId OR vlocity_cmt__AssetReferenceId__c =:OrderItemAssetRefId])
                {
                    if( relatedAssetList.vlocity_cmt__ReliesOnItemId__c!=null && relatedAssetList.vlocity_cmt__ReliesOnItemId__c.equals(OrderItemAssetRefId)){
                        sourceassetids.add(relatedAssetList.id);
                        sourceProductAssetRefID.add(relatedAssetList.vlocity_cmt__AssetReferenceId__c);
                    }
                    System.debug('relatedAssetList'+relatedAssetList);
                assetidwithAssetRefID.put(relatedAssetList.vlocity_cmt__AssetReferenceId__c,relatedAssetList.id);
                    
                
            }
            List<vlocity_cmt__OrderItemRelationship__c> relatedorderitemrelationships = [select id,vlocity_cmt__OrderItemId__c, vlocity_cmt__RelatedOrderItemId__c,vlocity_cmt__RelationshipType__c, vlocity_cmt__Action__c,vlocity_cmt__OrderItemId__r.vlocity_cmt__AssetReferenceId__c, vlocity_cmt__ProductRelationshipIdentifier__c, vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__AssetReferenceId__c from vlocity_cmt__OrderItemRelationship__c where vlocity_cmt__OrderItemId__r.vlocity_cmt__AssetReferenceId__c in :sourceProductAssetRefID And vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__AssetReferenceId__c =:OrderItemAssetRefId];
            if(relatedorderitemrelationships!=null){
                List<AssetRelationship> rectoupdate = new List<AssetRelationship>();
                for(vlocity_cmt__OrderItemRelationship__c orderitemRelationshiprec:relatedorderitemrelationships){
                    if(assetidwithAssetRefID.get(orderitemRelationshiprec.vlocity_cmt__OrderItemId__r.vlocity_cmt__AssetReferenceId__c)!=null){
                        AssetRelationship AssetRelationshiprecupdate = new AssetRelationship();
                    AssetRelationshiprecupdate.AssetId = assetidwithAssetRefID.get(orderitemRelationshiprec.vlocity_cmt__OrderItemId__r.vlocity_cmt__AssetReferenceId__c);
                    AssetRelationshiprecupdate.RelatedAssetId = assetidwithAssetRefID.get(orderitemRelationshiprec.vlocity_cmt__RelatedOrderItemId__r.vlocity_cmt__AssetReferenceId__c);
                    AssetRelationshiprecupdate.vlocity_cmt__ProductRelationshipIdentifier__c = orderitemRelationshiprec.vlocity_cmt__ProductRelationshipIdentifier__c;
                    AssetRelationshiprecupdate.RelationshipType = orderitemRelationshiprec.vlocity_cmt__RelationshipType__c;
                    //AssetRelationshiprecupdate.ARTL_Related_Asset_Reference_Id__c=
                    rectoupdate.add(AssetRelationshiprecupdate);
                    }
                    
                }
                if(rectoupdate.size()>0){
                    insert rectoupdate;
                }
                
            }
            List<Asset> assettoUpdateReliesOnId = new List<Asset>();
            for(id asetsId:sourceassetids){
                Asset assetidrec = new Asset();
                assetidrec.id = asetsId;
                assetidrec.vlocity_cmt__ReliesOnItemId__c = '';
				assettoUpdateReliesOnId.add(assetidrec);                
            }
            if(assettoUpdateReliesOnId.size()>0){
                update assettoUpdateReliesOnId;
            }
        }
    }
}