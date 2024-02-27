/**
* @Description: Class to implement the trigger helper for Quote Member Object
* @Author:  Salesforce (Sagar)
* @CreatedDate: 6th Dec 2023
*/
public with Sharing class ARTL_QuoteMemberTriggerHelper {
    
    private static final String PIN_INVALID = 'Invalid';
    private static final String PIN_VALID = 'Valid';
    
    
    /**
     * Name: updateAddressValidationResult
     * Description: used to update address validation result based on the error margin
     * Author: Sagar Sadhnani
     */
    public static void updateAddressValidationResult(List<vlocity_cmt__QuoteMember__c> addValidQMList) {
        for(vlocity_cmt__QuoteMember__c qm : addValidQMList){
            qm.vlocity_cmt__AddressValidationResult__c = (qm.ARTL_Feasibility_Error_Margin__c < 26 ? 'Valid' : ( qm.ARTL_Feasibility_Error_Margin__c < 50 ? 'Partial' : 'Invalid'));
            
        }
    }

    /**
     * Name: pincodeValidation
     * Description: used to validation address from pincode master table
     * Author: Sagar Sadhnani
     */
    public static void pincodeValidation(List<vlocity_cmt__QuoteMember__c> pincodeValQMList) {
        system.debug('pincodeValQMList=>'+JSON.serializePretty(pincodeValQMList));
        if(!pincodeValQMList.isEmpty()){
            
            Set<String> qmPincodes = new Set<String>();
            /*Set<String> qmCities = new Set<String>();
            Set<String> qmStates = new Set<String>();*/
            Map<String, Map<String, String>> pinCityStateMap = new Map<String, Map<String, String>>();

            for(vlocity_cmt__QuoteMember__c qm : pincodeValQMList){
                qmPincodes.add(qm.vlocity_cmt__PostalCode__c);
                /*qmCities.add(qm.vlocity_cmt__City__c);
                qmStates.add(qm.vlocity_cmt__State__c);*/
            }
            if(!qmPincodes.isEmpty()){
                for(ARTL_Pincode__c pincode: [SELECT name, ARTL_City__c, ARTL_State__c FROM ARTL_Pincode__c WHERE name IN: qmPincodes]){
                    
                    if(pincode.ARTL_City__c != null && pincode.ARTL_State__c != null){
                        
                        Map<String, String> cityStateMap = new Map<String, String>();
                        if(pinCityStateMap.containsKey(pincode.name)){
                            cityStateMap = pinCityStateMap.get(pincode.name);
                        }
                        cityStateMap.put(pincode.ARTL_City__c, pincode.ARTL_State__c);
                        pinCityStateMap.put(pincode.name, cityStateMap);
                    }
                }
                //if(!pinCityStateMap.isEmpty()){
                    for(vlocity_cmt__QuoteMember__c qm : pincodeValQMList){
                        if(pinCityStateMap.containsKey(qm.vlocity_cmt__PostalCode__c)){
                            if(pinCityStateMap.get(qm.vlocity_cmt__PostalCode__c).containsKey(qm.vlocity_cmt__City__c)){
                                if(pinCityStateMap.get(qm.vlocity_cmt__PostalCode__c).get(qm.vlocity_cmt__City__c).equalsIgnoreCase(qm.vlocity_cmt__State__c)){
                                    
                                    qm.ARTL_Pincode_Validation_Result__c = PIN_VALID;
                                    qm.ARTL_Pincode_Validation_Error__c = '';
                                }else{
                                    qm.ARTL_Pincode_Validation_Result__c = PIN_INVALID;
                                    qm.ARTL_Pincode_Validation_Error__c = System.Label.QM_PinCityState_Validate_Error;
                                }
                            }else{
                                qm.ARTL_Pincode_Validation_Result__c = PIN_INVALID;
                                qm.ARTL_Pincode_Validation_Error__c = System.Label.QM_PinCity_Validate_Error;
                            }
                        }else{
                            qm.ARTL_Pincode_Validation_Result__c = PIN_INVALID;
                            qm.ARTL_Pincode_Validation_Error__c = System.Label.QM_Pin_Validate_Error;
                        }    
                    }
                //}
            }
        }
    }

       /**
     * Name: updateAddressAndFeasibilityStatus
     * Description: Update 'Address and Feasibility Status' to 'Address Uploaded' on Quote when pincode validation completed successfully for all the quote members
     * Author: Prakash Sahu
     */
    public static void updateAddressAndFeasibilityStatusPinValidation(List<vlocity_cmt__QuoteMember__c> pincodeValQMList) {
        Set< Id > quoteIdsSet = new Set< Id > ();
        for(vlocity_cmt__QuoteMember__c qM: pincodeValQMList){
            if(qM.vlocity_cmt__QuoteId__c != null){
                quoteIdsSet.add(qM.vlocity_cmt__QuoteId__c);
            }
        }
        List< Quote > quoteList = new List < Quote > ();
        if(quoteIdsSet != null && quoteIdsSet.size() > 0){
           quoteList = [select id, Name,ARTL_Address_and_Feasibility_Status__c,  (Select id,ARTL_Pincode_Validation_Result__c from vlocity_cmt__QuoteMembers__r where ARTL_Pincode_Validation_Result__c  = 'Invalid' limit 1 ) from Quote where id In:  quoteIdsSet];
        }
        List< Quote > quoteListToUpdate = new List< Quote > ();
        if(quoteList != null && quoteList.size() >0){
            for(Quote qI : quoteList){
                Quote qIToUpdate = new Quote();
                qIToUpdate.Id = qI.Id;
                if(qI.vlocity_cmt__QuoteMembers__r != null && qI.vlocity_cmt__QuoteMembers__r.size() > 0){
                    if(qI.ARTL_Address_and_Feasibility_Status__c != 'None'){
                        qIToUpdate.ARTL_Address_and_Feasibility_Status__c = 'None';
                        quoteListToUpdate.add(qIToUpdate);
                    }
                   
                }else{
                    if(qI.ARTL_Address_and_Feasibility_Status__c != 'Address Uploaded'){
                        qIToUpdate.ARTL_Address_and_Feasibility_Status__c = 'Address Uploaded';
                        quoteListToUpdate.add(qIToUpdate);
                    }
                }
            }
        }
        if(quoteListToUpdate !=null && quoteListToUpdate.size() > 0 ){
            update quoteListToUpdate;
        }
    }

        /**
     * Name: updateAddressAndFeasibilityStatus
     * Description: Update 'Address and Feasibility Status' to 'Coordinate Validations Completed' on Quote when Address validation completed successfully for all the quote members
     * Author: Prakash Sahu
     */
    public static void updateAddressAndFeasibilityStatusAddValidation(List<vlocity_cmt__QuoteMember__c> addValidQMList) {
        Set< Id > quoteIdsSet = new Set< Id > ();
        for(vlocity_cmt__QuoteMember__c qM: addValidQMList){
            if(qM.vlocity_cmt__QuoteId__c != null){
                quoteIdsSet.add(qM.vlocity_cmt__QuoteId__c);
            }
        }
        List< Quote > quoteList = new List < Quote > ();
        if(quoteIdsSet != null && quoteIdsSet.size() > 0){
           quoteList = [select id, Name,ARTL_Address_and_Feasibility_Status__c,  (Select id,ARTL_Pincode_Validation_Result__c from vlocity_cmt__QuoteMembers__r where ARTL_Feasibility_Error_Margin__c  = null limit 1 ) from Quote where id In:  quoteIdsSet];
        }
        List< Quote > quoteListToUpdate = new List< Quote > ();
        if(quoteList != null && quoteList.size() >0){
            for(Quote qI : quoteList){
                Quote qIToUpdate = new Quote();
                qIToUpdate.Id = qI.Id;
                if(qI.vlocity_cmt__QuoteMembers__r != null && qI.vlocity_cmt__QuoteMembers__r.size() > 0){
                    if(qI.ARTL_Address_and_Feasibility_Status__c != 'Address Uploaded'){
                        qIToUpdate.ARTL_Address_and_Feasibility_Status__c = 'Address Uploaded';
                        quoteListToUpdate.add(qIToUpdate);
                    }
                   
                }else{
                    if(qI.ARTL_Address_and_Feasibility_Status__c != 'Coordinate Validations Completed'){
                        qIToUpdate.ARTL_Address_and_Feasibility_Status__c = 'Coordinate Validations Completed';
                        quoteListToUpdate.add(qIToUpdate);
                    }
                }
            }
        }
        if(quoteListToUpdate !=null && quoteListToUpdate.size() > 0 ){
            update quoteListToUpdate;
        }
    }

}