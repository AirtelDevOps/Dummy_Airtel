Global class ARTL_SeibelCreationBatch implements Database.Batchable<sObject> {
      private String caseNumber;

    global ARTL_SeibelCreationBatch(String caseNumber) {
        this.caseNumber = caseNumber;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select Id,Origin, CaseNumber from case where CaseNumber =: caseNumber]);
    }
    global void execute(Database.BatchableContext BC, List<Case> cs){
        
    }
    global void finish(Database.BatchableContext BC){
           system.debug('this is finish method');
        
    }
}