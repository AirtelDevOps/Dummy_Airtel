/******************************************************************************************************
* @Author:      Prabanch  <prabhanch.nath@salesforce.com >
* @Company:     Salesforce
* @Date:        13th Feb 2024
* @Reviewer:
* @Review Date:
* @Description: This utility is used for Attribute Validation feature.
* ++++++++++++++++++++++ Changes Implemented / Modification Log ++++++++++++++++++++++++++++++++++++++
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1. SFDC-                              
*******************************************************************************************************/


global class ARTL_ValidateESMQuoteAttField implements vlocity_cmt.VlocityOpenInterface{
    
    
    public  static  string quoteId  = '';
    public static List<vlocity_cmt__QuoteLineItemRelationship__c> qlirList;

    public static String qliFieldString='';
    public static set<String> fieldSetForQLI ;

    public static List<String> rootSourceTargetProdList;
   
    private static final string VALIDATE_ATTRIBUTE  = 'validateAttribute';



    public boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){
        try
        {      
            if(methodName.equalsIgnoreCase(VALIDATE_ATTRIBUTE)){
                return invokeAttrValidation(input, output, options);
            } 
              
        }
        catch (Exception ex){         
            System.debug('Exception thrown at invoke ' + methodName + 'msg--'+ex.getMessage());
            System.debug('Exception trace at invoke ' + ex.getStackTraceString());
            output.put('error', ex.getMessage());
        }      
        return false;
    }

    public static boolean invokeAttrValidation(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> optionsMap){


        try{
            quoteId = (String)inputMap.get('quoteId');
        Map<String,Map<String, Artl_ReliesOnValidations__mdt>> rootSourceTargetMdtMap = getAttValidationMdt();
        if((!rootSourceTargetMdtMap.isEmpty()) && (quoteId != '') && (qliFieldString != '')){
            //invoke batch
           System.debug('rootSourceTargetMdtMap--->'+rootSourceTargetMdtMap);
           System.debug('quoteId--->'+quoteId);
           System.debug('qliFieldString--->'+qliFieldString);
           
           Database.executeBatch(new ReliesOnAttributeFieldValidationBatch(rootSourceTargetMdtMap, quoteId, qliFieldString, null), 1);
        }
        else if(quoteId == ''){
            outputMap.put('errorMsg','No quoteId is passed');
            return false;
        }
        else if(rootSourceTargetMdtMap.isEmpty() && quoteId != ''){
            Quote updateStatus = new Quote(
                Id = quoteId,
                ARTL_ReliesOnValidationError__c ='' , 
                ARTL_ValidateAttributeFieldStatus__c ='Success'
            );
            outputMap.put('isEmptyMetadata',true);
            update updateStatus;
        }

        
        
        }
        catch (Exception ex){         
            outputMap.put('errorMsg', ex.getMessage());
            
        }  
        return true;
        
    }




    public static Map<String,Map<String, Artl_ReliesOnValidations__mdt>> getAttValidationMdt() {
    
        Map<String, Artl_ReliesOnValidations__mdt> attValidationMapRet = new Map<String, Artl_ReliesOnValidations__mdt>();

        List<String> fieldListVal; 
        Set<String> fieldSetVal = new Set<String>();

        Map<String,Map<String, Artl_ReliesOnValidations__mdt>> rootSourceTargetMdt= new Map<String,Map<String, Artl_ReliesOnValidations__mdt>>();  
        List<Artl_ReliesOnValidations__mdt> mcs = Artl_ReliesOnValidations__mdt.getAll().values();


        for(Artl_ReliesOnValidations__mdt mdtObj : mcs){
            fieldListVal =  new List<String>();
            if(!String.isBlank(mdtObj.FieldJson__c)){
                fieldListVal =(mdtObj.FieldJson__c).split(',');
                fieldSetVal.addAll(fieldListVal);
            }
            system.debug('qliFieldString '+qliFieldString);
            attValidationMapRet.put(mdtObj.Source_Target_Product__c, mdtObj);

            rootSourceTargetMdt.put(mdtObj.Root_Source_Target_Product__c,attValidationMapRet);
        }
        if(fieldSetVal != null){
            fieldSetVal.remove('Id');
            fieldSetVal.remove('Product2.Name');
            fieldSetVal.remove('Product2.ProductCode');
            fieldSetVal.remove('vlocity_cmt__AttributeSelectedValues__c');
            fieldSetVal.remove('vlocity_cmt__RootItemId__c');
            fieldSetForQLI  =new set<String> ();
            fieldSetForQLI = fieldSetVal;
            qliFieldString = fieldSetVal.toString();
            qliFieldString =qliFieldString.replace('{', ',');
            qliFieldString =qliFieldString.replace('}', ' ');
        }
        
        /*
            String qliQuery = 'Select Id '+qliFieldString +'from quoteLineItem Limit 1';
            System.debug('qliQuery $$'+qliQuery);
            QuoteLineItem qli = Database.query(qliQuery);

        */
        
        
            return rootSourceTargetMdt;
    }
    
}