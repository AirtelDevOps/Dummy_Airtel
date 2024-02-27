/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-09-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class ARTL_BCPDCPBulkUpdateBatch implements Database.Batchable<sObject>, Database.Stateful{
    String iterationid;
    public ARTL_BCPDCPBulkUpdateBatch(String iterationid) {
        this.iterationid = iterationid;
    }

    /* Id batchJobId = Database.executeBatch(new ARTL_BCPDCPBulkUpdateBatch('a7i720000002i8DAAQ'), 200); 
        System.debug('batchJobId = ' + batchJobId);
    */
    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('this.iterationid-->'+this.iterationid);
        String query = 'SELECT Record_Id__c, First_Name__c, Last_Name__c, Email_Address__c, Phone__c, Role__c, Designation__c, Street__c, City__c, State__c, Country__c, Pincode__c, Status__c, GST__c, GST_Applicable__c, Standard_Reason__c, ARTL_Bulk_Upload_Iteration__c FROM ARTL_Bulk_Upload_Staging__c WHERE ARTL_Bulk_Upload_Iteration__c = \''+this.iterationid+'\'';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<ARTL_Bulk_Upload_Staging__c> stagingRecordList){
        ARTL_UpdateBcpDcpLwcController.isUpdateBcpDcp = true;
        Set<String> cprIdSet = new Set<String>();
        Set<Id> contactIdSet = new Set<Id>();
        Set<Id> premiseIdSet = new Set<Id>();
        Set<Id> gstIdSet = new Set<Id>();
        List<sObject> recordsToUpdate = new List<sObject>();
        Set<String> gstNameSet = new Set<String>();
        Map<String,GST__c> gstNameMap = new Map<String,GST__c>();

        Map<Id,Id> cprIdWithStagingIdMap = new Map<Id,Id>();
        Map<Id,Id> cprRelatedIdWithcptIdMap = new Map<Id,Id>();
        Map<Id, ARTL_Bulk_Upload_Staging__c> stagingIdWithStagingRecordMap = new Map<Id, ARTL_Bulk_Upload_Staging__c>();

        for(ARTL_Bulk_Upload_Staging__c stagingrec : stagingRecordList) {
            cprIdSet.add(stagingrec.Record_Id__c);
            gstNameSet.add(stagingrec.GST__c);

            cprIdWithStagingIdMap.put(stagingrec.Record_Id__c, stagingrec.Id);
        }

        List<GST__c> gstList = [SELECT Id, Name FROM GST__c WHERE Name in: gstNameSet];

        for(GST__c gst : gstList) {
            gstNameMap.put(gst.Name, gst);
        }

        Map<Id,ContactPremiseRelation__c> cprMap = new Map<Id,ContactPremiseRelation__c>([SELECT Id, Contact__c, Premises__c, GST__c, ARTL_Standard_Reason__c FROM ContactPremiseRelation__c WHERE Id in: cprIdSet]);
        
        for(ContactPremiseRelation__c cpr : cprMap.values()) {
            contactIdSet.add(cpr.Contact__c);
            premiseIdSet.add(cpr.Premises__c);
            gstIdSet.add(cpr.GST__c);

            cprRelatedIdWithcptIdMap.put(cpr.Contact__c, cpr.Id);
            cprRelatedIdWithcptIdMap.put(cpr.Premises__c, cpr.Id);
            cprRelatedIdWithcptIdMap.put(cpr.Id, cpr.Id);
        }

        Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, FirstName, LastName, Email, MobilePhone, ARTL_Designation__c, ARTL_Contact_Role__c FROM Contact WHERE Id in: contactIdSet]);
        Map<Id,vlocity_cmt__Premises__c> premiseMap = new Map<Id,vlocity_cmt__Premises__c>([SELECT Id, vlocity_cmt__StreetAddress__c, vlocity_cmt__City__c, vlocity_cmt__State__c, vlocity_cmt__Country__c, vlocity_cmt__PostalCode__c FROM vlocity_cmt__Premises__c WHERE Id in: premiseIdSet]);
        Map<Id,GST__c> gstMap = new Map<Id,GST__c>([SELECT Id, Name FROM GST__c WHERE Id in: gstIdSet]);

        for(ARTL_Bulk_Upload_Staging__c stagingRec: stagingRecordList) {
            ContactPremiseRelation__c cpr = cprMap.get((Id)stagingRec.Record_Id__c);
            Contact con = contactMap.get(cprMap.get((Id)stagingRec.Record_Id__c).Contact__c);
            vlocity_cmt__Premises__c prem = premiseMap.get(cprMap.get((Id)stagingRec.Record_Id__c).Premises__c);
            GST__c gst = gstMap.get(cprMap.get((Id)stagingRec.Record_Id__c).GST__c);
            
            if(String.isNotBlank(stagingRec.First_Name__c)) {
                con.FirstName = stagingRec.First_Name__c;
            }
            if(String.isNotBlank(stagingRec.Last_Name__c)) {
                con.LastName = stagingRec.Last_Name__c;
            }
            if(String.isNotBlank(stagingRec.Email_Address__c)) {
                con.Email = stagingRec.Email_Address__c;
            }
            if(String.isNotBlank(stagingRec.Phone__c)) {
                con.MobilePhone = stagingRec.Phone__c;
            }
            if(String.isNotBlank(stagingRec.Designation__c)) {
                con.ARTL_Designation__c = stagingRec.Designation__c;
            }
            if(String.isNotBlank(stagingRec.Role__c)) {
                con.ARTL_Contact_Role__c = stagingRec.Role__c;
            }

            if(String.isNotBlank(stagingRec.Standard_Reason__c)) {
                cpr.ARTL_Standard_Reason__c = stagingRec.Standard_Reason__c;
            }

            if(String.isNotBlank(stagingRec.Street__c)) {
                prem.vlocity_cmt__StreetAddress__c = stagingRec.Street__c;
            }
            if(String.isNotBlank(stagingRec.City__c)) {
                prem.vlocity_cmt__City__c = stagingRec.City__c;
            }
            if(String.isNotBlank(stagingRec.State__c)) {
                prem.vlocity_cmt__State__c = stagingRec.State__c;
            }
            if(String.isNotBlank(stagingRec.Country__c)) {
                prem.vlocity_cmt__Country__c = stagingRec.Country__c;
            }
            if(String.isNotBlank(stagingRec.Pincode__c)) {
                prem.vlocity_cmt__PostalCode__c = stagingRec.Pincode__c;
            }
            if(gstNameMap.containsKey(stagingRec.GST__c) && String.isNotBlank(stagingRec.GST__c)) {
                System.debug('stagingRec.GST__c--->'+gstNameMap.get(stagingRec.GST__c).Id);
                cpr.GST__c = gstNameMap.get(stagingRec.GST__c).Id;
            }

            recordsToUpdate.add(prem);
            recordsToUpdate.add(cpr);
            recordsToUpdate.add(con);
        }

        if(!recordsToUpdate.isEmpty()) {
            List<Database.SaveResult> srList = new List<Database.SaveResult>();
            try {
                System.debug('sat recordsToUpdate=' + recordsToUpdate.size());
                
                srList = Database.update(recordsToUpdate, false);
                System.debug('sat srList=' + srList.size());
            } catch (Exception e) {
                System.debug('sat error=' + e.getMessage());
            }
            

            //stagingIdWithStagingRecordMap
            //cprIdWithStagingIdMap
            //cprRelatedIdWithcptIdMap
            
            System.debug('sat srList=' + srList.size());
            for (Database.SaveResult sr : srList) {
                ARTL_Bulk_Upload_Staging__c stagingRecord = new ARTL_Bulk_Upload_Staging__c();
                stagingRecord.Id = cprIdWithStagingIdMap.get(cprRelatedIdWithcptIdMap.get(sr.getId()));

                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    stagingRecord.Status__c = 'Success';
                }
                else {
                    stagingRecord.Status__c = 'Failed';
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                        stagingRecord.Errors__c = err.getMessage();
                    }
                }

                stagingIdWithStagingRecordMap.put(stagingRecord.Id, stagingRecord);
            }

            update stagingIdWithStagingRecordMap.values();
        }
    }

    public void finish(Database.BatchableContext bc){
        //System.debug('sat this.iterationid=' + this.iterationid + '=');
        Artl_BcpDcpCtrl.handleNotification(this.iterationid);
    }
}