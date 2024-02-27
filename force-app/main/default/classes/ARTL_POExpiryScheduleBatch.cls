global class ARTL_POExpiryScheduleBatch implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        ARTL_POExpiryBatch b = new ARTL_POExpiryBatch(); // Your batch class
        database.executeBatch(b);
    }
}