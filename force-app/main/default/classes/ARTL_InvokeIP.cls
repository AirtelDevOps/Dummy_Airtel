/*
Author: Nesar M
Functionality: This apex class is used to invoke Integration Procedure which creates Party, NBA, VAN Accounts in FxIntegration System.
*/

public class ARTL_InvokeIP{
    
    public static void invokeIPOnAccCreation(Id recordId, String ipName){
        if(!String.isBlank(recordId) && !String.isBlank(ipName)) {
            callIntegrationProcedure(recordId,ipName);
        }
    }
    
    /**
* @description: callIntegrationProcedure
* @return: void
*/
    @future(callout=true)
    private static void callIntegrationProcedure(Id recordId, String ipName){
        try{
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        System.debug('recordId'+recordId);
        System.debug('ipName'+ipName);
        ipInput.put('recordId',recordId);
        if(!ipInput.isEmpty()){
            ipOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(ipName, ipInput, (new Map<string, object>()));
            System.debug('ipOutput'+ipOutput);
        } 
    }catch(Exception ex){
        System.debug('Invoke IP 32');
        ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_InvokeIP:callIntegrationProcedure', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
    }
    }
    
    public without sharing class IntegrationProcedureQueueable implements Queueable, Database.AllowsCallouts {
        Map<String, Object> input;
        Map<String, Object> options;
        Map<String, Object> output;
        String ipName;
        List<Id> vanId;
        
        public IntegrationProcedureQueueable(List<Id> vanId,String ipName, Map<String, Object> input,Map<String, Object> output, Map<String, Object> options) {
            this.vanId = vanId;
            this.ipName = ipName;
            this.input = input;
            this.output = output;
            this.options = options;
        }
        
        public void execute(QueueableContext context) {
            System.debug(vanId + ' Fresh List');
            Id vanRecordId;
            if(!vanId.IsEmpty()){
                vanRecordId = vanId[0];
			}
            System.debug(vanId+'VAN Record Ids inside Queueable');
            //Map<String, Object> ipInput = new Map<String, Object>();
            input.put('recordId',vanRecordId);
            String output = ARTL_InvokeIP.runIntegrationProcedure(ipName,input, output, options);
            vanId.remove(0);
            if(String.isNotBlank(output) && !vanId.isEmpty() && !Test.isRunningTest()){
                System.debug(output+'output of IP');
                input.clear();
                System.enqueueJob(new ARTL_InvokeIP.IntegrationProcedureQueueable(vanId,'ARTL_FXCreateVANAccount',input,(new Map<string, object>()),(new Map<string, object>())),1);  
            }
        }
    }
    
    public static string runIntegrationProcedure(String ipName, Map < String, Object > input, Map < String, Object > outMap, Map < String, Object > options){
    	 Map<String,Object> ipOutput = new Map<String,Object>();
        ipOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(ipName, input, (new Map<string, object>()));
    	String output = new List<String> ( ipOutput.keyset() )[0];
        return output;
    }
}