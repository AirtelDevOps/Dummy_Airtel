public class ARTL_NonDeemedLOCEmail {
    
    
/******************************************************************************************************************
* Method Name        : generateAttachmentForNonDeemedLOCILLnewCircuitID
* Method Description : Generate Non Deemed LOC ILL Product Attachment
*******************************************************************************************************************/
    
    public void generateAttachmentForNonDeemedLOCILLnewCircuitID( Map<String, Object> inputMap, Map<String, Object> outMap,Map<String, Object> options){
        String OrderId = String.valueOf(inputMap.get('OrderId'));
        List<Order> orderRecords = [Select vlocity_cmt__QuoteId__c,vlocity_cmt__QuoteId__r.QuoteNumber,vlocity_cmt__ParentOrderId__r.OrderNumber,OrderNumber,Account.name,AccountId,vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c,account.vlocity_cmt__PrimaryContactId__r.name, account.vlocity_cmt__PrimaryContactId__r.Email, account.vlocity_cmt__PrimaryContactId__r.MobilePhone, vlocity_cmt__DefaultServiceAccountId__r.ShippingStreet,vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode ,vlocity_cmt__DefaultServiceAccountId__r.ShippingCity, vlocity_cmt__DefaultServiceAccountId__r.ShippingState, vlocity_cmt__DefaultServiceAccountId__r.ARTL_Billing_Pincode__c,vlocity_cmt__DefaultServiceAccountId__r.ShippingCountry, vlocity_cmt__OneTimeTotal__c, ARTL_AnnualRecurringTotal__c, vlocity_cmt__QuoteId__r.Contract.ContractTerm, account.vlocity_cmt__BillFrequency__c,vlocity_cmt__QuoteId__r.PM_Name__c, vlocity_cmt__QuoteId__r.PM_Phone__c, vlocity_cmt__QuoteId__r.PM_Email__c from Order where Id=:OrderId Limit 1 ];
        String QuoteId = orderRecords[0].vlocity_cmt__QuoteId__c;
        String AccountId = orderRecords[0].AccountId;
        String AccountName = orderRecords[0].Account.name;
        String Quotenumber = orderRecords[0].vlocity_cmt__QuoteId__r.QuoteNumber;
        List<Id> quoteitemids = new List<Id>();
        List<AccountTeamMember> accteammem = [SELECT Id,User.name,User.Email, user.MobilePhone from AccountTeamMember where AccountId =:AccountId and TeamMemberRole = 'Voice KAM' ];
        for (OrderItem orderitemrecord: [select ARTL_QuoteLineItemId__c from orderitem where orderid =:OrderId]){
            quoteitemids.add(orderitemrecord.ARTL_QuoteLineItemId__c);
        }
        List<QuoteLineItem> quotelineitems = [select id, vlocity_cmt__AttributeSelectedValues__c,ARTL_LSI__c, vlocity_cmt__Product2Id__r.ProductCode from QuoteLineItem where id in:quoteitemids ];
        List<String> toaddresses = new List<String>();        
        //Creating Kick Off CSV file
        String csvFile;
        String csvColumnHeader = 'Sr. No.,Particulars,Values';
        List<String> csvRowValues = new List<String>();
        
        //Entering All the fields 
        if(csvColumnHeader != NULL)
        {
            csvFile = csvColumnHeader + '\n' +'1,Customer Name,'+AccountName+'\n'+'2,Customer PO Number,'+(orderRecords[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c==null?'':orderRecords[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c)+ '\n' +'3,Master Order Number,'+orderRecords[0].vlocity_cmt__ParentOrderId__r.OrderNumber+'\n'+'4,Sub Order Number,'+orderRecords[0].OrderNumber+'\n'+'5,Order Type,New'+'\n'+'6,Product Type,Internet'+'\n'+'7,Router Max. Bandwidth,-'+'\n'+'8,Local Contact Name,'+(orderRecords[0].account.vlocity_cmt__PrimaryContactId__r.name==null?'':orderRecords[0].account.vlocity_cmt__PrimaryContactId__r.name) +'\n'+'9,Local Contact Email,'+(orderRecords[0].account.vlocity_cmt__PrimaryContactId__r.Email==null?'':orderRecords[0].account.vlocity_cmt__PrimaryContactId__r.Email)+'\n'+'10,Local Contact Phone Number,'+orderRecords[0].account.vlocity_cmt__PrimaryContactId__r.MobilePhone+'\n'+'11,Installation Address,'+(orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingStreet==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingStreet) +' ' +(orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCity==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCity) +' ' +(orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingState==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingState) +' ' +(orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCountry==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCountry) +' '  + (orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode ==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode )+' ' + +'\n'+'12,Installation City,'+(orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCity==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCity)+'\n'+'13,Installation State,'+(orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingState==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingState)+'\n'+'14,Installation Location Pincode,'+(orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode)+'\n'+'15,Delivery Completion Date,-'+'\n'+'16,Bill Start Date,-'+'\n'+'17,MRTG URL,-'+'\n'+'18,MRTG Username,-'+'\n'+'19,MRTG Password,-'+'\n'+'20,Billing Level,-'+'\n'+'21,One Time Charge,'+orderRecords[0].vlocity_cmt__OneTimeTotal__c+'\n'+'22,Annual Recurring Charge,'+orderRecords[0].ARTL_AnnualRecurringTotal__c+'\n'+'23,Contract Term,'+(orderRecords[0].vlocity_cmt__QuoteId__r.Contract.ContractTerm==null?0:orderRecords[0].vlocity_cmt__QuoteId__r.Contract.ContractTerm)+'\n'+'24,Bill Frequency,'+(orderRecords[0].account.vlocity_cmt__BillFrequency__c==null?'':orderRecords[0].account.vlocity_cmt__BillFrequency__c) +'\n'+'25,Project Manager Name,'+(orderRecords[0].vlocity_cmt__QuoteId__r.PM_Name__c==null?'':orderRecords[0].vlocity_cmt__QuoteId__r.PM_Name__c)+'\n'+'26,Project Manager Contact Number,'+(orderRecords[0].vlocity_cmt__QuoteId__r.PM_Phone__c==null?'':orderRecords[0].vlocity_cmt__QuoteId__r.PM_Phone__c) +'\n'+'27,Project Manager Email Id,'+(orderRecords[0].vlocity_cmt__QuoteId__r.PM_Email__c==null?'':orderRecords[0].vlocity_cmt__QuoteId__r.PM_Email__c) +'\n';
            if(accteammem!=null && accteammem.size()>0){
                csvFile = csvFile + '28,Account Manager/Sales Manager Name,'+accteammem[0].User.name+'\n'+'29,Account Manager/Sales Manager Contact Number,'+accteammem[0].User.MobilePhone+'\n'+'30,Account Manager/Sales Manager Email id,'+accteammem[0].User.Email+ '\n'+'31,Loopback IP with Subnet Mask,-'+'\n';
            }
        }
        integer i =31;
        List<String> availableproducts = new List<String>();
        for(QuoteLineItem quotelineitemrec:quotelineitems){
            availableproducts.add(quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode);
            Map<String,Object> attrselectedvalues = new Map<String,Object>();
            if(quotelineitemrec != null && quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode != null){
                if(quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_E_IIL') || quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_SECONDARY_LINK')){
                csvFile = csvFile + (i+=1) +',Circuit ID (LSI),'+(quotelineitemrec.ARTL_LSI__c==null?0:quotelineitemrec.ARTL_LSI__c) + '\n';
            }
            if(quotelineitemrec.vlocity_cmt__AttributeSelectedValues__c!=null){
                attrselectedvalues = (Map<String,Object>) JSON.deserializeUntyped(quotelineitemrec.vlocity_cmt__AttributeSelectedValues__c);
                if(quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_PRIMARY_LINK') || quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_SECONDARY_LINK')){
                    csvFile = csvFile + (i+=1) +',Bandwidth,'+attrselectedvalues.get('ATT_ACCESS_BANDWIDTH') + '\n'+ (i+1)+',Media,'+attrselectedvalues.get('ATT_MEDIA') + '\n'+ (i+2)+',Service Type,'+attrselectedvalues.get('ATT_SERVICE_TYPE') + '\n'+ (i+3)+',Connectivity Type,'+attrselectedvalues.get('ATT_ENTERPRISE_CONNECTIVITY_TYPE') + '\n';
                    i+=3;
                }
                else if(quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_ENTERPRISE_ICONNECTIVITY_ROUTERS')){
                    csvFile = csvFile + (i+1)+',Router Make,'+attrselectedvalues.get('ATT_ROUTER_MAKE') + '\n'+ (i+=1)+',Router Model,'+attrselectedvalues.get('ATT_ROUTER_MODEL') + '\n';
                }
                else if(quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_ICONNECTIVTY_LAN_IP')){
                    csvFile = csvFile + (i+=1)+',LAN IP with Subnet Mask,'+attrselectedvalues.get('ATT_LAN_IPV4_SUBNET_MASK')+ '\n';
                }
                else if(quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_ICONNECTIVITY_WAN_IP')){
                    csvFile = csvFile + (i+=1)+',WAN IP with Subnet Mask,'+attrselectedvalues.get('ATT_WAN_IPV4_SUBNET_MASK')  + '\n';
                }
                
                else if(quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_E_IIL') || quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_SECONDARY_LINK')){
                    List<XLI_Technical_Attribute__c> technicalRecords = [select id,Technical_Product__r.Name,Technical_Attribute__c from XLI_Technical_Attribute__c where Root_Quote_Line_Item__c =:quotelineitemrec.Id and(Technical_Product__r.Name = 'Internet Product Specification CFS' OR Technical_Product__r.Name = 'iConnectivity Routing Type CFS')];
                    
                    for(XLI_Technical_Attribute__c technicalrecord : technicalRecords){
                        if(technicalrecord.Technical_Product__r.Name =='Internet Product Specification CFS'){
                            if(technicalrecord.Technical_Attribute__c!=null){
                                availableproducts.add('Internet Product Specification CFS');
                                Map<String,Object> attrselectedvaluesfortechnicalproduct = (Map<String,Object>) JSON.deserializeUntyped(technicalrecord.Technical_Attribute__c);
                                String attributevalue = String.valueof(attrselectedvaluesfortechnicalproduct.get('CAF Number'));
                                csvFile = csvFile + (i+=1)+',CAF Number,'+attributevalue + '\n';
                            }
                            
                        }
                        else if(technicalrecord.Technical_Product__r.Name =='iConnectivity Routing Type CFS'){
                            if(technicalrecord.Technical_Attribute__c!=null){
                                availableproducts.add('Routing Protocol');
                                Map<String,Object> attrselectedvaluesfortechnicalproduct = (Map<String,Object>) JSON.deserializeUntyped(technicalrecord.Technical_Attribute__c);
                                String attributevalue = String.valueOf(attrselectedvaluesfortechnicalproduct.get('Routing Protocol'));
                                csvFile = csvFile + (i+=1)+',Routing Protocol,'+attributevalue + '\n';
                            }
                        }
                    }
                }
            }
            
            }
            
        }
        if(!availableproducts.contains('VEPC_ENTERPRISE_ICONNECTIVITY_ROUTERS')){
            csvFile = csvFile + (i+=1)+',Router Make,-' + '\n'+ (i+=1)+',Router Model,-'+ '\n';
        }
        if(!availableproducts.contains('VEPC_ICONNECTIVTY_LAN_IP')){
            csvFile = csvFile + (i+=1)+',LAN IP with Subnet Mask,-'+ '\n';
        }
        if(!availableproducts.contains('VEPC_ICONNECTIVITY_WAN_IP')){
            csvFile = csvFile + (i+=1)+',WAN IP with Subnet Mask,-' + '\n';
        }
        if(!availableproducts.contains('Internet Product Specification CFS')){
            csvFile = csvFile + (i+=1)+',CAF Number,-' + '\n';
        }
        if(!availableproducts.contains('iConnectivity Routing Type CFS')){
            csvFile = csvFile + (i+=1)+',Routing Protocol,-' + '\n';
        }
        String CsvToSend = AttachFile(csvFile,'Non Deemed LOC ILL',QuoteId);
        SendEmail(CsvToSend,toaddresses,QuoteId,AccountId,'Non Deemed LOC ILL E-mail','Welcome_Email');
        
    }
    public void generateAttachmentForNonDeemedLOCMPLSnewCircuitID( Map<String, Object> inputMap, Map<String, Object> outMap,Map<String, Object> options){
        String OrderId = String.valueOf(inputMap.get('OrderId'));
        List<Order> orderRecords = [Select vlocity_cmt__QuoteId__c,vlocity_cmt__QuoteId__r.QuoteNumber,vlocity_cmt__ParentOrderId__r.OrderNumber,OrderNumber,Account.name,AccountId,vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c,account.vlocity_cmt__PrimaryContactId__r.name, account.vlocity_cmt__PrimaryContactId__r.Email, account.vlocity_cmt__PrimaryContactId__r.MobilePhone, vlocity_cmt__DefaultServiceAccountId__r.ShippingStreet,vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode ,vlocity_cmt__DefaultServiceAccountId__r.ShippingCity, vlocity_cmt__DefaultServiceAccountId__r.ShippingState, vlocity_cmt__DefaultServiceAccountId__r.ARTL_Billing_Pincode__c,vlocity_cmt__DefaultServiceAccountId__r.ShippingCountry, vlocity_cmt__OneTimeTotal__c, ARTL_AnnualRecurringTotal__c, vlocity_cmt__QuoteId__r.Contract.ContractTerm, account.vlocity_cmt__BillFrequency__c,vlocity_cmt__QuoteId__r.PM_Name__c, vlocity_cmt__QuoteId__r.PM_Phone__c, vlocity_cmt__QuoteId__r.PM_Email__c from Order where Id=:OrderId Limit 1 ];
        String QuoteId = orderRecords[0].vlocity_cmt__QuoteId__c;
        String AccountId = orderRecords[0].AccountId;
        String AccountName = orderRecords[0].Account.name;
        String Quotenumber = orderRecords[0].vlocity_cmt__QuoteId__r.QuoteNumber;
        List<Id> quoteitemids = new List<Id>();
        List<AccountTeamMember> accteammem = [SELECT Id,User.name,User.Email, user.MobilePhone from AccountTeamMember where AccountId =:AccountId and TeamMemberRole = 'Voice KAM' ];
        for (OrderItem orderitemrecord: [select ARTL_QuoteLineItemId__c from orderitem where orderid =:OrderId]){
            quoteitemids.add(orderitemrecord.ARTL_QuoteLineItemId__c);
        }
        List<QuoteLineItem> quotelineitems = [select id, vlocity_cmt__AttributeSelectedValues__c,ARTL_LSI__c, vlocity_cmt__Product2Id__r.ProductCode from QuoteLineItem where id in:quoteitemids ];
        List<String> toaddresses = new List<String>();        
        //Creating Kick Off CSV file
        String csvFile;
        String csvColumnHeader = 'Sr. No.,Particulars,Values';
        List<String> csvRowValues = new List<String>();
        
        //Entering All the fields 
        if(csvColumnHeader != NULL)
        {
            csvFile = csvColumnHeader + '\n' +'1,Customer Name,'+AccountName+'\n'+'2,Customer PO Number,'+(orderRecords[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c==null?'':orderRecords[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c)+ '\n' +'3,Master Order Number,'+orderRecords[0].vlocity_cmt__ParentOrderId__r.OrderNumber+'\n'+'4,Sub Order Number,'+orderRecords[0].OrderNumber+'\n'+'5,Order Type,New'+'\n'+'6,Product Type,Internet'+'\n'+'7,Router Max. Bandwidth,-'+'\n'+'8,Local Contact Name,'+(orderRecords[0].account.vlocity_cmt__PrimaryContactId__r.name==null?'':orderRecords[0].account.vlocity_cmt__PrimaryContactId__r.name) +'\n'+'9,Local Contact Email,'+(orderRecords[0].account.vlocity_cmt__PrimaryContactId__r.Email==null?'':orderRecords[0].account.vlocity_cmt__PrimaryContactId__r.Email)+'\n'+'10,Local Contact Phone Number,'+orderRecords[0].account.vlocity_cmt__PrimaryContactId__r.MobilePhone+'\n'+'11,Installation Address,'+(orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingStreet==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingStreet) +' ' +(orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCity==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCity) +' ' +(orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingState==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingState) +' ' +(orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCountry==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCountry) +' '  + (orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode ==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode )+' ' + +'\n'+'12,Installation City,'+(orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCity==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCity)+'\n'+'13,Installation State,'+(orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingState==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingState)+'\n'+'14,Installation Location Pincode,'+(orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode==null?'':orderRecords[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode)+'\n'+'15,Delivery Completion Date,-'+'\n'+'16,Bill Start Date,-'+'\n'+'17,Infovista URL,-'+'\n'+'18,Infovista Username,-'+'\n'+'19,Infovista Password,-'+'\n'+'20,Billing Level,-'+'\n'+'21,One Time Charge,'+orderRecords[0].vlocity_cmt__OneTimeTotal__c+'\n'+'22,Annual Recurring Charge,'+orderRecords[0].ARTL_AnnualRecurringTotal__c+'\n'+'23,Contract Term,'+orderRecords[0].vlocity_cmt__QuoteId__r.Contract.ContractTerm+'\n'+'24,Bill Frequency,'+(orderRecords[0].account.vlocity_cmt__BillFrequency__c==null?'':orderRecords[0].account.vlocity_cmt__BillFrequency__c) +'\n'+'25,Project Manager Name,'+orderRecords[0].vlocity_cmt__QuoteId__r.PM_Name__c+'\n'+'26,Project Manager Contact Number,'+orderRecords[0].vlocity_cmt__QuoteId__r.PM_Phone__c +'\n'+'27,Project Manager Email Id,'+orderRecords[0].vlocity_cmt__QuoteId__r.PM_Email__c +'\n';
            if(accteammem!=null && accteammem.size()>0){
                csvFile = csvFile + '28,Account Manager/Sales Manager Name,'+accteammem[0].User.name+'\n'+'29,Account Manager/Sales Manager Contact Number,'+accteammem[0].User.MobilePhone+'\n'+'30,Account Manager/Sales Manager Email id,'+accteammem[0].User.Email+ '\n'+'31,Loopback IP with Subnet Mask,-'+'\n';
            }
        }
        integer i =31;
        List<String> availableproducts = new List<String>();
        for(QuoteLineItem quotelineitemrec:quotelineitems){
            availableproducts.add(quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode);
            Map<String,Object> attrselectedvalues = new Map<String,Object>();
            if(quotelineitemrec != null && quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode != null){
                if(quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_E_MPLS') || quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_SECONDARY_MPLS_LINK')){
                csvFile = csvFile + (i+=1) +',Circuit ID (LSI),'+(quotelineitemrec.ARTL_LSI__c==null?0:quotelineitemrec.ARTL_LSI__c) + '\n';
            }
            if(quotelineitemrec.vlocity_cmt__AttributeSelectedValues__c!=null){
                attrselectedvalues = (Map<String,Object>) JSON.deserializeUntyped(quotelineitemrec.vlocity_cmt__AttributeSelectedValues__c);
                if(quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_PRIMARY_MPLS_LINK') || quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_SECONDARY_MPLS_LINK')){
                    csvFile = csvFile + (i+=1) +',Bandwidth,'+attrselectedvalues.get('ATT_ACCESS_BANDWIDTH') + '\n'+ (i+=1)+',Media,'+attrselectedvalues.get('ATT_MEDIA') + '\n'+ (i+=1)+',Service Type,'+attrselectedvalues.get('ATT_SERVICE_TYPE') + '\n'+ (i+=1)+',Connectivity Type,'+attrselectedvalues.get('ATT_ENTERPRISE_CONNECTIVITY_TYPE') + '\n';
                }
                else if(quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_ENTERPRISE_ICONNECTIVITY_ROUTERS_MPLS')){
                    csvFile = csvFile + (i+=1)+',Router Make,'+attrselectedvalues.get('ATT_ROUTER_MAKE') + '\n'+ (i+=1)+',Router Model,'+attrselectedvalues.get('ATT_ROUTER_MODEL') + '\n';
                }
                else if(quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_ICONNECTIVTY_LAN_IP_MPLS')){
                    csvFile = csvFile + (i+=1)+',LAN IP with Subnet Mask,'+attrselectedvalues.get('ATT_LAN_IPV4_SUBNET_MASK')+ '\n';
                }
                else if(quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_ICONNECTIVTY_WAN_IP_MPLS')){
                    csvFile = csvFile + (i+=1)+',WAN IP CE with Subnet Mask,'+attrselectedvalues.get('ATT_WAN_IPV4_CE_SUBNET_MASK')  + '\n'+(i+=1)+',WAN IP PE with Subnet Mask,'+attrselectedvalues.get('ATT_WAN_IPV4_PE_SUBNET_MASK')  + '\n';
                }
                
                
                else if(quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_E_MPLS') || quotelineitemrec.vlocity_cmt__Product2Id__r.ProductCode.equals('VEPC_SECONDARY_MPLS_LINK')){
                    List<XLI_Technical_Attribute__c> technicalRecords = [select id,Technical_Product__r.Name,Technical_Attribute__c from XLI_Technical_Attribute__c where Root_Quote_Line_Item__c =:quotelineitemrec.Id and(Technical_Product__r.Name = 'Internet Product Specification CFS' OR Technical_Product__r.Name = 'iConnectivity Routing Type CFS')];
                    
                    for(XLI_Technical_Attribute__c technicalrecord : technicalRecords){
                        if(technicalrecord.Technical_Product__r.Name =='Internet Product Specification CFS'){
                            if(technicalrecord.Technical_Attribute__c!=null){
                                availableproducts.add('Internet Product Specification CFS');
                                Map<String,Object> attrselectedvaluesfortechnicalproduct = (Map<String,Object>) JSON.deserializeUntyped(technicalrecord.Technical_Attribute__c);
                                String attributevalue = String.valueof(attrselectedvaluesfortechnicalproduct.get('CAF Number'));
                                csvFile = csvFile + (i+=1)+',CAF Number,'+attributevalue + '\n';
                            }
                            
                        }
                        else if(technicalrecord.Technical_Product__r.Name =='iConnectivity Routing Type CFS'){
                            if(technicalrecord.Technical_Attribute__c!=null){
                                availableproducts.add('Routing Protocol');
                                Map<String,Object> attrselectedvaluesfortechnicalproduct = (Map<String,Object>) JSON.deserializeUntyped(technicalrecord.Technical_Attribute__c);
                                String attributevalue = String.valueOf(attrselectedvaluesfortechnicalproduct.get('Routing Protocol'));
                                csvFile = csvFile + (i+=1)+',Routing Protocol,'+attributevalue + '\n';
                            }
                        }
                    }
                }
            }
            
            }
            
        }
        if(!availableproducts.contains('VEPC_ENTERPRISE_ICONNECTIVITY_ROUTERS_MPLS')){
            csvFile = csvFile + (i+=1)+',Router Make,-' + '\n'+ (i+=1)+',Router Model,-'+ '\n';
        }
        if(!availableproducts.contains('VEPC_ICONNECTIVTY_LAN_IP_MPLS')){
            csvFile = csvFile + (i+=1)+',LAN IP with Subnet Mask,-'+ '\n';
        }
        if(!availableproducts.contains('VEPC_ICONNECTIVITY_WAN_IP_MPLS')){
            csvFile = csvFile + (i+=1)+',WAN IP CE with Subnet Mask,-' + '\n'+ (i+=1)+',WAN IP PE with Subnet Mask,-' + '\n';
        }
        if(!availableproducts.contains('Internet Product Specification CFS')){
            csvFile = csvFile + (i+=1)+',CAF Number,-' + '\n';
        }
        if(!availableproducts.contains('VEPC_ICONNECTIVITY_WAN_IP')){
            csvFile = csvFile + (i+=1)+',Routing Protocol,-' + '\n';
        }
        csvFile = csvFile + (i+=1) + ',VPN Type,-' + '\n' + + (i+=1) + ',Link Topology,' + '\n' +',VPN Name,' +'\n'+ (i+=1) + ',QoS Type,' + '\n';
        System.debug('csvFile'+csvFile);
        String CsvToSend = AttachFile(csvFile,'Non Deemed LOC MPLS',QuoteId);
        SendEmail(CsvToSend,toaddresses,QuoteId,AccountId,'Non Deemed LOC MPLS E-mail','Welcome_Email');
        
    }
    
    public String AttachFile(String CSVFile,String AttachmentName,String QuoteId){
        //Attaching CSV To Quote Record
        List<ContentVersion> ListOfDocuments = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion();
        cv.Title = AttachmentName;
        cv.PathOnClient = AttachmentName+'.csv';
        cv.IsMajorVersion = true;
        cv.VersionData = Blob.valueOf(csvFile);
        ListOfDocuments.add(cv);
        Insert ListOfDocuments;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        List<ContentDocumentLink> ListofContentDocumentLink = new List<ContentDocumentLink>();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = QuoteId;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        ListofContentDocumentLink.add(cdl);
        Insert ListofContentDocumentLink;
        List<String> idsToreturn = new List<id>();
        String kickOffAttachment = AttachmentName+'.csv';
        return kickOffAttachment;
        
    }
    public void SendEmail(String kickOffAttachment,List<String> toaddresses,String QuoteId,String AccountId,String Subject,String TemplateName ){
        
        //Sending Email to Customer With CSV as attachment
        Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
        efa1.setFileName(kickOffAttachment);
        efa1.setBody(Blob.valueOf(kickOffAttachment));
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:TemplateName  ];
        List<string> toAddress = new List<string>();
        toAddress = toaddresses;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(et.Id);
        mail.setToAddresses(toAddress);
        mail.setSubject(Subject);
        mail.setTargetObjectId(QuoteId);
        mail.setWhatId(AccountId);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        
        try {
            Messaging.sendEmail(allmsg,true);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    
}