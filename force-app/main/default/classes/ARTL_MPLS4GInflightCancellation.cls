global class ARTL_MPLS4GInflightCancellation implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
    
    public void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items)
    {
           
        List<id> orchitemids = new List<id>();
        List<id> orderids = new List<id>();
        List<order> order_4G = new List<order>();
        List< OrderItem> order_4GItem = new List< OrderItem>();
        Map<String, Object> oiAttrMap = new Map<String, Object> ();
        Integer noOfLicenses=0;
        
        for(vlocity_cmt__OrchestrationItem__c orchitemRec :items){
            orchitemids.add(orchitemRec.id);            
        }
        List<vlocity_cmt__OrchestrationPlan__c> orchPlanList = [select vlocity_cmt__OrderId__c 
                                            from vlocity_cmt__OrchestrationPlan__c 
                                                where id in (select vlocity_cmt__OrchestrationPlanId__c 
                                                             from vlocity_cmt__OrchestrationItem__c where id in :orchitemids)];
        for(vlocity_cmt__OrchestrationPlan__c orchPlanRec:orchPlanList){
            orderids.add(orchPlanRec.vlocity_cmt__OrderId__c);
        }   
        
         order_4G = [Select Id,Order_with_ReliesOn__c from Order where Id IN :orderids];
          if(!order_4G .isEmpty()){
              
               order_4GItem = [Select Id,vlocity_cmt__AttributeSelectedValues__c,OrderId From OrderItem where OrderId =:order_4G[0].Order_with_ReliesOn__c];
              if(!order_4GItem .isEmpty()){
                  
                  for(OrderItem oi : order_4GItem){
                      
                      if(oi.vlocity_cmt__AttributeSelectedValues__c != null){
                        oiAttrMap = (Map<String, Object>) JSON.deserializeUntyped(oi.vlocity_cmt__AttributeSelectedValues__c);
                    }
                    if(!oiAttrMap.isEmpty()){
                        noOfLicenses = Integer.valueOf(oiAttrMap.get('ATT_NUMBER_OF_LICENCES'));
                        Map<String,Object> ipreq = new Map<String,Object>();
                         Map<String,Object> ipOutput = new Map<String,Object>();
                        ipreq.put('cartId',oi.OrderId);
                        if(noOfLicenses == 1){
                            
                             System.debug('ipreq : '+JSON.serializePretty(ipreq));
                            ipOutput = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService('b2bExpress_CancelSubOrder', ipreq, new Map<String,Object>());
                            System.debug('ipOutput : '+JSON.serializePretty(ipOutput));
                        }
                       else if(noOfLicenses > 1){
                           
                           ipreq.put('AttributeName','ATT_NUMBER_OF_LICENCES');
                           ipreq.put('AttributeValue',(noOfLicenses-1));
                           System.debug('ipreq111 : '+JSON.serializePretty(ipreq));
                           ipOutput = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService('ARTLOM_inflightAmend', ipreq, new Map<String,Object>());
                           System.debug('ipOutput111 : '+JSON.serializePretty(ipOutput));
                       
                       }
                        
                      
                      
                  
              }
              
              
          }
        }
    }
}
}