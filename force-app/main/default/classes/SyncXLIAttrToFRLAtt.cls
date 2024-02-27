/************************************************************************************************************************************************************************************************************
* @Author       : Vishal Kumar <vishal.kumar@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 18/10/2023
* @Test Class   : 
* @Description  : Sync XLI attribute to FRL Attribute 
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
*        1. SFDC-         Vishal Kumar          18/10/2023     Initial Dev
******************************************************************************************************************************************************************************************************************/

global with Sharing class SyncXLIAttrToFRLAtt implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask{
    
    global void executeBatch(List <vlocity_cmt__OrchestrationItem__c> items) {
        for (vlocity_cmt__OrchestrationItem__c item: items) {
            /* your custom logic here */
            //System.debug(LoggingLevel.INFO, 'Hello world: orchestration task Id = ' + item.Id);
            syncXLIAttToFRL(items);
        }
    } 
    
    global  void syncXLIAttToFRL(List<vlocity_cmt__OrchestrationItem__c> oItemsList){
        if(Test.isRunningTest()){
            oItemsList = [select id,vlocity_cmt__OrderItemId__r.OrderId from vlocity_cmt__OrchestrationItem__c];
        }
        List<Id> orderIdList = new List<Id>();
        for(vlocity_cmt__OrchestrationItem__c orItem: oItemsList){
            orderIdList.add(orItem.vlocity_cmt__OrderItemId__r.OrderId);
        }  
        Set<Id> QuoteLineItemIdList  = new Set<Id>();
        for(OrderItem ordItem : [ select id,vlocity_cmt__ParentOrderProduct__c, ARTL_QuoteLineItemId__c 
                                 from OrderItem 
                                 where vlocity_cmt__ParentOrderProduct__c = ''
                                 AND OrderId =: orderIdList
                                ]){
                                    QuoteLineItemIdList.add(ordItem.ARTL_QuoteLineItemId__c);
                                    
                                }
        /*   Map<String,Map<String,Object>> xliMap = new Map<String,Map<String,Object>>();

for(XLI_Technical_Attribute__c xli: [select id,Quote_Line_Item__c, Root_Quote_Line_Item__c,Technical_Attribute__c, 
Technical_Product__c from XLI_Technical_Attribute__c
where Root_Quote_Line_Item__c  =: QuoteLineItemIdList
]){

if(!xliMap.containskey(xli.Technical_Product__c) && xli.Technical_Attribute__c != NULL){
System.debug('xli.Technical_Attribute__c in 47###'+xli.Technical_Attribute__c);
Map<String, Object> techAttrMap = (Map<String, Object>) JSON.deserializeUntyped(xli.Technical_Attribute__c);
System.debug('techAttrMap### in 49'+techAttrMap);
xliMap.put(xli.Technical_Product__c,techAttrMap); 
}                                 
}

List<vlocity_cmt__FulfilmentRequestLine__c>  frlList = new List<vlocity_cmt__FulfilmentRequestLine__c>();
for(vlocity_cmt__FulfilmentRequestLine__c  frl: [select id, vlocity_cmt__Product2Id__c, vlocity_cmt__AttributeSelectedValues__c   
from vlocity_cmt__FulfilmentRequestLine__c 
where vlocity_cmt__Product2Id__c =: xliMap.keyset()
]){

Map<String, Object> FRLStringMap = new Map<String, Object> ();                         
if(xliMap.get(frl.vlocity_cmt__Product2Id__c) != NULL){

if(frl.vlocity_cmt__AttributeSelectedValues__c != NULL)
FRLStringMap = (Map<String, Object>) JSON.deserializeUntyped(frl.vlocity_cmt__AttributeSelectedValues__c);
else
FRLStringMap = new Map<String, Object>();
String FRLAttString = '';
Map<String, Object> xlvalue = xliMap.get(frl.vlocity_cmt__Product2Id__c);

if(FRLStringMap != null){
for(String s : FRLStringMap.keySet()){
if(xlvalue.containsKey(s)){
FRLStringMap.put(s,xlvalue.get(s));
xlvalue.remove(s);
}
}

if(xlvalue != null ){
FRLStringMap.putAll(xlvalue);
}

FRLAttString = JSON.serialize(FRLStringMap); 
}
frl.vlocity_cmt__AttributeSelectedValues__c = FRLAttString;
frlList.add(frl);   
}                                 
}
if(frlList.size() > 0){
update frlList;
} */
      /*   List<String> allProdCodeList = new List<String>();
         ARTL_Chargelist_Productcodes__mdt priceProdCodesList = [select Id,ARTL_Productcodes__c, DeveloperName from ARTL_Chargelist_Productcodes__mdt];
        if(priceProdCodesList!=NULL)
        {
             allProdCodeList = priceProdCodesList.ARTL_Productcodes__c.split(',');
        } */
        mapSelectedAttrWithMatrix(orderIdList);
    }
    
    public Static void mapSelectedAttrWithMatrix(List<Id> orderIdList){
        Map<String,Set<String>> techCommProdCodeMap = new Map<String,Set<String>>();
        Map<String,String> commProdARCFloorRateMap = new Map<String,String>();
        Map<String,String> commProdOTCFloorRateMap = new Map<String,String>();
        List<ARTL_Pricing_Productcodes__mdt> priceProdCodesList = [select Id,ARTL_Commercial_Product_Code__c,ARTL_Product_Code_and_Field_Name__c, ARTL_Productcodes__c, DeveloperName from ARTL_Pricing_Productcodes__mdt];
        List<String> allProdCodeList = new List<String>();
        List<String> prodCodeList = new List<String>();
        List<String> bwProdCodeList = new List<String>{'VEPC_Bandwidth_OTC_CFS','VEPC_Access_Bandwidth_ARC_CFS'};
            List<String> pcFiledNameList = new List<String>();
        Map<String,Map<String,String>> prodAttrFieldMap = new Map<String,Map<String,String>>();
        Map<String,String> prdCodeRateRowIdMap = new Map<String,String>();
        List<vlocity_cmt__FulfilmentRequestLine__c>  frlList = new List<vlocity_cmt__FulfilmentRequestLine__c>();
        Map<String,ARTL_Rate_Spec_Key_Matrix__c> rateSpecKeyMap = new Map<String,ARTL_Rate_Spec_Key_Matrix__c>();
        Map<String,Map<String,Object>> attrFieldValMap = new Map<String,Map<String,Object>>();
        List<vlocity_cmt__FulfilmentRequestLine__c>  fullfillReqList = new List<vlocity_cmt__FulfilmentRequestLine__c>();
        List<ARTL_Rate_Spec_Key_Matrix__c> rskMatrixList = new List<ARTL_Rate_Spec_Key_Matrix__c>();
        for(ARTL_Pricing_Productcodes__mdt prodMeta: priceProdCodesList){
            if(prodMeta.DeveloperName == 'Productcode'){
                allProdCodeList = prodMeta.ARTL_Productcodes__c.split(',');
                allProdCodeList.add('VEPC_PRIMARY_LINK_CFS');
                allProdCodeList.add('VEPC_MPLS_LINK_CFS');
                for(String prodCode : prodMeta.ARTL_Productcodes__c.split(',')){
                    if(!bwProdCodeList.contains(prodCode)){
                        prodCodeList.add(prodCode); 
                    }
                }
            }else{
                if(String.ISNOTBLANK(prodMeta.ARTL_Commercial_Product_Code__c)){
                    for(String commPC :prodMeta.ARTL_Commercial_Product_Code__c.split(',')){
                        if(!techCommProdCodeMap.containsKey(prodMeta.ARTL_Productcodes__c)) {
                            techCommProdCodeMap.put(prodMeta.ARTL_Productcodes__c, new Set<String>());
                        }
                        if(prodMeta.ARTL_Productcodes__c.endsWith('OTC_CFS')){
                            techCommProdCodeMap.get(prodMeta.ARTL_Productcodes__c).add(commPC+':OTC');
                        } if(prodMeta.ARTL_Productcodes__c.endsWith('ARC_CFS')){
                            techCommProdCodeMap.get(prodMeta.ARTL_Productcodes__c).add(commPC+':ARC');
                        }
                    }
                }
                if(String.ISNOTBLANK(prodMeta.ARTL_Product_Code_and_Field_Name__c)){
                    Map<String,String> attrFieldMap = new Map<String,String>();
                    pcFiledNameList = prodMeta.ARTL_Product_Code_and_Field_Name__c.split(',');
                    for(String pcField :pcFiledNameList){
                        attrFieldMap.put(pcField.split(':')[0],pcField.split(':')[1]);
                    }
                    if(String.ISNOTBLANK(prodMeta.ARTL_Productcodes__c)){
                        prodAttrFieldMap.put(prodMeta.ARTL_Productcodes__c,attrFieldMap);
                    }  
                }
            }
        }
        if(allProdCodeList.size() > 0){
            List<OrderItem> oitemList = [Select Id,ARTL_ARCFloorRate__c, ARTL_NRCFloorRate__c,Product2.productcode from OrderItem where OrderId =: orderIdList[0]];
            if(oitemList.size() > 0){
                for(OrderItem oi : oitemList){
                    if(oi.ARTL_NRCFloorRate__c != null)
                        commProdOTCFloorRateMap.put(oi.Product2.productcode+':OTC',String.valueof(oi.ARTL_NRCFloorRate__c.intValue()));
                    if(oi.ARTL_ARCFloorRate__c != null)
                        commProdARCFloorRateMap.put(oi.Product2.productcode+':ARC',String.valueof(oi.ARTL_ARCFloorRate__c.intValue()));
                }
            }
            
            Order RootProduct = [Select Id,ARTL_Root_ProductCode__c,CurrencyIsoCode from Order where  Id =: orderIdList[0]];
            
            List<vlocity_cmt__FulfilmentRequestLine__c> ffrList = [SELECT id, vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__r.Account.ARTL_Business_Unit__c,ARTL_RateSpecKey__c,   
                                                                   vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c FROM vlocity_cmt__FulfilmentRequestLine__c WHERE vlocity_cmt__Product2Id__r.ProductCode IN: allProdCodeList AND vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c IN: orderIdList];
            
            
            vlocity_cmt__FulfilmentRequestLine__c frlPrimary = new vlocity_cmt__FulfilmentRequestLine__c();
            
            if(ffrList.size() > 0){
                for(vlocity_cmt__FulfilmentRequestLine__c frl : ffrList){
                    if(frl.vlocity_cmt__Product2Id__c != NULL && (frl.vlocity_cmt__Product2Id__r.ProductCode == 'VEPC_PRIMARY_LINK_CFS' || frl.vlocity_cmt__Product2Id__r.ProductCode == 'VEPC_MPLS_LINK_CFS')){
                        frlPrimary = frl;
                    }else{
                        fullfillReqList.add(frl);
                    }
                }
            }
            if(String.isNotBlank(RootProduct.ARTL_Root_ProductCode__c) && String.isNotBlank(RootProduct.CurrencyIsoCode))
            {
                rskMatrixList = [SELECT Id,Name,ARTL_BandWidth__c,ARTL_BandWidth_Code__c,ARTL_BillingComponentId__c,ARTL_Business_Unit__c,ARTL_Business_Unit_Code__c,ARTL_Rate_Row_Type__c,
                                 ARTL_Charge_Name__c,ARTL_Currency_Code__c,ARTL_RootProduct__c,ARTL_Floor_Rate__c,ARTL_Productcode__c,ARTL_Rate_Row_Id__c,ARTL_Service_Type__c,ARTL_Service_Type_Code__c 
                                 FROM ARTL_Rate_Spec_Key_Matrix__c WHERE ARTL_Productcode__c IN: prodCodeList AND ARTL_RootProduct__c =: RootProduct.ARTL_Root_ProductCode__c AND CurrencyIsoCode =:RootProduct.CurrencyIsoCode];
            }
            
            
            
            if(frlPrimary != NULL){
                String accessBW = '';
                String serviceType = '';
                String businessUnit = '';
                
                Map<String, Object> friPriStringMap = new Map<String, Object> ();
                if(frlPrimary.vlocity_cmt__AttributeSelectedValues__c != NULL){
                    friPriStringMap = (Map<String, Object>) JSON.deserializeUntyped(frlPrimary.vlocity_cmt__AttributeSelectedValues__c);
                    if(friPriStringMap != NULL){
                        if(friPriStringMap.containsKey('ATT_TECH_SERVICE_TYPE')){
                            if(friPriStringMap.get('ATT_TECH_SERVICE_TYPE') != NULL){
                                serviceType = String.valueOf(friPriStringMap.get('ATT_TECH_SERVICE_TYPE'));
                            }
                        }
                        if(friPriStringMap.containsKey('ATT_TECH_ACCESS_BANDWIDTH')){
                            if(friPriStringMap.get('ATT_TECH_ACCESS_BANDWIDTH') != NULL){
                                accessBW = String.valueOf(friPriStringMap.get('ATT_TECH_ACCESS_BANDWIDTH'));
                            }
                        }
                    }
                }
                if(frlPrimary.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c != NULL){
                    businessUnit = frlPrimary.vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__r.Account.ARTL_Business_Unit__c;
                }
                
                if(String.isNotBlank(accessBW) && String.isNotBlank(serviceType) && String.isNotBlank(businessUnit) && String.isNotBlank(RootProduct.ARTL_Root_ProductCode__c) && String.isNotBlank(RootProduct.CurrencyIsoCode)){
                    List<ARTL_Rate_Spec_Key_Matrix__c> rskmList = [SELECT Id,Name,ARTL_BandWidth__c,ARTL_BandWidth_Code__c,ARTL_RootProduct__c,ARTL_BillingComponentId__c,ARTL_Business_Unit__c,ARTL_Business_Unit_Code__c,
                                                                   ARTL_Charge_Name__c,ARTL_Floor_Rate__c,ARTL_Currency_Code__c,ARTL_Productcode__c,ARTL_Rate_Row_Id__c,ARTL_Service_Type__c,ARTL_Service_Type_Code__c,ARTL_Rate_Row_Type__c   
                                                                   FROM ARTL_Rate_Spec_Key_Matrix__c WHERE ARTL_Productcode__c IN: bwProdCodeList AND ARTL_BandWidth__c=: accessBW AND ARTL_Service_Type__c =: serviceType AND ARTL_Business_Unit__c =: businessUnit AND ARTL_RootProduct__c =:RootProduct.ARTL_Root_ProductCode__c AND CurrencyIsoCode =:RootProduct.CurrencyIsoCode];
                    
                    
                    
                    
                    if(rskmList.size() > 0){
                        rskMatrixList.addAll(rskmList);
                    }
                }
            }
            
            if(rskMatrixList.size() > 0){
                
                
                for(ARTL_Rate_Spec_Key_Matrix__c rateSpecMat : rskMatrixList){
                    rateSpecKeyMap.put(rateSpecMat.ARTL_Productcode__c,rateSpecMat);
                    Map<String,Object> attrValMap = new Map<String,String>();
                    if(prodAttrFieldMap.containsKey(rateSpecMat.ARTL_Productcode__c)){
                        prdCodeRateRowIdMap.put(rateSpecMat.ARTL_Productcode__c,rateSpecMat.ARTL_Rate_Row_Id__c);
                        Map<String,String> attFieldNameMap = prodAttrFieldMap.get(rateSpecMat.ARTL_Productcode__c);
                        for(String attrKey :attFieldNameMap.keyset()){
                            if(attFieldNameMap.get(attrKey).equals('ARTL_BandWidth__c')){
                                attrValMap.put(attrKey,rateSpecMat.ARTL_BandWidth__c); 
                            }else if(attFieldNameMap.get(attrKey).equals('ARTL_BandWidth_Code__c')){
                                attrValMap.put(attrKey,rateSpecMat.ARTL_BandWidth_Code__c); 
                            }else if(attFieldNameMap.get(attrKey).equals('ARTL_BillingComponentId__c')){
                                attrValMap.put(attrKey,rateSpecMat.ARTL_BillingComponentId__c); 
                            }else if(attFieldNameMap.get(attrKey).equals('ARTL_Business_Unit__c')){
                                attrValMap.put(attrKey,rateSpecMat.ARTL_Business_Unit__c); 
                            }else if(attFieldNameMap.get(attrKey).equals('ARTL_Business_Unit_Code__c')){
                                attrValMap.put(attrKey,rateSpecMat.ARTL_Business_Unit_Code__c);
                            }else if(attFieldNameMap.get(attrKey).equals('ARTL_Charge_Name__c')){
                                attrValMap.put(attrKey,rateSpecMat.ARTL_Charge_Name__c);
                            }else if(attFieldNameMap.get(attrKey).equals('ARTL_Currency__c')){
                                attrValMap.put(attrKey,rateSpecMat.ARTL_Currency_Code__c);
                            }else if(attFieldNameMap.get(attrKey).equals('Floor_Rate')){
                                if(rateSpecMat.ARTL_Productcode__c.endsWith('OTC_CFS')){
                                    for(String code : techCommProdCodeMap.get(rateSpecMat.ARTL_Productcode__c)){
                                        if(commProdOTCFloorRateMap.get(code) != null)
                                            attrValMap.put(attrKey,commProdOTCFloorRateMap.get(code));
                                    }
                                } 
                                if(rateSpecMat.ARTL_Productcode__c.endsWith('ARC_CFS')){
                                    for(String code : techCommProdCodeMap.get(rateSpecMat.ARTL_Productcode__c)){
                                        if(commProdARCFloorRateMap.get(code) != null)
                                            attrValMap.put(attrKey,commProdARCFloorRateMap.get(code));
                                    }
                                }
                            }else if(attFieldNameMap.get(attrKey).equals('ARTL_Rate_Row_Id__c')){
                                attrValMap.put(attrKey,rateSpecMat.ARTL_Rate_Row_Id__c);
                            }else if(attFieldNameMap.get(attrKey).equals('ARTL_Rate_Row_Type__c')){
                                attrValMap.put(attrKey,rateSpecMat.ARTL_Rate_Row_Type__c);
                            }else if(attFieldNameMap.get(attrKey).equals('ARTL_Service_Type__c')){
                                attrValMap.put(attrKey,rateSpecMat.ARTL_Service_Type__c);
                            }else if(attFieldNameMap.get(attrKey).equals('ARTL_Service_Type_Code__c')){
                                attrValMap.put(attrKey,rateSpecMat.ARTL_Service_Type_Code__c);
                            }
                        }
                        attrValMap.put('ATT_StartDate',String.valueOf(System.today()));
                        if(attrValMap.size() > 0){
                            attrFieldValMap.put(rateSpecMat.ARTL_Productcode__c,attrValMap);
                        }else{
                            attrFieldValMap.put(rateSpecMat.ARTL_Productcode__c,new Map<String,Object>()); 
                        }                                                 
                    }
                }
            }
            
            if(fullfillReqList.size() > 0){
                for(vlocity_cmt__FulfilmentRequestLine__c  frl: fullfillReqList){
                    Map<String, Object> FRLStringMap = new Map<String, Object> ();
                    if(frl.vlocity_cmt__Product2Id__c != NULL && attrFieldValMap.containsKey(frl.vlocity_cmt__Product2Id__r.ProductCode)){
                        if(frl.vlocity_cmt__AttributeSelectedValues__c != NULL)
                            FRLStringMap = (Map<String, Object>) JSON.deserializeUntyped(frl.vlocity_cmt__AttributeSelectedValues__c);
                        else
                            FRLStringMap = new Map<String, Object>();
                        String FRLAttString = '';
                        Map<String,Object> attFieldValMap = attrFieldValMap.get(frl.vlocity_cmt__Product2Id__r.ProductCode);
                        if(FRLStringMap != null){
                            for(String s : FRLStringMap.keySet()){
                                if(attFieldValMap.containsKey(s)){
                                    FRLStringMap.put(s,attFieldValMap.get(s));
                                }
                            }
                            FRLAttString = JSON.serialize(FRLStringMap); 
                        }
                        if(prdCodeRateRowIdMap.containsKey(frl.vlocity_cmt__Product2Id__r.ProductCode)){
                            frl.ARTL_RateSpecKey__c= prdCodeRateRowIdMap.get(frl.vlocity_cmt__Product2Id__r.ProductCode);
                        }
                        frl.vlocity_cmt__AttributeSelectedValues__c = FRLAttString;
                        frlList.add(frl);
                    }  
                }
            }
            
        }
        
        
        if(frlList.size() > 0){
            update frlList;
        }
    }
    
}