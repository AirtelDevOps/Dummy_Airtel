/******************************************************************************************************
* @Author:      
* @Company:     Salesforce
* @Date:        
* @Reviewer:
* @Review Date:
* @Description: 
* ++++++++++++++++++++++ Changes Implemented / Modification Log ++++++++++++++++++++++++++++++++++++++
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1.           
*******************************************************************************************************/
global with sharing class ARTL_ContractTemplateClass implements vlocity_cmt.VlocityOpenInterface2{
    @TestVisible private static final String CONST_tokenMap   = 'tokenMap';
    private static final String WANPRODNAME='Connectivity WAN IP';
    private static final String LANPRODNAME='Connectivity LAN IP';
     private static String ConLinkPeriod='';
    // Method invoked during OmniStudio DocGen that calls getTokenData
    global Object invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){
        try{
            Boolean success = false;
            if (methodName == 'getTokenData') {
                success = getTokenData(input, output, options);          
            } else {
            } return success;
        }catch(Exception ex){
            System.debug('Exception invokeMethod ------------- '+ex.getMessage()+'L No- '+ex.getLineNumber());
            return false;
        }   
    }    
    private Boolean getTokenData(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        try{
            Boolean success = true;
            Id contractId = (Id) input.get('contextId');
            Id templateId = (Id) input.get('templateId');
            System.debug('***Template Id: '+input.get('templateId'));
            vlocity_cmt__DocumentTemplate__c selectedTemplate = [SELECT Name FROM vlocity_cmt__DocumentTemplate__c WHERE Id = :templateId];
            String selectedTemplateName = selectedTemplate.Name;
            System.debug('***selectedTemplateName: '+selectedTemplateName);
            System.debug('***scontractId: '+contractId);
           
            if(contractId != null){
                
                // Query Quote Object - Return as single object
                Contract contractRec = [SELECT Id,vlocity_cmt__QuoteId__c
                                        FROM Contract 
                                        WHERE Id=:contractId];
                String quoteId = contractRec.vlocity_cmt__QuoteId__c;
                Quote thisQuote = [select id, ARTL_AnnualRecurringTotal__c,vlocity_cmt__EffectiveOneTimeTotal__c from quote where id=:quoteId Limit 1];				
                Map<Id,ARTL_Billing_Staging__c>  QuotelineStagingMap=getBillStagingRecords(quoteId);
                List<QuoteLineItem> lineitemlist = new List<QuoteLineItem>();
                
                // Construct Dynamic Query for QuoteLineItem Query
                String LineItemQuery = 'select id,quote.vlocity_cmt__EffectiveOneTimeTotal__c,CND__c ,ARTL_Service_Type__c,quote.account.name,Quote.Name,Annual_Recurring_Total__c,Annual_Recurring_Charge__c,vlocity_cmt__AttributeSelectedValues__c,Quote.vlocity_cmt__OneTimeTotal__c,Quote.ARTL_AnnualRecurringTotal__c,Quote.vlocity_cmt__RecurringTotal__c,quote.QuoteNumber,vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c,vlocity_cmt__QuoteMemberId__r.vlocity_cmt__City__c,vlocity_cmt__QuoteMemberId__r.vlocity_cmt__State__c,vlocity_cmt__QuoteMemberId__r.vlocity_cmt__PostalCode__c,vlocity_cmt__QuoteMemberId__r.vlocity_cmt__Country__c,vlocity_cmt__AssetReferenceId__c,vlocity_cmt__JSONAttribute__c,vlocity_cmt__QuoteGroupId__c,vlocity_cmt__QuoteMemberId__c,vlocity_cmt__QuoteMemberId__r.DCP_Record__r.Contact__r.name,vlocity_cmt__QuoteMemberId__r.DCP_Record__r.Contact__r.phone,Product2id,Product2.Name,Product2.vlocity_cmt__IsLocationDependent__c,vlocity_cmt__QuoteGroupId__r.Name,vlocity_cmt__ParentItemId__c,vlocity_cmt__RootItemId__c,vlocity_cmt__OneTimeTotal__c,Quantity,vlocity_cmt__RecurringTotal__c,';
                LineItemQuery+='TotalPrice,Product2.vlocity_cmt__AttributeMetadata__c,Product2.Description,vlocity_cmt__EffectiveQuantity__c,Product2.ProductCode,vlocity_cmt__AttributeMetadataChanges__c,Product2.ARTL_LSIRequired__c from QuoteLineItem';
                String LineItemwhereClause;
                
                LineItemwhereClause = 'QuoteId=:quoteId';
                
                // Declare Variable - Set value for lineitemlist equal to results of Database.query() with Dynamic Query
                lineitemlist = Database.query(LineItemQuery + ' where ' + LineItemwhereClause);
                system.debug('***Line Item List: '+lineitemlist);
                
                List< Map< String , Object > > clsQuoteList = new List< Map< String , Object > >();
                Map< Id , List < QuoteLineItem > > memberAndRootItemMap = new Map< Id , List < QuoteLineItem > >();
                Map< String , List< QuoteLineItem > > parentChildProdMap = new Map< String , List< QuoteLineItem > >();
                Map< String, Object >  ConnectivityLanAttMap =  New  Map< String, Object >();
                Map< String, Object >  ConnectivityWanAttMap =  New  Map< String, Object >();
                Map< String, Object >  PrimaryMplsMap =  New  Map< String, Object >();
                List< QuoteLineItem > qLIList = new List< QuoteLineItem >();
                Map<Id,sitewrapper> memberSiteMap=new Map<Id,sitewrapper> ();
                string serviceType='';
                Integer noOfWan=0;
                Integer noOfLan=0;
                Integer countRoot=0;
                String productType='';
                Set<Id> sitesProcessed=new Set<Id>();
                Map<string,Integer> LSILanMap=new Map<string,Integer>();
                Map<string,Integer> LSIWanMap=new Map<string,Integer>();
                Integer LSILanCount=0;
                Integer LSIWanCount=0;
                for(QuoteLineItem qLI: lineitemlist)
                {
                    If(qli.product2.Name=='Primary Link' )
                    {
                        system.debug('first if');
                          ///Contract period at link level
                        if(qli.vlocity_cmt__AttributeSelectedValues__c!= null){
                            system.debug('first if vlocity_cmt__AttributeSelectedValues__c');
                            Map< String, Object >  contractPeriodAtt =  (Map< String, Object >)JSON.deserializeUntyped(qli.vlocity_cmt__AttributeSelectedValues__c);
                            if(contractPeriodAtt !=  null && contractPeriodAtt.keySet().size() > 0){
                                if(contractPeriodAtt.containsKey('ATT_CONTRACT_TERM')){
                                    ConLinkPeriod=(string)contractPeriodAtt.get('ATT_CONTRACT_TERM');
                                }
                            }
                        }     
                    }
                }
                
                for(QuoteLineItem qLI: lineitemlist){
                    
                    if(qli.product2.Name==WANPRODNAME)
                    {
                        system.debug('second if');
                        if(LSIWanMap.get(qli.vlocity_cmt__ParentItemId__c)==Null)
                        {
                            LSIWanMap.put(qli.vlocity_cmt__ParentItemId__c,Integer.valueof(qli.Quantity)); 
                            LSIWanCount= Integer.valueof(qli.Quantity);
                        } 
                        else {
                            LSIWanMap.put(qli.vlocity_cmt__ParentItemId__c,LSIWanMap.get(qli.vlocity_cmt__ParentItemId__c) + Integer.valueof(qli.Quantity)); 
                            LSIWanCount+= Integer.valueof(qli.Quantity) ;
                        }
                        
                        ConnectivityWanAttMap = getattributes(qLI.vlocity_cmt__AttributeSelectedValues__c);
                    }
                    else if(qli.product2.Name==LANPRODNAME)
                    {
                        system.debug('third if');
                        if(LSILanMap.get(qli.vlocity_cmt__ParentItemId__c)==Null)
                        {
                            LSILanMap.put(qli.vlocity_cmt__ParentItemId__c,Integer.valueof(qli.Quantity)); 
                            LSILANCount+=Integer.valueof(qli.Quantity);
                        } else {
                            LSILanMap.put(qli.vlocity_cmt__ParentItemId__c,LSILanMap.get(qli.vlocity_cmt__ParentItemId__c) + Integer.valueof(qli.Quantity)); 
                            LSILANCount+=Integer.valueof(qli.Quantity);
                        }
                        ConnectivityLanAttMap = getattributes(qLI.vlocity_cmt__AttributeSelectedValues__c);
                    }
                   
                    
                    if(qLI.vlocity_cmt__QuoteMemberId__c != null  && qLI.vlocity_cmt__ParentItemId__c == null){
                        system.debug('fourth if');
                        system.debug('memberAndRootItemMap memberAndRootItemMap=>'+JSON.serializePretty(memberAndRootItemMap));
                        if(memberAndRootItemMap != null && memberAndRootItemMap.containsKey(qLI.vlocity_cmt__QuoteMemberId__c)){
                            memberAndRootItemMap.get(qLI.vlocity_cmt__QuoteMemberId__c).add(qLI);
                        }else{
                            memberAndRootItemMap.put(qLI.vlocity_cmt__QuoteMemberId__c, new List< QuoteLineItem >{qLI});
                        }
                        system.debug('memberAndRootItemMap memberAndRootItemMap2=>'+JSON.serializePretty(memberAndRootItemMap));
                        //set servicetype
                        if(qli.product2.Name!='Secondary Internet Link' && qli.product2.Name!='Secondary Internet Link')
                        countRoot+=1;
                        if((qli.product2.Name).contains('Internet'))
                        {
                            productType = 'Dedicated Internet';
                        } 
                        ARTL_Billing_Staging__c stagerecord=new  ARTL_Billing_Staging__c();
                        system.debug('memberAndRootItemMap QuotelineStagingMap=>'+JSON.serializePretty(QuotelineStagingMap));
                        system.debug('qLI.id::' + qLI.id);
                        system.debug('QuotelineStagingMap.get(qLI.id)::' + QuotelineStagingMap.get(qLI.id));
                        //this part is coming as null.Iterating with root qli and map contains primary link
                        //Map key :: link QLI :: value :: billing staging.
                        //its not going into if block
                        if(QuotelineStagingMap.get(qLI.id)!=null){
                            system.debug('qLI.id::' + qLI.id);
                            stagerecord=QuotelineStagingMap.get(qLI.id);
                        }
                        system.debug('qli.vlocity_cmt__OneTimeTotal__c '+qli.vlocity_cmt__OneTimeTotal__c);
                         
                      	system.debug('memberAndRootItemMap stagerecord=>'+JSON.serializePretty(stagerecord));
                        
                        system.debug('ConLinkPeriod::' + ConLinkPeriod);
                       // string contractPeriodVal= string.valueof(((Map< String, Object >)JSON.deserializeUntyped(qLI.vlocity_cmt__AttributeSelectedValues__c));
                       system.debug('165'+stagerecord.Billing_Address__c+stagerecord.Delivery_Standard_Reason__c);
                        sitewrapper site=new sitewrapper(string.valueof(qli.CND__c) , serviceType, qli.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c,qli.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__PostalCode__c,qli.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__City__c,qli.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__State__c,
                                                         qli.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__Country__c,qli.quote.Account.name,stagerecord.Billing_Address__c,qli.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__City__c,qli.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__State__c,qli.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__Country__c,qli.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__PostalCode__c,
                                                         qli.vlocity_cmt__QuoteMemberId__r.DCP_Record__r.Contact__r.name,qli.vlocity_cmt__QuoteMemberId__r.DCP_Record__r.Contact__r.Phone,ConLinkPeriod,null,qli.Annual_Recurring_Total__c,qli.vlocity_cmt__OneTimeTotal__c,stagerecord.Delivery_Standard_Reason__c=='SEZ'?'YES':'NO',stagerecord.Installation_GST__c);
                        memberSiteMap.put(qLI.vlocity_cmt__QuoteMemberId__c,site);
                        system.debug('memberAndRootItemMap site=>'+JSON.serializePretty(site));
                        system.debug('memberAndRootItemMap memberSiteMap=>'+JSON.serializePretty(memberSiteMap));
                    }
                    if(qLI.vlocity_cmt__ParentItemId__c != null){
                        qLIList.add(qLI);
                    }
                }
                //system.debug('memberAndRootItemMap site=>'+JSON.serializePretty(site));
                system.debug('memberAndRootItemMap=>'+JSON.serializePretty(memberAndRootItemMap));
                //List< Map< String , Object > > clsQuoteList = new List< Map< String , Object > >();
                Map< String , Object > pW = new  Map< String , Object >();
                 
                if(memberAndRootItemMap != null && memberAndRootItemMap.values().size() > 0){
                    for(Id qM: memberAndRootItemMap.keySet() ){
                        system.debug('qm id=>'+JSON.serializePretty(qM));
                        // cls_QuoteMember alsQM = new cls_QuoteMember();
                        Map< String, Object > alsQM = new Map< String, Object>();
                        alsQM.put('MemberId',qM);
                        siteWrapper siteRec= memberSiteMap.get(qM);
                        siteRec.PrimaryAccess=new List<Map<String, Object>> ();
                        List< Map< String, Object > > primarylinks = new  List< Map< String, Object > >();
                        Map< String, Object > attrMap = new Map< String, Object >();
                        
                        system.debug('memberAndRootItemMap LSIWanMap=>'+JSON.serializePretty(LSIWanMap));
                        system.debug('memberAndRootItemMap LSILanMap=>'+JSON.serializePretty(LSILanMap));
                        for(QuoteLineItem qLI: qLIList){
                            system.debug('qm id qLI=>'+JSON.serializePretty(qLI));
                            if(qLI.vlocity_cmt__QuoteMemberId__c != null && qLI.vlocity_cmt__QuoteMemberId__c == qM){
                                system.debug(QLI.id + '::we are here A::' + qli.product2.ARTL_LSIRequired__c);
                                if(qli.product2.ARTL_LSIRequired__c){
                                    system.debug('we are here B');
                                    attrMap=getattributes(qLI.vlocity_cmt__AttributeSelectedValues__c);
                                    ////Connectivity LAN/WAN Attribute mappings
                                   // attrMap.put('wan',LSIWanMap.get(qli.vlocity_cmt__AssetReferenceId__c));
                                   // attrMap.put('Lan',LSILanMap.get(qli.vlocity_cmt__AssetReferenceId__c));
                                    attrMap.putall(ConnectivityWanAttMap);
                                    attrMap.putall(ConnectivityLanAttMap);
                                  /*  attrMap.put('ATT_WAN_IPV6_PE_SUBNET_MASK',ConnectivityWanAttMap.get('ATT_WAN_IPV6_PE_SUBNET_MASK'));
                                    attrMap.put('ATT_WAN_IPV4_CE_SUBNET_MASK',ConnectivityWanAttMap.get('ATT_WAN_IPV4_CE_SUBNET_MASK'));
                                    attrMap.put('ATT_LAN_IPV6_SUBNET_MASK',ConnectivityLanAttMap.get('ATT_LAN_IPV6_SUBNET_MASK'));
                                    attrMap.put('ATT_LAN_IPV4_SUBNET_MASK',ConnectivityLanAttMap.get('ATT_LAN_IPV4_SUBNET_MASK'));
                                    ////Connectivity LAN/WAN Attribute mappings End
                                    attrMap.put('ATT_QOS_PRT_MBPS_CFS',PrimaryMplsMap.get(qm+'ATT_QOS_PRT_MBPS_CFS'));
                                    attrMap.put('ATT_QOS_PnRT_MBPS_CFS',PrimaryMplsMap.get(qm+'ATT_QOS_PnRT_MBPS_CFS'));
                                    attrMap.put('ATT_VPN_TYPE',PrimaryMplsMap.get(qm+'ATT_VPN_TYPE'));
                                    attrMap.put('ATT_VPN_TOPOLOGY',PrimaryMplsMap.get(qm+'ATT_VPN_TOPOLOGY'));
                                    attrMap.put('ATT_LinkTopology',PrimaryMplsMap.get(qm+'ATT_LinkTopology'));*/
                                    
                                    siteRec.PrimaryAccess.add(attrMap);
                                    alsQM.put('PrimaryAccess',primarylinks);
                                }  
                            }
                        }
                        //clsQuoteList.add(alsQM);
                        clsQuoteList.add((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(siteRec)));
                    }
                    if(countRoot==1 && productType=='Dedicated Internet'){
                        serviceType='Dedicated Internet';
                    }else{
                        serviceType='EVPN';
                    }
                    //Calling Dr for other details
                    String DRName = 'ARTLFetchContractDetailsV2'; 
                    /* Populate the input JSON */
                    Map<String, Object> myTransformData = new Map<String, Object>{'Id'=>(String)contractId,'wan'=>LSIWANCount,'Lan'=>LSILANCount,'ServiceType'=>serviceType,'quoteOTC'=>thisQuote.vlocity_cmt__EffectiveOneTimeTotal__c,
					                                                               'quoteARC'=>thisQuote.ARTL_AnnualRecurringTotal__c,'quoteTotal'=> thisQuote.vlocity_cmt__EffectiveOneTimeTotal__c+thisQuote.ARTL_AnnualRecurringTotal__c}; 
                        /* Call the DataRaptor */
                    vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.process(myTransformData, DRName); 
                    /* Deserialize the DataRaptor output for processing in Apex */ 
                    Map<String, Object> myTransformResult = (Map<String,Object>) result.toJson();
                    system.debug('myTransformResult '+myTransformResult);
                    //pW.put('OtherDetails',myTransformResult);
                    pw.putAll(myTransformResult);
                    pW.put('SiteDetails',clsQuoteList);
                    system.debug('memberAndRootItemMap pW=>'+JSON.serializePretty(pW));
                }
                
                
                output.put(CONST_tokenMap, pW);
                system.debug('***Contract Class Output: ' + JSON.serialize(output));
                success = true;
                
                
            }
            else{
                success = false;
            }
            
            return success;
            
        }
        Catch(Exception ex){
            
            System.debug('Exception ARTL_ContractTemplateClass --Msg--'+ex.getMessage()+' L No-'+ex.getLineNumber() +ex.getStackTraceString());
            
            return false;
            
        }
        
        
    }
    
    private Map<Id,ARTL_Billing_Staging__c>  getBillStagingRecords(String quoteId){
        String billStagingFields='Installation_GST__c,Billing_GST__c,Quote_Line_Item__c,Delivery_Standard_Reason__c,Billing_Address__c,Billing_PinCode__c,Billing_State__c,Billing_Street__c,Billing_City__c,Billing_Country__c,DCP_First_Name__c,DCP_Last_Name__c,DCP_Phone__c';
        String whereClause='WHERE Quote__c=:quoteId' ;       
        String billStagingQuery='SELECT '+ billStagingFields+ ' FROM ARTL_Billing_Staging__c ' +whereClause;
        system.debug('billStagingQuery '+billStagingQuery);
        List<ARTL_Billing_Staging__c> billStaging=Database.query(billStagingQuery);
        system.debug('memberAndRootItemMap billStaging=>'+JSON.serializePretty(billStaging));
        Map<Id,ARTL_Billing_Staging__c> QuotelineStagingMap=new Map<Id,ARTL_Billing_Staging__c> ();
        for(ARTL_Billing_Staging__c stageRec:billStaging){
            QuotelineStagingMap.put(stageRec.Quote_Line_Item__c,stageRec);
        } 
        system.debug('memberAndRootItemMap QuotelineStagingMap=>'+JSON.serializePretty(QuotelineStagingMap));
        return QuotelineStagingMap;
    }
    private Map<String,Object> getattributes(String attributeJson){
        Map< String, Object > attrMap = new Map< String, Object >();
        system.debug('attributeJson==>'+attributeJson);
        if(attributeJson!= null){
            Map< String, Object >  existingSAttMap =  (Map< String, Object >)JSON.deserializeUntyped(attributeJson);
            System.debug('existingSAttMap--'+existingSAttMap);
            if(existingSAttMap !=  null && existingSAttMap.keySet().size() > 0){
                if(existingSAttMap.containsKey('ATT_ACCESS_BANDWIDTH')){
                    attrMap.put('ATT_ACCESS_BANDWIDTH',existingSAttMap.get('ATT_ACCESS_BANDWIDTH'));
                }
                if(existingSAttMap.containsKey('ATT_CPE')){
                    attrMap.put('ATT_CPE',existingSAttMap.get('ATT_CPE'));
                }
                if(existingSAttMap.containsKey('ATT_IP_Type')){
                    attrMap.put('ATT_IP_Type',existingSAttMap.get('ATT_IP_Type'));
                }
                if(existingSAttMap.containsKey('ATT_MEDIA')){
                    attrMap.put('ATT_MEDIA',existingSAttMap.get('ATT_MEDIA'));
                }
                if(existingSAttMap.containsKey('ATT_POP')){
                    attrMap.put('ATT_POP',existingSAttMap.get('ATT_POP'));
                }
                if(existingSAttMap.containsKey('ATT_PORT_BANDWIDTH')){
                    attrMap.put('ATT_PORT_BANDWIDTH',existingSAttMap.get('ATT_PORT_BANDWIDTH'));
                }
                if(existingSAttMap.containsKey('ATT_ROUTING_TYPE')){
                    attrMap.put('ATT_ROUTING_TYPE',existingSAttMap.get('ATT_ROUTING_TYPE'));
                }
                if(existingSAttMap.containsKey('ATT_ROUTING_PROTOCOL')){
                    attrMap.put('ATT_ROUTING_PROTOCOL',existingSAttMap.get('ATT_ROUTING_PROTOCOL'));
                }
                if(existingSAttMap.containsKey('ATT_SERVICE_TYPE')){
                    attrMap.put('ATT_SERVICE_TYPE',existingSAttMap.get('ATT_SERVICE_TYPE'));
                }
                if(existingSAttMap.containsKey('ATT_CONTRACT_TERM')){
                    attrMap.put('ATT_CONTRACT_TERM',existingSAttMap.get('ATT_CONTRACT_TERM'));
                }
                if(existingSAttMap.containsKey('ATT_LAST_MILE')){
                    attrMap.put('ATT_LAST_MILE',existingSAttMap.get('ATT_LAST_MILE'));
                }
                if(existingSAttMap.containsKey('ATT_IP_REQUIRED')){
                    attrMap.put('ATT_IP_REQUIRED',existingSAttMap.get('ATT_IP_REQUIRED'));
                }
                if(existingSAttMap.containsKey('ATT_QOS_PRT_MBPS_CFS')){
                    attrMap.put('ATT_QOS_PRT_MBPS_CFS',existingSAttMap.get('ATT_QOS_PRT_MBPS_CFS'));
                }
                if(existingSAttMap.containsKey('ATT_QOS_PnRT_MBPS_CFS')){
                    attrMap.put('ATT_QOS_PnRT_MBPS_CFS',existingSAttMap.get('ATT_QOS_PnRT_MBPS_CFS'));
                }
                if(existingSAttMap.containsKey('ATT_VPN_TYPE')){
                    attrMap.put('ATT_VPN_TYPE',existingSAttMap.get('ATT_VPN_TYPE'));
                }
                if(existingSAttMap.containsKey('ATT_LinkTopology')){
                    attrMap.put('ATT_LinkTopology',existingSAttMap.get('ATT_LinkTopology'));
                }
                if(existingSAttMap.containsKey('ATT_VPN_TOPOLOGY')){
                    attrMap.put('ATT_VPN_TOPOLOGY',existingSAttMap.get('ATT_VPN_TOPOLOGY'));
                }
                if(existingSAttMap.containsKey('ATT_WAN_IPV6_PE_SUBNET_MASK')){
                    attrMap.put('ATT_WAN_IPV6_PE_SUBNET_MASK',existingSAttMap.get('ATT_WAN_IPV6_PE_SUBNET_MASK'));
                }
                if(existingSAttMap.containsKey('ATT_WAN_IPV4_CE_SUBNET_MASK')){
                    attrMap.put('ATT_WAN_IPV4_CE_SUBNET_MASK',existingSAttMap.get('ATT_WAN_IPV4_CE_SUBNET_MASK'));
                }
                if(existingSAttMap.containsKey('ATT_LAN_IPV6_SUBNET_MASK')){
                    attrMap.put('ATT_LAN_IPV6_SUBNET_MASK',existingSAttMap.get('ATT_LAN_IPV6_SUBNET_MASK'));
                }
                if(existingSAttMap.containsKey('ATT_LAN_IPV4_SUBNET_MASK')){
                    attrMap.put('ATT_LAN_IPV4_SUBNET_MASK',existingSAttMap.get('ATT_LAN_IPV4_SUBNET_MASK'));
                }
                if(existingSAttMap.containsKey('ATT_LAN_IPV4') && existingSAttMap.get('LANIP')==null){
                    attrMap.put('LANIP',existingSAttMap.get('ATT_LAN_IPV4'));
                }
                if(existingSAttMap.containsKey('ATT_LAN_IPV6') && existingSAttMap.get('LANIP')==null){
                    attrMap.put('LANIP',existingSAttMap.get('ATT_LAN_IPV6'));
                }
                if(existingSAttMap.containsKey('ATT_WAN_IPV4_CE') && existingSAttMap.get('WANIP')==null){
                    attrMap.put('WANIP',existingSAttMap.get('ATT_WAN_IPV4_CE'));
                }
                if(existingSAttMap.containsKey('ATT_WAN_IPV4_PE') && existingSAttMap.get('WANIP')==null){
                    attrMap.put('WANIP',existingSAttMap.get('ATT_WAN_IPV4_PE'));
                }
                if(existingSAttMap.containsKey('ATT_WAN_IPV6_CE') && existingSAttMap.get('WANIP')==null){
                    attrMap.put('WANIP',existingSAttMap.get('ATT_WAN_IPV6_CE'));
                }
                if(existingSAttMap.containsKey('ATT_WAN_IPV6_PE') && existingSAttMap.get('WANIP')==null){
                    attrMap.put('WANIP',existingSAttMap.get('ATT_WAN_IPV6_PE'));
                }
                
            }
        }
        return attrMap;
    }
    class sitewrapper{
        public string streetAddress;
        public string sitePincode;
        public string siteCity;
        public string siteState;
        public string siteCountry;
        public string CompanyName;
        public string billingAddress;
        public string billingCity;
        public string billingState;
        public string billingCountry;
        public string billingPincode;
        public string inchargeName;
        public String inchargePhone;
        public string contractPeriod;
        public Date deliveryDate;
        public Decimal arc;
        public Decimal otc;
        public Decimal total;
        public Decimal otcharge;
		
        public String SEZ;
        public String GSTN;
        public String ServiceType;
        public String RequestedDateOfDelivery;
        
        List<Map<String, Object>> PrimaryAccess;
        
        public sitewrapper(string RequestedDateOfDelivery,string ServiceType,string streetAddress,string sitePincode,string siteCity,string siteState,string siteCountry,string CompanyName,
                           string billingAddress,string billingCity,string billingState,string billingCountry,String billingPincode,string inchargeName,string inchargePhone,
                           string contractPeriod,Date deliveryDate,Decimal arc,Decimal otc, String SEZ,String GSTN){
                               this.streetAddress=streetAddress;
                               this.sitePincode=sitePincode;
                               this.siteCity=siteCity;
                               this.siteState=siteState;
                               this.siteCountry=siteCountry;
                               this.CompanyName=CompanyName;
                               this.billingAddress=billingAddress;
                               this.billingCity=billingCity;
                               this.billingState=billingState;
                               this.billingCountry=billingCountry;
                               this.billingPincode=billingPincode;
                               this.inchargeName=inchargeName;
                               this.inchargePhone=inchargePhone;
                               this.contractPeriod=contractPeriod;
                               this.deliveryDate=deliveryDate;
                               this.arc=arc;
                               this.SEZ=SEZ;
                               this.GSTN=GSTN;
                               this.otc=otc;
                               this.total=arc+otc;
							   this.ServiceType=ServiceType;
                               this.RequestedDateOfDelivery =RequestedDateOfDelivery;
                           }
    }
    
}