public class CrcconfigureAttributeController {
    
    @AuraEnabled
    public static  List< AttributeWrapper > getJSONAttribute(Id recordId) {
        
        try{
            List<vlocity_cmt__ContractLineItem__c> CLIAttrList = getProductAttributes(recordId);
            if(CLIAttrList != null && CLIAttrList.size() > 0){
                List< ARTL_Customer_Rate_Card__mdt > cRCList = [Select id,ARTL_Attribute_JSON__c,ARTL_Product_Code__c	 from ARTL_Customer_Rate_Card__mdt where ARTL_Product_Code__c =: CLIAttrList[0].vlocity_cmt__Product2Id__r.ProductCode];
                List < String > appAttList = new List< String >();
                if(cRCList != null && cRCList.size() > 0){
                    Map< String, Object > attCodeValueMap = (Map< String, Object >)JSON.deserializeUntyped(cRCList[0].ARTL_Attribute_JSON__c);
                    appAttList.addAll(attCodeValueMap.keySet());
                }
                Map< String, Object > existingSAttMap;
                if(CLIAttrList[0].vlocity_cmt__AttributeSelectedValues__c != null){
                    existingSAttMap =  (Map< String, Object >)JSON.deserializeUntyped(CLIAttrList[0].vlocity_cmt__AttributeSelectedValues__c);
                }
                
                if(appAttList != null && appAttList.size() >0){
           
                    Map<String, Object> attMetadataMap = (Map<String, Object>)JSON.deserializeUntyped(CLIAttrList[0].vlocity_cmt__Product2Id__r.vlocity_cmt__AttributeMetadata__c);
                   // System.debug('attMetadataMap-----'+attMetadataMap);
                    List<Object> attCategoryList = new List<Object>();
                    attCategoryList =(List<Object>)attMetadataMap.get('records');
                   // system.debug('attCategoryList------'+attCategoryList);
                    Map<String, Object> attCategoryInstanceMap = new Map<String, Object>();
                    List< AttributeWrapper > attWrapperList = new List< AttributeWrapper >();  
                    for(Object aCL: attCategoryList){
                        attCategoryInstanceMap = (Map<String, Object>)aCL; 
                        
                        // system.debug('attCategoryInstanceMap---'+attCategoryInstanceMap);
                        // system.debug('Product Attribtues----'+attCategoryInstanceMap.get('productAttributes'));
                        Map< String, Object > prodAttMap = (Map< String, Object >)attCategoryInstanceMap.get('productAttributes');
                        // System.debug('prodAttMap---'+prodAttMap);
                        List< Object > attList = (List< Object > )prodAttMap.get('records');
                        // System.debug('attList---'+attList);
                        // System.debug('attList---0---'+attList[0]);
                        for(Object aL: attList){
                            
                            Map< String, Object > attInstanceMap = (Map< String, Object >)aL;
                            // System.debug('attInstanceMap---'+attInstanceMap.get('code'));
                            if(appAttList != null && appAttList.contains(String.valueOf(attInstanceMap.get('code')))){
                                
                                AttributeWrapper aW = new AttributeWrapper();
                                aW.name = String.valueOf(attInstanceMap.get('label'));
                                aW.code =   String.valueOf(attInstanceMap.get('code'));
                                aW.readonly = Boolean.valueOf(attInstanceMap.get('readonly'));
                                aW.text_color = 'slds-text-color_default';
                                aW.valueType = String.ValueOf(attInstanceMap.get('dataType'));
                                aW.is_picklist = attInstanceMap.get('inputType') == 'dropdown' ? true : false;
                                aW.is_input = attInstanceMap.get('inputType') == 'text' ? true : false;
                                aW.is_date = attInstanceMap.get('dataType') == 'date' ? true : false;    
                                aW.is_datetime = attInstanceMap.get('dataType') == 'datetime' ? true : false;
                                aW.is_number = attInstanceMap.get('dataType') == 'number' ? true : false;
                                aW.is_currency = attInstanceMap.get('dataType') == 'currency' ? true : false;
                                aW.is_percent = attInstanceMap.get('dataType') == 'percent' ? true : false;
                                aW.is_checkbox = attInstanceMap.get('dataType') == 'checkbox' ? true : false;
                                if(existingSAttMap != null && existingSAttMap.keySet().size() >0 && existingSAttMap.containsKey(String.valueOf(attInstanceMap.get('code')))){
                                    aW.value = existingSAttMap.get(String.valueOf(attInstanceMap.get('code')));
                                }
                                
                                
                                if(aW.is_picklist){
                                    List < cls_options > optionList = new List< cls_options >();
                                    if(attInstanceMap.get('values') != null ){
                                        List< Object > valList = (List< Object >)attInstanceMap.get('values');
                                        Map< Integer , Map< String, Object> > disSeqValMap = new Map< Integer , Map< String, Object> >();
                                        for(Object vL: valList){
                                            Map< String, Object > vLMap = (Map< String, Object >)vL;
                                            // System.debug('Label----'+vLMap.get('label'));
                                            disSeqValMap.put(Integer.ValueOf(vLMap.get('displaySequence')), vLMap);
                                        }
                                        List< Integer > disSeqList = new List< Integer >();
                                        disSeqList.addAll(disSeqValMap.keySet());
                                        disSeqList.sort();
                                        cls_options cOB = new cls_options();
                                        cOB.label = '';
                                        cOB.value = '';
                                        optionList.add(cOB);
                                        for( Integer disInt: disSeqList){
                                            cls_options cO = new cls_options();
                                            cO.label = String.valueOf(disSeqValMap.get(disInt).get('label'));
                                            cO.value = String.valueOf(disSeqValMap.get(disInt).get('value'));
                                            optionList.add(cO);
                                        }
                                        aW.options =  optionList;
                                    }
                                }
                                attWrapperList.add(aW);                               
                            }  
                        }
                    }
                    System.debug('attWrapperList---'+attWrapperList);
                    return attWrapperList;   
                }else{
                    System.debug('Metadta Not Found!');
                    return null;
                }
            }else{
                System.debug('CLI record no found.');
                return null;
            }

        }catch(Exception ex){
            System.debug('Exception Msg:--'+ex.getMessage()+' L No--'+ex.getLineNumber());
            return null;
        }
    }
    
    @AuraEnabled
    public static List<vlocity_cmt__ContractLineItem__c> getProductAttributes(String recordId){
        List<vlocity_cmt__ContractLineItem__c> lstProductAttr = new List<vlocity_cmt__ContractLineItem__c>();
        lstProductAttr = [select id,vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__Product2Id__r.vlocity_cmt__AttributeMetadata__c,
                          vlocity_cmt__Product2Id__r.vlocity_cmt__AttributeDefaultValues__c, vlocity_cmt__AttributeSelectedValues__c,
                          vlocity_cmt__Product2Id__r.vlocity_cmt__JSONAttribute__c,vlocity_cmt__AttributesData__c, vlocity_cmt__JSONAttribute__c
                          from vlocity_cmt__ContractLineItem__c 
                          WHERE Id =:recordId /*AND Quote_Line_Item__r.vlocity_cmt__ParentItemId__c =:recordId*/];
        
        return lstProductAttr;
    }
    
    @AuraEnabled
    public static String saveAttribute(String recordId, List< SelectedAttribute >  selectedAttJSON){
        try{
            System.debug('selectedAttJSON---'+selectedAttJSON);
            
            List<vlocity_cmt__ContractLineItem__c> CLIAttrList = getProductAttributes(recordId);
            if(CLIAttrList != null && CLIAttrList.size() >0){
                Map< String, Object > existingSAttMap;
                if(CLIAttrList[0].vlocity_cmt__AttributeSelectedValues__c != null){
                    existingSAttMap =  (Map< String, Object >)JSON.deserializeUntyped(CLIAttrList[0].vlocity_cmt__AttributeSelectedValues__c);
                }else{
                    existingSAttMap = new Map< String, Object > ();
                }
                if(selectedAttJSON != null && selectedAttJSON.size() > 0){
                    // List< Map< String, Object > > newAttValMap = (List< Map< String, Object > >)JSON.deserializeUntyped(String.valueOf(selectedAttJSON));
                    
                    for(SelectedAttribute sA : selectedAttJSON){
                        if(sA.valueSelected == '' && existingSAttMap != null && existingSAttMap.containsKey(sA.attCode)){
                            existingSAttMap.remove(sA.attCode);
                        }else{
                            if(sA.valueSelected != '')
                                existingSAttMap.put(sA.attCode,sA.valueSelected);
                        } 
                    }
                    System.debug('existingSAttMap----'+existingSAttMap);
                    System.debug('existingSAttMap-  serialize---'+JSON.serialize(existingSAttMap));
                    vlocity_cmt__ContractLineItem__c vCLI = new vlocity_cmt__ContractLineItem__c();
                    vCLI.Id = recordId;
                    vCLI.vlocity_cmt__AttributeSelectedValues__c = JSON.serialize(existingSAttMap);
                    update vCLI;
                }
            }  
            return 'success';
        }catch(Exception ex){
            System.debug(' Exception saveAttribute Msg----'+ex.getMessage()+' L No:- '+ex.getLineNumber());
            return ex.getMessage();
        }
        
    }
    public class SelectedAttribute{
        @AuraEnabled public String attCode { get; set; }
        @AuraEnabled public String valueSelected { get; set; }
        
    }
    
    public class AttributeWrapper {
        @AuraEnabled public String name;	//Contract Term
        @AuraEnabled public String code;	//ATT_CONTRACT_TERM
        @AuraEnabled public boolean readonly;
        @AuraEnabled public String text_color;	//slds-text-color_default
        @AuraEnabled public String valueType;	//text
        @AuraEnabled public boolean is_changed;
        @AuraEnabled public boolean is_picklist;
        @AuraEnabled public boolean is_input;
        @AuraEnabled public boolean is_date;
        @AuraEnabled public boolean is_datetime;
        @AuraEnabled public boolean is_number;
        @AuraEnabled public boolean is_currency;
        @AuraEnabled public boolean is_percent;
        @AuraEnabled public boolean is_checkbox;
        @AuraEnabled public Object value;
        @AuraEnabled public cls_options[] options;
    }
    public class cls_options {
        @AuraEnabled public String label;	//
        @AuraEnabled public String value;
    }
   
}