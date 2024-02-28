Global class ARTL_PDOrderCreationBatch implements Database.Batchable<sObject> {
      private String caseNumber;

    global ARTL_PDOrderCreationBatch(String caseNumber) {
        this.caseNumber = caseNumber;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([select Id,Origin, CaseNumber from case where CaseNumber =: caseNumber]);
    }
    global void execute(Database.BatchableContext BC, List<Case> cs){
        
    }
    global void finish(Database.BatchableContext BC){
           system.debug('this is finish method');
           /*Here  Input to the IP will be passed 
            Input to the Ip Name - Callout_After_PDOrderCreation is
			{
					
                 "body":{
                   "StatusCode" : "Success/ Error",
                   "OrderStatus": "Closed",
                   "OrderNum" : "SFDC Order#",
                   "SRNum" : "1234",
                   "ErrorMessage" : "Invalid LSI/Invalid Date/Open Order exists on LSI/Dependent LSIs exists on LSI"
                }
          }
            */
    }
}