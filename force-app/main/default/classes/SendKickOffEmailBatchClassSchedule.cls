global class SendKickOffEmailBatchClassSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        SendKickOffEmailBatchClass b = new SendKickOffEmailBatchClass(); // Your batch class
        database.executeBatch(b,1);
    }
}