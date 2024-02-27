/******************************************************************************************************
* @Author       : arka.bhattacharjee@salesforce.com
* @Company      : Salesforce
* @Date         : 05-Dec-2023
* @Test Class   : ARTL_DocumentUploadControllerTest
* @Description  : Controller for artl_DocumentUpload LWC
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date             Comment
*                         Arka Bhattacharjee    05-Dec-2023      Initial Dev
*******************************************************************************************************/
global without sharing class ARTL_DocumentUploadController {
    private static String PROCESS_NAME = 'DocumentUpload';
    private static String API_KEY = 'api-key';
    private static String CONTENT_TYPE = 'Content-Type';
    private static String CONTENT_TYPE_VALUE = 'application/json';
    private static String AUTHORIZATION = 'Authorization';
    private static String SOURCE = 'leo';
    private static String ISSUE_AUTHORITY = 'example';
    /******************************************************************************************************
* Method Name        : makeDocUploadCallout
* Method Description : Call IP for Doc Upload Callout
*******************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> makeDocUploadCallout(String docId, String cvId){
        Map<String,Object> response = new Map<String,Object>();
        try{
            ContentVersion cv = [Select Id, VersionData, ContentDocumentId From ContentVersion Where Id = :cvId Limit 1];
            ContentDocument cd = [Select Id, Title, FileExtension From ContentDocument Where Id = :cv.ContentDocumentId Limit 1];
            Map<String,String> input = new Map<String,String>();
            input.put('ContextId', docId);
            input.put('docName', cd.Title + '.' + cd.FileExtension);
            input.put('docBody', EncodingUtil.base64Encode(cv.VersionData));
            system.debug('input****>>>>'+input);
            response = makeAPICallout(input);
            system.debug('After Callout ****>>>>'+response);
            delete cd;
        }catch(Exception ex){
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_DocumentUploadController:makeDocUploadCallout',
                              '', new Map<String,Object>{'Exception'=>ex.getMessage() , 'LineNumber' => ex.getLineNumber()}, ex);
        }
        return response;
    }
    /******************************************************************************************************
* Method Name        : makeAPICallout
* Method Description : Call API Service for file upload
*******************************************************************************************************/
    public static Map<String,Object> makeAPICallout(Map<String, String> inputMap){
        Map<String,Object> response = new Map<String,Object>(); 
        try{
            ARTL_Callout_Event_Configs__mdt cec = [Select ARTL_API_Key__c, ARTL_EndPointURL__c, ARTL_Operation__c, 
                                                   ARTL_Pattern__c, ARTL_Authorization__c From ARTL_Callout_Event_Configs__mdt 
                                                   Where DeveloperName = :PROCESS_NAME Limit 1];
            ARTL_Document__c doc = [Select Id, Document_Name__c, Category__c, Type__c From ARTL_Document__c 
                                    Where Id = :inputMap.get('ContextId') Limit 1];
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setTimeout(120000);
            request.setEndPoint(cec.ARTL_EndPointURL__c);
            request.setMethod(cec.ARTL_Operation__c);
            request.setHeader(API_KEY, cec.ARTL_API_Key__c);
            request.setHeader(CONTENT_TYPE, CONTENT_TYPE_VALUE);
            request.setHeader(AUTHORIZATION, cec.ARTL_Authorization__c);
            Payload pld = new Payload();
            pld.identifier = inputMap.get('ContextId');
            pld.source = SOURCE;
            pld.document.category = doc.Category__c;
            pld.document.metadata.issueAuthority = ISSUE_AUTHORITY;
            pld.document.name = doc.Document_Name__c;
            pld.document.type = doc.Type__c;
            List<cls_images> imagesList = new List<cls_images>();
            cls_images img = new cls_images();
            img.base64Image = inputMap.get('docBody');
            img.imageName = inputMap.get('docName');
            imagesList.add(img);
            pld.document.images = imagesList;
            request.setBody(JSON.serialize(pld));
            HttpResponse resp = http.send(request);
            if(resp.getStatusCode()==200){
                Map<String,Object> resMap = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
                Map<String,Object> docMap = (Map<String,Object>)resMap.get('document');
                List<Object> urlList = (List<Object>)docMap.get('urls');
                Map<String,Object> urlMap = (Map<String,Object>)urlList[0];
                String finalUrl = (String)urlMap.get('url');
                ARTL_Document__c upDoc = new ARTL_Document__c();
                upDoc.Id = inputMap.get('ContextId');
                upDoc.s3_Document_URL__c = finalUrl;
                update upDoc;
                response.put('callout',true);
                response.put('errorMsg','');
            }else{
                Map<String,Object> resMap = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
                response.put('callout',false);
                response.put('errorMsg',resMap.get('errorMsg'));
            }
        }catch(Exception ex){
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_DocumentUploadController:makeAPICallout',
                              '', new Map<String,Object>{'Exception'=>ex.getMessage() , 'LineNumber' => ex.getLineNumber()}, ex);
        }
        return response;
    }
    
    /******************************************************************************************************
* Class Name        : Payload
* Class Description : Wrapper class for Payload JSON
*******************************************************************************************************/
    global class Payload{
        global String identifier;
        global String source;
        global cls_document document;
        Payload(){
            this.document = new cls_document();
        }
    }
    global class cls_document {
        global String category;
        global cls_metadata metadata;
        global String name;
        global String type;
        global cls_images[] images;
        cls_Document(){
            this.metadata = new cls_metadata();
            this.images = new List<cls_images>();
        }
    }
    global class cls_metadata {
        global String issueAuthority;
    }
    global class cls_images {
        global String imageName;
        global String base64Image;
    }
    
    
    
    @AuraEnabled
    public static string validateDoc(Id recId , string objName){
        set<string> docNames = new Set<string>();
        boolean flag = true;
        Set<String> QLIProductCodes = new Set<String>(); 
        string falseresponse='' ;
        if(recId != null){
            for(ARTL_Document__c doc : [SELECT id,  Document_Name__c  FROM ARTL_Document__c WHERE Quote__c =: recId]){
                docNames.add(doc.Document_Name__c);
            }
            for (QuoteLineItem QLI : [SELECT id, vlocity_cmt__Product2Id__r.productCode FROM QuoteLineItem WHERE QuoteId = :recId]) {
                QLIProductCodes.add(QLI.vlocity_cmt__Product2Id__r.productCode);
            }
        }
        for(Document_Upload_Config__mdt mdt: [SELECT MasterLabel , DeveloperName , Mandatory_for_OV_Approval__c , Object_Level__c,Product_Codes__c 
                                              FROM Document_Upload_Config__mdt 
                                              WHERE Object_Level__c =: objName AND Mandatory_for_OV_Approval__c = True And Product_Codes__c IN : QLIProductCodes  ]){
                                                  
                                                  flag = docNames.contains(mdt.MasterLabel);
                                                  if(!flag){
                                                      falseresponse += ',' + mdt.MasterLabel;
                                                      //KB: Sagar - Below statement is to remove duplicate doc names from error msg.
                                                      docNames.add(mdt.MasterLabel);
                                                  }                                                      
                                              }
        system.debug('@@@@Apex response::' + falseresponse);
        falseresponse = String.isNotBlank(falseresponse) ? falseresponse.removeStart(',') : falseresponse;
        return falseresponse;
        
    }
}