@RestResource(urlMapping='/api/getQuoteLineItems/*')
global with sharing class ARTL_GetQLIsAPI {
    public static string fields, customfields, namespace='vlocity_cmt';
    
    @HttpGet
    global static void doGetPO() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String quoteId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String NBA_Number = '';
        String customerName = '';
        String Order_Type = '';
        List<sTRING> billingBCPId = new List<STRING>(); 
        Map<String, ContactPremiseRelation__c> contactPremiseRelationMap = new Map<String, ContactPremiseRelation__c>();
        Id userId = UserInfo.getUserId();
        try {
            sYSTEM.DEBUG('ARTL_GetQLIsAPI quoteId***** '+quoteId);
            List<QuoteLineItem> lstQLI = 
                [SELECT Quote.ARTL_Quote_Type__c,Quote.Status,Quote.Account.Name, Product2.Name ,ARTL_Purchase_Order__r.PO_Group__r.name,
                 ARTL_Feasibility__c,Quote.ARTL_NBA_Account__r.accountNumber,Quote.ARTL_NBA_Account__c,  Product2.ProductCode, Product2Id,
                 Product2.ARTL_OFT_Product_Name__c,
                 vlocity_cmt__QuoteMemberId__r.DCP_Record__c, vlocity_cmt__QuoteMemberId__r.DCP_Record__r.ARTL_BCP_DCP_Search_String__c, 
                 vlocity_cmt__BillingAccountId__r.BCP_DCP_Id__c,
                 ARTL_Purchase_Order__r.Tenure__c, ARTL_Purchase_Order__r.ARTL_PO_Number__c, ARTL_Purchase_Order__r.Amount__c,
                 ARTL_Purchase_Order__r.ARTL_PO_Date__c, ARTL_Purchase_Order__r.PO_Group__c,
                 vlocity_cmt__BillingAccountId__r.Billing_Level__c, vlocity_cmt__BillingAccountId__r.ARTL_Bill_Type__c,
                 vlocity_cmt__BillingAccountId__r.vlocity_cmt__BillFrequency__c, vlocity_cmt__BillingAccountId__r.vlocity_cmt__BillDeliveryMethod__c,
                 vlocity_cmt__BillingAccountId__r.ARTL_Legal_Entity__c, vlocity_cmt__BillingAccountId__r.ARTL_License_Company__c,PricebookEntryId,
                 vlocity_cmt__RootItemId__c,vlocity_cmt__ParentItemId__c,vlocity_cmt__AssetReferenceId__c, 
                 vlocity_cmt__LineNumber__c,Quantity,  vlocity_cmt__ProductHierarchyPath__c,  
                 vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringCostTotal__c,  
                 Annual_Recurring_Charge__c,vlocity_cmt__OneTimeCharge__c,vlocity_cmt__OneTimeTotal__c,
                 vlocity_cmt__AttributeSelectedValues__c,vlocity_cmt__Action__c ,Product2.ARTL_LSIRequired__c
                 FROM QuoteLineItem  
                 WHERE Quote.RecordType.DeveloperName= 'EnterpriseQuote'  
                 AND QuoteId =: quoteId ];
            
            User userRecord = [Select id,Email, UserRole.Name from user where id =: userId limit 1];
            
            
            Map<String ,String> qliBillingMap = new Map<String ,String>();
            Map<String ,String> qliBillingStagingMap = new Map<String ,String>();
            Map<String ,Map<String , String>> qliBillingAccountMap = new Map<String ,Map<String , String>>();
            Set<Id> qliIdSet = new Set<Id>();
            Set<Id> bcpIdSet = new Set<Id>();
            sYSTEM.DEBUG('ARTL_GetQLIsAPI lstQLI***** '+lstQLI);
            for(QuoteLineItem objQLI : lstQLI){
                if(objQLI.Product2.ARTL_LSIRequired__c == true){
                    if(objQLI.vlocity_cmt__BillingAccountId__c != null){
                        Map<String , String> BillingDataMap = new Map<String, String>();
                        BillingDataMap.put('BillingLevel',objQLI.vlocity_cmt__BillingAccountId__r.Billing_Level__c);
                        BillingDataMap.put('BillingMode',objQLI.vlocity_cmt__BillingAccountId__r.ARTL_Bill_Type__c);
                        BillingDataMap.put('BillFrequency',objQLI.vlocity_cmt__BillingAccountId__r.vlocity_cmt__BillFrequency__c);
                        BillingDataMap.put('BillDispatchMethod',objQLI.vlocity_cmt__BillingAccountId__r.vlocity_cmt__BillDeliveryMethod__c);
                        BillingDataMap.put('LegalEntity',objQLI.vlocity_cmt__BillingAccountId__r.ARTL_Legal_Entity__c);
                        BillingDataMap.put('LicenseCompany',objQLI.vlocity_cmt__BillingAccountId__r.ARTL_License_Company__c);
                        qliBillingAccountMap.put(objQLI.id , BillingDataMap);
                        billingBCPId.add(objQLI.vlocity_cmt__BillingAccountId__r.BCP_DCP_Id__c);
                        qliBillingMap.put( objQLI.vlocity_cmt__BillingAccountId__r.BCP_DCP_Id__c ,objQLI.id );
                        System.debug('billingBCPId.SIZE() LSI TRUE objQLI.vlocity_cmt__BillingAccountId__r.BCP_DCP_Id__c    '+objQLI.vlocity_cmt__BillingAccountId__r.BCP_DCP_Id__c);
                    }else{
                        qliIdSet.add(objQLI.id);
                    }
                }
            }
            
            sYSTEM.DEBUG('ARTL_GetQLIsAPI billingBCPId***** '+billingBCPId);
            System.debug('billingBCPId.SIZE()    '+billingBCPId.SIZE());
            System.debug('billingBCPId    '+billingBCPId);

            IF(billingBCPId.SIZE()>0){
                List<ContactPremiseRelation__c> contactPremiseRelationList = [select id,BCP_DCP_Number__c,ARTL_BCP_DCP_Search_String__c from ContactPremiseRelation__c where BCP_DCP_Number__c IN: billingBCPId AND BCP_DCP_Number__c!= NULL ];
                if(contactPremiseRelationList.size()>0){
                    FOR(ContactPremiseRelation__c contactPremiseRelationRecord : contactPremiseRelationList){
                        contactPremiseRelationMap.put(qliBillingMap.get(contactPremiseRelationRecord.BCP_DCP_Number__c) , contactPremiseRelationRecord);
                    }
                }
            }
            
            List<ARTL_Billing_Staging__c> billingStagingRec = [select id,NBA_Account_Number__c,Bill_Type__c, ARTL_Bill_Frequency__c, Billing_Level__c, ARTL_Bill_Dispatch_Method__c,Quote_Line_Item__c, Legal_Entity__c, License_Company__c from ARTL_Billing_Staging__c WHERE Quote_Line_Item__c =: qliIdSet and Quote_Line_Item__c!= null];
            for(ARTL_Billing_Staging__c billingStaging : billingStagingRec){
                Map<String , String> BillingDataMap = new Map<String, String>();
                bcpIdSet.add(billingStaging.BCP_Id__c);
                BillingDataMap.put('BillingLevel',billingStaging.Billing_Level__c);
                BillingDataMap.put('BillingMode',billingStaging.Bill_Type__c);
                BillingDataMap.put('BillFrequency',billingStaging.ARTL_Bill_Frequency__c);
                BillingDataMap.put('BillDispatchMethod',billingStaging.ARTL_Bill_Dispatch_Method__c);
                BillingDataMap.put('LegalEntity',billingStaging.Legal_Entity__c);
                BillingDataMap.put('LicenseCompany',billingStaging.License_Company__c);
                qliBillingAccountMap.put(billingStaging.Quote_Line_Item__c , BillingDataMap);
            }
            Map<id , ContactPremiseRelation__c> contactPremiseRelationMapBcp = new Map<id , ContactPremiseRelation__c>([select id,BCP_DCP_Number__c,ARTL_BCP_DCP_Search_String__c from ContactPremiseRelation__c where BCP_DCP_Number__c IN: bcpIdSet and BCP_DCP_Number__c!=null]);
            for(ARTL_Billing_Staging__c billingStaging : billingStagingRec){
                if(contactPremiseRelationMapBcp.containsKey(billingStaging.BCP_Id__c)){
                    contactPremiseRelationMap.put(billingStaging.Quote_Line_Item__c , contactPremiseRelationMapBcp.get(billingStaging.BCP_Id__c));
                }
                
            }
            
                       
            
            
            sYSTEM.DEBUG('ARTL_GetQLIsAPI contactPremiseRelationMap***** '+contactPremiseRelationMap);
            
            System.debug('***lstQLI*** '+lstQLI);
            Map<String,List<Object>> mapRootLineItemToRecords =  new Map<String,List<Object>>();
            Map<String,Id> mapRootItemIdToSFid = new Map<String,Id>();
            Map<String,String> mapRootItemIdToProductCode = new Map<String,String>();
            for(QuoteLineItem objQLI : lstQLI){
                NBA_Number = objQLI.Quote.ARTL_NBA_Account__r.accountNumber;
                customerName = objQLI.Quote.Account.Name;
                Order_Type = objQLI.Quote.ARTL_Quote_Type__c;
                if(objQLI.vlocity_cmt__ParentItemId__c == null){
                    mapRootItemIdToSFid.put(objQLI.vlocity_cmt__RootItemId__c, objQLI.Id);
                    mapRootItemIdToProductCode.put(objQLI.vlocity_cmt__RootItemId__c , objQLI.Product2.ProductCode);
                }
                List<Object> lstLineItems = new List<Object>();
                if(mapRootLineItemToRecords.containsKey(objQLI.vlocity_cmt__RootItemId__c)){
                    lstLineItems = mapRootLineItemToRecords.get(objQLI.vlocity_cmt__RootItemId__c);    
                }
                Object lineItem = getJSONForLineItemPO(objQLI , contactPremiseRelationMap ,qliBillingAccountMap);
                lstLineItems.add(lineItem);
                mapRootLineItemToRecords.put(objQLI.vlocity_cmt__RootItemId__c,lstLineItems);
            }
            system.debug('mapRootLineItemToRecords:'+mapRootLineItemToRecords);
            res.statusCode = 200;
            Map<String,Object> mapResp = new Map<String,Object>();
            List<Object> records = new List<Object>();
            for(String srtRootItemId: mapRootLineItemToRecords.keyset()){
                Map<String,Object> mapLineItems = new Map<String,Object>();
                Object lineItem = (Object)mapRootLineItemToRecords.get(srtRootItemId);
                system.debug('lineitem::'+JSON.serialize(lineItem));
                mapLineItems.put('lineItems',lineItem);
                mapLineItems.put('productCode',mapRootItemIdToProductCode.get(srtRootItemId));
                mapLineItems.put('rootItemId',srtRootItemId);
                mapLineItems.put('rootItemSFid',mapRootItemIdToSFid.get(srtRootItemId));
                
                System.debug('mapRootItemIdToProductCode ' +mapRootItemIdToProductCode);
                
                //{'lineItems'=>(Object)mapRootLineItemToRecords.get('srtRootItemId'),'rootItemId'=>srtRootItemId};
                records.add(mapLineItems);
            }
            mapResp.put('records',records);
            mapResp.put('SecurityKey','2345');
            mapResp.put('DownloadDateTime',System.today());
            mapResp.put('NBANumber',NBA_Number);
            mapResp.put('customerName',customerName);
            mapResp.put('cartId',quoteId);
            mapResp.put('orderType','New');
            mapResp.put('userEmail',userRecord.email);
            mapResp.put('userRole',userRecord.UserRole.Name);
            
            
            system.debug('mapResp: '+mapResp);
            //System.RestResponse resp = new System.RestResponse();
            res.responseBody = Blob.valueOF(JSON.serialize(mapResp));
        } catch (Exception e) {
            res.responseBody = Blob.valueOF(e.getStackTraceString() +'  '+e.getMessage()+'  '+e.getLineNumber()+'  '+e.getCause());
            System.debug('error msg### ' + e.getMessage());
            System.debug('error msg### ' + e.getStackTraceString());
        }
    }
    
    
    @TestVisible
    private static Object getJSONForLineItemPO(QuoteLineItem lineItem , Map<String, ContactPremiseRelation__c> contactPremiseRelationMap , Map<String ,Map<String , String>> qliBillingAccountMap){
        List<String> quoteStatus = new List<String>{'Contract Generated','Customer Signed','Order Created'};
        Map<String,Object> mapLineItem = new Map<String,Object>();
        Map<String,Object> mapPrice = new Map<String,Object>();
        Map<String,Object> mapProduct = new Map<String,Object>();
        Map<String,Object> mapProductPO = new Map<String,Object>();
        Map<String,Object> mapBillingData = new Map<String,Object>();
        Map<String,Object> mapBCP = new Map<String,Object>();
        Map<String,Object> mapDCP = new Map<String,Object>();
        mapLineItem.put('linenumber',lineItem.vlocity_cmt__LineNumber__c);
        mapLineItem.put('Quantity',lineItem.Quantity);
        SYSTEM.DEBUG('ARTL_GetQLIsAPI getJSONForLineItemPO contactPremiseRelationMap***** '+contactPremiseRelationMap);
        SYSTEM.DEBUG('ARTL_GetQLIsAPI getJSONForLineItemPO qliBillingAccountMap***** '+qliBillingAccountMap);
        if(lineItem.Product2.ARTL_LSIRequired__c == true){
            System.debug('lineItem    '+lineItem);
            ContactPremiseRelation__c ContactPremiseRelationRecord = new ContactPremiseRelation__c();
            /*if(contactPremiseRelationMap.keySet().size()>0){
                ContactPremiseRelationRecord = contactPremiseRelationMap.get(lineItem.vlocity_cmt__BillingAccountId__r.BCP_DCP_Id__c);
              }*/
            sYSTEM.DEBUG('ARTL_GetQLIsAPI getJSONForLineItemPO ContactPremiseRelationRecord***** '+ContactPremiseRelationRecord);
            
            if(lineItem.Product2.ARTL_OFT_Product_Name__c != null){
                mapLineItem.put('FeasibilityId',lineItem.ARTL_Feasibility__c);
            }
            
            mapProductPO.put('POTerm',lineItem.ARTL_Purchase_Order__r.Tenure__c);
            mapProductPO.put('PONumber',lineItem.ARTL_Purchase_Order__r.ARTL_PO_Number__c);
            mapProductPO.put('POAmount',lineItem.ARTL_Purchase_Order__r.Amount__c);
            mapProductPO.put('PODate',lineItem.ARTL_Purchase_Order__r.ARTL_PO_Date__c);
            //mapProductPO.put('POId','');
            mapProductPO.put('POGroupId',lineItem.ARTL_Purchase_Order__r.PO_Group__r.name);
            
            
            if(qliBillingAccountMap.containsKey(lineItem.id)){
                SYSTEM.DEBUG('ARTL_GetQLIsAPI getJSONForLineItemPO qliBillingAccountMap.containsKey(lineItem.id)***** '+qliBillingAccountMap.containsKey(lineItem.id));
                mapBillingData.put('BillingLevel',qliBillingAccountMap.get('BillingLevel'));
                mapBillingData.put('BillingMode',qliBillingAccountMap.get('BillingMode'));
                mapBillingData.put('BillFrequency',qliBillingAccountMap.get('BillFrequency'));
                mapBillingData.put('BillDispatchMethod',qliBillingAccountMap.get('BillDispatchMethod'));
                mapBillingData.put('LegalEntity',qliBillingAccountMap.get('LegalEntity'));
                mapBillingData.put('LicenseCompany',qliBillingAccountMap.get('LicenseCompany'));
            }else{
                SYSTEM.DEBUG('ARTL_GetQLIsAPI getJSONForLineItemPO qliBillingAccountMap***** else');
                mapBillingData.put('BillingLevel',null);
                mapBillingData.put('BillingMode',null);
                mapBillingData.put('BillFrequency',null);
                mapBillingData.put('BillDispatchMethod',null);
                mapBillingData.put('LegalEntity',null);
                mapBillingData.put('LicenseCompany',null);
            }
            sYSTEM.DEBUG('ARTL_GetQLIsAPI getJSONForLineItemPO mapProductPO***** '+mapProductPO);
            /*if(quoteStatus.contains(lineItem.Quote.Status)){
                sYSTEM.DEBUG('ARTL_GetQLIsAPI lineItem.Quote.Status**** '+lineItem.Quote.Status);
                mapBillingData.put('BillingLevel',lineItem.vlocity_cmt__BillingAccountId__r.Billing_Level__c);
                mapBillingData.put('BillingMode',lineItem.vlocity_cmt__BillingAccountId__r.ARTL_Bill_Type__c);
                mapBillingData.put('BillFrequency',lineItem.vlocity_cmt__BillingAccountId__r.vlocity_cmt__BillFrequency__c);
                mapBillingData.put('BillDispatchMethod',lineItem.vlocity_cmt__BillingAccountId__r.vlocity_cmt__BillDeliveryMethod__c);
                mapBillingData.put('LegalEntity',lineItem.vlocity_cmt__BillingAccountId__r.ARTL_Legal_Entity__c);
                mapBillingData.put('LicenseCompany',lineItem.vlocity_cmt__BillingAccountId__r.ARTL_License_Company__c);
                }else{
                ARTL_Billing_Staging__c billingStagingRec = [select id,NBA_Account_Number__c,Bill_Type__c, ARTL_Bill_Frequency__c, Billing_Level__c, ARTL_Bill_Dispatch_Method__c, Legal_Entity__c, License_Company__c from ARTL_Billing_Staging__c WHERE (NBA_Account_Number__c=:lineItem.Quote.ARTL_NBA_Account__c OR NBA_Account_Number__c=:lineItem.Quote.ARTL_NBA_Account__r.accountNumber) AND NBA_Account_Number__c!=null LIMIT 1];
                sYSTEM.DEBUG('ARTL_GetQLIsAPI billingStagingRec**** '+billingStagingRec);
                mapBillingData.put('BillingLevel',billingStagingRec.Billing_Level__c);
                mapBillingData.put('BillingMode',billingStagingRec.Bill_Type__c);
                mapBillingData.put('BillFrequency',billingStagingRec.ARTL_Bill_Frequency__c);
                mapBillingData.put('BillDispatchMethod',billingStagingRec.ARTL_Bill_Dispatch_Method__c);
                mapBillingData.put('LegalEntity',billingStagingRec.Legal_Entity__c);
                mapBillingData.put('LicenseCompany',billingStagingRec.License_Company__c);
               }*/
            
            
            sYSTEM.DEBUG('ARTL_GetQLIsAPI getJSONForLineItemPO mapBillingData***** '+mapBillingData);
            
            
            if(contactPremiseRelationMap.containsKey(lineItem.id)){
                SYSTEM.DEBUG('ARTL_GetQLIsAPI getJSONForLineItemPO contactPremiseRelationMap***** contactPremiseRelationMap.containsKey(lineItem.id)   '+contactPremiseRelationMap.containsKey(lineItem.id));
                ContactPremiseRelationRecord = contactPremiseRelationMap.get(lineItem.id);
                mapBCP.put('BCDPStr',ContactPremiseRelationRecord.ARTL_BCP_DCP_Search_String__c);
                mapBCP.put('BCPId',ContactPremiseRelationRecord.Id);
            }else{
                SYSTEM.DEBUG('ARTL_GetQLIsAPI getJSONForLineItemPO contactPremiseRelationMap***** else');
                mapBCP.put('BCDPStr',null);
                mapBCP.put('BCPId',null);
            }
                        
            mapDCP.put('DCDPStr',lineItem.vlocity_cmt__QuoteMemberId__r.DCP_Record__r.ARTL_BCP_DCP_Search_String__c);
            mapDCP.put('DCPId',lineItem.vlocity_cmt__QuoteMemberId__r.DCP_Record__c);
            sYSTEM.DEBUG('ARTL_GetQLIsAPI getJSONForLineItemPO mapBCP***** '+mapBCP);
            sYSTEM.DEBUG('ARTL_GetQLIsAPI getJSONForLineItemPO mapDCP***** '+mapDCP);
            mapLineItem.put('POData',mapProductPO);
            mapLineItem.put('BillingData',mapBillingData);
            mapLineItem.put('BCP',mapBCP);
            mapLineItem.put('DCP',mapDCP);
            sYSTEM.DEBUG('ARTL_GetQLIsAPI getJSONForLineItemPO mapLineItem***** '+mapLineItem);
        }
        
        
        
        mapPrice.put('vlocity_cmt__RecurringCharge__c',lineItem.vlocity_cmt__RecurringCharge__c);
        mapPrice.put('vlocity_cmt__RecurringCostTotal__c',lineItem.vlocity_cmt__RecurringCostTotal__c);
        mapPrice.put('Annual_Recurring_Charge__c',lineItem.Annual_Recurring_Charge__c);
        mapPrice.put('vlocity_cmt__OneTimeCharge__c',lineItem.vlocity_cmt__OneTimeCharge__c);
        mapPrice.put('vlocity_cmt__OneTimeTotal__c',lineItem.vlocity_cmt__OneTimeTotal__c);
        
        mapProduct.put('Name',lineItem.Product2.Name);
        mapProduct.put('ProductCode',lineItem.Product2.ProductCode);
        mapProduct.put('ProductId',lineItem.Product2Id);
        mapProduct.put('PriceBookEntryId',lineItem.PricebookEntryId);
        
        
        
        
        
        
        
        mapLineItem.put('Id',lineItem.Id);
        mapLineItem.put('vlocity_cmt__AssetReferenceId__c',lineItem.vlocity_cmt__AssetReferenceId__c);
        if(lineItem.vlocity_cmt__AttributeSelectedValues__c != null){
            Map<String, Object> attributeMap = (Map<String, Object>) JSON.deserializeUntyped(lineItem.vlocity_cmt__AttributeSelectedValues__c);
            mapLineItem.put('vlocity_cmt__AttributeSelectedValues__c',attributeMap);	
        }else{
            mapLineItem.put('vlocity_cmt__AttributeSelectedValues__c',lineItem.vlocity_cmt__AttributeSelectedValues__c);
        }
        
        mapLineItem.put('price',mapPrice);
        mapLineItem.put('product',mapProduct);
        
        mapLineItem.put('vlocity_cmt__Action__c',lineItem.vlocity_cmt__Action__c);
        mapLineItem.put('vlocity_cmt__ProductHierarchyPath__c',lineItem.vlocity_cmt__ProductHierarchyPath__c);
        return mapLineItem;
        
    }
    
    /*public class InputEntity {
public String NEWNODE { get; set; }
public String CreateDate { get; set; }
public String Circle { get; set; }
public Boolean GSTApplicable { get; set; }
public String City { get; set; }
public String Pincode { get; set; }
public String State { get; set; }
public String NBAId { get; set; }
public String Country { get; set; }
public String MiddleName { get; set; }
public String SFDCId { get; set; }
public String Salutation { get; set; }
public String Email { get; set; }
public String Designation { get; set; }
public String Mobile { get; set; }
public String Role { get; set; }
public String FirstName { get; set; }
public String LastName { get; set; }
}

public static List<String> transformToJson(List<InputEntity> input) {
List<String> output = new List<String>();

for (InputEntity entity : input) {
Map<String, Object> mapvalue = new Map<String, Object>();
mapvalue.put('NEWNODE', entity.NEWNODE);
output.add(JSON.serialize(mapvalue));
}

return output;
}*/
    
    
}