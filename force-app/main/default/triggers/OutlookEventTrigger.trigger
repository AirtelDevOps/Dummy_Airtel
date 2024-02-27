trigger OutlookEventTrigger on Event (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        OutlookEventTriggerHandler.handleAfterInsert(Trigger.new);
    }
}