trigger ContactPremiseRelation on ContactPremiseRelation__c (before insert, before update, after insert, after update, after delete) {

    if((Trigger.isAfter && Trigger.isInsert && !trigger.new.isEmpty()) || 
          (Trigger.isAfter && Trigger.isUpdate && !trigger.new.isEmpty())||(Trigger.isBefore && Trigger.isInsert && !trigger.new.isEmpty())){
        new ContactPremiseRelationTriggerHandler().run();
    }
    if(trigger.isBefore && trigger.isUpdate){
        Map<Id, ContactPremiseRelation__c> contactPremiseRelationOldMap = trigger.oldMap;
        for(ContactPremiseRelation__c relation : trigger.new){
            if(!ARTL_UpdateBcpDcpLwcController.isUpdateBcpDcp && 
               (relation.Role__c != contactPremiseRelationOldMap.get(relation.Id).Role__c ||
                relation.ARTL_Standard_Reason__c != contactPremiseRelationOldMap.get(relation.Id).ARTL_Standard_Reason__c)){
                    Relation.addError('Please use Edit button to edit the BCP/DCP Contact Premise Relation record.');
                }
        }
    }
}