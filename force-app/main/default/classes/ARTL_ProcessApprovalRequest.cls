global class ARTL_ProcessApprovalRequest implements vlocity_cmt.VlocityOpenInterface {
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){
        try
        {         
            System.debug('invokeMethod.methodName'+methodName);
            if(methodName.equalsIgnoreCase('submitForOVApproval')){
                return submitForOVApproval(input, output, options);
            }
            else if(methodName.equalsIgnoreCase('approveOVApproval')){
                approveOVApproval(input, output, options);
            }
            else{
                output.put('Error', 'Unsupported method name: ' + methodName);
            } 
            return true;
        }
        catch (Exception ex){         
            System.debug('Exception thrown at invoke ' + methodName + 'msg--'+ex.getMessage());
            System.debug('Exception trace at invoke ' + ex.getStackTraceString());
            output.put('error', ex.getMessage());
            return false;
        }      
    }
    
    private static Boolean submitForOVApproval(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap){        
        // Create an approval request
        Id quoteId       = (Id)inputMap.get('QuoteId');
        Id publicGroupId = (Id)inputMap.get('PublicGroupId');
        Id opportunityId = (Id)inputMap.get('OpportunityId');
        
        System.debug('submitForOVApproval inputMap'+JSON.serializePretty(inputMap));
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        req.setComments('Submitting approval request');        
        req.setObjectId(quoteId);
        req.setProcessDefinitionNameOrId('Submit_For_OV_Approval');
        req.setSkipEntryCriteria(true);
        
        // Submit the approval request
        Approval.ProcessResult result = Approval.process(req); 
        System.debug('submitForOVApproval submitForApproval.result'+JSON.serializePretty(result));
        if(result.success == true){
            OpportunityShare oppShr  = new OpportunityShare();
            oppShr.OpportunityId = opportunityId;
            oppShr.UserOrGroupId = publicGroupId;
            oppShr.OpportunityAccessLevel = 'Edit';
            oppShr.RowCause = Schema.OpportunityShare.RowCause.Manual;
            
            Database.SaveResult sr = Database.insert(oppShr,false); 
        }
        
        outputMap.put('SubmitApprovalStatus',result.success);
        return true;      
    }
    private static Boolean approveOVApproval(Map<String,Object> input, Map<String,Object> output, Map<String,Object> option){
        String quoteId = input.containsKey('QuoteId')? String.valueOf(input.get('QuoteId')) : '';
        String Status = input.containsKey('Status')? String.valueOf(input.get('Status')) : 'Reject';
        String Remark = input.containsKey('Remark')? String.valueOf(input.get('Remark')) : '';
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments(Remark);
        req2.setAction(Status);
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        Id workItemId;
        
        for(ProcessInstanceWorkitem workItem  : [SELECT p.Id FROM ProcessInstanceWorkitem p
                                                 WHERE p.ProcessInstance.TargetObjectId =: quoteId]){
                                                    if(workItem.actorId == UserInfo.getUserId()){
                                                        workItemId  =  workItem.Id;
                                                    }
                                                 }
        System.debug('workItemId '+workItemId);
        if(workItemId != null){
            req2.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result2 =  Approval.process(req2);
            output.put('ApproveStatus','success'); 
        }
        else{
            output.put('ApproveStatus','failed'); 
        }
        return true;   
    }
    
    
}