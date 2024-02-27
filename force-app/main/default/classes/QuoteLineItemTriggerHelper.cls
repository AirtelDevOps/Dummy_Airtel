/************************************************************************************************************************************************************************************************************
* @Author       : Abinash Barik <abinash.barik@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 25/09/2023
* @Test Class   : 
* @Description  : Handles to create Technical Attribute records once root QLI's are inserted .
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1. SFDC-217              Abinash Barik         25/09/2023     Initial Dev
******************************************************************************************************************************************************************************************************************/

public class QuoteLineItemTriggerHelper {
    /*
public static void createTechnicalAttribute(List<QuoteLineItem> triggerNewList, Map<Id,QuoteLineItem> newMap){
createAllTechnicalProducts(newMap);
List<XLI_Technical_Attribute__c> lstTechnicalAttributetobeCreated = new List<XLI_Technical_Attribute__c>();
Map<String,vlocity_cmt__DecompositionRelationship__c> mapOfTechProduct = new Map<String,vlocity_cmt__DecompositionRelationship__c>();
Set<String> setOfProductIds = new Set<String>();
for(QuoteLineItem objqli: triggerNewList){
if(objqli.Product2Id != null){
setOfProductIds.add(objqli.Product2Id);
}
}
mapOfTechProduct = getTechnicalProductDetails(setOfProductIds);
for(QuoteLineItem qli: triggerNewList){
if(qli.vlocity_cmt__ParentItemId__c == null ){
XLI_Technical_Attribute__c techAttribute = new XLI_Technical_Attribute__c();
techAttribute.Quote_Line_Item__c  = qli.id;
if(mapOfTechProduct.containsKey(qli.Product2Id)){
techAttribute.Technical_Product__c = mapOfTechProduct.get(qli.Product2Id).vlocity_cmt__DestinationProductId__c;
techAttribute.Technical_Attribute_Metadata__c =mapOfTechProduct.get(qli.Product2Id).vlocity_cmt__DestinationProductId__r.vlocity_cmt__AttributeMetadata__c;
techAttribute.Technical_Attribute__c = mapOfTechProduct.get(qli.Product2Id).vlocity_cmt__DestinationProductId__r.vlocity_cmt__JSONAttribute__c;
//techAttribute.AttributeMetadataChanges__c = mapOfTechProduct.get(qli.Product2Id).vlocity_cmt__DestinationProductId__c;
}
lstTechnicalAttributetobeCreated.add(techAttribute);
}
}
if(!lstTechnicalAttributetobeCreated.isEmpty()){
Insert lstTechnicalAttributetobeCreated;
}
}

public static void createAllTechnicalProducts(Map<Id,QuoteLineItem> newMap){
Set<String> setOfTechnicalProductCodes = new Set<String>();
Map<String, Product2> mapOfTechnicalProduct = new Map<String, Product2>();
Map<String, Set<String>> mapOfQLwithTechProductCode = new Map<String, Set<String>>();
List<XLI_Technical_Attribute__c> lstTechnicalAttributetobeCreated = new List<XLI_Technical_Attribute__c>();
Map<String,Id> mapOfrootQLI = new Map<String,Id>();
for(QuoteLineItem qli: [Select Id, Product2.ARTL_TechnicalProduct__c, vlocity_cmt__RootItemId__c, vlocity_cmt__ParentItemId__c 
FROM QuoteLineItem WHERE
Id IN:newMap.keySet()]){
if(qli.Product2.ARTL_TechnicalProduct__c != null){
for(String prodCode : qli.Product2.ARTL_TechnicalProduct__c.split(',')){
setOfTechnicalProductCodes.add(prodCode);
if(mapOfQLwithTechProductCode.containsKey(qli.Id)){
mapOfQLwithTechProductCode.get(qli.Id).add(prodCode);
}else{
mapOfQLwithTechProductCode.put(qli.Id, new Set<String>{prodCode});
}
} 
}
if(qli.vlocity_cmt__ParentItemId__c == null){
mapOfrootQLI.put(qli.vlocity_cmt__RootItemId__c,qli.id);
}                   
}
System.debug('setOfTechnicalProductCodes>>>'+setOfTechnicalProductCodes);
if(getlistOfTechnicalAttr(newMap).size() == 0){
System.debug('mapOfQLwithTechProductCode>>>'+mapOfQLwithTechProductCode);
for(Product2 objprod: [Select id,ProductCode,vlocity_cmt__JSONAttribute__c,vlocity_cmt__AttributeDefaultValues__c ,
vlocity_cmt__AttributeMetadata__c 
FROM Product2 WHERE (ProductCode IN:setOfTechnicalProductCodes
OR Id IN:setOfTechnicalProductCodes)]){
mapOfTechnicalProduct.put(objprod.ProductCode,objprod);
}
System.debug('setOfTechnicalProductCodes>>>'+setOfTechnicalProductCodes);
for(String qlId: mapOfQLwithTechProductCode.keySet()){
System.debug('qlId>>>'+qlId);
for(String ProductCode: mapOfQLwithTechProductCode.get(qlId)){
System.debug('mapOfQLwithTechProductCode.get(qlId)>>>'+mapOfQLwithTechProductCode.get(qlId));
if(mapOfTechnicalProduct.containsKey(ProductCode)){
Product2 prod = mapOfTechnicalProduct.get(ProductCode);

XLI_Technical_Attribute__c techAttribute = new XLI_Technical_Attribute__c();

if(mapOfrootQLI.containsKey(newMap.get(qlId).vlocity_cmt__RootItemId__c)){
techAttribute.Root_Quote_Line_Item__c = mapOfrootQLI.get(newMap.get(qlId).vlocity_cmt__RootItemId__c);
}
techAttribute.Quote_Line_Item__c  = qlId;
techAttribute.Technical_Product__c = prod.Id;
techAttribute.Technical_Attribute_Metadata__c = prod.vlocity_cmt__AttributeMetadata__c;
techAttribute.Technical_Attribute__c = prod.vlocity_cmt__AttributeDefaultValues__c;
lstTechnicalAttributetobeCreated.add(techAttribute);
}
}
}        
System.debug('lstTechnicalAttributetobeCreated>>>'+lstTechnicalAttributetobeCreated);
if(!lstTechnicalAttributetobeCreated.isEmpty()){
Insert lstTechnicalAttributetobeCreated;
}
}

}

public static List<XLI_Technical_Attribute__c> getlistOfTechnicalAttr(Map<Id,QuoteLineItem> newMap){
return [Select id FROM XLI_Technical_Attribute__c WHERE Quote_Line_Item__c IN:newMap.keySet()];
}

*/
    // Counting QLI if product LSI is rquired : after insertion 
    
    
    public static void updateDOACapexFieldsFUpdate(Map<Id,QuoteLineItem> QLIOldMap,Map<Id,QuoteLineItem> QLINewMap){//QLINewMap
        Set<Id> dOAFieldChangedQuotes=new Set<Id>();
        Set<Id> capexFieldChangedQuotes=new Set<Id>();
        QuoteLineItem oldQli;
        
        Map<Id, Quote> quoteUpdateMap=new Map<Id, Quote>();
        
        try{
            //Catch QLI that need DOA Capex field value changes
            
            for(QuoteLineItem qli:QLINewMap.values()){
                oldQli=QLIOldMap != null ? QLIOldMap.get(qli.Id) : null;
                system.debug('oldQli=>'+JSON.serializePretty(oldQli));
                system.debug('newQli=>'+JSON.serializePretty(qli));
                if(oldQli != null && qli.ARTL_NeedDOAApproval__c != oldQli.ARTL_NeedDOAApproval__c){
                    dOAFieldChangedQuotes.add(qli.quoteId);
                }else if(oldQli == null && qli.ARTL_NeedDOAApproval__c){
                    dOAFieldChangedQuotes.add(qli.quoteId);
                }
                if(oldQli != null && qli.ARTL_NeedCapexApproval__c != oldQli.ARTL_NeedCapexApproval__c){
                    capexFieldChangedQuotes.add(qli.quoteId);
                }else if(oldQli == null && qli.ARTL_NeedCapexApproval__c){
                    capexFieldChangedQuotes.add(qli.quoteId);
                }
            }
            //List<Quote> doaRequiredQuoteList=[Select Id,Name,ARTL_QNeedDOAApproval__c,(Select Id,ARTL_NeedDOAApproval__c From QuoteLineItems Where ARTL_NeedDOAApproval__c = true limit 1) From Quote Where Id IN (Select QuoteId From  QuoteLineItem Where Id IN: dOAFieldChangedQLI)];
            //update DOA Field on Quote
            if(!dOAFieldChangedQuotes.isEmpty()){
                for(Quote q:[Select Id,Name,ARTL_QNeedDOAApproval__c,(Select Id,ARTL_NeedDOAApproval__c From QuoteLineItems Where ARTL_NeedDOAApproval__c = true limit 1) 
                             From Quote 
                             Where Id IN: dOAFieldChangedQuotes]){
                                 if(q.QuoteLineItems != null && !q.QuoteLineItems.isEmpty() && !q.ARTL_QNeedDOAApproval__c){
                                     quoteUpdateMap.put(q.Id,new Quote(Id=q.Id,ARTL_QNeedDOAApproval__c=true));
                                 }
                                 else if(q.ARTL_QNeedDOAApproval__c && (q.QuoteLineItems == null || q.QuoteLineItems.isEmpty())){
                                     quoteUpdateMap.put(q.Id, new Quote(Id= q.Id, ARTL_QNeedDOAApproval__c = false));
                                 }
                             }
            }
            //List<Quote> capexRequiredQuoteList=[Select Id,Name,ARTL_QNeedCapexApproval__c,(Select Id,ARTL_NeedCapexApproval__c From QuoteLineItems Where ARTL_NeedCapexApproval__c = true limit 1) From Quote Where Id IN (Select QuoteId From  QuoteLineItem Where Id IN: capexFieldChangedQLI)];
            //update Capex Field on Quote
            if(!capexFieldChangedQuotes.isEmpty()){
                for(Quote q:[SELECT Id,Name,ARTL_QNeedCapexApproval__c,
                             (SELECT Id,ARTL_NeedCapexApproval__c FROM QuoteLineItems WHERE ARTL_NeedCapexApproval__c = true LIMIT 1) 
                             FROM Quote WHERE Id IN : capexFieldChangedQuotes]
                   ){
                       //system.debug('quote in the loop=>'+JSON.serializePretty(q));
                       Quote updateCapexQuote;
                       if(q.QuoteLineItems != null && !q.QuoteLineItems.isEmpty() && !q.ARTL_QNeedCapexApproval__c){
                           if(quoteUpdateMap.containsKey(q.Id)){
                               updateCapexQuote = quoteUpdateMap.get(q.Id);
                           }else{
                               updateCapexQuote = new Quote(id = q.Id);
                           }
                           updateCapexQuote.ARTL_QNeedCapexApproval__c = true;
                           quoteUpdateMap.put(q.id, updateCapexQuote);
                           
                       }else if(q.ARTL_QNeedCapexApproval__c && (q.QuoteLineItems == null || q.QuoteLineItems.isEmpty())){
                           if(quoteUpdateMap.containsKey(q.Id)){
                               updateCapexQuote = quoteUpdateMap.get(q.Id);
                           }else{
                               updateCapexQuote = new Quote(id = q.Id);
                           }
                           updateCapexQuote.ARTL_QNeedCapexApproval__c = false;
                           quoteUpdateMap.put(q.id, updateCapexQuote);
                       }
                   }
            }
            
            
            //update the Quote
            if(!quoteUpdateMap.isEmpty()){
                update quoteUpdateMap.values();
            }
            system.debug('updated quote value=>'+JSON.serializePretty(quoteUpdateMap));
            
            
        }catch(Exception e){
            System.debug('Exception in class::QuoteLineItemTriggerHelper and method::updateDOACapexFields @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
    }
    
    
    public static void AggregateToQuote(List<QuoteLineItem> qliList , map<id,QuoteLineItem> oldMapQli){
        
        set<id> POQliSet = new Set<id>();
        map<id,Quote> QuotePoLSIUpdateMap = new Map<id,Quote>();
        set<id> dupPoCheck = new Set<id>();
        set<id> LSIQliSet = new Set<id>();
        
        set<id> LSIQuoteIdSet = new Set<id>();
        //set<id> LSIQliSet = new Set<id>();
        
        List<QuoteLineItem> quoteToUpdate = new List<QuoteLineItem>(); 
        try{
            if(!qliList.isEmpty()){
                for(QuoteLineItem qli : qliList){
                    // system.debug('oldMapQli :::' + (qli.id));
                    //system.debug('new qli po val :::' + qli.ARTL_Purchase_Order__c);
                    /*
                    if(qli.ARTL_Purchase_Order__c != Null  &&  oldMapQli == Null){                                                   									      // for insert
                        POQliSet.add(qli.Id);
                        // system.debug('Atter QLI Insert for PO :::' + POQliSet);
                    }
                    else if(oldMapQli != null && oldMapQli.containskey(qli.id) && qli.ARTL_Purchase_Order__c != Null  && oldMapQli.get(qli.id).ARTL_Purchase_Order__c != qli.ARTL_Purchase_Order__c   ){     //  po != null && with oldmap                                              // update
                        // system.debug('Inside else while adding QLi');
                        POQliSet.add(qli.Id);
                    }
                    */
                    /*
                    if(qli.vlocity_cmt__Product2Id__c != Null  &&  oldMapQli == Null){   // vlocity_cmt__Product2Id__c                                                        // for insert
                        LSIQliSet.add(qli.Id);
                        LSIQuoteIdSet.add(qli.QuoteId);
                        // system.debug('Atter QLI Insert for LSI:::' + LSIQliSet);
                        
                    }
                    //wont get in to this else if case
                    else if(oldMapQli != null && oldMapQli.get(qli.id).vlocity_cmt__Product2Id__c != qli.vlocity_cmt__Product2Id__c && qli.vlocity_cmt__Product2Id__c != Null ){     //  po != null && with oldmap                                              // update
                        LSIQliSet.add(qli.Id);
                        LSIQuoteIdSet.add(qli.QuoteId);
                    }   
                    */
                    LSIQuoteIdSet.add(qli.QuoteId);
                }
                //  system.debug('new map' + qliList);		// vlocity_cmt__Product2Id__c
                //   system.debug('old map' + oldMapQli);
            }
            /*
            if(!POQliSet.isEmpty()){
                system.debug('POQliSet query==>'+JSON.serializepretty([SELECT id ,quoteId, ARTL_Purchase_Order__c , ARTL_Purchase_Order__r.Amount__c
                                                                       FROM QuoteLineItem 
                                                                       WHERE Id IN: POQliSet  ]));
                
                for(quoteLineItem qli : [SELECT id ,quoteId, ARTL_Purchase_Order__c , ARTL_Purchase_Order__r.Amount__c
                                         FROM QuoteLineItem 
                                         WHERE Id IN: POQliSet  ]){
                                             if(!dupPoCheck.contains(qli.ARTL_Purchase_Order__c)){
                                                 if(!QuotePoLSIUpdateMap.containsKey(qli.quoteId)){
                                                     QuotePoLSIUpdateMap.put(qli.quoteId , new Quote(id = qli.quoteId  ,ARTL_PO_Total__c = qli.ARTL_Purchase_Order__r.Amount__c != Null  ? qli.ARTL_Purchase_Order__r.Amount__c : 0 )); 
                                                 }else {
                                                     QuotePoLSIUpdateMap.get(qli.QuoteId).ARTL_PO_Total__c += qli.ARTL_Purchase_Order__r.Amount__c != Null  ? qli.ARTL_Purchase_Order__r.Amount__c : 0  ;
                                                 }
                                                 dupPoCheck.add(qli.ARTL_Purchase_Order__c);
                                             }
                                             
                                         }
                
            }
            system.debug('QuotePoLSIUpdateMap poqli==>'+JSON.serializepretty(QuotePoLSIUpdateMap));
            */
            //SM added this on feb 19 ,2024 for PO Total Update
            if(!LSIQuoteIdSet.isEmpty()){
                
                for(quoteLineItem qli : [SELECT id ,quoteId, ARTL_Purchase_Order__c , ARTL_Purchase_Order__r.Amount__c
                                         FROM QuoteLineItem 
                                         WHERE QuoteId IN: LSIQuoteIdSet and ARTL_Purchase_Order__c != null  ]){
                                             if(!dupPoCheck.contains(qli.ARTL_Purchase_Order__c)){
                                                 if(!QuotePoLSIUpdateMap.containsKey(qli.quoteId)){
                                                     QuotePoLSIUpdateMap.put(qli.quoteId , new Quote(id = qli.quoteId  ,ARTL_PO_Total__c = qli.ARTL_Purchase_Order__r.Amount__c != Null  ? qli.ARTL_Purchase_Order__r.Amount__c : 0 )); 
                                                 }else {
                                                     QuotePoLSIUpdateMap.get(qli.QuoteId).ARTL_PO_Total__c += qli.ARTL_Purchase_Order__r.Amount__c != Null  ? qli.ARTL_Purchase_Order__r.Amount__c : 0  ;
                                                 }
                                                 dupPoCheck.add(qli.ARTL_Purchase_Order__c);
                                             }
                                             
                                         }
                
            }
            
            /*commenetd by SM on feb 19 ,2024
            if(!LSIQliSet.isEMpty())
            {
                system.debug('LSIQliSet query==>'+JSON.serializepretty([SELECT quoteId,count(Id) lsiCount 
                                                                        FROM QuoteLineItem 
                                                                        WHERE Id IN: LSIQliSet AND vlocity_cmt__Product2Id__r.ARTL_LSIRequired__c = true 
                                                                        GROUP BY  QuoteId ]));
                
                
                for(AggregateResult qli : [SELECT quoteId,count(Id) lsiCount 
                                           FROM QuoteLineItem 
                                           WHERE Id IN: LSIQliSet AND vlocity_cmt__Product2Id__r.ARTL_LSIRequired__c = true 
                                           GROUP BY  QuoteId ]){
                                               
                                               id quoteId = (id) qli.get('quoteId');
                                               if(!QuotePoLSIUpdateMap.containsKey(quoteId)){
                                                   QuotePoLSIUpdateMap.put(quoteId , new Quote(id = quoteId ,ARTL_LSI_Count__c = (Integer) qli.get('lsiCount'))); 
                                               }else{
                                                   QuotePoLSIUpdateMap.get(quoteId).ARTL_LSI_Count__c = (Integer) qli.get('lsiCount')  ;
                                               }
                                           }
            }
            */
            //SM added this on feb 19 ,2024 for LSI Count Update
            if(!LSIQuoteIdSet.isEMpty())
            {
                
                for(AggregateResult qli : [SELECT quoteId,count(Id) lsiCount 
                                           FROM QuoteLineItem 
                                           WHERE QuoteId IN: LSIQuoteIdSet AND vlocity_cmt__Product2Id__r.ARTL_LSIRequired__c = true 
                                           GROUP BY  QuoteId ]){
                                               
                                               id quoteId = (id) qli.get('quoteId');
                                               if(!QuotePoLSIUpdateMap.containsKey(quoteId)){
                                                   QuotePoLSIUpdateMap.put(quoteId , new Quote(id = quoteId ,ARTL_LSI_Count__c = (Integer) qli.get('lsiCount'))); 
                                               }else{
                                                   QuotePoLSIUpdateMap.get(quoteId).ARTL_LSI_Count__c = (Integer) qli.get('lsiCount')  ;
                                               }
                                           }
            }
            //end
            
            
            // system.debug('QuotePoLSIUpdateMap lsiqli==>'+JSON.serializepretty(QuotePoLSIUpdateMap));
            
            system.debug('QuotePoLSIUpdateMap ::::' + QuotePoLSIUpdateMap);
            
            if(!QuotePoLSIUpdateMap.isEmpty()){
                system.debug('QuotePoLSIUpdateMap quote Values :::' + QuotePoLSIUpdateMap.values());
                update QuotePoLSIUpdateMap.values();
            }
        }
        catch(exception e){
            System.debug('Exception in class::QuoteLineItemTriggerHelper and method::AggregateQuotePO @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
        
    }
    
    // public static void updateQliLSiField(Set<Id> qliIds){
    //     List<QuotelIneItem> qliUpdate = new List<QuoteLineItem>(); 
    //     for(quoteLineItem qli : [SELECT id ,product_lsi_check__c , product2.ARTL_LSIRequired__c FROM QuoteLineItem WHERE id IN: qliIds ] ){
    //         qli.product_lsi_check__c = qli.product2.ARTL_LSIRequired__c;
    //         system.debug('product lsi Chck :::' + qli.product_lsi_check__c);
    //         qliUpdate.add(qli);
    //     }   
    //     if(!qliUpdate.isEmpty()){
    //         Update qliUpdate;
    //     }
    // }
    
    /*Commented by Saurav::updateDOACapexFieldFInsert
public static void updateDOACapexFieldFInsert(Map<Id,QuoteLineItem> QLINewMap){
Set<Id> dOAFieldChangedQLI=new Set<Id>();
Set<Id> capexFieldChangedQLI=new Set<Id>();
Set<Id> quoteIdSet=new Set<Id>();
Map<Id, Quote> quoteUpdateMap=new Map<Id, Quote>();
Quote updateCapexQuote;
try{
//catch DOA Fields and Capex fields
system.debug('updateDOACapexFieldFInsert');
for(QuoteLineItem qli:QLINewMap.values()){
if(qli.ARTL_NeedDOAApproval__c == true){
dOAFieldChangedQLI.add(qli.QuoteId);
if(!quoteIdSet.contains(qli.QuoteId)){
quoteIdSet.add(qli.QuoteId);
}
}
if(qli.ARTL_NeedCapexApproval__c == true){
capexFieldChangedQLI.add(qli.QuoteId);
if(!quoteIdSet.contains(qli.QuoteId)){
quoteIdSet.add(qli.QuoteId);
}
}
}
system.debug('insert dOAFieldChangedQLI=>'+JSON.serializePretty(dOAFieldChangedQLI));
system.debug('insert capexFieldChangedQLI=>'+JSON.serializePretty(capexFieldChangedQLI));
for(Quote q:[Select id,ARTL_QNeedDOAApproval__c,ARTL_QNeedCapexApproval__c from Quote where Id IN:quoteIdSet]){

if(q.ARTL_QNeedDOAApproval__c == false && dOAFieldChangedQLI.contains(q.Id)){
quoteUpdateMap.put(q.id, new Quote(Id= q.Id, ARTL_QNeedDOAApproval__c = true));
}
else if(q.ARTL_QNeedCapexApproval__c == false && capexFieldChangedQLI.contains(q.Id)){
if(quoteUpdateMap.containsKey(q.Id)){
updateCapexQuote=quoteUpdateMap.get(q.Id);
updateCapexQuote.put('ARTL_QNeedCapexApproval__c',true);
}else{
quoteUpdateMap.put(q.id, new Quote(Id= q.Id, ARTL_QNeedCapexApproval__c = true));
}
}
}
update quoteUpdateMap.values();
}catch(Exception e){
System.debug('Exception in class::QuoteLineItemTriggerHelper and method::updateDOACapexFieldFInsert @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
}
}
*/
    /* public static Map<String,vlocity_cmt__DecompositionRelationship__c> getTechnicalProductDetails(Set<String> setOfProductIds){
Map<String,vlocity_cmt__DecompositionRelationship__c> mapOfTechProduct = new Map<String,vlocity_cmt__DecompositionRelationship__c>();
for(vlocity_cmt__DecompositionRelationship__c  prod: 
[Select Id,vlocity_cmt__DestinationProductId__r.ProductCode,vlocity_cmt__DestinationProductId__c,
vlocity_cmt__DestinationProductId__r.vlocity_cmt__AttributeMetadata__c,
vlocity_cmt__DestinationProductId__r.vlocity_cmt__AttributeDefaultValues__c,
vlocity_cmt__DestinationProductId__r.vlocity_cmt__JSONAttribute__c,
vlocity_cmt__SourceProductId__c
FROM vlocity_cmt__DecompositionRelationship__c 
WHERE vlocity_cmt__SourceProductId__c IN:setOfProductIds
AND vlocity_cmt__DestinationProductId__c != null]){
mapOfTechProduct.put(prod.vlocity_cmt__SourceProductId__c,prod); 
}
return mapOfTechProduct;
}*/
    public static void updateQuoteValidationStatus(List<QuoteLineItem> triggerNewList, Map<Id, QuoteLineItem> oldMap) {
        Set<Id> quoteIdsToUpdateSet = new Set<Id>();
        
        for (QuoteLineItem qli : triggerNewList) {
              if( (qli.ARTL_Validation_Status__c=='Passed' || qli.ARTL_Validation_Status__c=='Failed') && qli.ARTL_Validation_Status__c != oldMap.get(qli.Id).ARTL_Validation_Status__c )
                 {
                
                    quoteIdsToUpdateSet.add(qli.QuoteId);
                 }
        }
        if(!quoteIdsToUpdateSet.isEmpty())
        {
            Map<String, Boolean> QuoteValidationUpdateMap = new Map<String, Boolean>();
            
            for(QuoteLineItem qli : [SELECT Id, ARTL_Validation_Status__c, QuoteId, Quote.vlocity_cmt__ValidationStatus__c FROM QuoteLineItem WHERE 
                                        vlocity_cmt__Product2Id__r.ARTL_LSIRequired__c=true AND Quoteid IN: quoteIdsToUpdateSet] )
            {
                if (qli.ARTL_Validation_Status__c != 'Passed' && qli.Quote.vlocity_cmt__ValidationStatus__c!='Failed') {
                    QuoteValidationUpdateMap.put(qli.QuoteId, false);
                }
                else if (qli.ARTL_Validation_Status__c == 'Passed' && qli.Quote.vlocity_cmt__ValidationStatus__c!='Passed'
                            && !QuoteValidationUpdateMap.containsKey(qli.QuoteId) ){
                                QuoteValidationUpdateMap.put(qli.QuoteId, true);
                            }
            }
            if (!QuoteValidationUpdateMap.isEmpty()) {
                List<Quote> quotesToUpdate = new List<Quote>();
                for (string key : QuoteValidationUpdateMap.keySet()) {
                    Quote quote = new Quote(Id = key, vlocity_cmt__ValidationStatus__c = QuoteValidationUpdateMap.get(key) ? 'Passed' : 'Failed');
                    quotesToUpdate.add(quote);
                }
                update quotesToUpdate;
            }
        }
    }
}