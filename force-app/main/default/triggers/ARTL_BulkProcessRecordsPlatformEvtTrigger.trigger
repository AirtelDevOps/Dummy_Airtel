trigger ARTL_BulkProcessRecordsPlatformEvtTrigger on ARTL_Bulk_Process_Records__e (after Insert) {
    ARTL_BulkProcessRecordsTriggerHandler.processAfterInsert(Trigger.New);
}