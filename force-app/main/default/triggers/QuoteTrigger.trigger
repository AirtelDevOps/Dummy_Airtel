/*------------------------------------------------------Trigger Signature-------------------------------------------------------
Trigger Name    : CreateOrderTrigger
Purpose         : Create a Order record when Quote Status is 'OV Approved'.
Handler Class   : CreateOrderTriggerHandler
Helper Class    : QuoteTriggerHelper
Date            : 05-October-2023
-------------------------------------------------------------------------------------------------------------------------------*/
trigger QuoteTrigger on Quote (after update,before update) {
    if(Trigger.isAfter && Trigger.isUpdate && !trigger.new.isEmpty()){
        new QuoteTriggerHandler().run();
    }
    
    if(Trigger.isBefore && Trigger.isUpdate && !trigger.new.isEmpty()){
        new QuoteTriggerHandler().run();
    }
}