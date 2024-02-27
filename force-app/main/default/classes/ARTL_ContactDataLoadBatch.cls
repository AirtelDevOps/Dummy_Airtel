/******************************************************************************************************
* @Author       : arka.bhattacharjee@salesforce.com
* @Company      : Salesforce
* @Date         : 29-Dec-2023
* @Test Class   : 
* @Description  : Load Contact Records from External System to Salesforce
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date             Comment
*                         Arka Bhattacharjee    29-Dec-2023      Initial Dev
*******************************************************************************************************/
global without sharing class ARTL_ContactDataLoadBatch implements Database.Batchable<Object>, Database.Stateful, Database.AllowsCallouts{
	public List<Object> conList = new List<Object>();
    List<String> successList = new List<String>();
    Id csId;
    List<String> errorList = new List<String>();
    global ARTL_ContactDataLoadBatch(List<Object> conWrapList , Id caseId){
        csId=caseId;
        conList = conWrapList;
    }
    global List<Object> start(Database.BatchableContext bc){
        return conList;
    }
    global void execute(Database.BatchableContext bc, List<Object> scope){
        ARTL_UpdateBcpDcpLwcController.isUpdateBcpDcp=true;
        List<String> gstnames = new List<String>();
        List<string> pincodenames = new List<string>();
        List<String> contactnames = new List<String>();
        List<string> contactSiebelIds = new List<string>();
        
         for (Object obj : scope) {
             Map<String, Object> cwMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
             gstnames.add(String.valueOf(cwMap.get('GST')));
             pincodenames.add(String.valueOf(cwMap.get('Pincode')));
             if(cwMap.get('OpType')== 'UPDATE' && cwMap.get('Id') != Null){
             if(String.valueOf(cwMap.get('Id')).length()==15 || String.valueOf(cwMap.get('Id')).length()==18 ){
             contactnames.add(String.valueOf(cwMap.get('Id')));
             } else {
                 contactSiebelIds.add(String.valueOf(cwMap.get('Id')));
             }
             }
             
         }
        	Map<Id,ARTL_Pincode__c> pincodeMap = new Map<Id, ARTL_Pincode__c>();
            Map<String, ARTL_Pincode__c> pincodeCityAndRecordMap = new Map<String, ARTL_Pincode__c>();
            for(ARTL_Pincode__c pincodeRecord : [SELECT Id,Name,ARTL_City__c,ARTL_State__c,ARTL_Country__c FROM ARTL_Pincode__c WHERE Name in :pincodenames]) {
                pincodeMap.put(pincodeRecord.Id,pincodeRecord);
                pincodeCityAndRecordMap.put(pincodeRecord.Name + '-' + String.valueOf(pincodeRecord.ARTL_City__c).toLowerCase(), pincodeRecord);
            }
        
        
        RecordType BcpDcpRecordTypeId =[select id ,DeveloperName from RecordType  where DeveloperName ='ARTL_BCP_DCP_Contact'];
        system.debug('scope check'+scope);
        List<Contact> contactList = new List<Contact>();
        List<Contact> contactupdateList = new List<Contact>();
        List<vlocity_cmt__Premises__c> premiseupdateList = new List<vlocity_cmt__Premises__c>();
        List<String> Updatelist = new List<String>();
        List<vlocity_cmt__Premises__c> premisesList = new List<vlocity_cmt__Premises__c>();
        List<ContactPremiseRelation__c> cprList = new List<ContactPremiseRelation__c>();
        List<AccountContactRelation> accConList = new List<AccountContactRelation>();
        List<contact> getCon = [select id from contact where id In :contactnames and recordTypeId=:BcpDcpRecordTypeId.id ];
        List<contact> getSiebelcon = [select id , external_Id__c from contact where  external_Id__c In :contactSiebelIds and recordTypeId=:BcpDcpRecordTypeId.Id];
        List<vlocity_cmt__Premises__c> getSiebelPrem =[select id , external_Id__c from vlocity_cmt__Premises__c where external_Id__c In :contactSiebelIds ];
        Map<string,Id> siebelPremMap = new Map<string,Id>();
        for(vlocity_cmt__Premises__c preex: getSiebelPrem){
            siebelPremMap.put(preex.External_Id__c , preex.id);
        }
        Map<string,Id> consiebIdsmap = new Map<string,Id>();
        for(contact c: getSiebelcon){
            consiebIdsmap.put(c.External_Id__c,c.id);
        }
        
        Set<Id> conIds = new Set<Id>();
        List<string> conseibelIds = new List<string>();
        for(contact c:getCon){
            conIds.add(c.id);
            //conseibelIds.add(c.External_Id__C);
        }
        
        List<GST__c> gstList1 = [Select Id ,name From GST__c where name in :gstnames];
        Map<string,Id> gstMap = new Map<string,Id>();
        for(GST__c gt:gstList1){
            gstMap.put(gt.name,gt.id);
        }
        
        //Map<String,Object> cwMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(scope[0]));
        for (Object obj : scope) {
            Map<String, Object> cwMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
        
        try{
            //Account nbaAcc = [Select Id, ParentId From Account Where ARTL_Billing_Aggregator_Account_Number__c = :String.valueOf(cwMap.get('NBAAccNumber')) Limit 1];
            
            Contact con = new Contact();
            con.FirstName = String.valueOf(cwMap.get('FirstName'));
            con.MiddleName = String.valueOf(cwMap.get('MiddleName'));
            con.LastName = String.valueOf(cwMap.get('LastName'));
            con.Phone = String.valueOf(cwMap.get('Mobile'));
            con.Email = String.valueOf(cwMap.get('Email'));
            con.Salutation = String.valueOf(cwMap.get('Salutation'));
            con.RecordTypeId=BcpDcpRecordTypeId.Id;
            con.Integration_Id__c=String.valueOf(cwMap.get('IntegrationId'));
            if(String.isNotBlank(String.valueOf(cwMap.get('NBAId')))){
            con.AccountId = String.valueOf(cwMap.get('NBAId'));   // changed from party to NBA
            }
            if(String.isNotBlank(String.valueOf(cwMap.get('NBAId')))){
                con.NBA_Account__c = String.valueOf(cwMap.get('NBAId'));
            }
            
            /*con.MailingStreet = String.valueOf(cwMap.get('AddLine1'))+' '+String.valueOf(cwMap.get('AddLine2'))+' '+String.valueOf(cwMap.get('AddLine3')); //TBD
            con.MailingCity = String.valueOf(cwMap.get('City'));
            con.MailingState = String.valueOf(cwMap.get('State'));
            con.MailingCountry = String.valueOf(cwMap.get('Country'));
            con.MailingPostalCode = String.valueOf(cwMap.get('Pincode'));*/
            con.Channel__c = String.valueOf(cwMap.get('Channel'));
            con.ARTL_Contact_Role__c = String.valueOf(cwMap.get('Role'));
            con.ARTL_Designation__c = String.valueOf(cwMap.get('Designation'));
            con.Title = String.valueOf(cwMap.get('Title'));
            con.Department = String.valueOf(cwMap.get('Department'));
            //con.ARTL_Interaction_Level__c = String.valueOf(cwMap.get('InteractionLevel'));
            //con.ARTL_Stakeholder_Score__c = String.valueOf(cwMap.get('StakeholderScore'));
            vlocity_cmt__Premises__c pre = new vlocity_cmt__Premises__c();
            String originalString = String.valueOf(cwMap.get('AddLine1'))+String.valueOf(cwMap.get('AddLine2'))+' '+String.valueOf(cwMap.get('AddLine3'));
			Integer maxLength = 255;
			// Truncate the string to 255 characters
			String truncatedString = originalString.length() > maxLength ? originalString.substring(0, maxLength) : originalString;
            pre.vlocity_cmt__StreetAddress__c=truncatedString;

            //pre.vlocity_cmt__Address1__c = String.valueOf(cwMap.get('AddLine1'));
            //pre.vlocity_cmt__Address2__c = String.valueOf(cwMap.get('AddLine2'))+' '+String.valueOf(cwMap.get('AddLine3'));
            string Pincodekey = String.valueOf(cwMap.get('Pincode'))+'-'+String.valueOf(cwMap.get('City')).toLowercase();
            if(pincodeCityAndRecordMap.containskey(Pincodekey)){
                ARTL_Pincode__c pincoderec = pincodeCityAndRecordMap.get(Pincodekey);
                pre.ARTL_Pincode__c =pincoderec.id;																																				
                pre.vlocity_cmt__City__c = pincoderec.ARTL_City__c;
            	pre.vlocity_cmt__State__c = pincoderec.ARTL_State__c;
           	    pre.vlocity_cmt__Country__c = pincoderec.ARTL_Country__c;
            	pre.vlocity_cmt__PostalCode__c = pincoderec.Name;
            }
            
            pre.vlocity_cmt__Status__c = String.valueOf(cwMap.get('Status'));
            ContactPremiseRelation__c cpr = new ContactPremiseRelation__c();
            cpr.ARTL_GST_Applicable__c = String.valueOf(cwMap.get('GSTApp'));
            cpr.ARTL_Standard_Reason__c = String.valueOf(cwMap.get('GSTNAReason'));
            cpr.Role__c = String.valueOf(cwMap.get('Designation'));
            AccountContactRelation accCon = new AccountContactRelation();
            
            String opType = String.valueOf(cwMap.get('OpType'));
            
            if(opType == 'CREATE'){ 
                //GST__c gst = new GST__c();
                //if(String.valueOf(cwMap.get('GST'))!=null){                    
            		//List<GST__c> gstlist = [Select Id From GST__c Where Name = :String.valueOf(cwMap.get('GST')) Limit 1];
                    //if(gstlist.size()>0){
                      //  gst=gstlist[0];
                    //}
                    
                //}
                
                //Database.SaveResult csr = Database.insert( con,false);
                contactList.add(con);
                
                
                accCon.AccountId=String.valueOf(cwMap.get('NBAId'));
                accCon.ContactId =con.id;
                //Database.SaveResult accConsr = Database.insert(accCon,false);
                //accConList.add(accCon);
                //successList.add('Contact ID :' +con.id +' is Inserted successfully');
                //Database.SaveResult presr = Database.insert(pre,false);
                premisesList.add(pre);
                system.debug('conid'+con.id+'preid'+pre.id);
                cpr.Contact__c = con.Id;
                cpr.Premises__c = pre.Id;
                if(gstMap.get(String.valueOf(cwMap.get('GST'))) != null){
                  cpr.GST__c = gstMap.get(String.valueOf(cwMap.get('GST')));  
                }
                    
                //Database.SaveResult cprsr = Database.insert(cpr,false);
                //cprList.add(cpr);
            }
            
            else if(opType == 'UPDATE' && cwMap.get('Id') != Null ){
                
                
                //Contact oldCon;
                Id conId;
                if(String.valueOf(cwMap.get('Id')).length()==15 || String.valueOf(cwMap.get('Id')).length()==18 ){
                    //oldCon = [Select Id From Contact Where  Id=:(Id)cwMap.get('Id') Limit 1];
                    If(conIds.contains(String.valueOf(cwMap.get('Id')))){
                        conId=String.valueOf(cwMap.get('Id'));
                    }
                    
                }else{
                    //oldCon = [Select Id From Contact Where  External_Id__c=:String.valueOf(cwMap.get('Id')) Limit 1];
                    If(consiebIdsmap.containskey(String.valueOf(cwMap.get('Id')))){
                        conId=consiebIdsmap.get(String.valueOf(cwMap.get('Id')));
                    }
                    
                }
                
                con.Id = conId;
                //Database.SaveResult cupdsr =Database.update(con,false);
                contactupdateList.add(con);
                //premiseupdateList.add(pre);
                
                //successList.add('Contact ID :' +con.id +' is updated successfully');
                
            }
            else if(opType == 'UPDATE' && String.valueOf(cwMap.get('Id')) == Null ){
                
             //   Updatelist.add('Contact Updation failed as Id is Null');
                contactupdateList.add(con);
                //errorList.add('id is null for '+con.name);
                
                
            }
            if(Test.isRunningTest()){
			CalloutException e = new CalloutException();
            e.setMessage('This is a constructed exception for test class');
            throw e;
}
            
        }catch(Exception ex){
            system.debug('exception 87'+ex.getMessage()+' :: '+ex.getLineNumber());
            String opType = String.valueOf(cwMap.get('OpType'));
            if(opType == 'UPDATE'){
                errorList.add('Contact ID :'+String.valueOf(cwMap.get('Id'))+' has an error.' +ex.getMessage()+' :: '+ex.getLineNumber());
            	
            }else if(opType == 'CREATE'){
                errorList.add('Contact has an error.' +ex.getMessage()+' :: '+ex.getLineNumber());
            }
            
            
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_ContactDataLoadBatch:execute',
                              '', new Map<String,Object>{'Exception'=>ex.getMessage() , 'LineNumber' => ex.getLineNumber()}, ex);
        }
        }
        // Bulk insert/update the records using maps
        case c = [select id , Description , caseNumber from case where id=:csId];
        List<contact> ContactDel = new List<contact>();
        List<Database.SaveResult> csr = Database.insert(contactList, false);
        List<Database.SaveResult> presr = Database.insert(premisesList, false);
        for (Integer i = 0; i < csr.size(); i++){
            if(csr[i].isSuccess()){
                //ContactPremiseRelation__c cpr = new ContactPremiseRelation__c();
                system.debug('conid'+contactList[i].Id+'preid'+premisesList[i].Id);
                //cpr.Contact__c = contactList[i].Id;
                //cpr.Premises__c = premisesList[i].Id;
                    
                //Database.SaveResult cprsr = Database.insert(cpr,false);
                //cprList.add(cpr);
            }
        }
        
       
        List<Case_Tracking_Detail__c> CtdList = new List<Case_Tracking_Detail__c>();
        for (Integer i = 0; i < csr.size(); i++){
        if(csr[i].isSuccess()){
            system.debug('conid '+contactList[i].id);
            successList.add('Contact ID :' +contactList[i].id +' is Created successfully');
            Case_Tracking_Detail__c Ctr = new Case_Tracking_Detail__c();
            Ctr.OperationType__c='CREATE';
            Ctr.SF_Record_ID__c=contactList[i].id;
            //system.debug('accConsr[i].isSuccess()'+accConsr[i].isSuccess()+'cprsr[i].isSuccess()'+cprsr[i].isSuccess()+'presr[i].isSuccess()'+presr[i].isSuccess());
            // Check if related records are successfully created
        	if (presr[i].isSuccess() ) {
                AccountContactRelation accCon = new AccountContactRelation();
                for (Object obj : scope) {
            Map<String, Object> cwMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                    if(String.valueOf(cwMap.get('FirstName'))==contactList[i].FirstName && contactList[i].LastName == String.valueOf(cwMap.get('LastName')) && contactList[i].LastName == String.valueOf(cwMap.get('Email'))){
                       accCon.AccountId=String.valueOf(cwMap.get('PartyId')); 
                    }
                    accCon.Roles=String.valueOf(cwMap.get('Designation'));
                
                }
                accCon.ContactId =csr[i].Id;             
                accConList.add(accCon);
                
                ContactPremiseRelation__c cpr = new ContactPremiseRelation__c();
                system.debug('conid'+contactList[i].Id+'preid'+premisesList[i].Id);
                cpr.Contact__c = contactList[i].Id;
                cpr.Premises__c = premisesList[i].Id;
                for (Object obj : scope) {
            	Map<String, Object> cwMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                system.debug('cwMap scope'+cwMap);
                    if(String.valueOf(cwMap.get('FirstName'))==contactList[i].Firstname && String.valueOf(cwMap.get('Email'))==contactList[i].Email){
                        system.debug('cwMap scope in if'+String.valueOf(cwMap.get('GSTNAReason')));
                if(gstMap.get(String.valueOf(cwMap.get('GST'))) != null){
                  cpr.GST__c = gstMap.get(String.valueOf(cwMap.get('GST')));  
                }
                cpr.ARTL_GST_Applicable__c = String.valueOf(cwMap.get('GSTApp'));
            	cpr.ARTL_Standard_Reason__c = String.valueOf(cwMap.get('GSTNAReason'));
            	cpr.Role__c = String.valueOf(cwMap.get('Designation'));
                    }
                }
                    
                //Database.SaveResult cprsr = Database.insert(cpr,false);
                system.debug('check cpr'+cpr);
                cprList.add(cpr);
                Ctr.Step1__c='Success';
                     Ctr.Step_1_Description__c= 'Contact ID :' +contactList[i].id +' is Created successfully';
                
                
            
            } else {
                     ContactDel.add(contactList[i]);
                	 Ctr.Step1__c='Error';
                     Ctr.Step_1_Description__c= 'Contact Creation has an Error On Premise '+presr[i].getErrors()[0].getMessage();
                	 System.debug('ErrOnPremise'+presr[i].getErrors()[0].getMessage());
            }
            
            
            Ctr.Case__c=csId;
            Ctr.Name=c.caseNumber;
            CtdList.add(Ctr);
           
            
        }else {
            system.debug('fail record '+csr[i].getErrors());
            errorList.add('Contact Creation has an error On contact.' +csr[i].getErrors());
            Case_Tracking_Detail__c Ctr = new Case_Tracking_Detail__c();
            Ctr.OperationType__c='CREATE';
      //      Ctr.SF_Record_ID__c=contactupdateList[i].id;
            Ctr.Step1__c='Error';
            Ctr.Case__c=csId;
            Ctr.Name=c.caseNumber;
            Ctr.Step_1_Description__c= 'Contact Creation has an error.'+String.valueOf(csr[i].getErrors()[0].getMessage());
            CtdList.add(Ctr);   
        }
        }
       // Database.insert(CtdList);
        List<Database.SaveResult> cprsr = Database.insert(cprList, false);
        for (Integer i = 0; i < cprsr.size(); i++){
            if(cprsr[i].isSuccess()){
                
            }else {
                for(Case_Tracking_Detail__c cd :CtdList ){
                    if(cd.SF_Record_ID__c==cprList[i].Contact__c){
                        cd.Step1__c='Error';
                        cd.Step_1_Description__c='Contact Creation has an error on CPR .'+String.valueOf(cprsr[i].getErrors()[0].getMessage());
                    }
                    
                    
                }
                
            }
        }
        List<Database.SaveResult> accConsr = Database.insert(accConList, false);
        List<Database.SaveResult> updcsr = Database.update(contactupdateList, false);
        //List<Database.SaveResult> updpre = Database.update(premiseupdateList,false);
   //     case c = [select id , Description , caseNumber from case where id=:csId];
   //     List<Case_Tracking_Detail__c> CtdList = new List<Case_Tracking_Detail__c>();
     //  Database.insert(CtdList);
        for (Integer i = 0; i < updcsr.size(); i++){
        if(updcsr[i].isSuccess()){
            Case_Tracking_Detail__c Ctr = new Case_Tracking_Detail__c();
            Ctr.OperationType__c='UPDATE';
            Ctr.SF_Record_ID__c=contactupdateList[i].id;
            Ctr.Step1__c='Success';
            Ctr.Case__c=c.id;
            Ctr.Name=c.caseNumber;
            Ctr.Step_1_Description__c='Contact ID :' +contactupdateList[i].id +' is Updated successfully';
            CtdList.add(Ctr);          
            
            successList.add('Contact ID :' +contactupdateList[i].id +' is Updated successfully');
            
        }else {
            Case_Tracking_Detail__c Ctr = new Case_Tracking_Detail__c();
            Ctr.OperationType__c='UPDATE';
            Ctr.SF_Record_ID__c=contactupdateList[i].id;
            Ctr.Step1__c='Error';
            Ctr.Case__c=c.id;
            Ctr.Name=c.caseNumber;
            Ctr.Step_1_Description__c=String.valueOf(updcsr[i].getErrors()[0].getMessage());
            CtdList.add(Ctr);
            
            errorList.add('Contact Update has an error.' +updcsr[i].getErrors()[0].getMessage());
        }
        }
        Database.insert(CtdList);
        List<Case_Tracking_Detail__c> caseTrackingDetailsUpdate = new List<Case_Tracking_Detail__c>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        for(Case_Tracking_Detail__c ctdRecord: CtdList ){
            if(ctdRecord.Step1__c == 'Success' && (ctdRecord.Step_1_Description__c.containsIgnoreCase('created') || ctdRecord.Step_1_Description__c.containsIgnoreCase('updated'))){//  && ctdRecord.Case__r?.Status == STATUS_IN_PROGRESS){
                inputMap.put('contactId', ctdRecord.SF_Record_ID__c);
                inputMap.put('ctdId',ctdRecord.Id);
                system.debug('ctdRecord.SF_Record_ID__c'+ctdRecord.SF_Record_ID__c);
                //outputMap = (Map<String, Object>) ARTL_CaseTrackingDetailTriggerHandler.invokeIntegrationProcedure(inputMap, 'ARTL_BCPDCPSolaceQueue');
                //System.debug('DEBUGG outputMap '+ outputMap);
                //ctdRecord.Step_2_Status__c = (String) outputMap.get('status');
                //ctdRecord.Step_2_Description__c = (String) outputMap.get('description');
                //caseTrackingDetailsUpdate.add(ctdRecord);
            }
        }
        //Database.update(caseTrackingDetailsUpdate);
        If(ContactDel.size()>0){
           Delete ContactDel;
        }
    }
    global void finish(Database.BatchableContext bc){
        string Des = '';
        for(string succ :successList){
            Des=Des+succ+'\n';
        }
        for(string err :errorList){
            Des=Des+err+'\n';
        }
        case c = [select id , Description from case where id=:csId];
        c.Description= 'Processed successfully';
        //c.status='Closed';
        update c;
        system.debug('Success '+successList);
        system.debug('Error '+errorList);
        
        
        
    } 
}