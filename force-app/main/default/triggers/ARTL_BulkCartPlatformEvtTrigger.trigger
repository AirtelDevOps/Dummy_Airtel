trigger ARTL_BulkCartPlatformEvtTrigger on Bulk_Cart_Update_Notification__e (after Insert) {
    ARTL_BulkCartPlatformEvtTriggerHandler.processAfterInsert(Trigger.New);
}