global with sharing class ARTL_IPCallToUpdate implements vlocity_cmt.VlocityOpenInterface{
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options){
        if (methodName == 'updateRRorRbDate') {
            updateRRorRbDate(inputs, output, options);
            return true;
        }
        return false;
    }
    
    public static void updateRRorRbDate(Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options){
        List<Id> qliId = (List<Id>)inputs.get('QLIId');
        List<QuoteLineItem> qliList = [Select Id , ARTL_Purchase_Order__c , ARTL_Effective_Change_Date__c From QuoteLineItem where Id IN :qliId];
        List<String> poIds = new list<String>();
        Map<String , DateTime> dateMap = new Map<String , DateTime>();
        for(QuoteLineItem qli : qliList){
            poIds.add(qli.ARTL_Purchase_Order__c);
            dateMap.put(qli.ARTL_Purchase_Order__c , qli.ARTL_Effective_Change_Date__c);
        }
        try{
        List<ARTL_Purchase_Order__c> poList = [Select Id , Start_Date__c , End_Date__c From ARTL_Purchase_Order__c where Id IN :poIds AND Start_Date__c = NULL];
        List<ARTL_Purchase_Order__c> listToUpdate = new List<ARTL_Purchase_Order__c>();
        for(ARTL_Purchase_Order__c po : poList){
            po.Start_Date__c = (Date)dateMap.get(po.Id);
            po.End_Date__c = (Date)dateMap.get(po.Id).addMonths(Integer.valueOf(po.Tenure__c));
            listToUpdate.add(po);
        }
        if(listToUpdate.size() > 0){
            update listToUpdate;
        }
        }catch(exception e){
            system.debug('Error --->');
        }
    }
}