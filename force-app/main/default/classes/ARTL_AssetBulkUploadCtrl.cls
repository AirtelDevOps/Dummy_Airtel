public without sharing class ARTL_AssetBulkUploadCtrl {
    
    private static String STAGING_TYPE = 'Asset_to_Quote';

    @AuraEnabled
    public static List<Decimal> checkLsi(List<Decimal> lsiList , String iterationId){
        System.debug('lsiList=' + lsiList + '=');
        System.debug('iterationId=' + iterationId + '=');
        try {
            List<Decimal> invalidLsiList = new List<Decimal>();
            Set<Decimal> existingLsiSet = new Set<Decimal>();

            List<Asset> assetList = [Select ARTL_LSI__c From Asset Where ARTL_LSI__c IN : lsiList];
            for(Asset lsi : assetList){
                existingLsiSet.add(lsi.ARTL_LSI__c);
            }

            if(!existingLsiSet.isEmpty()){
                for(Decimal lsi : lsiList){
                    if(!existingLsiSet.contains(lsi)){
                        invalidLsiList.add(lsi);
                    }
                }
            }

            if(invalidLsiList.isEmpty()){
                createStagingRecords(lsiList, iterationId);
            }
            
            return invalidLsiList;
        } catch (Exception e) {
            System.debug('e.getMessage()=' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @TestVisible
    private static void createStagingRecords(List<Decimal> lsiList , String iterationId){
        List<sObject> lstStageToInsert = new List<sObject>();
        ARTL_Bulk_Upload_Staging__c stagingRecord = new ARTL_Bulk_Upload_Staging__c();
        if(iterationId.contains('"')) iterationId = iterationId.remove('"');

        for(Decimal lsi : lsiList) {
            stagingRecord = new ARTL_Bulk_Upload_Staging__c();
            
            stagingRecord.Record_Id__c = String.valueOf(lsi);
            stagingRecord.Type__c = STAGING_TYPE;
            stagingRecord.ARTL_Bulk_Upload_Iteration__c = iterationId;

            lstStageToInsert.add(stagingRecord);
        }
        System.debug('lstStageToInsert=' + lstStageToInsert.size() + '=');
        insert lstStageToInsert;
    }
}