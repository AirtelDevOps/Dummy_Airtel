/**
 * Description: Used as Handler class of Quote Member Trigger based on the trigger framework
 * Author: Salesforce (Sagar)
 */
public class ARTL_QuoteMemberTriggerHandler extends TriggerHandler {
    
    private Map<Id, vlocity_cmt__QuoteMember__c> oldMap;

    public override void beforeInsert() {
        //KB: filtering QMs for Pincode Master Validation -- start
        List<vlocity_cmt__QuoteMember__c> pincodeValQMList = new List<vlocity_cmt__QuoteMember__c>();
        for(vlocity_cmt__QuoteMember__c qm : (List<vlocity_cmt__QuoteMember__c>) Trigger.new){
            if(qm.vlocity_cmt__PostalCode__c != null && qm.vlocity_cmt__City__c != null && qm.vlocity_cmt__State__c != null){
                pincodeValQMList.add(qm);
            }
        }
        if(!pincodeValQMList.isEmpty()){
            ARTL_QuoteMemberTriggerHelper.pincodeValidation(pincodeValQMList);
        }
        
        //KB: filtering QMs for Pincode Master Validation -- end
    }

    public override void afterInsert() {
        System.debug('QuoteMember After Insert');
          List<vlocity_cmt__QuoteMember__c> pincodeValQMList = new List<vlocity_cmt__QuoteMember__c>();
          for(vlocity_cmt__QuoteMember__c qm : (List<vlocity_cmt__QuoteMember__c>) Trigger.new){
              if(qm.vlocity_cmt__PostalCode__c != null && qm.vlocity_cmt__City__c != null && qm.vlocity_cmt__State__c != null){
                  pincodeValQMList.add(qm);
              }
          }
          if(!pincodeValQMList.isEmpty()){
              ARTL_QuoteMemberTriggerHelper.updateAddressAndFeasibilityStatusPinValidation(pincodeValQMList);
          }
    }


    public override void beforeUpdate() {
        this.oldMap = (Map<Id, vlocity_cmt__QuoteMember__c>) Trigger.oldMap;
        
        //KB: filtering QMs for Pincode Master Validation -- start
        List<vlocity_cmt__QuoteMember__c> pincodeValQMList = new List<vlocity_cmt__QuoteMember__c>();
        for(vlocity_cmt__QuoteMember__c qm : (List<vlocity_cmt__QuoteMember__c>) Trigger.new){
            
            vlocity_cmt__QuoteMember__c oldQM =  this.oldMap.get(qm.id);
            if( (qm.vlocity_cmt__PostalCode__c != null && qm.vlocity_cmt__PostalCode__c != oldQM.vlocity_cmt__PostalCode__c) ||
                (qm.vlocity_cmt__City__c != null && qm.vlocity_cmt__City__c != oldQM.vlocity_cmt__City__c) ||
                (qm.vlocity_cmt__State__c != null && qm.vlocity_cmt__State__c != oldQM.vlocity_cmt__State__c)
            ){
                pincodeValQMList.add(qm);
            }
        }
        if(!pincodeValQMList.isEmpty()){
            ARTL_QuoteMemberTriggerHelper.pincodeValidation(pincodeValQMList);
        }
        //KB: filtering QMs for Pincode Master Validation -- end

        //KB: Filtering QMs for populate Address Validation Result -- start
        List<vlocity_cmt__QuoteMember__c> addValidQMList = new List<vlocity_cmt__QuoteMember__c>();
        for(vlocity_cmt__QuoteMember__c qm : (List<vlocity_cmt__QuoteMember__c>) Trigger.new){
            vlocity_cmt__QuoteMember__c oldQM = this.oldMap.get(qm.id);
            
            if(qm.ARTL_Feasibility_Error_Margin__c != null && qm.ARTL_Feasibility_Error_Margin__c != oldQM.ARTL_Feasibility_Error_Margin__c){
                addValidQMList.add(qm);
            }
        }
        if(!addValidQMList.isEmpty()){
            ARTL_QuoteMemberTriggerHelper.updateAddressValidationResult(addValidQMList);
        }
        //KB: Filtering QMs for populate Address Validation Result -- end
    
    }
    public override void afterUpdate() {
        this.oldMap = (Map<Id, vlocity_cmt__QuoteMember__c>) Trigger.oldMap;
        
        //KB: filtering QMs for Address And Feasibility Status update -- start
        List<vlocity_cmt__QuoteMember__c> pincodeValQMList = new List<vlocity_cmt__QuoteMember__c>();
        List<vlocity_cmt__QuoteMember__c> addValidQMList = new List<vlocity_cmt__QuoteMember__c>();
        for(vlocity_cmt__QuoteMember__c qm : (List<vlocity_cmt__QuoteMember__c>) Trigger.new){
            
            vlocity_cmt__QuoteMember__c oldQM =  this.oldMap.get(qm.id);
            if( (qm.vlocity_cmt__PostalCode__c != null && qm.vlocity_cmt__PostalCode__c != oldQM.vlocity_cmt__PostalCode__c) ||
                (qm.vlocity_cmt__City__c != null && qm.vlocity_cmt__City__c != oldQM.vlocity_cmt__City__c) ||
                (qm.vlocity_cmt__State__c != null && qm.vlocity_cmt__State__c != oldQM.vlocity_cmt__State__c)
            ){
                pincodeValQMList.add(qm);
            }
            if(qm.ARTL_Feasibility_Error_Margin__c != null && qm.ARTL_Feasibility_Error_Margin__c != oldQM.ARTL_Feasibility_Error_Margin__c){
                addValidQMList.add(qm);
            }
        }
        if(!pincodeValQMList.isEmpty()){
            ARTL_QuoteMemberTriggerHelper.updateAddressAndFeasibilityStatusPinValidation(pincodeValQMList);
        }
        if(!addValidQMList.isEmpty()){
            ARTL_QuoteMemberTriggerHelper.updateAddressAndFeasibilityStatusAddValidation(addValidQMList);
        }
        //KB: filtering QMs for Address And Feasibility Status update -- end

    }
  
    
  }