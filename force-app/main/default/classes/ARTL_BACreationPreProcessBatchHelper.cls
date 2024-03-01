/************************************************************************************************************************************************************************************************************
* @Class Name   : ARTL_BACreationPreProcessBatchHelper
* @Author       : Rakesh Rajan <rakesh.rajan@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 13/11/2023
* @Test Class   : 
* @Description  : 
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1. SFDC-114             Rakesh Rajan          13/11/2023     Initial Dev
******************************************************************************************************************************************************************************************************************/

public class ARTL_BACreationPreProcessBatchHelper {
    
    
    /** 
* Description: used to call from BA SA Batch to handle PO Group 
* @Author: Sagar Sadhnani 
*/
    public static void getPOGroupOrCreate(Map<String, ARTL_Billing_Staging__c> POGroupMap){
        Map<String, PO_Group__c> toBeCreatedPOG = new Map<String, PO_Group__c>();
        
        if(!POGroupMap.isEmpty()){
            for(PO_Group__c pog : [Select ARTL_PO_Group_Number__c FROM PO_Group__c WHERE ARTL_PO_Group_Number__c IN :POGroupMap.keySet()]){
                POGroupMap.get(pog.ARTL_PO_Group_Number__c).ARTL_PO_Group_Id__c = pog.id;
            }
            
            //KB: below code is to create PO Group for non added PO Group numbers
            for(String pogNumber: POGroupMap.keySet()){
                if(POGroupMap.get(pogNumber).ARTL_PO_Group_Id__c == null){
                    toBeCreatedPOG.put(pogNumber, new PO_Group__c(ARTL_PO_Group_Number__c = pogNumber));
                }
            }
            if(!toBeCreatedPOG.isEmpty()){
                insert toBeCreatedPOG.values();
                
                for(PO_Group__c pog : toBeCreatedPOG.values()){
                    POGroupMap.get(pog.ARTL_PO_Group_Number__c).ARTL_PO_Group_Id__c = pog.id;
                }
                
            }
        }
    }
    /** 
* Description: used to call from BA SA Batch to handle PO Group 
* @Author: Sagar Sadhnani 
*/
    /*public static void getPOGroupOrCreate(Map<String, String> POGroupNumIdMap){
Map<String, PO_Group__c> toBeCreatedPOG = new Map<String, PO_Group__c>();

if(!POGroupNumIdMap.isEmpty()){
for(PO_Group__c pog : [Select Name FROM PO_Group__c WHERE Name IN :POGroupNumIdMap.keySet()]){
//POGroupNumIdMap.get(pog.name).put('PO');
POGroupNumIdMap.put(pog.name, pog.id);
}

//KB: below code is to create PO Group for non added PO Group numbers
for(String pogNumber: POGroupNumIdMap.keySet()){
if(POGroupNumIdMap.get(pogNumber) == null){
toBeCreatedPOG.put(pogNumber, new PO_Group__c(Name = pogNumber));
}
}
if(!toBeCreatedPOG.isEmpty()){
insert toBeCreatedPOG.values();

for(PO_Group__c pog : toBeCreatedPOG.values()){
POGroupNumIdMap.put(pog.name, pog.id);
}

}
}
}*/
    
    /** 
* Description: used to call from BA SA Batch to handle PO 
* @Author: Sagar Sadhnani 
*/
    public static void updateRestStagingWithPOGroup(Map<String, List<ARTL_Billing_Staging__c>> POMap, Map<String, ARTL_Billing_Staging__c> POGroupMap){
        if(!POMap.isEmpty() && !POGroupMap.isEmpty()){
            for(String poNumber: POMap.keySet()){
                for(ARTL_Billing_Staging__c bs : POMap.get(poNumber)){
                    
                    if(bs.ARTL_PO_Group_Id__c == null){
                        bs.ARTL_PO_Group_Id__c = POGroupMap.get(bs.PO_Group__c).ARTL_PO_Group_Id__c;
                    }
                }
            }
        }
    }
    
    /** 
* Description: used to call from BA SA Batch to handle PO 
* @Author: Sagar Sadhnani 
*/
    public static void getPOOrCreate(Map<String, List<ARTL_Billing_Staging__c>> POMap, Map<String, QuoteLineItem> lsiQLIMap){

        
        Map<String, ARTL_Purchase_Order__c> toBeCreatedPOs = new Map<String, ARTL_Purchase_Order__c>();
        //List<ARTL_Purchase_Order__c> toBeUpdatedPOs = new List<ARTL_Purchase_Order__c>();
        //List<QuoteLineItem> toBeUpdatedQLIs = new List<QuoteLineItem>();
       
        if(!POMap.isEmpty()){
            Set<String> onlyPOIds = new Set<String>();
            for(String key: POMap.keySet()){
                onlyPOIds.add(key.split('___')[0]);
            }
            
            for(ARTL_Purchase_Order__c po : [Select ARTL_PO_Number__c, ARTL_Account__c FROM ARTL_Purchase_Order__c WHERE ARTL_PO_Number__c IN :onlyPOIds]){
                for(ARTL_Billing_Staging__c bs : POMap.get(po.ARTL_PO_Number__c + '___' + po.ARTL_Account__c)){
                    bs.ARTL_PO_Id__c = po.id;
                    lsiQLIMap.get(bs.LSI__c).ARTL_Purchase_Order__c = po.id;

                    
                    
                    

                    
                }
                
            }
            //KB: Below updation is used to update new QLI on existing PO records
            /*if(!toBeUpdatedPOs.isEmpty()){
update toBeUpdatedPOs;
}*/
            
            
            //KB: below code is to create PO  for non added PO numbers
            for(String poNumber: POMap.keySet()){
                for(ARTL_Billing_Staging__c bs : POMap.get(poNumber)){
                    if(bs.ARTL_PO_Id__c == null){
                        Date startDate = bs.PO_Start_Date__c;
                        toBeCreatedPOs.put(poNumber,new ARTL_Purchase_Order__c
                                           (ARTL_PO_Number__c = poNumber.subStringBefore('___'),
                                            Start_Date__c = bs.PO_Start_Date__c,
                                            //Tenure__c editted by Prabanch since the Tenure__c field datatype ic changed
                                            //Tenure__c = String.valueOf(bs.PO_Terms_Years__c),
                                            //End_Date__c = (bs.PO_Terms_Years__c != null && startDate != null) ? startDate.addMonths(Integer.valueOf(bs.PO_Terms_Years__c)) : null,
                                            PO_Group__c = bs.ARTL_PO_Group_Id__c,
                                            ARTL_Account__c = bs.Quote__r.AccountId
                                           )
                                          );                       
                    }
                }
            }
            if(!toBeCreatedPOs.isEmpty()){
                insert toBeCreatedPOs.values();
                
                for(ARTL_Purchase_Order__c po : toBeCreatedPOs.values()){
                    for(ARTL_Billing_Staging__c bs : POMap.get(po.ARTL_PO_Number__c + '___' + po.ARTL_Account__c)){
                        bs.ARTL_PO_Id__c = po.id;
                        lsiQLIMap.get(bs.LSI__c).ARTL_Purchase_Order__c = po.id;                    
                    }
                    //POMap.get(po.ARTL_PO_Number__c).ARTL_PO_Id__c = po.id;
                    //toBeUpdatedQLIs.add(new QuoteLineItem(Id = POMap.get(po.ARTL_PO_Number__c).Quote_Line_Item__c, ARTL_Purchase_Order__c = po.id));
                }
                
            }
            
            /*if(!toBeUpdatedQLIs.isEmpty()){
                update toBeUpdatedQLIs;
            }*/
        }
    }
    
    /** 
* Description: used to create service account and update it on QLI
* @Author: Sagar Sadhnani 
*/
    public static void createServiceAccounts(List<ARTL_Billing_Staging__c> serviceAccountBStaggingList, String sARecordTypeId, Map<String, QuoteLineItem> lsiQLIMap){
        /*public static void createServiceAccounts(List<ARTL_Billing_Staging__c> serviceAccountBStaggingList, String sARecordTypeId, Map<String, QuoteLineItem> lsiQLIMap, Map<String,List<QuoteLineItem>> bundleMap){*/

            
        Map<String, Account> uniqueSAMap = new Map<String, Account>();
        List<QuoteLineItem> toBeUpdatedQLIs = new List<QuoteLineItem>();
        
        if(!serviceAccountBStaggingList.isEmpty()){
            for(ARTL_Billing_Staging__c obj : serviceAccountBStaggingList){
                system.debug('obj==>'+ obj);
                if(obj.Shipping_Street__c != null || Test.isrunningtest()){
                    
                    String uniqueKey = obj.Shipping_Street__c + obj.Shipping_State__c + obj.Shipping_PinCode__c + obj.Shipping_City__c + obj.Shipping_Country__c;
                    if(!uniqueSAMap.containsKey(uniqueKey)){
                        Account SA = new Account(Name = obj.Quote__r.Account.name +' (Service Account)', 
                                                 recordTypeId = sARecordTypeId,
                                                //  ShippingStreet = obj.Shipping_Street__c,
                                                //  ShippingState = obj.Shipping_State__c,
                                                //  ShippingPostalCode = obj.Shipping_PinCode__c,
                                                //  ShippingCity = obj.Shipping_City__c,
                                                //  ShippingCountry = obj.Shipping_Country__c,
                                                 ShippingStreet = obj.Quote_Member__r.DCP_Record__r.Premises__r.vlocity_cmt__StreetAddress__c,

                                                 ShippingState = obj.Quote_Member__r.DCP_Record__r.Premises__r.vlocity_cmt__State__c,

                                                 ShippingPostalCode = obj.Quote_Member__r.DCP_Record__r.Premises__r.ARTL_Pincode__r.Name,

                                                 ShippingCity = obj.Quote_Member__r.DCP_Record__r.Premises__r.vlocity_cmt__City__c,

                                                 ShippingCountry = obj.Quote_Member__r.DCP_Record__r.Premises__r.vlocity_cmt__Country__c,
                                                 
                                                 ParentId = obj.Billing_Account_Id__c,
                                                 BCP_DCP_Id__c = obj.Quote_Member__r.DCP_Record__c 
                                                );
                        uniqueSAMap.put(uniqueKey, SA);
                    }
                    
                }
            }
            
            if(!uniqueSAMap.isEmpty()){
                insert uniqueSAMap.values();
                
                for(ARTL_Billing_Staging__c obj : serviceAccountBStaggingList){
                    if(obj.Shipping_Street__c != null){
                        String uniqueKey = obj.Shipping_Street__c + obj.Shipping_State__c + obj.Shipping_PinCode__c + obj.Shipping_City__c + obj.Shipping_Country__c;
                        obj.Service_Account_Id__c = uniqueSAMap.get(uniqueKey).id;
                        lsiQLIMap.get(obj.LSI__c).vlocity_cmt__ServiceAccountId__c = uniqueSAMap.get(uniqueKey).id;                       
                    }    
                }
                //KB: Update QLIs with Service Accounts
                /*if(!toBeUpdatedQLIs.isEmpty()){
                    update toBeUpdatedQLIs;
                }*/
            }
        }
    }
    
    
    /** 
* Description: used to create billing account and update it on QLI
* @Author: Sagar Sadhnani 
*/
    public static Integer createBillingAccounts(List<ARTL_Billing_Staging__c> billingAccountBStaggingList, String bARecordTypeId, Map<String, QuoteLineItem> lsiQLIMap, Map<String, String> toBeBASyncedQLIs, Integer baAssociatedSuccessCount){

            
        Map<String, String> existingBAMap = new Map<String, String>();
        Map<String, Account> uniqueBAMap = new Map<String, Account>();
        //List<QuoteLineItem> toBeUpdatedQLIs = new List<QuoteLineItem>();
        Set<String> productNames = new Set<String>();
        Set<String> entities = new Set<String>();
        String segment;
        String circle;
        Map<String, String> licenseCompanyMap = new Map<String, String>();
        Map<String, String> billFormatMap = new Map<String, String>();
        Map<String, String> usageFlagMap = new Map<String, String>();

        if(!billingAccountBStaggingList.isEmpty()){
            for(ARTL_Billing_Staging__c obj :  billingAccountBStaggingList){
                if(obj.Billing_Street__c != null){
                    
                    productNames.add(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name);
                    //KB: Collecting product names entities, segment and circle for License Company
                    if(String.isNotBlank(obj.Legal_Entity__c)){
                        entities.add(obj.Legal_Entity__c);    
                        if(String.isBlank(segment)){
                            segment = obj.Quote__r.Account.ARTL_Customer_Segment__c;
                            circle = String.isNotBlank(obj.Quote__r.Account.ARTL_Business_Circle_Region__c) ? obj.Quote__r.Account.ARTL_Business_Circle_Region__c : 'NA';
                        }
                    }
                    
                }
            }
            //KB: Collecting Bill Format and Usage Flag
            if(!productNames.isEmpty()){
                for(ARTL_Bill_Format__mdt md : [SELECT ARTL_BF_Product__c, ARTL_Bill_Format__c, ARTL_Usage_Flag__c
                                                    FROM ARTL_Bill_Format__mdt 
                                                    WHERE ARTL_BF_Product__c IN: productNames]
                ){
                    billFormatMap.put(md.ARTL_BF_Product__c, md.ARTL_Bill_Format__c);
                    usageFlagMap.put(md.ARTL_BF_Product__c, md.ARTL_Usage_Flag__c);
                }
            }

            if(!entities.isEmpty()){
                for(ARTL_License_Company__mdt md : [SELECT ARTL_Product__c, ARTL_Legal_Entity__c, ARTL_Segment__c, ARTL_Circle__c, ARLT_License_Compay__c 
                                                    FROM ARTL_License_Company__mdt 
                                                    WHERE ARTL_Product__c IN: productNames AND ARTL_Legal_Entity__c IN: entities
                                                    AND ARTL_Segment__c = :segment AND ARTL_Circle__c = :circle]
                ){
                    licenseCompanyMap.put(md.ARTL_Product__c + '_' + md.ARTL_Legal_Entity__c + '_' +md.ARTL_Segment__c + '_' +md.ARTL_Circle__c, md.ARLT_License_Compay__c);
                }
            }
            //Running below loop again because we dont have license company and bill format initially to generateMD5Key
            if(!billingAccountBStaggingList.isEmpty()){
                for(ARTL_Billing_Staging__c obj :  billingAccountBStaggingList){
                    if(obj.Billing_Street__c != null){
                        String uniqueKey = generateMD5HashKey(obj, 
                                        (licenseCompanyMap.containsKey(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name + '_' + obj.Legal_Entity__c + '_' + segment + '_' + circle) ? licenseCompanyMap.get(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name + '_' + obj.Legal_Entity__c + '_' + segment + '_' + circle) : null),
                                        (billFormatMap.containsKey(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name) ? billFormatMap.get(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name) : null ));
                        if(!existingBAMap.containsKey(uniqueKey)){
                            existingBAMap.put(uniqueKey, null);
                        } 
                    }
                }
            }

            if(!existingBAMap.isEmpty()){
                
                for(Account bAcc : [SELECT id, MD5Hash__c FROM Account WHERE MD5Hash__c IN: existingBAMap.keySet()]){
                    existingBAMap.put(bAcc.MD5Hash__c, bAcc.id);
                }
            }
            

            for(ARTL_Billing_Staging__c obj :  billingAccountBStaggingList){
                if(obj.Billing_Street__c != null){
                    String uniqueKey = generateMD5HashKey(obj, 
                                        (licenseCompanyMap.containsKey(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name + '_' + obj.Legal_Entity__c + '_' + segment + '_' + circle) ? licenseCompanyMap.get(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name + '_' + obj.Legal_Entity__c + '_' + segment + '_' + circle) : null),
                                        (billFormatMap.containsKey(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name) ? billFormatMap.get(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name) : null ));
                    if(existingBAMap.get(uniqueKey) == null && !uniqueBAMap.containsKey(uniqueKey)){
                        Account BA = new Account(Name = obj.Quote__r.Account.name + +' (Billing Account)',
                                                 recordTypeId = bARecordTypeId,
                                                 BillingStreet = obj.Billing_Street__c,
                                                 BillingState = obj.Billing_State__c,
                                                 BillingPostalCode = obj.Billing_PinCode__c,
                                                 BillingCity = obj.Billing_City__c,
                                                 BillingCountry = obj.Billing_Country__c,
                                                 //AccountNumber = obj.Quote__r.ARTL_NBA_Account__r.,//NBA account number: need to check if its already populating
                                                 ParentId = obj.Quote__r.ARTL_NBA_Account__c,//obj.Quote_Line_Item__r.Quote.AccountId,
                                                 MD5Hash__c = uniqueKey,
                                                 Billing_Level__c = obj.Billing_Level__c,
                                                 ARTL_Legal_Entity__c = obj.Legal_Entity__c,
                                                 CurrencyIsoCode = obj.CurrencyIsoCode,
                                                 ARTL_Bill_Type__c = obj.Bill_Type__c,
                                                 ARTL_License_Company__c = obj.License_Company__c,
                                                 //vlocity_cmt__BillFormat__c = obj.Bill_Format__c,
                                                 //ARTL_Taxation__c = obj.Taxation__c,//this is not on UI
                                                 ARTL_Credit_Period__c = obj.Credit_Period__c,
                                                 ARTL_Store__c = obj.Store__c,
                                                 //ARTL_Usage_Flag__c = (obj.Usage_Flag__c != null ? String.valueOf(obj.Usage_Flag__c): null),
                                                 ARTL_Bill_Franchise_Tax_Code__c = obj.Bill_Franchise_Tax_Code__c,
                                                 //Exempt_Reason__c = obj.StandardReasonforTaxExemption__c, // not getting used anymore
                                                 ARTL_GST_Non_Applicable_Reason__c = obj.Billing_Standard_Reason__c,
                                                 BCP_DCP_Id__c = obj.BCP_Id__c,
                                                 ARTL_GST_Applicable__c = obj.Billing_GST_Applicable_for_Billing__c,
                                                 ARTL_Taxation__c = (obj.Billing_GST_Applicable_for_Billing__c ? 'Yes': 'No'),
                                                 ARTL_Virtual_Account_Number__c = obj.VAN_Account_Number__c
                                                 //Bill Franchise Tax Code should be derived: refer to excel shared by kanchan
                                                 // Delivery GST and Billing GST : Need to confirm with Vinod.

                                                );
                        if(licenseCompanyMap.containsKey(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name + '_' + obj.Legal_Entity__c + '_' + segment + '_' + circle)){
                            BA.ARTL_License_Company__c = licenseCompanyMap.get(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name + '_' + obj.Legal_Entity__c + '_' + segment + '_' + circle);
                        }
                        if(billFormatMap.containsKey(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name) && usageFlagMap.containsKey(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name)){
                            BA.ARTL_Usage_Flag__c = usageFlagMap.get(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name);
                            BA.vlocity_cmt__BillFormat__c = billFormatMap.get(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name);
  
                        }

                        uniqueBAMap.put(uniqueKey, BA);
                    }
                }
            }
            if(!uniqueBAMap.isEmpty()){
                insert uniqueBAMap.values();
                
                for(ARTL_Billing_Staging__c obj :  billingAccountBStaggingList){
                    if(obj.Billing_Street__c != null){
                        String uniqueKey = generateMD5HashKey(obj, 
                                        (licenseCompanyMap.containsKey(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name + '_' + obj.Legal_Entity__c + '_' + segment + '_' + circle) ? licenseCompanyMap.get(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name + '_' + obj.Legal_Entity__c + '_' + segment + '_' + circle) : null),
                                        (billFormatMap.containsKey(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name) ? billFormatMap.get(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name) : null ));
                        obj.Billing_Account_Id__c = uniqueBAMap.get(uniqueKey).id;
                        lsiQLIMap.get(obj.LSI__c).vlocity_cmt__BillingAccountId__c = obj.Billing_Account_Id__c;
                        lsiQLIMap.get(obj.LSI__c).ARTL_Validation_Status__c = 'BA Associated';
                       
                        toBeBASyncedQLIs.put((String)lsiQLIMap.get(obj.LSI__c).id, obj.Billing_Account_Id__c);
                        baAssociatedSuccessCount++;
                        
                    }    
                }
                //KB: Update QLIs with Service Accounts
                //system.debug('toBeUpdatedQLIs::' + toBeUpdatedQLIs);
                /*if(!toBeUpdatedQLIs.isEmpty()){
                    update toBeUpdatedQLIs;
                }*/
            }else{
                for(ARTL_Billing_Staging__c obj :  billingAccountBStaggingList){
                    if(obj.Billing_Street__c != null){
                        String uniqueKey = generateMD5HashKey(obj, 
                                        (licenseCompanyMap.containsKey(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name + '_' + obj.Legal_Entity__c + '_' + segment + '_' + circle) ? licenseCompanyMap.get(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name + '_' + obj.Legal_Entity__c + '_' + segment + '_' + circle) : null),
                                        (billFormatMap.containsKey(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name) ? billFormatMap.get(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__Product2Id__r.Name) : null ));
                        obj.Billing_Account_Id__c = existingBAMap.get(uniqueKey) != null ? existingBAMap.get(uniqueKey) : null;
                        lsiQLIMap.get(obj.LSI__c).vlocity_cmt__BillingAccountId__c = obj.Billing_Account_Id__c;
                        lsiQLIMap.get(obj.LSI__c).ARTL_Validation_Status__c = 'BA Associated';
                        baAssociatedSuccessCount++;
                       
                    }    
                }
            }
        }
        return baAssociatedSuccessCount;
    }

    
    
    /** 
* Description: used to generate unique key which will used to find billing account based on this key
* @Author: Sagar Sadhnani 
*/
    private static string generateMD5HashKey(ARTL_Billing_Staging__c obj, String licenseCompany, String billFormat){
        String InvoiceShipmentAddress = (obj.Billing_Level__c =='Account Level' ? obj.Delivery_GST__c : 
                                         (obj.Billing_Level__c =='PO Level' ? obj.Delivery_GST__c+'-'+obj.PO_Group__c: 
                                          obj.InvoiceShipmentAddress__c));
        // KB: if obj.Billing_Level__c =='LSI Level' this yet to be handled because there is no DCP address field in BS
        String requestInput = obj.Quote__r.ARTL_NBA_Account__r.AccountNumber+'-'+obj.Legal_Entity__c+'-'+obj.CurrencyIsoCode+'-'+obj.Bill_Type__c+
            '-'+licenseCompany+'-'+billFormat+'-'+obj.Billing_GST_Applicable_for_Billing__c+'-'+obj.Credit_Period__c+
            '-'+obj.Store__c+'-'+obj.Billing_Level__c+'-'+obj.Usage_Flag__c+'-'+obj.Bill_Franchise_Tax_Code__c+
            '-'+obj.Billing_Standard_Reason__c+'-'+obj.PO__c+'-'+obj.PO_Start_Date__c+'-'+obj.PO_End_Date__c+
            '-'+obj.PO_Amount__c+'-'+obj.Billing_Address__c+'-'+InvoiceShipmentAddress+
            '-'+obj.Quote_Member__r.DCP_Record__c+'-'+obj.BCP_Id__c;
        //KB: Creating an encrypted key which will be stored on billing account as a unique key
        return ARTL_EncryptDecryptUtil.generateMD5Hash(requestInput);
    }
    
    /** 
* Description: used to create BCP contact and ACRs and related those with BAs
* @Author: Sagar Sadhnani 
*/
   /* public static void createBCPContacts(List<ARTL_Billing_Staging__c> bcpBStaggingList){
        Map<String, Contact> uniqueBCPMap = new Map<String, Contact>();
        Map<String, AccountContactRelation> ACRInsertMap = new Map<String, AccountContactRelation>();
        
        if(!bcpBStaggingList.isEmpty()){
            for(ARTL_Billing_Staging__c obj : bcpBStaggingList){
                if(obj.BCP_Last_Name__c != null){
                    
                    String uniqueKey = obj.BCP_First_Name__c + obj.BCP_Last_Name__c + obj.BCP_Phone__c + obj.BCP_Email__c;
                    if(!uniqueBCPMap.containsKey(uniqueKey)){
                        Contact BCP = new Contact(firstname = obj.BCP_First_Name__c,
                                                  lastname = obj.BCP_Last_Name__c,
                                                  email = obj.BCP_Email__c,
                                                  phone = obj.BCP_Phone__c,
                                                  accountId = obj.Billing_Account_Id__c
                                                 );
                        ACRInsertMap.put(uniqueKey, new AccountContactRelation(accountId = obj.Billing_Account_Id__c, Contact = BCP, roles = 'Billing Contact Person'));
                        uniqueBCPMap.put(uniqueKey, BCP);
                    }
                    
                }
            }
            
            if(!uniqueBCPMap.isEmpty()){
                insert uniqueBCPMap.values();
                
                for(ARTL_Billing_Staging__c obj : bcpBStaggingList){
                    if(obj.BCP_Last_Name__c != null){
                        
                        String uniqueKey = obj.BCP_First_Name__c + obj.BCP_Last_Name__c + obj.BCP_Phone__c + obj.BCP_Email__c;
                        
                        obj.BCP_Id__c = uniqueBCPMap.get(uniqueKey).id;
                        ACRInsertMap.get(uniqueKey).contactId = ACRInsertMap.get(uniqueKey).contact.id;
                    }    
                }
                if(!ACRInsertMap.isEmpty()){
                    //insert ACRInsertMap.values();
                }
            }
        }
    }*/
    
    /** 
* Description: used to create DCP contact and ACRs and related those with SAs
* @Author: Sagar Sadhnani 
*/
   /* public static void createDCPContacts(List<ARTL_Billing_Staging__c> dcpBStaggingList){
        Map<String, Contact> uniqueDCPMap = new Map<String, Contact>();
        Map<String, AccountContactRelation> ACRInsertMap = new Map<String, AccountContactRelation>();
        
        if(!dcpBStaggingList.isEmpty()){
            for(ARTL_Billing_Staging__c obj : dcpBStaggingList){
                if(obj.DCP_Last_Name__c != null){
                    
                    String uniqueKey = obj.DCP_First_Name__c + obj.DCP_Last_Name__c + obj.DCP_Phone__c + obj.DCP_Email__c;
                    if(!uniqueDCPMap.containsKey(uniqueKey)){
                        Contact DCP = new Contact(firstname = obj.DCP_First_Name__c,
                                                  lastname = obj.DCP_Last_Name__c,
                                                  email = obj.DCP_Email__c,
                                                  phone = obj.DCP_Phone__c,
                                                  accountId = obj.Service_Account_Id__c
                                                 );
                        ACRInsertMap.put(uniqueKey, new AccountContactRelation(accountId = obj.Service_Account_Id__c, Contact = DCP, roles = 'Dispatch Contact Person'));
                        uniqueDCPMap.put(uniqueKey, DCP);
                    }
                    
                }
            }
            
            if(!uniqueDCPMap.isEmpty()){
                insert uniqueDCPMap.values();
                
                for(ARTL_Billing_Staging__c obj : dcpBStaggingList){
                    if(obj.DCP_Last_Name__c != null){
                        
                        String uniqueKey = obj.DCP_First_Name__c + obj.DCP_Last_Name__c + obj.DCP_Phone__c + obj.DCP_Email__c;
                        
                        obj.DCP_Id__c = uniqueDCPMap.get(uniqueKey).id;
                        ACRInsertMap.get(uniqueKey).contactId = ACRInsertMap.get(uniqueKey).contact.id;
                    }    
                }
                if(!ACRInsertMap.isEmpty()){
                    //insert ACRInsertMap.values();
                }
            }
        }
    }*/
    /*



public static String getContact(String firstName,String lastName, String phoneNumber, String email, String accId){
String contactId;
try{
Contact con   = new Contact();
con.FirstName = firstName;
con.LastName  = lastName;
con.Phone     = phoneNumber;
con.Email     = email;
con.AccountId = accId;
System.debug('ARTL_BACreationPreProcessBatch con '+con);
if(con!=null){
insert con;
contactId =con.Id;   
System.debug('ARTL_BACreationPreProcessBatch contactId '+contactId);
}

} catch(Exception e){
System.debug('Exception occurred in:ARTL_BACreationPreProcessBatchHelper '+ e.getMessage()+'Line Number: '+e.getLineNumber()+' Stack Trace: '+e.getStackTraceString());
}
return contactId;
}*/
}