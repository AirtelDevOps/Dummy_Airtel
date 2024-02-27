/***********************************************************************************************************************************
 * @Author       : Aliya Ameer
 * @Date         : 15/11/2023
 * @Test Class   : 
 * @Description  : Enrich FRL Attributes of DSL and Voice from feasibility records 
 ***********************************************************************************************************************************/
global class Artel_EnrichAtrributeFromFeasibility implements vlocity_cmt.XOMOrchestrationInterfaces.IAutoTask {
    global void executeBatch(List < vlocity_cmt__OrchestrationItem__c > items) {
        Set < String > parentLineNumbers = new Set < String > ();
        for (vlocity_cmt__OrchestrationItem__c item: items) {
            //System.debug(LoggingLevel.INFO, 'Orchestration task Id = ' + item.Id);
            enrichAttrFRL(items, parentLineNumbers);
        }
    }

    global void enrichAttrFRL(List < vlocity_cmt__OrchestrationItem__c > orchItemsList, Set < String > parentLineNumbers) {
        //System.debug('orchItemsList = ' + orchItemsList);
        List < vlocity_cmt__OrchestrationItem__c > orchItemsListQuery = new List < vlocity_cmt__OrchestrationItem__c >();
        List < Id > orderList = new List < Id > ();
        Set < Id > orchestrationPlanIds = new Set < Id > ();
        String FrId, rsuName, maxspeedrsu, maxspeed, maxspeedtechnology, city, technology;
        Map < Id, Id > orchestrationPlanIdToOrderId = new Map < Id, Id > ();
        Set < Id > quoteLineItemIdSet = new Set < Id > ();
        Set < Id > feasibilityIdSet = new Set < Id > ();
        Map < String, Decimal > cityToSTDCodeMap = new Map < String, Decimal > ();
        Map < String, Decimal > cityToMsuCodeMap = new Map < String, Decimal > ();
        Object attributeValue = null;
        
        orchItemsListQuery = [SELECT Id, 
                        vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c, 
                        vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c 
                 FROM vlocity_cmt__OrchestrationItem__c 
                 WHERE Id IN :orchItemsList];

        for (vlocity_cmt__OrchestrationItem__c orchItem: orchItemsListQuery) {
            orderList.add(orchItem.vlocity_cmt__OrchestrationPlanId__r.vlocity_cmt__OrderId__c);
            FrId = orchItem.vlocity_cmt__FulfilmentRequestLineId__r.vlocity_cmt__FulfilmentRequestID__c;
        }
        System.debug('orderList###' + orderList);
        System.debug('FrId###' + FrId);

        List < OrderItem > orderItemList = [
            SELECT Id, QuoteLineItemId, vlocity_cmt__ParentItemId__c, 
            vlocity_cmt__AttributeSelectedValues__c, QuoteLineItem.ARTL_Feasibility__c 
            FROM OrderItem WHERE OrderId IN: orderList AND vlocity_cmt__ParentItemId__c = ''
        ];

        for (OrderItem ordItem: orderItemList) {
            quoteLineItemIdSet.add(ordItem.QuoteLineItemId);
            feasibilityIdSet.add(ordItem.QuoteLineItem.ARTL_Feasibility__c);
            Map<String, Object> attributeValuesMap = (Map<String, Object>) JSON.deserializeUntyped(ordItem.vlocity_cmt__AttributeSelectedValues__c);
            attributeValue = attributeValuesMap.get('ATT_PLAN_SPEED');
        }
        System.debug('AA quoteLineItemIdSet=>'+quoteLineItemIdSet);
        System.debug('AA feasibilityIdSet=>'+feasibilityIdSet);

        List < ARTL_Feasibility_Attribute__c > feasibilityAttributeList = [
            SELECT Id, Name, Value__c, ARTL_Feasibility__c, ARTL_QLI__c
            FROM ARTL_Feasibility_Attribute__c
            WHERE ARTL_Feasibility__c IN: feasibilityIdSet
            AND ARTL_QLI__c IN: quoteLineItemIdSet
        ];

        for (ARTL_Feasibility_Attribute__c attribute: feasibilityAttributeList) {
            if (attribute.Name == 'rsuName') {
                rsuName = attribute.Value__c;
            } else if (attribute.Name == 'maxspeed') {
                maxspeed = attribute.Value__c;
            } else if (attribute.Name == 'maxspeedrsu') {
                maxspeedrsu = attribute.Value__c;
            } else if (attribute.Name == 'maxspeedtechnology') {
                maxspeedtechnology = attribute.Value__c;
            } else if (attribute.Name == 'city') {
                city = attribute.Value__c;
            } else if (attribute.Name == 'technology') {
                technology = attribute.Value__c;
            }
        }

        List < ARTL_MSU_Matrix__c > msuMatrixList = [
            SELECT Id, Circle__c, MSUCode__c, Name, NetworkCity__c, RSUCode__c, RSUIdentifier__c
            FROM ARTL_MSU_Matrix__c
            WHERE RSUCode__c =: rsuName
            AND NetworkCity__c =: city
        ];

        for (ARTL_MSU_Matrix__c msuCode: msuMatrixList) {
            cityToMsuCodeMap.put(msuCode.NetworkCity__c, msuCode.MSUCode__c);
        }

        List < STD_Code__mdt > stdCodeMetadataList = [
            SELECT Id, City__c, STD_Code__c FROM STD_Code__mdt WHERE City__c =: city
        ];

        for (STD_Code__mdt stdCode: stdCodeMetadataList) {
            cityToSTDCodeMap.put(stdCode.City__c, stdCode.STD_Code__c);
        }

        List < vlocity_cmt__FulfilmentRequestLine__c > frlList = new List < vlocity_cmt__FulfilmentRequestLine__c > ();
        List < vlocity_cmt__FulfilmentRequestLine__c > RootFrlList = [
            Select id, vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.ProductCode,
            vlocity_cmt__AttributeSelectedValues__c, vlocity_cmt__FulfilmentRequestID__c, vlocity_cmt__LineNumber__c
            From vlocity_cmt__FulfilmentRequestLine__c
            Where vlocity_cmt__FulfilmentRequestID__c =: FrId AND
            (vlocity_cmt__Product2Id__r.ProductCode = 'VEPC_DSL_CFS'
                OR vlocity_cmt__Product2Id__r.ProductCode = 'VEPC_Voice_CFS')
        ];    //For DSL & voice line nos
        System.debug('AA RootFrlList=>'+RootFrlList);
        
        List < vlocity_cmt__FulfilmentRequestLine__c > ChildFrlList = [
            select id, vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.ProductCode,
            vlocity_cmt__AttributeSelectedValues__c, vlocity_cmt__FulfilmentRequestID__c, vlocity_cmt__LineNumber__c
            from vlocity_cmt__FulfilmentRequestLine__c
            where vlocity_cmt__FulfilmentRequestID__c =: FrId AND
            (vlocity_cmt__Product2Id__r.ProductCode != 'VEPC_DSL_CFS'
                OR vlocity_cmt__Product2Id__r.ProductCode != 'VEPC_Voice_CFS')
        ]; 
        System.debug('AA ChildFrlList=>'+ ChildFrlList);
        
        for (vlocity_cmt__FulfilmentRequestLine__c frl: RootFrlList) {
            //String linenumber = frl.vlocity_cmt__LineNumber__c;
            if (frl.vlocity_cmt__Product2Id__r.ProductCode == 'VEPC_DSL_CFS' || frl.vlocity_cmt__Product2Id__r.ProductCode == 'VEPC_Voice_CFS') {
                parentLineNumbers.add(frl.vlocity_cmt__LineNumber__c);
                System.debug('linenumber#' + parentLineNumbers);
            } 
        }

        for (vlocity_cmt__FulfilmentRequestLine__c frl: ChildFrlList) {
            for (String parentLineNumber: parentLineNumbers) {
                if (frl.vlocity_cmt__LineNumber__c.startsWith(parentLineNumber + '.')) {
                    System.debug('frl line no inside if#' + frl.vlocity_cmt__LineNumber__c);
                    System.debug('frl inside if#' + frl.vlocity_cmt__Product2Id__r.ProductCode);
                    Map < String, Object > FRLStringMap;
                    if (frl.vlocity_cmt__AttributeSelectedValues__c != NULL)
                        FRLStringMap = (Map < String, Object > ) JSON.deserializeUntyped(frl.vlocity_cmt__AttributeSelectedValues__c);
                    else
                        FRLStringMap = new Map < String, Object > ();
                    String FRLAttString = '';

                    for (String s: FRLStringMap.keySet()) {
                        if (s == 'ATT_ RSU') {
                            FRLStringMap.put(s, rsuName);
                        }
                        if (s == 'ATT_Max_Speed') {
                            FRLStringMap.put(s, maxspeed);
                        }
                        if (s == 'ATT_Max_Speed_RSU') {
                            FRLStringMap.put(s, maxspeedrsu);
                        }
                        if (s == 'ATT_Max_Speed_Technology') {
                            FRLStringMap.put(s, maxspeedtechnology);
                        }
                        if (s == 'ATT_TECHNOLOGY') {
                            FRLStringMap.put(s, technology);
                        }
                        if (s == 'ATT_STD_Code') {
                            FRLStringMap.put(s, cityToSTDCodeMap.get(city));
                        }
                        if (s == 'ATT_MSU') {
                            FRLStringMap.put(s, cityToMsuCodeMap.get(city));
                        }
                        if (s == 'ATT_Speed') {
                        FRLStringMap.put(s, attributeValue);
                        }
                    }
                    FRLAttString = JSON.serialize(FRLStringMap);
                    frl.vlocity_cmt__AttributeSelectedValues__c = FRLAttString;
                    frlList.add(frl);
                } 
            }
        }

        if (frlList.size() > 0) {
            update frlList;
        }
    }
}