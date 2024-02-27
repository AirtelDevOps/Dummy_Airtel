/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ARTL_GenerateLettersAndSendEmail
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Akshay Kaushik    <akshay.kaushik@salesforce.com>
* @modifiedBy     Akshay Kaushik    <akshay.kaushik@salesforce.com>
* @maintainedBy   Akshay Kaushik    <akshay.kaushik@salesforce.com>
* @version        1.0
* @created        04-10-2023
* @modified       YYYY-MM-DD
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* 1.0             akshay.kaushik@salesforce.com
* 2023-10-04      Created the class to generate Welcome CSV on Getting Quote OC Approved & To 
*.                generate Kick Off CSV on PM Command and email to customer after generating CSV as 
*				  attachment.
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
global  with sharing class ARTL_GenerateLettersAndSendEmail implements vlocity_cmt.VlocityOpenInterface
{
    //Invocable Method to call from Flow To generate Welcome Letter and Send email to customer with Attachment
    @InvocableMethod(label='create CSV Document')
    public static List<String> CreateAndSendWelcomeLetter(List<FlowInput> flowInputs) {
        String QuoteId = flowInputs.get(0).recordId;
        String AccountId;
        String Quotenumber;
        List<String> toaddresses = new List<String>();
        List<QuoteLineItem> ListOfRecordsTocreateCSV = [select id,quote.QuoteNumber,Quote.PM_Team_Lead_Email__c,Quote.PM_Email__c,Quote.vlocity_cmt__Type__c,Quote.PO_Value__c, Quote.PO_Term__c,vlocity_cmt__BillingAccountId__c,quote.vlocity_cmt__PoNumber__c,quote.Opportunity.Product__c, Quote.Account.name,LineNumber,vlocity_cmt__ServiceAccountId__c, vlocity_cmt__AttributeSelectedValues__c,Quote.PM__r.Email,Product2.Family,Quote.PM__r.OIM_Id__c,quote.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email,vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Name,vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email,vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.MobilePhone,Quote.PM__r.MobilePhone,vlocity_cmt__ServiceAccountId__r.ShippingAddress,Quote.PM__r.name,vlocity_cmt__ServiceAccountId__r.ShippingCity,vlocity_cmt__ServiceAccountId__r.ShippingState,vlocity_cmt__ServiceAccountId__r.ShippingPostalCode from quotelineitem where quoteid = :QuoteId  ];
        List<String> quotelineitemDetails = new List<String>();
        if(ListOfRecordsTocreateCSV != NULL && !ListOfRecordsTocreateCSV.isEmpty())
        {
            for(QuoteLineItem qliObj: ListOfRecordsTocreateCSV)
            {
                Map<String,Object> AttributeSelectedValues = new Map<String,Object>();
                if(qliObj.vlocity_cmt__AttributeSelectedValues__c != NULL ){
                    AttributeSelectedValues = (Map<String,Object>) JSON.deserializeUntyped(qliObj.vlocity_cmt__AttributeSelectedValues__c);
                }
                String ShippingAddresses = String.valueof(qliObj.vlocity_cmt__ServiceAccountId__r.ShippingAddress);
                String POValue = String.valueOf(qliObj.Quote.PO_Value__c);
                if(ShippingAddresses==null){
                    ShippingAddresses='';
                }
                quotelineitemDetails.add(qliObj.Quote.Account.name+','+(qliObj.Quote.vlocity_cmt__PoNumber__c==null?'':qliObj.Quote.vlocity_cmt__PoNumber__c)+','+(POValue==null?'':POValue)+','+(qliObj.Quote.PO_Term__c==null?'':qliObj.Quote.PO_Term__c)+','+(qliObj.quote.QuoteNumber==null?'':qliObj.quote.QuoteNumber)+','+ListOfRecordsTocreateCSV.size()+','+qliObj.LineNumber+','+qliObj.id+','+(qliObj.Quote.vlocity_cmt__Type__c==null?'':qliObj.Quote.vlocity_cmt__Type__c)+','+(qliObj.Product2.Family==null?'':qliObj.Product2.Family)+','+qliObj.id+','+(AttributeSelectedValues.get('ATT_PORT_BANDWIDTH')==null?'':AttributeSelectedValues.get('ATT_PORT_BANDWIDTH'))+','+(AttributeSelectedValues.get('ATT_ACCESS_BANDWIDTH')==null?'':AttributeSelectedValues.get('ATT_ACCESS_BANDWIDTH'))+','+(AttributeSelectedValues.get('ATT_MEDIA')==null?'':AttributeSelectedValues.get('ATT_MEDIA'))+','+(AttributeSelectedValues.get('ATT_SERVICE_TYPE')==null?'':AttributeSelectedValues.get('ATT_SERVICE_TYPE'))+','+''+','+''+','+(AttributeSelectedValues.get('ATT_ENTERPRISE_CONNECTIVITY_TYPE')==null?'':AttributeSelectedValues.get('ATT_ENTERPRISE_CONNECTIVITY_TYPE'))+','+''+','+(qliObj.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Name==null?'':qliObj.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Name)+','+(qliObj.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email==null?'':qliObj.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email)+','+(qliObj.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.MobilePhone==null?'':qliObj.vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.MobilePhone)+','+ShippingAddresses+','+(qliObj.vlocity_cmt__ServiceAccountId__r.ShippingCity==null?'':qliObj.vlocity_cmt__ServiceAccountId__r.ShippingCity)+','+(qliObj.vlocity_cmt__ServiceAccountId__r.ShippingState==null?'':qliObj.vlocity_cmt__ServiceAccountId__r.ShippingState)+','+(qliObj.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode==null?'':+qliObj.vlocity_cmt__ServiceAccountId__r.ShippingPostalCode)+','+''+','+''+','+''+','+''+','+(qliObj.quote.PM__r.name==null?'':qliObj.Quote.PM__r.name)+','+(qliObj.Quote.PM__r.MobilePhone==null?'':qliObj.Quote.PM__r.MobilePhone)+','+(qliObj.Quote.PM__r.Email==null?'':qliObj.Quote.PM__r.Email));
                AccountId = qliObj.Quote.Accountid;
                Quotenumber = qliObj.Quote.QuoteNumber;
                toaddresses.add(qliObj.Quote.PM_Email__c);
                toaddresses.add(qliObj.Quote.PM_Team_Lead_Email__c);
            }
        }
        
        //Creating Welcome Letter CSV file
        String csvFile;
        String csvColumnHeader = 'Customer Name,Customer PO Number,PO Value,PO Term,Order Number,Total Number of Sites,Sub Order Number,Circuit ID (LSI),Order Type,Product Type,CAF Number,Port Bandwidth,Access Bandwidth,Media,Service Type,Router Make,Router Model,Connectivity Type,Link Topology,Local Contact Name,Local Contact Email,Local Contact Phone Number,Installation Address,Installation City,Installation State,Installation Location Pincode,Expected Date of Delivery,Account Manager/Sales Manager Name,Account Manager/Sales Manager Contact Number,Account Manager/Sales Manager Email id,Project Manager Name,Project Manager Contact Number,Project Manager Email id';
        List<String> csvRowValues = new List<String>();
        if(quotelineitemDetails != NULL && !quotelineitemDetails.isEmpty())
        {
            csvFile = csvColumnHeader + '\n' +String.join(quotelineitemDetails,'\n');
        }
        
        //Attaching CSV With Quote Record
        List<ContentVersion> ListOfDocuments = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Welcome Letter';
        cv.PathOnClient = 'Welcome Letter.csv';
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
        idsToreturn.add(String.valueof(cdl.id));
        
        //Sending Email to Customer With CSV as attachment
        String welcomeLetter = 'Welcome Letter.csv';
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(welcomeLetter);
        efa.setBody(Blob.valueOf(welcomeLetter));
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='Welcome_Email' ];
        List<string> toAddress = new List<string>();
        toAddress = toaddresses;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(et.Id);
        mail.setToAddresses(toAddress);
        mail.setSubject('Welcome Letter: Bharti Airtel - Order Reference: '+Quotenumber);
        mail.setTargetObjectId(QuoteId);
        mail.setWhatId(AccountId);
        mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);
        try {
            Messaging.sendEmail(allmsg,false);
            if(QuoteId != null){
                //sendkickoffEmailthroughDIRS(QuoteId,'Welcome_Email1','Quote');
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return idsToreturn;
    }
    
    //Flow Inputs
    public class FlowInput{
        @InvocableVariable(required=true) public Id recordId;
        @InvocableVariable(required=false) public String objectName;
        @InvocableVariable(required=false) public String templateName;
    }
    
    /******************************************************************************************************************
	* Method Name        : invokeMethod
	* Method Description : invoke method used for sending the method name called with the input data sent from os and IP
	*******************************************************************************************************************/
    global  Boolean invokeMethod( String methodName,Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options)
    {
        try
        {
            System.debug('invokeMethod>>>>' + String.valueOf(inputMap.get('OrderId')));
            //checking the method name is the name sent from os then calling that method
            if((methodName != null || String.isNotBlank(methodName)) && methodName.equals('CreateAndSendKickOffEmail'))
            {
                //CreateAndSendKickOffEmail(inputMap, outMap, options);
                List<ARTL_TaskEmailController.FlowInput> lstinput = new List<ARTL_TaskEmailController.FlowInput>();
                ARTL_TaskEmailController.FlowInput input = new ARTL_TaskEmailController.FlowInput();
                input.recordId = String.valueOf(inputMap.get('OrderId'));
                input.templateName = 'Welcome_Email1';
                input.emailType = 'CreateAndSendKickOffEmail';
                lstinput.add(input);
                
                if(!lstinput.isEmpty()){
                    ARTL_TaskEmailController.sendWelcomeEmail(lstinput);
                }
            }
        }
        catch(Exception ex)
        {
            outMap.put('Error Occurred', ex.getMessage());// if any error occurred send the data using output map
            System.debug('exception occurred ::=> '+ ex.getMessage()+' '+ex.getStackTraceString());
        }
        outMap.put('ApexCall', true);
        return true;
    }    
    
    /******************************************************************************************************************
	* Method Name        : CreateAndSendKickOffEmail
	* Method Description : Generate KickOff CSV and Send Email To Customer along with attachment
	*******************************************************************************************************************/
    
    public void CreateAndSendKickOffEmail( Map<String, Object> inputMap, Map<String, Object> outMap,Map<String, Object> options){
        String OrderId = String.valueOf(inputMap.get('OrderId'));
        List<Order> orderRecords = [Select vlocity_cmt__QuoteId__c from Order where Id=:OrderId Limit 1 ];
        String QuoteId = orderRecords[0].vlocity_cmt__QuoteId__c;
        String AccountId;
        String Quotenumber;
        List<String> toaddresses = new List<String>();
        List<QuoteLineItem> ListOfRecordsTocreateCSV = [select id,quote.QuoteNumber,Quote.PM_Team_Lead_Email__c,Quote.PM_Email__c,Quote.vlocity_cmt__Type__c,Quote.PO_Value__c, Quote.PO_Term__c,vlocity_cmt__BillingAccountId__c,quote.vlocity_cmt__PoNumber__c,quote.Opportunity.Product__c, Quote.Account.name,LineNumber,vlocity_cmt__ServiceAccountId__c, vlocity_cmt__AttributeSelectedValues__c,Quote.PM__r.Email,Product2.Family,Quote.PM__r.OIM_Id__c,quote.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email,vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Name,vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email,vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.MobilePhone,Quote.PM__r.MobilePhone,vlocity_cmt__ServiceAccountId__r.ShippingAddress,Quote.PM__r.name,vlocity_cmt__ServiceAccountId__r.ShippingCity,vlocity_cmt__ServiceAccountId__r.ShippingState,vlocity_cmt__ServiceAccountId__r.ShippingPostalCode from quotelineitem where quoteid = :QuoteId  ];
        List<String> quotelineitemDetails = new List<String>();
        if(ListOfRecordsTocreateCSV != NULL && !ListOfRecordsTocreateCSV.isEmpty())
        {
            for(QuoteLineItem qliObj: ListOfRecordsTocreateCSV)
            {
                Map<String,Object> AttributeSelectedValues = new Map<String,Object>();
                if(qliObj.vlocity_cmt__AttributeSelectedValues__c != NULL ){
                    AttributeSelectedValues = (Map<String,Object>) JSON.deserializeUntyped(qliObj.vlocity_cmt__AttributeSelectedValues__c);
                }
                String ShippingAddresses = String.valueof(qliObj.vlocity_cmt__ServiceAccountId__r.ShippingAddress);
                if(ShippingAddresses==null){
                    ShippingAddresses='';
                }
                quotelineitemDetails.add(qliObj.id + ',' +qliObj.quote.QuoteNumber + ',' + qliObj.Quote.Account.name + ',' + qliObj.LineNumber +','+''+ ',' + (qliObj.Quote.vlocity_cmt__PoNumber__c==null?'':qliObj.Quote.vlocity_cmt__PoNumber__c)+ ','+(qliObj.Quote.vlocity_cmt__Type__c==null?'':qliObj.Quote.vlocity_cmt__Type__c)+','+(qliObj.Product2.Family==null?'':qliObj.Product2.Family)+','+(AttributeSelectedValues.get('ATT_SERVICE_TYPE')==null?'':AttributeSelectedValues.get('ATT_SERVICE_TYPE'))+','+' '+','+ShippingAddresses+','+(qliObj.vlocity_cmt__BillingAccountId__c==null?'':qliObj.vlocity_cmt__BillingAccountId__c)+','+(qliObj.vlocity_cmt__ServiceAccountId__c==null?'':qliObj.vlocity_cmt__ServiceAccountId__c)+','+(qliObj.Quote.PM__r.OIM_Id__c==null?'':qliObj.Quote.PM__r.OIM_Id__c)+','+(qliObj.Quote.PM__r.Email==null?'':qliObj.Quote.PM__r.Email)+','+'-'+','+(AttributeSelectedValues.get('ATT_ACCESS_BANDWIDTH')==null?'':AttributeSelectedValues.get('ATT_ACCESS_BANDWIDTH'))+','+'PM Approval'+','+'PM Approval'+','+(AttributeSelectedValues.get('ATT_LAN_IPV4')==null?'':AttributeSelectedValues.get('ATT_LAN_IPV4'))+','+(AttributeSelectedValues.get('ATT_LAN_IPV4_SUBNET_MASK')==null?'':AttributeSelectedValues.get('ATT_LAN_IPV4_SUBNET_MASK'))+','+(AttributeSelectedValues.get('ATT_LAN_IPV6')==null?'':AttributeSelectedValues.get('ATT_LAN_IPV6'))+','+(AttributeSelectedValues.get('ATT_LAN_IPV6_SUBNET_MASK')==null?'':AttributeSelectedValues.get('ATT_LAN_IPV6_SUBNET_MASK'))+','+(AttributeSelectedValues.get('ATT_WAN_IPV4_PE')==null?'':AttributeSelectedValues.get('ATT_WAN_IPV4_PE'))+','+(AttributeSelectedValues.get('ATT_WAN_IPV4_PE_SUBNET_MASK')==null?'':AttributeSelectedValues.get('ATT_WAN_IPV4_PE_SUBNET_MASK'))+','+(AttributeSelectedValues.get('ATT_WAN_IPV4_CE')==null?'':AttributeSelectedValues.get('ATT_WAN_IPV4_CE'))+','+(AttributeSelectedValues.get('ATT_WAN_IPV4_CE_SUBNET_MASK')==null?'':AttributeSelectedValues.get('ATT_WAN_IPV4_CE_SUBNET_MASK'))+','+(AttributeSelectedValues.get('ATT_WAN_IPV6_PE')==null?'':AttributeSelectedValues.get('ATT_WAN_IPV6_PE'))+','+(AttributeSelectedValues.get('ATT_WAN_IPV6_PE_SUBNET_MASK')==null?'':AttributeSelectedValues.get('ATT_WAN_IPV6_PE_SUBNET_MASK'))+','+(AttributeSelectedValues.get('ATT_WAN_IPV6_CE')==null?'':AttributeSelectedValues.get('ATT_WAN_IPV6_CE'))+','+(AttributeSelectedValues.get('ATT_WAN_IPV6_CE_SUBNET_MASK')==null?'':AttributeSelectedValues.get('ATT_WAN_IPV6_CE_SUBNET_MASK'))+','+(AttributeSelectedValues.get('ATT_AIRTEL_LOOPBACK_IP')==null?'':AttributeSelectedValues.get('ATT_AIRTEL_LOOPBACK_IP'))+','+(AttributeSelectedValues.get('ATT_REMOTE_LOOPBACK_IP')==null?'':AttributeSelectedValues.get('ATT_REMOTE_LOOPBACK_IPP'))+','+'-'+','+System.Today().Format());
                AccountId = qliObj.Quote.Accountid;
                Quotenumber = qliObj.Quote.QuoteNumber;
                toaddresses.add(qliObj.Quote.PM_Email__c);
                toaddresses.add(qliObj.Quote.PM_Team_Lead_Email__c);
            }
        }
        
        //Creating Kick Off CSV file
        String csvFile;
        String csvColumnHeader = 'Logical Circuit Id , Master Order Id, Customer Name,Sub Order Number ,Sub Order Status,Customer PO Number, Order Type, Product Type,Service Type,Expected Jeopardy Resolution Date, Installation Address,BCP Email Address, DCP Email Address, Assignee OLM, PM Email Id,Old Bandwidth(Mbps),New Bandwidth(Mbps),Task Name,Current Stage,LAN IPv4,LAN IPv4 Subnet Mask,LAN IPv6,LAN IPv6 Subnet Mask,WAN IPv4 PE,WAN IPv4 PE Subnet Mask,WAN IPv4 CE,WAN IPV4 CE Subnet Mask,WAN IPv6 PE,WAN IPv6 PE Subnet Mask,WAN IPv6 CE,WAN IPv6 CE Subnet Mask,Loopback IPv4,Loopback IPv6,Jeopardy Description,PM Approval In Date';
        List<String> csvRowValues = new List<String>();
        if(quotelineitemDetails != NULL && !quotelineitemDetails.isEmpty())
        {
            csvFile = csvColumnHeader + '\n' +String.join(quotelineitemDetails,'\n');
        }
        
        //Attaching CSV To Quote Record
        List<ContentVersion> ListOfDocuments = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Kick Off Letter';
        cv.PathOnClient = 'Kick Off Letter.csv';
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
        String kickOffAttachment = 'Kick Off Letter.csv';
        
        //Sending Email to Customer With CSV as attachment
        Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
        efa1.setFileName(kickOffAttachment);
        efa1.setBody(Blob.valueOf(kickOffAttachment));
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName ='Welcome_Email' ];
        List<string> toAddress = new List<string>();
        toAddress = toaddresses;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(et.Id);
        mail.setToAddresses(toAddress);
        mail.setSubject('Kick Off Letter: Bharti Airtel - Order Reference: '+Quotenumber);
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
    
    /*Public static void sendkickoffEmailthroughDIRS(String recordId, String templateName, String objectName){
        Map<String,Object> input = new Map<String,Object>();
        Map<String,Object> output = new Map<String,Object>();
        String cclist = '';
        String tolist = '';
        String msgbody = ARTL_EmailTemplateService.TransformEmailTenplate(recordId,templateName,objectName);
        input.put('message',msgbody);
        
        List<Quote> lstQuote = [select id,Quote.QuoteNumber,Quote.PM_Team_Lead_Email__c,
                                Quote.PM_Email__c,Quote.vlocity_cmt__Type__c,Quote.PO_Value__c, 
                                Quote.PO_Term__c,Account.AccountNumber, 
                                quote.vlocity_cmt__PoNumber__c,quote.Opportunity.Product__c, 
                                Quote.Account.name, 
                                Quote.PM__r.Email,
                                Quote.PM__r.OIM_Id__c,
                                quote.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email,
                                Quote.PM__r.MobilePhone,Quote.PM__r.name
                                from Quote where Id = :recordId];
        if(!lstQuote.isEmpty()){
                tolist ='a_Abinash.Barik@airtel.com'+';'+'a_Rishab.kalra@airtel.com'+';'+'a_sujay.dey@airtel.com' + ';'+'a_Vishal.kumar24@airtel.com'; 
                //tolist.add('a_Vishal.kmuar24@airtel.com');
                //tolist.add('a_Abinash.Barik@airtel.com');
                //tolist.add('a_shashi.kumar@airtel.com');
                //if(lstQuote[0].quote.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email != null)
                	//tolist.add(lstQuote[0].quote.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email);
                
                input.put('custNo',lstQuote[0].Account.AccountNumber);
                input.put('nbaId',lstQuote[0].Account.AccountNumber);
                input.put('emailId','a_Abinash.Barik@airtel.com');
                input.put('accountNo',lstQuote[0].Account.AccountNumber);
                input.put('subject','Welcome Letter: Bharti Airtel - Order Reference:');
            }
             
			input.put('filePath','');
            input.put('partyId','PARTY_ID');
            input.put('invoiceNo',lstQuote[0].Id);
            input.put('ccList',cclist);
            input.put('toList',tolist);
            System.debug('input>>>'+JSON.serialize(input));
            String submitresult = JSON.serialize(vlocity_cmt.IntegrationProcedureService.runIntegrationProcedureQueueable('ARTL_MailThroughDIRS', 
                            input, output));
            System.debug('submitresult>>>'+submitresult);
            //input.put('productName',objtask.Product_Name__c);
    }*/
}