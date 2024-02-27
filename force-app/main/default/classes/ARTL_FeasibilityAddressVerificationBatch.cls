/******************************************************************************************************
* @Author:      Rishab Kalra  <rishab.kalra@salesforce.com >
* @Company:     Salesforce
* @Date:        11-21-2023
* @Reviewer:
* @Review Date:
* @Description: For Address Verification of Feasibility Analysis and storing the response values to vlocity_cmt__QuoteMember__c
*******************************************************************************************************/

public class ARTL_FeasibilityAddressVerificationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
    private string quoteId;
    public  List<vlocity_cmt__QuoteMember__c> quoteMemberUpdateList = new List<vlocity_cmt__QuoteMember__c>();
    public ARTL_Integration_Details__c integrationDetail = ARTL_Integration_Details__c.getInstance('AddressVerification');
    private final String ADDRESS_VALIDATION_COMPLETED_EVENT = 'ADDRESS_VALIDATION_COMPLETED';

    public ARTL_FeasibilityAddressVerificationBatch(String quoteIdInput){
        quoteId = quoteIdInput;
    }
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        System.debug('DEBUGG quote id ' + quoteId);
        return Database.getQueryLocator([Select Id, ARTL_Feasibility_Geolocation__Latitude__s, 
                                         ARTL_Feasibility_Geolocation__Longitude__s, 
                                         ARTL_Feasibility_Error_Margin__c, vlocity_cmt__StreetAddress__c, vlocity_cmt__City__c,
                                         vlocity_cmt__State__c, vlocity_cmt__PostalCode__c, vlocity_cmt__Country__c
                                         From vlocity_cmt__QuoteMember__c 
                                         Where vlocity_cmt__QuoteId__c = :quoteId AND ARTL_Pincode_Validation_Result__c = 'Valid']);
    }
    public void execute(Database.BatchableContext bc, List<vlocity_cmt__QuoteMember__c> scope)
    {
        try{
            String addressString = '';
            //API details stored in Custom Setting - ARTL_Integration_Details__c
            //creation of address string for API request payload 
            for(vlocity_cmt__QuoteMember__c qm: scope){
                if(qm.vlocity_cmt__StreetAddress__c != null){
                    addressString = addressString + qm.vlocity_cmt__StreetAddress__c + ', ';
                }
                if(qm.vlocity_cmt__City__c != null){
                    addressString = addressString + qm.vlocity_cmt__City__c + ', ';
                }
                if(qm.vlocity_cmt__State__c != null){
                    addressString = addressString + qm.vlocity_cmt__State__c + ', ';
                }
                if(qm.vlocity_cmt__PostalCode__c != null){
                    addressString = addressString + qm.vlocity_cmt__PostalCode__c + ', ';
                }
                if(qm.vlocity_cmt__Country__c != null){
                    addressString = addressString + qm.vlocity_cmt__Country__c;
                }
                
                String requestJson = '{"requestorSource": "B2B","address": {"city": '+((qm.vlocity_cmt__City__c != null)?'"'+qm.vlocity_cmt__City__c+'"': null )+',"addressString": "'+ addressString+'"} }';
                System.debug('DEBUG requestJson '+ requestJson);
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http();
                request.setHeader('api-key', integrationDetail.ARTL_API_Key__c);
                request.setHeader('Content-Type', 'application/json');
                request.setEndpoint(integrationDetail.ARTL_Endpoint__c);
                request.setMethod('POST');
                request.setBody(requestJson);
                response = http.send(request);
                System.debug('DEBUGG scope '+ response);
                System.debug('debugg response '+ response.getBody());
                Map<String, Object> responseObject = (Map<String, Object>)System.JSON.deserializeUntyped(response.getBody());
                //checking if API returned a valid response 
                if(responseObject.containsKey('requestId')){
                    Map<String, Object> data = (Map<String, Object>)responseObject.get('data');
                    Map<String, Object> address = (Map<String, Object>)data.get('address');
                    
                    vlocity_cmt__QuoteMember__c quoteMember = new vlocity_cmt__QuoteMember__c(Id = qm.Id);
                    
                    if(address.containsKey('id')){
                        quoteMember.ARTL_Address_Id__c = String.valueOf(address.get('id'));
                    }
                    if(address.containsKey('latitude')){
                        quoteMember.ARTL_Feasibility_Geolocation__Latitude__s = Decimal.valueOf(String.valueOf(address.get('latitude')));
                    }
                    if(address.containsKey('longitude')){
                        quoteMember.ARTL_Feasibility_Geolocation__Longitude__s = Decimal.valueOf(String.valueOf(address.get('longitude')));
                    }
                    if(address.containsKey('errorMargin')){
                        quoteMember.ARTL_Feasibility_Error_Margin__c = Decimal.valueOf(String.valueOf(address.get('errorMargin')));
                    }
                    
                    quoteMemberUpdateList.add(quoteMember);
                }
            }
        }
        catch(Exception ex){
            System.debug('DEBUGG Exception '+ ex.getLineNumber() + ex.getMessage());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_FeasibilityAddressVerificationBatch', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        try{
            //KB: Once the response is captured for all the quote members, updating the record here in finish
            if(!quoteMemberUpdateList.isEmpty()){
                update quoteMemberUpdateList; 
                List<ARTL_Feasibility_Event__e> feasibilityEvtList = new List<ARTL_Feasibility_Event__e>();
                ARTL_Feasibility_Event__e obj = new ARTL_Feasibility_Event__e();
                obj.ARTL_QuoteId__c  = quoteId;
                obj.subEventName__c = ADDRESS_VALIDATION_COMPLETED_EVENT;
                feasibilityEvtList.add(obj);

                Database.SaveResult[] contractresult = EventBus.publish(feasibilityEvtList);
            
            }
        }
        catch(Exception ex){
            System.debug('DEBUGG Exception finish'+ ex.getLineNumber() + ex.getMessage());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_FeasibilityAddressVerificationBatch', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
        }
        
    }
}