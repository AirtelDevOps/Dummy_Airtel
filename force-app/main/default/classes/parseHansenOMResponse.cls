/************************************************************************************************************************************************************************************************************
* @Author       : Vishal Kumar <vishal.kumar@salesforce.com>
* @Company      : Salesforce (SFI)
* @Date         : 12/10/2023
* @Test Class   : 
* @Description  : Handles response from Hansen Callout invoked from IP: ARTL_CallOutToHansenFromOrchest 
*
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
*      1. SFDC-849         Vishal Kumar          12/10/2023     Initial Dev
******************************************************************************************************************************************************************************************************************/

global with Sharing class parseHansenOMResponse implements vlocity_cmt.VlocityOpenInterface{
    
   
   global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {
      
       if (methodName.equals('parseXML')) {
            parseXML(inputMap,outMap,options);
        }
        return true;
        
    }
    global static void parseXML(Map < String, Object > inputMap, Map < String, Object > outMap, Map<String, Object> options)
    {
    
        String XMLString = String.valueOf(inputMap.get('response'));
        
        //XMLString = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><som:OrderResponse xmlns:cmn="http://ossj.org/xml/Common/v1-5" xmlns:bi="http://ossj.org/xml/Common-CBEBi/v1-5" xmlns:cbe="http://ossj.org/xml/Common-CBECore/v1-5" xmlns:cbe-service="http://ossj.org/xml/Common-CBEService/v1-5" xmlns:cbe-location="http://ossj.org/xml/Common-CBELocation/v1-5" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:som="http://som.sigma.com" xmlns:cbe-product-offering="http://ossj.org/xml/Common-CBEProductOffering/v1-5" xmlns:cbe-product="http://ossj.org/xml/Common-CBEProduct/v1-5" xmlns:cbe-datatype="http://ossj.org/xml/Common-CBEDatatypes/v1-5" xmlns:cbe-resource="http://ossj.org/xml/Common-CBEResource/v1-5" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:cbe-party="http://ossj.org/xml/Common-CBEParty/v1-5" xmlns:om="http://ossj.org/xml/OrderManagement/v1-0"><som:status>OK</som:status><som:orderId>710228</som:orderId><som:type>Submit Order</som:type></som:OrderResponse>';
        Dom.Document doc = new Dom.Document();
        doc.load(XMLString);

        for(Dom.XMLNode child: doc.getRootElement().getChildElements() ){
             if(child.getName() == 'orderId'){
                system.debug(child.getText());
                 outMap.put('orderId',child.getText());
             	}
             if(child.getName() == 'status'){
                system.debug(child.getText());
                 outMap.put('status',child.getText());
				}

    	}
   
    }
   
}