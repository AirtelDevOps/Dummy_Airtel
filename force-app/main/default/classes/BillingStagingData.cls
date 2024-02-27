global class BillingStagingData implements vlocity_cmt.VlocityOpenInterface{

    private Static final String BILLING_STAGING = 'SELECT id, NBA_Account_Number__c, LSI__c, Legal_Entity__c, Billing_Type__c, License_Company__c, Bill_Format__c, Billing_Level__c, PO__c, PO_Amount__c, PO_Start_Date__c, PO_End_Date__c, StandardReasonforTaxExemption__c, PO_Group__c, BCP_Id__c, DCP_Id__c, Billing_Address__c, InvoiceShipmentAddress__c, Quote_Line_Item__c FROM ARTL_Billing_Staging__c WHERE Quote_Line_Item__c IN :itemIds';
    private Static final String PARENT_QLI = 'SELECT id, vlocity_cmt__RootItemId__c FROM QuoteLineItem WHERE Product2.ProductCode =: productCode AND QuoteId =: quoteId';
    private Static final String CHILD_QLI = 'SELECT id, vlocity_cmt__AttributeSelectedValues__c FROM QuoteLineItem WHERE vlocity_cmt__RootItemId__c IN : rootItemIds AND Product2.ARTL_LSIRequired__c= true AND QuoteId =: quoteId';


    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map < String, Object > output, Map < String, Object > options){

        if (methodName == 'getBillingStagingData')
            getBillingStagingData(input,output);

        else
            throw new BillingStagingDataException ('Unknown method: ' + methodName );
 
        return true;
	}
    
    public static void getBillingStagingData( Map<String,Object> input, Map<String,Object> output ){


        String productCode = (String)input.get('productCode');
        String quoteId = (String)input.get('quoteId');

        List<String> rootItemIds = new List<String>();
        List<SObject> parentQLIs = Database.query(PARENT_QLI);
        System.debug('🛟🛟🛟🛟 parentQLIs '+ parentQLIs);
        for (SObject qli : parentQLIs) {
            rootItemIds.add(String.valueOf(qli.get('vlocity_cmt__RootItemId__c')));
        }
        System.debug('🛟🛟🛟🛟 rootItemIds '+ rootItemIds);

        List<String> itemIds = new List<String>();
        List<Object> selectedAttributeJSON = new List<Object>();
        List<SObject> childQLIs = Database.query(CHILD_QLI);
        System.debug('🛟🛟🛟🛟 childQLIs '+ childQLIs);
        for (SObject qli : childQLIs) {
            itemIds.add(String.valueOf(qli.get('Id')));
            Map<String,Object> attrSelectedMap = ( Map<String,Object>)JSON.deserializeUntyped((String)qli.get('vlocity_cmt__AttributeSelectedValues__c'));
            attrSelectedMap.put('Quote_Line_Item__c', qli.Id);
            selectedAttributeJSON.add(attrSelectedMap);
        }
        System.debug('🛟🛟🛟🛟 selectedAttributeJSON '+ JSON.serialize(selectedAttributeJSON));


        List<SObject> billingStagingData = Database.query(BILLING_STAGING);
        selectedAttributeJSON.addAll(billingStagingData);
        output.put('selectedAttributeJSON', JSON.deserializeUntyped(JSON.serialize(selectedAttributeJSON)));
        // output.put('billingStagingData', selectedAttributeJSON);

    }

    public class BillingStagingDataException extends Exception{}
}