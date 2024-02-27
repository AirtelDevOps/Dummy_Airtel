/******************************************************************************************************
* @Author       : arka.bhattacharjee@salesforce.com
* @Company      : Salesforce
* @Date         : 29-Dec-2023
* @Test Class   : 
* @Description  : Custom Rest API to Get Contact Records from External System
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date             Comment
*                         Arka Bhattacharjee    29-Dec-2023      Initial Dev
*******************************************************************************************************/
@RestResource(urlMapping='/v1/ContactDataLoad')
global without sharing class ARTL_ContactDataLoadAPI {
	@httpPost
    global static void doPostMethod(){
        List<conWrapper> conList = new List<conWrapper>();
        List<Case_Tracking_Detail__c> CtdList =  new List<Case_Tracking_Detail__c>();
        	string Description;
        	case cs = new case();
        	cs.Status='In-Progress';
        	cs.Origin='Web';
        	insert cs;
        try{
            
            RestRequest req = RestContext.request;
            Map<string,Object> jsonMap = (Map<string,Object>)JSON.deserializeUntyped(req.requestbody.toString());
            List<Object> objList =(List<Object>)jsonMap.get('Payload');
            for(Integer i=0; i<objList.size(); i++){
                Map<String,Object> objMap = (Map<String, Object>)objList[i];
                conWrapper cw = new conWrapper();
                cw.FirstName = (objMap.get('First Name') != null) ? String.valueOf(objMap.get('First Name')) : null;
                cw.MiddleName = (objMap.get('Middle Name') != null) ? String.valueOf(objMap.get('Middle Name')) : null;
                cw.LastName = (objMap.get('Last Name') != null) ? String.valueOf(objMap.get('Last Name')) : null;
                cw.Mobile = (objMap.get('Mobile') != null) ? String.valueOf(objMap.get('Mobile')) : null;
                cw.Email = (objMap.get('Email') != null) ? String.valueOf(objMap.get('Email')) : null;
                cw.AccNumber = (objMap.get('AccountNumber') != null) ? String.valueOf(objMap.get('AccountNumber')) : null;
                cw.NBAAccNumber = (objMap.get('NBAAccountNumber') != null) ? String.valueOf(objMap.get('NBAAccountNumber')) : null;
                cw.AddLine1 = (objMap.get('AddressLine1') != null) ? String.valueOf(objMap.get('AddressLine1')) : null;
                cw.AddLine2 = (objMap.get('AddressLine2') != null) ? String.valueOf(objMap.get('AddressLine2')) : null;
                cw.AddLine3 = (objMap.get('AddressLine3') != null) ? String.valueOf(objMap.get('AddressLine3')) : null;
                cw.City = (objMap.get('City') != null) ? String.valueOf(objMap.get('City')) : null;
                cw.State = (objMap.get('State') != null) ? String.valueOf(objMap.get('State')) : null;
                cw.Country = (objMap.get('Country') != null) ? String.valueOf(objMap.get('Country')) : null;
                cw.Pincode = (objMap.get('Pincode') != null) ? String.valueOf(objMap.get('Pincode')) : null;
                cw.Channel = (objMap.get('Channel') != null) ? String.valueOf(objMap.get('Channel')) : null;
                cw.Role = (objMap.get('Role') != null) ? String.valueOf(objMap.get('Role')) : null;
                cw.Designation = (objMap.get('Designation') != null) ? String.valueOf(objMap.get('Designation')) : null;
                cw.Salutation = (objMap.get('Salutation') != null) ? String.valueOf(objMap.get('Salutation')) : null;
                cw.Department = (objMap.get('Department') != null) ? String.valueOf(objMap.get('Department')) : null;
                //cw.CustomerType = (objMap.get('CustomerType') != null) ? String.valueOf(objMap.get('CustomerType')) : null;
                //cw.InteractionLevel = (objMap.get('InteractionLevel') != null) ? String.valueOf(objMap.get('InteractionLevel')) : null;
                //cw.StakeholderScore = (objMap.get('StakeholderScore') != null) ? String.valueOf(objMap.get('StakeholderScore')) : null;
                cw.Status = (objMap.get('Status') != null) ? String.valueOf(objMap.get('Status')) : null;
                cw.Title = (objMap.get('Title') != null) ? String.valueOf(objMap.get('Title')) : null;
                cw.GST = (objMap.get('GST') != null) ? String.valueOf(objMap.get('GST')) : null;
                cw.GSTApp = (objMap.get('GST Applicable') != null) ? String.valueOf(objMap.get('GST Applicable')) : null;
                cw.GSTNAReason = (objMap.get('GST Non Applicable Reason') != null) ? String.valueOf(objMap.get('GST Non Applicable Reason')) : null;
                cw.OpType = (objMap.get('operationType') != null) ? String.valueOf(objMap.get('operationType')) : null;
                cw.Id=(objMap.get('Id') != null) ? String.valueOf(objMap.get('Id')) : null;
                cw.PartyId=(objMap.get('PartyId') != null) ? String.valueOf(objMap.get('PartyId')) : null;
                cw.NBAId=(objMap.get('NBAId') != null) ? String.valueOf(objMap.get('NBAId')) : null;
                cw.IntegrationId=(objMap.get('IntegrationId') != null) ? String.valueOf(objMap.get('IntegrationId')) : null;
                conList.add(cw);
          //      Case_Tracking_Detail__c Ctr = new Case_Tracking_Detail__c();
          //  	Ctr.Step1__c='In-Progress';
         //   	Ctr.Case__c=cs.id;
         //   	Ctr.Name=cs.caseNumber;
         //   	CtdList.add(Ctr);
            }
         //   Database.insert(CtdList);
            ARTL_ContactDataLoadBatch cdlb = new ARTL_ContactDataLoadBatch(conList,cs.id);
            Database.executeBatch(cdlb,100);
        }catch(Exception ex){
            Description='Processing Failed : '+ex.getMessage() + ex.getLineNumber();
            case ce =[select id , caseNumber, Description from case where id=:cs.id];
            ce.Status='Closed';
        	ce.Description=Description;
        	update ce;
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_ContactDataLoadAPI:doPostMethod',
                              '', new Map<String,Object>{'Exception'=>ex.getMessage() , 'LineNumber' => ex.getLineNumber()}, ex);
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf('{"Status": "Failure", "Message" : "' + ex.getMessage() + ex.getLineNumber() + '"}');
            RestContext.response.statusCode = 400;
            return ;
        }
        case ce =[select id , caseNumber, Description from case where id=:cs.id];
        string message = conList.size() + ' Contacts are getting processed';
        //RestContext.response.responseBody = Blob.valueOf('{"Status": "Success", "Message" : message}');
        RestContext.response.addHeader('Content-Type', 'application/json');
        
        RestContext.response.responseBody = Blob.valueOf('{"CaseNumber": "' +ce.CaseNumber+'", "Message" : "' + message + '"}');
        RestContext.response.statusCode = 200;
        return ;
    }
    global class conWrapper{
        global String Id;
        global String FirstName;
        global String MiddleName;
        global String LastName;
        global String Mobile;
        global String Email;
        global String AccNumber;
        global String NBAAccNumber;
        global String AddLine1;
        global String AddLine2;
        global String AddLine3;
        global String City;
        global String State;
        global String Country; 
        global String Pincode;
        global String Channel;
        global String Role;
        global String Designation;
        global String Status;
        global String Title;
        global String GST;
        global String GSTApp;
        global String GSTNAReason;
        global String OpType;
        global String PartyId;
        global String NBAId;
        global String Department;
        global String IntegrationId;
        global String Salutation;
        //global String CustomerType;
        //global String InteractionLevel;
        //global String StakeholderScore;
    }
}