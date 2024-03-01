/************************************************************************************************************************************************************************************************************
* @Class Name   : ARTL_BACreationPreProcessBatch
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

public class ARTL_BACreationPreProcessBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts
{
    public Set<Id> quoteIds;
    //public String accName;
    public String serviceAccRecordType;
    public String billingAccRecordType;
    public String billAggrAccRecordType;
    public final String PASSED = 'Passed';
    public Map<String, String> toBeBASyncedQLIs = new Map<String, String>();
    public static Boolean bypassFromBACreationBatch = false;
    //public Map<String, String> onlyBAAssociatedQLIs = new Map<String, String>();
    public  Integer baAssociatedSuccessCount;
    

    Exception[] errors = new Exception[0];



    
    List<QuoteLineItem> innerBundleList = new List<QuoteLineItem>();
    String rootItemId =''; //todo
    
    public ARTL_BACreationPreProcessBatch(Set<Id> quoteIds){
        this.quoteIds = quoteIds;
        baAssociatedSuccessCount = 0;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        //KB: Fetching Account Record Type Ids
        Map<String,Schema.RecordTypeInfo> recordTypeInfoMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        if(recordTypeInfoMap.containsKey('Service')){
            serviceAccRecordType = recordTypeInfoMap.get('Service').getRecordTypeId();
        }
        if(recordTypeInfoMap.containsKey('Billing')){
            billingAccRecordType = recordTypeInfoMap.get('Billing').getRecordTypeId();
        }
        if(recordTypeInfoMap.containsKey('Billing Aggregator')){
            billAggrAccRecordType = recordTypeInfoMap.get('Billing Aggregator').getRecordTypeId();
        }
        
        return Database.getQueryLocator([
            SELECT Id, Quote__c, Quote__r.Account.name, Product_Name__c, Product_Code__c, Site_Street__c,
            Site_City__c, Site_State__c,Site_Country__c,Site_PinCode__c, Delivery_GST__c, Billing_GST_Applicable_for_Billing__c,
            Billing_GST__c, Site_GST_Applicable_for_Billing__c, Billing_Standard_Reason__c,
            Delivery_Standard_Reason__c, Installation_GST_Applicable__c, DCP_First_Name__c, DCP_Last_Name__c,Bill_Type__c, 
            License_Company__c, DCP_Phone__c, DCP_Email__c, NBA_Account_Number__c, Billing_Account_Number__c, 
            DCP_Id__c,PO__c,PO_Start_Date__c , PO_End_Date__c, PO_Terms_Years__c, PO_Group__c, ARTL_PO_Group_Id__c, ARTL_PO_Id__c, 
            PO_Amount__c,Taxation__c, Legal_Entity__c, Billing_Type__c,BCP_Id__c,Credit_Period__c, Store__c, Billing_Level__c,
            Billing_Street__c, Billing_City__c, Billing_State__c, Usage_Flag__c,Billing_PinCode__c, Bill_Format__c,
            BCP_First_Name__c, BCP_Last_Name__c, BCP_Phone__c, BCP_Email__c, Site_is_Same_as_Billing_Address__c,
            Shipping_Street__c,Shipping_City__c,Billing_Address__c,Shipping_State__c, Shipping_PinCode__c,
            Quote_Member__c, OwnerId, CurrencyIsoCode, Service_Account_Id__c, Billing_Account_Id__c,Billing_Country__c,
            Bill_Franchise_Tax_Code__c, StandardReasonforTaxExemption__c, InvoiceShipmentAddress__c, Shipping_Country__c,
            Quote__r.AccountId,  Quote_Member__r.DCP_Record__c,
            Quote__r.Account.ARTL_Business_Circle_Region__c, Quote__r.Account.ARTL_Customer_Segment__c,
            Quote__r.ARTL_NBA_Account__c, Quote__r.ARTL_NBA_Account__r.AccountNumber, VAN_Account_Number__c,
            LSI__c,Quote_Member__r.DCP_Record__r.Premises__r.vlocity_cmt__StreetAddress__c,Quote_Member__r.DCP_Record__r.Premises__r.vlocity_cmt__State__c,Quote_Member__r.DCP_Record__r.Premises__r.vlocity_cmt__Country__c ,Quote_Member__r.DCP_Record__r.Premises__r.ARTL_Pincode__r.Name,
            Quote_Member__r.DCP_Record__r.Premises__r.vlocity_cmt__City__c

            FROM ARTL_Billing_Staging__c
            WHERE Quote__c IN :quoteIds AND Status__c = 'Success' AND LSI__c != null]); 
        
    }
    
    public void execute(Database.BatchableContext BC, List<ARTL_Billing_Staging__c> scope){
        //System.debug('!!!!ARTL_BACreationPreProcessBatch scope '+scope.size());
        //String POGroupIdName, POIdName, requestInput = '', md5HashKey='';
        try
        {
            
            Map<String, ARTL_Billing_Staging__c> POGroupMap = new Map<String, ARTL_Billing_Staging__c>();
            Map<String, List<ARTL_Billing_Staging__c>> POMap = new Map<String, List<ARTL_Billing_Staging__c>>();
            List<ARTL_Billing_Staging__c> serviceAccountBStaggingList = new List<ARTL_Billing_Staging__c>();
            List<ARTL_Billing_Staging__c> billingAccountBStaggingList = new List<ARTL_Billing_Staging__c>();
            List<ARTL_Billing_Staging__c> bcpBStaggingList = new List<ARTL_Billing_Staging__c>();
            List<ARTL_Billing_Staging__c> dcpBStaggingList = new List<ARTL_Billing_Staging__c>();
            Map<String, QuoteLineItem> lsiQLIMap = new Map<String, QuoteLineItem>();
            Map<String, List<QuoteLineItem>> bundleMap = new Map<String,List<QuoteLineItem>>(); //todo
            Map<String,String> lsiRootItemIdMap = new Map<String,String>();
            //KB: As QLI reference wont be there on Billing Staging, retieving correcponding QLIs
            for(ARTL_Billing_Staging__c obj : scope){
                lsiQLIMap.put(obj.LSI__c, null);
            }
            for(QuoteLineItem obj : [SELECT ARTL_LSI_OLI_Formula__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__BillingAccountId__c,vlocity_cmt__RootItemId__c,vlocity_cmt__ParentItemId__c,
                                    ARTL_Purchase_Order__c, vlocity_cmt__Product2Id__r.Name
                                    FROM QuoteLineItem 
                                    WHERE quoteId = :new List<Id> (quoteIds).get(0)  AND ARTL_LSI_OLI_Formula__c IN: lsiQLIMap.keySet() ]
            ){
                lsiQLIMap.put(obj.ARTL_LSI_OLI_Formula__c, obj);
                lsiRootItemIdMap.put(obj.ARTL_LSI_OLI_Formula__c, obj.vlocity_cmt__RootItemId__c);    

            }

            bundleMap = fetchBundleMapQLIs(lsiRootItemIdMap, new List<Id> (quoteIds).get(0));

            system.debug('bundleMap @@ -->'+JSON.serializePretty(bundleMap));

            system.debug('lsiQLIMap @@  -->'+JSON.serializePretty(lsiQLIMap));
            
            //KB: ------------Below the main processing is started--------------
            for(ARTL_Billing_Staging__c obj : scope){
                /*Step 1 & 2: Check PO Group and PO, If exist add the reference otherwise create those records and then
                *             add the reference
                */
                if(obj.ARTL_PO_Group_Id__c == null && obj.PO_Group__c != null){
                    POGroupMap.put(obj.PO_Group__c, obj);
                }
                if(obj.PO__c != null && (obj.ARTL_PO_Id__c == null || lsiQLIMap.get(obj.LSI__c).ARTL_Purchase_Order__c == null)){
                    
                    if(POMap.containsKey(obj.PO__c + '___' + obj.Quote__r.AccountId)){
                        POMap.get(obj.PO__c + '___' + obj.Quote__r.AccountId).add(obj);
                    }else{
                        POMap.put(obj.PO__c + '___' + obj.Quote__r.AccountId, new List<ARTL_Billing_Staging__c>{obj});
                    }
                    
                }
                
                
                //Step 8: Creation of Service Account -- Adding into Collection
                if(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__ServiceAccountId__c == null || lsiQLIMap.get(obj.LSI__c).vlocity_cmt__ServiceAccountId__c == obj.Quote__r.AccountId){ 
                    serviceAccountBStaggingList.add(obj);
                }
                else{
                    obj.Service_Account_Id__c=	lsiQLIMap.get(obj.LSI__c).vlocity_cmt__ServiceAccountId__c;
                }
               
                
                //Step 9 BA Creation -- adding into collection
                if(lsiQLIMap.get(obj.LSI__c).vlocity_cmt__BillingAccountId__c == null  || lsiQLIMap.get(obj.LSI__c).vlocity_cmt__BillingAccountId__c == obj.Quote__r.AccountId){
                    billingAccountBStaggingList.add(obj);
                }else{
                    obj.Billing_Account_Id__c=	lsiQLIMap.get(obj.LSI__c).vlocity_cmt__BillingAccountId__c;
                }
                //Step 12 BCP Creation - Adding into Collection
                if(obj.BCP_Id__c == null){
                    bcpBStaggingList.add(obj);
                }
                //Step 13 DCP Creation - Adding into Collection
                if(obj.DCP_Id__c == null){
                    dcpBStaggingList.add(obj);
                }

                system.debug('obj @@'+JSON.serializePretty(obj ));
            }

            //system.debug('parent class POMap @@'+POMap);  // issue PO group ID and PO_Group__c (blank) 
            //system.debug('parent class POGroupMap @@'+POGroupMap);
           // system.debug('parent class lsiQLIMap @@'+lsiQLIMap);
           // system.debug('parent class billingAccountBStaggingList @@'+billingAccountBStaggingList);
           // system.debug('parent class serviceAccountBStaggingList @@'+serviceAccountBStaggingList);
           // system.debug('parent class toBeBASyncedQLIs @@'+toBeBASyncedQLIs);
            
            //Step 1 & 2
            ARTL_BACreationPreProcessBatchHelper.getPOGroupOrCreate(POGroupMap);
            //KB: Assign PO Group ID to Rest of the Billing Staging Records
            ARTL_BACreationPreProcessBatchHelper.updateRestStagingWithPOGroup(POMap, POGroupMap);
            ARTL_BACreationPreProcessBatchHelper.getPOOrCreate(POMap, lsiQLIMap);
       
            //Step 9-10-11 BA Creation 
           baAssociatedSuccessCount = ARTL_BACreationPreProcessBatchHelper.createBillingAccounts(billingAccountBStaggingList, billingAccRecordType, lsiQLIMap, toBeBASyncedQLIs, baAssociatedSuccessCount);
           system.debug('$$$ = '+ baAssociatedSuccessCount);
           
            //Step 8: Creation of Service Account
            ARTL_BACreationPreProcessBatchHelper.createServiceAccounts(serviceAccountBStaggingList, serviceAccRecordType, lsiQLIMap);

            //Step 12 BCP Creation
            //ARTL_BACreationPreProcessBatchHelper.createBCPContacts(bcpBStaggingList);
            //Step 12 BCP Creation
            //ARTL_BACreationPreProcessBatchHelper.createDCPContacts(dcpBStaggingList);
            //system.debug('construct bundleMap @@ '+JSON.serializePretty(bundleMap));
            //system.debug('construct bundleMap @@ '+JSON.serializePretty(lsiQLIMap));
            //system.debug('construct bundleMap @@ '+JSON.serializePretty(bundleMap));
            
            

            for(QuoteLineItem bundleQli : lsiQLIMap.values()){

                updateBAIdOnQLIs(bundleMap, bundleQli);
            }


            List<QuoteLineItem> wrapperQLiList = new List<QuoteLineItem>();
            wrapperQLiList.addAll(lsiQLIMap.values());

        
            
            for( List<QuoteLineItem> tempQliVal :bundleMap.values() ){
                wrapperQLiList.addAll(tempQliVal);
            }

           
            update wrapperQLiList;


                        // method 
            //update lsiQLIMap.values();
            update scope; 


           
            /*
//Step 12: Send BCP & DCP to Siebel 
*/
            
            
        } 
        catch(Exception e){
            System.debug('Exception occurred in:execute '+ e.getMessage()+'Line Number: '+e.getLineNumber()+' Stack Trace: '+e.getStackTraceString());
            errors.add(e);
        }
        
    }

    public Map<String, List<QuoteLineItem>> fetchBundleMapQLIs(Map<String, String> lsiRootItemIdMap, Id quoteId){


        Map<String, List<QuotelineItem>> tempQliBundleMap = new Map<String, List<QuotelineItem>>();

        for(QuoteLineItem lsiQli : [SELECT ARTL_LSI_OLI_Formula__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__BillingAccountId__c,vlocity_cmt__RootItemId__c,vlocity_cmt__ParentItemId__c,
                                    ARTL_Purchase_Order__c, vlocity_cmt__Product2Id__r.Name,ARTL_Purchase_Order__r.Id
                                    FROM QuoteLineItem 
                                    WHERE quoteId = :quoteId AND vlocity_cmt__RootItemId__c IN :lsiRootItemIdMap.values() AND ARTL_LSI_OLI_Formula__c =null]){

                                    if(!tempQliBundleMap.containsKey(lsiQli.vlocity_cmt__RootItemId__c)){
                                        tempQliBundleMap.put(lsiQli.vlocity_cmt__RootItemId__c ,new List<QuoteLineItem>{lsiQli});
                                    }
                                    else{

                                        tempQliBundleMap.get(lsiQli.vlocity_cmt__RootItemId__c).add(lsiQli);
                                    }      


        }
        return tempQliBundleMap;
        //return null;
    }


        /** 
    * Description: update the billing Account Id on all the child QLIs
    * @Author:Shishir Bansal 
    */
    private static void updateBAIdOnQLIs(Map<String, List<QuoteLineItem>> bundleMap, QuoteLineItem qliRec){
        
        system.debug('## qliRec'+qliRec);
        for(QuoteLineItem cqli: bundleMap.get(qliRec.vlocity_cmt__RootItemId__c)){
            
            if(qliRec.vlocity_cmt__BillingAccountId__c != null){
                cqli.vlocity_cmt__BillingAccountId__c = qliRec.vlocity_cmt__BillingAccountId__c;
                cqli.ARTL_Validation_Status__c = 'BA Associated';
            }
            if(qliRec.vlocity_cmt__ServiceAccountId__c != null){
                 cqli.vlocity_cmt__ServiceAccountId__c = qliRec.vlocity_cmt__ServiceAccountId__c;
            }
            if(qliRec.ARTL_Purchase_Order__c != null){
                cqli.ARTL_Purchase_Order__c = qliRec.ARTL_Purchase_Order__c;
            }
            
            
        }

    }
    
    public void finish(Database.BatchableContext BC){
        Boolean billingSyncFailedOverall = false;
        if(!toBeBASyncedQLIs.isEmpty() && errors.isEmpty()){
            //Step 11: Sent BA to FXs
            Map<String, QuoteLineItem> toBeUpdatedQLIMap = new Map<String, QuoteLineItem>();
            Map<String, Account> billingSyncAccMap = new Map<String, Account>();

            for(String qliId : toBeBASyncedQLIs.keySet()){

                String ipName = 'ARTL_FXSyncBillingAccountWithoutDML';
                String accountId= toBeBASyncedQLIs.get(qliId);
                Map<String, Object> inputMap = new Map<String, Object>();
                Map<String, Object> outputMap = new Map<String, Object>();
                Map<String, Object> optionsMap = new Map<String, Object>();

                inputMap.put('accountId', accountId);
               

                Object result = vlocity_cmt.IntegrationProcedureService.runIntegrationService(ipName,inputMap,optionsMap);

                system.debug('result @@'+JSON.serializePretty(result));
                //outputMap.put('Result', result);
                Map<String, Object> resultMap = (Map<String, Object>) result;
                if(resultMap.containsKey('VlocityNoRootNode')){
                    Map<String, Object> resultRoomMap = (Map<String, Object>)resultMap.get('VlocityNoRootNode');
                    if(resultRoomMap.containsKey('dataArea')){
                        Map<String, Object> dataAreaMap =  (Map<String, Object>)resultRoomMap.get('dataArea');
                        if(dataAreaMap.containsKey('createBillingAccountResponse')){
                            Map<String, Object> dataCreateBillMap =  (Map<String, Object>)dataAreaMap.get('createBillingAccountResponse');
                            if(dataCreateBillMap.containsKey('customerOrderItem')){
                                Map<String, Object> dataCustomerOrderItemMap =  (Map<String, Object>)dataCreateBillMap.get('customerOrderItem');
                                if(dataCustomerOrderItemMap.containsKey('billingAccountSynFlag') && ((String)dataCustomerOrderItemMap.get('billingAccountSynFlag')).equalsIgnoreCase('true')){
                                    toBeUpdatedQLIMap.put(qliId, new QuoteLineItem(id = qliId, ARTL_Validation_Status__c = 'Billing Sync Successful'));
                                    billingSyncAccMap.put(accountId, new account(id = accountId, ARTL_billingId__c = (String)dataCustomerOrderItemMap.get('billingAccountId'), ARTL_FXSynch__c = true));
                                }
                                
                            }    
                        }    
                    }
                }
                
                //KB: If not synced then updating billing sync failed on QLI
                if(!toBeUpdatedQLIMap.containsKey(qliId)){
                    toBeUpdatedQLIMap.put(qliId, new QuoteLineItem(id = qliId, ARTL_Validation_Status__c = 'Billing Sync Failed'));
                    billingSyncFailedOverall = true;
                }
                /*if(!billingSyncAccMap.containsKey(accountId)){
                    billingSyncAccMap.put(accountId, new account(id = accountId, ARTL_FXSynch__c = true));
                }*/

            }
            if(!toBeUpdatedQLIMap.isEmpty()){
                update toBeUpdatedQLIMap.values();
            }
            if(!billingSyncAccMap.isEmpty()){
                update billingSyncAccMap.values();
            }

            
        }

        if(baAssociatedSuccessCount > 0){
            bypassFromBACreationBatch = true;
            update new Quote(id = new List<Id>(quoteIds).get(0), vlocity_cmt__ValidationStatus__c = (!billingSyncFailedOverall && errors.isEmpty() ? 'Ready for Order': 'Billing Sync Failed'));
            bypassFromBACreationBatch = false;
        }    
        
    }
}