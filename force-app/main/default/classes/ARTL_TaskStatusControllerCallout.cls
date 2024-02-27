global  with sharing class ARTL_TaskStatusControllerCallout {
 @InvocableMethod(label = 'check Task Status')
    global static List <IntegrationProcedureOutput> runIntegrationServiceInvocable(List <IntegrationProcedureInput> input) {
        System.debug(LoggingLevel.Error, JSON.serialize(input));
        IntegrationProcedureOutput result = new IntegrationProcedureOutput();
        Map <String, Object> objinput = new Map <String, Object>();
        if(input[0].OrderType == 'SUSPEND_ORDER'){
            objinput.put('OrderType','SUSPEND_ORDER');
            objinput.put('TaskId',input[0].recordId);
        }
        else if(input[0].OrderType == 'RESUME_ORDER'){
            objinput.put('OrderType','RESUME_ORDER');
            objinput.put('TaskId',input[0].recordId);
        }else{
            objinput.put('TaskId',input[0].recordId);
        }
        System.debug('input'+input);
        result.output = JSON.serialize(
            vlocity_cmt.IntegrationProcedureService.runIntegrationService(
                input[0].procedureAPIName,
                objinput,
                new Map < String, Object > ()));
        System.debug('Input'+input[0].recordId);
        System.debug(LoggingLevel.Error, JSON.serialize(result));
        system.debug('Result:'+result);
        return new List <IntegrationProcedureOutput>
        {
            result
		};
	}
    global class IntegrationProcedureInput
    {
        @InvocableVariable(label = 'Procedure Name') global String procedureAPIName;
        @InvocableVariable(label = 'recordId') global String recordId;
        @InvocableVariable(label = 'OrderType') global String OrderType;
    }
    global class IntegrationProcedureOutput
    {
        @InvocableVariable(label = 'Output') global String output;
    }
}