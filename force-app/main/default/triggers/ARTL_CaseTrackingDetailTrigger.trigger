trigger ARTL_CaseTrackingDetailTrigger on Case_Tracking_Detail__c (before insert, before update, after insert, after update, after delete) {
    System.debug('DEBUGG ARTL_CaseTrackingDetailTriggerHandler.isFirstRun 1 ');
    if(Trigger.isAfter && Trigger.isInsert && !trigger.new.isEmpty()){ //|| Trigger.isAfter && Trigger.isUpdate && !trigger.new.isEmpty()){
        System.debug('DEBUGG ARTL_CaseTrackingDetailTriggerHandler.isFirstRun '+ ARTL_CaseTrackingDetailTriggerHandler.isFirstRun);
        
        if(ARTL_CaseTrackingDetailTriggerHandler.isFirstRun){
            ARTL_CaseTrackingDetailTriggerHandler.isFirstRun = false;
            Map<Id, Case_Tracking_Detail__c> caseTrackingDetailsNewMap = new Map<Id, Case_Tracking_Detail__c>();
            caseTrackingDetailsNewMap = Trigger.newMap;
            Map<Id, Case_Tracking_Detail__c> caseTrackingDetailsOldMap = new Map<Id, Case_Tracking_Detail__c>();
            caseTrackingDetailsOldMap = Trigger.oldMap;
            Map<Id, Case_Tracking_Detail__c> caseTrackingStep2Map = new Map<Id, Case_Tracking_Detail__c>();
            List<Case_Tracking_Detail__c> caseTrackingstep4Map = new List<Case_Tracking_Detail__c>();
            for(Id recordId: caseTrackingDetailsNewMap.keySet()){
                Case_Tracking_Detail__c ctdRecord = caseTrackingDetailsNewMap.get(recordId);
                if(!String.isBlank(ctdRecord.Step1__c) //&& ctdRecord.Step1__c == 'Success' 
                  // && !String.isBlank(ctdRecord.Step_1_Description__c) 
                  // && (ctdRecord.Step_1_Description__c.containsIgnoreCase('created') || 
                     //  ctdRecord.Step_1_Description__c.containsIgnoreCase('updated'))
                       && (ctdRecord.Step_2_Status__c == '' || ctdRecord.Step_2_Status__c == NULL)) {
                   //&& ((caseTrackingDetailsOldMap.containsKey(recordId) && caseTrackingDetailsOldMap.get(recordId)?.Step_2_Status__c != caseTrackingDetailsNewMap.get(recordId).Step_2_Status__c) ||
                     //  (caseTrackingDetailsOldMap.containsKey(recordId) && caseTrackingDetailsOldMap.get(recordId)?.Step_2_Description__c != caseTrackingDetailsNewMap.get(recordId).Step_2_Description__c))){
                           //&& ctdRecord.Case__r?.Status == ARTL_CaseTrackingDetailTriggerHandler.STATUS_IN_PROGRESS){
                           System.debug('DEBUGG Step 2 '+ ctdRecord.Step_2_Status__c);
                           caseTrackingStep2Map.put(recordId, ctdRecord);
                       }
                       else if(ctdRecord.Step1__c == 'Error'){
                        caseTrackingstep4Map.add(ctdRecord);

                       }
            }
            if(!caseTrackingStep2Map.isEmpty()){
                system.debug('caseTrackingStep2Map.keySet())'+caseTrackingStep2Map.keySet());
                //ARTL_CaseTrackingDetailTriggerHandler.afterInsert(caseTrackingStep2Map.keySet());
                System.enqueueJob(new ARTL_CaseTrackingDetailTriggerHandler(caseTrackingStep2Map.keySet()));
            }
            if(!caseTrackingstep4Map.isEmpty()){
                system.debug('caseTrackingstep4Map '+caseTrackingstep4Map);
                //System.enqueueJob(new CaseTrackingDetailStep4Handler(caseTrackingstep4Map));
                
            }
        }
    }
    if(Trigger.isAfter && Trigger.isUpdate && !trigger.new.isEmpty()){
        if(ARTL_CaseTrackingDetailTriggerHandler.isFirstRun){
            ARTL_CaseTrackingDetailTriggerHandler.isFirstRun = false;
            Map<Id, Case_Tracking_Detail__c> caseTrackingDetailsNewMap = new Map<Id, Case_Tracking_Detail__c>();
            caseTrackingDetailsNewMap = Trigger.newMap;
            Map<Id, Case_Tracking_Detail__c> caseTrackingDetailsOldMap = new Map<Id, Case_Tracking_Detail__c>();
            caseTrackingDetailsOldMap = Trigger.oldMap;
            Map<Id, Case_Tracking_Detail__c> caseTrackingStep2Map = new Map<Id, Case_Tracking_Detail__c>();
            for(Id recordId: caseTrackingDetailsNewMap.keySet()){
                Case_Tracking_Detail__c ctdRecord = caseTrackingDetailsNewMap.get(recordId);
                if( ctdRecord.Step1__c == 'Success'
                       && (ctdRecord.Step_2_Status__c == 'Success' )
                       && (ctdRecord.Step_3_Status__c == 'Success' && caseTrackingDetailsOldMap.get(ctdRecord.id).Step_3_Status__c!=ctdRecord.Step_3_Status__c ) 
                       && (ctdRecord.ARTL_Step_4_Status__c == '' || ctdRecord.ARTL_Step_4_Status__c == NULL)) {
                   //&& ((caseTrackingDetailsOldMap.containsKey(recordId) && caseTrackingDetailsOldMap.get(recordId)?.Step_2_Status__c != caseTrackingDetailsNewMap.get(recordId).Step_2_Status__c) ||
                     //  (caseTrackingDetailsOldMap.containsKey(recordId) && caseTrackingDetailsOldMap.get(recordId)?.Step_2_Description__c != caseTrackingDetailsNewMap.get(recordId).Step_2_Description__c))){
                           //&& ctdRecord.Case__r?.Status == ARTL_CaseTrackingDetailTriggerHandler.STATUS_IN_PROGRESS){
                           System.debug('DEBUGG Step 2 '+ ctdRecord.Step_2_Status__c);
                           caseTrackingStep2Map.put(recordId, ctdRecord);
                       }
                else if( ctdRecord.Step1__c == 'Success' && ctdRecord.Step_2_Status__c == 'Error' ){
                caseTrackingStep2Map.put(recordId, ctdRecord);
                      }
     
                else if(ctdRecord.Step1__c == 'Success' && ctdRecord.Step_2_Status__c == 'Success' && ctdRecord.Step_3_Status__c == 'Error' ){
                caseTrackingStep2Map.put(recordId, ctdRecord);
                       }

            }
           
            if(!caseTrackingStep2Map.isEmpty()){
                system.debug('caseTrackingStep2Map.keySet())'+caseTrackingStep2Map.keySet());
                //ARTL_CaseTrackingDetailTriggerHandler.afterInsert(caseTrackingStep2Map.keySet());
                
                System.enqueueJob(new CaseTrackingDetailStep4Handler(caseTrackingStep2Map.keySet()));
            }
        }
        
    }  
}