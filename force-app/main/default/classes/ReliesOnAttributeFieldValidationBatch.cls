/******************************************************************************************************
* @Author:      Shishir Bansal
* @Company:     Salesforce
* @Date:        13th Feb 2024
* @Reviewer:
* @Review Date:
* @Description: This Batch apex is used for Attribute Validation feature.
* ++++++++++++++++++++++ Changes Implemented / Modification Log ++++++++++++++++++++++++++++++++++++++
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1. SFDC-                              
*******************************************************************************************************/
public with sharing class ReliesOnAttributeFieldValidationBatch implements Database.Batchable<sObject>, Database.Stateful{

    public Map<String,Map<String, Artl_ReliesOnValidations__mdt>> customMetadataMap;
    public final String quoteId;
    public string errorMessage='';
    public String rootSourceTargetVal ='';
    public String qliFieldString='';
    public string customNotificationErrorMsg='';
    public string customNotificationSuccessMsg='';


    public set<String> fieldsToQuery = new set<String> ();


    //Constructor to intialise custom metadata map, quote id and QLI fields to validate
    public ReliesOnAttributeFieldValidationBatch(Map<String,Map<String, Artl_ReliesOnValidations__mdt>> paramCustomMetadataMap , String quoteIdVal, String fieldString, set<String> fieldsParam) {

        
        customMetadataMap = paramCustomMetadataMap; 
        quoteId = quoteIdVal;
        qliFieldString=fieldString;

        customNotificationErrorMsg = System.Label.FailureMessageForCustomNotificationInAttributeValidation; //Setting error message for custom notification
        customNotificationSuccessMsg = System.Label.SuccessMessageForCustomNotificaiton; //Setting success message for custom notification
        //fieldsToQuery =fieldsParam;

        system.debug('customMetadataMap @@ '+customMetadataMap);
        system.debug('quoteId @@'+quoteId);
        system.debug('qliFieldString inside Batch @@'+qliFieldString);

    }

    public Database.QueryLocator start(Database.BatchableContext BC){

        String query ='SELECT Id, vlocity_cmt__QuoteLineItemId__c, vlocity_cmt__QuoteLineItemId__r.QuoteId,'+
        'vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__Product2Id__r.Name,'+
        'vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__AssetReferenceId__c,'+
        'vlocity_cmt__RelatedQuoteLineItemId__c, vlocity_cmt__RelatedQuoteLineItemId__r.QuoteId,vlocity_cmt__RelatedQuoteLineItemId__r.vlocity_cmt__Product2Id__r.Name,'+'vlocity_cmt__RelatedQuoteLineItemId__r.vlocity_cmt__AssetReferenceId__c,'+
        'vlocity_cmt__RelatedAssetReferenceId__c, vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__Product2Id__c,'+
        'vlocity_cmt__RelatedQuoteLineItemId__r.vlocity_cmt__Product2Id__c'+
        ' FROM vlocity_cmt__QuoteLineItemRelationship__c'+' WHERE vlocity_cmt__QuoteId__c ='+'\''+quoteId+'\''+' AND  vlocity_cmt__RelationshipType__c = \'ReliesOn\'';
        system.debug('query '+JSON.serializePretty(query));
        return Database.getQueryLocator(query);

     }


    public void execute(Database.BatchableContext BC, List<vlocity_cmt__QuoteLineItemRelationship__c> scope){

        system.debug('scope @@'+scope);


        for(vlocity_cmt__QuoteLineItemRelationship__c qlirRec : scope){

            Map<String,Map<String,QuoteLineItem>> sourceBundleMap; //Source QLI data
            Map<String,Map<String,QuoteLineItem>> targetBundleMap; //Target QLI data

            Map<String,Map<String,Asset>> sourceAssetBundleMap; //Asset data

            
            //When the relationship is between two products in the same quote
            if((qlirRec.vlocity_cmt__RelatedQuoteLineItemId__c !=null)  && (qlirRec.vlocity_cmt__QuoteLineItemId__r.QuoteId == quoteId) && (qlirRec.vlocity_cmt__RelatedQuoteLineItemId__r.QuoteId == quoteId) ){



                sourceBundleMap = new Map<String,Map<String,QuoteLineItem>>();
                //Fetch QLI records for source product
                sourceBundleMap =getQLIRecords(qlirRec.vlocity_cmt__RelatedQuoteLineItemId__r.vlocity_cmt__Product2Id__r.Name,qlirRec.vlocity_cmt__RelatedQuoteLineItemId__r.vlocity_cmt__AssetReferenceId__c,quoteId);

                targetBundleMap=new Map<String,Map<String,QuoteLineItem>>();
                //Fetch QLI records for target product
                targetBundleMap= getQLIRecords(qlirRec.vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__Product2Id__r.Name,qlirRec.vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__AssetReferenceId__c,quoteId);

                // Constructing a unique identifier for source and target bundle data.
                rootSourceTargetVal = qlirRec.vlocity_cmt__RelatedQuoteLineItemId__r.vlocity_cmt__Product2Id__r.Name +':'+qlirRec.vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__Product2Id__r.Name;

                system.debug('sourceBundleMap @@'+sourceBundleMap);
                system.debug('targetBundleMap @@'+targetBundleMap);

                system.debug('rootSourceTargetVal @@'+rootSourceTargetVal);

                //Method to do the comparison between source QLI and target QLI
                compareResult(sourceBundleMap, targetBundleMap, rootSourceTargetVal);
                

            }

            //When the relationship is between two products in different quote
            else if((qlirRec.vlocity_cmt__RelatedQuoteLineItemId__c !=null)  && (qlirRec.vlocity_cmt__QuoteLineItemId__r.QuoteId != qlirRec.vlocity_cmt__RelatedQuoteLineItemId__r.QuoteId) ){
               
            
                sourceBundleMap = new Map<String,Map<String,QuoteLineItem>>();
                sourceBundleMap =getQLIRecords(qlirRec.vlocity_cmt__RelatedQuoteLineItemId__r.vlocity_cmt__Product2Id__r.Name,qlirRec.vlocity_cmt__RelatedQuoteLineItemId__r.vlocity_cmt__AssetReferenceId__c,qlirRec.vlocity_cmt__RelatedQuoteLineItemId__r.QuoteId);
    
                targetBundleMap=new Map<String,Map<String,QuoteLineItem>>();
                targetBundleMap= getQLIRecords(qlirRec.vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__Product2Id__r.Name,qlirRec.vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__AssetReferenceId__c, qlirRec.vlocity_cmt__QuoteLineItemId__r.QuoteId);
    
                rootSourceTargetVal = qlirRec.vlocity_cmt__RelatedQuoteLineItemId__r.vlocity_cmt__Product2Id__r.Name +':'+qlirRec.vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__Product2Id__r.Name;
    
                system.debug(' inside second scenario 2 sourceBundleMap @@'+sourceBundleMap);
                system.debug('inside second scenario 2 targetBundleMap @@'+targetBundleMap);
    
                system.debug('  scenario 2 rootSourceTargetVal @@'+rootSourceTargetVal);

                //Method to do the comparison between source QLI and target QLI
                compareResult(sourceBundleMap, targetBundleMap, rootSourceTargetVal);

            }

            //When the relationship is on an asset
            else if(qlirRec.vlocity_cmt__RelatedQuoteLineItemId__c == null){

                sourceAssetBundleMap = new Map<String,Map<String,Asset>>();

                sourceAssetBundleMap = getAssetRecords(qlirRec.vlocity_cmt__RelatedAssetReferenceId__c);

                targetBundleMap=new Map<String,Map<String,QuoteLineItem>>();
                targetBundleMap= getQLIRecords(qlirRec.vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__Product2Id__r.Name,qlirRec.vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__AssetReferenceId__c, qlirRec.vlocity_cmt__QuoteLineItemId__r.QuoteId);
        
                rootSourceTargetVal = qlirRec.vlocity_cmt__RelatedQuoteLineItemId__r.vlocity_cmt__Product2Id__r.Name +':'+qlirRec.vlocity_cmt__QuoteLineItemId__r.vlocity_cmt__Product2Id__r.Name;

                //Method to fetch asset records
                compareAssetResult(sourceAssetBundleMap,targetBundleMap, rootSourceTargetVal);
            }
            else{
                // not required 
            }
        }
    } 


    //Method to get QLI records
    public Map<String,Map<String,QuoteLineItem>>  getQLIRecords(String rootProduct , String rootAssetReferenceId, String relatedRootQuoteId){
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        Map<String,QuoteLineItem> qliMap = new Map<String,QuoteLineItem>();
        Map<String,Map<String,QuoteLineItem>> qliBundleMap = new Map<String,Map<String,QuoteLineItem>>(); 
        String qliQuery ='';
        if(qliFieldString !=null){
            qliQuery = 'Select Id,Product2.Name, Product2.ProductCode,vlocity_cmt__AttributeSelectedValues__c '+qliFieldString + ' from quotelineitem where QuoteId ';

        }else{
            qliQuery ='Select Id,Product2.Name, Product2.ProductCode,vlocity_cmt__AttributeSelectedValues__c ' + ' from quotelineitem where QuoteId ';

        }
       
    
        qliQuery += '=:relatedRootQuoteId  AND vlocity_cmt__RootItemId__c =:rootAssetReferenceId';


        System.debug('Dynamic query @@ '+qliQuery);

        qliList = Database.query(qliQuery);

        System.debug('Dynamic query @@ qliList'+qliList);



        if(!qliList.isEmpty()){

            for(quotelineitem qliRec : qliList){
                qliMap.put(qliRec.Product2.Name , qliRec);
            }

            qliBundleMap.put(rootProduct, qliMap);

            return qliBundleMap;
        }
        
        return null;
    }

    //Method to get asset records
    public Map<String,Map<String,Asset>> getAssetRecords( String relatedAssetReferenceId){

        List<Asset> assetList = new List<Asset>();

        Map<String,Asset> childAssetMap = new Map<String,Asset>();

        Map<String,Map<String,Asset>> bundleAssetMap = new Map<String,Map<String,Asset>>();

        String rootAssetName ='';

        assetList =[Select Id, Product2.NAme, vlocity_cmt__AssetReferenceId__c, vlocity_cmt__RootItemId__c, vlocity_cmt__AttributeSelectedValues__c from Asset where vlocity_cmt__RootItemId__c =: relatedAssetReferenceId];

        
        for(Asset assetRec : assetList){

            if(assetRec.vlocity_cmt__AssetReferenceId__c == assetRec.vlocity_cmt__RootItemId__c){

                rootAssetName = assetRec.Product2.Name;
            }else{

                childAssetMap.put(assetRec.Product2.Name , assetRec);
            }


        }

        bundleAssetMap.put(rootAssetName , childAssetMap);

        return bundleAssetMap;
        
    }

    //Method to do comparison between source and target
    public void compareResult(Map<String,Map<String,QuoteLineItem>> rSource,Map<String,Map<String,QuoteLineItem>> rTarget, String rootSourceTargetString){


        Map<String, Artl_ReliesOnValidations__mdt> HierarchyMdt =customMetadataMap.get(rootSourceTargetString);

        Integer indexVal; 

        String localRootSourceProduct='';
        String localRootTargetProduct='';

        // local source target map key concatenated
        String localTMapkey='';
        String sProductKey='';
        String tProductKey='';
        
        indexVal = rootSourceTargetString.indexOf(':');
        localRootSourceProduct = rootSourceTargetString.substring(0,indexVal);
        localRootTargetProduct=rootSourceTargetString.substring(indexVal+1,rootSourceTargetString.length());

        system.debug('localRootSourceProduct @@ '+localRootSourceProduct);
        system.debug('localRootTargetProduct @@ '+localRootTargetProduct);

        QuoteLineItem sourceQliTemp;
        QuoteLineItem targetQliTemp;
       

        String localSourceProduct='';
        String localTargetProduct='';

        Artl_ReliesOnValidations__mdt currentMdt;
        List<Map<String, String>> currentMdtAttJosn;


        Map<String,String> sAttMap ;
        Map<String,String> tAttMap ;


        system.debug('HierarchyMdt @@ '+HierarchyMdt);
        Set <String> sourceTargetSet = new Set<String>();
        sourceTargetSet = HierarchyMdt.keySet();

        system.debug('sourceTargetSet @@ '+sourceTargetSet);
        List<String> keyList ;

        // looping through custom metadata and comparing the Qli later

        for(String key : sourceTargetSet){


            indexVal = key.indexof(':');
            localSourceProduct =key.substring(0,indexVal);
            localTargetProduct = key.substring(indexVal+1,key.length());

            system.debug('localTargetProduct @@'+localTargetProduct);

            sourceQliTemp = new QuoteLineItem();
            sourceQliTemp = (rSource.get(localRootSourceProduct)).get(localSourceProduct);

            system.debug('sourceQliTemp @@'+sourceQliTemp);

            targetQliTemp = new QuoteLineItem();
            targetQliTemp = (rTarget.get(localRootTargetProduct)).get(localTargetProduct);

            
            system.debug('targetQliTemp @@'+targetQliTemp);

            sAttMap = new Map<String,String>();
            tAttMap = new Map<String,String>() ;

            sAttMap =fetchAttributesMap(sourceQliTemp.vlocity_cmt__AttributeSelectedValues__c);
            tAttMap=fetchAttributesMap(targetQliTemp.vlocity_cmt__AttributeSelectedValues__c);

            system.debug('sAttMap @@'+sAttMap);
            system.debug('tAttMap @@'+tAttMap);

            
            currentMdt = new Artl_ReliesOnValidations__mdt();
            currentMdt = HierarchyMdt.get(key);
            currentMdtAttJosn = new List<Map<String, String>>();
            currentMdtAttJosn=fetchcustomMdtAttributeMap(currentMdt.AttributeJson__c);

            system.debug('currentMdtAttJosn @@'+currentMdtAttJosn);


            for(Map<String, String> mdtAttjsonMap : currentMdtAttJosn){

                system.debug('mdtAttjsonMap @@'+mdtAttjsonMap);

                localTMapkey = mdtAttjsonMap.get('ATT');
                system.debug('localTMapkey @@'+localTMapkey);
                indexVal = localTMapkey.indexof(':');
                system.debug('indexVal @@'+indexVal);
                sProductKey =localTMapkey.substring(0,indexVal);
                system.debug('sProductKey @@'+sProductKey);
                tProductKey = localTMapkey.substring(indexVal+1,localTMapkey.length());

                
                
                system.debug('tProductKey @@'+tProductKey);

                if(sAttMap.get(sProductKey) != tAttMap.get(tProductKey)){
                    

                    errorMessage += sProductKey+' of source product and '+ tProductKey + ' Target product do not match';

                    system.debug('errorMessage @@'+errorMessage);
                }
            }

            // fetch fields list 
            if(currentMdt.FieldJson__c !=null){

                List<String> localFieldList = new List<String>();
                localFieldList = fetchQliFieldsList(currentMdt.FieldJson__c);
                system.debug('localFieldList Field @@'+localFieldList);

                // comparing the fields status between QLI 


                for(String FieldVal : localFieldList){
                    system.debug('FieldVal Field @@'+FieldVal);
                    system.debug('sourceQliTemp.get(FieldVal)  @@'+sourceQliTemp.get(FieldVal));
                    system.debug('targetQliTemp.get(FieldVal)  @@'+targetQliTemp.get(FieldVal));

                    if(sourceQliTemp.get(FieldVal) != targetQliTemp.get(FieldVal)){

                    

                        errorMessage +='There is a mismatch of field: '+FieldVal +' in source Product and the target ' + FieldVal;

                        system.debug('errorMessage Field @@'+errorMessage);
                    }
                }

            }
            
        }
    }

    //Method to do comparison for asset scenario
    public void compareAssetResult(Map<String,Map<String,Asset>> sAssetBundleMap,Map<String,Map<String,QuoteLineItem>> rTarget, String rootSourceTargetString){

        Map<String, Artl_ReliesOnValidations__mdt> HierarchyMdt =customMetadataMap.get(rootSourceTargetString);

        Integer indexVal;
        String localRootSAssetProduct='';
        String localRootTargetProduct=''; 


        // local source target map key concatenated
        String localTMapkey='';
        String sProductKey='';
        String tProductKey='';

        indexVal = rootSourceTargetString.indexOf(':');
        localRootSAssetProduct = rootSourceTargetString.substring(0,indexVal);
        localRootTargetProduct=rootSourceTargetString.substring(indexVal+1,rootSourceTargetString.length());

        system.debug('localRootSAssetProduct @@ '+localRootSAssetProduct);
        system.debug('localRootTargetProduct @@ '+localRootTargetProduct);

        Asset sourceAssetTemp;
        QuoteLineItem targetQliTemp;

        Map<String,String> sAttMap ;
        Map<String,String> tAttMap ;

        String localSAssetProduct='';
        String localTargetProduct='';

        Artl_ReliesOnValidations__mdt currentMdt;
        List<Map<String, String>> currentMdtAttJosn;

        system.debug('HierarchyMdt @@ '+HierarchyMdt);
        Set <String> sourceTargetSet = new Set<String>();
        if(HierarchyMdt != null){
            sourceTargetSet = HierarchyMdt.keySet();

        for(String key : sourceTargetSet){

            indexVal = key.indexof(':');
            localSAssetProduct =key.substring(0,indexVal);
            localTargetProduct = key.substring(indexVal+1,key.length());

            system.debug('localTargetProduct @@'+localTargetProduct);


            sourceAssetTemp = new Asset();
            sourceAssetTemp = (sAssetBundleMap.get(localRootSAssetProduct)).get(localSAssetProduct);
            system.debug('sourceAssetTemp @@'+sourceAssetTemp);

            targetQliTemp = new QuoteLineItem();
            targetQliTemp = (rTarget.get(localRootTargetProduct)).get(localTargetProduct);

            
            system.debug('targetQliTemp @@'+targetQliTemp);

            sAttMap = new Map<String,String>();
            tAttMap = new Map<String,String>() ;

            sAttMap =fetchAttributesMap(sourceAssetTemp.vlocity_cmt__AttributeSelectedValues__c);
            tAttMap=fetchAttributesMap(targetQliTemp.vlocity_cmt__AttributeSelectedValues__c);


            system.debug('sAttMap asset @@'+sAttMap);
            system.debug('tAttMap @@'+tAttMap);

            currentMdt = new Artl_ReliesOnValidations__mdt();
            currentMdt = HierarchyMdt.get(key);
            currentMdtAttJosn = new List<Map<String, String>>();
            currentMdtAttJosn=fetchcustomMdtAttributeMap(currentMdt.AttributeJson__c);

            system.debug('currentMdtAttJosn @@'+currentMdtAttJosn);

            for(Map<String, String> mdtAttjsonMap : currentMdtAttJosn){

                system.debug('mdtAttjsonMap @@'+mdtAttjsonMap);

                localTMapkey = mdtAttjsonMap.get('ATT');
                system.debug('localTMapkey @@'+localTMapkey);
                indexVal = localTMapkey.indexof(':');
                system.debug('indexVal @@'+indexVal);
                sProductKey =localTMapkey.substring(0,indexVal);
                system.debug('sProductKey @@'+sProductKey);
                tProductKey = localTMapkey.substring(indexVal+1,localTMapkey.length());

                
                
                system.debug('tProductKey @@'+tProductKey);

                if(sAttMap.get(sProductKey) != tAttMap.get(tProductKey)){
                    

                    errorMessage += sProductKey+' of source asset product and '+ tProductKey + 'Target product do not match';

                    system.debug('errorMessage asset @@'+errorMessage);
                }
            }


        }
        }
        
    }

    //
    public Map<String,String> fetchAttributesMap(String jsonVal){


        Map<String, String> attMap = new Map<String, String>() ;

        return attMap = (Map<String, String>) JSON.deserialize(jsonVal,Map<String, String>.class);
    }

    public List<String> fetchQliFieldsList(String fieldJson){

        return fieldJson.split(',');

    }

    public List<Map<String,String>> fetchcustomMdtAttributeMap(String jsonVal){


        List<Map<String, String>> attMap = new List<Map<String, String>>() ;

        return attMap = (List<Map<String, String>>) JSON.deserialize(jsonVal,List<Map<String, String>>.class);
    }



    


    public void finish(Database.BatchableContext BC){

        system.debug('error @@'+JSON.serializePretty(errorMessage));

        CustomNotificationType sendUserStatus = [SELECT Id, DeveloperName, CustomNotifTypeName FROM CustomNotificationType where CustomNotifTypeName ='ARTL ReliesOn Attribute  Field Validation' Limit 1];

        if(sendUserStatus !=null){                       
        
            Messaging.CustomNotification currNotification = new Messaging.CustomNotification();

            currNotification.setTitle('Validation of Attributes and Fields Status, ');
            if(!String.isBlank(errorMessage)){
                currNotification.setBody(customNotificationErrorMsg + system.today());
            }
            else{
                currNotification.setBody(customNotificationSuccessMsg + system.today());
            }
            
            currNotification.setNotificationTypeId(sendUserStatus.Id);
            currNotification.setTargetId(quoteId);

            try {

                Quote updateStatus;
                if(!String.isBlank(errorMessage)){
                     updateStatus = new Quote(Id =Id.valueOf(quoteId), ARTL_ReliesOnValidationError__c =errorMessage , ARTL_ValidateAttributeFieldStatus__c ='Failed');
                }
                else{
                     updateStatus = new Quote(Id =Id.valueOf(quoteId), ARTL_ReliesOnValidationError__c ='' , ARTL_ValidateAttributeFieldStatus__c ='Success');
                }

                update updateStatus;
                currNotification.send(new Set<String> { Userinfo.getUserId() });

                
            }
            catch (Exception ex){
                System.debug('Notification Failed: ' + ex.getMessage());
            }   
        }
    }
}