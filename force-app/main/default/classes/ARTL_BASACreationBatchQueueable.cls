public with sharing class ARTL_BASACreationBatchQueueable implements Queueable{
    Set<Id> quoteIds;
    public ARTL_BASACreationBatchQueueable(Set<Id> quoteIds) {
        this.quoteIds=quoteIds;
    }
    public void execute(QueueableContext context) {
        Database.executeBatch(new ARTL_BACreationPreProcessBatch(quoteIds),1);

    }
}