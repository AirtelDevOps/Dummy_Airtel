global with sharing class ARTL_CreateInflightCancelOrder {
    @InvocableMethod(label = 'Calling Order Cancel IP')
    global static List <IntegrationProcedureOutput> runIntegrationServiceInvocable(List < IntegrationProcedureInput > input) {
        System.debug(LoggingLevel.Error, JSON.serialize(input));
        IntegrationProcedureOutput result = new IntegrationProcedureOutput();
        System.debug('input'+input);
        /*result.output = JSON.serialize(
            vlocity_cmt.IntegrationProcedureService.runIntegrationService(
                input[0].procedureAPIName,
                new Map < String, Object >
                {
                    'cartId' => input[0].input
                        
				},
                new Map < String, Object > ()));
        System.debug('Input'+input[0].input);
        System.debug(LoggingLevel.Error, JSON.serialize(result));
        system.debug('Result:'+JSON.serialize(result));
        system.debug(JSON.serialize(result.output));
        
        Map<String,Object> mapitemJsonObjectList = (Map<String,Object>)JSON.deserializeUntyped(result.output);
        system.debug('mapitemJsonObjectList:'+mapitemJsonObjectList);
        system.debug('CreateSupplementalOrder>>>>:'+mapitemJsonObjectList.get('CreateSupplementalOrder'));
        if(mapitemJsonObjectList.get('CreateSupplementalOrder') != null && mapitemJsonObjectList.get('CreateSupplementalOrder') != ''){
            Map<String,Object> itemJsonObjectList = (Map<String,Object>) mapitemJsonObjectList.get('CreateSupplementalOrder'); 
            system.debug('itemJsonObjectList:'+itemJsonObjectList);
            List<Object> data2 = (List<Object>) itemJsonObjectList.get('records');
            if(data2.size() > 0){
                Map<String,Object> checkdata = (Map<String,Object>) data2[0]; 
                
                System.debug('data2>>>>'+(String)(checkdata.get('supplementalOrderId')));
                if(checkdata.containsKey('supplementalOrderId') && (String)(checkdata.get('supplementalOrderId')) != null){
                    vlocity_cmt.IntegrationProcedureService.runIntegrationProcedureQueueable('b2bExpress_SubmitSubOrder', 
                        new Map < String, Object >
                    {
                        'ContextId' => (String)(checkdata.get('supplementalOrderId'))
                            
                    }, new Map < String, Object > ());
                }
            }
        }*/
        
        return new List < IntegrationProcedureOutput >
        {
			result
		};
            
            
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