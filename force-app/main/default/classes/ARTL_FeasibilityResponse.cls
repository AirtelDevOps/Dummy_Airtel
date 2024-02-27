/******************************************************************************************************
* @Author:     Sujay /Sagar Sadhnani  <sagar.sadhnani@salesforce.com >
* @Company:     Salesforc
* @Date:        17th Nov 2023
* @Reviewer:
* @Review Date:
* @Description: This utility is used for Feasibility feature.
* ++++++++++++++++++++++ Changes Implemented / Modification Log ++++++++++++++++++++++++++++++++++++++
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1. XXXXX	          Sujay/Sagar Sadhnani        11/20/2023        Added POST method to handle async feasibility response 
                                                            related to individual QLI and send that for parsing.
*******************************************************************************************************/

@RestResource(urlMapping='/api/feasibilityResponse/*')
global without sharing class ARTL_FeasibilityResponse {
    @httpPost
    global static void handlePost(){
        try{
            RestRequest request = RestContext.request;
            RestResponse response = Restcontext.response;
            //System.debug('Request' + request.requestBody.toString());
			boolean isValid = false;
            //Check all API Header paramter for Authentication
            if(request.headers.containsKey('api-key')){
                ARTL_Integration_Details__c integrationDetail = ARTL_Integration_Details__c.getValues('FeasibilityResponseSFDC');
                isValid = integrationDetail.ARTL_API_Key__c == request.headers.get('api-key');
            }
            
            if(isValid){
                
                //Send API Response
                response.addHeader('Content-Type', 'application/json');
            	response.responseBody = Blob.valueOf('Success :' + true);
            	response.statusCode = 200;
                //Transformation Logic
                ARTL_FeasibilityUtility.parseData(request.requestBody.toString());
            }
            else{
                response.addHeader('Content-Type', 'application/json');
            	response.responseBody = Blob.valueOf('Unauthorized Access');
            	response.statusCode = 400;
            }
        }
       catch(Exception e){
            
        }
	}
}