public without sharing class ARTL_NotifyCustomerOnEventCompleted {
    @InvocableMethod(label='Notify Customer on Event Completed')
    public static void emailCustomerOnEventCompletion(List<FlowInput> flowInput){
        try{
            Map<String, Object> input = new Map<String, Object>();
            Map<String,Object> output = new Map<String,Object>();
            String mailBody;
            String eventId = flowInput.get(0).eventId;
 			System.debug('Inoput received'+flowInput);
            String templateName = flowInput.get(0).templateName;
            EmailTemplate emailTemplate;
            String toList = String.join(flowInput.get(0).toList, ';');
            if(!String.isBlank(templateName) && !String.isBlank(eventId) && !String.isBlank(toList)){
                emailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body
                                               From EmailTemplate 
                                               Where DeveloperName = :templateName];
                Event eventRecord = [Select Id, Meeting_Notes_External__c, Owner.FirstName, Owner.LastName, SR_FTR_Number__c 
                                     from Event Where Id = :eventId];
                
                mailBody = String.valueOf(emailTemplate.HtmlValue);
                
                mailBody = mailBody.containsIgnoreCase('$OwnerFirstName$') && !String.isBlank(eventRecord.Owner.FirstName) ? 
                    mailBody.replace('$OwnerFirstName$', eventRecord.Owner.FirstName) :  mailBody.replace('$OwnerFirstName$', '');
                
                mailBody = mailBody.containsIgnoreCase('$OwnerLastName$') && !String.isBlank(eventRecord.Owner.LastName) ?
                    mailBody.replace('$OwnerLastName$', eventRecord.Owner.LastName) : mailBody.replace('$OwnerLastName$', '');
                
                mailBody = mailBody.containsIgnoreCase('$MeetingNotes$') && !String.isBlank(eventRecord.Meeting_Notes_External__c) ?
                    mailBody.replace('$MeetingNotes$', eventRecord.Meeting_Notes_External__c) : mailBody.replace('$MeetingNotes$', '');
                
                mailBody = templateName.equalsIgnoreCase('ARTL_Event_Completed_With_SRNumber') && mailBody.containsIgnoreCase('$FTRNumber$')
                  && !String.isBlank(eventRecord.SR_FTR_Number__c) ? mailBody.replace('$FTRNumber$', eventRecord.SR_FTR_Number__c) : mailBody.replace('$FTRNumber$', '');
                
                mailBody = mailBody.replace(']]>', '');                
            }
            input.put('message', mailBody);
            input.put('invoiceNo', 'Mail_through_DIRS');
            input.put('accountNo', 'Mail_through_DIRS');
            input.put('custNo', 'Mail_through_DIRS');
            input.put('subject', emailTemplate.Subject);
            input.put('ccList', '');
            input.put('toList', toList);
            
            String submitresult = JSON.serialize(vlocity_cmt.IntegrationProcedureService.runIntegrationProcedureQueueable('ARTL_MailThroughDIRS', 
						input, output));
            System.debug('submitresult>>>'+submitresult);
        }
        catch(Exception ex){
            System.debug('DEBUGG Exception '+ ex.getLineNumber()+' '+ex.getMessage());
        }
    }

    public class FlowInput{
        @InvocableVariable(required=true) public List<String> toList;
        @InvocableVariable(required=true) public String templateName;
        @InvocableVariable(required=true) public String eventId;
    }
}