global with sharing class PricingVariableMapHookImplementation implements callable, vlocity_cmt.VlocityOpenInterface{
    
    global Object call(String action, Map<String, Object> args) {
        
        Map<String, Object> input = (Map<String, Object>)args.get('input');
        Map<String, Object> output = (Map<String, Object>)args.get('output');
        Map<String, Object> options = (Map<String, Object>)args.get('options');
        
        return invokeMethod(action, input, output, options);
    }
    
    global boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap) {
        Boolean result = true;
        
        //System.debug('PricingVariableMapHook invokeMethod: methodName: ' + methodName);
        
        
        if (methodName.equalsIgnoreCase('calculate.PostInvoke')) {
            //System.debug('Calling the update function');
            updateARC(inputMap, outputMap, optionsMap);
        } 
        else {
            result = false;
        }
        
        return result;
    }
    
    global void updateARC(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap){

        system.debug('Mtd in updateARC-->');
        SObject parent = (SObject) vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
        system.debug('Parent Data-->'+JSON.serialize(parent));
        //system.debug('Parent Type-->'+(String)parent.get('vlocity_cmt__Type__c'));
        Map<String, Object> priciingVariableMap = (Map<String, Object>)inputMap.get('pricingVariableMap');
        /*system.debug('After parent data-->');
        if((String)parent.get('vlocity_cmt__Type__c') == 'Demo'){
            system.debug('Demo Quote');
            Double OT_STD_PRC = 0.0;
            Double REC_YRLY_STD_PRC = 0.0;
            Double REC_MNTH_STD_PRC = 0.0;
            

            priciingVariableMap.put('OT_STD_PRC',OT_STD_PRC);
            priciingVariableMap.put('OT_STD_PRC_TOTAL',OT_STD_PRC);
            priciingVariableMap.put('REC_YRLY_STD_PRC',REC_YRLY_STD_PRC);
            priciingVariableMap.put('REC_YRLY_STD_PRC_TOTAL',REC_MNTH_STD_PRC);
            priciingVariableMap.put('REC_MNTH_STD_PRC',REC_MNTH_STD_PRC);
            priciingVariableMap.put('REC_MNTH_STD_PRC_TOTAL',REC_MNTH_STD_PRC);
        }
        else{  */  
            Double EFF_REC_YRLY_STD_PRC_TOTAL  = (Double)priciingVariableMap.get('REC_YRLY_STD_PRC');
            Double NEW_EFF_REC_YRLY_STD_PRC_TOTAL = EFF_REC_YRLY_STD_PRC_TOTAL = (Double)priciingVariableMap.get('REC_YRLY_STD_PRC') * (Double)priciingVariableMap.get('LINE_QUANTITY');
            
            Double REC_YRLY_STD_PRC_TOTAL  = (Double)priciingVariableMap.get('REC_YRLY_STD_PRC');
            Double NEW_REC_YRLY_STD_PRC_TOTAL = REC_YRLY_STD_PRC_TOTAL = (Double)priciingVariableMap.get('REC_YRLY_STD_PRC') * (Double)priciingVariableMap.get('LINE_QUANTITY');
            
            
            priciingVariableMap.put('REC_YRLY_STD_PRC_CALC',NEW_EFF_REC_YRLY_STD_PRC_TOTAL);
            
            NEW_REC_YRLY_STD_PRC_TOTAL = (NEW_EFF_REC_YRLY_STD_PRC_TOTAL +  (Double) priciingVariableMap.get('ROLLUP_REC_YRLY_STD_PRC_TOTAL')) * (Double)priciingVariableMap.get('LINE_QUANTITY');
            
            priciingVariableMap.put('REC_YRLY_STD_PRC_TOTAL',NEW_REC_YRLY_STD_PRC_TOTAL);
            
            //System.debug('NEW_REC_YRLY_STD_PRC_TOTAL'+NEW_REC_YRLY_STD_PRC_TOTAL);
            
            // Retrieve the isRoot flag from the input
            Boolean isRoot = (Boolean)inputMap.get('isRoot');
            //system.debug('isRoot=>'+isRoot);
            //system.debug('EFF_REC_YRLY_STD_PRC_TOTAL=>'+EFF_REC_YRLY_STD_PRC_TOTAL);
            // If this is the root, then set the EFF_REC_YRLY_STD_PRC_TOTAL of the line item to be the same as
            // REC_MNTH_STD_PRC_TOTAL value. EFF_REC_YRLY_STD_PRC_TOTAL participates in a rollup summary field in the parent header
            if (isRoot)
            {   
                
                //System.debug('Updating the Root Item'+inputMap.get('id'));
                //system.debug('Input for Root'+JSON.serialize(inputMap));
                EFF_REC_YRLY_STD_PRC_TOTAL = (Double)priciingVariableMap.get('REC_YRLY_STD_PRC_TOTAL');
                //system.debug('EFF_REC_YRLY_STD_PRC_TOTAL=>isRoot=>'+EFF_REC_YRLY_STD_PRC_TOTAL);
                
                priciingVariableMap.put('EFF_REC_YRLY_STD_PRC_TOTAL', EFF_REC_YRLY_STD_PRC_TOTAL);
                //system.debug('Updated Root'+priciingVariableMap.get('REC_YRLY_STD_PRC_TOTAL'));
                
            }
        //}
    }
}