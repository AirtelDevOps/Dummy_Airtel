/************************************************************************************************************************************************************************************************************
* @Author       : Harika
* @Company      : Salesforce (SFI)
* @Date         : 18/01/2024
* @Description  : Track Order API
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
*        1. SFDC-         Harika          18/01/2024     Initial Dev
************************************************************************************************************************************************************************************************************/

@RestResource(urlMapping='/ARTL_b2bTrackOrderService/*')
global class ARTL_b2bTrackOrderService  {
    @HttpPost  
    global static Void HandleTaskoperations(){
        
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        Map<String, Object> ipOptions = new Map<String, Object> ();
        String procedureName = 'ARTL_InboundHansenIntegration';
        String contentType = RestContext.request.headers.get('Content-Type');
        if(String.isNotBlank(contentType))
        {
            List<String> contentTypevalue = contentType.split(';');
            List<String> contentTypeextract = contentTypevalue[0].split('/');
            if(contentTypeextract[1].equalsIgnoreCase('json'))
            {
                
                
                ipInput = (Map <String, Object>) JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            }
            
            else 
            {
                if(contentTypeextract[1].equalsIgnoreCase('xml'))
                {
                    
                    XMLSerializer serializer = new XMLSerializer();
                    String jsonString = serializer.XMLToJson(RestContext.request.requestBody.toString());
                    ipInput = (Map <String, Object>) JSON.deserializeUntyped(jsonString);
                }
            }
            
            ipOutput = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
            
        }
        
    }
}