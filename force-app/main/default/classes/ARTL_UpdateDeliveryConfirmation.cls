public class ARTL_UpdateDeliveryConfirmation {

    @InvocableMethod(label= 'Update Order Item')
    public static void updateDeliveryConfirmation(List<inputVariables> inputs){
        OrderItem ordrItem = new OrderItem();
        Product2 ECRprod = new Product2();
        List<Id> ordIds = new List<Id>();
        for(inputVariables input : inputs){
        	ordrItem = input.ordItem;
            ECRprod = input.ECRproduct;
        }
        //Product2 ECRprod = [Select Id From Product2 where ProductCode = '2808c41f-a83c-492d-bba9-9bf09e3d8247'];
        List<OrderItem> ordItemList = [Select Id , ARTL_Delivery_Confirmation__c,vlocity_cmt__AttributeSelectedValues__c From OrderItem where Product2Id = :ECRprod.Id AND OrderId = :ordrItem.OrderId];
        for(OrderItem ordItm : ordItemList){
            if(ordItm.vlocity_cmt__AttributeSelectedValues__c!=null){
        	Map<String,Object> attrJSON = (Map<String,Object>) JSON.deserializeUntyped(ordItm.vlocity_cmt__AttributeSelectedValues__c);
                if(attrJSON.get('ATT_ROUTER_TYPE' ) == 'Non-Standard'){
        			ordItm.ARTL_Delivery_Confirmation__c = ordrItem.ARTL_Delivery_Confirmation__c; 
                }
            }
        }
        update ordItemList;
    }
    
    public class inputVariables{
        @InvocableVariable(label='Order Item')
        public OrderItem ordItem;
        
        @InvocableVariable(label='Product')
        public Product2 ECRproduct;
    }
}