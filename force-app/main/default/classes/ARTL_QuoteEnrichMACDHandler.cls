/************************************************************************************************************************************************************************************************************
* @Class Name   : ARTL_QuoteEnrichMACDHandler
* @Author       : Rakesh Rajan <rakesh.rajan@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 13/11/2023
* @Test Class   : ARTL_QuoteEnrichMACDHandlerTest
* @Description  : Apex Handler Class that have Apex class methods related to Quote Enrich MACD Scenarios
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1. SFDC-                Rakesh Rajan          01/01/2023     Initial Dev
******************************************************************************************************************************************************************************************************************/

global class ARTL_QuoteEnrichMACDHandler implements vlocity_cmt.VlocityOpenInterface{
    public static String purchaseOrderId;
    public static String poGrpId;
    public static Map<String,Object> purchaseOrderDetails;
    global boolean invokeMethod(String methodName,Map<String,Object> input,Map<String,Object> output,Map<String,Object> option){
        system.debug('invoke method');
        if(methodName.equalsIgnoreCase('CreatePODetails')){
            return createPODetails(input, output, option);   
        }
        if(methodName.equalsIgnoreCase('LabelPOGroup')){
            return labelPOGroup(input, output, option);
        }
        if(methodName.equalsIgnoreCase('UpdateBSDetials')){
            return updateBASAForMACD(input, output, option);
        }
        else{
            return false;
        }
    }
    
    /*
* Name         :  CreatePODetails
* Author       :  Rakesh Rajan (SFI Dev)
* Date         :  02 Jan, 2024
* Description  :  used to create PO & implement PO against charges for MACD scenerios. 
*/
    public static boolean createPODetails(Map<String,Object> input,Map<String,Object> output,Map<String,Object> option){
        String quoteType, contextId, businessAccountId, expiredPO;
        List<Object> selectedLinkRecords;
        Map<String,Object> poDetailsBlock;
        Map<String,Object> purchaseOrderDetails;
        Boolean UpdatePODetails,createNewPO;
        QuoteLineItem qliObj = new QuoteLineItem();
        List<QuoteLineItem> qliListWithNewPO = new List<QuoteLineItem>();
        Map<String,Object> basaData;
        List<ARTL_Billing_Staging__c> billingStagingList=new List<ARTL_Billing_Staging__c>();
        try{
            
            //System.debug('QuoteEnrichMACDHandler input map=>'+JSON.SerializePretty(input));
            contextId = (String)input.get('ContextId');
            System.debug('QuoteEnrichMACDHandler contextId '+contextId);
            selectedLinkRecords=(List<Object>)input.get('rows');
            System.debug('QuoteEnrichMACDHandler selectedLinkRecords '+selectedLinkRecords);
            businessAccountId = (String)input.get('businessAccountId');
            System.debug('QuoteEnrichMACDHandler businessAccountId '+businessAccountId);
            quoteType = (String)input.get('QuoteType');
            System.debug('QuoteEnrichMACDHandler quoteType '+quoteType);
            if(quoteType !='PO Renewal'){
                UpdatePODetails=(Boolean)input.get('UpdatePODetails');
                System.debug('QuoteEnrichMACDHandler UpdatePODetails '+UpdatePODetails);   
            }
            else if(quoteType =='PO Renewal'){
                UpdatePODetails=true;
            }
            
            
            if(UpdatePODetails){
                purchaseOrderDetails=(Map<String,Object>)input.get('PODetailsBlock');
                System.debug('QuoteEnrichMACDHandler purchaseOrderDetails '+purchaseOrderDetails);
                purchaseOrderId = getCreatedPODetails(purchaseOrderDetails, businessAccountId);
                system.debug('purchaseOrderId'+purchaseOrderId);
                if(String.isNotEmpty(contextId)){
                    List<QuoteLineItem> qliListWithoutPO = [SELECT Id, ARTL_Purchase_Order__c, vlocity_cmt__Action__c, ARTL_Expired_PO__c, ARTL_Latest_PO__c, Quote.vlocity_cmt__Type__c, vlocity_cmt__AssetId__r.ARTL_Purchase_Order__r.ARTL_PO_Number__c
                                                            FROM QuoteLineItem 
                                                            WHERE QuoteId =:contextId AND ((Quote.vlocity_cmt__Type__c !='PO Renewal' AND ARTL_Purchase_Order__c=null AND vlocity_cmt__Action__c='Add') OR 
                                                                                           (Quote.vlocity_cmt__Type__c !='PO Renewal' AND ARTL_Purchase_Order__c!=null AND vlocity_cmt__Action__c='Change') OR 
                                                                                           (Quote.vlocity_cmt__Type__c ='PO Renewal' AND ARTL_Purchase_Order__c!=null AND vlocity_cmt__Action__c='Existing') OR
                                                                                           (Quote.vlocity_cmt__Type__c ='Rebilling' AND ARTL_Purchase_Order__c!=null AND vlocity_cmt__Action__c='Existing'))];
                    System.debug('QuoteEnrichMACDHandler qliListWithoutPO '+qliListWithoutPO);
                    System.debug('QuoteEnrichMACDHandler qliListWithoutPO.size() '+qliListWithoutPO.size()); 
                    if(qliListWithoutPO.size()>0){
                        for(QuoteLineItem qliWithoutPO:qliListWithoutPO){  
                            qliWithoutPO.ARTL_Purchase_Order__c = purchaseOrderId; 
                            if(qliWithoutPO.ARTL_Expired_PO__c !=null){
                                expiredPO = qliWithoutPO.ARTL_Expired_PO__c; 
                                qliObj = qliWithoutPO;
                            }
                        }
                        update qliListWithoutPO;
                        
                        //Update billing staging records with necessary details
                        for(Object selLinkRecord:selectedLinkRecords){
                            
                            basaData=(Map<String,Object>)selLinkRecord;
                            System.debug('QuoteEnrichMACDHandler basaData=> '+basaData);
                            ARTL_Billing_Staging__c bs=new ARTL_Billing_Staging__c();
                            bs.Id=(Id)basaData.get('BSId');
                            
                            QuoteLineItem qli = new QuoteLineItem();
                            qli.Id =(Id)basaData.get('Id');
                            
                            //System.debug('QuoteEnrichMACDHandler UpdatePODetails=> '+UpdatePODetails);
                            System.debug('QuoteEnrichMACDHandler poGrpId=> '+poGrpId);
                            System.debug('QuoteEnrichMACDHandler purchaseOrderId=> '+purchaseOrderId);
                            
                            if(UpdatePODetails && poGrpId != null && purchaseOrderId != null){
                                //update po details
                                bs.ARTL_PO_Group_Id__c= poGrpId;
                                bs.PO_Start_Date__c   = Date.ValueOf((String)purchaseOrderDetails.get('POStartDate'));
                                bs.PO_Terms_Years__c  = (String)purchaseOrderDetails.get('POTerms');
                                bs.PO_Amount__c       = (Double)purchaseOrderDetails.get('POAmount');
                                bs.PO__c              = String.valueof(purchaseOrderDetails.get('PONumber'));
                                bs.ARTL_PO_Id__c      = purchaseOrderId;
                                billingStagingList.add(bs);
                                
                                //Update qli details
                                qli.ARTL_Latest_PO__c = purchaseOrderId;
                                
                                
                                System.debug('QuoteEnrichMACDHandler quoteType=> '+quoteType);
                                System.debug('QuoteEnrichMACDHandler expiredPO=> '+expiredPO);
                                if(quoteType =='PO Renewal'){
                                    //System.debug('QuoteEnrichMACDHandler qli.ARTL_Expired_PO__c=> '+qli.ARTL_Expired_PO__c);
                                    if(expiredPO!=null){
                                        qli.ARTL_Expired_PO__c = expiredPO+' , '+qliObj.vlocity_cmt__AssetId__r.ARTL_Purchase_Order__r.ARTL_PO_Number__c;    
                                    }else{
                                        System.debug('QuoteEnrichMACDHandler qliObj.vlocity_cmt__AssetId__r.ARTL_Purchase_Order__r.ARTL_PO_Number__c=> '+qliObj.vlocity_cmt__AssetId__r.ARTL_Purchase_Order__r.ARTL_PO_Number__c);
                                        
                                        qli.ARTL_Expired_PO__c = qliObj.vlocity_cmt__AssetId__r.ARTL_Purchase_Order__r.ARTL_PO_Number__c;
                                        System.debug('QuoteEnrichMACDHandler qli.ARTL_Expired_PO__c=> '+qli.ARTL_Expired_PO__c);
                                    }
                                }
                                
                                qliListWithNewPO.add(qli);
                                
                                
                            }
                        }
                        System.debug('QuoteEnrichMACDHandler billingStagingList=> '+billingStagingList);
                        if(billingStagingList.size()>0){
                            update billingStagingList;
                        }
                        System.debug('QuoteEnrichMACDHandler qliListWithNewPO=> '+qliListWithNewPO);
                        if(qliListWithNewPO.size()>0){
                            update qliListWithNewPO;
                        }
                        
                        
                    }  
                }   
            }
        }catch(Exception e){
            System.debug('Exception in class::ARTL_QuoteEnrichMACDHandler and method::createPODetails @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
            output.put('Error Message', e.getMessage());
            output.put('Error Line Number', e.getLineNumber());
            
        }
        return true;
    }
    
    /*
* Name         :  getCreatedPODetails
* Author       :  Rakesh Rajan (SFI Dev)
* Date         :  02 Jan, 2024
* Description  :  used to create PO details. 
*/
    public static Id getCreatedPODetails(Map<String,Object> purchaseOrderDetails, String businessAccId){
        Boolean createNewPO;
        String poNumber;
        System.debug('QuoteEnrichMACDHandler purchaseOrderDetails'+JSON.SerializePretty(purchaseOrderDetails));
        
        try{
            System.debug('QuoteEnrichMACDHandler purchaseOrderDetails.get(CreateNewPO)'+purchaseOrderDetails.get('CreateNewPO'));  
            if(purchaseOrderDetails.get('CreateNewPO') != null){
                createNewPO=(Boolean)purchaseOrderDetails.get('CreateNewPO');
                if(createNewPO){
                    PO_Group__c pOGrp=new PO_Group__c();
                    insert pOGrp;
                    poGrpId=pOGrp.Id;
                }
                else{
                    poGrpId=(Id)((Map<String,Object>)purchaseOrderDetails.get('POGroup-Block')).get('Id');
                } 
            }else{
                poGrpId=(Id)((Map<String,Object>)purchaseOrderDetails.get('POGroup-Block')).get('Id');
            }
            poNumber = String.valueof(purchaseOrderDetails.get('PONumber'));
            //update PO details: need to check.
            //Check if PO Number entereed exist, If Not create or update.
            if(businessAccId!=null && poNumber!=null){
                List<ARTL_Purchase_Order__c> checkPOExist = [SELECT id,artl_po_number__c,artl_account__c 
                                                             FROM ARTL_Purchase_Order__c 
                                                             WHERE (ARTL_Account__c =:businessAccId AND ARTL_PO_Number__c =:poNumber) LIMIT 50000];
                
                if(checkPOExist.size()== 0){
                    if(poGrpId != null){
                        ARTL_Purchase_Order__c newPO = new ARTL_Purchase_Order__c();
                        //newPO.Start_Date__c=Date.ValueOf((String)purchaseOrderDetails.get('POStartDate'));
                        newPO.ARTL_PO_Recieved_Date__c = Date.ValueOf((String)purchaseOrderDetails.get('POStartDate'));
                        newPO.Amount__c=(Decimal)purchaseOrderDetails.get('POAmount');
                        newPO.Tenure__c=(String)purchaseOrderDetails.get('POTerms');
                        //Tenure__c editted by Prabanch since the Tenure__c field datatype ic changed
                        //Commented by RR since EndDate is now populated by OM. 
                        //newPO.End_Date__c = newPO.Start_Date__c.addYears(Integer.valueOf(newPO.Tenure__c)); 
                        newPO.ARTL_PO_Number__c=String.valueof(purchaseOrderDetails.get('PONumber'));
                        newPO.ARTL_Account__c = businessAccId;
                        newPO.PO_Group__c=poGrpId;
                        
                        insert newPO;
                        purchaseOrderId = newPO.Id;
                    }  
                }
            }
            
            
        }
        catch(Exception e){
            System.debug('Exception in class::ARTL_QuoteEnrichMACDHandler and method::getCreatedPODetails @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
        return purchaseOrderId;
    }    
    
    /*
* Name         :  labelPOGroup
* Author       :  Rakesh Rajan (SFI Dev)
* Date         :  02 Jan, 2024
* Description  :  used to populate PO Group/ Legal Entity labels during New Connect/ MACD Enrich Quote flow
*/
    public static boolean labelPOGroup(Map<String,Object> input,Map<String,Object> output,Map<String,Object> option){
        
        List<Object> poGroupList;
        List<Object> legalEntityList;
        List<Object> newLegalEntityList = new List<Object>();
        
        List<String> uniqueLegalEntityList = new List<String>();
        Set<String> legalEntitySet = new Set<String>();
        
        try{
            Set<String> purchaseOrderIdSetWithoutPOGroup = new Set<String>();
            List<ARTL_Purchase_Order__c> purchaseOrderWithoutPOGroupList = [Select Id, Name, PO_Group__c, PO_Group__r.Name From ARTL_Purchase_Order__c Where PO_Group__c !=null];
            for(ARTL_Purchase_Order__c purchaseOrderWithoutPOGroup: purchaseOrderWithoutPOGroupList){
                purchaseOrderIdSetWithoutPOGroup.add(purchaseOrderWithoutPOGroup.PO_Group__c);
            }
            
            if(input.containsKey('POGroup')){
                
                poGroupList=(List<Object>)input.get('POGroup');
                System.debug('QuoteEnrichMACDHandler poGroupList '+poGroupList);
                for(Object obj: poGroupList){
                    Map<String,Object> objMap = (Map<String,Object>)obj;
                    if(!purchaseOrderIdSetWithoutPOGroup.contains(String.valueOf(objMap.get('Id')))){
                        objMap.put('Name',objMap.get('Name')+' - New');
                    }
                }
                output.put('POGroup',poGroupList);
            }
            if(input.containsKey('LegalEntity')){
                legalEntityList = (List<Object>)input.get('LegalEntity');
                System.debug('QuoteEnrichMACDHandler legalEntityList '+legalEntityList);
                for(Object obj1:legalEntityList){
                    Map<String,Object> objMap1 = (Map<String,Object>)obj1; 
                    String nameValue = String.valueOf(objMap1.get('Name'));
                    //System.debug('QuoteEnrichMACDHandler nameValue '+nameValue );
                    
                    
                    //System.debug('QuoteEnrichMACDHandler legalEntitySet'+legalEntitySet);
                    Map<String, String> legalEntityMap = new Map<String, String>();
                    if(!legalEntitySet.contains(nameValue)){
                        //System.debug('QuoteEnrichMACDHandler Inside IF');
                        legalEntityMap.put('Name',nameValue);
                        newLegalEntityList.add(legalEntityMap);
                    }
                    legalEntitySet.add(nameValue);           
                }
                output.put('LegalEntity',newLegalEntityList);
            }
            
        }catch(Exception e){
            System.debug('Exception in class::ARTL_QuoteEnrichMACDHandler and method::labelPOGroup @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
        return true;
    }
    
    /*
* Name         :  updateBASAForMACD
* Author       :  Saurav M (SFI Dev)
* Date         :  02 Jan, 2024
* Description  :  used to update BASA during MACD Enrich Quote flow
*/
    
    public static boolean updateBASAForMACD(Map<String,Object> input,Map<String,Object> output,Map<String,Object> option){
        //Declare necessary variables
        List<Object> selectedBASARecords,newBillingContactList;
        Map<String,Object> gSTApplicableForBillingBlock,bcpBlock,bcpBlockDetails,BillingDetailsBlock, LegalEntityBlock, newBCPMap,inputMap;
        Boolean UpdatePODetails,UpdateGSTApplicable,UpdateBCPDetails,UpdateBillingDetails,createNewPO,createBillingContact;
        String businessAccountId;
        
        try{
            system.debug('input =>'+JSON.SerializePretty(input));
            inputMap=(Map<String,Object>)input.get('bsDetails');
            businessAccountId = (String)input.get('businessAccountId');
            //Set flags from the input: these flags decide the operations need to be done in the code
            UpdatePODetails=(Boolean)inputMap.get('UpdatePODetails');
            UpdateGSTApplicable=(Boolean)inputMap.get('SelectGSTApplicableForBilling');
            UpdateBCPDetails=(Boolean)inputMap.get('UpdateBillingContacts');
            UpdateBillingDetails=(Boolean)inputMap.get('UpdateBillingDetails');
            
            
            selectedBASARecords=(List<Object>)input.get('rows');
            
            
            Map<String,Object> basaData;
            
            List<ARTL_Billing_Staging__c> billingStagingList=new List<ARTL_Billing_Staging__c>();
            //Update billing staging records with necessary details
            for(Object basa:selectedBASARecords){
                
                basaData=(Map<String,Object>)basa;
                
                ARTL_Billing_Staging__c bs=new ARTL_Billing_Staging__c();
                bs.Id=(Id)basaData.get('BSId');
                
                //update gst applicable
                if(UpdateGSTApplicable){
                    gSTApplicableForBillingBlock=(Map<String,Object>)inputMap.get('GSTApplicableForBillingBlock');
                    system.debug('gSTApplicableForBillingBlock input =>'+JSON.SerializePretty(gSTApplicableForBillingBlock));
                    if((String)gSTApplicableForBillingBlock.get('GSTApplicableForBilling')=='Delivery GST'){
                        bs.Billing_GST_Applicable_for_Billing__c =false;
                        bs.Site_GST_Applicable_for_Billing__c  =true;
                    }else{
                        bs.Billing_GST_Applicable_for_Billing__c =true;
                        bs.Site_GST_Applicable_for_Billing__c  =false;
                    }
                }
                //update bcp details
                if(UpdateBCPDetails){
                    bcpBlock=(Map<String,Object>)inputMap.get('BillingContactsBlock');
                    system.debug('bcpBlock input =>'+JSON.SerializePretty(bcpBlock));
                    createBillingContact=(boolean)bcpBlock.get('CreateNewBillingContact');
                    if(!createBillingContact){
                        bcpBlockDetails=(Map<String,Object>)bcpBlock.get('BillingContactPerson-Block');
                        bs.BCP_Id__c=(String)bcpBlockDetails.get('BCPId');
                        bs.BCP_First_Name__c=(String)bcpBlockDetails.get('BCPFirstName');
                        bs.BCP_Last_Name__c=(String)bcpBlockDetails.get('BCPLastName');
                        bs.BCP_Email__c=(String)bcpBlockDetails.get('BCPEmail');
                        bs.BCP_Phone__c=(String)bcpBlockDetails.get('BCPMobile');
                    }else{
                        newBillingContactList=(List<object>)input.get('newBCP');
                        //Map<String,Object> newBCP=(Map<String,Object>)bcpBlock.get('BCPAddress-Block');
                        newBCPMap=(Map<String,Object>)newBillingContactList[0];
                        bs.BCP_Id__c=(String)newBCPMap.get('Id');
                        bs.BCP_First_Name__c=(String)bcpBlock.get('FirstNameEdit');
                        bs.BCP_Last_Name__c=(String)bcpBlock.get('LastNameEdit');
                        bs.BCP_Email__c=(String)bcpBlock.get('EmailEdit');
                        bs.BCP_Phone__c=(String)bcpBlock.get('MobileEdit');
                    }
                    
                }
                //update billing deatils
                if(UpdateBillingDetails){
                    ////PODetailsStep:BillingDetailsBlock:LegalEntity-Block:LegalEntity
                    BillingDetailsBlock=(Map<String,Object>)inputMap.get('BillingDetailsBlock');
                    LegalEntityBlock = (Map<String, Object>) BillingDetailsBlock.get('LegalEntity-Block');
                    bs.Bill_Type__c=(String)BillingDetailsBlock.get('BillType');
                    bs.Billing_Level__c=(String)BillingDetailsBlock.get('BillingLevel');
                    bs.Credit_Period__c=(String)BillingDetailsBlock.get('CreditPeriod');
                    bs.Store__c=(String)BillingDetailsBlock.get('Store');
                    //bs.Legal_Entity__c=(String)BillingDetailsBlock.get('LegalEntity');
                    bs.Legal_Entity__c=(String)LegalEntityBlock.get('LegalEntity');
                    bs.ARTL_Bill_Dispatch_Method__c = (String)BillingDetailsBlock.get('BillDispatchMethod');
                    bs.ARTL_Bill_Frequency__c =(String)BillingDetailsBlock.get('BillFrequency');
                    System.debug('QuoteEnrichMACDHandler bs.Legal_Entity__c '+bs.Legal_Entity__c);
                    System.debug('QuoteEnrichMACDHandler businessAccountId '+businessAccountId);
                    if(bs.Legal_Entity__c!=null){
                        bs.VAN_Account_Number__c  = getVANAccountNumberDetails(bs.Legal_Entity__c, businessAccountId); 
                        System.debug('QuoteEnrichMACDHandler bs.VAN_Account_Number__c '+bs.VAN_Account_Number__c);
                    } 
                }
                
                billingStagingList.add(bs);
            }
            system.debug('billingStagingList input =>'+JSON.SerializePretty(billingStagingList));
            update billingStagingList;
            
        }catch(Exception e){
            system.debug('Exception');
            System.debug('Exception in class::ARTL_QuoteEnrichMACDHandler and method::updateBASAForMACD @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
        return true;
    }
    
    /*
* Name         :  getVANAccountNumberDetails
* Author       :  Rakesh Rajan (SFI Dev)
* Date         :  23 Jan, 2024
* Description  :  used to fetch VAN Account Number. 
*/
    public static String getVANAccountNumberDetails(String legalEntity, String businessAccount){
        String vanAccountNumber;
        try{
            System.debug('QuoteEnrichMACDHandler legalEntity '+legalEntity);
            System.debug('QuoteEnrichMACDHandler businessAccount '+businessAccount);
            if(legalEntity!=null && businessAccount!=null){
                List<ARTL_VAN_AccountNumbers__c> vanAccountNumbers  =[SELECT Id, ARTL_Legal_Entity_Name__c, ARTL_Business_Account__c 
                                                                      FROM ARTL_VAN_AccountNumbers__c 
                                                                      WHERE ARTL_Legal_Entity_Name__c=:legalEntity AND ARTL_Business_Account__c=:businessAccount LIMIT 1];
                System.debug('QuoteEnrichMACDHandler vanAccountNumbers '+vanAccountNumbers);
                if(vanAccountNumbers.size()>0){
                    vanAccountNumber= vanAccountNumbers[0].Id;
                }
            }
            
        }
        catch(Exception e){
            System.debug('Exception in class::ARTL_QuoteEnrichMACDHandler and method::getVANAccountNumberDetails @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
        return vanAccountNumber;
    }    
}