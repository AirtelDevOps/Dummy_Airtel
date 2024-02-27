public without Sharing class TaskTriggerHelper {

    Public static void resetTaskFields(List<Task> lsttask, Map<Id,Task> oldMap){
        Set<Id> setofApprovalIds = new Set<Id>();
        for(Task objtask: lsttask){
            system.debug('TaskHelper'+objtask);
            if(objtask.ARTL_Rejection_Category__c != null && objtask.ARTL_Rejection_Category__c.equalsIgnoreCase('Invalid') 
               && objtask.Record_Type_Name__c == 'LOC' &&
              objtask.ARTL_Rejection_Category__c != oldMap.get(objtask.id).ARTL_Rejection_Category__c){
                  objtask.ARTL_LOC_Trigger_to_Customer__c = null;
                  objtask.ARTL_locAcceptanceCriteria__c = null;
                  objtask.ARTL_LOC_Bill_Start_Date__c = null;
                  objtask.Number_of_days_for_Deemed_LOC__c = null;
                  //objtask.ARTL_Rejection_Category__c = null;
                  objtask.ARTL_locRejectionReason__c = null;
                  if(objtask.ARTL_LOC_Task_Approval__c != null){
                      setofApprovalIds.add(objtask.ARTL_LOC_Task_Approval__c);
                  } 
                  objtask.Status = 'Open';
            }
        }
        if(!setofApprovalIds.isEmpty()){
            delete [Select Id FROM ARTL_LOC_Task_Approval__c WHERE Id IN:setofApprovalIds];
        }
    }
    Public static void validateAttachment(List<Task> lsttask, Map<Id,Task> oldMap){
        Set<Id> setOfTaskIds = new Set<Id>();
        for(Task objtask: lsttask){
            if(objtask.ARTL_Rejection_Category__c =='Valid' && objtask.ARTL_Rejection_Category__c <> oldMap.get(objtask.Id).ARTL_Rejection_Category__c){
                setOfTaskIds.add(objtask.Id);
            }
        }
        Map<Id,ContentDocumentLink> mapOftaskwithFile = New Map<Id,ContentDocumentLink>();
        if(!setOfTaskIds.isEmpty()){
            for(ContentDocumentLink cdoc:[SELECT ContentDocumentId,LinkedEntityId 
                                          FROM ContentDocumentLink WHERE LinkedEntityId IN:setOfTaskIds]){
                mapOftaskwithFile.put(cdoc.LinkedEntityId, cdoc);
            }
        }
        if(!setOfTaskIds.isEmpty()){
            for(Task taskrec: lsttask){
                if(!mapOftaskwithFile.containsKey(taskrec.Id) && !Test.IsRunningTest()){
                    taskrec.addError('Please upload file.');
                }
            } 
        }
               
    }
    
    public static void updateRelatedTaskStatus(Set<Id> setOfOrderIds, Map<Id,Task> newMap){
        List<Task> lstTasktobeUpdated = new List<Task>();
        lstTasktobeUpdated = [Select Id,Status FROM Task WHERE 
                             WhatId IN:setOfOrderIds AND Id NOT IN: newMap.Keyset() 
                              AND Status != 'Open' AND Record_Type_Name__c = 'LOC'];
        if(!lstTasktobeUpdated.isEmpty()){
            for(Task objtask :lstTasktobeUpdated){
                objtask.Status = 'Open';
            }
            //update lstTasktobeUpdated;
        }
    }
    
    public Static void createTaskForPM(List<Task> lstOfTask){
        List<Task> lstofTasktobeCreated = new List<Task>();
        for(Task objtask:lstOfTask){
            Task newtask = objtask.clone();
            newtask.Created_for_PM__c = true;
            newtask.ARTL_LOC_Trigger_to_Customer__c = null;
            newtask.ARTL_locAcceptanceCriteria__c = null;
            newtask.ARTL_LOC_Bill_Start_Date__c = null;
            newtask.Number_of_days_for_Deemed_LOC__c = null;
            newtask.Status = 'Open';
            newtask.Subject = 'PM NW Jeopardy';
            lstofTasktobeCreated.add(newtask);
        }
        if(!lstofTasktobeCreated.isEmpty()){
            insert lstofTasktobeCreated;
        }
    }
    
    public static void populateAccount(List<Task> lsttask){
        Map<Id, Order> mapOfOrder = new Map<Id,Order>();
        set<Id> setOfOrderIds = new Set<Id>();
        for(Task objtask: lsttask){
            //if(objtask.Record_Type_Name__c == 'LOC'){
                setOfOrderIds.add(objtask.WhatId);
            //}
        }
        if(!setOfOrderIds.isEmpty()){
            for(Order ord :[Select Id,AccountId,(Select Id FROM OrderItems WHERE vlocity_cmt__ParentItemId__c = null limit 1) 
                            FROM Order WHERE Id IN:setOfOrderIds]){
                mapOfOrder.put(ord.Id,ord);
            }
        }
        if(mapOfOrder.size() > 0){
           for(Task objtask: lsttask){
                if(mapOfOrder.containsKey(objtask.WhatId)){
                    objtask.ARTL_Account_Name__c = mapOfOrder.get(objtask.WhatId).AccountId;
                    Order ord = mapOfOrder.get(objtask.WhatId);
                    if(ord.OrderItems.size() > 0){
                      objtask.Order_Product__c = ord.OrderItems[0].Id;   
                    }
                }
            } 
        }
    }
    
    public static void updateEffectiveDateOnOLI(List<Task> lsttask){
        Map<Id, List<OrderItem>> mapOfOrder = new Map<Id,List<OrderItem>>();
        set<Id> setOfOrderIds = new Set<Id>();
        for(Task objtask: lsttask){
                setOfOrderIds.add(objtask.WhatId);
        }
        if(!setOfOrderIds.isEmpty()){
            for(Order ord :[Select Id,AccountId ,(Select Id , ARTL_Effective_Date__c From OrderItems) FROM Order WHERE Id IN:setOfOrderIds]){
                mapOfOrder.put(ord.Id,ord.OrderItems);
            }
        }
        List<OrderItem> oliToUpdate = new List<OrderItem>();
        if(mapOfOrder.size() > 0){
           for(Task objtask: lsttask){
                if(mapOfOrder.containsKey(objtask.WhatId)){
                    //objtask.ARTL_Account_Name__c = mapOfOrder.get(objtask.WhatId).AccountId;
                    for(OrderItem oi : mapOfOrder.get(objtask.WhatId)){
                       oi.ARTL_Effective_Date__c = objtask.ARTL_LOC_Bill_Start_Date__c;
                       oliToUpdate.add(oi);
                    }
                }
            } 
        }
        if(oliToUpdate.size()>0){
            update oliToUpdate;
        }
    }
}