trigger ARTL_OrderTrigger on Order (after insert) {
    if(Trigger.isAfter && Trigger.isInsert) {        
        ARTL_OrderTriggerHandler.afterInsert(Trigger.new);
    }
}