public with sharing class ARTL_MACD_CreateBillingStaging {
    public ARTL_MACD_CreateBillingStaging() {
        
    }
    public static void createBillingStaging(List< String > assetIdList, List< QuoteLineItem > qLIList){
        
        try{
            System.debug('createBillingStaging -- ');
            List< Asset > assetQLIList = [select id,ARTL_LSI__c, vlocity_cmt__OrderProductId__c,vlocity_cmt__BillingAccountId__c,vlocity_cmt__ServiceAccountId__c, ARTL_Purchase_Order__c, vlocity_cmt__AssetReferenceId__c, vlocity_cmt__OrderProductId__r.QuoteLineItemId, vlocity_cmt__OrderProductId__r.ARTL_QuoteLineItemId__c , vlocity_cmt__OrderProductId__r.QuoteLineItem.vlocity_cmt__BillingAccountId__c, vlocity_cmt__OrderProductId__r.QuoteLineItem.vlocity_cmt__ServiceAccountId__c from Asset where vlocity_cmt__AssetReferenceId__c in: assetIdList];
            Map< Id , Id > assetIdPOIdMap = new  Map< Id , Id >();
            Map< Id , Id > astIdBAIdMap = new  Map< Id , Id >();
            Map< Id , Id > astIdSAIdMap = new  Map< Id , Id >();
            Map< Id, Asset > assetMap = new Map< Id, Asset > ();
            if(assetQLIList !=  null && assetQLIList.size() > 0){
                
                for(Asset ast: assetQLIList){
                    if(ast.ARTL_Purchase_Order__c != null ){
                        assetIdPOIdMap.put(ast.Id,ast.ARTL_Purchase_Order__c);
                    }
                    if( ast.vlocity_cmt__BillingAccountId__c != null){
                        astIdBAIdMap.put(ast.Id , ast.vlocity_cmt__BillingAccountId__c);
                    }
                    if( ast.vlocity_cmt__ServiceAccountId__c != null){
                        astIdSAIdMap.put(ast.Id, ast.vlocity_cmt__ServiceAccountId__c);
                    }
                    assetMap.put(ast.Id,ast);
                    
                }
            }
            Map< Id, Quote > quoteMap = new Map< Id, Quote >();
            List< Id > quoteIdList = new List< Id >();
            for(QuoteLineItem qLI: qLIList){
                quoteIdList.add(qLI.QuoteId);
            }
            List< ARTL_Billing_Staging__c > existingBSList = new List< ARTL_Billing_Staging__c >();
            if(quoteIdList != null && quoteIdList.size() > 0){
                quoteMap = new Map< Id , Quote > ([select id, RecordType.DeveloperName from quote where id in :  quoteIdList]);
                existingBSList = [ Select id ,Quote__c, LSI__c from ARTL_Billing_Staging__c where Quote__c In: quoteIdList and LSI__c != null ];
            }
            Map< String , Id > exBSLSIAndIdMap = new Map< String , Id >();
            if(existingBSList != null && existingBSList.size() > 0){
                for(ARTL_Billing_Staging__c bs: existingBSList ){
                    exBSLSIAndIdMap.put(String.valueOf(bs.Quote__c) + String.valueOf(bs.LSI__c) , bs.id);
                }
            }



            Map <Id,  ARTL_Purchase_Order__c > pOMap = new Map< Id, ARTL_Purchase_Order__c >();
            //  Map< Id, ARTL_Purchase_Order__c > qLIIdPOMap = new Map< Id, ARTL_Purchase_Order__c >();
            if(assetIdPOIdMap != null && assetIdPOIdMap.values().size() > 0){
                pOMap = new Map< Id,ARTL_Purchase_Order__c >([Select id,Quote_Line_Item__c, ARTL_PO_Number__c, Start_Date__c, Tenure__c, End_Date__c, PO_Group__c from ARTL_Purchase_Order__c where Id in : assetIdPOIdMap.values()]);
                // if(pOList != null && pOList.size() > 0){
                //     for(ARTL_Purchase_Order__c pO: pOList){
                //         if(pO.Quote_Line_Item__c != null){
                //             qLIIdPOMap.put(pO.Quote_Line_Item__c, pO );
                //         }
                //     }
                // }
            }
            Map< Id, Account > billingAccountMap = new Map< Id, Account >();
            List< Id > allAccList = new List< Id >(); 
            List< Account > allBASAList = new List< Account > ();
            if(astIdBAIdMap != null && astIdBAIdMap.values().size() > 0){
                billingAccountMap = new Map< Id , Account > ([Select id,ParentId,BCP_DCP_Id__c,ARTL_Usage_Flag__c,Billing_Level__c,vlocity_cmt__BillFormat__c, Exempt_Reason__c,ARTL_GST_Applicable__c,ARTL_Store__c,ARTL_Taxation__c,ARTL_License_Company__c,ARTL_Legal_Entity__c,ARTL_Credit_Period__c,ARTL_Bill_Franchise_Tax_Code__c,ARTL_Bill_Type__c, BillingStreet, BillingState, BillingPostalCode, BillingCity, BillingCountry, AccountNumber, MD5Hash__c from Account where Id In : astIdBAIdMap.values()]);
                allAccList.addAll(astIdBAIdMap.values());
                allBASAList.addAll(billingAccountMap.values());
            }
            
            Map< Id, Account > serviceAccountMap = new Map< Id, Account >();
            if(astIdSAIdMap != null && astIdSAIdMap.values().size() > 0){
                serviceAccountMap = new Map< Id , Account > ([Select id,BCP_DCP_Id__c, ShippingStreet, ShippingState, ShippingPostalCode, ShippingCity, ShippingCountry from Account where Id In : astIdSAIdMap.values()]);
                allAccList.addAll(astIdSAIdMap.values());
                allBASAList.addAll(serviceAccountMap.values());
            }
            List< String > conIdList = new List< String >();
            List< String > conPreRelationIdList = new List< String > ();
            if(allBASAList != null && allBASAList.size() > 0){
                for(Account acc: allBASAList){
                    conPreRelationIdList.add(acc.BCP_DCP_Id__c);
                }
            }
            Map< Id, ContactPremiseRelation__c > conPreRelnMap =  new Map< Id, ContactPremiseRelation__c >();
            if(conPreRelationIdList != null && conPreRelationIdList.size() > 0){
                conPreRelnMap = new Map< Id,ContactPremiseRelation__c> ( [ select id, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Phone, Contact__r.Email from ContactPremiseRelation__c where Id IN: conPreRelationIdList ]);
            }

            


            // Map< Id, Contact > conMap = new Map < Id, Contact >();
            // if(conIdList != null && conIdList.size() > 0){
            //     conMap = new Map< Id, Contact >([Select Id, firstname, lastname, email, phone, accountId from Contact where Id In: conIdList]);
            // }
            // Map< Id , Contact > accIdConMap = new Map< Id, Contact >();
            // for(Contact con: conList){
            //     if(con.AccountId != null){
            //         accIdConMap.put(con.AccountId, con);
            //     }
            // }
            
            List< ARTL_Billing_Staging__c > bStgListToInsert = new List< ARTL_Billing_Staging__c >();
            
            for(QuoteLineItem qLI: qLIList){
                if(qLI.vlocity_cmt__AssetId__c != null && qLI.ARTL_LSI__c != null && quoteMap != null && quoteMap.containskey(qLI.QuoteId) && quoteMap.get(qLI.QuoteId).RecordType.DeveloperName == 'EnterpriseQuote' && (exBSLSIAndIdMap == null || (exBSLSIAndIdMap != null && !exBSLSIAndIdMap.containsKey(String.valueOf(qLI.QuoteId) + String.valueOf(qLI.ARTL_LSI__c)) )) ){
                    ARTL_Billing_Staging__c bS = new ARTL_Billing_Staging__c();
                    if(assetIdPOIdMap != null && assetIdPOIdMap.containsKey(qLI.vlocity_cmt__AssetId__c)){
                        if(pOMap != null && pOMap.containsKey(assetIdPOIdMap.get(qLI.vlocity_cmt__AssetId__c))){
                            bS.PO_Start_Date__c = pOMap.get(assetIdPOIdMap.get(qLI.vlocity_cmt__AssetId__c)).Start_Date__c;
                            //Tenure__c editted by Prabanch since the Tenure__c field datatype ic changed
                            bS.PO_Terms_Years__c = pOMap.get(assetIdPOIdMap.get(qLI.vlocity_cmt__AssetId__c)).Tenure__c;
                            bS.ARTL_PO_Group_Id__c = pOMap.get(assetIdPOIdMap.get(qLI.vlocity_cmt__AssetId__c)).PO_Group__c;
                            bS.PO__c = pOMap.get(assetIdPOIdMap.get(qLI.vlocity_cmt__AssetId__c)).ARTL_PO_Number__c;
                            bS.Quote_Line_Item__c = pOMap.get(assetIdPOIdMap.get(qLI.vlocity_cmt__AssetId__c)).Quote_Line_Item__c;
                        }
                    }
                    if(astIdBAIdMap != null && astIdBAIdMap.containsKey(qLI.vlocity_cmt__AssetId__c)){
                        if(billingAccountMap != null && billingAccountMap.containsKey(astIdBAIdMap.get(qLI.vlocity_cmt__AssetId__c))){
                            Account tBA = billingAccountMap.get(astIdBAIdMap.get(qLI.vlocity_cmt__AssetId__c));
                            
                            bS.Billing_Account_Id__c = tBA.Id;
                            bS.Billing_Street__c = tBA.BillingStreet;
                            bS.Billing_State__c = tBA.BillingState;
                            bS.Billing_PinCode__c = tBA.BillingPostalCode;
                            bS.Billing_City__c = tBA.BillingCity;
                            bS.Billing_Country__c = tBA.BillingCountry;
                            bS.Billing_Account_Number__c = tBA.AccountNumber; 
                            bS.Bill_Franchise_Tax_Code__c = tBA.ARTL_Bill_Franchise_Tax_Code__c;   
                            bS.Bill_Type__c = tBA.ARTL_Bill_Type__c;
                            bS.Credit_Period__c = tBA.ARTL_Credit_Period__c;
                            bS.Legal_Entity__c = tBA.ARTL_Legal_Entity__c;
                            bS.License_Company__c = tBA.ARTL_License_Company__c;
                            bS.Taxation__c = tBA.ARTL_Taxation__c;
                            bS.Store__c = tBA.ARTL_Store__c;
                            bS.Billing_GST_Applicable_for_Billing__c = tBA.ARTL_GST_Applicable__c;
                            bS.StandardReasonforTaxExemption__c = tBA.Exempt_Reason__c;
                            bS.Bill_Format__c = tBA.vlocity_cmt__BillFormat__c;
                            bS.Billing_Level__c = tBA.Billing_Level__c;
                           bS.NBA_Account_Number__c = tBA.ParentId;

                           if(tBA.ARTL_Usage_Flag__c != null && tBA.ARTL_Usage_Flag__c.isNumeric()){
                               bS.Usage_Flag__c = Decimal.valueOf(tBA.ARTL_Usage_Flag__c); 
                           }

                            
                            
                            
                            if(tBA.BCP_DCP_Id__c != null && conPreRelnMap != null && conPreRelnMap.containsKey(tBA.BCP_DCP_Id__c)){
                                
                                bS.BCP_Id__c = tBA.BCP_DCP_Id__c;
                                bS.BCP_First_Name__c = conPreRelnMap.get(tBA.BCP_DCP_Id__c).Contact__r.firstname;
                                bS.BCP_Last_Name__c = conPreRelnMap.get(tBA.BCP_DCP_Id__c).Contact__r.lastname;
                                bS.BCP_Email__c = conPreRelnMap.get(tBA.BCP_DCP_Id__c).Contact__r.Email;
                                bS.BCP_Phone__c = conPreRelnMap.get(tBA.BCP_DCP_Id__c).Contact__r.Phone;
                            }
                        }
                    }
                    
                    
                    if(astIdSAIdMap != null && astIdSAIdMap.containsKey(qLI.vlocity_cmt__AssetId__c)){
                        if(serviceAccountMap != null && serviceAccountMap.containsKey(astIdSAIdMap.get(qLI.vlocity_cmt__AssetId__c))){
                            Account tSA = serviceAccountMap.get(astIdSAIdMap.get(qLI.vlocity_cmt__AssetId__c));
                            bS.Shipping_Street__c = tSA.ShippingStreet;
                            bS.Shipping_State__c = tSA.ShippingState;
                            bS.Shipping_PinCode__c = tSA.ShippingPostalCode;
                            bS.Shipping_City__c = tSA.ShippingCity;
                            bS.Shipping_Country__c = tSA.ShippingCountry;
                            if(tSA.BCP_DCP_Id__c != null && conPreRelnMap != null && conPreRelnMap.containsKey(tSA.BCP_DCP_Id__c)){
                                
                                bS.DCP_Id__c = tSA.BCP_DCP_Id__c;
                                bS.DCP_First_Name__c = conPreRelnMap.get(tSA.BCP_DCP_Id__c).Contact__r.firstname;
                                bS.DCP_Last_Name__c = conPreRelnMap.get(tSA.BCP_DCP_Id__c).Contact__r.lastname;
                                bS.DCP_Email__c = conPreRelnMap.get(tSA.BCP_DCP_Id__c).Contact__r.Email;
                                bS.DCP_Phone__c = conPreRelnMap.get(tSA.BCP_DCP_Id__c).Contact__r.Phone;
                            }
                        }
                    }

                    if(assetMap != null && assetMap.containsKey(qLI.vlocity_cmt__AssetId__c)){
                        bS.LSI__c = String.valueOF(assetMap.get(qLI.vlocity_cmt__AssetId__c).ARTL_LSI__c);
                    }
                    
                    bS.Quote__c = qLI.QuoteId;
                   // bS.Quote_Line_Item__c = qLI.Id;
                    bS.Quote_Member__c = qLI.vlocity_cmt__QuoteMemberId__c;
                    bStgListToInsert.add(bS);
                }
            }
            System.debug('bStgListToInsert---'+bStgListToInsert);
            if(bStgListToInsert != null && bStgListToInsert.size() > 0){
                insert bStgListToInsert;
            }
        }catch(Exception ex){
            System.debug('Exception ARTL_MACD_CreateBillingStaging - createBillingStaging - Msg - '+ex.getMessage()+' L No- '+ex.getLineNumber());
        }
        
        
        
    }
    
}