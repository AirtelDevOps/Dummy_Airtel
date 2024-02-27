public class Artel_getFieldAndAttr {
    
    public PageReference save() {
        return null;
    }
    
    
    public String AccountName { get; set; }
    public String ciruitId { get; set; }
    public String routerMake { get; set; }
    public String routerModel { get; set; }
    public String PODate { get; set; }
    public String PONumber { get; set; }
    public String POValue { get; set; }
    public String POTerm { get; set; }
    public String masterOrder {get; set;}
    public String customerAddress {get;set;}
    public String bandWidth {get;set;}
    public String media {get;set;}
    public String serviceType {get;set;}
    public String projectmanager {get;set;}
    public String projectManagerPhone {get;set;}
    public String projectManagerEmail {get;set;}
	public Id ordId {get;set;}
    
    public Boolean getOrderRelDetails()
    {
        List<Order> orderList;
        orderList = [
                        SELECT Id,Account.name,PoNumber,Account.billingstreet,
                        Account.billingcity,Account.billingstate,
                        Account.billingPostalCode,Account.BillingCountry, 
                        vlocity_cmt__ParentOrderId__c, 
                        vlocity_cmt__QuoteId__r.vlocity_cmt__PoDate__c, 
                        vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c,
                        vlocity_cmt__QuoteId__r.PO_Term__c,
                        vlocity_cmt__QuoteId__r.PO_Value__c,
                        vlocity_cmt__QuoteId__c,vlocity_cmt__QuoteId__r.PM_Name__c,
                        vlocity_cmt__QuoteId__r.PM_Phone__c,vlocity_cmt__QuoteId__r.PM_Email__c  
                        FROM Order 
            			where id =: ordId
        ];
        
        String quoteId = orderList[0].vlocity_cmt__QuoteId__c;
        PODate = String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoDate__c);
        POValue = String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.PO_Value__c);
        PONumber = String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.vlocity_cmt__PoNumber__c);
        POTerm = String.valueOf(orderList[0].vlocity_cmt__QuoteId__r.PO_Term__c);
        // get all QLI
        List<QuoteLineItem> rootQuoteLineItm = [
            									select id,vlocity_cmt__AttributeSelectedValues__c,Product2.ProductCode,ARTL_LSI__c,
            									ARTL_RouterMake__c,ARTL_RouterModel__c,vlocity_cmt__RootItemId__c from QuoteLineItem 
        										where QuoteId =: quoteId
        ];
        
        for(QuoteLineItem qli: rootQuoteLineItm){
            if(qli.vlocity_cmt__RootItemId__c == '')
            {
                ciruitId = String.valueOf(qli.ARTL_LSI__c);
            }
            if(qli.Product2.ProductCode == 'VEPC_ENTERPRISE_ICONNECTIVITY_ROUTERS'){
                routerMake = qli.ARTL_RouterMake__c;
                routerModel = qli.ARTL_RouterModel__c;
            }
            if(qli.vlocity_cmt__AttributeSelectedValues__c != NULL && (qli.Product2.ProductCode == 'VEPC_PRIMARY_LINK' || qli.Product2.ProductCode == 'VEPC_SECONDARY_LINK')){
                Map<String, Object> attributeQuoteLineMap = (Map<String, Object>) JSON.deserializeUntyped(qli.vlocity_cmt__AttributeSelectedValues__c);
                bandWidth = String.valueOf(attributeQuoteLineMap.get('ATT_ACCESS_BANDWIDTH'));
                media = String.valueOf(attributeQuoteLineMap.get('ATT_MEDIA'));
                serviceType = String.valueOf(attributeQuoteLineMap.get('ATT_SERVICE_TYPE'));
            }
            
        }                                           
       
        AccountName = orderList[0].Account.name;
        masterOrder = orderList[0].vlocity_cmt__ParentOrderId__c;
        customerAddress = orderList[0].Account.billingstreet+ orderList[0].Account.billingcity + orderList[0].Account.billingstate + orderList[0].Account.billingPostalCode+ orderList[0].Account.BillingCountry;
        projectmanager =  orderList[0].vlocity_cmt__QuoteId__r.PM_Name__c;
        projectManagerPhone = orderList[0].vlocity_cmt__QuoteId__r.PM_Phone__c;
        projectManagerEmail = orderList[0].vlocity_cmt__QuoteId__r.PM_Email__c;
          
        return true;
    }
    public void getapproveTask(){
        
        List<Task> t = [
            			select id,status,whatId,subject 
            			from task 
            			where whatId=: ordId 
            			AND subject like '%LOC Customer%' limit 1
        ];
        
        if(t.size() >0 ){
            Task tUpdate = new Task();
            tUpdate.Status = 'Completed';
            tUpdate.Id = t[0].Id;
            update tUpdate;
        }
        
    }
    public void getrejectTask(){
        
        List<Task> t = [
            			select id,status,whatId,subject 
            			from task 
            			where whatId=: ordId 
            			AND subject like '%LOC Customer%' limit 1
        ];
        if(t.size() > 0){
            Task tUpdate = new Task();
            tUpdate.Status = 'Rejected';
            tUpdate.Id = t[0].Id;
            update tUpdate;
        }
        
    }
    
    
}