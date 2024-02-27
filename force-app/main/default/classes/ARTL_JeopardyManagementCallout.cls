/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ARTL_JeopardyManagementCallout
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Akshay Kaushik    <akshay.kaushik@salesforce.com>
* @modifiedBy     Akshay Kaushik    <akshay.kaushik@salesforce.com>
* @maintainedBy   Akshay Kaushik    <akshay.kaushik@salesforce.com>
* @version        1.0
* @created        20-10-2023
* @modified       YYYY-MM-DD
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* 1.0             akshay.kaushik@salesforce.com
* 2023-10-04      Created the class to call the IPs and made call to Hansen when required. 
*.                 
*				  
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
global with sharing class ARTL_JeopardyManagementCallout {
    @InvocableMethod(label = 'Calling Jeopardy IPs')
    global static List <IntegrationProcedureOutput> runIntegrationServiceInvocable(List < IntegrationProcedureInput > input) {
    //global static void runIntegrationServiceInvocable(List < IntegrationProcedureInput > input) {
      
        System.debug(LoggingLevel.Error, JSON.serialize(input));
        List < IntegrationProcedureOutput > outputList = new List < IntegrationProcedureOutput > ();
        for (IntegrationProcedureInput i : input) {
            IntegrationProcedureOutput result = new IntegrationProcedureOutput();
            result.output = JSON.serialize(
                vlocity_cmt.IntegrationProcedureService.runIntegrationService(
                    i.procedureAPIName,
                    new Map < String, Object > {
                        'Id' => i.input
                    },
                    new Map < String, Object > ()
                )
            );
            outputList.add(result);
        }
        return outputList;
    }
    global class IntegrationProcedureInput
    {
        @InvocableVariable(label = 'Procedure Name') global String procedureAPIName;
        @InvocableVariable(label = 'Input') global String input;
    }
    global class IntegrationProcedureOutput
    {
        @InvocableVariable(label = 'Output') global String output;
         
    }
}