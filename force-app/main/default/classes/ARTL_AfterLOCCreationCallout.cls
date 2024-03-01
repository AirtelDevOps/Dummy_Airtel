global with sharing class ARTL_AfterLOCCreationCallout {

    @InvocableMethod(label = 'Callout for LOC Task')
    global static void jsonPrepareForLOC(List<taskLOC> input){
        Id taskId = input[0].taskLOCId;
        Id orderId = input[0].orderRecId;
        if(orderId != null && taskId != null){
            jsonPrepareForLOCFuture(orderId,taskId);
        }
    }
    
    @future(callout=true)
    global static void jsonPrepareForLOCFuture(Id orderId, Id taskId){
        Map<String, Object> sitesMap = new Map<String, Object> ();
        Map<String, String> attrDataMap = new Map<String, String>();
        Task tsk = [Select Id,CreatedDate,Number_of_days_for_Deemed_LOC__c, ARTL_locAcceptanceCriteria__c from Task where Id =: taskId];
        List<ARTL_Task_Integration_Logs__c> tskIntLog = [Select id,ARTL_Input_Attributes__c from ARTL_Task_Integration_Logs__c where ARTL_OrderId__c =: orderId];
        Order ordRec = [Select Id,ARTL_SOMOrderId__c, vlocity_cmt__ParentOrderId__c, ARTL_OrderType__c, ARTL_Root_ProductCode__c, 
                        Opportunity.Owner.Name,Opportunity.Owner.Email, Opportunity.Owner.Phone,AccountId,
                        vlocity_cmt__DefaultBillingAccountId__r.vlocity_cmt__BillFrequency__c, vlocity_cmt__DefaultBillingAccountId__r.Billing_Level__c,
                        PM_Name__c, PM_Email__c, PM_Phone__c,Account.ARTL_Customer_Segment__c,Account.ARTL_Business_Circle_Region__c,Account.ARTL_Vertical_Segment__c,
                        Account.Name,Account.AccountNumber,Contract.ARTL_CAFNumber__c, Contract.ContractNumber,Contract.ContractTerm FROM Order WHERE Id =:orderId];
        Contact[] deliveryContact = [Select id,MailingAddress, MailingState, MailingCity, MailingPostalCode, Name,Email,Phone  from Contact where ARTL_Contact_Role__c = 'Delivery Contact' and AccountId =:ordRec.AccountId];
        List<OrderItem> oliRecordList = [Select Id,ARTL_Media__c, ARRTL_BandWidth__c, ARTL_PortBandwidth__c, ARTL_Latest_PO__r.ARTL_PO_Number__c, 
                                         ARTL_Feasibility__r.ARTL_Feasibility_ID__c,ARTL_LSI__c,ARTL_Service_Type__c,ARTL_ItemCode__c, 
                                         ARTL_RouterMake__c, ARTL_RouterModel__c,RFS__c, CND__c from OrderItem where orderId =: orderId];               
        for(OrderItem oi : oliRecordList){
            sitesMap.put('media', oi.ARTL_Media__c != null ? oi.ARTL_Media__c : '');
            sitesMap.put('serviceType', oi.ARTL_Service_Type__c != null ? oi.ARTL_Service_Type__c : '');
            sitesMap.put('poNumber', oi.ARTL_Latest_PO__r.ARTL_PO_Number__c != null ? oi.ARTL_Latest_PO__r.ARTL_PO_Number__c : '');
            sitesMap.put('portBandwidth', oi.ARTL_PortBandwidth__c != null ? oi.ARTL_PortBandwidth__c : '');
            sitesMap.put('accessBandwidth', oi.ARRTL_BandWidth__c != null ? oi.ARRTL_BandWidth__c : '');
            sitesMap.put('lsiId', oi.ARTL_LSI__c != null ? String.valueof(oi.ARTL_LSI__c) : '');
            sitesMap.put('feasibilityId', oi.ARTL_Feasibility__r.ARTL_Feasibility_ID__c != null ? oi.ARTL_Feasibility__r.ARTL_Feasibility_ID__c : '');
            sitesMap.put('itemCode', oi.ARTL_ItemCode__c != null ? oi.ARTL_ItemCode__c : '');
            sitesMap.put('routerMake', oi.ARTL_RouterMake__c != null ? oi.ARTL_RouterMake__c : '');
            sitesMap.put('routerModel', oi.ARTL_RouterModel__c != null ? String.valueof(oi.ARTL_RouterModel__c) : '');
            sitesMap.put('newRfsDate', oi.RFS__c != null ? String.valueof(oi.RFS__c) : '');
            sitesMap.put('originalRfsDate', oi.RFS__c != null ? String.valueof(oi.RFS__c) : '');
            sitesMap.put('customerNeedByDate', oi.CND__c != null ? String.valueof(oi.CND__c) : '');
        }
        if (deliveryContact.size() > 0){
            sitesMap.put('locCustContactName',deliveryContact[0].Name);
            sitesMap.put('locCustContactEmail',deliveryContact[0].Email);
            sitesMap.put('locCustContactPhone',deliveryContact[0].Phone);
            sitesMap.put('dcpAddress',deliveryContact[0].MailingAddress);
            sitesMap.put('dcpCity',deliveryContact[0].MailingCity);
            sitesMap.put('dcpState',deliveryContact[0].MailingState);
            sitesMap.put('dcpPincode',deliveryContact[0].MailingPostalCode);
        }
        if(tskIntLog.size() > 0){
            if(tskIntLog[0].ARTL_Input_Attributes__c != null){
                Map<String, Object> attrObject = (Map<String, Object>)JSON.deserializeUntyped(tskIntLog[0].ARTL_Input_Attributes__c);
                for (String key : attrObject.keySet()) {
                    Object innerData = attrObject.get(key);
                    List<Object> attrList = (List<Object>)innerData;
                    for (Object data : attrList) {
                        Map<String, Object> dataItem = (Map<String, Object>)data;
                        String name = (String)dataItem.get('Name');
                        String value = (String)dataItem.get('Value');
                        attrDataMap.put(name, value);
                    }
                }
                system.debug('attrDataMap--->'+attrDataMap);
            }
        }
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object>();
        ipOptions.put('isDebug',false);
        ipOptions.put('useQueueable',true);
        List<Object> sitesList =  new List<Object>();
        sitesMap.put('id',taskId);
        sitesMap.put('deemedLocDays',tsk.Number_of_days_for_Deemed_LOC__c);
        sitesMap.put('acceptanceCriteria',tsk.ARTL_locAcceptanceCriteria__c);
        sitesMap.put('poleTowerHeight',attrDataMap.get('CPE Customer Tower Height'));
        sitesMap.put('poleTowerType',attrDataMap.get('CPE Customer Tower Type'));
        sitesMap.put('lanIpv4',attrDataMap.get('LAN IPv4'));
        sitesMap.put('wanIpv4CE',attrDataMap.get('WAN IPv4 CE'));
        sitesMap.put('wanIpv4PE',attrDataMap.get('WAN IPv4 PE'));
        sitesMap.put('lanIpv6',attrDataMap.get('LAN IPv6'));
        sitesMap.put('wanIpv6',attrDataMap.get('WAN IPv6'));
        sitesMap.put('circuitId',attrDataMap.get('Circuit ID'));
        sitesMap.put('lanIpv4Subnet',attrDataMap.get('LAN IPv4 Subnet'));
        sitesMap.put('lanIpv6Subnet',attrDataMap.get('LAN IPv6 Subnet'));
        sitesMap.put('wanIpv4Subnet',attrDataMap.get('WAN IPv4 Subnet'));
        sitesMap.put('wanIpv6CE',attrDataMap.get('WAN IPv6 CE'));
        sitesMap.put('wanIpv6PE',attrDataMap.get('WAN IPv6 PE'));
        sitesMap.put('wanIpv6Subnet',attrDataMap.get('WAN IPv6 Subnet'));
        sitesMap.put('loopbackIpv4',attrDataMap.get('Loopback Ipv4'));
        sitesMap.put('loopbackIpv6',attrDataMap.get('Loopback IPv6'));
        sitesMap.put('businessCircle',ordRec.Account.ARTL_Business_Circle_Region__c);
        sitesMap.put('implementationCircle',ordRec.Account.ARTL_Business_Circle_Region__c);
        sitesMap.put('connectivityType','');
        sitesMap.put('customerSegment',ordRec.Account.ARTL_Customer_Segment__c);
        sitesMap.put('vertical',ordRec.Account.ARTL_Vertical_Segment__c);
        sitesMap.put('infovistaUrl',attrDataMap.get('Infovista URL'));
        sitesMap.put('infovistaUsername',attrDataMap.get('Infovista Username'));
        sitesMap.put('infovistaPassword',attrDataMap.get('Infovista Password'));
        sitesMap.put('billingStartDate','');
        sitesMap.put('contractTerm',ordRec.Contract.ContractTerm);
        sitesMap.put('billingLevel',ordRec.vlocity_cmt__DefaultBillingAccountId__r.Billing_Level__c);
        sitesMap.put('billFrequency',ordRec.vlocity_cmt__DefaultBillingAccountId__r.vlocity_cmt__BillFrequency__c);
        sitesMap.put('kamTsmName',ordRec.Opportunity.Owner.Name);
        sitesMap.put('kamTsmPhone',ordRec.Opportunity.Owner.Phone);
        sitesMap.put('kamTsmEmail',ordRec.Opportunity.Owner.Email);
        sitesMap.put('pmName',ordRec.PM_Name__c);
        sitesMap.put('pmContact',ordRec.PM_Phone__c);
        sitesMap.put('pmEmail',ordRec.PM_Email__c);
        sitesList.add(sitesMap);
        //ipInput
        ipInput.put('SOMOrderId',ordRec.ARTL_SOMOrderId__c);
        ipInput.put('MasterOrderId',ordRec.vlocity_cmt__ParentOrderId__c);
        ipInput.put('OrderType',ordRec.ARTL_OrderType__c);
        ipInput.put('RootProductName',ordRec.ARTL_Root_ProductCode__c);
        ipInput.put('AccountNumber',ordRec.Account.AccountNumber);
        ipInput.put('AccountName',ordRec.Account.Name);
        ipInput.put('ContractNumber',ordRec.Contract.ContractNumber);
        ipInput.put('TaskCreatedDate',tsk.CreatedDate);
        ipInput.put('sites',sitesList);
        System.debug('ipInput : '+JSON.serializePretty(ipInput));
        ipOutput = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService('ARTLOM_LOCTaskCallout', ipInput, ipOptions);
        System.debug('ipOutput : '+JSON.serializePretty(ipOutput));
    }
    
    global class taskLOC
    {
        @InvocableVariable(label = 'LOC Task Record') global String taskLOCId;
        @InvocableVariable(label = 'Order Record') global String orderRecId;
    }
}