public with sharing class ARTL_GstTaggingContactsController {
    @AuraEnabled
    public static String getNBAAccountId(String quoteMId){
        List< vlocity_cmt__QuoteMember__c > quoteMList = [Select id, vlocity_cmt__QuoteId__r.ARTL_NBA_Account__c from vlocity_cmt__QuoteMember__c where id =: quoteMId];
        System.debug('quoteMList---'+quoteMList);
        if(quoteMList != null && quoteMList.size() > 0){
            return quoteMList[0].vlocity_cmt__QuoteId__r.ARTL_NBA_Account__c;
        }else{
            return null;
        }
       
    }
}