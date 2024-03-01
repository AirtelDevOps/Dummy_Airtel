public class TechnicalAttributeEnrichmentController {
    public static string getAssetRef ='';
    public static string rootItem = '';
    public static string orderId = '';
    public static string  quoteId='';

    public class AttributeCategory {
           @AuraEnabled public Id id;
           @AuraEnabled public String code;
           @AuraEnabled public String name;
           @AuraEnabled public Integer displaySequence;
            public AttributeCategory(Map<String, Object> categoryV2) {
               id = (Id)categoryV2.get('Id');
               code = (String)categoryV2.get('Code__c');
               name = (String)categoryV2.get('Name');
               displaySequence = (Integer)categoryV2.get('displaySequence');
           }
            public AttributeCategory(String code) {
               this.code = code;
           }
       }
        public class AttributeSpecification {
           @AuraEnabled public String code;
           @AuraEnabled public String label;
           @AuraEnabled public Integer displaySequence;
           @AuraEnabled public String valueType;
           @AuraEnabled public String fieldValue;
           @AuraEnabled public String theRecordId;
           @AuraEnabled public String productName;
           // @AuraEnabled public String inputType;
           @AuraEnabled public Boolean multiselect;
           @AuraEnabled public Boolean required;
           @AuraEnabled public Boolean readonly;
           @AuraEnabled public Boolean disabled;
           @AuraEnabled public Boolean filterable;
           @AuraEnabled public Boolean hasRules;
           @AuraEnabled public Boolean hidden;
           @AuraEnabled public Boolean cloneable;
           @AuraEnabled public Boolean isNotTranslatable;
           @AuraEnabled public String categoryCode;
           @AuraEnabled public String categoryName;
            @AuraEnabled public List<AttributeSpecValue> values;
           @AuraEnabled public Object defaultValue;
          
           public AttributeSpecification(Map<String, Object> attrMapV2, Map<String, Object> attrChangeV2, Object defVal, String catName, String catCode) {
               code = (String)attrMapV2.get('code');
               valueType = (String)attrMapV2.get('inputType');
               if (valueType == 'number') {
                   valueType = (String)attrMapV2.get('dataType');
                   if (valueType == 'percentage') valueType = 'percent';
               } else if (valueType == 'dropdown') {
                   valueType = 'picklist';
               }
                label = (String)attrMapV2.get('label');
               multiselect = (Boolean)attrMapV2.get('multiselect');
               required = (Boolean)attrMapV2.get('required');
               readonly = (Boolean)attrMapV2.get('readonly');
               disabled = (Boolean)attrMapV2.get('disabled');
               filterable = (Boolean)attrMapV2.get('filterable');
               hasRules = (Boolean)attrMapV2.get('hasRules');
               hidden = (Boolean)attrMapV2.get('hidden');
               cloneable = (Boolean)attrMapV2.get('cloneable');
               isNotTranslatable = (Boolean)attrMapV2.get('isNotTranslatable');
               displaySequence = Integer.valueOf(attrMapV2.get('displaySequence'));
               fieldValue = (String)attrMapV2.get('fieldValue');
               theRecordId = (String)attrMapV2.get('theRecordId');
               productName = (String)attrMapV2.get('ProductName');
                values = new List<AttributeSpecValue>();
               categoryName = catName;
               categoryCode = catCode;
               defaultValue = defVal;
               if(attrMapV2.containsKey('values')){
                   List<Object> valueObjs = (Object[])attrMapV2.get('values');
                   for (Object valueObj : valueObjs) {
                       Map<String, Object> valMap = (Map<String, Object>)valueObj;
                       if (valMap.containsKey('value')) {
                           AttributeSpecValue val = new AttributeSpecValue();
                           val.value = valMap.get('value');
                           val.label = (String)valMap.get('label');
                           val.displaySequence = Integer.valueOf(valMap.get('displaySequence'));
                           if (String.valueOf(val.value) == String.valueOf(defaultValue)) {
                               val.defaultSelected = true;
                           } else {
                               val.defaultSelected = false;
                           }
                           values.add(val);
                       }
                   }
               }
             
           }
       }
        public class AttributeSpecValue {
           @AuraEnabled public Object value;
           @AuraEnabled public String label;
           @AuraEnabled public Integer displaySequence;
           @AuraEnabled public Boolean defaultSelected;
       }
        public class AttributeMetadata {
           @AuraEnabled public Map<String, AttributeCategory> categories;
           @AuraEnabled public Map<String, AttributeSpecification> attributes;
         
           public AttributeMetadata() {
               categories = new Map<String, AttributeCategory>();
               attributes = new Map<String, AttributeSpecification>();
           }
       }
        public class JSONAttribute {
           @AuraEnabled public AttributeMetadata metadata { get; set; }
           @AuraEnabled public Map<String, Object> values { get; set; }
       }
      
       public static String getProduct2ReferenceName(SObjectType objectType) {
           if (objectType == vlocity_cmt__InventoryItem__c.SObjectType) return 'vlocity_cmt__ProductId__r';
           else if (objectType == vlocity_cmt__FulfilmentRequestLine__c.SObjectType) return 'vlocity_cmt__Product2Id__r';
           else if (objectType == XLI_Technical_Attribute__c.SObjectType) return 'Technical_Product__r';
           else return 'Product2';
       }
      
       @AuraEnabled(cacheable=true)
       public static JSONAttribute getJSONAttribute(Id recordId) {
        JSONAttribute jsonAttrib = new JSONAttribute();
        SObjectType objectType = recordId.getSobjectType();
        DescribeSObjectResult objectDesc = objectType.getDescribe();
        List<SObject> xLI = new List<SObject>();    
        
        if (objectType == OrderItem.SObjectType) {
            xLI = getOrderLineItem(recordId, objectType, objectDesc);
        } else if (objectType == QuoteLineItem.SObjectType) {
            xLI = getLineItem(recordId, objectType, objectDesc);
            system.debug('xLI OLI 130 ::' + xLI);
        }
    
        jsonAttrib.metadata = getAttributeMetadataOLI(xLI, recordId, objectType, objectDesc);
        jsonAttrib.values = getJSONAttributeValuesOLI(xLI, objectType, objectDesc);
        return jsonAttrib;
    }
    
   
       private static List<SObject> getLineItem(Id xLIId, SObjectType objectType, DescribeSObjectResult objectDesc) {
        String productRefName = getProduct2ReferenceName(objectType);
        System.debug('productRefName>>>' + productRefName);
        String query;
        List<SObject> xLI = new List<SObject>(); 
        QuoteLineItem qliRoot = [SELECT Id, quoteId, vlocity_cmt__RootItemId__c, vlocity_cmt__AssetReferenceId__c FROM QuoteLineItem WHERE Id = :xLIId];
        
        if (qliRoot != null) {
            String rootAssetRef = qliRoot.vlocity_cmt__AssetReferenceId__c;
            quoteId = qliRoot.quoteId;
            getAssetRef = rootAssetRef; // setting rootAssetRef val to static variable
            if (TechnicalAttributeHelper.isV2Attribute(objectType)) {
                query = String.format('SELECT Id, {0}.Name, {0}.vlocity_cmt__JSONAttribute__c, {0}.vlocity_cmt__AttributeMetadata__c, {0}.vlocity_cmt__AttributeDefaultValues__c, vlocity_cmt__JSONAttribute__c, vlocity_cmt__AttributeMetadataChanges__c, vlocity_cmt__AttributeSelectedValues__c FROM {1} WHERE vlocity_cmt__RootItemId__c =:rootAssetRef AND QuoteId =:quoteId', new List<String> {
                    productRefName,
                    objectDesc.getName()
                });
            } else {
                query = String.format('SELECT Id, {0}.Name, {0}.vlocity_cmt__JSONAttribute__c, vlocity_cmt__JSONAttribute__c FROM {1} WHERE Id=:xLIId AND QuoteId =:quoteId', new List<String> {
                    productRefName,
                    objectDesc.getName()
                });
            }
            
            System.debug('query>>>>>>>>: ' + query);
            xLI = Database.query(query);
            system.debug('xLI 163 :::' + xLI);

        }
        
        return xLI;
    }
    
  
       public static void getAttributeMetadataV2(String jsonAttributeMetadata, String jsonAttributeDefaultValues, String prodName, Id theRecordId, AttributeMetadata mdAttribute) {
         
           List<Object> categories = (Object[])((Map<String, Object>)JSON.deserializeUntyped(jsonAttributeMetadata)).get('records');
           //System.debug('categories>>>'+categories);
           Map<String, Object> attrDefVals = new Map<String, Object>();
           if (String.isNotBlank(jsonAttributeDefaultValues)) {
               attrDefVals = (Map<String, Object>)JSON.deserializeUntyped(jsonAttributeDefaultValues);
           }
           for (Object category : categories) {
               Map<String, Object> productAttributes = (Map<String, Object>)((Map<String, Object>)category).get('productAttributes');
               System.debug('Att Category----Name----'+((Map<String, Object>)category).get('Name'));
               System.debug('Att Category----Code__c----'+((Map<String, Object>)category).get('Code__c'));
               String catName = (String)((Map<String, Object>)category).get('Name');
               String catCode = (String)((Map<String, Object>)category).get('Code__c');
               List<Object> records = (Object[])productAttributes.get('records');
               for (Object record : records){
                   Map<String, Object> attrMapV2 = (Map<String, Object>)record;
                   attrMapV2.put('theRecordId', theRecordId);
                   attrMapV2.put('ProductName', prodName);
                   String attrCode = (String)attrMapV2.get('code');
                   Object attrDefVal = attrDefVals.get(attrCode);
                 
                   AttributeSpecification attrSpec = new AttributeSpecification(attrMapV2, new Map<String, Object>(), attrDefVal, catName, catCode );
                   mdAttribute.attributes.put(attrSpec.code +'___'+theRecordId, attrSpec);
               }
            }
         
         
       }
        public static void getfieldMetadata(String fieldCode, String value, String dataType, Id recId, AttributeMetadata mdAttribute) {
           Map<String, Object> customfieldMap = new Map<String, Object>();
           customfieldMap.put('values', new List<Object>());
           customfieldMap.put('required', false);
           customfieldMap.put('readonly', false);
           customfieldMap.put('multiselect', false);
           customfieldMap.put('label', 'Dummy Label1');
           customfieldMap.put('isNotTranslatable', false);
           customfieldMap.put('hidden', false);
           customfieldMap.put('hasRules', false);
           customfieldMap.put('filterable', false);
           customfieldMap.put('displaySequence', 3);
           customfieldMap.put('disabled', false);
           customfieldMap.put('defaultValue', 'null');
           customfieldMap.put('categoryCode', 'ATC_ENTERPRISE_DETAILS');
           customfieldMap.put('inputType', 'field');
           customfieldMap.put('code', fieldCode);
           customfieldMap.put('label', fieldCode);
           customfieldMap.put('fieldValue', value);
           customfieldMap.put('value', value);
           customfieldMap.put('theRecordId', recId);
          
         
     
           AttributeSpecification attrSpec = new AttributeSpecification(customfieldMap, new Map<String, Object>(), null, null , 'ATC_ENTERPRISE_DETAILS');
           mdAttribute.attributes.put(fieldCode, attrSpec);
       }
       @AuraEnabled

    public static void setAttributeValues(String selectedAttributeJSON, String objName) {
       List<Object> inputJsonList = (List<Object>) JSON.deserializeUntyped(selectedAttributeJSON);
       List<SObject> qliList = new List<sobject>();
       Map<String, Object> inputMap = new Map<String, Object>();
        for (Object inpObj : inputJsonList) {
           inputMap = (Map<String, Object>) inpObj;
           String qliId = (String) inputMap.get('Id');
           String attributes = JSON.serialize (inputMap.get('vlocity_cmt__AttributeSelectedValues__c'));
          
           if(objName=='QuoteLineItem'){
               QuoteLineItem qli = new QuoteLineItem();
               qli.Id = qliId;
               //Can be moved to outside if else statement
               if(attributes != ''){
                   qli.vlocity_cmt__AttributeSelectedValues__c = attributes;
               }
               if(inputMap.get('fieldVal')!=null){
                   //String cndDateVal = (String)((Map<String, Object>)inputMap.get('fieldVal')).get('Customer Needed By Date');
                   if(((Map<String, Object>)inputMap.get('fieldVal')).containsKey('RFS')){
                       String rfsDateVal = (String)((Map<String, Object>)inputMap.get('fieldVal')).get('RFS');
                       qli.RFS__c = Date.valueOf(rfsDateVal);
                   }
                   if(((Map<String, Object>)inputMap.get('fieldVal')).containsKey('Customer Needed By Date')){
                       String cndDateVal = (String)((Map<String, Object>)inputMap.get('fieldVal')).get('Customer Needed By Date');
                       qli.CND__c = Date.valueOf(cndDateVal);
                   }
                   if(((Map<String, Object>)inputMap.get('fieldVal')).containsKey('Operating Unit')){
                    qli.ARTL_OperatingUnit__c = (String)((Map<String, Object>)inputMap.get('fieldVal')).get('Operating Unit');
                    //qli.ARTL_OperatingUnit__c = Date.valueOf(rfsDateVal);
                }
                if(((Map<String, Object>)inputMap.get('fieldVal')).containsKey('Requisition Number')){
                    qli.RequisitionNumber__c  = (String)((Map<String, Object>)inputMap.get('fieldVal')).get('Requisition Number');
                    //qli.RequisitionNumber__c = Date.valueOf(cndDateVal);
                }
               }
              
              
    
               qliList.add(qli);
           }
           //Can be moved to outside if else statement
           else if(objName=='OrderItem'){
               OrderItem qli = new OrderItem();
               qli.Id = qliId;
               if(attributes != ''){
                   qli.vlocity_cmt__AttributeSelectedValues__c = attributes;
               }
               if(inputMap.get('fieldVal')!=null){
                   //String cndDateVal = (String)((Map<String, Object>)inputMap.get('fieldVal')).get('Customer Needed By Date');
                   if(((Map<String, Object>)inputMap.get('fieldVal')).containsKey('RFS')){
                       String rfsDateVal = (String)((Map<String, Object>)inputMap.get('fieldVal')).get('RFS');
                       qli.RFS__c = Date.valueOf(rfsDateVal);
                   }
                   if(((Map<String, Object>)inputMap.get('fieldVal')).containsKey('Customer Needed By Date')){
                       String cndDateVal = (String)((Map<String, Object>)inputMap.get('fieldVal')).get('Customer Needed By Date');
                       qli.CND__c = Date.valueOf(cndDateVal);
                   }
                   if(((Map<String, Object>)inputMap.get('fieldVal')).containsKey('Operating Unit')){
                    qli.ARTL_OperatingUnit__c = (String)((Map<String, Object>)inputMap.get('fieldVal')).get('Operating Unit');
                    //qli.ARTL_OperatingUnit__c = Date.valueOf(rfsDateVal);
                }
                // if(((Map<String, Object>)inputMap.get('fieldVal')).containsKey('Requisition Number')){
                //     qli.RequisitionNumber__c  = (String)((Map<String, Object>)inputMap.get('fieldVal')).get('Requisition Number');
                //     //qli.RequisitionNumber__c = Date.valueOf(cndDateVal);
                // }
                  
                  
               }
    
               qliList.add(qli);
           }
          
       }
       update qliList;
   }

   private static List<SObject> getOrderLineItem(Id xLIId, SObjectType objectType, DescribeSObjectResult objectDesc) {
    String productRefName = getProduct2ReferenceName(objectType);
    System.debug('productRefName>>>' + productRefName);
    String query;
    List<SObject> xLI = new List<SObject>();
    SObject qliRoot;
    
    qliRoot = [SELECT Id, orderId, vlocity_cmt__RootItemId__c, vlocity_cmt__AssetReferenceId__c FROM OrderItem WHERE Id = :xLIId];
    
    if (qliRoot != null) {
        String rootAssetRef = (String)qliRoot.get('vlocity_cmt__AssetReferenceId__c');
        getAssetRef = rootAssetRef; // setting rootAssetRef val to a static variable 
        orderId = (String)qliRoot.get('orderId');
        System.debug('getAssetRef--->'+rootAssetRef);
        if (TechnicalAttributeHelper.isV2Attribute(objectType)) {
            query = String.format('SELECT Id, {0}.Name, {0}.vlocity_cmt__JSONAttribute__c, {0}.vlocity_cmt__AttributeMetadata__c, {0}.vlocity_cmt__AttributeDefaultValues__c, vlocity_cmt__JSONAttribute__c, vlocity_cmt__AttributeMetadataChanges__c, vlocity_cmt__AttributeSelectedValues__c FROM {1} WHERE vlocity_cmt__RootItemId__c =:rootAssetRef AND OrderId = :orderId', new List<String> {
                productRefName,
                objectDesc.getName()
            });
        } else {
            query = String.format('SELECT Id, {0}.Name, {0}.vlocity_cmt__JSONAttribute__c, vlocity_cmt__JSONAttribute__c FROM {1} WHERE Id=:xLIId AND OrderId = :orderId', new List<String> {
                productRefName,
                objectDesc.getName()
            });
        }
        
        System.debug('query>>>>>>>>: ' + query);
        xLI = Database.query(query);
        system.debug('xLI 321 :::' + xLI);
    }
    
    return xLI;
}

    public static AttributeMetadata getAttributeMetadataOLI(List<SObject> xLI,Id recordId, SObjectType objectType, DescribeSObjectResult objectDesc) {
        AttributeMetadata mdAttribute = new AttributeMetadata();
        //Custom Field Logic
        Map<String, Object> outputMap = new Map<String, Object>();
            outputMap =  getQLIData(objectType);    
            system.debug('outputMap ::::::' + outputMap);
            if(!outputMap.isEmpty()){
                for(String s : outputMap.keySet()){
                    getfieldMetadata(s, String.ValueOf(outputMap.get(s)), 'text', (Id)outputMap.get('Id'), mdAttribute);
                }
            }
        system.debug('xLI 340:::' + xLI);
        
        for(SObject so : xLI){
           //QuoteLineItem qli = (QuoteLineItem)so;
               //getAttributeMetadataV2((String)qli.Product2.vlocity_cmt__AttributeMetadata__c, (String)qli.Product2.vlocity_cmt__AttributeDefaultValues__c, qli.Id, mdAttribute);
               SObject prodDetails = so.getSObject('Product2');
               String attMetadata = (String)prodDetails.get('vlocity_cmt__AttributeMetadata__c');
               String attDefVals = (String)prodDetails.get('vlocity_cmt__AttributeDefaultValues__c');
               String prodName = (String)prodDetails.get('Name');
               if(attMetadata != null && attDefVals != null)
               getAttributeMetadataV2(attMetadata, attDefVals, prodName, (String)so.get('Id'), mdAttribute);
        }
        return mdAttribute;
     
   }
   public static Map<String, Object> getJSONAttributeValuesOLI(List<SObject> xLI, SObjectType objectType, DescribeSObjectResult objectDesc) {
    String jsonAttribute;
    Map<String, Object> jsonMap = new Map<String, Object>();
    for(SObject qli : (List<SObject>)xLI){
        if(qli.get('vlocity_cmt__AttributeSelectedValues__c') != null)
            jsonMap.putAll((Map<String,Object>)JSON.deserializeUntyped((String)qli.get('vlocity_cmt__AttributeSelectedValues__c')));
    }
    //custom field map
    jsonMap.put('KAM_Name', 'Shashi Kumar');
    jsonAttribute = JSON.serialize(jsonMap);
    return TechnicalAttributeHelper.getJSONAttributeValues(jsonAttribute);
}
    
    public static map<string,object> getQLIData(SObjectType objectType){
        map<string,object> qliDataMap = new Map<string,object>();
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        List<OrderItem> oliList = new List<OrderItem>();
        List<SObject> liList = new List<SObject>();
        List<ARTL_Feasibility__c> fId = new List<ARTL_Feasibility__c>();
        List<ARTL_Feasibility_Attribute__c> fAttr = new List<ARTL_Feasibility_Attribute__c>();
        
        try{
            if(objectType == QuoteLineItem.SObjectType){
                
                qliList = [SELECT id,quote.account.billingcity,quote.owner.name,createddate,quote.account.name, ARTL_OperatingUnit__c, RequisitionNumber__c,
                           quote.account.billingstate,artl_lsi__c,quote.opportunity.Opportunity_Type__c,artl_purchase_order__r.artl_po_number__c,
                           artl_feasibility__r.ARTL_Feasibility_ID__c,product2.name,quote.account.artl_customer_segment__c,quote.artl_demo_duration__c,
                           quote.opportunity.owner.email,quote.owner.email,quote.account.artl_vertical_segment__c,quote.opportunity.pm__r.firstname,
                           quote.opportunity.pm__r.lastname,quote.opportunity.pm__r.email,quote.account.artl_business_circle_region__c,
                           ARTL_Purchase_Order__r.start_date__c,CND__c,RFS__c,quote.opportunity.pm__r.Phone,
                           quote.CreatedDate,ARTL_FeasibiltyRemarks__c,quote.account.ARTL_Legal_Entity__c,quote.opportunity.pm__r.Contact.FirstName,
                           quote.opportunity.pm__r.contact.LastName,quote.opportunity.pm__r.contact.Phone,
                           quote.opportunity.pm__r.Name
                           FROM QuoteLineItem 
                           WHERE QuoteID =: quoteId  AND vlocity_cmt__RootItemId__c =: getAssetRef  AND Product2.ARTL_LSIRequired__c =true ]; 
               // system.debug('qliList 388 ::' + qliList);
                if(!qliList.isEmpty()){
                    fId = [SELECT ARTL_Feasibility_ID__c,ARTL_QLI__c FROM ARTL_Feasibility__c WHERE ARTL_QLI__c =: qliList[0].id ];
                    //    system.debug('fId :::>>>' + fId);
                    if(fId.size() > 0){
                        fAttr = [SELECT ARTL_Feasibility__r.ARTL_Feasibility_ID__c , ARTL_QLI__c , Name,Value__c FROM ARTL_Feasibility_Attribute__c WHERE ARTL_Feasibility__r.ARTL_Feasibility_ID__c =: fId[0].ARTL_Feasibility_ID__c  AND Name = 'longitude']; 
                    }
                }
                
                if(!qliList.isEmpty()){
                    fId = [SELECT ARTL_Feasibility_ID__c,ARTL_QLI__c FROM ARTL_Feasibility__c WHERE ARTL_QLI__c =: qliList[0].id ];
                    system.debug('fId :::>>>' + fId);
                    if(fId.size() > 0){
                        fAttr = [SELECT ARTL_Feasibility__r.ARTL_Feasibility_ID__c , ARTL_QLI__c , Name,Value__c FROM ARTL_Feasibility_Attribute__c WHERE ARTL_Feasibility__r.ARTL_Feasibility_ID__c =: fId[0].ARTL_Feasibility_ID__c  AND Name = 'longitude']; 
                    }
                } 
            }
            else if(objectType == OrderItem.SObjectType){
                oliList = [SELECT id,order.account.billingcity,order.owner.name,createddate,order.account.name, ARTL_OperatingUnit__c, 
                           order.account.billingstate,artl_lsi__c,order.opportunity.Opportunity_Type__c, Order.Type,order.PoNumber,
                           product2.name,order.account.artl_customer_segment__c,order.artl_demo_duration__c,
                           order.opportunity.owner.email,order.owner.email,order.account.artl_vertical_segment__c,order.opportunity.pm__r.firstname,
                           order.opportunity.pm__r.lastname,order.opportunity.pm__r.email,order.account.artl_business_circle_region__c,
                           order.PoDate,CND__c,RFS__c,order.opportunity.pm__r.Phone,
                           order.CreatedDate,ARTL_FeasibiltyRemarks__c,order.account.ARTL_Legal_Entity__c,order.opportunity.pm__r.contact.FirstName,
                           order.opportunity.pm__r.Contact.LastName,order.opportunity.pm__r.Contact.Phone,order.opportunity.pm__r.Contact.Email,
                           QuoteLineItem.ARTL_Feasibility__r.ARTL_Feasibility_ID__c,QuoteLineItemId, order.opportunity.pm__r.Name
                           FROM OrderItem 
                           WHERE OrderID =: orderId  AND vlocity_cmt__RootItemId__c =: getAssetRef  AND Product2.ARTL_LSIRequired__c =true];
                system.debug('oliList 417 ::' + oliList);
                
                if( !oliList.isEmpty() && oliList[0].QuoteLineItemId != Null){
                    fId = [SELECT ARTL_Feasibility_ID__c,ARTL_QLI__c FROM ARTL_Feasibility__c  WHERE ARTL_QLI__c =: oliList[0].QuoteLineItemId ];
                    if(!fId.isEmpty()){
                        fAttr = [SELECT ARTL_Feasibility__r.ARTL_Feasibility_ID__c , Name,Value__c FROM ARTL_Feasibility_Attribute__c WHERE ARTL_Feasibility__r.ARTL_Feasibility_ID__c =: fId[0].ARTL_Feasibility_ID__c AND Name = 'longitude'];
                    }
                }          
            }     
            // For QLI 
            if(!qliList.isEmpty()){                                  
                for(QuoteLineItem q : qliList){
                    qliDataMap.put('Customer Name' , q.quote.account.name);
                    qliDataMap.put('City' , q.quote.account.billingcity);
                    qliDataMap.put('State' , q.quote.account.billingstate);
                    qliDataMap.put('LSI' , q.artl_lsi__c);
                    qliDataMap.put('Id' , q.Id);
                    qliDataMap.put('Order Type' , q.quote.opportunity.Opportunity_Type__c);
                    qliDataMap.put('PO Number' , q.artl_purchase_order__r.artl_po_number__c);
                    qliDataMap.put('Feasibility Id' , (!fId.isEmpty() && fId.Size() > 0 ) ? fId[0].ARTL_Feasibility_ID__c  : '');
                    qliDataMap.put('KAM Name' , q.quote.opportunity.pm__r.firstname);
                    qliDataMap.put('Product' , q.product2.name);
                    qliDataMap.put('RFS' , q.RFS__c);
                    qliDataMap.put('Customer Needed By Date' , q.CND__c);
                    qliDataMap.put('PO Date' , q.ARTL_Purchase_Order__r.Start_Date__c);
                    qliDataMap.put('Business Circle' , q.quote.account.artl_business_circle_region__c);
                    qliDataMap.put('KAM Contact' , q.quote.opportunity.pm__r.Phone);
                    qliDataMap.put('Operating Unit' , q.ARTL_OperatingUnit__c);
                    qliDataMap.put('Requisition Number' , q.RequisitionNumber__c);
                    qliDataMap.put('Longitude' , (!fAttr.isEmpty() && fAttr.Size() > 0 ) ? fAttr[0].Value__c : '');                                                                           // ??
                    qliDataMap.put('Vertical Segment' , q.quote.Account.ARTL_Vertical_Segment__c);
                    qliDataMap.put('Customer Segment' , 'EGB'); // q.quote.Account.artl_customer_segment__c for now
                    qliDataMap.put('Hardware Legal Entity' , q.quote.account.ARTL_Legal_Entity__c);                             // ?? xl : ARTL_Billing_Staging__c.Legal_Entity__c
                    qliDataMap.put('TP Feasibility Remarks' , q.ARTL_FeasibiltyRemarks__c);
                    qliDataMap.put('Customer PM Name' , q.quote.opportunity.pm__r.Name);
                    //qliDataMap.put('Customer PM Last Name' ,  q.quote.opportunity.pm__r.Contact.LastName);
                    qliDataMap.put('Customer PM Number' ,  q.quote.opportunity.pm__r.Phone);
                    qliDataMap.put('Customer PM Email' ,  q.quote.opportunity.pm__r.Email);
                }
            }
            // For Order Item  
            if(!oliList.isEmpty()){        
                for(OrderItem ol : oliList){
                    qliDataMap.put('Customer Name' , ol.order.account.name);
                    qliDataMap.put('City' , ol.order.account.billingcity);
                    qliDataMap.put('State' , ol.order.account.billingstate);
                    qliDataMap.put('LSI' , ol.artl_lsi__c);
                    qliDataMap.put('Id' , ol.Id);
                    qliDataMap.put('Order Type' , ol.Order.Type);
                    qliDataMap.put('PO Number' , ol.order.PoNumber);
                    qliDataMap.put('Feasibility Id' , (!fId.isEmpty() && fId.Size() > 0 ) ? fId[0].ARTL_Feasibility_ID__c  : '');																	//its in product
                    qliDataMap.put('KAM Name' , ol.order.opportunity.pm__r.firstname);
                    qliDataMap.put('Product' , ol.product2.name);
                    qliDataMap.put('RFS' , ol.RFS__c);
                    qliDataMap.put('Customer Needed By Date' , ol.CND__c);
                    qliDataMap.put('PO Date' , ol.order.PoDate);
                    qliDataMap.put('Business Circle' , ol.order.account.artl_business_circle_region__c);
                    qliDataMap.put('KAM Contact' , ol.order.opportunity.pm__r.Phone);
                    qliDataMap.put('Operating Unit' , ol.ARTL_OperatingUnit__c);
                    qliDataMap.put('Longitude' ,  (!fAttr.isEmpty() && fAttr.Size() > 0 ) ? fAttr[0].Value__c : '');                                                                           // ??
                    qliDataMap.put('Vertical Segment' , ol.order.Account.ARTL_Vertical_Segment__c);
                    qliDataMap.put('Customer Segment' , 'EGB'); // ol.order.Account.ARTL_Customer_Segment__c for now
                    qliDataMap.put('Hardware Legal Entity' , ol.order.account.ARTL_Legal_Entity__c);
                    qliDataMap.put('TP Feasibility Remarks' , ol.ARTL_FeasibiltyRemarks__c);
                    qliDataMap.put('Customer PM Name' , ol.order.opportunity.pm__r.Name);
                    //qliDataMap.put('Customer PM Last Name' ,  q.quote.opportunity.pm__r.Contact.LastName);
                    qliDataMap.put('Customer PM Number' ,  ol.order.opportunity.pm__r.Phone);
                    qliDataMap.put('Customer PM Email' ,  ol.order.opportunity.pm__r.Email);
                    
                }
            }    
            if(!qliDataMap.isEmpty()){
                return qliDataMap;
            }else{
                return null;
            }
        }
        
        catch(exception e){
            system.debug('Exception in TechnicalAttributeEnrichmentController.getQLIData: at Line ('+e.getLineNumber()+') Error Message: ' + e.getMessage());
            return null;
        }
    }     
    
    // @AuraEnabled
    // public static List<ARTL_RFS_Mapping__mdt> getRFSMappingData() {
    //     return [SELECT Customer_Segment__c, Order_Type__c, Days__c, Service_Type__c, Media__c FROM ARTL_RFS_Mapping__mdt];
    // }
    // @AuraEnabled
    // public static List<Artl_AttributeValidation__mdt> getAttributeValidations() {
    //     return [SELECT Attribute_JSON__c, AttributeCode__c, Object__c FROM Artl_AttributeValidation__mdt];
    // }
    @AuraEnabled
    public static List<SObject> getMetadataRecords(String metadataName, List<String> fields) {
        String dynamicQuery = 'SELECT ' + String.join(fields, ',') + ' FROM ' + metadataName;
        
        try {
            return Database.query(dynamicQuery);
        } catch (Exception e) {
            throw new AuraHandledException('Error querying metadata: ' + e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static Task getTaskDetails(String recordId) {
        
        try {
            return [Select Id,Order_Product__c,Subject FROM Task WHERE Id=:recordId limit 1];
        } catch (Exception e) {
            throw new AuraHandledException('Error querying metadata: ' + e.getMessage());
        }
    }
}