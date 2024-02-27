global with sharing class ARTL_CreatePurchaseRequest {
    @InvocableMethod(label = 'Calling Purchase Request Apex')
    global static void  CreatePRRecord(List<InputVariable> inputVar) {
    
     String ids = inputVar.get(0).Id;
     System.debug(ids);
    
        Order ordr = [
                       SELECT id,RecordType.DeveloperName,Is_NIPS__c,vlocity_cmt__QuoteId__c 
                       from Order where Id =: ids limit 1
        ];
         System.debug(ordr.vlocity_cmt__QuoteId__c);
         
        List<QuoteLineItem> quoteLine = [
                                   SELECT id, RequisitionNumber__c,ARTL_OUName__c, ARTL_ItemCode__c 
                                   from QuoteLineItem  
                                   where QuoteId=: ordr.vlocity_cmt__QuoteId__c
                                   AND (vlocity_cmt__Product2Id__r.ProductCode = 'dac49a09-9b41-4999-b7c4-cf6319ad5b44'
                                   OR vlocity_cmt__Product2Id__r.ProductCode = 'c09a2e70-64af-4ad6-8427-06c8489234d7')
                                   AND RequisitionNumber__c != '' 
                                    
        ];
        if(quoteLine.size() > 0){
        List<String> reqitem = new List<String>();
        List<ARTL_Purchase_Request__c> prObjList = new List<ARTL_Purchase_Request__c>();
            for(QuoteLineItem ql: quoteLine){
                if(ql.RequisitionNumber__c.contains(';')){
                    List<String> req = ql.RequisitionNumber__c.split(';');
                    for(String eachItem: req){
                        //reqitem.add(eachItem);
                        
                        ARTL_Purchase_Request__c prObj = new ARTL_Purchase_Request__c();
                        prObj.Requisition_Number__c = eachItem;
                        prObj.Item_Code__c = ql.ARTL_ItemCode__c ;
                        prObj.Quote_Line_Item__c = ql.Id;
                        prObj.Master_Order__c = ids;
                        prObjList.add(prObj);
                    }
                       
                }
                else{
                        //reqitem.add(ql.RequisitionNumber__c);

                        ARTL_Purchase_Request__c prObj = new ARTL_Purchase_Request__c();
                        prObj.Requisition_Number__c = ql.RequisitionNumber__c;
                        prObj.Item_Code__c = ql.ARTL_ItemCode__c ;
                        prObj.Quote_Line_Item__c = ql.Id;
                        prObj.Master_Order__c = ids;
                        prObjList.add(prObj);
                }
            }
        /*if(quoteLine[0].RequisitionNumber__c.contains(';')){
               reqitem = quoteLine[0].RequisitionNumber__c.split(';');
        }*/
        /*for(integer i = 0; i < reqitem.size(); i++){
           ARTL_Purchase_Request__c prObj = new ARTL_Purchase_Request__c();
           prObj.Requisition_Number__c = reqitem[i];
           prObj.Item_Code__c = quoteLine[0].ARTL_ItemCode__c ;
           prObj.Quote_Line_Item__c = quoteLine[0].Id;
           prObj.Master_Order__c = ids;
           prObjList.add(prObj);
        }*/
    
        if(prObjList.size()>0){
            insert prObjList;
            ordr.Is_NIPS__c = true;
            update ordr;
        }
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{UserInfo.getUserEmail()});
            email.setSubject('PR Task Assigned.');
            String body = 'A PR Task has been assigned to you, Please click on the Link to Proceed.';
            body += '<br></br>';
            body += '<br></br>';
            String link = URL.getOrgDomainUrl().toExternalForm()+'/'+ids;
            body += link;
            email.setHtmlBody(body);
             Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    
        }
    
    }
    global class InputVariable
    {
    @InvocableVariable(label = 'Ids') global String Id;
       
    } 
    
    }