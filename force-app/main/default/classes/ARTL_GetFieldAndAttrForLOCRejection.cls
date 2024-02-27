public class ARTL_GetFieldAndAttrForLOCRejection {
    
    public PageReference save() {
        return null;
    }
    
    public String OrderNumber { get; set; }
    public String todaysDate { get; set; }
    public String Product { get; set; }
    public String Onetimecharge { get; set; }
    public String AnnualRecurringCharge { get; set; }
    public String AccountName { get; set; }
    public String PODate { get; set; }
    public String PONumber { get; set; }
    public String ciruitId { get; set; }
    public String manageability { get; set; }
    public String masterOrder {get; set;}
    public String subOrder {get; set;}
    public String customerAddress {get;set;}
    public String bandWidth {get;set;}
    public String media {get;set;}
    public String projectmanager {get;set;}
    public String projectManagerPhone {get;set;}
    public String projectManagerEmail {get;set;}
    public String projectmanagerlead {get;set;}
    public String projectManagerleadPhone {get;set;}
    public String projectManagerleadEmail {get;set;}
	public Id ordId {get;set;}
    
    public Boolean getOrderRelDetails()
    {
        List<Order> orderList;
        orderList = [
                        SELECT Id,Account.name, OrderNumber,
                        vlocity_cmt__ParentOrderId__c, vlocity_cmt__ParentOrderId__r.OrderNumber,
                        vlocity_cmt__QuoteId__r.vlocity_cmt__PoDate__c, 
                        vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c,
                        vlocity_cmt__QuoteId__r.PO_Term__c,vlocity_cmt__QuoteId__r.Product_Family__c,
                        vlocity_cmt__QuoteId__r.PO_Value__c,ARTL_AnnualRecurringTotal__c, vlocity_cmt__OneTimeTotal__c,
                        vlocity_cmt__QuoteId__c,vlocity_cmt__QuoteId__r.PM_Name__c,
                        vlocity_cmt__QuoteId__r.PM_Phone__c,vlocity_cmt__QuoteId__r.PM_Email__c,vlocity_cmt__DefaultServiceAccountId__r.ShippingStreet,vlocity_cmt__DefaultServiceAccountId__r.ShippingCity, vlocity_cmt__DefaultServiceAccountId__r.ShippingState, vlocity_cmt__DefaultServiceAccountId__r.ShippingCountry, vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode,vlocity_cmt__QuoteId__r.PM_Team_Lead__c,vlocity_cmt__QuoteId__r.PM_Team_Lead_Email__c, vlocity_cmt__QuoteId__r.PM_Team_Lead_Phone__c  
                        FROM Order 
            			where id =: ordId
        ];
        
        String quoteId = orderList[0].vlocity_cmt__QuoteId__c;
        PODate = String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoDate__c);
        PONumber = String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c);
        Onetimecharge = String.valueOf(orderList[0].vlocity_cmt__OneTimeTotal__c) + ' INR';
    	AnnualRecurringCharge = String.valueOf(orderList[0].ARTL_AnnualRecurringTotal__c)+ ' INR';
        Product = String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.Product_Family__c);
         
        DateTime dT = System.now();
		Date d = Date.newInstance(dT.year(), dT.month(), dT.day());
        todaysDate = String.valueOf(dT.day())+' ' + String.valueOf(dT.format('MMMM'))+', ' +String.valueOf(dT.year());
        // get all QLI
        List<QuoteLineItem> rootQuoteLineItm = [
            									select id,vlocity_cmt__AttributeSelectedValues__c,Product2.ProductCode,ARTL_LSI__c,
            									vlocity_cmt__RootItemId__c from QuoteLineItem 
        										where QuoteId =: quoteId
        ];
        
        for(QuoteLineItem qli: rootQuoteLineItm){
            if(qli.vlocity_cmt__RootItemId__c == '')
            {
                ciruitId = String.valueOf(qli.ARTL_LSI__c);
            }
            if(qli.vlocity_cmt__AttributeSelectedValues__c != NULL && (qli.Product2.ProductCode == 'VEPC_PRIMARY_LINK' || qli.Product2.ProductCode == 'VEPC_SECONDARY_LINK' || qli.Product2.ProductCode == 'VEPC_PRIMARY_MPLS_LINK' || qli.Product2.ProductCode == 'VEPC_SECONDARY_MPLS_LINK')){
                Map<String, Object> attributeQuoteLineMap = (Map<String, Object>) JSON.deserializeUntyped(qli.vlocity_cmt__AttributeSelectedValues__c);
                bandWidth = String.valueOf(attributeQuoteLineMap.get('ATT_ACCESS_BANDWIDTH'));
                media = String.valueOf(attributeQuoteLineMap.get('ATT_MEDIA'));
                manageability = String.valueOf(attributeQuoteLineMap.get('ATT_SERVICE_TYPE'));
            }
            
        }                                           
       
        AccountName = orderList[0].Account.name;
        masterOrder = orderList[0].vlocity_cmt__ParentOrderId__r.OrderNumber;
        subOrder = orderList[0].OrderNumber;
        customerAddress = orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingStreet + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCity + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingState + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingCountry + orderList[0].vlocity_cmt__DefaultServiceAccountId__r.ShippingPostalCode;
        projectmanager =  orderList[0].vlocity_cmt__QuoteId__r.PM_Name__c;
        projectManagerPhone = orderList[0].vlocity_cmt__QuoteId__r.PM_Phone__c;
        projectManagerEmail = orderList[0].vlocity_cmt__QuoteId__r.PM_Email__c;
        projectmanagerlead =  orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead__c;
        projectManagerleadPhone = orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead_Phone__c;
        projectManagerleadEmail = orderList[0].vlocity_cmt__QuoteId__r.PM_Team_Lead_Email__c;
        return true;
    }
     
}