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
    public static String purchaseOrderId, lsiPurchaseOrderId;
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
        String quoteType, contextId, businessAccountId, expiredPO, newExpiredPO, poNumberLSI, poUITerm, poUIGroupName, poUIGroupId, poUINumber;
        Boolean UpdatePODetails,createNewPO, isNotLSI =false, POGroupExist;
        Double poUIAmount;
        List<Object> selectedLinkRecords;
        Map<String,Object> poDetailsBlock;
        Map<String,Object> purchaseOrderDetails;
        QuoteLineItem qliObj = new QuoteLineItem();
        List<QuoteLineItem> qliListWithNewPO = new List<QuoteLineItem>();
        Map<String,Object> basaData;
        List<ARTL_Billing_Staging__c> billingStagingList=new List<ARTL_Billing_Staging__c>();
        Map<String, Object> poUIMap = new Map<String, Object>();
        List<QuoteLineItem> qliListWithoutPO = new List<QuoteLineItem>();
        
        try{
            contextId = (String)input.get('ContextId'); 
            System.debug('QuoteEnrichMACDHandler contextId '+contextId);
            selectedLinkRecords=(List<Object>)input.get('rows'); 
            System.debug('QuoteEnrichMACDHandler selectedLinkRecords '+selectedLinkRecords);
            businessAccountId = (String)input.get('businessAccountId');
            System.debug('QuoteEnrichMACDHandler businessAccountId '+businessAccountId);
            quoteType = (String)input.get('QuoteType');
            System.debug('QuoteEnrichMACDHandler quoteType '+quoteType);
            
            UpdatePODetails= quoteType != 'PO Renewal'? (Boolean)input.get('UpdatePODetails'): true;
            System.debug('QuoteEnrichMACDHandler UpdatePODetails '+UpdatePODetails);
            
            purchaseOrderDetails=(Map<String,Object>)input.get('PODetailsBlock');
            System.debug('QuoteEnrichMACDHandler purchaseOrderDetails '+purchaseOrderDetails);
            poUINumber = String.valueof(purchaseOrderDetails.get('PONumber'));
            System.debug('QuoteEnrichMACDHandler poUINumber '+poUINumber);
            
            if(UpdatePODetails && String.isNotEmpty(contextId)){
                if(quoteType == 'Upgrade' ||quoteType == 'Downgrade' || quoteType == 'Shifting' || quoteType == 'Rate Revision' || quoteType == 'Rebilling'){
                    
                    poUITerm      = (String)purchaseOrderDetails.get('POTerms');
                    poUIAmount    = (Double)purchaseOrderDetails.get('POAmount');
                    if(purchaseOrderDetails.get('POGroup-Block')!=null){
                        POGroupExist = true;
                        poUIGroupName = (String)((Map<String,Object>)purchaseOrderDetails.get('POGroup-Block')).get('Name');
                        poUIGroupId = (String)((Map<String,Object>)purchaseOrderDetails.get('POGroup-Block')).get('Id');
                    }else{
                        POGroupExist = false;    
                    }
                    
                    if(quoteType =='Upgrade' ||quoteType == 'Downgrade' || quoteType == 'Shifting' || quoteType == 'Rate Revision'){
                        //For Upgrade/Downgrade/shifting/Rate Revision, Query line items with Action: Change + Add
                        qliListWithoutPO = [SELECT Id, ARTL_Purchase_Order__c, ARTL_LSI__c, vlocity_cmt__Action__c, ARTL_Expired_PO__c, ARTL_Latest_PO__c, Quote.vlocity_cmt__Type__c, vlocity_cmt__AssetId__r.ARTL_Purchase_Order__r.ARTL_PO_Number__c, ARTL_Purchase_Order__r.ARTL_PO_Number__c
                                            FROM QuoteLineItem 
                                            WHERE QuoteId =:contextId AND ((ARTL_Purchase_Order__c =null AND vlocity_cmt__Action__c='Add') OR 
                                                                           (ARTL_Purchase_Order__c!=null AND vlocity_cmt__Action__c='Change'))];
                    System.debug('QuoteEnrichMACDHandler Upgrade/Downgrade/shifting/Rate Revision qliListWithoutPO '+qliListWithoutPO);
                    }else if(quoteType == 'Rebilling'){
                        //For Rebilling, Query All line items.
                        qliListWithoutPO = [SELECT Id, ARTL_Purchase_Order__c, ARTL_LSI__c, vlocity_cmt__Action__c, ARTL_Expired_PO__c, ARTL_Latest_PO__c, Quote.vlocity_cmt__Type__c, vlocity_cmt__AssetId__r.ARTL_Purchase_Order__r.ARTL_PO_Number__c, ARTL_Purchase_Order__r.ARTL_PO_Number__c
                                            FROM QuoteLineItem 
                                            WHERE QuoteId =:contextId];
                        System.debug('QuoteEnrichMACDHandler Rebilling qliListWithoutPO '+qliListWithoutPO);
                    }       
                }
                else if(quoteType =='PO Renewal'){
                    UpdatePODetails=true;
                    poUITerm      = (String)purchaseOrderDetails.get('POTermsReadOnly');
                    poUIAmount    = (Double)purchaseOrderDetails.get('POAmountReadOnly');  
                    if(purchaseOrderDetails.get('POGroupReadOnly-Block')!=null){
                        POGroupExist = true;
                        poUIGroupName = (String)((Map<String,Object>)purchaseOrderDetails.get('POGroupReadOnly-Block')).get('Name');
                        poUIGroupId = (String)((Map<String,Object>)purchaseOrderDetails.get('POGroupReadOnly-Block')).get('Id');    
                    }else{
                        POGroupExist = false;    
                    }
                    List<QuoteLineItem> newQliCreatedList = [Select vlocity_cmt__AssetId__r.ARTL_Purchase_Order__r.ARTL_PO_Number__c FROM QuoteLineItem Where QuoteId =:contextId AND ARTL_LSI__c!=null LIMIT 1];
                    String searchedPONumber = newQliCreatedList[0]. vlocity_cmt__AssetId__r.ARTL_Purchase_Order__r.ARTL_PO_Number__c;
                    System.debug('QuoteEnrichMACDHandler searchedPONumber '+searchedPONumber);
                    qliListWithoutPO = [SELECT Id, ARTL_Purchase_Order__c, ARTL_LSI__c, vlocity_cmt__Action__c, ARTL_Expired_PO__c, ARTL_Latest_PO__c, Quote.vlocity_cmt__Type__c, vlocity_cmt__AssetId__r.ARTL_Purchase_Order__r.ARTL_PO_Number__c, ARTL_Purchase_Order__r.ARTL_PO_Number__c
                                        FROM QuoteLineItem 
                                        WHERE QuoteId =:contextId AND ARTL_Purchase_Order__r.ARTL_PO_Number__c =:searchedPONumber];
                    System.debug('QuoteEnrichMACDHandler PORenewal qliListWithoutPO '+qliListWithoutPO);
                    
                }
            }
            createNewPO = (Boolean)purchaseOrderDetails.get('CreateNewPO') !=null ? (Boolean)purchaseOrderDetails.get('CreateNewPO'):false;
            System.debug('QuoteEnrichMACDHandler POGroupExist '+POGroupExist);
            
            poUIMap.put('StartDate',Date.ValueOf((String)purchaseOrderDetails.get('POStartDate')));
            poUIMap.put('PONumber', poUINumber);
            poUIMap.put('POTerm',poUITerm);
            poUIMap.put('POAmount',poUIAmount);
            poUIMap.put('createNewPO',createNewPO);
            poUIMap.put('POGroupExist',POGroupExist);
            poUIMap.put('POGroupName', poUIGroupName);
            poUIMap.put('POGroupId', poUIGroupId );
            System.debug('QuoteEnrichMACDHandler poUIMap '+poUIMap);
            
            if(UpdatePODetails && poUIMap !=null && String.isNotEmpty(businessAccountId)){
                purchaseOrderId = getCreatedPODetails(poUIMap,businessAccountId);
                System.debug('QuoteEnrichMACDHandler purchaseOrderId'+purchaseOrderId);
                System.debug('QuoteEnrichMACDHandler qliListWithoutPO '+qliListWithoutPO);
                System.debug('QuoteEnrichMACDHandler qliListWithoutPO.size() '+qliListWithoutPO.size()); 
                if(qliListWithoutPO.size()>0){
                    //PO from PrimaryLink, PG From UI, accountId
                    for(QuoteLineItem qliWithoutPO:qliListWithoutPO){  
                        qliWithoutPO.ARTL_Purchase_Order__c = purchaseOrderId;
                        //Fetch LSI PO Number
                        if(qliWithoutPO.ARTL_LSI__c !=null){
                            poNumberLSI= qliWithoutPO.ARTL_Purchase_Order__r.ARTL_PO_Number__c;
                            System.debug('QuoteEnrichMACDHandler poNumberLSI '+poNumberLSI);
                        }
                        // Fetch Non-LSI Line Item
                        if((qliWithoutPO.vlocity_cmt__Action__c =='Add' || qliWithoutPO.vlocity_cmt__Action__c =='Change') && qliWithoutPO.ARTL_LSI__c ==null ){
                            isNotLSI = true;
                            String poGroupUIName =(String)((Map<String,Object>)purchaseOrderDetails.get('POGroup-Block')).get('Name');  
                            System.debug('QuoteEnrichMACDHandler poGroupUIName '+poGroupUIName);
                            lsiPurchaseOrderId = recheckPODetais(poNumberLSI, poGroupUIName ,businessAccountId, poUIMap);
                            System.debug('QuoteEnrichMACDHandler lsiPurchaseOrderId '+lsiPurchaseOrderId);
                            qliWithoutPO.ARTL_Purchase_Order__c = lsiPurchaseOrderId; 
                            isNotLSI = false;     
                        }
                        
                        System.debug('QuoteEnrichMACDHandler qliWithoutPO.ARTL_Expired_PO__c '+qliWithoutPO.ARTL_Expired_PO__c);
                        if(qliWithoutPO.ARTL_Expired_PO__c !=null){
                            expiredPO = qliWithoutPO.ARTL_Expired_PO__c; 
                            
                        }
                        qliObj = qliWithoutPO;
                        System.debug('QuoteEnrichMACDHandler qliObj '+qliObj);
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
                        
                        System.debug('QuoteEnrichMACDHandler poGrpId=> '+poGrpId);
                        System.debug('QuoteEnrichMACDHandler purchaseOrderId=> '+purchaseOrderId);
                        
                        if(poGrpId != null && purchaseOrderId != null){
                            //update po details
                            bs.PO_Start_Date__c   = Date.ValueOf((String)purchaseOrderDetails.get('POStartDate'));
                            bs.PO_Terms_Years__c  = poUITerm;
                            bs.PO_Amount__c       = poUIAmount;
                            bs.PO__c              = String.valueof(purchaseOrderDetails.get('PONumber'));
                            bs.ARTL_PO_Id__c      = purchaseOrderId;
                            bs.ARTL_PO_Group_Id__c= poGrpId;
                            
                            billingStagingList.add(bs);
                            
                            //Update qli details
                            qli.ARTL_Latest_PO__c = purchaseOrderId;
                            System.debug('QuoteEnrichMACDHandler qli.ARTL_Latest_PO__c=> '+qli.ARTL_Latest_PO__c);
                            System.debug('QuoteEnrichMACDHandler quoteType=> '+quoteType);
                            System.debug('QuoteEnrichMACDHandler expiredPO=> '+expiredPO);
                            if(quoteType =='PO Renewal'){
                                //System.debug('QuoteEnrichMACDHandler qli.ARTL_Expired_PO__c=> '+qli.ARTL_Expired_PO__c);
                                if(expiredPO!=null){
                                    qli.ARTL_Expired_PO__c = expiredPO+' , '+qliObj.vlocity_cmt__AssetId__r.ARTL_Purchase_Order__r.ARTL_PO_Number__c;    
                                }else{
                                    System.debug('QuoteEnrichMACDHandler qli.vlocity_cmt__AssetId__r.ARTL_Purchase_Order__r.ARTL_PO_Number__c=> '+qli.vlocity_cmt__AssetId__r.ARTL_Purchase_Order__r.ARTL_PO_Number__c);
                                    
                                    qli.ARTL_Expired_PO__c = qliObj.vlocity_cmt__AssetId__r.ARTL_Purchase_Order__r.ARTL_PO_Number__c;
                                    System.debug('QuoteEnrichMACDHandler qliObj.ARTL_Expired_PO__c=> '+qliObj.ARTL_Expired_PO__c);
                                }
                            }
                            
                            qliListWithNewPO.add(qli);
                            
                        }
                    }
                    System.debug('QuoteEnrichMACDHandler billingStagingList=> '+billingStagingList);
                    if(billingStagingList.size()>0){
                        update billingStagingList;
                        output.put('isQLIUpdate',true);  
                    }
                    else{
                        output.put('isQLIUpdate',false);   
                    }
                    System.debug('QuoteEnrichMACDHandler qliListWithNewPO=> '+qliListWithNewPO);
                    if(qliListWithNewPO.size()>0){
                        update qliListWithNewPO;
                        output.put('isQLIUpdate',true);
                    }
                }else{
                	output.put('isQLIUpdate',false);    
                }  
            }
            
        }catch(Exception e){
            System.debug('Exception in class::ARTL_QuoteEnrichMACDHandler and method::createPODetails @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
            output.put('isQLIUpdate',false);
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
    public static Id getCreatedPODetails(Map<String,Object> poMap, String businessAccId){
        
        System.debug('QuoteEnrichMACDHandler poMap'+JSON.SerializePretty(poMap));
        String poNumber, poGroupName;
        Boolean createNewPO;
        try{
            
            
            if((Boolean)poMap.get('POGroupExist')){
                if((Boolean)poMap.get('createNewPO')){
                    createNewPO=(Boolean)poMap.get('CreateNewPO');
                    if(createNewPO){
                        PO_Group__c pOGrp=new PO_Group__c();
                        insert pOGrp;
                        poGrpId=pOGrp.Id;
                    }
                    else{
                        poGrpId     = (String)poMap.get('POGroupId');
                        poGroupName = (String)poMap.get('POGroupName');
                    } 
                }else{
                    poGrpId     = (String)poMap.get('POGroupId');
                    poGroupName = (String)poMap.get('POGroupName');
                    
                }
            }
            
            poNumber = (String)poMap.get('PONumber');
            //Check if PO Number entereed exist, If Not create or update.
            if(businessAccId!=null && poNumber!=null && poGroupName!=null){
                List<ARTL_Purchase_Order__c> checkPOExist = [SELECT id,artl_po_number__c,artl_account__c 
                                                             FROM ARTL_Purchase_Order__c 
                                                             WHERE (ARTL_Account__c =:businessAccId AND ARTL_PO_Number__c =:poNumber AND PO_Group__r.Name=:poGroupName) LIMIT 50000];
                
                if(checkPOExist.size()== 0){
                    ARTL_Purchase_Order__c newPO = new ARTL_Purchase_Order__c();
                    newPO.ARTL_PO_Recieved_Date__c = (Date)poMap.get('StartDate');
                    newPO.Amount__c= (Decimal)poMap.get('POAmount');
                    newPO.Tenure__c= (String)poMap.get('POTerm');
                    newPO.ARTL_PO_Number__c= (String)poMap.get('PONumber');
                    newPO.ARTL_Account__c = businessAccId;
                    if(poGrpId != null){
                        newPO.PO_Group__c=poGrpId;
                    }
                    insert newPO;
                    purchaseOrderId = newPO.Id;
                }
                else if(checkPOExist.size()>0){
                    purchaseOrderId = checkPOExist[0].Id;
                }
            }else if(businessAccId!=null && poNumber!=null && poGroupName == null){
                
                List<ARTL_Purchase_Order__c> checkPOExistNG = [SELECT id,artl_po_number__c,artl_account__c 
                                                               FROM ARTL_Purchase_Order__c 
                                                               WHERE (ARTL_Account__c =:businessAccId AND ARTL_PO_Number__c =:poNumber) LIMIT 50000];
                
                if(checkPOExistNG.size()==0){
                    ARTL_Purchase_Order__c newPO = new ARTL_Purchase_Order__c();
                    newPO.ARTL_PO_Recieved_Date__c = (Date)poMap.get('StartDate');
                    newPO.Amount__c= (Decimal)poMap.get('POAmount');
                    newPO.Tenure__c= (String)poMap.get('POTerm');
                    newPO.ARTL_PO_Number__c= (String)poMap.get('PONumber');
                    newPO.ARTL_Account__c = businessAccId;
                    insert newPO;
                    purchaseOrderId = newPO.Id;
                }
                else if(checkPOExistNG.size()>0){
                    purchaseOrderId = checkPOExistNG[0].Id;
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
* Name         :  recheckPODetais
* Author       :  Rakesh Rajan (SFI Dev)
* Date         :  02 Jan, 2024
* Description  :  used to create PO details. 
*/
    public static Id recheckPODetais(String poLSINumber,String poGroupUINumber,String businessAccId, Map<String,Object> poMap){
        Boolean createNewPO;
        String poNumber, poGroupName;
        System.debug('QuoteEnrichMACDHandler purchaseOrderDetails'+JSON.SerializePretty(purchaseOrderDetails));
        
        try{
            System.debug('QuoteEnrichMACDHandler purchaseOrderDetails.get(CreateNewPO)'+purchaseOrderDetails.get('CreateNewPO'));  
            
            //update PO details: need to check.
            //Check if PO Number entereed exist, If Not create or update.
            if(businessAccId!=null && poNumber!=null && poGroupName!=null){
                List<ARTL_Purchase_Order__c> checkPOExist = [SELECT id,artl_po_number__c,artl_account__c 
                                                             FROM ARTL_Purchase_Order__c 
                                                             WHERE (ARTL_Account__c =:businessAccId AND ARTL_PO_Number__c =:poLSINumber AND PO_Group__r.Name=:poGroupUINumber) LIMIT 50000];
                
                if(checkPOExist.size()== 0){
                    ARTL_Purchase_Order__c newPO = new ARTL_Purchase_Order__c();
                    newPO.ARTL_PO_Recieved_Date__c = (Date)poMap.get('StartDate');
                    newPO.Amount__c= (Decimal)poMap.get('POAmount');
                    newPO.Tenure__c= (String)poMap.get('POTerm');
                    newPO.ARTL_PO_Number__c= (String)poMap.get('PONumber');
                    newPO.ARTL_Account__c = businessAccId;
                    if(poGrpId != null){
                        newPO.PO_Group__c=poGrpId;
                    }
                    insert newPO;
                    purchaseOrderId = newPO.Id;
                }
                else if(checkPOExist.size()>0){
                    purchaseOrderId = checkPOExist[0].Id;
                }
            }else if(businessAccId!=null && poNumber!=null && poGroupName == null){
                
                List<ARTL_Purchase_Order__c> checkPOExistNG = [SELECT id,artl_po_number__c,artl_account__c 
                                                               FROM ARTL_Purchase_Order__c 
                                                               WHERE (ARTL_Account__c =:businessAccId AND ARTL_PO_Number__c =:poNumber) LIMIT 50000];
                
                if(checkPOExistNG.size()==0){
                    ARTL_Purchase_Order__c newPO = new ARTL_Purchase_Order__c();
                    newPO.ARTL_PO_Recieved_Date__c = (Date)poMap.get('StartDate');
                    newPO.Amount__c= (Decimal)poMap.get('POAmount');
                    newPO.Tenure__c= (String)poMap.get('POTerm');
                    newPO.ARTL_PO_Number__c= (String)poMap.get('PONumber');
                    newPO.ARTL_Account__c = businessAccId;
                    insert newPO;
                    purchaseOrderId = newPO.Id;
                }
                else if(checkPOExistNG.size()>0){
                    purchaseOrderId = checkPOExistNG[0].Id;
                }
            }
        }
        catch(Exception e){
            System.debug('Exception in class::ARTL_QuoteEnrichMACDHandler and method::recheckPODetais @line number' +
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
        Set<String> purchaseOrderIdSetWithoutPOGroup = new Set<String>();
        
        try{
            
            List<ARTL_Purchase_Order__c> purchaseOrderWithoutPOGroupList = [SELECT Id, Name, PO_Group__c, PO_Group__r.Name 
                                                                            FROM ARTL_Purchase_Order__c 
                                                                            WHERE PO_Group__c !=null];
            
            if(purchaseOrderWithoutPOGroupList.size() > 0){
                for(ARTL_Purchase_Order__c purchaseOrderWithoutPOGroup: purchaseOrderWithoutPOGroupList){
                    purchaseOrderIdSetWithoutPOGroup.add(purchaseOrderWithoutPOGroup.PO_Group__c);
                }
            }
            
            
            if(input.containsKey('POGroup')){
                poGroupList=(List<Object>)input.get('POGroup');
                System.debug('QuoteEnrichMACDHandler poGroupList '+poGroupList);
                if(poGroupList.size() > 0){
                    for(Object obj: poGroupList){
                        Map<String,Object> objMap = (Map<String,Object>)obj;
                        if(!purchaseOrderIdSetWithoutPOGroup.contains(String.valueOf(objMap.get('Id')))){
                            objMap.put('Name',objMap.get('Name')+' - New');
                        }
                    }
                    output.put('POGroup',poGroupList);
                }
            }
            
            if(input.containsKey('LegalEntity')){
                legalEntityList = (List<Object>)input.get('LegalEntity');
                if(legalEntityList.size() > 0){
                    for(Object obj1:legalEntityList){
                        Map<String,Object> objMap1 = (Map<String,Object>)obj1; 
                        String nameValue = String.valueOf(objMap1.get('Name'));
                        Map<String, String> legalEntityMap = new Map<String, String>();
                        if(!legalEntitySet.contains(nameValue)){
                            legalEntityMap.put('Name',nameValue);
                            newLegalEntityList.add(legalEntityMap);
                        }
                        legalEntitySet.add(nameValue);           
                    }
                    output.put('LegalEntity',newLegalEntityList);
                }
            }
            
        }catch(Exception e){
            
            output.put('Error Message', e.getMessage());
            output.put('Error Line Number', e.getLineNumber());
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
        Map<String,Object> basaData;
        List<ARTL_Billing_Staging__c> billingStagingList=new List<ARTL_Billing_Staging__c>();
        
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
            output.put('isBSUpdate',true);
            
        }catch(Exception e){
            system.debug('Exception');
            output.put('isBSUpdate',false);
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