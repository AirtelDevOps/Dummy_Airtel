public without sharing class ARTL_BulkUploadCtrl {
    public static List<Id> itera = NEW List<Id>();
    @AuraEnabled
    public static Map<String,Object> getMetadataConfig(){
        Map<String,Object> mapResponse = new Map<String,Object>();
        Map<String,Object> mapResponseRefined = new Map<String,Object>();
        Map<String,Object> mapHeaders = new Map<String,Object>();
        Map<String,Object> mapApiNameFields = new Map<String,Object>();
        List<Map<String,Object>> options = new List<Map<String,Object>>(); 
        for(ARTL_Bulk_Upload_Config__mdt objMdt : [SELECT Label, File_Header_CSV__c,Object_Fields__c FROM ARTL_Bulk_Upload_Config__mdt]){
            mapHeaders.put(objMdt.Label,objMdt.File_Header_CSV__c);
            mapApiNameFields.put(objMdt.Label,objMdt.Object_Fields__c);
        }
        mapResponse.put('headers',mapHeaders);
        mapResponse.put('apiNames',mapApiNameFields);
        
        String assignedPermissionSet;
        String permissionSets = System.Label.ARTL_Permission;
        List<String> permSetList = permissionSets.split(',');
        for(String per: permSetList){
            Boolean hasCustomPermission = FeatureManagement.checkPermission(per);
            if(hasCustomPermission)
                assignedPermissionSet = per;
        }
        System.debug('Assigned Permission'+assignedPermissionSet);
        List<String> option = (System.Label.get('', assignedPermissionSet, '')).split(',');
        System.debug('Options'+option);
        For(String op : option){
            Map<String,Object> opt = new Map<String,Object>();
            if(op == 'BCPDCP_Contact') {
                opt.put('label','Insert BCPDCP Contact');
            	opt.put('value','BCPDCP_Contact');
            } else if(op == 'Party_Contact') {
                opt.put('label','Insert Party Contact');
            	opt.put('value','Party_Contact');
            } else if(op == 'Party_Contact_Update') {
                opt.put('label','Update Party Contact');
            	opt.put('value','Party_Contact_Update');
            } else if(op == 'BCPDCP_Contact_Update') {
                opt.put('label','Update BCPDCP Contact');
            	opt.put('value','BCPDCP_Contact_Update');
            } else {
            	opt.put('label',op);
            	opt.put('value',op);
            }
            options.add(opt);
        }
        mapResponse.put('options',options);
        return mapResponse;
        
    }
    @AuraEnabled
    public static string uploadData(List<Object> csvData, String header, String type, Id iterationId ){
       try {
    
            ARTL_Bulk_Upload_Config__mdt recMetadata = [SELECT Object_Fields__c ,File_Header_CSV__c FROM ARTL_Bulk_Upload_Config__mdt WHERE DeveloperName =:type];
            List<String> lstHeaderColumns = recMetadata.File_Header_CSV__c.split(',');
            Integer numberOfColumns =  lstHeaderColumns.size();
            List<String> lstFieldAPIs = recMetadata.Object_Fields__c .split(',');
            System.debug('Field API'+lstFieldAPIs);
            List<sObject> lstStageToInsert = new List<sObject>();
            for(Object obj : csvData) {
                System.debug('CSV Data'+obj);
                String strColumns = String.valueOf(obj);
                System.debug('strColumns'+strColumns);
                Sobject objRec;
                objRec = new ARTL_Bulk_Upload_Staging__c();
                if (strColumns.startsWith(','))
                    strColumns = strColumns.replace(',', ':blank:,');
                while (strColumns.contains(',,')) {
                    strColumns = strColumns.replace(',,', ',:blank:,');
                }
                if (strColumns.endsWith(',')) {
                    strColumns = strColumns + ':blank:';
                }
                String[] lstData = strColumns.trim().split(',(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)');
                //List<String> lstData = strColumns.split(',');
                for(Integer iterator=0; iterator<numberOfColumns; iterator++) {
                    objRec.put(lstFieldAPIs[iterator], (lstData.size()>iterator) ? (String.valueOf(lstData[iterator]).replaceAll('"','').replaceAll(':blank:','')) : '');
                    objRec.put('Type__c',type);
                }
                     
                
                objRec.put('ARTL_Bulk_Upload_Iteration__c',iterationId);
                lstStageToInsert.add(objRec);
            }
        
            insert lstStageToInsert;
           
            return 'success';
        } catch (Exception e) {
            return 'error';
            //throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string createIteration(String fileName, String type){
        try {
            ARTL_Bulk_Upload_Iteration__c objIteration = new ARTL_Bulk_Upload_Iteration__c();
            objIteration.File_Name__c = fileName;
            Id iterationRecordTypeId = Schema.SObjectType.ARTL_Bulk_Upload_Iteration__c.getRecordTypeInfosByDeveloperName().get(type).getRecordTypeId();
            objIteration.RecordTypeId = iterationRecordTypeId;
            insert objIteration;
            
            String UserId = UserInfo.getUserId();
        
            List<ARTL_Bulk_Upload_Iteration__c> prevIte = new List<ARTL_Bulk_Upload_Iteration__c>();
            List<ARTL_Bulk_Upload_Iteration__c> prevIteUpdate = new List<ARTL_Bulk_Upload_Iteration__c>();
            
            prevIte = [SELECT id FROM ARTL_Bulk_Upload_Iteration__c WHERE id !=: objIteration.Id AND CreatedById =:UserId AND RecordType.Name =: type AND isNew__c = true];
            if(prevIte.size()>0){
                for(ARTL_Bulk_Upload_Iteration__c it : prevIte){
                    it.isNew__c = false;
                    prevIteUpdate.add(it);
                }
                if(prevIteUpdate.size()>0){
                    update prevIteUpdate;
                }
            }
            return objIteration.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static string inititeValidationBatch(Id iterationId, String type){
        try {
            ARTL_BulkUploadValidationBatchJob job = new ARTL_BulkUploadValidationBatchJob(iterationId,type);
            Integer defaultBatchSize = 200;
            if(type.containsIgnoreCase('contact')) {
                defaultBatchSize = 20;
            }
            Id batchJobId = Database.executeBatch(job,defaultBatchSize);
            ARTL_Bulk_Upload_Iteration__c objIteration = [SELECT id,Job_Id__c FROM ARTL_Bulk_Upload_Iteration__c WHERE id=:iterationId];
            objIteration.Job_Id__c = batchJobId;
            System.debug('ObjectIteration '+objIteration);
            upsert objIteration;
            if(batchJobId!=NULL){
                return 'success';
            }else{
                return 'failed'; 
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /*@AuraEnabled
    public static Map<String,Object> getHeader(){
        try {
            String fileId = '069xxxxxxxxxxxxxxx';
            ContentVersion fileVersion = [SELECT Id, Title,VersionData FROM ContentVersion WHERE Id = '068720000076YuDAAU'];
            return new Map<String,Object>{'data'=>EncodingUtil.base64Encode(fileVersion.VersionData),'userName'=>UserInfo.getUserName()};
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }*/
    @AuraEnabled
    public static String getTemplate(String type){
        try {
            ARTL_Bulk_Upload_Config__mdt recMetadata = [SELECT Template_URL__c FROM ARTL_Bulk_Upload_Config__mdt WHERE DeveloperName =:type];
            String url = recMetadata.Template_URL__c;
            return url;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}