global class ARTL_DataMigrationContact implements Database.Batchable<sObject>{
    global Map<Id, String> errorMap {get; set;}
    global Map<Id, SObject> IdToSObjectMap {get; set;}
    
    global ARTL_DataMigrationContact(){
        errorMap = new Map<Id, String>();
        IdToSObjectMap = new Map<Id, SObject>();
    }
    
    // global List<Account> lstAccounts;
    // global List<Account> lstAccount;
    // global ARTL_DataMigrationContact(List<Account> lstAccounts) {
    //     this.lstAccounts = lstAccounts;
    //     System.debug('Contact --> lstAccounts --> '+lstAccounts);
    //     this.lstAccount = lstAccount;
    //     System.debug('Contact --> lstAccount --> '+lstAccount);
    // }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String str = 'SELECT Id, Contact_Parent_Account__c,Contact_Number__c,NBA_Account__c,Status__c,Description__c,Party_Account__c, Contact_Customer_Type__c,Salutation__c,Contact_First_Name__c,Contact_Middle_Name__c,Contact_Last_Name__c,Designation__c,Responsibility__c,Contact_Phn_Code__c, Contact_Cell_Phone__c, Contact_Email_Address__c, Fax_Phone__c,Alternate_Email_Addr__c,Contact_Address_Line_1__c, Contact_Address_Line_2__c, Contact_Address_Line_3__c, Contact_Pincode__c, Contact_City__c, Contact_Country__c,Contact_State__c, Contact_Implementation_Circle__c, Contact_Zone__c, Contact_GST_Applicable__c, GST__c, Contact_Standard_Reason__c, Active__c, Remark__c, Document_Start_Date__c, Document_End_Date__c ,Siebel_Contact__c,Siebel_Contact_Id__c, GST_Non_Applicable_Reason__c	 FROM ARTL_DataMigrationStaging__c where type__c = \'Contact\'  ';
         System.debug('ARTL_DatamigratinStagingBatch --> '+str);
         return Database.getQueryLocator(str);
         
    }

    global void execute(Database.BatchableContext BC, List<sObject> lstData1) {
        List<ARTL_DataMigrationStaging__c> lstData =(List<ARTL_DataMigrationStaging__c>)lstData1;
        RecordType BcpDcpRecordTypeId =[select id ,DeveloperName from RecordType  where DeveloperName ='ARTL_BCP_DCP_Contact'];

        Map<string,Id> PincodeList = new Map<string,Id>();
        List<String> pincodenames = new List<String>();
        List<string> gstnames = new List<string>();
        List<String> connames = new List<string>();
        List<String> premnames = new List<string>();
        List<String> accnames = new List<String>();
         for(ARTL_DataMigrationStaging__c stagingRecord : lstData){
             accnames.add(stagingRecord.Contact_Parent_Account__c);
             gstnames.add(stagingRecord.GST__c);
             string Externalid =stagingRecord.Contact_Parent_Account__c+stagingRecord.Contact_Address_Line_1__c+stagingRecord.Contact_City__c+stagingRecord.Contact_State__c+stagingRecord.Contact_Pincode__c;
             premnames.add(Externalid);
             pincodenames.add(stagingRecord.Contact_Pincode__c);
             string conEx = stagingRecord.Contact_First_Name__c + stagingRecord.Contact_Last_Name__c + stagingRecord.Contact_Cell_Phone__c + stagingRecord.Contact_Email_Address__c +stagingRecord.Siebel_Contact__c;
             connames.add(conEx);
        }
        List<ARTL_Pincode__c> getPincode = [select id , Name from ARTL_Pincode__c where name=:pincodenames];
        for(ARTL_Pincode__c pin :getPincode){
            PincodeList.put(pin.Name,pin.id);

        }

        System.debug('lstdata --> '+ lstData);
        List<Contact> lstContact = new List<Contact>();
        List<vlocity_cmt__Premises__c> lstPremises = new List<vlocity_cmt__Premises__c>();
        List<GST__c> GstList = new List<GST__c>();
        
        
        List<GST__C> GetGstList = [select id , name from Gst__c where name=:gstnames];
        Map<string,id> gstids = new Map<string,id>();
        for(gst__c gt:GetGstList){
			gstids.put(gt.name,gt.id);            
        }
        map<String, Id> mapCon = new map<String,Id>();
        map<string, Id> mapPremises = new map<string,Id>();
        map<string,string> mappcr = new map<string,string>();
        List<ContactPremiseRelation__c> lstConPremiseRelation = new List<ContactPremiseRelation__c>();
        Boolean flag = true;
        map<string,AccountContactRelation> mapconPremiseRelation = new map<string,AccountContactRelation>();
        
        List<AccountContactRelation> lstAccCon = new List<AccountContactRelation>();
        List<AccountContactRelation> lstAccCon1 = new List<AccountContactRelation>();
        String businessRecorTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        List<Account> lstAcc =[Select id ,AccountNumber from Account where AccountNumber=:accnames ];
        system.debug('business acc 40: '+lstAcc);
        
        Map<string , id> mapacc = new Map<string , id>();
        for(Account loopAcc : lstAcc){
            mapacc.put(loopAcc.AccountNumber , LoopAcc.id);
        }

        String billingAggregatorRecorTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing Aggregator').getRecordTypeId();
        List<Account> lstNBAacc = [Select id ,AccountNumber ,ParentId from Account where AccountNumber=:accnames AND recordtypeId =:billingAggregatorRecorTypeid];
        //It should be NABAccount List, else query will fails
        Map<string,account> mapNBAacc = new Map<string,account>();
        for(account nba: lstNBAacc ){
            mapNBAacc.put(nba.AccountNumber, nba);
        }

        List<ARTL_DataMigrationStaging__c> lstStagingRecordsToUpdate = new List<ARTL_DataMigrationStaging__c>();
        List<ARTL_DataMigrationStaging__c> lstStagingRecordsToUpdategst = new List<ARTL_DataMigrationStaging__c>();
        List<ARTL_DataMigrationStaging__c> lstStagingRecordsToUpdatePremises = new List<ARTL_DataMigrationStaging__c>();
        List<ARTL_DataMigrationStaging__c> lstStagingRecordsToUpdateConPreRel = new List<ARTL_DataMigrationStaging__c>();
        Map<string,ARTL_DataMigrationStaging__c> mapconDataMig = new Map<string,ARTL_DataMigrationStaging__c>();
        List<ARTL_DataMigrationStaging__c> lstContactData = new List<ARTL_DataMigrationStaging__c>();
        List<ARTL_DataMigrationStaging__c> lstPremisesData = new List<ARTL_DataMigrationStaging__c>();
        List<ARTL_DataMigrationStaging__c> lstConPremStaging = new List<ARTL_DataMigrationStaging__c>();
        List<Contact> getContact = [select id , External_Id__c from Contact  where External_Id__C =:connames ];
        Map<string,id> mapgetcontact = new Map<string,id>();
        for(Contact cn: getContact){
            mapgetcontact.put(cn.External_Id__c,cn.Id);
            
        }
        List<vlocity_cmt__Premises__c> getPremises = [select id ,External_Id__c from vlocity_cmt__Premises__c where External_Id__c =: premnames];
        Map<string,id> mapgetpremises = new Map<string,id>();
        for(vlocity_cmt__Premises__c pre :getPremises){
            mapgetpremises.put(pre.External_Id__c,pre.id);
        }
        for (ARTL_DataMigrationStaging__c stagingRecord : lstData) {
            
            //Gst records Creation
            GST__c gs = new GST__c();
            gs.Name=stagingRecord.GST__c;
            gs.Account__c=mapNBAacc.get(stagingRecord.Contact_Parent_Account__c)?.Parentid;
            //gs.ARTL_Address__c=stagingRecord.Contact_Address_Line_1__c;
            gs.Address_Line_1__c= stagingRecord.Contact_Address_Line_1__c;
            gs.Address_Line_2__c=stagingRecord.Contact_Address_Line_2__c;
            gs.ARTL_Address__PostalCode__s=stagingRecord.Contact_Pincode__c;
            gs.ARTL_Address__City__s= stagingRecord.Contact_City__c;
            gs.Status__c='Active';
            gs.State__c= stagingRecord.Contact_State__c;
            if(!gstids.containsKey(stagingRecord.GST__c)){
                GstList.add(gs);
            lstStagingRecordsToUpdategst.add(stagingRecord);
            }
            

            Contact con = new Contact();
            //con.AccountId = stagingRecord.Contact_Parent_Account__c;
            con.vlocity_cmt__IsActive__c=Boolean.ValueOf(stagingRecord.Active__c);
            con.ARTL_Alternate_Email__c=stagingRecord.Alternate_Email_Addr__c;
            con.Phone = stagingRecord.Contact_Cell_Phone__c;
            con.Email = stagingRecord.Contact_Email_Address__c;
            con.RecordTypeId=BcpDcpRecordTypeId.id;
            //con.OtherPhone = stagingRecord.Fax_Phone__c;
            if(PincodeList.containskey(stagingRecord.Contact_Pincode__c)){
                con.ARTL_Mailing_Pincode__c=PincodeList.get(stagingRecord.Contact_Pincode__c);
            
            }
            
            //con.Title=
            con.LastName = stagingRecord.Contact_Last_Name__c;
            con.vlocity_cmt__MiddleName__c=stagingRecord.Contact_Middle_Name__c;
            con.AccountId = mapNBAacc.get(stagingRecord.Contact_Parent_Account__c)?.id;
            system.debug('accountid 69 :'+mapNBAacc.get(stagingRecord.Contact_Parent_Account__c)?.id);
            //con.NBA_Account__c= stagingRecord.NBA_Account__c;
            con.vlocity_cmt__ContactNumber__c=stagingRecord.Contact_Number__c;
            con.Country_Code__c=stagingRecord.Contact_Phn_Code__c;
            con.MailingStreet=stagingRecord.Contact_Address_Line_1__c;
            con.MailingCity=stagingRecord.Contact_City__c;
            con.MailingCountry=stagingRecord.Contact_Country__c;
            con.MailingPostalCode =stagingRecord.Contact_Pincode__c;
            con.MailingState= stagingRecord.Contact_State__c;
            con.Description=stagingRecord.Description__c;
            con.ARTL_Contact_Role__c=stagingRecord.Responsibility__c;
            con.vlocity_cmt__Status__c='Active';
            //con.vlocity_cmt__Type__c=stagingRecord.Contact_Customer_Type__c;

            con.CurrencyIsoCode = 'INR';
            con.Salutation = stagingRecord.Salutation__c;
            con.FirstName = stagingRecord.Contact_First_Name__c;
            con.ARTL_Designation__c = stagingRecord.Designation__c;
            con.title=stagingRecord.Designation__c;
            con.Fax = stagingRecord.Fax_Phone__c;
            string conEx = stagingRecord.Contact_First_Name__c + stagingRecord.Contact_Last_Name__c + stagingRecord.Contact_Cell_Phone__c + stagingRecord.Contact_Email_Address__c +stagingRecord.Siebel_Contact__c;
            con.External_Id__c=conEx;
            con.Siebel_Id__c=stagingRecord.Siebel_Contact_Id__c;
            mapconDataMig.put(conEx,stagingRecord);
            if(con.AccountId!=null ){   //&& !mapgetcontact.containsKey(conEx) removed from if condition
                lstContact.add(con);
                lstContactData.add(stagingRecord);
                
         }else If(con.AccountId==null){
            stagingRecord.Error_Message__c='Contact Can\'t be Created without Account Id Or No Matching Account Found with the Account Number';
         }
            /*else if(mapgetcontact.containsKey(conEx)){
                stagingRecord.Error_Message__c='Contact Is Already Exists';
                stagingRecord.Contact_Lookup__c=mapgetcontact.get(conEx);
                lstStagingRecordsToUpdate.add(stagingRecord);
            }*/

             vlocity_cmt__Premises__c premises = new vlocity_cmt__Premises__c();

            premises.Business_Account__c=mapNBAacc.get(stagingRecord.Contact_Parent_Account__c)?.parentId;
            premises.External_Id__c=stagingRecord.Contact_Parent_Account__c+stagingRecord.Contact_Address_Line_1__c+stagingRecord.Contact_City__c+stagingRecord.Contact_State__c+stagingRecord.Contact_Pincode__c;
            premises.vlocity_cmt__StreetAddress__c = stagingRecord.Contact_Address_Line_1__c;
            premises.vlocity_cmt__Address1__c = stagingRecord.Contact_Address_Line_2__c;
            premises.vlocity_cmt__Address2__c    = stagingRecord.Contact_Address_Line_3__c;
            premises.vlocity_cmt__PostalCode__c  = stagingRecord.Contact_Pincode__c;
            premises.vlocity_cmt__City__c    = stagingRecord.Contact_City__c;
            premises.vlocity_cmt__State__c   = stagingRecord.Contact_State__c;
            premises.vlocity_cmt__Country__c     = stagingRecord.Contact_Country__c;
            lstPremises.add(premises);
            lstPremisesData.add(stagingRecord);

            
        }
        system.debug('lstContact 134 :'+lstContact);
        system.debug('lstContact size 135 :'+lstContact.size());

        //inserting gst
        if(GstList.size()>0){
            List<Database.SaveResult> dsgs = Database.Insert(GstList,false);
            for(Integer i=0; i<dsgs.size() ;i++){
                if(dsgs[i].isSuccess()){
                    lstStagingRecordsToUpdategst[i].GST_Lookup__c=GstList[i].id;
                    lstStagingRecordsToUpdategst[i].Error_Message_Gst__c='';
                    system.debug('gstList'+gstList[i].id);
                    
                } else {
                    lstStagingRecordsToUpdategst[i].Error_Message_Gst__c=String.valueOf(dsgs[i].getErrors());
                    system.debug('gsterrors '+dsgs[i].getErrors());
                }
            }
        }
        // inserting contacts
        
        if (lstContact.size() > 0) {            
           List<Database.SaveResult> dsrs = Database.Insert(lstContact, false);
           for (Integer i = 0; i < dsrs.size(); i++){
               if(dsrs[i].isSuccess()){
                lstContactData[i].Contact_Lookup__c = lstContact[i].Id;
                lstContactData[i].Error_Message__c = '';
                lstStagingRecordsToUpdate.add(lstContactData[i]);
                System.debug('contact id ' +lstContactData[i].Contact_Lookup__c);
                   
               }else{
                lstContactData[i].Error_Message__c='';
                lstContactData[i].Error_Message__c = string.join(dsrs[i].getErrors(),', ');
                   lstStagingRecordsToUpdate.add(lstContactData[i]);
                   system.debug('stagingrecupdate ;'+lstStagingRecordsToUpdate);
                   system.debug('Error Message --> '+lstContactData[i].Error_Message__c);
                }
           }
           
        }
        if(lstStagingRecordsToUpdate.size()>0){
            try{                update lstStagingRecordsToUpdate;             } catch(Exception e){
                system.debug('Dml fail 152: '+e.getMessage());
               }
        }
        

        // insert premises records 

        if (lstPremises.size() > 0) {
           List<Database.SaveResult> dsrs = Database.Insert(lstPremises, false);
           for (Integer i = 0; i < dsrs.size(); i++){
               if(dsrs[i].isSuccess()){
                lstPremisesData[i].Error_Message_Premises__c='';
                lstPremisesData[i].Premises_Lookup__c=lstPremises[i].id;
                lstStagingRecordsToUpdatePremises.add(lstPremisesData[i]);

                   
               }else{
                system.debug('lstPremises[i].External_Id__c :'+lstPremises[i].External_Id__c);
                system.debug(mapgetpremises.keyset());
                if(mapgetpremises.containsKey(lstPremises[i].External_Id__c)){
                    system.debug('check 156');
                    
                    lstPremisesData[i].Premises_Lookup__c=mapgetpremises.get(lstPremises[i].External_Id__c);
                }
                lstPremisesData[i].Error_Message_Premises__c = string.join(dsrs[i].getErrors(),', ');
                lstStagingRecordsToUpdatePremises.add(lstPremisesData[i]);
                   system.debug('Error Message --> '+lstPremisesData[i].Error_Message_Premises__c);
                }
           }
        }
        try{
            update lstStagingRecordsToUpdatePremises;
           } catch(Exception e){
            system.debug('Dml fail 155: '+e.getMessage());
           }

           //******************** ContactPremiseRelation insertion ************************

        for(contact con : lstContact){
            mapCon.put(con.External_Id__C, con.Id);
            system.debug(mapCon);
        }

        for(vlocity_cmt__Premises__c pre : lstPremises){
            mapPremises.put(pre.External_Id__c, pre.Id);
            system.debug(mapPremises);
        }

        //mapping again if they are already present id  in Database

        map<string,Id> MapConget = new map<string,Id>();
        for(contact clist :[select id , External_id__c from contact where External_id__c =:mapCon.keySet()]){
            MapConget.put(clist.External_id__c,clist.Id);
            system.debug('MapConget '+MapConget );

        }
        map<string,Id> MapPremget = new map<string,Id>();
        for(vlocity_cmt__Premises__c prem:[select id , External_Id__C from vlocity_cmt__Premises__c where External_id__c =:mapPremises.keySet()] ){
            MapPremget.put(prem.External_id__C , prem.Id);
            system.debug('MapPremget '+MapPremget);
        }
        for (ARTL_DataMigrationStaging__c stagingRecord : lstData){
        ContactPremiseRelation__c conRelation = new ContactPremiseRelation__c();
            string cprname = stagingRecord.Contact_Number__c+' - '+stagingRecord.Contact_First_Name__c+' '+stagingRecord.Contact_Last_Name__c;
            conRelation.Name = cprname; 
            conRelation.Siebel_Id__c=stagingRecord.Siebel_Contact_Id__c;
            conRelation.BCP_DCP_Number__c=stagingRecord.Siebel_Contact_Id__c;
            conRelation.External_Id__c=stagingRecord.Siebel_Contact__c;
            string ConExternal = stagingRecord.Contact_First_Name__c + stagingRecord.Contact_Last_Name__c + stagingRecord.Contact_Cell_Phone__c + stagingRecord.Contact_Email_Address__c +stagingRecord.Siebel_Contact__c;
            if(MapConget.get(ConExternal)!=null){
                system.debug('MapConget.get(ConExternal)  '+MapConget.get(ConExternal) ); 
                conRelation.Contact__c =MapConget.get(ConExternal);
                system.debug('check contact id '+conRelation.Contact__c);
            }
            string PreExternal = stagingRecord.Contact_Parent_Account__c+stagingRecord.Contact_Address_Line_1__c+stagingRecord.Contact_City__c+stagingRecord.Contact_State__c+stagingRecord.Contact_Pincode__c;

            if(MapPremget.get(PreExternal)!=null){
                system.debug('MapPremget.get(PreExternal)  '+MapPremget.get(PreExternal) );
                conRelation.Premises__c =MapPremget.get(PreExternal);
                system.debug('check premises id '+conRelation.Premises__c);
            }
            conRelation.Gst__c=gstids.get(stagingRecord.Gst__c);
            conRelation.ARTL_GST_Applicable__c = stagingRecord.Contact_GST_Applicable__c;
            conRelation.ARTL_Standard_Reason__c=stagingRecord.GST_Non_Applicable_Reason__c;
            if(stagingRecord.Contact_Customer_Type__c=='Dispatch Contact Person'){
                conRelation.Role__c='DCP';
            } else if(stagingRecord.Contact_Customer_Type__c=='Billing Contact Person'){
                conRelation.Role__c='BCP';
            }
            //conRelation.Role__c = stagingRecord.Contact_Customer_Type__c;
            lstConPremiseRelation.add(conRelation);
            lstConPremStaging.add(stagingRecord);

        }
        if (lstConPremiseRelation.size() > 0) {            
           List<Database.SaveResult> dsrs = Database.Insert(lstConPremiseRelation, false);
           for (Integer i = 0; i < dsrs.size(); i++){
               if(dsrs[i].isSuccess()){
                lstConPremStaging[i].Contact_Premise_Relation_Lookup__c = lstConPremiseRelation[i].Id;
                lstConPremStaging[i].Error_Message_ConPreRel__c = '';
                lstStagingRecordsToUpdateConPreRel.add(lstConPremStaging[i]);
                system.debug('ConPremRel id '+lstConPremStaging[i].Contact_Premise_Relation_Lookup__c);
                   
               }else{
                lstConPremStaging[i].Error_Message_ConPreRel__c='';
                lstConPremStaging[i].Error_Message_ConPreRel__c = string.join(dsrs[i].getErrors(),', ');
                   lstStagingRecordsToUpdateConPreRel.add(lstConPremStaging[i]);
                   system.debug('stagingrecupdate ;'+lstStagingRecordsToUpdateConPreRel);
                   system.debug('Error Message --> '+lstConPremStaging[i].Error_Message_ConPreRel__c);
                }
           }
           try{
            update lstStagingRecordsToUpdateConPreRel;
           } catch(Exception e){
            system.debug('Dml fail 152: '+e.getMessage());
           }
           
        }

        //************************AccountContactRelation ***********************************

        List<ARTL_DataMigrationStaging__c> lstStagingRecordsToUpdateAccConRel = new List<ARTL_DataMigrationStaging__c>();

        /*String billingAggregatorRecorTypeidACR = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Billing Aggregator').getRecordTypeId();
        List<Account> lstNBAaCR = [Select id ,AccountNumber from Account where Recordtypeid = : billingAggregatorRecorTypeidACR];
        Map<string,Id> mapNBAacr = new Map<string,Id>();
        for(account nba: lstNBAaCR ){
            mapNBAacr.put(nba.AccountNumber, nba.id);
        }*/

        
        for (ARTL_DataMigrationStaging__c stagingRecord : lstData){
        AccountContactRelation accCon = new AccountContactRelation();
            string ACRExternal = stagingRecord.Contact_Parent_Account__c+' '+stagingRecord.Contact_First_Name__c+stagingRecord.Contact_Last_Name__c+stagingRecord.Contact_Cell_Phone__c+stagingRecord.Contact_Email_Address__c;
            accCon.External_Id__c=ACRExternal;
            //accCon.CurrencyIsoCode = 'INR';
            
            accCon.AccountId=mapNBAacc.get(stagingRecord.Contact_Parent_Account__c)?.parentId;
            string ConExternal = stagingRecord.Contact_First_Name__c + stagingRecord.Contact_Last_Name__c + stagingRecord.Contact_Cell_Phone__c + stagingRecord.Contact_Email_Address__c +stagingRecord.Siebel_Contact__c;
            if(MapConget.get(ConExternal)!=null){
                system.debug('MapConget.get(ConExternal)  '+MapConget.get(ConExternal) );
                accCon.ContactId =MapConget.get(ConExternal);
                
                system.debug('check accCon.contact id '+accCon.ContactId);
            }
            if(stagingRecord.Contact_Customer_Type__c=='Dispatch Contact Person'){
                accCon.Roles='DCP';
            } else if(stagingRecord.Contact_Customer_Type__c=='Billing Contact Person'){
                accCon.Roles='BCP';
            } 
                //accCon.Roles = stagingRecord.Contact_Customer_Type__c;
                mapconPremiseRelation.put(ACRExternal,accCon);
                
            
            mappcr.put(ACRExternal,stagingRecord.Contact_Customer_Type__c);

            system.debug('accCon.AccountId '+accCon.AccountId);
            
            
        }
        if (mapconPremiseRelation.size() > 0) {
            List<AccountContactRelation> lstAccConRel =mapconPremiseRelation.values();
           // lstAccConRel.add(mapconPremiseRelation.values());
            List<Database.SaveResult> dsrs = Database.Insert(lstAccConRel, false);
            for (Integer i = 0; i < dsrs.size(); i++){
               if(dsrs[i].isSuccess()){
                
                lstData[i].Error_Message_AccConRel__c = '';
                lstData[i].AccountContactRel_Lookup__c=lstAccConRel[i].Id;
                lstStagingRecordsToUpdateAccConRel.add(lstData[i]);
                   
               }else{
                   lstData[i].Error_Message_AccConRel__c='';
                   lstData[i].Error_Message_AccConRel__c = string.join(dsrs[i].getErrors(),', ');
                   lstStagingRecordsToUpdateAccConRel.add(lstData[i]);
                   system.debug('stagingrecupdate ;'+lstStagingRecordsToUpdateAccConRel);
                   system.debug('Error Message --> '+lstData[i].Error_Message_AccConRel__c);
                }
           }
           try{
            update lstStagingRecordsToUpdateAccConRel;
           } catch(Exception e){
            system.debug('Dml fail 313: '+e.getMessage());
           }
           

         }

       
    }

    global void finish(Database.BatchableContext BC) {
         /*if(!errorMap.isEmpty()){
            AsyncApexJob a = [SELECT id, ApexClassId,
                       JobItemsProcessed, TotalJobItems,
                       NumberOfErrors, CreatedBy.Email
                       FROM AsyncApexJob
                       WHERE id = :BC.getJobId()];
            String body = 'Data Migration for Staging Records type Contact '
             + 'ARTL_DataMigrationContact '
             + 'has finished. \n' 
             + 'There were '
             + errorMap.size()
             + ' errors.';
            
            String finalstr = 'Id, Name, Error \n';
            String subject = 'Account - Apex Batch Error  : Data Migration for Staging Records type Contact';
            String attName = 'Account Contact Errors.csv';
            for(Id id  : errorMap.keySet()){
                string err = errorMap.get(id);
                Contact acct = (Contact) IdToSObjectMap.get(id);
                vlocity_cmt__Premises__c pre = (vlocity_cmt__Premises__c) IdToSObjectMap.get(id);
                AccountContactRelation accCont = (AccountContactRelation) IdToSObjectMap.get(id);
                ContactPremiseRelation__c conPre = (ContactPremiseRelation__c) IdToSObjectMap.get(id);
                
                string recordString = '"'+id+'","'+acct.Name+'","'+err+'"\n';
                string recordString1 = '"'+id+'","'+pre.id+'","'+err+'"\n';
                string recordString2 = '"'+id+'","'+accCont.id+'","'+err+'"\n';
                string recordString3 = '"'+id+'","'+conPre.id+'","'+err+'"\n';
                
                finalstr = finalstr +recordString +recordString1+' '+ recordString2+ ' '+ recordString3 ;
            } 
 
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(attName);
            efa.setBody(Blob.valueOf(finalstr));
            
            email.setSubject( subject );
            email.setToAddresses( new String[] {a.CreatedBy.Email} );
            //email.setToAddresses( new String[] {UserInfo.getUserId().Email} );
            email.setPlainTextBody( body );
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
 
            Messaging.SendEmailResult [] r = 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
            }*/
    }
}