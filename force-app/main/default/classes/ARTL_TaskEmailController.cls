global  without sharing class ARTL_TaskEmailController {
	@InvocableMethod(label='send Email to DIRS')
    public static void sendEmailtoDIRS(List<FlowInput> flowInputs) {
        if(!ARTL_BACreationPreProcessBatch.bypassFromBACreationBatch){
            sendWelcomeEmail(flowInputs);
        }
    }
     
    public static void sendWelcomeEmail(List<FlowInput> flowInputs){
        Map<String,Object> input = new Map<String,Object>();
        Map<String,Object> output = new Map<String,Object>();
        Id recordId = flowInputs.get(0).recordId;
        Id taskrecordId = flowInputs.get(0).taskrecordId;
        String templateName = flowInputs.get(0).templateName;
        String objectName = flowInputs.get(0).objectName;
        String emailType = flowInputs.get(0).emailType;
        SObjectType objectType = recordId.getSobjectType();
        List<String> bcclist = new List<String>();
        String cclist = '';
        String tolist = '';
        emailWrapper objemail = new emailWrapper();
        System.debug('emailType>>>' +emailType);
        String filename;
        try{
            String cvId = ARTL_EmailTemplateService.getcontentVerionId(recordId);
            System.debug('emailType>>>' +cvId);
            sendEmail(recordId,taskrecordId,templateName,cvId,emailType);
             	
        }
        Catch(Exception e){
            System.debug('Exception>>>'+ e.getMessage() + '===' + e.getLineNumber());
        }
    }
        
    
    @future (Callout=true)
    public static void sendEmail(String recordId,String taskrecordId, String templateName, String cvId, String emailType)
    {   
        Map<String,Object> response = new Map<String,Object>();
        ARTL_Document__c doc = [Select Id FROM ARTL_Document__c WHERE (Quote__c=:recordId OR Order__c =:recordId) limit 1];
        System.debug('doc>>>'+doc);
        response = ARTL_DocumentUploadController.makeDocUploadCallout(doc.Id,cvId);
        System.debug('response>>>'+response);
        doc = [Select Id,s3_Document_URL__c FROM ARTL_Document__c WHERE Id=:doc.Id limit 1];
        emailWrapper objemail = new emailWrapper();
        String activityName;
        if(emailType == 'welcome'){
            objemail = ARTL_EmailTemplateService.getWelcomeEmailTemplate(recordId,templateName);
            activityName = 'Welcome Email';
        }
        else if(emailType == 'CreateAndSendKickOffEmail'){
            objemail = ARTL_EmailTemplateService.getNonDeemedLOCEmailTemplate(recordId,templateName);
            activityName = 'Kick Off Email';
        }
        else if(emailType == 'ServiceHandover'){
            objemail = ARTL_EmailTemplateService.getServiceHandoverEmailTemplate(recordId,templateName);
            activityName = 'Service Handover';
        }
        else if(emailType == 'LOCReject'){
            objemail = ARTL_EmailTemplateService.getLOCRejectEmailTemplate(recordId,templateName);
            activityName = 'LOC Reject';
        }
        else if(emailType == 'DeemedEmail'){
            objemail = ARTL_EmailTemplateService.getLOCRejectEmailTemplate(recordId,templateName);
            activityName = 'Deemed Email';
        }
        else if(emailType == 'NonDeemedEmail'){
            objemail = ARTL_EmailTemplateService.getNonDeemedLOCEmailTemplate(recordId,templateName);
            activityName = 'Non Deemed Email';
        }
		// Replace  GracePeriodDate 
        If(taskrecordId != null){
            List<Task> lsttask = [Select Id,ARTL_LOC_Bill_Start_Date__c, Number_of_days_for_Deemed_LOC__c  
                                  FROM Task WHERE Id=:taskrecordId];
            if(!lsttask.isEmpty() && lsttask[0].ARTL_LOC_Bill_Start_Date__c != null && lsttask[0].Number_of_days_for_Deemed_LOC__c != null){
                objemail.msgbody = objemail.msgbody.replaceAll('GracePeriodDate',String.valueOf(lsttask[0].ARTL_LOC_Bill_Start_Date__c.addDays(Integer.valueOf(lsttask[0].Number_of_days_for_Deemed_LOC__c)))); 
            }else if(!lsttask.isEmpty() && lsttask[0].ARTL_LOC_Bill_Start_Date__c != null && lsttask[0].Number_of_days_for_Deemed_LOC__c == null){
                objemail.msgbody = objemail.msgbody.replaceAll('GracePeriodDate',String.valueOf(lsttask[0].ARTL_LOC_Bill_Start_Date__c));
            }
        }       
        
        objemail.filePath = doc.s3_Document_URL__c;
        objemail.invoiceNo = ARTL_EmailTemplateService.createActivity(recordId,activityName);
        System.debug('objemail>>>'+objemail);
        sendEmailtoDIRS(objemail);
    }
    
    public static void sendEmailtoDIRS(emailWrapper wrapper){
        System.debug('wrapper>>>>'+JSON.serialize(wrapper));
        Map<String,Object> input = new Map<String,Object>();
        Map<String,Object> output = new Map<String,Object>();
        input.put('message',wrapper.msgbody);
        input.put('custNo',wrapper.custNo);
        input.put('nbaId',wrapper.nbaId);
        input.put('emailId','');
        input.put('accountNo',wrapper.accountNo);
        input.put('subject',wrapper.subject);
        input.put('filePath',wrapper.filePath);
        input.put('partyId',wrapper.partyId);
        input.put('invoiceNo',wrapper.invoiceNo);
        input.put('ccList',wrapper.ccList);
        input.put('toList',wrapper.toList);
        input.put('productName',wrapper.productName);
        System.debug('input>>>>'+JSON.serialize(input));
        String submitresult = JSON.serialize(vlocity_cmt.IntegrationProcedureService.runIntegrationProcedureQueueable('ARTL_MailThroughDIRS', 
						input, output));
    }
    public class emailWrapper{
        public String msgbody {get;set;}
        public String subject {get;set;}
        public String custNo {get;set;}
        public String nbaId {get;set;}
        public String emailId {get;set;}
        public String accountNo {get;set;}
        public String filePath {get;set;}
        public String partyId {get;set;}
        public String invoiceNo {get;set;}
        public String ccList {get;set;}
        public String toList {get;set;}
        public String productName {get;set;}
        public String contentversionId {get;set;}
    }
    //Flow Inputs
    public class FlowInput{
        @InvocableVariable(required=true) public Id recordId;
        @InvocableVariable(required=true) public String templateName;
        @InvocableVariable(required=false) public Id taskrecordId;
        @InvocableVariable(required=false) public Id objectName;
        @InvocableVariable(required=true) public String emailType;
    }
    
}