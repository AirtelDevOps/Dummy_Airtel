/*****************************************************************************************************************
Name : ARTL_UpdateCaseStatus
==================================================================================================================
Purpose: 1.Updating Case Status 
==================================================================================================================
History
---------------
Version      Author               Date         Detail      Features/CSR/TTP
1.0       Akshay(SFI)  		    08.02.2024    Created   
*********/

global class ARTL_UpdateCaseStatus implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {

    public void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items)
    {	
        List<vlocity_cmt__FulfilmentRequestLine__c> FRLRecordsToUpdate = new List<vlocity_cmt__FulfilmentRequestLine__c>();
        List<id> orchitemids = new List<id>(); 
        for(vlocity_cmt__OrchestrationItem__c orchitemRec :items){
			orchitemids.add(orchitemRec.id);            
        }
        List<id> orderids = new List<id>();
        List<vlocity_cmt__OrchestrationPlan__c> orchPlanList = [select vlocity_cmt__OrderId__c from vlocity_cmt__OrchestrationPlan__c where id in (select vlocity_cmt__OrchestrationPlanId__c from vlocity_cmt__OrchestrationItem__c where id in :orchitemids)];
        for(vlocity_cmt__OrchestrationPlan__c orchPlanRec:orchPlanList){
            orderids.add(orchPlanRec.vlocity_cmt__OrderId__c);
        }
        List<Order> StatusUpdateOrders = new List<Order>();
        for(Id orderIDrec:orderids){
            Order orderrectoUpdate = new Order();
            orderrectoUpdate.id = orderIDrec;
            orderrectoUpdate.status = 'Closed';
            StatusUpdateOrders.add(orderrectoUpdate);
        }
        if(StatusUpdateOrders.size()>0){
            update StatusUpdateOrders;
        }
    }
}