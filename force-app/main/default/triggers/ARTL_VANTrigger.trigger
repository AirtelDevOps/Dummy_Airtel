trigger ARTL_VANTrigger on ARTL_VAN_AccountNumbers__c (after Insert) { //,before Insert
    if(Trigger.isInsert && Trigger.isAfter && !trigger.new.isEmpty()){ // Trigger.isInsert && Trigger.isBefore && !trigger.new.isEmpty()
        new ARTL_VANTriggerHandler().run();
    }
}