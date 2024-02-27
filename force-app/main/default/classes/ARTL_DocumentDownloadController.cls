/******************************************************************************************************
* @Author       : arka.bhattacharjee@salesforce.com
* @Company      : Salesforce
* @Date         : 05-Dec-2023
* @Test Class   : ARTL_DocumentDownloadControllerTest
* @Description  : Controller for artl_DocumentDownload LWC
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date             Comment
*                         Arka Bhattacharjee    05-Dec-2023      Initial Dev
*******************************************************************************************************/
public class ARTL_DocumentDownloadController {
/******************************************************************************************************
 * Method Name        : getDocumentsWire
 * Method Description : Get the Documents
*******************************************************************************************************/    
    @AuraEnabled(cacheable=true)
    public static List<ARTL_Document__c> getDocumentsWire(String recId, String objAPIName){
        return ARTL_DocumentDownloadController.getDocuments(recId, objAPIName);
    }
/******************************************************************************************************
 * Method Name        : getDocuments
 * Method Description : Get the Documents
*******************************************************************************************************/
    @AuraEnabled
    public static List<ARTL_Document__c> getDocuments(String recId, String objAPIName){
        List<ARTL_Document__c> docList = new List<ARTL_Document__c>();
        if(objAPIName == 'Account'){
            docList = [Select Id, Document_Name__c, toLabel(Category__c), toLabel(Type__c), s3_Document_URL__c, Error_Message__c 
                       From ARTL_Document__c Where Account__c = :recId Order By CreatedDate DESC];
        } else if(objAPIName == 'Contact'){
            docList = [Select Id, Document_Name__c, toLabel(Category__c), toLabel(Type__c), s3_Document_URL__c, Error_Message__c 
                       From ARTL_Document__c Where Contact__c = :recId Order By CreatedDate DESC];
        } else if(objAPIName == 'Opportunity'){
            docList = [Select Id, Document_Name__c, toLabel(Category__c), toLabel(Type__c), s3_Document_URL__c, Error_Message__c 
                       From ARTL_Document__c Where Opportunity__c = :recId Order By CreatedDate DESC];
        } else if(objAPIName == 'Quote'){
            docList = [Select Id, Document_Name__c, toLabel(Category__c), toLabel(Type__c), s3_Document_URL__c, Error_Message__c 
                       From ARTL_Document__c Where Quote__c = :recId Order By CreatedDate DESC];
        } else if(objAPIName == 'Order'){
            docList = [Select Id, Document_Name__c, toLabel(Category__c), toLabel(Type__c), s3_Document_URL__c, Error_Message__c 
                       From ARTL_Document__c Where Order__c = :recId Order By CreatedDate DESC];
        }
        return docList;
    }
/******************************************************************************************************
 * Method Name        : makeDocDownloadloadCallout
 * Method Description : Call IP for Doc Download Callout
*******************************************************************************************************/
    @AuraEnabled
    public static Map<String,Object> makeDocDownloadloadCallout(String docId){
        Map<String,Object> response = new Map<String,Object>();
        try{
            Map<String,Object> input = new Map<String,Object>();
            input.put('processName', 'DocumentDownload');
            //input.put('c', 'Basic YWRtaW46aUBtT3AzblMzYzIzMnQ=');
            input.put('source', 'leo');
            input.put('ContextId', docId);    
            Map<String,Object> outMap = new Map<String,Object>();
            ARTL_CalloutEventHandler ceh = new ARTL_CalloutEventHandler();
            ceh.invokeMethod('initiateCallout', input, outMap, null);
            response = (Map<String,Object>)outMap.get('response');
        }catch(Exception ex){
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_DocumentDownloadController:makeDocDownloadloadCallout',
                              '', new Map<String,Object>{'Exception'=>ex.getMessage() , 'LineNumber' => ex.getLineNumber()}, ex);
        }
        return response;
    }
}