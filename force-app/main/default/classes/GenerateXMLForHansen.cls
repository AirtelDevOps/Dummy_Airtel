/***********************************************************************************************************************************
 * @Author       : Aliya Ameer
 * @Date         : 25/10/2023
 * @Test Class   : GenerateXMLForHansenTest
 * @Description  : Generate OSSJ for Hansen OM 
 ***********************************************************************************************************************************/
global without sharing class GenerateXMLForHansen implements IProcess {

    public static Map < String, String > data = new Map < String, String > {
        'Quote_Creation_Date' => '',
        'Oracle_Crm_Number' => '',
        'Source_CRM' => 'SFDC',
        'Customer_Ref' => '',
        'Current_User_Claims' => 'airtelinvsit2'
    };

    public String generateXML(Id orderItemId) {
        String xmlString;
        try {
            OrderItem orderItem = getOrderDetails(orderItemId);
            List < vlocity_cmt__FulfilmentRequestLine__c > fulfillmentRequestLines = getFRLSList(orderItem);
            Map < String, Object > mMap = createXMLSchema(orderItem, fulfillmentRequestLines);
            //System.debug('mMap:' +mMap);
            xmlString = addNamespacePrefixes(mMap);
            System.debug('xmlString ' + xmlString);
        } catch (Exception e) {
            System.debug('An error occurred at line number: ' + e.getLineNumber() + e.getMessage());
        }
        return xmlString;
    }

    // Method to retrieve order details
    private static OrderItem getOrderDetails(Id orderItemId) {
        OrderItem orderItemDets = null;
        try {
            orderItemDets = [select Id, OrderId, Order.OrderNumber, Order.Account.Name,
                Order.EffectiveDate, Order.Hansen_Order_Status__c, Order.Account.Description,
                Order.Account.AccountNumber,
                vlocity_cmt__BillingAccountId__r.Description,
                vlocity_cmt__BillingAccountId__r.AccountNumber,
                Order.vlocity_cmt__QuoteId__r.CreatedDate,
                Order.vlocity_cmt__QuoteId__r.ARTL_NBA_Account__r.AccountNumber
                from OrderItem WHERE Id =: orderItemId WITH SECURITY_ENFORCED LIMIT 1
            ];
        } catch (Exception e) {
            System.debug('An error occurred at line number: ' + e.getLineNumber() + e.getMessage());
        }
        return orderItemDets;
    }

    // Method to retrieve FRLs
    private static List < vlocity_cmt__FulfilmentRequestLine__c > getFRLSList(OrderItem orderItem) {
        List < vlocity_cmt__FulfilmentRequestLine__c > fulfillmentRequestLines = new List < vlocity_cmt__FulfilmentRequestLine__c > ();
        try {
            fulfillmentRequestLines = [select Id, Name, vlocity_cmt__Product2Id__r.Name,
                vlocity_cmt__Product2Id__r.ARTL_Hansen_Primary_Key__c, vlocity_cmt__Action__c,
                vlocity_cmt__LineNumber__c, vlocity_cmt__AttributeSelectedValues__c,
                ARTL_RateSpecKey__c, ARTL_ProductPrice__c, ARTL_EntityKey__c
                from vlocity_cmt__FulfilmentRequestLine__c
                where vlocity_cmt__FulfilmentRequestID__r.vlocity_cmt__OrderId__c =: orderItem.OrderId
                //and vlocity_cmt__Action__c = 'Add' 
                WITH SECURITY_ENFORCED
            ];
        } catch (Exception e) {
            System.debug('An error occurred at line number: ' + e.getLineNumber() + e.getMessage());
        }
        return fulfillmentRequestLines;
    }

    //Method to create XML Schema
    private static Map < String, Object > createXMLSchema(OrderItem orderItem, List < vlocity_cmt__FulfilmentRequestLine__c > fulfillmentRequestLines) {
        Map < String, Object > mMap = new Map < String, Object > ();
        populateOrderItem(mMap, fulfillmentRequestLines);
        //System.debug('mMap:' +mMap);
        populatecustomer(mMap, orderItem);
        populatecharacteristics(mMap, orderItem);
        populateHeader(mMap, orderItem);
        //System.debug('mMap:' +mMap);
        return mMap;
    }

    //Method to add namespaces to the XML file
    private static String addNamespacePrefixes(Map < String, Object > mMap) {
        String xmlString;
        xmlString = XML.serialize(mMap).addNamespace('http://som.sigma.com', 'som')
            .addNamespace('http://ossj.org/xml/Common-CBEBi/v1-5', 'bi')
            .addNamespace('http://ossj.org/xml/Common-CBECore/v1-5', 'cbe')
            .addNamespace('http://ossj.org/xml/Common-CBEDatatypes/v1-5', 'cbe-datatype')
            .addNamespace('http://ossj.org/xml/Common-CBELocation/v1-5', 'cbe-location')
            .addNamespace('http://ossj.org/xml/Common-CBEParty/v1-5', 'cbe-party')
            .addNamespace('http://ossj.org/xml/Common-CBEProduct/v1-5', 'cbe-product')
            .addNamespace('http://ossj.org/xml/Common-CBEProductOffering/v1-5', 'cbe-product-offering')
            .addNamespace('http://ossj.org/xml/Common-CBEResource/v1-5', 'cbe-resource')
            .addNamespace('http://ossj.org/xml/Common-CBEService/v1-5', 'cbe-service')
            .addNamespace('http://ossj.org/xml/Common/v1-5', 'cmn')
            .addNamespace('http://ossj.org/xml/OrderManagement/v1-0', 'om')
            .addNamespace('http://www.w3.org/2001/XMLSchema', 'xs')
            .addNamespace('http://www.w3.org/2001/XMLSchema-instance', 'xsi')
            .embedAttributes().beautify().toString();
        return xmlString;
    }

    // Method to populate the header part of the XML
    private static void populateHeader(Map < String, Object > mMap, OrderItem orderItem) {
        mMap.put(XMLConstants.ACTIVATIONDATE, Date.valueOf(orderItem.Order.EffectiveDate));
        mMap.put(XMLConstants.PRIORITY, XMLConstants.PRIORITY_VALUE);
        mMap.put(XMLConstants.STATUS, orderItem.Order.Hansen_Order_Status__c);
        mMap.put(XMLConstants.DISPLAYID, orderItem.Order.Account.Name);
        populateorderSpecKey(mMap);
        populateOrderKey(mMap, orderItem);
        mMap.put(XMLConstants.CLIENTID, XMLConstants.CLIENT_ID_VALUE);
        mMap.put(XMLConstants.LAST_UPDATE_VERSION_NUMBER, XMLConstants.LAST_UPDATE_VERSION_NUMBER_VALUE);
    }

    // Method to populate the orderKey part of the XML
    private static void populateOrderKey(Map < String, Object > mMap, OrderItem orderItem) {
        Map < String, Object > orderKeyMap = new Map < String, Object > ();
        Map < String, Object > primaryAttr = new Map < String, Object > ();
        Map < String, Object > attributeMap = new Map < String, Object > ();
        String uniqueKey = generateUniqueId();
        orderKeyMap.put(XMLConstants.EXTERNALKEY, uniqueKey);
        primaryAttr.put('value', '-1');
        attributeMap.put('attributes', primaryAttr);
        orderKeyMap.put(XMLConstants.PRIMARYKEY, attributeMap);
        orderKeyMap.put(XMLConstants.TYPE, 'Order');
        mMap.put(XMLConstants.ORDERKEY, orderKeyMap);
    }

    // Method to populate the orderSpecKey part of the XML
    private static void populateorderSpecKey(Map < String, Object > mMap) {
        Map < String, Object > orderSpecKeyMap = new Map < String, Object > ();
        Map < String, Object > primaryAttr = new Map < String, Object > ();
        Map < String, Object > attributeMap = new Map < String, Object > ();
        orderSpecKeyMap.put(XMLConstants.EXTERNALKEY, 'Order');
        primaryAttr.put('value', 'O0000000-0000-0000-0000-000000000000');
        attributeMap.put('attributes', primaryAttr);
        orderSpecKeyMap.put(XMLConstants.PRIMARYKEY, attributeMap);
        orderSpecKeyMap.put(XMLConstants.TYPE, 'Order');
        mMap.put(XMLConstants.ORDERSPECKEY, orderSpecKeyMap);
    }

    // Method to populate the characteristics part of the XML
    private static void populatecharacteristics(Map < String, Object > mMap, OrderItem orderItem) {
        Map < String, Object > characteristicsMap = new Map < String, Object > ();
        List < Map < String, Object >> itemMaps = new List < Map < String, Object >> ();

        for (String characteristicKeys: data.keySet()) {
            Map < String, Object > itemMap = new Map < String, Object > ();
            Map < String, Object > valueMap = new Map < String, Object > ();

            if (characteristicKeys == 'Quote_Creation_Date') {
                valueMap.put(XMLConstants.VALUEDETAIL, orderItem.Order.vlocity_cmt__QuoteId__r.ARTL_CreatedDate__c);
            } else if (characteristicKeys == 'Oracle_Crm_Number') {
                valueMap.put(XMLConstants.VALUEDETAIL, orderItem.Order.Account.AccountNumber);
                //valueMap.put(XMLConstants.VALUEDETAIL, orderItem.Order.Account.Description);
            } else if (characteristicKeys == 'Customer_Ref') {
                valueMap.put(XMLConstants.VALUEDETAIL, orderItem.Order.vlocity_cmt__QuoteId__r.ARTL_NBA_Account__r.AccountNumber);
                //valueMap.put(XMLConstants.VALUEDETAIL, orderItem.vlocity_cmt__BillingAccountId__r.Description);
            } else {
                valueMap.put(XMLConstants.VALUEDETAIL, data.get(characteristicKeys));
            }
            itemMap.put(XMLConstants.VALUE, valueMap);
            itemMaps.add(itemMap);
            itemMap.put(XMLConstants.CHARACTERISTIC, characteristicKeys);
        }
        characteristicsMap.put(XMLConstants.ITEM, itemMaps);
        mMap.put(XMLConstants.CHARACTERISTICS, characteristicsMap);
    }

    // Method to populate the customer part of the XML
    private static void populatecustomer(Map < String, Object > mMap, OrderItem orderItem) {
        Map < String, Object > customerMap = new Map < String, Object > ();
        Map < String, Object > customerKeyMap = new Map < String, Object > ();
        Map < String, Object > customerSpecKeyMap = new Map < String, Object > ();
        Map < String, Object > primaryAttr = new Map < String, Object > ();
        Map < String, Object > attributeMap = new Map < String, Object > ();
        Map < String, Object > primarySpecAttr = new Map < String, Object > ();
        Map < String, Object > attributeSpecMap = new Map < String, Object > ();
        primaryAttr.put('value', '-1');
        attributeMap.put('attributes', primaryAttr);
        customerKeyMap.put(XMLConstants.EXTERNALKEY, orderItem.Order.vlocity_cmt__QuoteId__r.ARTL_NBA_Account__r.AccountNumber);
        //customerKeyMap.put(XMLConstants.EXTERNALKEY, orderItem.vlocity_cmt__BillingAccountId__r.Description);
        customerKeyMap.put(XMLConstants.PRIMARYKEY, attributeMap);
        customerKeyMap.put(XMLConstants.TYPE, 'Customer');
        customerSpecKeyMap.put(XMLConstants.EXTERNALKEY, 'Customer');
        primarySpecAttr.put('value', 'OC000000-0000-0000-0000-000000000000');
        attributeSpecMap.put('attributes', primarySpecAttr);
        customerSpecKeyMap.put(XMLConstants.PRIMARYKEY, attributeSpecMap);
        customerSpecKeyMap.put(XMLConstants.TYPE, 'Customer');
        customerMap.put(XMLConstants.CHARACTERISTICS, '');
        customerMap.put(XMLConstants.CUSTOMERSPECKEY, customerSpecKeyMap);
        customerMap.put(XMLConstants.CUSTOMERKEY, customerKeyMap);
        mMap.put(XMLConstants.CUSTOMER, customerMap);
    }

    // Method to populate order item part of the XML
    private static void populateOrderItem(Map < String, Object > mMap, List < vlocity_cmt__FulfilmentRequestLine__c > fulfillmentRequestLines) {
        String rootLineNumber = getRootFRL(fulfillmentRequestLines);
        Map < String, Object > orderItemMap = buildSubOrderItem(fulfillmentRequestLines, rootLineNumber, true);
        //System.debug('orderItemMap:' +orderItemMap);
        mMap.put(XMLConstants.ORDERITEM, orderItemMap);
    }

    private static String getRootFRL(List < vlocity_cmt__FulfilmentRequestLine__c > fulfillmentRequestLines) {
        Map < String, vlocity_cmt__FulfilmentRequestLine__c > lineToFRLMap = new Map < String, vlocity_cmt__FulfilmentRequestLine__c > ();
        vlocity_cmt__FulfilmentRequestLine__c rootNode = null;
        String rootLineNumber;
        for (vlocity_cmt__FulfilmentRequestLine__c frl: fulfillmentRequestLines) {
            lineToFRLMap.put(frl.vlocity_cmt__LineNumber__c, frl);
            if (countLevels(frl.vlocity_cmt__LineNumber__c) == 2) {
                rootNode = frl;
                rootLineNumber = frl.vlocity_cmt__LineNumber__c;
            }
        }
        return rootLineNumber;
    }

    // Helper method to count the number of levels in a line number
    private static Integer countLevels(String lineNumber) {
        return lineNumber.split('\\.').size();
    }

    private static Map < String, Object > buildSubOrderItem(List < vlocity_cmt__FulfilmentRequestLine__c > fulfillmentRequestLines, String lineNumber, boolean isRoot) {
        Map < String, Object > subOrderItem = new Map < String, Object > ();
        vlocity_cmt__FulfilmentRequestLine__c frl = null;
        if (isRoot) {
            frl = getFRLByLineNumber(fulfillmentRequestLines, lineNumber);
        } else {
            frl = getFRLByLineNumber(fulfillmentRequestLines, lineNumber);
        }

        if (frl != null) {
            List < Map < String, Object >> childSubOrderItems = buildChildSubOrderItems(fulfillmentRequestLines, lineNumber);
            if (!childSubOrderItems.isEmpty()) {
                subOrderItem.put(XMLConstants.SUBORDERITEM, childSubOrderItems);
            }
            populateRootOrSubOrderItem(subOrderItem, frl, isRoot);
        }
        //System.debug('subOrderItem:' +subOrderItem);
        return subOrderItem;
    }

    private static vlocity_cmt__FulfilmentRequestLine__c getFRLByLineNumber(List < vlocity_cmt__FulfilmentRequestLine__c > fulfillmentRequestLines, String lineNumber) {
        for (vlocity_cmt__FulfilmentRequestLine__c frl: fulfillmentRequestLines) {
            if (frl.vlocity_cmt__LineNumber__c.equals(lineNumber)) {
                return frl;
            }
        }
        return null;
    }

    private static void populateRootOrSubOrderItem(Map < String, Object > subOrderItem, vlocity_cmt__FulfilmentRequestLine__c frl, boolean isRoot) {
        Map < String, Object > entityMap = new Map < String, Object > ();
        String frlName = frl.Name;
        String entitySpecKey = frl.vlocity_cmt__Product2Id__r.ARTL_Hansen_Primary_Key__c;
        String productName = frl.vlocity_cmt__Product2Id__r.Name;
        if (productName.contains('CFS')) {
            productName = productName.replace('CFS', '').trim();
        }
        Map < String, Object > entityKey = populateEntityKey(productName, frl);

        if (productName.contains('OTC') || productName.contains('ARC') || productName.contains('Charge')) {
            String primaryKey = null;
            Map < String, Object > primaryMap = (Map < String, Object > ) entityKey.get(XMLConstants.PRIMARYKEY);
            if (primaryMap != null && primaryMap.containsKey('attributes')) {
                Map < String, Object > attributesMap = (Map < String, Object > ) primaryMap.get('attributes');
                if (attributesMap != null && attributesMap.containsKey('value')) {
                    primaryKey = String.valueOf(attributesMap.get('value'));
                }
            }
            entityMap.put(XMLConstants.RATE, populateRate(frl, primaryKey, productName));
            entityMap.put(XMLConstants.CHARACTERISTICS, '');
        } else {
            entityMap.put(XMLConstants.CHARACTERISTICS, populateCharacteristicsForSubOrderItem(frl));
            //System.debug('entityMap:' +entityMap);
        }
        entityMap.put(XMLConstants.ENTITYSPECKEY, populateEntitySpecKey(productName, entitySpecKey));
        entityMap.put(XMLConstants.ENTITYKEY, entityKey);
        subOrderItem.put(XMLConstants.ENTITY, entityMap);
        subOrderItem.put(XMLConstants.CHARACTERISTICS, '');
        subOrderItem.put(XMLConstants.SOURCE, XMLConstants.SOURCE_VALUE);
        subOrderItem.put(XMLConstants.OPERATION, XMLConstants.OPERATION_VALUE);
        subOrderItem.put(XMLConstants.DISPLAYID, productName);
        subOrderItem.put(XMLConstants.ORDERITEMSPECKEY, populateOrderItemSpecKey());
        subOrderItem.put(XMLConstants.ORDERITEMKEY, populateOrderItemKey(frlName));
        subOrderItem.put(XMLConstants.ACTION, frl.vlocity_cmt__Action__c);
        subOrderItem.put(XMLConstants.LAST_UPDATE_VERSION_NUMBER, XMLConstants.LAST_UPDATE_VERSION_NUMBER_VALUE);
    }

    private static List < Map < String, Object >> buildChildSubOrderItems(List < vlocity_cmt__FulfilmentRequestLine__c > fulfillmentRequestLines, String lineNumber) {
        List < Map < String, Object >> childSubOrderItems = new List < Map < String, Object >> ();
        for (vlocity_cmt__FulfilmentRequestLine__c frl: fulfillmentRequestLines) {
            String parentLineNumber = getParentLineNumber(frl.vlocity_cmt__LineNumber__c);
            if (parentLineNumber.equals(lineNumber)) {
                Map < String, Object > childSubOrderItem = buildSubOrderItem(fulfillmentRequestLines, frl.vlocity_cmt__LineNumber__c, false);
                childSubOrderItems.add(childSubOrderItem);
            }
        }
        return childSubOrderItems;
    }

    // Populate orderItemKey
    private static Map < String, Object > populateOrderItemKey(String frlName) {
        Map < String, Object > orderItemKeyMap = new Map < String, Object > ();
        Map < String, Object > primaryAttr = new Map < String, Object > ();
        Map < String, Object > attributeMap = new Map < String, Object > ();
        orderItemKeyMap.put(XMLConstants.EXTERNALKEY, generateUniqueId());
        primaryAttr.put('value', '-1');
        attributeMap.put('attributes', primaryAttr);
        orderItemKeyMap.put(XMLConstants.PRIMARYKEY, attributeMap);
        orderItemKeyMap.put(XMLConstants.TYPE, 'OrderItem');
        return orderItemKeyMap;
    }

    // Populate orderItemSpecKey
    private static Map < String, Object > populateOrderItemSpecKey() {
        Map < String, Object > orderItemSpecKeyMap = new Map < String, Object > ();
        Map < String, Object > primaryAttr = new Map < String, Object > ();
        Map < String, Object > attributeMap = new Map < String, Object > ();
        primaryAttr.put('value', 'OI000000-0000-0000-0000-000000000000');
        attributeMap.put('attributes', primaryAttr);
        orderItemSpecKeyMap.put(XMLConstants.EXTERNALKEY, 'OrderItem');
        orderItemSpecKeyMap.put(XMLConstants.PRIMARYKEY, attributeMap);
        orderItemSpecKeyMap.put(XMLConstants.TYPE, 'OrderItem');
        return orderItemSpecKeyMap;
    }

    private static String generateUniqueId() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
        return guid;
    }

    private static Map < String, Object > populateEntityKey(String productName, vlocity_cmt__FulfilmentRequestLine__c frl) {
        Map < String, Object > entityKeyMap = new Map < String, Object > ();
        Map < String, Object > primaryAttr = new Map < String, Object > ();
        Map < String, Object > attributeMap = new Map < String, Object > ();
        Map < String, Object > existingAttributes = new Map < String, Object > ();
        String uniqueKey;
        if (productName.contains('OTC') || productName.contains('ARC')) {
            uniqueKey = 'CS_' + generateUniqueId();
        } else {
            uniqueKey = 'ID_' + generateUniqueId();
        }
        frl.ARTL_EntityKey__c = uniqueKey;
        // Deserialize the existing attributes
        if (String.isNotBlank(frl.vlocity_cmt__AttributeSelectedValues__c)) {
            existingAttributes = (Map < String, Object > ) JSON.deserializeUntyped(frl.vlocity_cmt__AttributeSelectedValues__c);
        }
        existingAttributes.put('ATT_PRIMARY_KEY', uniqueKey);
        String updatedAttributes = JSON.serialize(existingAttributes);
        frl.vlocity_cmt__AttributeSelectedValues__c = updatedAttributes;
        update frl;
        primaryAttr.put('value', uniqueKey);
        attributeMap.put('attributes', primaryAttr);
        entityKeyMap.put(XMLConstants.PRIMARYKEY, attributeMap);
        entityKeyMap.put(XMLConstants.TYPE, '');
        return entityKeyMap;
    }

    // Populate entitySpecKey
    private static Map < String, Object > populateEntitySpecKey(String productName, String entitySpecKey) {
        Map < String, Object > entitySpecKeyMap = new Map < String, Object > ();
        Map < String, Object > primaryAttr = new Map < String, Object > ();
        Map < String, Object > attributeMap = new Map < String, Object > ();
        entitySpecKeyMap.put(XMLConstants.EXTERNALKEY, productName);
        //System.debug('productName '+productName +'value '+entitySpecKey);
        primaryAttr.put('value', entitySpecKey);
        attributeMap.put('attributes', primaryAttr);
        entitySpecKeyMap.put(XMLConstants.PRIMARYKEY, attributeMap);
        entitySpecKeyMap.put(XMLConstants.TYPE, '');
        return entitySpecKeyMap;
    }

    private static String getParentLineNumber(String lineNumber) {
        if (lineNumber != null && lineNumber.contains('.')) {
            List < String > parts = lineNumber.split('\\.');
            parts.remove(parts.size() - 1);
            String parentLineNumber = '';
            for (String part: parts) {
                if (!String.isBlank(parentLineNumber)) {
                    parentLineNumber += '.';
                }
                parentLineNumber += part;
            }
            return parentLineNumber;
        }
        return null;
    }

    private static Map < String, Object > populateCharacteristicsForSubOrderItem(vlocity_cmt__FulfilmentRequestLine__c frl) {
        Map < String, Object > characteristicsMap = new Map < String, Object > ();
        List < Map < String, Object >> itemList = new List < Map < String, Object >> ();
        String jsonAttributes = frl.vlocity_cmt__AttributeSelectedValues__c;
        Map < String, String > attributeCodeToNameMap = populateAttributeCodeToNameMap(jsonAttributes);
        if (String.isNotBlank(jsonAttributes)) {
            Map < String, Object > jsonData = (Map < String, Object > ) JSON.deserializeUntyped(jsonAttributes);
            if (jsonData.containsKey('ATT_PRIMARY_KEY')) {
                jsonData.remove('ATT_PRIMARY_KEY'); // Exclude ATT_PRIMARY_KEY from the map
            }
            if (!jsonData.isEmpty()) {
                for (String attributeCode: jsonData.keySet()) {
                    Object attributeValueObj = jsonData.get(attributeCode);
                    //System.debug('attributeCode:' +attributeCode);
                    //System.debug('attributeValueObj:' +attributeValueObj);
                    if (attributeValueObj != null && String.valueOf(attributeValueObj).trim() != '') {
                        String attributeValue = attributeValueObj != null ? String.valueOf(attributeValueObj) : null;
                        //System.debug('attributeValue:' +attributeValue);
                        String attributeName = attributeCodeToNameMap.get(attributeCode);
                        //System.debug('attributeName:' +attributeName);
                        Map < String, Object > itemMap = new Map < String, Object > ();
                        Map < String, Object > valueMap = new Map < String, Object > ();
                        Map < String, Object > valueDetailMap = new Map < String, Object > ();
                        valueDetailMap.put(XMLConstants.VALUEDETAIL, attributeValue);
                        valueMap.put(XMLConstants.VALUE, valueDetailMap);
                        itemMap.putAll(valueMap);
                        itemList.add(itemMap);
                        itemMap.put(XMLConstants.CHARACTERISTIC, attributeName);
                    }
                }
                if (!itemList.isEmpty()) {
                    characteristicsMap.put(XMLConstants.ITEM, itemList);
                //System.debug('characteristicsMap:' +characteristicsMap);
                }
            }
        }
        return characteristicsMap;
    }

    private static Map < String, Object > populateRate(vlocity_cmt__FulfilmentRequestLine__c frl, String uniqueKey, String productName) {
        Map < String, Object > rateMap = new Map < String, Object > ();
        Map < String, Object > rateAttributesMap = new Map < String, Object > ();
        List < Map < String, Object >> rateAttributeList = new List < Map < String, Object >> ();
        Map < String, Object > primaryAttr = new Map < String, Object > ();
        Map < String, Object > attributeMap = new Map < String, Object > ();
        Map < String, Object > primarySpecAttr = new Map < String, Object > ();
        Map < String, Object > attributeSpecMap = new Map < String, Object > ();
        //System.debug('productName: '+productName);
        String jsonAttributes = frl.vlocity_cmt__AttributeSelectedValues__c;
        String rateSpecRowKey = frl.ARTL_RateSpecKey__c;
        String rateValue = String.valueOf(frl.ARTL_ProductPrice__c);
        Map < String, String > attributeCodeToNameMap = populateAttributeCodeToNameMap(jsonAttributes);
        if (String.isNotBlank(jsonAttributes)) {
            Map < String, Object > jsonData = (Map < String, Object > ) JSON.deserializeUntyped(jsonAttributes);
            if (jsonData.containsKey('ATT_PRIMARY_KEY')) {
                jsonData.remove('ATT_PRIMARY_KEY'); // Exclude ATT_PRIMARY_KEY from the map
            }
            for (String attributeCode: jsonData.keySet()) {
                String attributeName = attributeCodeToNameMap.get(attributeCode);
                //System.debug('attributeName: '+attributeName);
                String attributeValue = (String) jsonData.get(attributeCode);
                //System.debug('attributeValue: '+attributeValue);
                if (String.isNotBlank(attributeValue)) {
                    Map < String, Object > rateAttributeMap = new Map < String, Object > ();
                rateAttributeMap.put(XMLConstants.VALUE, attributeValue);
                rateAttributeMap.put(XMLConstants.NAME, attributeName);
                rateAttributeList.add(rateAttributeMap);
                }
            }
        }
        rateAttributesMap.put(XMLConstants.RATEATTRIBUTE, rateAttributeList);
        rateMap.put(XMLConstants.RATEATTRIBUTES, rateAttributesMap);
        Map < String, Object > rateKeyMap = new Map < String, Object > ();
        primaryAttr.put('value', uniqueKey);
        attributeMap.put('attributes', primaryAttr);
        rateKeyMap.put(XMLConstants.PRIMARYKEY, attributeMap);
        rateKeyMap.put(XMLConstants.TYPE, 'Rate');

        Map < String, Object > rateSpecKeyMap = new Map < String, Object > ();
        rateSpecKeyMap.put(XMLConstants.EXTERNALKEY, productName);
        primarySpecAttr.put('value', rateSpecRowKey);
        attributeSpecMap.put('attributes', primarySpecAttr);
        rateSpecKeyMap.put(XMLConstants.PRIMARYKEY, attributeSpecMap);
        rateSpecKeyMap.put(XMLConstants.TYPE, 'Rate');
        rateMap.put(XMLConstants.RATEVALUE, rateValue);
        rateMap.put(XMLConstants.RATESPECKEY, rateSpecKeyMap);
        rateMap.put(XMLConstants.RATEKEY, rateKeyMap);
        return rateMap;
    }

    // Method to query the attribute name based on the attribute code
    private static Map < String, String > populateAttributeCodeToNameMap(String jsonAttributes) {
        Map < String, String > attributeCodeToNameMap = new Map < String, String > ();
        if (String.isNotBlank(jsonAttributes)) {
            // Parse the JSON data from the field as a map
            Map < String, Object > jsonData = (Map < String, Object > ) JSON.deserializeUntyped(jsonAttributes);
            List < String > attributeCodes = new List < String > (jsonData.keySet());
            List < vlocity_cmt__Attribute__c > attributeRecords = [SELECT vlocity_cmt__Code__c, Name FROM vlocity_cmt__Attribute__c WHERE vlocity_cmt__Code__c IN: attributeCodes WITH SECURITY_ENFORCED];
            for (vlocity_cmt__Attribute__c attributeRecord: attributeRecords) {
                attributeCodeToNameMap.put(attributeRecord.vlocity_cmt__Code__c, attributeRecord.Name);
            }
        }
        return attributeCodeToNameMap;
    }
}