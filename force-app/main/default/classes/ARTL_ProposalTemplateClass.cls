/******************************************************************************************************
* @Author:      
* @Company:     Salesforce (SFI)
* @Date:        
* @Reviewer:
* @Review Date:
* @Description: ARTL_ProposalTemplateClass for B2BExpressProposalTemplateDetailed and B2BExpressProposalTemplateSummary
* @Last Modified By: Prakash Sahu
* @Last Modified Date: 08/10/2023
*******************************************************************************************************/
global with sharing class ARTL_ProposalTemplateClass implements vlocity_cmt.VlocityOpenInterface2 
{   
    @TestVisible private static final String CONST_tokenMap                     = 'tokenMap';
    
    // Method invoked during OmniStudio DocGen that calls getTokenData
    global Object invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){
        try{
            Boolean success = false;
            if (methodName == 'getTokenData') {
                success = getTokenData(input, output, options);          
            } else {
                //  ATT_GenericErrorHandler.throwMethodNotFoundException(ARTL_ProposalTemplateClass.class, methodName);
            } return success;
        }catch(Exception ex){
            System.debug('Exception invokeMethod ------------- '+ex.getMessage()+'L No- '+ex.getLineNumber());
            return false;
        }   
    }    
    
    
    // Method that constructs the token map utilized in OmniStudio DocGen
    private Boolean getTokenData(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
        Id quoteId = (Id) input.get('contextId');
        Id templateId = (Id) input.get('templateId');
        System.debug('***Template Id: '+input.get('templateId'));
        vlocity_cmt__DocumentTemplate__c selectedTemplate = [SELECT Name FROM vlocity_cmt__DocumentTemplate__c WHERE Id = :templateId];
        String selectedTemplateName = selectedTemplate.Name;
        System.debug('***selectedTemplateName: '+selectedTemplateName);
        Boolean success = false;
        if (quoteId != Null) {
            // Query Quote Object - Return as single object
            Quote mainquoteobj = [SELECT Id,Account.Name,Name
                                  ,QuoteNumber,vlocity_cmt__OneTimeTotal__c,vlocity_cmt__RecurringTotal__c
                                  
                                  FROM Quote 
                                  WHERE Id=:quoteId];
            
            List<QuoteLineItem> lineitemlist = new List<QuoteLineItem>();
            
            // Construct Dynamic Query for QuoteLineItem Query
            String LineItemQuery = 'select id,product2.ARTL_LSIRequired__c,Quote.Name,Annual_Recurring_Charge__c,Annual_Recurring_Total__c,vlocity_cmt__AttributeSelectedValues__c,Quote.vlocity_cmt__OneTimeTotal__c,Quote.ARTL_Effective_Quote_Total__c,Quote.ARTL_AnnualRecurringTotal__c,Quote.vlocity_cmt__RecurringTotal__c,quote.QuoteNumber,vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c,vlocity_cmt__AssetReferenceId__c,vlocity_cmt__JSONAttribute__c,vlocity_cmt__QuoteGroupId__c,vlocity_cmt__QuoteMemberId__c,Product2id,Product2.Name,Product2.vlocity_cmt__IsLocationDependent__c,vlocity_cmt__QuoteGroupId__r.Name,vlocity_cmt__ParentItemId__c,vlocity_cmt__RootItemId__c,vlocity_cmt__OneTimeTotal__c,Quantity,vlocity_cmt__RecurringTotal__c,TotalPrice,Product2.vlocity_cmt__AttributeMetadata__c,Product2.Description,vlocity_cmt__EffectiveQuantity__c,Product2.ProductCode,vlocity_cmt__AttributeMetadataChanges__c from QuoteLineItem';
            String LineItemwhereClasue;
            LineItemwhereClasue = 'QuoteId=:quoteId';
            
            // Declare Variable - Set value for lineitemlist equal to results of Database.query() with Dynamic Query
            lineitemlist = Database.query(LineItemQuery + ' where ' + LineItemwhereClasue);
            system.debug('***Line Item List: '+lineitemlist);
            
            
            Map< String , List < QuoteLineItem > > memberAndRootItemMap = new Map< String , List < QuoteLineItem > >();
            Map< String , List< QuoteLineItem > > parentChildProdMap = new Map< String , List< QuoteLineItem > >();
            
            for(QuoteLineItem qLI: lineitemlist){
                if(qLI.vlocity_cmt__QuoteMemberId__r != null && qLI.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c != null && qLI.vlocity_cmt__ParentItemId__c == null){
                    if(memberAndRootItemMap != null && memberAndRootItemMap.containsKey(qLI.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c)){
                        memberAndRootItemMap.get(qLI.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c).add(qLI);
                    }else{
                        memberAndRootItemMap.put(qLI.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c, new List< QuoteLineItem > {qLI});
                    }
                }
                if(qLI.vlocity_cmt__ParentItemId__c != null){
                    if(parentChildProdMap != null && parentChildProdMap.containsKey(qLI.vlocity_cmt__ParentItemId__c)){
                        parentChildProdMap.get(qLI.vlocity_cmt__ParentItemId__c).add(qLI);
                    }else{
                        parentChildProdMap.put(qLI.vlocity_cmt__ParentItemId__c, new List< QuoteLineItem > {qLI});
                    }
                }
            }
            System.debug( 'memberAndRootItemMap---------'+memberAndRootItemMap);
            System.debug( 'parentChildProdMap---------'+parentChildProdMap);
            
            List< Map< String , Object > > clsQuoteList = new List< Map< String , Object > >();
            Map< String , Object > pW = new  Map< String , Object >();
            String offerName = '';
            
          //  Hierarchy JSON
          /*
           if(memberAndRootItemMap != null && memberAndRootItemMap.values().size() > 0){
                integer memberCount = 0;
                for(String memberName: memberAndRootItemMap.keySet() ){
                    // cls_QuoteMember alsQM = new cls_QuoteMember();
                    Map< String, Object > alsQM = new Map< String, Object>();
                    memberCount++;
                    alsQM.put('MemberName',memberName);
                    alsQM.put('SlNo',memberCount);
                    // alsQM.put('OneTimeTotal',1000);
                    // alsQM.put('RecurringTotal',2000);
                    // alsQM.MemberName = memberName;
                    // alsQM.OneTimeTotal = 1000;
                    // alsQM.RecurringTotal = 2000;
                    // List < cls_QuoteLineItemRoot > qIR = new List< cls_QuoteLineItemRoot >();
                    List< Map< String, Object > > qIR = new  List< Map< String, Object > >();
                    Decimal memberOTTotal = 0.0;
                    Decimal memberRTotal = 0.0;
                    Decimal memberAnnualRCharge = 0.0;
                    for(QuoteLineItem qLIRoot : memberAndRootItemMap.get(memberName)){
                        memberOTTotal = memberOTTotal + qLIRoot.vlocity_cmt__OneTimeTotal__c;
                        memberRTotal = memberRTotal + qLIRoot.vlocity_cmt__RecurringTotal__c;
                        memberAnnualRCharge = memberAnnualRCharge + qLIRoot.Annual_Recurring_Total__c;
                        // cls_QuoteLineItemRoot clsQRoot = new cls_QuoteLineItemRoot();
                        Map< String , Object > clsQRoot = new Map< String, Object >();
                        clsQRoot.put('ProductName',qLIRoot.Product2.Name);
                        clsQRoot.put('OneTimeTotal',qLIRoot.vlocity_cmt__OneTimeTotal__c);
                        clsQRoot.put('Quantity',qLIRoot.Quantity);
                        clsQRoot.put('RecurringTotal',qLIRoot.vlocity_cmt__RecurringTotal__c);
                        clsQRoot.put('AnnualRecurringCharge',qLIRoot.Annual_Recurring_Total__c);
                        
                        
                        // clsQRoot.ProductName = qLIRoot.Product2.Name;
                        // clsQRoot.OneTimeTotal = qLIRoot.vlocity_cmt__OneTimeTotal__c;
                        // clsQRoot.Quantity = qLIRoot.Quantity;
                        // clsQRoot.RecurringTotal = qLIRoot.vlocity_cmt__RecurringTotal__c;
                        // List< cls_QuoteLineItemChild > clsCList = new List< cls_QuoteLineItemChild >();
                        List< Map< String, Object > > clsCList = new List< Map< String, Object > >();
                        if(parentChildProdMap != null && parentChildProdMap.containsKey(qLIRoot.vlocity_cmt__AssetReferenceId__c)){
                            for(QuoteLineItem qLIChild : parentChildProdMap.get(qLIRoot.vlocity_cmt__AssetReferenceId__c)){
                                if(qLIChild.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c != null && qLIChild.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c == memberName){
                                    
                                    Map < String , Object > clsQC = new Map< String, Object >();
                                    clsQC.put('ProductName',qLIChild.Product2.Name);
                                    clsQC.put('OneTimeTotal',qLIChild.vlocity_cmt__OneTimeTotal__c);
                                    clsQC.put('Quantity',qLIChild.Quantity);
                                    clsQC.put('RecurringTotal',qLIChild.vlocity_cmt__RecurringTotal__c);
                                    clsQC.put('AnnualRecurringCharge',qLIChild.Annual_Recurring_Total__c);
                                    Map< String, String > attSelectedMap = new Map< String, String >();
                                    if(qLIChild.vlocity_cmt__AttributeSelectedValues__c != null){
                                        attSelectedMap = (Map< String, String >)JSON.deserialize(qLIChild.vlocity_cmt__AttributeSelectedValues__c, Map< String, String >.class);
                                    }
                                   if(attSelectedMap != null && attSelectedMap.keySet().size() >0 && attSelectedMap.containsKey('ATT_ACCESS_BANDWIDTH')){
                                    clsQC.put('Bandwidth',attSelectedMap.get('ATT_ACCESS_BANDWIDTH'));
                                    System.debug('attSelectedMap.get(ATT_ACCESS_BANDWIDTH)---'+attSelectedMap.get('ATT_ACCESS_BANDWIDTH'));
                                   }else{
                                    System.debug('Data not exist');
                                   }
                                   

                                    List< Map< String , Object > > clsQLSubCList = new List < Map< String , Object > >();
                                    if(parentChildProdMap != null && parentChildProdMap.containsKey(qLIChild.vlocity_cmt__AssetReferenceId__c)){
                                        for(QuoteLineItem qLISubClild : parentChildProdMap.get(qLIChild.vlocity_cmt__AssetReferenceId__c)){
                                            
                                            if(qLISubClild.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c != null && qLISubClild.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c == memberName){
                                                Map< String, Object > clsQLSubC = new Map< String, Object >();
                                                clsQLSubC.put('ProductName',qLISubClild.Product2.Name);
                                                clsQLSubC.put('OneTimeTotal',qLISubClild.vlocity_cmt__OneTimeTotal__c);
                                                clsQLSubC.put('Quantity',qLISubClild.Quantity);
                                                clsQLSubC.put('RecurringTotal',qLISubClild.vlocity_cmt__RecurringTotal__c);
                                                clsQLSubC.put('AnnualRecurringCharge',qLISubClild.Annual_Recurring_Total__c);
                                                clsQLSubCList.add(clsQLSubC);
                                                
                                            }   
                                        }
                                    }
                                    clsQC.put('QuoteLineItemSubChild',clsQLSubCList);
                                    clsCList.add(clsQC);
                                }
                            }
                        }
                        clsQRoot.put('QuoteLineItemChild',clsCList);
                        qIR.add(clsQRoot);
                    }
                    alsQM.put('OneTimeTotal',memberOTTotal);
                    alsQM.put('AnnualRecurringCharge',memberAnnualRCharge);
                    alsQM.put('RecurringTotal',memberRTotal);
                    alsQM.put('QuoteLineItemRoot',qIR);
                    clsQuoteList.add(alsQM);
                }
                
                pW.put('QuoteOneTimeTotal',lineitemlist[0].Quote.vlocity_cmt__OneTimeTotal__c);
                pW.put('QuoteRecurringTotal',lineitemlist[0].Quote.vlocity_cmt__RecurringTotal__c);
                pW.put('QuoteAnnualRecurringTotal',lineitemlist[0].Quote.ARTL_AnnualRecurringTotal__c);
                pW.put('QuoteNumber',lineitemlist[0].quote.QuoteNumber);
                pW.put('QuoteName',lineitemlist[0].quote.Name);
                pW.put('QuoteMember',clsQuoteList);  
                
            } */  








            
            // Single raw JSON
            if(memberAndRootItemMap != null && memberAndRootItemMap.values().size() > 0){
                integer memberCount = 0;
                for(String memberName: memberAndRootItemMap.keySet() ){
                   //  cls_QuoteMember alsQM = new cls_QuoteMember();
                    Map< String, Object > alsQM = new Map< String, Object>();
                    //  memberCount++;
                    //  alsQM.put('MemberName',memberName);
                    //  alsQM.put('SlNo',memberCount);
                    // alsQM.put('OneTimeTotal',1000);
                    // alsQM.put('RecurringTotal',2000);
                    // alsQM.MemberName = memberName;
                    // alsQM.OneTimeTotal = 1000;
                    // alsQM.RecurringTotal = 2000;
                    // List < cls_QuoteLineItemRoot > qIR = new List< cls_QuoteLineItemRoot >();
                    // List< Map< String, Object > > qIR = new  List< Map< String, Object > >();
                    // Decimal memberOTTotal = 0.0;
                    // Decimal memberRTotal = 0.0;
                    // Decimal memberAnnualRCharge = 0.0;
                    List< Map< String, Object > > clsCList = new List< Map< String, Object > >();
                    for(QuoteLineItem qLIRoot : memberAndRootItemMap.get(memberName)){
                        // memberOTTotal = memberOTTotal + qLIRoot.vlocity_cmt__OneTimeTotal__c;
                        // memberRTotal = memberRTotal + qLIRoot.vlocity_cmt__RecurringTotal__c;
                        // memberAnnualRCharge = memberAnnualRCharge + qLIRoot.Annual_Recurring_Total__c;
                        // cls_QuoteLineItemRoot clsQRoot = new cls_QuoteLineItemRoot();
                        // Map< String , Object > clsQRoot = new Map< String, Object >();
                        // clsQRoot.put('ProductName',qLIRoot.Product2.Name);
                        offerName = qLIRoot.Product2.Name;
                        // clsQRoot.put('OneTimeTotal',qLIRoot.vlocity_cmt__OneTimeTotal__c);
                        // clsQRoot.put('Quantity',qLIRoot.Quantity);
                        // clsQRoot.put('RecurringTotal',qLIRoot.vlocity_cmt__RecurringTotal__c);
                        // clsQRoot.put('AnnualRecurringCharge',qLIRoot.Annual_Recurring_Total__c);
                        
                        
                        // clsQRoot.ProductName = qLIRoot.Product2.Name;
                        // clsQRoot.OneTimeTotal = qLIRoot.vlocity_cmt__OneTimeTotal__c;
                        // clsQRoot.Quantity = qLIRoot.Quantity;
                        // clsQRoot.RecurringTotal = qLIRoot.vlocity_cmt__RecurringTotal__c;
                        // List< cls_QuoteLineItemChild > clsCList = new List< cls_QuoteLineItemChild >();
                      //  List< Map< String, Object > > clsCList = new List< Map< String, Object > >();

                      //check LSI products in offer level
                      if(qLIRoot.product2.ARTL_LSIRequired__c && qLIRoot.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c != null && qLIRoot.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c == memberName ){
                        Map< String, Object > alsQMC = new Map< String, Object>();
                        memberCount++;
                        alsQMC.put('SlNo',memberCount);
                        alsQMC.put('MemberName',memberName);
                        alsQMC.put('OfferName',qLIRoot.Product2.Name);

                       // Map < String , Object > clsQC = new Map< String, Object >();
                       alsQMC.put('ProductName',qLIRoot.Product2.Name);
                       alsQMC.put('OneTimeTotal',qLIRoot.vlocity_cmt__OneTimeTotal__c);
                       alsQMC.put('Quantity',qLIRoot.Quantity);
                       alsQMC.put('RecurringTotal',qLIRoot.vlocity_cmt__RecurringTotal__c);
                       alsQMC.put('AnnualRecurringCharge',qLIRoot.Annual_Recurring_Total__c);
                        Map< String, String > attSelectedMap = new Map< String, String >();
                        if(qLIRoot.vlocity_cmt__AttributeSelectedValues__c != null){
                            attSelectedMap = (Map< String, String >)JSON.deserialize(qLIRoot.vlocity_cmt__AttributeSelectedValues__c, Map< String, String >.class);
                        }
                       if(attSelectedMap != null && attSelectedMap.keySet().size() >0 && attSelectedMap.containsKey('ATT_ACCESS_BANDWIDTH')){
                        alsQMC.put('Bandwidth',attSelectedMap.get('ATT_ACCESS_BANDWIDTH'));
                        System.debug('attSelectedMap.get(ATT_ACCESS_BANDWIDTH)---'+attSelectedMap.get('ATT_ACCESS_BANDWIDTH'));
                       }else{
                        System.debug('Data not exist');
                       }
                       
                       if(attSelectedMap != null && attSelectedMap.keySet().size() >0 && attSelectedMap.containsKey('ATT_SERVICE_TYPE')){
                        alsQMC.put('ServiceType',attSelectedMap.get('ATT_SERVICE_TYPE'));
                        System.debug('attSelectedMap.get(ATT_SERVICE_TYPE)---'+attSelectedMap.get('ATT_SERVICE_TYPE'));
                       }else{
                        System.debug('Data not exist ATT_SERVICE_TYPE');
                       }
                       clsCList.add(alsQMC);
                      }
                     
                        if(parentChildProdMap != null && parentChildProdMap.containsKey(qLIRoot.vlocity_cmt__AssetReferenceId__c)){
                            for(QuoteLineItem qLIChild : parentChildProdMap.get(qLIRoot.vlocity_cmt__AssetReferenceId__c)){
                                if(qLIChild.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c != null && qLIChild.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c == memberName){
                                    Map< String, Object > alsQMC = new Map< String, Object>();
                                    memberCount++;
                                    alsQMC.put('SlNo',memberCount);
                                    alsQMC.put('MemberName',memberName);
                                    alsQMC.put('OfferName',qLIRoot.Product2.Name);

                                   // Map < String , Object > clsQC = new Map< String, Object >();
                                   alsQMC.put('ProductName',qLIChild.Product2.Name);
                                   alsQMC.put('OneTimeTotal',qLIChild.vlocity_cmt__OneTimeTotal__c);
                                   alsQMC.put('Quantity',qLIChild.Quantity);
                                   alsQMC.put('RecurringTotal',qLIChild.vlocity_cmt__RecurringTotal__c);
                                   alsQMC.put('AnnualRecurringCharge',qLIChild.Annual_Recurring_Total__c);
                                    Map< String, String > attSelectedMap = new Map< String, String >();
                                    if(qLIChild.vlocity_cmt__AttributeSelectedValues__c != null){
                                        attSelectedMap = (Map< String, String >)JSON.deserialize(qLIChild.vlocity_cmt__AttributeSelectedValues__c, Map< String, String >.class);
                                    }
                                   if(attSelectedMap != null && attSelectedMap.keySet().size() >0 && attSelectedMap.containsKey('ATT_ACCESS_BANDWIDTH')){
                                    alsQMC.put('Bandwidth',attSelectedMap.get('ATT_ACCESS_BANDWIDTH'));
                                    System.debug('attSelectedMap.get(ATT_ACCESS_BANDWIDTH)---'+attSelectedMap.get('ATT_ACCESS_BANDWIDTH'));
                                   }else{
                                    System.debug('Data not exist');
                                   }
                                   
                                   if(attSelectedMap != null && attSelectedMap.keySet().size() >0 && attSelectedMap.containsKey('ATT_SERVICE_TYPE')){
                                    alsQMC.put('ServiceType',attSelectedMap.get('ATT_SERVICE_TYPE'));
                                    System.debug('attSelectedMap.get(ATT_SERVICE_TYPE)---'+attSelectedMap.get('ATT_SERVICE_TYPE'));
                                   }else{
                                    System.debug('Data not exist ATT_SERVICE_TYPE');
                                   }

                                    // List< Map< String , Object > > clsQLSubCList = new List < Map< String , Object > >();
                                    // if(parentChildProdMap != null && parentChildProdMap.containsKey(qLIChild.vlocity_cmt__AssetReferenceId__c)){
                                    //     for(QuoteLineItem qLISubClild : parentChildProdMap.get(qLIChild.vlocity_cmt__AssetReferenceId__c)){
                                            
                                    //         if(qLISubClild.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c != null && qLISubClild.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__StreetAddress__c == memberName){
                                    //             Map< String, Object > clsQLSubC = new Map< String, Object >();
                                    //             clsQLSubC.put('ProductName',qLISubClild.Product2.Name);
                                    //             clsQLSubC.put('OneTimeTotal',qLISubClild.vlocity_cmt__OneTimeTotal__c);
                                    //             clsQLSubC.put('Quantity',qLISubClild.Quantity);
                                    //             clsQLSubC.put('RecurringTotal',qLISubClild.vlocity_cmt__RecurringTotal__c);
                                    //             clsQLSubC.put('AnnualRecurringCharge',qLISubClild.Annual_Recurring_Total__c);
                                    //             clsQLSubCList.add(clsQLSubC);
                                                
                                    //         }   
                                    //     }
                                    // }
                                  //  clsQC.put('QuoteLineItemSubChild',clsQLSubCList);
                                    clsCList.add(alsQMC);
                                  /// clsQuoteList.add(alsQMC);

                                }
                            }
                        }
                        // clsQRoot.put('QuoteLineItemChild',clsCList);
                        // qIR.add(clsQRoot);
                    }
                    // alsQM.put('OneTimeTotal',memberOTTotal);
                    // alsQM.put('AnnualRecurringCharge',memberAnnualRCharge);
                    // alsQM.put('RecurringTotal',memberRTotal);
                     alsQM.put('QuoteLineItemRoot',clsCList);
                     clsQuoteList.add(alsQM);
                }
                
                pW.put('QuoteOneTimeTotal',lineitemlist[0].Quote.vlocity_cmt__OneTimeTotal__c);
                pW.put('QuoteRecurringTotal',lineitemlist[0].Quote.vlocity_cmt__RecurringTotal__c);
                pW.put('QuoteAnnualRecurringTotal',lineitemlist[0].Quote.ARTL_AnnualRecurringTotal__c);
                Decimal totalAmount = lineitemlist[0].Quote.vlocity_cmt__OneTimeTotal__c + lineitemlist[0].Quote.vlocity_cmt__RecurringTotal__c + lineitemlist[0].Quote.ARTL_AnnualRecurringTotal__c;
                pW.put('QuoteNumber',lineitemlist[0].quote.QuoteNumber);
                pW.put('TotalAmount', lineitemlist[0].Quote.ARTL_Effective_Quote_Total__c);
                pW.put('OfferName',offerName);
                
                pW.put('QuoteName',lineitemlist[0].quote.Name);
                pW.put('QuoteMember',clsQuoteList);  
                
            }




            output.put(CONST_tokenMap, pW);
            system.debug('***Proposal Class Output: ' + JSON.serialize(output));
            success = true;
        }
        else{                
            success = false;   
            // ATT_GenericErrorHandler.throwMethodNotFoundException(ARTL_ProposalTemplateClass.class, 'getTokenData');
        }
        // Return success value as output of getTokenData
        return success;
    }
}