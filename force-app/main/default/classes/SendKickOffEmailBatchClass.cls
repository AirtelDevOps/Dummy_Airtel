public class SendKickOffEmailBatchClass implements Database.Batchable<sObject>,Database.AllowsCallouts{


   public Database.QueryLocator start(Database.BatchableContext BC){
      List<Task> quoteItem = [
                        select id,whatid,status,ARTL_TaskType__c,Quote_Line_Item__c from task  
                        where ARTL_TaskType__c = 'PM Approval' AND Status = 'Complete'
                         
      ];
      Map<String,Id> uniqueOrderIdToAccountId = getUniqueAccountId(quoteItem);
      System.debug('uniqueOrderIdToAccountId.values()###'+uniqueOrderIdToAccountId.values());
      return Database.getQueryLocator([
                                       SELECT Id,Quote_Line_Item__c,whatid,ARTL_TaskType__c FROM Task
                                       WHERE whatid IN: uniqueOrderIdToAccountId.values()
                                       AND ARTL_TaskType__c = 'PM Approval' AND Status = 'Complete'
      ]);
   }
   public Map<String,Id> getUniqueAccountId(List<Task> quoteItem){
      // Get list of Quote_Line_Item__c
      Set<Id> quoteLineList = new Set<Id>();
      for(Task t: quoteItem){
         quoteLineList.add(t.Quote_Line_Item__c);
      }
      System.debug('quoteLineList###'+quoteLineList);
      // Get unique account Id for all Quote from Quote_Line_Item__c
      Set<Id> uniqueAccountId = new Set<Id>();
      for(QuoteLineItem quotelineId: [Select Quote.AccountId from QuoteLineItem where id IN: quoteLineList]){
         uniqueAccountId.add(quotelineId.Quote.AccountId);
      }
      System.debug('uniqueAccountId###'+uniqueAccountId);
      Map<String,Id> uniqueOrderIdToAccountId = new Map<String,Id>();
      for(Order ord: [Select id,accountId,RecordType.Name,vlocity_cmt__ParentOrderId__r.Id from order where accountid IN:uniqueAccountId]){
         String key = String.valueOf(ord.accountId) + String.valueOf(ord.vlocity_cmt__ParentOrderId__r.Id); // to handle multple master Order
         if(!uniqueOrderIdToAccountId.containsKey(key)){
            String accountMasterOrderId = String.valueOf(ord.accountId) + String.valueOf(ord.vlocity_cmt__ParentOrderId__r.Id);
            uniqueOrderIdToAccountId.put(accountMasterOrderId,ord.Id);
         }
         
      }
      System.debug('uniqueOrderIdToAccountId###'+uniqueOrderIdToAccountId);
      return uniqueOrderIdToAccountId;

   }
   public void execute(Database.BatchableContext BC, List<Task> scope){
     
     String templateName = 'Welcome_Email1';
     System.debug('Total Record to Iterate ##'+scope.size());
     for(Task tsk : scope){
        ARTL_TaskEmailController.emailWrapper  objemail = ARTL_EmailTemplateService.getKickoffEmailTemplate(tsk.whatid,templateName);
        ARTL_TaskEmailController.sendEmailtoDIRS(objemail);

     }
           
    }

   public void finish(Database.BatchableContext BC){
   }
}