/************************************************************************************************************************************************************************************************************
* @Author       : Akshay Kaushik <akshay.kaushik@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 24/01/2024
* @Test Class   : 
* @Description  : Create Sub orders according to root item custom logic
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
*     Developer               Date           	  Comment
* ------------------      ---------------       -----------    
*  Akshay Kaushik          24/01/2024     		Initial Dev
******************************************************************************************************************************************************************************************************************/
global class ARTL_SubOrderCreationAndSubmission implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        Boolean result = true;
        try {
            if ('CreateSubOrderCustomLogic'.equalsIgnoreCase(methodName)) {
                CreateSubOrderCustomLogic(inputMap, outMap, options);
            } else {
                result = false;
            }
        } catch (Exception e) {
            result = false;
        }
        return result;
    }
    
    public void CreateSubOrderCustomLogic(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
        String SubOrderId = (String)inputMap.get('SubOrderId');
        Boolean batchRequiredForSubOrderCreation = false;
        List<Orderitem> SubOrderitemList = [select id,order.vlocity_cmt__QuoteId__c,order.vlocity_cmt__QuoteId__r.PM__c,vlocity_cmt__ParentItemId__c,OrderId,Quantity,order.vlocity_cmt__ParentOrderId__c from orderitem where orderid =:SubOrderId and vlocity_cmt__ParentItemId__c = null];
        Id PMID;
        if(SubOrderitemList[0].order.vlocity_cmt__QuoteId__c!=null && SubOrderitemList[0].order.vlocity_cmt__QuoteId__r.PM__c!=null){
            PMID = (Id)SubOrderitemList[0].order.vlocity_cmt__QuoteId__r.PM__c;
        }
        
        system.debug('SubOrderitemList==>'+SubOrderitemList.size());
        Integer Quantity = Integer.valueOf(SubOrderitemList[0].Quantity);
        if(SubOrderitemList.size()>1 || (Quantity>1 && SubOrderitemList.size()>0)) {
            batchRequiredForSubOrderCreation = true;
        }
        if(batchRequiredForSubOrderCreation){
            ARTL_CreateSubOrderCustomLogic batchJob = new ARTL_CreateSubOrderCustomLogic(SubOrderId,PMID);
            Id batchJobId = Database.executeBatch(batchJob, 200);
        }
        else if(batchRequiredForSubOrderCreation==false && PMID !=null){
            OrderShare ordershareforPM = new OrderShare();
            ordershareforPM.OrderAccessLevel = 'Edit';
            ordershareforPM.OrderId=SubOrderId;
            ordershareforPM.RowCause='Manual';
            ordershareforPM.UserOrGroupId=PMID;
            insert ordershareforPM;
            
        }
        Id MasterOrderID = (Id)SubOrderitemList[0].order.vlocity_cmt__ParentOrderId__c;
        OrderShare ordershareforPMmasterorder = new OrderShare();
            ordershareforPMmasterorder.OrderAccessLevel = 'Edit';
            ordershareforPMmasterorder.OrderId=MasterOrderID;
            ordershareforPMmasterorder.RowCause='Manual';
            ordershareforPMmasterorder.UserOrGroupId=PMID;
            insert ordershareforPMmasterorder;
    }
}