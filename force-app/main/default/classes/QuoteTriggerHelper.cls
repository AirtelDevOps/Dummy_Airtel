/*------------------------------------------------------Class Signature-------------------------------------------------------
Class Name		: QuoteTriggerHelper
Purpose			: Create Master Order and Sub-Order records when Quote Status is 'OV Approved'.
Generate LSI when Quote Status is 'OV Approved'
Nested Classes  : 
Date 			: 05-October-2023
-------------------------------------------------------------------------------------------------------------------------------*/
public without Sharing class QuoteTriggerHelper {
    
    //private Map<Id, vlocity_cmt__QuoteMember__c> oldMap;
    
    public static void runQuoteAfterTriggerEvents(List<Quote> qlist, Map<Id, Quote> oldMap){
        
        
        string qStatus, validationStatus, oldValidationStatus;
        String IPName = 'b2bExpress_SalesOrder';
        Id accountId,opportunityId,quoteId;
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>();
        List<Quote> customNotifyQuoteList = new List<Quote>();
        String READY_FOR_ORDER='Ready for Order';
        
        try{
            system.debug('runQuoteAfterTriggerEvent qlist=>'+JSON.serializePretty(qlist));
            for(Quote q:qlist){ 
                
                //kb: Added by Prabanch to check if the quote status is DOA Approved or Rejected and send notification to KAM accordingly
                qStatus=(string)q.get('Status');
                String oldQuoteStatus = (String)oldMap.get(q.Id).get('Status');
                validationStatus = (String)q.get('vlocity_cmt__ValidationStatus__c');
                oldValidationStatus = (String)oldMap.get(q.Id).get('vlocity_cmt__ValidationStatus__c');
                
                // Check if there's a change in ValidationStatus
                system.debug('validationStatus==>'+validationStatus);
                system.debug('oldValidationStatus==>'+oldValidationStatus);
                if (validationStatus == READY_FOR_ORDER && validationStatus != oldValidationStatus) { 
                    //if(qStatus=='OV Approved'){
                    //create sub order and Master orders
                    quoteId=(Id)q.Id;
                    accountId=(Id)q.get('AccountId');
                    opportunityId=(Id)q.get('OpportunityId');
                    inputMap = new Map<String, Object>();
                    inputMap.put('Quote',new Map<string,object>{'AccountId'=>accountId,'Id'=>quoteId,'OpportunityId'=>opportunityId});
                    Object result = vlocity_cmt.IntegrationProcedureService.runIntegrationService(IPName, inputMap,optionsMap);
                    outputMap.put('Result', result);
                    
                    //Generate LSI and populate that in QLI
                    //updateLSI(quoteId);
                }
                
                //Check if quote status is changed to DOA Approved or DOA Rejected or 
                if(qStatus != oldQuoteStatus && (qStatus == 'DOA Rejected' || qStatus == 'DOA Approved' || qStatus == 'OV Approved' || qStatus == 'OV Rejected')){
                    customNotifyQuoteList.add(q);
                }
                
            }
            if(!customNotifyQuoteList.isEmpty()){
               sendCustomNotification(customNotifyQuoteList);
            }
            
        }catch(Exception e){
            System.debug('Exception in class::QuoteTriggerHelper and method::createOrder @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
    }
    public static void runQuoteBeforeTriggerEvents(List<Quote> qlist, Map<id,Quote> oldQuoteRec){
        String qStatus;
        Id quoteId;
        Boolean doaApproved;
        
        List<QuoteLineItem> allQLIList=new List<QuoteLineItem>();
        try{
            system.debug('runQuoteBeforeTriggerEvents qlist=>'+JSON.serializePretty(qlist));
            for(Quote quoteObj:qlist){              
                qStatus=(string)quoteObj.get('status');
                doaApproved=quoteObj.ARTL_DOAApproved__c; 
                /*
                if(qStatus=='Proposal Sent') {
                    quoteId=(Id)quoteObj.Id;
                    //Generate LSI and populate that in QLI	
                    updateLSI(quoteId,allQLIList);
                }*/
                if(oldQuoteRec.get(quoteObj.id).Status != quoteObj.Status && quoteObj.Status == System.label.ARTL_Quote_Status_Proposal_Sent){
                    updateLSI((Id)quoteObj.Id,allQLIList);                   
                }
                
                // to update assigned date based on status changed to ov assigned
                if(oldQuoteRec.get(quoteObj.id).Status != quoteObj.Status && quoteObj.Status == System.label.ARTL_Quote_Status_Assigned_to_OV  ){
                    quoteObj.ARTL_OV_Assigned_Date__c = system.now();                    
                }
                // to update assigned date based on status changed to ov approved
                 /*
                if(oldQuoteRec.get(quoteObj.id).Status != quoteObj.Status && quoteObj.Status == System.label.ARTL_Quote_Status_OV_Approved){
                    quoteObj.ARTL_OVApprovedDate__c = system.now();                    
                }*/

                // update 'Address and Feasibility Status' to '	Feasibility in Progress' when Quote status changed to 'Feasibility in Progress'
                if(oldQuoteRec.get(quoteObj.id).Status != quoteObj.Status && quoteObj.Status == System.label.ARTL_Quote_Status_Feasibility_in_Progress  ){
                    quoteObj.ARTL_Address_and_Feasibility_Status__c = 'Feasibility in Progress';                  
                }

                // update 'Address and Feasibility Status' to 'Feasibility Completed' when Quote status changed to 'Feasibility Completed'
                if(oldQuoteRec.get(quoteObj.id).Status != quoteObj.Status && quoteObj.Status == System.label.ARTL_Quote_Status_Feasibility_Completed  ){
                    quoteObj.ARTL_Address_and_Feasibility_Status__c = 'Feasibility Completed';                  
                }

               /* if(oldQuoteRec.get(quoteObj.id).Status != quoteObj.Status && quoteObj.Status == System.label.ARTL_Quote_Status_OV_Approved && quoteObj.ARTL_OV_Assigned_Date__c != Null){
                    quoteObj.ARTL_OV_Time_Spent_In_Days__c = Date.Today().Day() - quoteObj.ARTL_OV_Assigned_Date__c.day();
                }  //OV time Spent in days
                */
                if(quoteObj.ARTL_DOAApproved__c && oldQuoteRec.get(quoteObj.id).ARTL_DOAApproved__c != quoteObj.ARTL_DOAApproved__c){
                    System.debug('DOA Approval in Progress');
      
                    String approver=invokeCapexApproval(quoteObj);
                    if(string.isBlank(approver)){
                        system.debug('before update sts=>'+quoteObj);
                        //quote updateQuote=[SELECT Id,Status from Quote WHERE Id=:q.Id LIMIT 1];
                        quoteObj.Status='DOA Approved';
                        quoteObj.ARTL_DOAApproved__c=False;
                        system.debug('after update sts=>'+quoteObj);
                        //update updateQuote;
                        //System.debug('updateQuote=>'+updateQuote);
                    }
					system.debug('updated quote=>'+quoteObj);
                }
                system.debug('updated capex=>'+JSON.serializePretty(qlist));
            }
            system.debug('allQLIList=>'+JSON.serializePretty(allQLIList));
            //Updating LSI on QLI
            update allQLIList;
        }Catch(Exception e){
            System.debug('Exception in class::QuoteTriggerHelper and method::createOrder @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
    }
    
    
    public static void updateLSI(Id quoteId,List<QuoteLineItem> allQLIList){
        
        List<quotelineitem> qliList;
        Boolean sdwanHaveLSI=False;
        try{
            
            qliList=[select id,ARTL_LSI__c,Product2Id,product2.Name,product2.ProductCode,product2.ARTL_LSIRequired__c from quotelineitem  where quoteId=:quoteId and product2.ARTL_LSIRequired__c = true and ARTL_LSI__c = null];
			system.debug('qliList for LSI=>'+qliList);
            if(!qliList.isEmpty() && qliList != null){
                for(QuoteLineItem qli:qliList){
                    if(!sdwanHaveLSI && qli.product2.ProductCode =='beb3d29d-c914-43d1-8082-81ccfd7b6223'){
                        generateLSI(qli);
                        allQLIList.add(qli);
                        sdwanHaveLSI=True;
                    }else if(qli.product2.ProductCode !='beb3d29d-c914-43d1-8082-81ccfd7b6223'){
                        generateLSI(qli);
                        allQLIList.add(qli);
                    }
                }
                system.debug('qliList after LSI generation=>'+JSON.serializePretty(allQLIList));
                
            }
            
            
        }catch(Exception e){
            System.debug('Exception in class::QuoteTriggerHelper and method::updateLSI @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
    }
    public static void generateLSI(quotelineitem qli){
        string prodCode,year,month,day,hour,minute,LSIDateFormat,LSIAutoNumber,strippedYear;
        Datetime todayDate;
        try{
            todayDate = Datetime.now();
            year =(string.valueOf(todayDate.year())).right(2);
            month = string.valueOf(todayDate.month());
            if(month.length()==1){
                month='0'+month;
            }
            day = string.valueOf(todayDate.day());
            if(day.length()==1){
                day='0'+day;
            }
            LSIDateFormat=day+month+year;
            LSIAutoNumber=string.valueOf((Integer)Math.floor(Math.random() * 90000) + 10000);
            
            
            qli.ARTL_LSI__c=Decimal.valueOf('8000'+LSIDateFormat+LSIAutoNumber);
        }catch(Exception e){
            System.debug('Exception in class::QuoteTriggerHelper and method::generateLSI @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
    }
    public static void createBASABatch(Set<Id> quoteIds){
        try{          
            if(quoteIds.size()>0){
                //Database.executeBatch(new ARTL_BACreationPreProcessBatch(quoteIds), 1); 
                System.enqueueJob(new ARTL_BASACreationBatchQueueable(quoteIds));
            }    
        }
        catch(Exception e){
            System.debug('Exception in class::QuoteTriggerHelper and method::runCreateBASABatch @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
    }
    public static String invokeCapexApproval(Quote quoteObj){
        List<QuoteLineItem> qliList;
        Map<String,String> productCodeToApproverMap;
        String productCode;
        String approver;
        try{
            
            //Fetch Matrix records and construct productCode to Approver map
            productCodeToApproverMap=fetchMatrixRecords('Capex Matrix V1');
            
            if(quoteObj.ARTL_QNeedCapexApproval__c){
                //Query QLI records
                qliList=fetchQLI(quoteObj.Id);
                if(qliList != null && !qliList.isEmpty()){
                    for(QuoteLineItem qli:qliList){
                        productCode=qli.Product2.ProductCode;
                        if(productCodeToApproverMap.containsKey(productCode)){
                            approver=productCodeToApproverMap.get(productCode);
                            system.debug('approver==>'+approver);
                        }
                    }
                }
            }
            
            System.debug('Capex Approver=>'+approver);
            
            if(!String.isBlank(approver)){
                List<user> approverUser=[SELECT Id FROM USER WHERE Name=: approver];
                Id approverId=approverUser[0].Id;
                Id submittingUser=UserInfo.getUserId();
                ARTL_ApprovalProcessUtility.invokeApprovalProcess(quoteObj.Id,'Submitting request for Capex approval.',submittingUser,approverId,'Capex_Quote_Approval',True); 
            }
            
        }catch(Exception e){
            System.debug('Exception in class::QuoteTriggerHelper and method::invokeCapexApproval @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
        return approver;
    }
    public static Map<String,String> fetchMatrixRecords(String matrixVersionName){
        //String capexMatrixName='Capex Matrix V1';
        //String capexMatrixName;
        List<CalculationMatrixVersion> matrixVersionRec;
        List<CalculationMatrixRow> matrixRecords;
        Map<String,Object> inputJSON;
        Map<String,Object> outputJSON;
        
        
        Map<String,String> productCodeToApproverMap=new Map<String,String>();
        try{
            matrixVersionRec = [SELECT Id FROM CalculationMatrixVersion WHERE Name=:matrixVersionName LIMIT 1];
            system.debug('matrixVersionRec==>'+matrixVersionRec);
            if (!matrixVersionRec.isEmpty() && matrixVersionRec != null) {
                matrixRecords = [SELECT Id, InputData, OutputData FROM CalculationMatrixRow WHERE calculationMatrixVersionId=: matrixVersionRec[0].Id];
                if (!matrixRecords.isEmpty() && matrixRecords != null) {
                    for(CalculationMatrixRow row:matrixRecords){
                        inputJSON=(Map<String,Object>)JSON.deserializeUntyped(row.InputData);
                        outputJSON=(Map<String,Object>)JSON.deserializeUntyped(row.OutputData);
                        
                        productCodeToApproverMap.put((String)inputJSON.get('ProductCode'),(String)outputJSON.get('ApproverName'));
                    }
                }
            }
            system.debug('productCodeToApproverMap=>'+JSON.serializePretty(productCodeToApproverMap));
        }catch(Exception e){
            System.debug('Exception in class::QuoteTriggerHelper and method::fetchCapexMatrixRecords @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
        return productCodeToApproverMap;
    }
    public static List<QuoteLineItem> fetchQLI(Id quoteId){
        String query;
        List<QuoteLineItem> qliList;
        try{
            query='SELECT Id, Product2.Name, Product2.ProductCode, ARTL_NeedCapexApproval__c, Annual_Recurring_Charge__c FROM QuoteLineItem WHERE QuoteId = :quoteId AND ARTL_NeedCapexApproval__c = true';
            qliList=Database.query(query);
            system.debug('Testing qliList=>'+JSON.serializePretty(qliList));
            
        }catch(Exception e){
            System.debug('Exception in class::QuoteTriggerHelper and method::fetchCapexMatrixRecords @line number'+e.getLineNumber()+' ['+e.getMessage()+']');
        }
        return qliList;
    }
    
    /**
     * Name: sendCustomNotification
     * Description: used to send notification once DOA approval or OV approval is completed
     * Author: Prabanch Nath
     */
    public static void sendCustomNotification (List<Quote> quoteList){
        //KB: As of now bulk notification send is not supported in Salesforce like messaging
        Id typeId = [SELECT Id,CustomNotifTypeName  FROM CustomNotificationType WHERE CustomNotifTypeName = 'SendDOAApprovalTaskToKAM'].Id;
        
        for(quote qt : quoteList){
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
			notification.setTitle('Please click here to navigate to the quote');                
            if(qt.Status == 'DOA Approved'){
                notification.setBody('DOA Approval has been approved!');
            }
            else if(qt.Status == 'DOA Rejected'){
                notification.setBody('DOA Approval has been rejected!');
            }
            else if(qt.Status == 'OV Approved'){
                notification.setBody('OV Approval has been approved!');
            }
            else if(qt.Status == 'OV Rejected'){
                notification.setBody('OV Approval has been rejected!');
            }
            notification.setSenderId(Userinfo.getUserId());
            notification.setNotificationTypeId(typeId);
            notification.setTargetId(qt.Id);
            notification.send(new Set<String>{qt.OwnerId});
        }

    }
    
   public static void interOrderDepency(List<quote> quoteList , Map<Id, Quote> oldQuoteMap){
        List<Id> quoteIds = new List<Id>();
        List<String> attrCodes = new list<String>{'ATT_VPN_TYPE','ATT_VPN_NAME','ATT_VPN_TOPOLOGY','ATT_SERVICE_TYPE','ATT_PORT_BANDWIDTH','ATT_ROUTING_TYPE','ATT_ROUTING_PROTOCOL','ATT_MEDIA'};
        for(Quote qt : quoteList){  
            quoteIds.add(qt.Id);
        }
        system.debug('quoteIds  ----> ' + quoteIds);
        List<QuoteLineItem> qliList = [Select Id,ARTL_Media__c,ARTL_4GUniqueKey__c,vlocity_cmt__AttributeSelectedValues__c,Product2.Name,Quote.Account.AccountNumber,Quote.Account.Name From QuoteLineItem where QuoteId IN :quoteIds AND (Product2.Name = 'Primary MPLS Link' OR Product2.Name = 'Secondary MPLS Link')];
        system.debug('qliList  ------> ' + qliList);
        boolean is4G = false;
        Set<Id> qliIds = new Set<Id>();
        Set<Id> relOIIds = new Set<Id>();
        for(QuoteLineItem qli : qliList){
            if((qli.Product2.Name == 'Primary MPLS Link' || qli.Product2.Name == 'Secondary MPLS Link') && (qli.ARTL_Media__c == '4G' || qli.ARTL_Media__c == '5G')){
                    is4G = true;
                    relOIIds.add(qli.Id);
            }
        }
        system.debug('relOIIds ------>' + relOIIds);
        List<vlocity_cmt__QuoteLineItemRelationship__c> qprelList = [Select Id , vlocity_cmt__RelatedQuoteLineItemId__c , vlocity_cmt__QuoteLineItemId__c From vlocity_cmt__QuoteLineItemRelationship__c where vlocity_cmt__RelatedQuoteLineItemId__c IN :relOIIds];
        system.debug('qprelList ------>' + qprelList);
        Set<Id> qpQLIIds = new Set<Id>();
        Map<String , String> qliRelMap = new Map<String , String>();
        for(vlocity_cmt__QuoteLineItemRelationship__c qp : qprelList){
            qpQLIIds.add(qp.vlocity_cmt__QuoteLineItemId__c);
            qliRelMap.put(qp.vlocity_cmt__QuoteLineItemId__c , qp.vlocity_cmt__RelatedQuoteLineItemId__c);
        }
        List<QuoteLineItem> qliRelList = [Select Id , ARTL_4GUniqueKey__c From QuoteLineItem where Id IN :qpQLIIds];
       //List<QuoteLineItem> qliRelList = [Select Id , ARTL_4GUniqueKey__c From QuoteLineItem where Id IN :relOIIds];
        system.debug('qliRelList ------->' + qliRelList);
        List<QuoteLineItem> qlitoUpdate = new List<QuoteLineItem>();
        Map<String , String> uniqueKeyMap = new Map<String , String>();
        for(QuoteLineItem qli : qliList){
            Map<String, Object> xlvalue = (Map<String, Object>) JSON.deserializeUntyped(qli.vlocity_cmt__AttributeSelectedValues__c); 
            String attrString = '';
            Boolean isNew = false;
            for(String str : attrCodes){
                system.debug('str ----->' + str);
                system.debug('attrString ----->' + attrString);
                if(is4G && xlvalue.get(str) != null){
                    if(str == 'ATT_VPN_TYPE' && xlvalue.get(str) == 'New'){
                        isNew = true;
                    }
                    if(str == 'ATT_VPN_NAME' && isNew != true){
                        attrString = attrString +xlvalue.get(str);
                    }
                    if(str != 'ATT_VPN_NAME'){
                        attrString = attrString + xlvalue.get(str);
                    }
                }
            }
            if(is4G){
                attrString = attrString + qliList[0].Quote.Account.AccountNumber + qliList[0].Quote.Account.Name;
                system.debug('attrString -------> ' + attrString);
                //attrString = attrString.left(attrString.length()-2)+attrString.right(1); 
                uniqueKeyMap.put(qli.Id , attrString);
            }
        }
        
        for(QuoteLineItem qli : qliRelList){
            if(uniqueKeyMap.get(qliRelMap.get(qli.Id)) != null){
                qli.ARTL_4GUniqueKey__c = uniqueKeyMap.get(qliRelMap.get(qli.Id));
                qlitoUpdate.add(qli);
            }
        }
        
        for(QuoteLineItem qli : qliList){
            qli.ARTL_4GUniqueKey__c = uniqueKeyMap.get(qli.Id);
            qlitoUpdate.add(qli);
        }
        
        if(qlitoUpdate.size() > 0){
            update qlitoUpdate;
        }
    }

    public static void updateOpportunityStage(Map<Id, Quote> quoteNewMap, Map<Id, Quote> quoteOldMap){
        List < Opportunity > oppListToUpdate = new List< Opportunity >();
        List< Id > oppIdList = new List< Id >();
        for(Quote qte : quoteNewMap.values()){
            oppIdList.add(qte.OpportunityId);
        }
        Map< Id, Opportunity > oppMap = new Map< Id, Opportunity>();
        if(oppIdList != null && oppIdList.size() > 0){
            oppMap = new Map< Id, Opportunity>([Select id , StageName from opportunity where id in : oppIdList]);
        }
        for(Quote qte: quoteNewMap.values()){
            system.debug(qte.OpportunityId);
            if( qte.Status != null && qte.Status != quoteOldMap.get(qte.Id).Status && qte.Status == System.label.ARTL_Quote_Status_Proposal_Sent && oppMap != null && oppMap.get(qte.OpportunityId).StageName != 'Closed Won' && oppMap.get(qte.OpportunityId).StageName != 'Closed Lost' ){
                Opportunity oppInstance = new Opportunity();
                oppInstance.Id = qte.OpportunityId;
                oppInstance.StageName = 'Proposal Stage';
                oppListToUpdate.add(oppInstance);
            }
           // if( qte.Status != null && qte.Status != quoteOldMap.get(qte.Id).Status && qte.Status == System.label.ARTL_Quote_Status_Customer_Signed && oppMap != null && oppMap.get(qte.OpportunityId).StageName == 'PO Stage'){
            if( qte.Status != null && qte.Status != quoteOldMap.get(qte.Id).Status && qte.Status == 'Order Created' && oppMap != null && oppMap.get(qte.OpportunityId).StageName == 'PO Stage'){
                Opportunity oppInstance = new Opportunity();
                oppInstance.Id = qte.OpportunityId;
                oppInstance.StageName = 'Closed Won';
                oppInstance.Opportunity_Closure_Status__c = 'Completely Won';
                oppListToUpdate.add(oppInstance);
            }
        }
        if(oppListToUpdate != null && oppListToUpdate.size() > 0){
            system.debug(oppListToUpdate[0].id);
            update oppListToUpdate;
        }

    }
}