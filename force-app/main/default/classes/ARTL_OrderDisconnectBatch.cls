/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ARTL_OrderDisconnectBatch
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Akshay Kaushik    <akshay.kaushik@salesforce.com>
* @modifiedBy     Akshay Kaushik    <akshay.kaushik@salesforce.com>
* @maintainedBy   Akshay Kaushik    <akshay.kaushik@salesforce.com>
* @version        1.0
* @created        14-12-2023
* @modified       DD-MM-YYYY
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* 1.0             akshay.kaushik@salesforce.com
* 2023-10-04      Created the class to create disconnect order and add OTC and submit order
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
global class ARTL_OrderDisconnectBatch implements Database.Batchable < sObject > , Database.Stateful{
    global String caseId;
    global List<String> cartIds = new List<String>();
    global ARTL_OrderDisconnectBatch(String caseId) {
        system.debug('caseId'+caseId);
        this.caseId = caseId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('select Id,ARTL_LSI__c, ARTL_PTC__c from case' +
                                        ' WHERE Id =:caseId' );
    }
   global void execute(Database.BatchableContext BC, List <case> caseList) {
        Id assetId;
        Map < String, Object > input = new Map < String, Object> ();
        Map < String, Object > output = new Map < String, Object> ();
        Map < String, Object > options = new Map < String, Object> ();
        String attNoOfSites = ARTL_Constants.SDWAN_NO_OF_SITE_ATTCODE; 
        String attNoOfLicences = ARTL_Constants.FOURG_NO_OF_LICENCES_ATTCODE;
        Asset[] asset = [select id,vlocity_cmt__ParentItemId__c,vlocity_cmt__AssetReferenceId__c,vlocity_cmt__BillingAccountId__c,vlocity_cmt__ServiceAccountId__c,vlocity_cmt__RootItemId__c,AccountId,vlocity_cmt__AttributeSelectedValues__c from asset WHERE ARTL_LSI_FText__c =: caseList[0].ARTL_LSI__c];
        if(asset.size() > 0){
            if(String.isNotBlank(asset[0].vlocity_cmt__ParentItemId__c)){
                Asset[] ParentAsset = [select id,vlocity_cmt__ParentItemId__c,vlocity_cmt__AssetReferenceId__c,vlocity_cmt__BillingAccountId__c,vlocity_cmt__ServiceAccountId__c,vlocity_cmt__RootItemId__c,AccountId,vlocity_cmt__AttributeSelectedValues__c from asset WHERE vlocity_cmt__RootItemId__c =: asset[0].vlocity_cmt__ParentItemId__c];
                assetId = ParentAsset[0].Id;
                system.debug('ParentAsset Internet or MPLS***'+ParentAsset);
            }
            system.debug('asset  primary or secondary***'+asset);
            disconnectAsset(asset[0],caseList[0].ARTL_PTC__c,'Yes');
            AssetRelationship[] assetReltionList = [select id,RelatedAsset.Product2.ProductCode,Asset.Product2.ProductCode,AssetId,RelatedAssetId,RelatedAsset.vlocity_cmt__ParentItemId__c,RelatedAsset.vlocity_cmt__RootItemId__c, RelatedAsset.vlocity_cmt__AssetReferenceId__c
                                                    from AssetRelationship where RelationshipType = 'ReliesOn' AND (AssetId =:assetId OR AssetId =:asset[0].Id)];
            if(assetReltionList.size() > 0){ 
                Set<String> assetRefIds = new Set<String>();
                for(AssetRelationship aRel : assetReltionList){
                    assetRefIds.add(aRel.RelatedAsset.vlocity_cmt__AssetReferenceId__c);
                }
                List<Asset> relatedAsset = [select id,vlocity_cmt__ParentItemId__c,vlocity_cmt__BillingAccountId__c,vlocity_cmt__ServiceAccountId__c,vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__AssetReferenceId__c,vlocity_cmt__RootItemId__c,AccountId from Asset 
                                                  where vlocity_cmt__RootItemId__c IN:assetRefIds ];
                system.debug('relatedAsset Internet or MPLS***'+relatedAsset);
                for(Asset assetRec : relatedAsset){
                    if(assetRec.vlocity_cmt__AttributeSelectedValues__c != null){
                        if(assetRec.vlocity_cmt__AttributeSelectedValues__c.contains(attNoOfLicences)){
                            modifyRelatedAsset(assetRec,attNoOfLicences,false);
                        } 
                        else if(assetRec.vlocity_cmt__AttributeSelectedValues__c.contains(attNoOfSites)){
                            modifyRelatedAsset(assetRec,attNoOfSites,true);
                        }
                    }
                }                                  
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        validateAndSubmitOrder();
        system.debug('cartIds***'+cartIds);
    }
    
    //Disconnect Asset
    public void modifyRelatedAsset(Asset relatedAsset, String attName,Boolean isSDWAN) {
        if(relatedAsset.vlocity_cmt__AttributeSelectedValues__c != null){
            Map<String, Object> assetAttMap = (Map<String, Object>) JSON.deserializeUntyped(relatedAsset.vlocity_cmt__AttributeSelectedValues__c);
            if(assetAttMap != NULL){
                Integer noOfLicences;
                if(assetAttMap.containsKey(attName)){
                    if(assetAttMap.get(attName) != NULL){
                        noOfLicences  = Integer.valueOf(assetAttMap.get(attName));
                        if(noOfLicences > 1 || isSDWAN){
                            //call IP to modify attributes
                            String procedureName = 'ARTLOM_ModifyOrder';
                            Map<String, Object> ipInput = new Map<String, Object> ();
                            Map<String, Object> ipOutput = new Map<String, Object> ();
                            Map<String, Object> ipOptions = new Map<String, Object> ();
                            ipInput.put('AssetId',relatedAsset.Id);
                            ipInput.put('AttributeName',attName);
                            ipInput.put('AttributeValue',noOfLicences-1);
                            ipInput.put('Account',relatedAsset.AccountId);
                            ipInput.put('BillingAccount',relatedAsset.vlocity_cmt__BillingAccountId__c);
                            ipInput.put('ServiceAccount',relatedAsset.vlocity_cmt__ServiceAccountId__c);
                            System.debug('IP ipInput modify: ' + ipInput);
                            ipOutput = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
                            String cartId = (String)ipOutput.get('CartId');
                            if(Test.isRunningTest()){
                                cartId = 'Test';
                            }
                            cartIds.add(cartId);
                            System.debug('IP Output modify: ' + ipOutput);
                        } else if(!isSDWAN && noOfLicences <= 1){
                            disconnectAsset(relatedAsset,0,'No');
                        }
                    }
                }
            } 
        }
    }
    
    //Disconnect Asset
    public void disconnectAsset(Asset asset,Decimal PTC,String CancellationChargeApplied) {
        String procedureName = 'ATRLOM_DisconnectOrder';
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        ipInput.put('AssetId',asset.Id);
        ipInput.put('PTC',PTC);
        ipInput.put('CancellationChargeApplied',CancellationChargeApplied);
        System.debug('IP ipInput disconnect: ' + ipInput);
        ipOutput = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
        String cartId = (String)ipOutput.get('CartId');
        if(Test.isRunningTest()){
            cartId = 'Test';
        }
        cartIds.add(cartId.remove('"'));
        System.debug('IP Output disconnect: ' + ipOutput);
    }
    
    //Validate and Submit Order
    public void validateAndSubmitOrder() {
        String procedureName = 'b2bExpress_BulkSubmitSubOrders';
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        ipInput.put('cartId',cartIds[0]);
        ipInput.put('subOrderIds',cartIds);
        System.debug('IP ipInput disconnect: ' + ipInput);
        ipOutput = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
        
    }
    
}