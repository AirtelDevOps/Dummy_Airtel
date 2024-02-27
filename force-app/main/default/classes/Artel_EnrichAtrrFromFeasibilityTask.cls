/************************************************************************************************************************************************************************************************************
* @Author       : Vishal Kumar <vishal.kumar@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 07/11/2023
* @Test Class   : 
* @Description  : Enrich Attribute from feasibility
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
*        1. SFDC-         Vishal Kumar          07/11/2023     Initial Dev
******************************************************************************************************************************************************************************************************************/

global class Artel_EnrichAtrrFromFeasibilityTask implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask{
    
  global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items) {
    //  system.debug('items==>'+items);  
      for (vlocity_cmt__OrchestrationItem__c item: items) {
            /* your custom logic here */
            //System.debug(LoggingLevel.INFO, 'Hello world: orchestration task Id = ' + item.Id);
           // enrichAttrFRL(items);
        }
    } 
       
	/*global  void enrichAttrFRL(List<vlocity_cmt__OrchestrationItem__c> oItemsList){
    
       List<Id> orderItemList = new List<Id>();
       String FrlId;
       for(vlocity_cmt__OrchestrationItem__c orItem: oItemsList){
           orderItemList.add(orItem.vlocity_cmt__OrderItemId__c);//null
           FrlId = orItem.vlocity_cmt__OrderFulfilmentRequest__c; 
       }
        

        
       System.debug('orderItemList###'+orderItemList);
       System.debug('FrlId###'+FrlId);
       Set<Id> QuoteLineItemIdList  = new Set<Id>();
       for(OrderItem ordItem : [ 
           							select id,QuoteLineItemId
                           			from OrderItem 
                           			where id =: orderItemList
                          			 
           
                               ]){
                                   
               QuoteLineItemIdList.add(ordItem.QuoteLineItemId);
                                   
       }
        
       /* 
                OrchestrationItem : OrchestrationPlan:OrderId
           RootOLI =  Query on OLI with OrderId and ParentItemID = nullRead FeasibilityId, QLI

            Query on Feasibility attributes Attribute name, FeasibilityId, QLI
            Read Value
            Attribute name : rsuName , maxspeed , maxspeedrsu, maxspeedtechnology, city 
                MSU Matrix query with rsuName and city value 
STD Code query with city */
               
                    
                
            
      /* Id quoteMemberId = [select vlocity_cmt__QuoteMemberId__c from QuoteLineItem where id=:QuoteLineItemIdList limit 1].vlocity_cmt__QuoteMemberId__c;
       vlocity_cmt__QuoteMember__c quoteMemObj = [
           										  	Select id, vlocity_cmt__ServiceabilityData__c  
                                                  	from vlocity_cmt__QuoteMember__c
           											where id=:quoteMemberId 
       ];
        
       	Map<String, Object> serviceDataMap = (Map<String, Object>) JSON.deserializeUntyped(quoteMemObj.vlocity_cmt__ServiceabilityData__c);
      
       	string rsuQM  =  String.valueOf(serviceDataMap.get('rsu'));
        string maxspeedQM  =  String.valueOf(serviceDataMap.get('maxspeed'));
		string maxspeedrsuQM  =  String.valueOf(serviceDataMap.get('maxspeedrsu'));
        string maxspeedtechnologyQM  =  String.valueOf(serviceDataMap.get('maxspeedtechnology'));
      	string technologyFromQM  =  String.valueOf(serviceDataMap.get('maxspeedtechnology'));
        
        
        
        
       List<vlocity_cmt__FulfilmentRequestLine__c>  frlList = new List<vlocity_cmt__FulfilmentRequestLine__c>();
       for(vlocity_cmt__FulfilmentRequestLine__c  frl: [
           												select id, vlocity_cmt__Product2Id__c, vlocity_cmt__AttributeSelectedValues__c,
           												vlocity_cmt__FulfilmentRequestID__c,vlocity_cmt__LineNumber__c   
                                                        from vlocity_cmt__FulfilmentRequestLine__c 
                            							where vlocity_cmt__FulfilmentRequestID__c =: FrlId
                                           				AND (vlocity_cmt__Product2Id__r.ProductCode = 'VEPC_DSL_CFS' 
                                                             OR vlocity_cmt__Product2Id__r.ProductCode = 'VEPC_Voice_CFS')
       ]){
           String linenumber;		
           if(frl.vlocity_cmt__Product2Id__r.ProductCode == 'VEPC_DSL_CFS'){
                linenumber = frl.vlocity_cmt__LineNumber__c;
           } 
           else if(frl.vlocity_cmt__Product2Id__r.ProductCode == 'VEPC_Voice_CFS'){
                linenumber = frl.vlocity_cmt__LineNumber__c;
           }
           if(frl.vlocity_cmt__LineNumber__c.contains(linenumber) && frl.vlocity_cmt__Product2Id__r.ProductCode != 'VEPC_DSL_CFS'){
               	Map<String, Object> FRLStringMap;                         
                 if(frl.vlocity_cmt__AttributeSelectedValues__c != NULL)
                    	 FRLStringMap = (Map<String, Object>) JSON.deserializeUntyped(frl.vlocity_cmt__AttributeSelectedValues__c);
                 else
                         FRLStringMap = new Map<String, Object>();
                     
					 
                    for(String s : FRLStringMap.keySet()){
                        if(s == 'ATT_ RSU'){
                            FRLStringMap.put(s,rsuQM);
                        }
                        if(s == 'ATT_Max_Speed'){
                            FRLStringMap.put(s,maxspeedQM);
                        }
                        if(s == 'ATT_Max_Speed_RSU'){
                            FRLStringMap.put(s,maxspeedrsuQM);
                        }
                        if(s == 'ATT_Max_Speed_Technology'){
                            FRLStringMap.put(s,maxspeedtechnologyQM);
                        }
                        if(s == 'ATT_TECHNOLOGY'){
                            FRLStringMap.put(s,technologyFromQM);
                        }
                    }
               		String FRLAttString = JSON.serialize(FRLStringMap);                     
                    frl.vlocity_cmt__AttributeSelectedValues__c = FRLAttString;
                    frlList.add(frl);	
			}            
          }
           
            if(frlList.size() > 0){
                update frlList;
            }
    }*/
   
}