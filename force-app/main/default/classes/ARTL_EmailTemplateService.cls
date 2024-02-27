/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* ARTL_EmailTemplateService
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author			Abinash Barik    <abinash.barik@salesforce.com>
* @modifiedBy		Abinash Barik    <abinash.barik@salesforce.com>
* @maintainedBy		Abinash Barik    <abinash.barik@salesforce.com>
* @version			1.0
* @created			2023-11-9
* @modified			YYYY-MM-DD
* @Description		this method will expect recordId and emailtemplateName, and it will replace all merged fields and return the HTML content
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* 1.0             abinash.barik@salesforce.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public without sharing class ARTL_EmailTemplateService {
    public Static String ProductType = '';
    /*
     * This method is responsible get Order Id and generate email template doby aand return, used for Welcome and Kick off template
     * */
    public static ARTL_TaskEmailController.emailWrapper getKickoffEmailTemplate(Id recordId, String emailTemplateName){
        ARTL_TaskEmailController.emailWrapper objemailwrapper = new ARTL_TaskEmailController.emailWrapper();
        List<Order> lstOrder = new List<Order>();
        lstOrder = [Select Id, vlocity_cmt__QuoteId__c FROM Order Where Id =:recordId AND vlocity_cmt__QuoteId__c != null];
        if(!lstOrder.isEmpty()){
            objemailwrapper.contentversionId = generateAttchment(recordId);
            objemailwrapper = getNonDeemedLOCEmailTemplate(recordId,emailTemplateName);
        }
        return objemailwrapper;
    }
    public static String getcontentVerionId(Id recordId){
        String cvId;
        SObjectType objectType = recordId.getSobjectType();
        ARTL_Document__c doc = new ARTL_Document__c();
        doc.Document_Name__c = 'LOC_Email';
        doc.Category__c = 'EMAIL';
        doc.Type__c = 'LOC';
        if(recordId.getSObjectType().getDescribe().getName() == 'Quote'){
            cvId = generateAttchment(recordId);
            doc.Quote__c =recordId;  
        }else if(recordId.getSObjectType().getDescribe().getName() == 'Order'){
			cvId = generateOrderAttchment(recordId);
            doc.Order__c =recordId;
        }
        Insert doc;
        return cvId;
    } 
    public Static String generateAttchment(Id recordId){
        ContentVersion cv = new ContentVersion();
        List<QuoteLineItem> ListOfRecordsTocreateCSV = [select id,quote.QuoteNumber,Quote.PM_Team_Lead_Email__c,Quote.PM_Email__c,
									Quote.vlocity_cmt__Type__c,Quote.PO_Value__c, Quote.PO_Term__c,
									vlocity_cmt__BillingAccountId__c,quote.vlocity_cmt__PoNumber__c,
									quote.Opportunity.Product__c, Quote.Account.name,LineNumber,
									vlocity_cmt__ServiceAccountId__c, vlocity_cmt__AttributeSelectedValues__c,
									Quote.PM__r.Email,Product2.Family,Quote.PM__r.OIM_Id__c,
									quote.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email,
									vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Name,
									vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email,
									vlocity_cmt__ServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.MobilePhone,
									Quote.PM__r.MobilePhone,vlocity_cmt__ServiceAccountId__r.ShippingAddress,Quote.PM__r.name,
									vlocity_cmt__ServiceAccountId__r.ShippingCity,vlocity_cmt__ServiceAccountId__r.ShippingState,
									vlocity_cmt__ServiceAccountId__r.ShippingPostalCode 
									from quotelineitem where quoteid = :recordId];
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
            //ContentVersion cv = new ContentVersion();
            cv.Title = 'Welcome Letter';
            cv.PathOnClient = 'Welcome Letter.csv';
            cv.IsMajorVersion = true;
            cv.VersionData = Blob.valueOf(csvFile);
            ListOfDocuments.add(cv);
            Insert ListOfDocuments;
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            List<ContentDocumentLink> ListofContentDocumentLink = new List<ContentDocumentLink>();
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            ListofContentDocumentLink.add(cdl);
            Insert ListofContentDocumentLink;
        }
            
        
        return cv.Id;
        
    }
    
    public Static String generateOrderAttchment(Id recordId){
        ContentVersion cv = new ContentVersion();
        List<OrderItem> ListOfRecordsTocreateCSV = [select id,Order.OrderNumber,Order.vlocity_cmt__ParentOrderId__r.OrderNumber,
									Order.vlocity_cmt__QuoteId__r.PM_Team_Lead_Email__c,Order.vlocity_cmt__QuoteId__r.PM_Email__c,
									Order.vlocity_cmt__QuoteId__r.vlocity_cmt__Type__c,Order.vlocity_cmt__QuoteId__r.PO_Value__c, 
									Order.vlocity_cmt__QuoteId__r.PO_Term__c,
									vlocity_cmt__BillingAccountId__c,Order.vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c,
									Order.vlocity_cmt__QuoteId__r.Opportunity.Product__c, Order.Account.name,vlocity_cmt__LineNumber__c,
									Order.vlocity_cmt__QuoteId__r.PM__r.Email,Product2.Family,Order.vlocity_cmt__QuoteId__r.PM__r.OIM_Id__c,
									Order.vlocity_cmt__QuoteId__r.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email,
									Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Name,
                                    Order.vlocity_cmt__DefaultServiceAccountId__c,vlocity_cmt__AttributeSelectedValues__c,
									Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email,
									Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.MobilePhone,
									Order.vlocity_cmt__QuoteId__r.PM__r.MobilePhone,Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingAddress,
									Order.vlocity_cmt__QuoteId__r.PM__r.name,
									Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingCity,Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingState,
									Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode 
									from OrderItem where (OrderId = :recordId OR Order.vlocity_cmt__ParentOrderId__c= :recordId) 
									AND vlocity_cmt__ParentItemId__c = null];
        List<String> quotelineitemDetails = new List<String>();
        if(ListOfRecordsTocreateCSV != NULL && !ListOfRecordsTocreateCSV.isEmpty())
        {
            for(OrderItem oli: ListOfRecordsTocreateCSV)
            {
                Map<String,Object> AttributeSelectedValues = new Map<String,Object>();
                if(oli.vlocity_cmt__AttributeSelectedValues__c != NULL ){
                    AttributeSelectedValues = (Map<String,Object>) JSON.deserializeUntyped(oli.vlocity_cmt__AttributeSelectedValues__c);
                }
                String ShippingAddresses = String.valueof(oli.Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingAddress);
                String POValue = String.valueOf(oli.Order.vlocity_cmt__QuoteId__r.PO_Value__c);
                if(ShippingAddresses==null){
                    ShippingAddresses='';
                }
				
				quotelineitemDetails.add(oli.Order.Account.name+','+(oli.Order.vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c==null?'':oli.Order.vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c)+','+(POValue==null?'':POValue)+','+(oli.Order.vlocity_cmt__QuoteId__r.PO_Term__c==null?'':oli.Order.vlocity_cmt__QuoteId__r.PO_Term__c)+','+(oli.Order.vlocity_cmt__ParentOrderId__r.OrderNumber==null?'':oli.Order.vlocity_cmt__ParentOrderId__r.OrderNumber)+','+ListOfRecordsTocreateCSV.size()+','+oli.Order.OrderNumber+','+oli.orderid+','+(Oli.Order.vlocity_cmt__QuoteId__r.vlocity_cmt__Type__c==null?'':Oli.Order.vlocity_cmt__QuoteId__r.vlocity_cmt__Type__c)+','+(oli.Product2.Family==null?'':oli.Product2.Family)+','+oli.orderid+','+(AttributeSelectedValues.get('ATT_PORT_BANDWIDTH')==null?'':AttributeSelectedValues.get('ATT_PORT_BANDWIDTH'))+','+(AttributeSelectedValues.get('ATT_ACCESS_BANDWIDTH')==null?'':AttributeSelectedValues.get('ATT_ACCESS_BANDWIDTH'))+','+(AttributeSelectedValues.get('ATT_MEDIA')==null?'':AttributeSelectedValues.get('ATT_MEDIA'))+','+(AttributeSelectedValues.get('ATT_SERVICE_TYPE')==null?'':AttributeSelectedValues.get('ATT_SERVICE_TYPE'))+','+''+','+''+','+(AttributeSelectedValues.get('ATT_ENTERPRISE_CONNECTIVITY_TYPE')==null?'':AttributeSelectedValues.get('ATT_ENTERPRISE_CONNECTIVITY_TYPE'))+','+''+','+(oli.Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Name==null?'':oli.Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Name)+','+(oli.Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email==null?'':oli.Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email)+','+(oli.Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.MobilePhone==null?'':oli.Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.MobilePhone)+','+ShippingAddresses+','+(oli.Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingCity==null?'':oli.Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingCity)+','+(oli.Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingState==null?'':oli.Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingState)+','+(oli.Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode==null?'':+oli.Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode)+','+''+','+''+','+''+','+''+','+(oli.Order.vlocity_cmt__QuoteId__r.PM__r.name==null?'':oli.Order.vlocity_cmt__QuoteId__r.PM__r.name)+','+(oli.Order.vlocity_cmt__QuoteId__r.PM__r.MobilePhone==null?'':oli.Order.vlocity_cmt__QuoteId__r.PM__r.MobilePhone)+','+(oli.Order.vlocity_cmt__QuoteId__r.PM__r.Email==null?'':oli.Order.vlocity_cmt__QuoteId__r.PM__r.Email));
                //quotelineitemDetails.add(oli.Order.Account.name+','+(oli.Order.vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c==null?'':oli.Order.vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c)+','+(POValue==null?'':POValue)+','+(oli.Order.vlocity_cmt__QuoteId__r.PO_Term__c==null?'':oli.Order.vlocity_cmt__QuoteId__r.PO_Term__c)+','+(oli.Order.vlocity_cmt__QuoteId__r.QuoteNumber==null?'':oli.Order.vlocity_cmt__QuoteId__r.QuoteNumber)+','+ListOfRecordsTocreateCSV.size()+','+oli.vlocity_cmt__LineNumber__c+','+oli.id+','+(oli.Order.vlocity_cmt__QuoteId__r.vlocity_cmt__Type__c==null?'':oli.Order.vlocity_cmt__QuoteId__r.vlocity_cmt__Type__c)+','+(oli.Product2.Family==null?'':oli.Product2.Family)+','+oli.id+','+(AttributeSelectedValues.get('ATT_PORT_BANDWIDTH')==null?'':AttributeSelectedValues.get('ATT_PORT_BANDWIDTH'))+','+(AttributeSelectedValues.get('ATT_ACCESS_BANDWIDTH')==null?'':AttributeSelectedValues.get('ATT_ACCESS_BANDWIDTH'))+','+(AttributeSelectedValues.get('ATT_MEDIA')==null?'':AttributeSelectedValues.get('ATT_MEDIA'))+','+(AttributeSelectedValues.get('ATT_SERVICE_TYPE')==null?'':AttributeSelectedValues.get('ATT_SERVICE_TYPE'))+','+''+','+''+','+(AttributeSelectedValues.get('ATT_ENTERPRISE_CONNECTIVITY_TYPE')==null?'':AttributeSelectedValues.get('ATT_ENTERPRISE_CONNECTIVITY_TYPE'))+','+''+','+(oli.Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Name==null?'':oli.Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Name)+','+(oli.Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email==null?'':oli.Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email)+','+(oli.Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.MobilePhone==null?'':oli.Order.vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.MobilePhone)+','+ShippingAddresses+','+(oli.Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingCity==null?'':oli.Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingCity)+','+(qliObj.vlocity_cmt__ServiceAccountId__r.ShippingState==null?'':Oli.Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingState)+','+(:Oli.Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode==null?''::Oli.Order.vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode)+','+''+','+''+','+''+','+''+','+oli.Order.vlocity_cmt__QuoteId__r.PM__r.name==null?''+oli.Order.vlocity_cmt__QuoteId__r.PM__r.name)+','++oli.Order.vlocity_cmt__QuoteId__r.PM__r.MobilePhone==null?''+oli.Order.vlocity_cmt__QuoteId__r.PM__r.MobilePhone)+','+oli.Order.vlocity_cmt__QuoteId__r.PM__r.Email==null?''+oli.Order.vlocity_cmt__QuoteId__r.PM__r.Email));
                
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
            //ContentVersion cv = new ContentVersion();
            cv.Title = 'Welcome Letter';
            cv.PathOnClient = 'Welcome Letter.csv';
            cv.IsMajorVersion = true;
            cv.VersionData = Blob.valueOf(csvFile);
            ListOfDocuments.add(cv);
            Insert ListOfDocuments;
            Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            List<ContentDocumentLink> ListofContentDocumentLink = new List<ContentDocumentLink>();
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
            cdl.ContentDocumentId = conDocId;
            cdl.shareType = 'V';
            ListofContentDocumentLink.add(cdl);
            Insert ListofContentDocumentLink;
        }
            
        
        return cv.Id;
        
    }
    
    /*
     * This method is responsible get quote Id and generate email template doby aand return, used for Welcome and Kick off template
     * */
    
    public static ARTL_TaskEmailController.emailWrapper getWelcomeEmailTemplate(String recordId, String emailTemplateName){
        ARTL_TaskEmailController.emailWrapper objemailwrapper = new ARTL_TaskEmailController.emailWrapper();
        string templateContent = null;
        EmailTemplate objemail = new EmailTemplate();
		objemail = [Select Id,Name,Body,HtmlValue,IsActive,Subject,Markup,TemplateType FROM EmailTemplate 
                        WHERE DeveloperName =:emailTemplateName];
        if(objemail != null){
        	if(objemail.TemplateType == 'html'){
                templateContent = objemail.HtmlValue;
            }else if(objemail.TemplateType == 'visualforce'){
                templateContent = objemail.Markup;
                objemailwrapper.subject = objemail.Subject;
            }
    	}
        String cclist = '';
        String tolist = '';
        List<Quote> lstquote = new List<Quote>();
        lstquote = [Select Id, Customer_Name__c,Name,vlocity_cmt__Type__c,Product_Family__c,vlocity_cmt__PoDate__c,
                    AccountId,OpportunityId,QuoteNumber,
                    vlocity_cmt__PoNumber__c,PO_Value__c,PO_Term__c,PM_Name__c,PM_Email__c,PM_Phone__c,PM_Team_Lead__c,
                    PM_Team_Lead_Email__c, PM_Team_Lead_Phone__c,PM__r.Email,PM__r.Manager.Email,Account.AccountNumber,
                    vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email
                    FROM Quote WHERE Id=:recordId];
        System.debug('lstquote>>>'+ lstquote);
        if(!lstquote.isEmpty()){
            templateContent = lstquote[0].Name != null ? templateContent.replaceAll('Quote.Name',
                                    lstquote[0].Name):templateContent.replaceAll('Quote.Name', '');
            templateContent = lstquote[0].Customer_Name__c != null ? templateContent.replaceAll('Quote.Customer_Name__c',
                                    lstquote[0].Customer_Name__c):templateContent.replaceAll('Quote.Customer_Name__c', '');
            templateContent = lstquote[0].vlocity_cmt__Type__c != null ? templateContent.replaceAll('Quote.vlocity_cmt__Type__c',
                                    lstquote[0].vlocity_cmt__Type__c):templateContent.replaceAll('Quote.vlocity_cmt__Type__c', '');
            //templateContent = lstquote[0].Product_Family__c != null ? templateContent.replaceAll('Quote.Product_Family__c',
                                   // lstquote[0].Product_Family__c):templateContent.replaceAll('Quote.Product_Family__c', '');
            templateContent = lstquote[0].vlocity_cmt__PoDate__c != null ? templateContent.replaceAll('Quote.vlocity_cmt__PoDate__c',
                                    String.valueOf(lstquote[0].vlocity_cmt__PoDate__c)):templateContent.replaceAll('Quote.vlocity_cmt__PoDate__c', '');
            templateContent = lstquote[0].vlocity_cmt__PoNumber__c != null ? templateContent.replaceAll('Quote.vlocity_cmt__PoNumber__c',
                                    lstquote[0].vlocity_cmt__PoNumber__c):templateContent.replaceAll('Quote.vlocity_cmt__PoNumber__c', '');
            templateContent = lstquote[0].PO_Value__c != null ? templateContent.replaceAll('Quote.PO_Value__c',
                                    String.valueOf(lstquote[0].PO_Value__c)):templateContent.replaceAll('Quote.PO_Value__c', '');
            templateContent = lstquote[0].PO_Term__c != null ? templateContent.replaceAll('Quote.PO_Term__c',
                                    lstquote[0].PO_Term__c):templateContent.replaceAll('Quote.PO_Term__c', '');
            templateContent = lstquote[0].PM_Name__c != null ? templateContent.replaceAll('Quote.PM_Name__c',
                                    lstquote[0].PM_Name__c):templateContent.replaceAll('Quote.PM_Name__c', '');
            templateContent = lstquote[0].PM_Email__c != null ? templateContent.replaceAll('Quote.PM_Email__c',
                                    lstquote[0].PM_Email__c):templateContent.replaceAll('Quote.PM_Email__c', '');
            templateContent = lstquote[0].PM_Phone__c != null ? templateContent.replaceAll('Quote.PM_Phone__c',
                                    lstquote[0].PM_Phone__c):templateContent.replaceAll('Quote.PM_Phone__c', '');
            templateContent = lstquote[0].PM_Team_Lead__c != null ? templateContent.replaceAll('Quote.PM_Team_Lead__c',
                                    lstquote[0].PM_Team_Lead__c):templateContent.replaceAll('Quote.PM_Team_Lead__c', '');
            templateContent = lstquote[0].PM_Team_Lead_Email__c != null ? templateContent.replaceAll('Quote.PM_Team_Lead_Email__c',
                                    lstquote[0].PM_Team_Lead_Email__c):templateContent.replaceAll('Quote.PM_Team_Lead_Email__c', '');
            templateContent = lstquote[0].PM_Team_Lead_Phone__c != null ? templateContent.replaceAll('Quote.PM_Team_Lead_Phone__c',
                                    lstquote[0].PM_Team_Lead_Phone__c):templateContent.replaceAll('Quote.PM_Team_Lead_Phone__c', '');
            templateContent = populateQLIDetails(recordId,templateContent);
            if(lstquote[0].PM__c != null){
                if(lstquote[0].PM__r.Email != null){
                	tolist = lstquote[0].PM__r.Email;
                }
                if(lstquote[0].PM__r.Manager.Email != null && tolist != null){
                	tolist =tolist+';'+ lstquote[0].PM__r.Manager.Email;
                }
                else if(lstquote[0].PM__r.Manager.Email != null){
                    tolist =lstquote[0].PM__r.Manager.Email;
                }
                if(lstquote[0].vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email != null && tolist != null){
                    tolist =tolist+';'+ lstquote[0].vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email;
                }else if(lstquote[0].vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email != null){
                    tolist =lstquote[0].vlocity_cmt__DefaultServiceAccountId__r.vlocity_cmt__PrimaryContactId__r.Email;
                }
            }
            System.debug('objemailwrapper.subject>>>'+ objemailwrapper.subject + '===' + lstquote[0].QuoteNumber);
            objemailwrapper.subject = objemailwrapper.subject.replaceAll('QuoteNumber',lstquote[0].QuoteNumber);
            System.debug('objemailwrapper.subject>>>'+ objemailwrapper.subject);
            objemailwrapper.contentversionId = generateAttchment(lstquote[0].Id);
            //objemailwrapper.invoiceNo = lstquote[0].Id;
            objemailwrapper.productName = lstquote[0].Product_Family__c != null ? lstquote[0].Product_Family__c :'';
            objemailwrapper.custNo = lstquote[0].Account.AccountNumber;
            objemailwrapper.nbaId = lstquote[0].Account.AccountNumber;
            objemailwrapper.accountNo =lstquote[0].Account.AccountNumber != null ? lstquote[0].Account.AccountNumber : '';
            objemailwrapper = getCustomerTOEmailAddress(lstquote[0].AccountId,objemailwrapper);
        	objemailwrapper = getCustomerCCEmailAddress(lstquote[0].OpportunityId,objemailwrapper);
        }
        //tolist=tolist +';'+'a_Abinash.Barik@airtel.com';
        //objemailwrapper.tolist =tolist; 
        
        templateContent = templateContent.remove('%').remove('%');
        templateContent = templateContent.replaceAll('"','\'');
        templateContent = templateContent.replaceAll('<!\\[CDATA\\[', ''); // replace '<![CDATA['
        templateContent= templateContent.replaceAll('\\]\\]>', ''); // replace ']]'
        System.debug('templateContent>>>'+ templateContent);
        objemailwrapper.msgbody =templateContent; 
        objemailwrapper.filePath =''; 
        objemailwrapper.partyId ='PARTY_ID'; 
        
        return objemailwrapper;
    }
    public static ARTL_TaskEmailController.emailWrapper getServiceHandoverEmailTemplate(String recordId, String emailTemplateName){
        ARTL_TaskEmailController.emailWrapper objemailwrapper = new ARTL_TaskEmailController.emailWrapper();
        string templateContent = null;
        EmailTemplate objemail = new EmailTemplate();
		objemail = [Select Id,Name,Body,HtmlValue,IsActive,Subject,Markup,TemplateType FROM EmailTemplate 
                        WHERE DeveloperName =:emailTemplateName];
        if(objemail != null){
        	if(objemail.TemplateType == 'html'){
                templateContent = objemail.HtmlValue;
            }else if(objemail.TemplateType == 'visualforce'){
                templateContent = objemail.Markup;
                objemailwrapper.subject = objemail.Subject;
            }
    	}
        String cclist = '';
        String tolist = '';
        List<Order> orderList = new List<Order>();
        orderList = getOrderdetails(recordId);
        if(!orderList.isEmpty()){
            String customerAddress = orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingStreet + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCity + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingState + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCountry + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode;
        	DateTime dT = System.now();
            Date d = Date.newInstance(dT.year(), dT.month(), dT.day());
            String todaysDate = String.valueOf(dT.day())+' ' + String.valueOf(dT.format('MMMM'))+', ' +String.valueOf(dT.year());
            templateContent = orderList[0].Account.name != null ? templateContent.replaceAll('AccountName',
                                    orderList[0].Account.name):templateContent.replaceAll('AccountName', '');
            templateContent = orderList[0].vlocity_cmt__ParentOrderId__r.OrderNumber != null ? templateContent.replaceAll('OrderNumber',
                              orderList[0].vlocity_cmt__ParentOrderId__r.OrderNumber):templateContent.replaceAll('OrderNumber', '');
            templateContent = String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoDate__c) != null ? templateContent.replaceAll('PoDate',
                                    String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoDate__c)):templateContent.replaceAll('PoDate', '');
            templateContent = String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c) != null ? templateContent.replaceAll('PoNumber',
                              String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c)):templateContent.replaceAll('PoNumber', '');
            templateContent = todaysDate != null ? templateContent.replaceAll('BillingStartDate',
                                    todaysDate):templateContent.replaceAll('BillingStartDate', '');
            templateContent = customerAddress != null ? templateContent.replaceAll('CustomerAddress',
                              customerAddress):templateContent.replaceAll('CustomerAddress', '');
            templateContent = String.valueOf(orderList[0].vlocity_cmt__OneTimeTotal__c) + ' INR' != null ? templateContent.replaceAll('Onetimecharge',
                               String.valueOf(orderList[0].vlocity_cmt__OneTimeTotal__c) + ' INR'):templateContent.replaceAll('Onetimecharge', '');
        	templateContent = String.valueOf(orderList[0].ARTL_AnnualRecurringTotal__c)+ ' INR' != null ? templateContent.replaceAll('AnnualRecurringCharge',
                              String.valueOf(orderList[0].ARTL_AnnualRecurringTotal__c)+ ' INR'):templateContent.replaceAll('AnnualRecurringCharge', '');
            
           
        	if(orderList[0].vlocity_cmt__QuoteId__r.PM__c != null){
                if(orderList[0].vlocity_cmt__QuoteId__r.PM__r.Email != null){
                	tolist = orderList[0].vlocity_cmt__QuoteId__r.PM__r.Email;
                }
                if(orderList[0].vlocity_cmt__QuoteId__r.PM__r.Manager.Email != null && tolist != null){
                	tolist =tolist+';'+ orderList[0].vlocity_cmt__QuoteId__r.PM__r.Manager.Email;
                }
                else if(orderList[0].vlocity_cmt__QuoteId__r.PM__r.Manager.Email != null){
                    tolist =orderList[0].vlocity_cmt__QuoteId__r.PM__r.Manager.Email;
                }
            }
            objemailwrapper = getCustomerTOEmailAddress(orderList[0].AccountId,objemailwrapper);
            objemailwrapper = getCustomerCCEmailAddress(orderList[0].OpportunityId,objemailwrapper);
        	//objemailwrapper.invoiceNo = orderList[0].Id;
            //objemailwrapper.productName = orderList[0].vlocity_cmt__QuoteId__r.Product_Family__c != null ? orderList[0].vlocity_cmt__QuoteId__r.Product_Family__c :'';
            objemailwrapper.custNo = orderList[0].Account.AccountNumber;
            objemailwrapper.nbaId = orderList[0].Account.AccountNumber;
            objemailwrapper.accountNo =orderList[0].Account.AccountNumber != null ? orderList[0].Account.AccountNumber : '';
        }
        
        // get all OLI
            List<OrderItem> rootOrderLineItm = getOrderItems(orderList[0].Id);
            templateContent = populateOLIDetails(rootOrderLineItm, templateContent);
        	objemailwrapper.productName = ProductType;
            
            templateContent = templateContent.remove('%').remove('%');
            templateContent = templateContent.replaceAll('"','\'');
            templateContent = templateContent.replaceAll('<!\\[CDATA\\[', ''); // replace '<![CDATA['
            templateContent= templateContent.replaceAll('\\]\\]>', ''); // replace ']]'
            System.debug('templateContent>>>'+ templateContent);
            objemailwrapper.msgbody =templateContent; 
            objemailwrapper.filePath =''; 
            objemailwrapper.partyId ='PARTY_ID';
        return objemailwrapper;
    }
    public static ARTL_TaskEmailController.emailWrapper getLOCRejectEmailTemplate(String recordId, String emailTemplateName){
        ARTL_TaskEmailController.emailWrapper objemailwrapper = new ARTL_TaskEmailController.emailWrapper();
        string templateContent = null;
        EmailTemplate objemail = new EmailTemplate();
		objemail = [Select Id,Name,Body,HtmlValue,IsActive,Subject,Markup,TemplateType FROM EmailTemplate 
                        WHERE DeveloperName =:emailTemplateName];
        if(objemail != null){
        	if(objemail.TemplateType == 'html'){
                templateContent = objemail.HtmlValue;
            }else if(objemail.TemplateType == 'visualforce'){
                templateContent = objemail.Markup;
                objemailwrapper.subject = objemail.Subject;
            }
    	}
        String cclist = '';
        String tolist = '';
        List<Order> orderList = new List<Order>();
        orderList = getOrderdetails(recordId);
        if(!orderList.isEmpty()){
            String customerAddress = orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingStreet + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCity + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingState + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCountry + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode;
        	
            templateContent = templateContent.replaceAll('ParentOrderNumber',orderList[0].vlocity_cmt__ParentOrderId__c != null ? orderList[0].vlocity_cmt__ParentOrderId__r.OrderNumber:'');
            templateContent = templateContent.replaceAll('OrderNumber',orderList[0].OrderNumber);
            templateContent = templateContent.replaceAll('AccountName',orderList[0].Account.name);
            //templateContent = templateContent.replaceAll('Product2',orderList[0].vlocity_cmt__QuoteId__r.Product_Family__c != null ? String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.Product_Family__c):'');
            templateContent = templateContent.replaceAll('ProjectManager',orderList[0].vlocity_cmt__QuoteId__r.PM_Name__c != null ? orderList[0].vlocity_cmt__QuoteId__r.PM_Name__c:'');
            templateContent = templateContent.replaceAll('ManagerPhone',orderList[0].vlocity_cmt__QuoteId__r.PM_Phone__c != null ? orderList[0].vlocity_cmt__QuoteId__r.PM_Phone__c:'');
            templateContent = templateContent.replaceAll('ManagerEmail',orderList[0].vlocity_cmt__QuoteId__r.PM_Email__c != null ? orderList[0].vlocity_cmt__QuoteId__r.PM_Email__c:'');
            templateContent = templateContent.replaceAll('ManagerProjectLead',orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead__c != null ? orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead__c:'');
            templateContent = templateContent.replaceAll('ProjectLeadPhone',orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead_Phone__c != null ? orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead_Phone__c:'');
            templateContent = templateContent.replaceAll('ProjectLeadEmail',orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead_Email__c != null ? orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead_Email__c:'');
        	templateContent = String.valueOf(orderList[0].ShippingAddress) != null ? templateContent.replaceAll('ShippingAddress',
                              String.valueOf(orderList[0].ShippingAddress)):templateContent.replaceAll('ShippingAddress', '');
            templateContent = orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoDate__c != null ? templateContent.replaceAll('PoDate',
                                    String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoDate__c)):templateContent.replaceAll('PoDate', '');
            templateContent = orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c != null ? templateContent.replaceAll('PoNumber',
                                    orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c):templateContent.replaceAll('PoNumber', '');
            templateContent = orderList[0].vlocity_cmt__QuoteId__r.PO_Value__c != null ? templateContent.replaceAll('PoValue',
                                    String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.PO_Value__c)):templateContent.replaceAll('PoValue', '');
            templateContent = orderList[0].vlocity_cmt__QuoteId__r.PO_Term__c != null ? templateContent.replaceAll('PoTerm',
                                    orderList[0].vlocity_cmt__QuoteId__r.PO_Term__c):templateContent.replaceAll('PoTerm', '');
			templateContent = orderList[0].Billing_Start_Date__c != null ? templateContent.replaceAll('BillingStartDate',
                                    String.valueOf(orderList[0].Billing_Start_Date__c)):templateContent.replaceAll('BillingStartDate', '');
            templateContent = String.valueOf(orderList[0].Customer_Name__c) != null ? templateContent.replaceAll('DeliveryContactName',
                              String.valueOf(orderList[0].Customer_Name__c)):templateContent.replaceAll('DeliveryContactName', '');
            templateContent = String.valueOf(orderList[0].Customer_Email__c) != null ? templateContent.replaceAll('DeliveryEmail',
                              String.valueOf(orderList[0].Customer_Email__c)):templateContent.replaceAll('DeliveryEmail', '');
            templateContent = templateContent.replaceAll('BillingAddress',customerAddress);
            templateContent = orderList[0].Billing_Start_Date__c != null ? templateContent.replaceAll('CommissioningDate',
                                    String.valueOf(orderList[0].Billing_Start_Date__c)):templateContent.replaceAll('CommissioningDate', '');
            //templateContent = templateContent.replaceAll('GracePeriodDate',''); 
            //objemailwrapper.subject = objemailwrapper.subject.replaceAll('OrderNumber',orderList[0].OrderNumber != null ? orderList[0].OrderNumber: '');
            //objemailwrapper.invoiceNo = orderList[0].Id;
            //objemailwrapper.productName = orderList[0].Product_Family__c != null ? orderList[0].Product_Family__c :'Demo Product';
            objemailwrapper.custNo = orderList[0].Account.AccountNumber;
            objemailwrapper.nbaId = orderList[0].Account.AccountNumber;
            objemailwrapper.accountNo =orderList[0].Account.AccountNumber;
            if(objemailwrapper.subject != null)
        		objemailwrapper.subject = objemailwrapper.subject.replace('OrderNumber',orderList[0].OrderNumber);
        }
            // get all OLI
            List<OrderItem> rootOrderLineItm = getOrderItems(orderList[0].Id);
        	System.debug('rootOrderLineItm>>>'+rootOrderLineItm);
            templateContent = populateOLIDetails(rootOrderLineItm, templateContent);
        	objemailwrapper.productName = ProductType;
        	
            //tolist=tolist +';'+'a_Abinash.Barik@airtel.com';
            //objemailwrapper.tolist =tolist; 
            objemailwrapper = getCustomerTOEmailAddress(orderList[0].AccountId,objemailwrapper);
            objemailwrapper = getCustomerCCEmailAddress(orderList[0].OpportunityId,objemailwrapper);
            templateContent = templateContent.remove('%').remove('%');
            templateContent = templateContent.replaceAll('"','\'');
            templateContent = templateContent.replaceAll('<!\\[CDATA\\[', ''); // replace '<![CDATA['
            templateContent= templateContent.replaceAll('\\]\\]>', ''); // replace ']]'
            System.debug('templateContent>>>'+ templateContent);
            objemailwrapper.msgbody =templateContent; 
            objemailwrapper.filePath =''; 
            objemailwrapper.partyId ='PARTY_ID';
        
        return objemailwrapper;
    }
    
    public static ARTL_TaskEmailController.emailWrapper getNonDeemedLOCEmailTemplate(String recordId, String emailTemplateName){
        System.debug('getNonDeemedLOCEmailTemplate>>>'+emailTemplateName);
        ARTL_TaskEmailController.emailWrapper objemailwrapper = new ARTL_TaskEmailController.emailWrapper();
        string templateContent = null;
        EmailTemplate objemail = new EmailTemplate();
		objemail = [Select Id,Name,Body,HtmlValue,IsActive,Subject,Markup,TemplateType FROM EmailTemplate 
                        WHERE DeveloperName =:emailTemplateName];
        if(objemail != null){
        	if(objemail.TemplateType == 'html'){
                templateContent = objemail.HtmlValue;
            }else if(objemail.TemplateType == 'visualforce'){
                templateContent = objemail.Markup;
                objemailwrapper.subject = objemail.Subject;
            }
    	}
        String cclist = '';
        String tolist = '';
        List<Order> orderList = new List<Order>();
        orderList = getOrderdetails(recordId);
        if(!orderList.isEmpty()){
            String customerAddress = orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingStreet + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCity + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingState + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCountry + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode;
        	
            templateContent = orderList[0].OrderNumber != null ? templateContent.replaceAll('OrderNumber',
				orderList[0].OrderNumber):templateContent.replaceAll('OrderNumber', '');
            templateContent = orderList[0].Account.name != null ? templateContent.replaceAll('AccountName',
				orderList[0].Account.name):templateContent.replaceAll('AccountName', '');
            templateContent = orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__Type__c != null ? templateContent.replaceAll('OrderType',
				orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__Type__c):templateContent.replaceAll('OrderType', '');
            templateContent = String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoDate__c) != null ? templateContent.replaceAll('PoDate',
                                    String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoDate__c)):templateContent.replaceAll('PoDate', '');
            templateContent = String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.PO_Value__c) != null ? templateContent.replaceAll('PoValue',
                              String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.PO_Value__c)):templateContent.replaceAll('PoValue', '');
            templateContent = String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.PO_Term__c) != null ? templateContent.replaceAll('PoTerm',
                                    String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.PO_Term__c)):templateContent.replaceAll('PoTerm', '');
            templateContent = String.valueOf(orderList[0].ContractId) != null ? templateContent.replaceAll('CafNumber',
                              String.valueOf(orderList[0].ContractId)):templateContent.replaceAll('CafNumber', '');
			templateContent = String.valueOf(orderList[0].ShippingAddress) != null ? templateContent.replaceAll('ShippingAddress',
                              String.valueOf(orderList[0].ShippingAddress)):templateContent.replaceAll('ShippingAddress', '');
			templateContent = String.valueOf(orderList[0].Customer_Name__c) != null ? templateContent.replaceAll('DeliveryContactName',
                              String.valueOf(orderList[0].Customer_Name__c)):templateContent.replaceAll('DeliveryContactName', '');
            templateContent = String.valueOf(orderList[0].Customer_Email__c) != null ? templateContent.replaceAll('DeliveryEmail',
                              String.valueOf(orderList[0].Customer_Email__c)):templateContent.replaceAll('DeliveryEmail', '');
            
            templateContent = orderList[0].vlocity_cmt__QuoteId__r.PM_Name__c != null ? templateContent.replaceAll('ProjectManager',
				orderList[0].vlocity_cmt__QuoteId__r.PM_Name__c):templateContent.replaceAll('ProjectManager', '');
            
            templateContent = orderList[0].vlocity_cmt__QuoteId__r.PM_Phone__c != null ? templateContent.replaceAll('ManagerPhone',
				orderList[0].vlocity_cmt__QuoteId__r.PM_Phone__c):templateContent.replaceAll('ManagerPhone', '');
            templateContent = orderList[0].vlocity_cmt__QuoteId__r.PM_Email__c != null ? templateContent.replaceAll('ManagerEmail',
				orderList[0].vlocity_cmt__QuoteId__r.PM_Email__c):templateContent.replaceAll('ManagerEmail', '');
            templateContent = orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead__c != null ? templateContent.replaceAll('ManagerProjectLead',
				orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead__c):templateContent.replaceAll('ManagerProjectLead', '');
            templateContent = orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead_Phone__c != null ? templateContent.replaceAll('ProjectLeadPhone',
				orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead_Phone__c):templateContent.replaceAll('ProjectLeadPhone', '');
            templateContent = orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead_Email__c != null ? templateContent.replaceAll('ProjectLeadEmail',
				orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead_Email__c):templateContent.replaceAll('ProjectLeadEmail', '');
        	templateContent = orderList[0].Billing_Start_Date__c != null ? templateContent.replaceAll('BillingStartDate',
                                    String.valueOf(orderList[0].Billing_Start_Date__c)):templateContent.replaceAll('BillingStartDate', '');
            templateContent = String.valueOf(orderList[0].Customer_Name__c) != null ? templateContent.replaceAll('DeliveryContactName',
                              String.valueOf(orderList[0].Customer_Name__c)):templateContent.replaceAll('DeliveryContactName', '');
            templateContent = String.valueOf(orderList[0].Customer_Email__c) != null ? templateContent.replaceAll('DeliveryEmail',
                              String.valueOf(orderList[0].Customer_Email__c)):templateContent.replaceAll('DeliveryEmail', '');
            templateContent = templateContent.replaceAll('BillingAddress',customerAddress);
            templateContent = orderList[0].Billing_Start_Date__c != null ? templateContent.replaceAll('CommissioningDate',
                                    String.valueOf(orderList[0].Billing_Start_Date__c)):templateContent.replaceAll('CommissioningDate', '');
            
            objemailwrapper.subject = objemailwrapper.subject.replaceAll('OrderNumber',orderList[0].OrderNumber);
        	//objemailwrapper.invoiceNo = orderList[0].Id;
            //objemailwrapper.productName = orderList[0].Product_Family__c != null ? orderList[0].Product_Family__c :'Demo Product';
            objemailwrapper.custNo = orderList[0].Account.AccountNumber;
            objemailwrapper.nbaId = orderList[0].Account.AccountNumber;
            objemailwrapper.accountNo =orderList[0].Account.AccountNumber;
        
        }
		// get all OLI
            List<OrderItem> rootOrderLineItm = getOrderItems(orderList[0].Id); 
            templateContent = populateOLIDetails(rootOrderLineItm, templateContent);
        	objemailwrapper.productName = ProductType;
            
        	objemailwrapper = getCustomerTOEmailAddress(orderList[0].AccountId,objemailwrapper);
            objemailwrapper = getCustomerCCEmailAddress(orderList[0].OpportunityId,objemailwrapper);
            //tolist=tolist +';'+'a_Abinash.Barik@airtel.com';
            //objemailwrapper.tolist =tolist; 
            templateContent = templateContent.remove('%').remove('%');
            templateContent = templateContent.replaceAll('"','\'');
            templateContent = templateContent.replaceAll('<!\\[CDATA\\[', ''); // replace '<![CDATA['
            templateContent= templateContent.replaceAll('\\]\\]>', ''); // replace ']]'
            System.debug('templateContent>>>'+ templateContent);
            objemailwrapper.msgbody =templateContent; 
            objemailwrapper.filePath =''; 
            objemailwrapper.partyId ='PARTY_ID';
        System.debug('objemailwrapper>>>'+objemailwrapper);
        return objemailwrapper;
    }
    
    public static ARTL_TaskEmailController.emailWrapper getCustomerTOEmailAddress(String accountId, ARTL_TaskEmailController.emailWrapper objemailwrapper){
        String tolist = '';
        for(Contact con: [Select Id,Email FROM Contact WHERE AccountId=:accountId AND Email != null 
                          AND (ARTL_Contact_Role__c ='Delivery Contact' OR ARTL_Contact_Role__c ='Billing Contact')]){
            tolist=tolist +';'+con.Email;
        }
        //tolist=tolist +';'+'a_Abinash.Barik@airtel.com';
        objemailwrapper.tolist =tolist;
        
        System.debug('to Emails>>>'+objemailwrapper.tolist);
        return objemailwrapper;
    }
    public static ARTL_TaskEmailController.emailWrapper getCustomerCCEmailAddress(String opportunityId, ARTL_TaskEmailController.emailWrapper objemailwrapper){
        String cclist = '';
        for(Opportunity opp: [Select Id,PM__r.email,PM__r.manager.email,Owner.email,Owner.Manager.email 
                              FROM Opportunity WHERE Id=:opportunityId]){
            cclist+=';'+opp.PM__r.email;
			cclist+=';'+opp.PM__r.manager.email;
			cclist+=';'+opp.Owner.email;
			cclist+=';'+opp.Owner.Manager.email;
        }
        cclist=cclist +';'+'a_Abinash.Barik@airtel.com';
        objemailwrapper.cclist =cclist;
        System.debug('CC Emails>>>'+objemailwrapper.cclist);
        return objemailwrapper;
    }
    public static List<OrderItem> getOrderItems(String orderId){
        List<OrderItem> rootOrderLineItm = [Select Id,vlocity_cmt__AttributeSelectedValues__c,Product2.ProductCode,
						Product2.Family,vlocity_cmt__RootItemId__c, ARTL_LSI__c,ARTL_Service_Type__c,ARTL_RouterMake__c,
							ARTL_RouterModel__c 
							from OrderItem 
							WHERE (OrderId =: orderId OR Order.vlocity_cmt__ParentOrderId__c =:OrderId) 
                                            AND vlocity_cmt__ParentItemId__c = null];
        System.debug('rootOrderLineItm>>>'+rootOrderLineItm);
        return rootOrderLineItm;
    }
    public Static String populateOLIDetails(List<OrderItem> rootOrderLineItm, String templateContent){
        String Circuitid;
        String ServiceType;
        if(!rootOrderLineItm.isEmpty()){
            for(OrderItem oli: rootOrderLineItm){
                if(ProductType == ''){
                    ProductType = oli.Product2.Family;
                }else if(!ProductType.contains(oli.Product2.Family)){
                    ProductType +=','+ oli.Product2.Family;
                }
                System.debug('Family>>>'+oli.Product2.Family + '===ProductType===' +ProductType );
                if(Circuitid == null){
                    Circuitid = String.valueOf(oli.ARTL_LSI__c);
                }
                if(ServiceType == null){
                    ServiceType = String.valueOf(oli.ARTL_Service_Type__c);
                }
                templateContent = Circuitid != null ? templateContent.replaceAll('Circuitid',Circuitid):templateContent.replaceAll('Circuitid','');
                templateContent = ServiceType !=null ? templateContent.replaceAll('ServiceType',ServiceType):templateContent.replaceAll('ServiceType','');
                templateContent = oli.ARTL_RouterMake__c != null ? templateContent.replaceAll('RouterMake',
                                                                                              oli.ARTL_RouterMake__c):templateContent.replaceAll('RouterMake', '');
                templateContent = oli.ARTL_RouterModel__c != null ? templateContent.replaceAll('RouterModel',
                                                                                               oli.ARTL_RouterModel__c):templateContent.replaceAll('RouterModel', '');
                if(oli.vlocity_cmt__AttributeSelectedValues__c != NULL){
                    Map<String, Object> attributeQuoteLineMap = (Map<String, Object>) JSON.deserializeUntyped(oli.vlocity_cmt__AttributeSelectedValues__c);
                    String Bandwidth = String.valueOf(attributeQuoteLineMap.get('ATT_ACCESS_BANDWIDTH'));
                    String Media = String.valueOf(attributeQuoteLineMap.get('ATT_MEDIA'));
                    String Manageability = String.valueOf(attributeQuoteLineMap.get('ATT_SERVICE_TYPE'));                                     
                    templateContent = Bandwidth != null ? templateContent.replaceAll('Bandwidth2',Bandwidth): templateContent.replaceAll('Bandwidth2','');
                    templateContent = Media != null ? templateContent.replaceAll('Media2',Media): templateContent.replaceAll('Media2','');
                    templateContent = Manageability != null ? templateContent.replaceAll('Manageability2',Manageability): templateContent.replaceAll('Manageability2','');
                }else{
                    templateContent = templateContent.replaceAll('Bandwidth2','');
                    templateContent = templateContent.replaceAll('Media2','');
                    templateContent = templateContent.replaceAll('Manageability2','');
                    
                }
            }
        }else{
            templateContent = templateContent.replaceAll('Bandwidth2','');
            templateContent = templateContent.replaceAll('Media2','');
            templateContent = templateContent.replaceAll('Manageability2','');
            templateContent = templateContent.replaceAll('RouterMake','');
            templateContent = templateContent.replaceAll('RouterModel','');
            templateContent = templateContent.replaceAll('Circuitid','');
            templateContent = templateContent.replaceAll('ServiceType','');
        }
        System.debug('ProductType>>>'+ProductType);
		templateContent = ProductType != null ? templateContent.replaceAll('Product2',ProductType):'';
        return templateContent;
    }
    public Static String populateQLIDetails(String quoteId, String templateContent){
        List<QuoteLineItem> lstQLI = [Select Id,Product2.Family  FROM QuoteLineItem WHERE QuoteId=:quoteId
                                     AND vlocity_cmt__ParentItemId__c = null];
        if(!lstQLI.isEmpty()){
            for(QuoteLineItem qli: lstQLI){
                if(ProductType == ''){
                    ProductType = qli.Product2.Family;
                }else if(!ProductType.contains(qli.Product2.Family)){
                    ProductType +=','+ qli.Product2.Family;
                }
                System.debug('Family>>>'+qli.Product2.Family + '===ProductType===' +ProductType );
            }
        }
        System.debug('ProductType>>>'+ProductType);
		templateContent = templateContent.replaceAll('Quote.Product_Family__c',ProductType);
        return templateContent;
    }
    public static List<Order> getOrderdetails(String recordId){
        List<Order> orderList = [SELECT Id,Account.name, OrderNumber,Account.AccountNumber,ARTL_OrderType__c,ContractId,
                     	ShippingAddress,Customer_Name__c,Customer_Email__c,Product_Family__c,OpportunityId,
                        vlocity_cmt__ParentOrderId__c, vlocity_cmt__ParentOrderId__r.OrderNumber,
                        vlocity_cmt__QuoteId__r.vlocity_cmt__PoDate__c,Billing_Start_Date__c, 
                        vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c,Type,
                        vlocity_cmt__QuoteId__r.PO_Term__c,vlocity_cmt__QuoteId__r.Product_Family__c,
                        vlocity_cmt__QuoteId__r.PO_Value__c,ARTL_AnnualRecurringTotal__c, vlocity_cmt__OneTimeTotal__c,
                        vlocity_cmt__QuoteId__c,vlocity_cmt__QuoteId__r.PM_Name__c,
                     	vlocity_cmt__QuoteId__r.PM__c,vlocity_cmt__QuoteId__r.PM__r.Email,
                        vlocity_cmt__QuoteId__r.PM_Phone__c,vlocity_cmt__QuoteId__r.PM_Email__c,
                     	vlocity_cmt__QuoteId__r.PM__r.Manager.Email,vlocity_cmt__QuoteId__r.vlocity_cmt__Type__c,
                     	vlocity_cmt__DefaultServiceAccountId__r.ShippingStreet,
                     	vlocity_cmt__DefaultServiceAccountId__r.ShippingCity, 
                     	vlocity_cmt__DefaultServiceAccountId__r.ShippingState, 
                     	vlocity_cmt__DefaultServiceAccountId__r.ShippingCountry, 
                     	vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode,vlocity_cmt__QuoteId__r.PM_Team_Lead__c,
                     	vlocity_cmt__QuoteId__r.PM_Team_Lead_Email__c, vlocity_cmt__QuoteId__r.PM_Team_Lead_Phone__c  
                        FROM Order WHERE id =: recordId];
         return orderList;               
    }
    
    public static string createActivity(String recordId, String emailType){
        Task newtask = new Task();
        newtask.WhatId = recordId;
        newtask.Subject = emailType;
        newtask.Status = 'Completed';
        
        insert newtask;
        
        return newtask.Id;
    } 
  
}