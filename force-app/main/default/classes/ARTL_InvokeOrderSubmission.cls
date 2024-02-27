/************************************************************************************************************************************************************************************************************
* @Author       : Abinash Barik <abinash.barik@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 09/12/2023
* @Test Class   : 
* @Description  : SFDC-2216 Auto Submit Order on PM Approval task
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1. SFDC-2216              Abinash Barik         09/10/2023     Initial Dev
******************************************************************************************************************************************************************************************************************/
global with sharing class ARTL_InvokeOrderSubmission {
	@InvocableMethod(label = 'Submit Order')
    global static List <IntegrationProcedureOutput> runIntegrationServiceInvocable(List < IntegrationProcedureInput > flowinput) {
        IntegrationProcedureOutput result = new IntegrationProcedureOutput();
        map<String,Object> input = new Map<String,Object>();
        map<String,Object> output = new Map<String,Object>();
        map<String,Object> options = new Map<String,Object>();
        
		input.put('ContextId', (String)(flowinput[0].recordId));
        List<OrderItem> lstItem = [SELECT vlocity_cmt__AssetReferenceId__c,Quantity,OrderId FROM OrderItem
                                         WHERE vlocity_cmt__ParentItemId__c = null 
                                   AND OrderId =: flowinput[0].recordId];
        if(!lstItem.isEmpty() && lstItem.size() == 1){
            vlocity_cmt.IntegrationProcedureService.runIntegrationProcedureQueueable('b2bExpress_SubmitSubOrder', 
						input, output);
        }
        
        return new List < IntegrationProcedureOutput >
        {
			result
		};
    }
    global class IntegrationProcedureInput
    {
        @InvocableVariable(label = 'Procedure Name') global String procedureAPIName;
        @InvocableVariable(label = 'Input') global String recordId;
    }
    global class IntegrationProcedureOutput
    {
        @InvocableVariable(label = 'Output') global String output;
    }
}