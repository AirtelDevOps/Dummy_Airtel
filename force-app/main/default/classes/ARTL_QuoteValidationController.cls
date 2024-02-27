public without sharing class ARTL_QuoteValidationController {

    private static final String RATE_REVISION = 'Rate Revision';
    private static final String REBILLING = 'Rebilling';
    private static final String FX_VALIDATION_FAILED_MSG = 'Fx Validation Failed. ';
    private static final String FX_VALIDATION_FAILED_MSG_LSI = 'Fx Validation has been failed for following Line Items: ';
    
    @AuraEnabled
    public static String checkQuoteValidation(Id recId) {
       
        List<QuoteLineItem> quoteLineItems = [
            SELECT Id, ARTL_LSI__c
            FROM QuoteLineItem
            WHERE QuoteId = :recId AND vlocity_cmt__Product2Id__r.ARTL_LSIRequired__c = true AND 
            ( (ARTL_Validation_Status__c != 'To be Validated' AND ARTL_Validation_Status__c != 'Passed') OR
            ARTL_Validation_Status__c = 'Failed' ) 
            LIMIT 1
        ];
        
        if (!quoteLineItems.isEmpty()) {
            return  string.valueof(quoteLineItems[0].ARTL_LSI__c) ;
        }
        else {
            //KB: IF QLIs are exist to be validated then doing FX Validation
            List<QuoteLineItem> qliUpdateList = new List<QuoteLineItem> ();
            Set<String> failedLIs = new Set<String>();
            for(QuoteLineItem obj: [SELECT Id, lineNumber, ARTL_Effective_Change_Date__c, ARTL_Effective_Date__c  
                                    FROM QuoteLineItem
                                    WHERE QuoteId = :recId AND 
                                    (quote.vlocity_cmt__Type__c = :RATE_REVISION OR quote.vlocity_cmt__Type__c = :REBILLING)] 
            ){
                if(obj.ARTL_Effective_Change_Date__c == null || obj.ARTL_Effective_Date__c == null || 
                    (obj.ARTL_Effective_Change_Date__c < (obj.ARTL_Effective_Date__c).date())
                ){
                    qliUpdateList.add(new QuoteLineItem(id = obj.id, ARTL_Validation_Status__c = 'Failed', Validation_Message__c = FX_VALIDATION_FAILED_MSG));
                    failedLIs.add(obj.lineNumber);
                }
            }
            if(!qliUpdateList.isEmpty()){
                update qliUpdateList;
                return FX_VALIDATION_FAILED_MSG_LSI + String.join((Iterable<String>)failedLIs, ', ');
            }else{

                ARTL_ValidateStagingData batchClassInstance = new ARTL_ValidateStagingData(string.valueof(recId),false);
                Database.executeBatch(batchClassInstance);
            }
                
        }
       return 'In-Progress';
    }

    @AuraEnabled(cacheable=true)
    public static Id getReportId(){

        List<report> report=[SELECT Id FROM Report WHERE Name='ARTL QLI Validation'];
        if(report.size()>0){
            return report[0].Id;
        }
        else{
            return null;
        }
    }

    
}