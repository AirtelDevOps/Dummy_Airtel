trigger ContractTrigger on Contract (before insert, after update,after insert) {
    if(Trigger.isBefore && Trigger.isInsert && !trigger.new.isEmpty()){
        new ContractTriggerHandler().run();
    }
     if(Trigger.isAfter && Trigger.isInsert && !trigger.new.isEmpty()){
        new ContractTriggerHandler().run();
    }
    
     if(Trigger.isAfter && Trigger.isUpdate && !trigger.new.isEmpty() && !trigger.oldMap.isEmpty()){
        new ContractTriggerHandler().run();
    }
    
    
}