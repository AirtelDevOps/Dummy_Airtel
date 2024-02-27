global class ARTLOMCreateExternalDep  implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask{
    
    public void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items)
    {
        for (vlocity_cmt__OrchestrationItem__c item : items)
        {
            System.debug('orch item-> '+item.Id);
            vlocity_cmt__OrchestrationItem__c orchItem =[Select Id,vlocity_cmt__OrderItemId__r.Product2.ProductCode,vlocity_cmt__OrderItemId__c
                                                        FROM vlocity_cmt__OrchestrationItem__c WHERE Id=:item.Id];
            vlocity_cmt__OrderItemRelationship__c[] ordItemRelationship = [SELECT Id,vlocity_cmt__OrderItemId__r.Product2.ProductCode,vlocity_cmt__RelatedOrderItemId__r.Product2.ProductCode,
                                                                         vlocity_cmt__OrderItemId__c,vlocity_cmt__RelatedOrderItemId__c
               															from vlocity_cmt__OrderItemRelationship__c where vlocity_cmt__OrderItemId__c =: orchItem.vlocity_cmt__OrderItemId__c ] ;
            System.debug('orch item id-> '+orchItem.Id);
            if (ordItemRelationship.size() > 0){
                System.debug('orch item rel size-> '+ordItemRelationship.size());
            List<ARTL_Dynamic_Dependency__mdt> lstDynamicDep = new List<ARTL_Dynamic_Dependency__mdt>();
            if(orchItem != null){
                lstDynamicDep = [Select Id,DeveloperName, Dependency__c, Dependent_Item__c, Item__c  
                             FROM ARTL_Dynamic_Dependency__mdt 
                                 WHERE ARTL_Product_Code__c=:orchItem.vlocity_cmt__OrderItemId__r.Product2.ProductCode AND 
                                 ARTL_Related_Product_Code__c=: ordItemRelationship[0].vlocity_cmt__RelatedOrderItemId__r.Product2.ProductCode];
            }
            
                system.debug('lstDynamicDep==>'+lstDynamicDep);
            if(!lstDynamicDep.isEmpty()){
                //step 1 - locate dependency definition by Global Key
                vlocity_cmt__OrchestrationDependencyDefinition__c depDef = [select Id 
                                                                            from vlocity_cmt__OrchestrationDependencyDefinition__c 
                                                                            where vlocity_cmt__GlobalKey__c =: lstDynamicDep[0].Dependency__c  /*'42a6961d-bc9d-3213-b8d1-14520113bd0e'*/];
                
                //step 2 - locate the task that needs to be dependent on the other
                //find all orchestration items from the same plan
                //and filter by definition (Global Key)
                vlocity_cmt__OrchestrationItem__c fromItem = [select Id, vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Order_with_ReliesOn__r.vlocity_cmt__OrchestrationPlanId__c
                                                              from vlocity_cmt__OrchestrationItem__c 
                                                              where 
                                                              vlocity_cmt__OrchestrationItemDefinitionId__c in (
                                                                  select Id 
                                                                  from vlocity_cmt__OrchestrationItemDefinition__c 
                                                                  where vlocity_cmt__GlobalKey__c =:lstDynamicDep[0].Item__c /*'773864a0-c8ff-7739-2c55-c34345eef60f'*/) 
                                                              and vlocity_cmt__OrchestrationPlanId__c = :item.vlocity_cmt__OrchestrationPlanId__c limit 1];
                
                
                //step 3 - find the depends on task
                //auto task -> plan -> order -> linked order (custom logic) -> another order -> plan -> depends on task (using global key)
                
                Id externalPlanId = fromItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__r.Order_with_ReliesOn__r.vlocity_cmt__OrchestrationPlanId__c;
                vlocity_cmt__OrchestrationItem__c toItem;
                if(externalPlanId != null)
                {
                    system.debug('inside if');
                    toItem = [select Id from vlocity_cmt__OrchestrationItem__c 
                              where vlocity_cmt__OrchestrationItemDefinitionId__c in (
                                  select Id from vlocity_cmt__OrchestrationItemDefinition__c 
                                   where vlocity_cmt__GlobalKey__c =:lstDynamicDep[0].Dependent_Item__c /*'d70c9f72-aa87-25c7-39e1-f46200c74b08'*/) 
                              and vlocity_cmt__OrchestrationPlanId__c = :externalPlanId limit 1];            
                    
                }
                //step 4 - create dependency
                if(fromItem != null && toItem != null){
                    vlocity_cmt__OrchestrationDependency__c dep = new vlocity_cmt__OrchestrationDependency__c(
                        vlocity_cmt__OrchestrationItemId__c = fromItem.Id, 
                        vlocity_cmt__DependsOnItemId__c = toItem.Id, 
                        vlocity_cmt__OrchestrationDependencyDefinitionId__c = depDef.Id);
                    insert dep;
                }
            }
        } 
        }
    }
    
    
}