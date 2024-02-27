public class CaseTrackingDetailStep4Handler implements Queueable {
    public Set<Id> idList;

    public static Boolean isFirstRun = true;
    public static String STATUS_IN_PROGRESS = 'In-Progress';
    public CaseTrackingDetailStep4Handler(Set<Id> idList  ){
        this.idList=idList;
        
        
    }
    public void execute(QueueableContext context){
        system.debug('this.idlist'+this.idList);
        System.debug('Inside the ARTL_CaseTrackingDetailTrigger');
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<Id, Case_Tracking_Detail__c> caseTrackingDetailsUpdate = new Map<Id, Case_Tracking_Detail__c>();
        Map<Id, Case_Tracking_Detail__c> caseTrackingDetailsNew = new Map<ID, Case_Tracking_Detail__c>([Select Id, Step1__c, Step_1_Description__c, SF_Record_ID__c, 
                                                                                                        Case__r.Status, Step_2_Status__c, Step_2_Description__c,  Step_3_Status__c ,
                                                                                                        Step_3_Description__c ,ARTL_Step_4_Status__c, ARTL_Step_4_Description__c
                                                                                                       From Case_Tracking_Detail__c
                                                                                                       Where Id IN :idList]);
        
        for(Id recordId: caseTrackingDetailsNew.keySet()){
            Case_Tracking_Detail__c ctdRecord = caseTrackingDetailsNew.get(recordId);
            //if(ctdRecord.Step1__c == 'Success' && (ctdRecord.Step_1_Description__c.containsIgnoreCase('created') || ctdRecord.Step_1_Description__c.containsIgnoreCase('updated'))){//  && ctdRecord.Case__r?.Status == STATUS_IN_PROGRESS){
                inputMap.put('recordId', ctdRecord.SF_Record_ID__c);
                inputMap.put('caseId', ctdRecord.Case__c);
            	String inputMapJson = JSON.serialize(inputMap);
                CaseTrackingDetailStep4Handler.invokeIntegrationProcedure(inputMapJson, 'ARTL_Step4InvokeSolace', recordId);
                System.debug('DEBUGG outputMap '+ outputMap);         
                caseTrackingDetailsUpdate.put(recordId, ctdRecord);
            //}
        }
        /*if(!caseTrackingDetailsUpdate.isEmpty()){
            ARTL_CaseTrackingDetailTriggerHandler.isFirstRun = false;
            for(Database.SaveResult sr: Database.update(caseTrackingDetailsUpdate.values())){
                if (sr.isSuccess()) {
                    System.debug('Successfully updated ARTL_CaseTrackingDetailTriggerHandler - ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('DEBUGG The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('DEBUGG ' + err.getFields());
                    }
                }
            }
        }*/
        
    }

    @future(callout=true)
    public static void invokeIntegrationProcedure(String inputMapJson, String procedureName ,Id recordId){
        Map<String, Object> inputMap = (Map<String, Object>)JSON.deserializeUntyped(inputMapJson);
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        ipOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, inputMap, ipOptions);
        system.debug('ipOutput'+ipOutput);
        Case_Tracking_Detail__c ctdRecord = [select id , Step_2_Status__c,Step_2_Description__c from Case_Tracking_Detail__c where id=:recordId];
        ctdRecord.ARTL_Step_4_Status__c = (String) ipOutput.get('status');
        ctdRecord.ARTL_Step_4_Description__c = (String) ipOutput.get('description');
        update ctdRecord;
        
        //return ipOutput;
    }
}