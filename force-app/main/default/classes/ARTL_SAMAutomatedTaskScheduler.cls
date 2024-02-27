/**
 * @description       : SFDC-1110 - To schedule batch class - ARTL_SAMJourneyAutomatedTaskBatch
 * @test class        : ARTL_SAMJourneyAutomatedTaskBatchTest
 * @author            : Rishab Kalra
 * @last modified on  : 12-11-2023
**/
public class ARTL_SAMAutomatedTaskScheduler implements Schedulable{
    public void execute(SchedulableContext sc){
      Database.executebatch(new ARTL_SAMJourneyAutomatedTaskBatch());
    }
}