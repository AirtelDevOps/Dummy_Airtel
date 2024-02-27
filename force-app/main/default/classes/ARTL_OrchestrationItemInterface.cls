/************************************************************************************************************************************************************************************************************
 * @Author       : Abinash Barik <abinash.barik@salesforce.com>
 * @Company      : Salesforce (SFI)
 * @Date         : 09/10/2023
 * @Test Class   : ARTL_OrchestrationItemInterfaceTest
 * @Description  : 
 *
 * ----------------------- Changes Implemented / Modification Log --------------------------------------
 * UserStory / Defect      Developer             Date           Comment
 * ------------------      ---------------       -----------    ----------------------------------------
 * 1. SFDC-686              Abinash Barik         09/10/2023     Initial Dev
 ******************************************************************************************************************************************************************************************************************/
global class ARTL_OrchestrationItemInterface extends vlocity_cmt.DefaultSystemInterface {
    public static String PROCESS_NAME = 'processName';
    public static String RECORD_ID = 'ContextId';
    global override void executeItem(String url, String path, vlocity_cmt__OrchestrationItem__c item) {
        Map < String, Object > ipOutput = new Map < String, Object > ();
        Map < String, Object > ipInput = new Map < String, Object > ();
        try {
            ARTL_CalloutEventHandler obj = new ARTL_CalloutEventHandler();
            obj.invokeMethod('initiateCallout', new Map < String, Object > {
                PROCESS_NAME => item.vlocity_cmt__AutoTaskParameters__c,
                RECORD_ID => item.Id
            }, ipOutput, new Map < String, Object > ());
            Object Op = ipOutput.get('response');
            system.debug('output from hansen IP is = ' + ipOutput);
            ipInput.put('PROCESS_NAME', item.vlocity_cmt__AutoTaskParameters__c);
            ipInput.put('RECORD_ID', item.Id);


        } catch (Exception ex) {
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_OrchestrationItemInterface:initiateCalloutTrigger', '', new Map < String, Object > {
                'Exception' => ex.getMessage(),
                'LineNumber' => ex.getLineNumber()
            }, ex);
        }

        processResponse(item, ipInput, ipOutput);
    }
    /**
     * This method is called from executeItem to handle the response from the Integration Procedure.
     * By default it does nothing (but some logging), but it could be customized to do something more.
     *
     * @param item      The Orchestration Item
     * @param ipInput   The request sent to the Integration Procedure
     * @param ipOutput  The response from the Integration Procedure
     */
    global virtual void processResponse(vlocity_cmt__OrchestrationItem__c item, Map < String, Object > ipInput,
        Map < String, Object > ipOutput) {
        item.vlocity_cmt__Request__c = JSON.serialize(ipInput);
        item.vlocity_cmt__Response__c = JSON.serialize(ipOutput);

        if (ipOutput.containsKey('response')) {
            Map < String, Object > responseMap = (Map < String, Object > ) ipOutput.get('response');
            system.debug('output from hansen IP is = ' + responseMap);

            if (responseMap.containsKey('isSuccess')) {
                System.debug('Inside isSucess if');
                Boolean isSuccess = (Boolean) responseMap.get('isSuccess');
                system.debug('output from isSuccess is = ' + isSuccess);
                if (isSuccess == true) {
                    item.vlocity_cmt__State__c = 'Completed';
                } else {
                    //item.vlocity_cmt__State__c = 'Fatally Failed';

                    throw new vlocity_cmt.XOMOrchestrationInterfaces.SystemInterfaceRecoverableException('Error response, please check the response payload for more details');

                }
            } else {
                system.debug('output not found');
            }
        }

        update item;
        //system.debug('updated item = ' + item);
    }
}