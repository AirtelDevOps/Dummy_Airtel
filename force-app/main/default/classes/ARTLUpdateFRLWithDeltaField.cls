/*****************************************************************************************************************
Name : ARTLUpdateFRLWithDeltaField
==================================================================================================================
Purpose: 1.Updating Delta Field (F4)
==================================================================================================================
History
---------------
Version      Author               Date         Detail      Features/CSR/TTP
1.0       Akshay(SFI)  		    18.12.2023    Created   
*********/

global class ARTLUpdateFRLWithDeltaField implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {

    public void executeBatch(List<vlocity_cmt__OrchestrationItem__c> items)
    {	
        List<vlocity_cmt__FulfilmentRequestLine__c> FRLRecordsToUpdate = new List<vlocity_cmt__FulfilmentRequestLine__c>();
        List<id> orchitemids = new List<id>(); 
        for(vlocity_cmt__OrchestrationItem__c orchitemRec :items){
			orchitemids.add(orchitemRec.id);            
        }
        List<id> orderids = new List<id>();
        List<vlocity_cmt__FulfilmentRequestLine__c> ListOfEligibleFRLs = new List<vlocity_cmt__FulfilmentRequestLine__c>();
        List<vlocity_cmt__OrchestrationPlan__c> orchPlanList = [select vlocity_cmt__OrderId__c from vlocity_cmt__OrchestrationPlan__c where id in (select vlocity_cmt__OrchestrationPlanId__c from vlocity_cmt__OrchestrationItem__c where id in :orchitemids)];
        for(vlocity_cmt__OrchestrationPlan__c orchPlanRec:orchPlanList){
            orderids.add(orchPlanRec.vlocity_cmt__OrderId__c);
        }
        list <id> FRLids = new List<id>();
        list<vlocity_cmt__FulfilmentRequestLine__c> FRLList = [select id,vlocity_cmt__AttributeSelectedValues__c,ARTL_Updated_Attributes__c,vlocity_cmt__InventoryItemId__r.vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__Action__c,vlocity_cmt__Product2Id__r.ARTL_Parent_Products__c,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c from vlocity_cmt__FulfilmentRequestLine__c where  vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c in :orderids ];
        System.debug('FRLListsize'+FRLList.size());
        for(vlocity_cmt__FulfilmentRequestLine__c FrlRec:FRLList){
        Map<String,Object> ModifiedJson = new Map<String,Object>();
        Map<String,Object> InventoryJson = new Map<String,Object>();
        String orderid;
        String producthierarchy;
        
        if(FrlRec.vlocity_cmt__AttributeSelectedValues__c!=null){
        ModifiedJson = (Map<String,Object>) JSON.deserializeUntyped(FrlRec.vlocity_cmt__AttributeSelectedValues__c);
        FrlRec.ARTL_Updated_Attributes__c = FrlRec.vlocity_cmt__AttributeSelectedValues__c;
        }
        if(FrlRec.vlocity_cmt__InventoryItemId__r!=null ){
            if(FrlRec.vlocity_cmt__InventoryItemId__r.vlocity_cmt__AttributeSelectedValues__c!=null){
                InventoryJson = (Map<String,Object>) JSON.deserializeUntyped(FrlRec.vlocity_cmt__InventoryItemId__r.vlocity_cmt__AttributeSelectedValues__c);
            }
        }
        Map<String,String> DeltaValues = new Map<String,String>();
        orderid = (FrlRec.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c!=null?FrlRec.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c:null);
        producthierarchy = (FrlRec.vlocity_cmt__Product2Id__r.ARTL_Parent_Products__c!=null?FrlRec.vlocity_cmt__Product2Id__r.ARTL_Parent_Products__c:null);
        List<vlocity_cmt__FulfilmentRequestLine__c> ParentRecords = new List<vlocity_cmt__FulfilmentRequestLine__c>();
         List<String> ListofproductCodes = new List<String>();
         if(producthierarchy!=null){
            ListofproductCodes = producthierarchy.split(',');
         }
            for (String key : ModifiedJson.keySet()){
            String ModifiedJsonValue = String.valueOf(ModifiedJson.get(key));
            String InventoryJsonValue = String.valueOf(InventoryJson.get(key));
            if(ModifiedJsonValue!=InventoryJsonValue){
                DeltaValues.put(key,ModifiedJsonValue);
            }
        }
            
            
            if(!DeltaValues.isEmpty()){
        vlocity_cmt__FulfilmentRequestLine__c UpdatedRec = new vlocity_cmt__FulfilmentRequestLine__c();
        UpdatedRec.id = FrlRec.Id;   
        System.debug('DeltaValues'+DeltaValues);
        String updatedJson = JSON.serialize(DeltaValues);
                if(FrlRec.vlocity_cmt__Product2Id__c!=null ){
                    if(FrlRec.vlocity_cmt__Product2Id__r.Name.contains('ARC') || FrlRec.vlocity_cmt__Product2Id__r.Name == 'iConnectivity Billing CFS'){
        			UpdatedRec.vlocity_cmt__Action__c = 'Modify';
                    UpdatedRec.ARTL_Updated_Attributes__c = updatedJson;
                }
                }
        
        ParentRecords.add(UpdatedRec);
            System.debug('producthierarchy'+producthierarchy);
            if(producthierarchy!=null){
         List<vlocity_cmt__FulfilmentRequestLine__c> parentFRLRecords = [select id,vlocity_cmt__Action__c,vlocity_cmt__Product2Id__r.Name from vlocity_cmt__FulfilmentRequestLine__c where vlocity_cmt__Action__c !='Disconnect' AND vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c =:orderid AND vlocity_cmt__Product2Id__r.ProductCode IN :ListofproductCodes];
            for(vlocity_cmt__FulfilmentRequestLine__c eachRec:parentFRLRecords){
                vlocity_cmt__FulfilmentRequestLine__c UpdatedRecord = new vlocity_cmt__FulfilmentRequestLine__c();
                UpdatedRecord.id = eachRec.id;
                String idrec = eachRec.id;
                if(eachRec.vlocity_cmt__Product2Id__r.Name.contains('ARC') || eachRec.vlocity_cmt__Product2Id__r.Name == 'iConnectivity Billing CFS'){
        			UpdatedRecord.vlocity_cmt__Action__c = 'Modify';
                    UpdatedRecord.ARTL_Updated_Attributes__c = updatedJson;
                }
                if(FrlRec.id!=idrec){
                    ParentRecords.add(UpdatedRecord); 
                }
				               
            }
            }
        
        }
         System.debug('ParentRecords'+ParentRecords);
         List<vlocity_cmt__FulfilmentRequestLine__c> listOfStrings = new List<vlocity_cmt__FulfilmentRequestLine__c>(ParentRecords);
        update listOfStrings;
        }
        //update FRLRecordsToUpdate;
        Id OrderIdForFRL = orderids[0];
        List<vlocity_cmt__FulfilmentRequestLine__c> UpdateHansenOrderType = [select id,ARTL_Updated_Attributes__c,vlocity_cmt__MainOrderItemId__c,vlocity_cmt__LineNumber__c,vlocity_cmt__AttributeSelectedValues__c from vlocity_cmt__FulfilmentRequestLine__c where vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c =:OrderIdForFRL ];
        List<vlocity_cmt__FulfilmentRequestLine__c> updatedFRLlist = new List<vlocity_cmt__FulfilmentRequestLine__c>();
        for(vlocity_cmt__FulfilmentRequestLine__c UpdateHansenOrderTyperec:UpdateHansenOrderType){
            String LineNumber = UpdateHansenOrderTyperec.vlocity_cmt__MainOrderItemId__c+'.0001.0001';
            if(UpdateHansenOrderTyperec.vlocity_cmt__MainOrderItemId__c != null && UpdateHansenOrderTyperec.vlocity_cmt__LineNumber__c.equals(LineNumber)){
                vlocity_cmt__FulfilmentRequestLine__c updatedFRLRec = new vlocity_cmt__FulfilmentRequestLine__c();
                boolean ifUpdationRequired = false;
                Map<String,Object> updatedAttributes = new Map<String,Object>();
                //if(UpdateHansenOrderTyperec.ARTL_Updated_Attributes__c!=null && UpdateHansenOrderTyperec.vlocity_cmt__AttributeSelectedValues__c!=null){
                if(UpdateHansenOrderTyperec.ARTL_Updated_Attributes__c!=null){
                    updatedAttributes =(Map<String,Object>) JSON.deserializeUntyped(UpdateHansenOrderTyperec.ARTL_Updated_Attributes__c);
                String OrderType = String.valueOf(updatedAttributes.get('ATT_ORDER_TYPE_CFS'));
                if(OrderType==''||OrderType==null){
                    ifUpdationRequired=true;
                    }  
                
                     }
                else{
                    ifUpdationRequired=true;
                }
                if(ifUpdationRequired){
                    Map<String,Object> SelectedValues =(Map<String,Object>) JSON.deserializeUntyped(UpdateHansenOrderTyperec.vlocity_cmt__AttributeSelectedValues__c);
                    String selectedOrderType = String.valueOf(SelectedValues.get('ATT_ORDER_TYPE_CFS'));
                    updatedAttributes.put('ATT_ORDER_TYPE_CFS',selectedOrderType);
                }
                    //updatedAttributes.put();
                	
                
                String updatedDeltaAttribute = JSON.serialize(updatedAttributes);
                updatedFRLRec.id = UpdateHansenOrderTyperec.id;
                updatedFRLRec.ARTL_Updated_Attributes__c = updatedDeltaAttribute;
                updatedFRLlist.add(updatedFRLRec);
               
                
            }
        }
        if(updatedFRLlist.size()>0){
            update updatedFRLlist;
        }
		
    }
     
}