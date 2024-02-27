/*
 * Author: Nesar M
 * Functionality: This trigger calls Fx IP when NBA, Party account is inserted into Databased.
*/
trigger ARTL_AccountTrigger on Account (after insert, after update, before insert,before update) {
    if((Trigger.isAfter && Trigger.isInsert && !trigger.new.isEmpty()) || 
            (Trigger.isBefore && Trigger.isUpdate) ||
            (Trigger.isAfter && Trigger.isUpdate && !trigger.new.isEmpty())||(Trigger.isBefore && Trigger.isInsert && !trigger.new.isEmpty())){
        new ARTL_AccountTriggerHandler().run();
    }
}