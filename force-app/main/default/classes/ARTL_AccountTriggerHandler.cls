public class ARTL_AccountTriggerHandler extends TriggerHandler {
    List<Account> accountList = (List<Account>) Trigger.New;
    Map<Id,Account> accountMap = (Map<Id,Account>) Trigger.OldMap;

    Boolean preventRecusrive = false;
    Id BARecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BillingAggregator').getRecordTypeId();
    Id BusinessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Business').getRecordTypeId();
    
    public ARTL_AccountTriggerHandler() {
        this.accountList = (List<Account>) Trigger.New;
        this.accountMap = (Map<Id,Account>) Trigger.OldMap;
    }
    public override void beforeInsert(){
        if (Trigger.isInsert && Trigger.isBefore) {
            List<String> existList = new List<String>();
            List<Account> newBAAccList = new List<Account>();
            List<Account> existAccBAList =new List<Account>();
            String newStringCheck='';
            for(Account accountObj : accountList){
                if(accountObj.Name != null && accountObj.RecordTypeId == BARecordTypeId && (accountObj.Short_Code__c == null || String.isBlank(accountObj.Short_Code__c))){
                    newBAAccList.add(accountObj);
                    String resultString =  accountObj.Name.replace(' ', '').toUpperCase();
                    if(resultString.length()>=5){
                        newStringCheck = resultString.substring(0, 4)+'%';
                    }
                }else if(accountObj.Name != null && accountObj.RecordTypeId == BARecordTypeId && (accountObj.Short_Code__c != null || String.isNOtBlank(accountObj.Short_Code__c))){
                    String resultString =  accountObj.Short_Code__c.toUpperCase();
                    accountObj.Short_Code__c = resultString;
                }
            }
            if(newBAAccList.Size()>0)
             existAccBAList = [Select Id,Short_Code__c from Account where RecordTypeId =: BARecordTypeId AND 
                                            Short_Code__c != null AND Short_Code__c like : newStringCheck];
            for(Account existAcc :existAccBAList){
                existList.add(existAcc.Short_Code__c);
            }
            for(Account accountObj : newBAAccList){
            if(accountObj.Name != null && accountObj.RecordTypeId == BARecordTypeId && (accountObj.Short_Code__c == null || String.isBlank(accountObj.Short_Code__c))){
            String resultString =  accountObj.Name.replace(' ', '').toUpperCase();
            if(resultString.length()>=5){
            String resultStringcheck = resultString.substring(0, 5);
            if(existList.contains(resultStringcheck)){
                Integer toholdIntVslue=0;
                for(integer i=1;i<=resultString.length();i++){
                    String iteratedString = '';
                    iteratedString = resultString.substring(0, 4) + resultString.substring(toholdIntVslue,i);
                    if(!existList.contains(iteratedString)){
                        accountObj.Short_Code__c = iteratedString;
                        break;
                    }
                    if(i==resultString.length()){
                        accountObj.addError('Short Code Exist');
                    }
                    toholdIntVslue = i;
                  }
            }else if(!existList.contains(resultStringcheck)){
                accountObj.Short_Code__c = resultStringcheck;
            }
           }
           if(resultString.length()<5 && accountObj.RecordTypeId == BARecordTypeId){
           accountObj.addError('Short Code characters are lees than 5');
          }
        }
      }
    }
  }
    
    public override void afterInsert() {
        
        Map<Id, List<String>> accountIPMap = new Map<Id, List<String>>();
        
        if (Trigger.isInsert && Trigger.isAfter) {
            for (Account accountObj : accountList) {
                String recTypeId = accountObj.recordTypeId;
                try{
                if (recTypeId.equals(BARecordTypeId)) {
                    System.debug('BARecordTypeId if 22');
                    if (!accountIPMap.containsKey(accountObj.Id)) {
                        accountIPMap.put(accountObj.Id, new List<String>());
                    }
                    accountIPMap.get(accountObj.Id).add('ARTL_FXNBACreation');
                    accountIPMap.get(accountObj.Id).add('ARTL_NBASolaceQueue');
                }
            }catch(Exception ex){
                System.debug('catch 29');
                ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_AccountTriggerHandler:afterInsert', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
            }
                if (recTypeId.equals(BusinessRecordTypeId) && accountObj.vlocity_cmt__CustomerClass__c != 'EGB') {
                    if (!accountIPMap.containsKey(accountObj.Id)) {
                        accountIPMap.put(accountObj.Id, new List<String>());
                    }
                    accountIPMap.get(accountObj.Id).add('ARTL_FXCreatePartyAccount');
                    accountIPMap.get(accountObj.Id).add('ARTL_PartyCreationFromSolaceQueue');
                }
            }
            
            if (!accountIPMap.isEmpty()) {
                for (Id accountId : accountIPMap.keySet()) {
                    for (String ipAddress : accountIPMap.get(accountId)) {
                        //ARTL_InvokeIP.invokeIPOnAccCreation(accountId, ipAddress);
                        System.enqueueJob(new ARTL_InvokeIPQueueable(accountId,ipAddress));
                    }
                }
            }
        }
    }
    
    public override void beforeUpdate(){
        if (Trigger.isUpdate && Trigger.isBefore) {
            Id profileId = [SELECT Id FROM Profile WHERE NAME = 'System Administrator' LIMIT 1]?.Id;
            Boolean hasKAMPermission    = FeatureManagement.checkPermission('ARTL_KAM_General_User');
            Boolean hasKAMTLPermission  = FeatureManagement.checkPermission('ARTL_KAMTL_User');
            System.debug('isLeadConversion::'+ARTL_LeadConversion.isLeadConversion);
            for(Account accountObj : accountList){
                if(!ARTL_LeadConversion.isLeadConversion && accountObj.RecordTypeId == BusinessRecordTypeId && UserInfo.getProfileId() != profileId && 
                accountMap.get(accountObj.Id).Last_Account_Coverage_DateTime__c == accountObj.Last_Account_Coverage_DateTime__c && 
                accountMap.get(accountObj.Id).vlocity_cmt__Status__c == accountObj.vlocity_cmt__Status__c && 
                (accountObj.vlocity_cmt__Status__c == 'Active' || accountObj.vlocity_cmt__Status__c == 'Approved') && 
                (hasKAMPermission || hasKAMTLPermission)){
                    accountObj.addError('You don\'t have sufficient permissions to edit this record once the Account is Approved/Active. Please contact your System Administrator for more information.');
                }
            }
        }
    }

    public override void afterUpdate() {
        SYstem.debug('After update 56 trigger');
        System.debug('List '+accountList);
        System.debug('Map '+accountMap);
        //Map<Id,String> vanMap = new Map<Id,String>();
        //Map<String,Set<Id>> panMap = new Map<String,Set<Id>>();
        
        Map<Id, List<String>> accountIPMap = new Map<Id, List<String>>();
        Map<String,Map<String,Object>> accountIPWithInput = new Map<String,Map<String,Object>>();
        Map<Id,String> accMap = new Map<Id,String>();
        if (Trigger.isUpdate && Trigger.isAfter) {
            for (Account accountObj : accountList) {
                String recTypeId = accountObj.recordTypeId;
                
                /*if (recTypeId.equals(BusinessRecordTypeId) && 
                    accountObj.vlocity_cmt__Status__c =='Active' && 
                    accountMap.containsKey(accountObj.Id) &&
                    accountMap.get(accountObj.Id).vlocity_cmt__Status__c!='Active' && 
                    !String.isBlank(accountObj.ARTL_PAN__c)) {
                        vanMap.put(accountObj.Id,accountObj.ARTL_PAN__c); 
                        if(!panMap.containsKey(accountObj.ARTL_PAN__c)){
                            panMap.put(accountObj.ARTL_PAN__c,new Set<Id>{accountObj.Id});
                        }
                        	panMap.get(accountObj.ARTL_PAN__c).add(accountObj.Id);
                    }
                
                if (recTypeId.equals(BusinessRecordTypeId) && 
                    accountObj.vlocity_cmt__Status__c =='Active' &&
                    !String.isBlank(accountObj.ARTL_PAN__c) && 
                    accountMap.containsKey(accountObj.Id) &&
                    !String.isBlank(accountMap.get(accountObj.Id).ARTL_PAN__c) &&
                    !accountMap.get(accountObj.Id).ARTL_PAN__c.equals(accountObj.ARTL_PAN__c)) {
                        accMap.put(accountObj.Id,accountObj.ARTL_PAN__c);
                    }*/
                
                if(recTypeId == BusinessRecordTypeId && accountObj.vlocity_cmt__Status__c == 'Approved' && this.accountMap.get(accountObj.Id).vlocity_cmt__Status__c != 'Approved'
                   && accountObj.vlocity_cmt__CustomerClass__c == 'EGB') {
                       if (!accountIPMap.containsKey(accountObj.Id)) {
                           accountIPMap.put(accountObj.Id, new List<String>());
                       }
                       accountIPMap.get(accountObj.Id).add('ARTL_FXCreatePartyAccount');
                       accountIPMap.get(accountObj.Id).add('ARTL_PartyCreationFromSolaceQueue');
                   } 

                if(recTypeId.equals(BARecordTypeId) && preventRecusrive ==false && (accountObj.Step_2_Status__c != accountMap.get(accountObj.Id).Step_2_Status__c && accountObj.Step_2_Status__c == 'Error')) {
                    preventRecusrive =true;
                    Map<String,Object> ipInput = new Map<String,Object>();
                    ipInput.put('recordId',accountObj.Id);
                    ipInput.put('statusCode','7002');
                    ipInput.put('message', 'FX Callout Error.' + accountObj.Step_2_Description__c);
                    accountIPWithInput.put(accountObj.Id + ':' + 'ARTL_NBAResponseToSolace', ipInput);
                }
                if(recTypeId.equals(BARecordTypeId) && preventRecusrive ==false && (accountObj.Step_3_Status__c != accountMap.get(accountObj.Id).Step_3_Status__c && accountObj.Step_3_Status__c == 'Error')) {
                    preventRecusrive =true;
                    Map<String,Object> ipInput = new Map<String,Object>();
                    ipInput.put('recordId',accountObj.Id);
                    ipInput.put('statusCode','7003');
                    ipInput.put('message', 'Solace Callout Error.'+ accountObj.Step_3_Description__c);
                    accountIPWithInput.put(accountObj.Id + ':' + 'ARTL_NBAResponseToSolace', ipInput);
                }
                if(recTypeId.equals(BARecordTypeId) && preventRecusrive ==false && (accountObj.Step_4_Status__c != accountMap.get(accountObj.Id).Step_4_Status__c && accountObj.Step_4_Status__c == 'Error')) {
                    preventRecusrive =true;
                    Map<String,Object> ipInput = new Map<String,Object>();
                    ipInput.put('recordId',accountObj.Id);
                    ipInput.put('statusCode','7004');
                    ipInput.put('message', 'Solace Inbound Call Error.'+ accountObj.Step_4_Description__c);
                    accountIPWithInput.put(accountObj.Id + ':' + 'ARTL_NBAResponseToSolace', ipInput);
                }
                if(recTypeId.equals(BARecordTypeId) && preventRecusrive ==false && (accountObj.Step_1_Status__c == 'Success' && accountObj.Step_2_Status__c == 'Success' && accountObj.Step_3_Status__c == 'Success' && accountObj.Step_4_Status__c != accountMap.get(accountObj.Id).Step_4_Status__c && accountObj.Step_4_Status__c == 'Success')) {
                    preventRecusrive =true;
                    Map<String,Object> ipInput = new Map<String,Object>();
                    ipInput.put('recordId',accountObj.Id);
                    ipInput.put('statusCode','7000');
                    ipInput.put('message', 'Success');
                    accountIPWithInput.put(accountObj.Id + ':' + 'ARTL_NBAResponseToSolace', ipInput);
                }

                if(recTypeId.equals(BusinessRecordTypeId) && preventRecusrive ==false && (accountObj.Step_2_Status__c != accountMap.get(accountObj.Id).Step_2_Status__c && accountObj.Step_2_Status__c == 'Error')) {
                    preventRecusrive =true;
                    Map<String,Object> ipInput = new Map<String,Object>();
                    ipInput.put('recordId',accountObj.Id);
                    ipInput.put('statusCode','8002');
                    ipInput.put('message', 'FX Callout Error.' + accountObj.Step_2_Description__c);
                    accountIPWithInput.put(accountObj.Id + ':' + 'ARTL_NotificationToSolace', ipInput);
                }
                if(recTypeId.equals(BusinessRecordTypeId) && preventRecusrive ==false && (accountObj.Step_3_Status__c != accountMap.get(accountObj.Id).Step_3_Status__c && accountObj.Step_3_Status__c == 'Error')) {
                    preventRecusrive =true;
                    Map<String,Object> ipInput = new Map<String,Object>();
                    ipInput.put('recordId',accountObj.Id);
                    ipInput.put('statusCode','8003');
                    ipInput.put('message', 'Solace Callout Error.'+ accountObj.Step_3_Description__c);
                    accountIPWithInput.put(accountObj.Id + ':' + 'ARTL_NotificationToSolace', ipInput);
                }
                if(recTypeId.equals(BusinessRecordTypeId) && preventRecusrive ==false && (accountObj.Step_4_Status__c != accountMap.get(accountObj.Id).Step_4_Status__c && accountObj.Step_4_Status__c == 'Error')) {
                    preventRecusrive =true;
                    Map<String,Object> ipInput = new Map<String,Object>();
                    ipInput.put('recordId',accountObj.Id);
                    ipInput.put('statusCode','8004');
                    ipInput.put('message', 'Solace Inbound Call Error.'+ accountObj.Step_4_Description__c);
                    accountIPWithInput.put(accountObj.Id + ':' + 'ARTL_NotificationToSolace', ipInput);
                }
                if(recTypeId.equals(BusinessRecordTypeId) && preventRecusrive ==false && (accountObj.Step_1_Status__c == 'Success' && accountObj.Step_2_Status__c == 'Success' && accountObj.Step_3_Status__c == 'Success' && accountObj.Step_4_Status__c != accountMap.get(accountObj.Id).Step_4_Status__c && accountObj.Step_4_Status__c == 'Success')) {
                    preventRecusrive =true;
                    Map<String,Object> ipInput = new Map<String,Object>();
                    ipInput.put('recordId',accountObj.Id);
                    ipInput.put('statusCode','8000');
                    ipInput.put('message', accountObj.Step_1_Description__c  + '. ' + accountObj.Step_2_Description__c + '. ' + accountObj.Step_3_Description__c + '. ' + accountObj.Step_4_Description__c);
                    accountIPWithInput.put(accountObj.Id + ':' + 'ARTL_NotificationToSolace', ipInput);
                }
            }
            
            /*if(!vanMap.isEmpty()){
                ARTL_CreateVANRecords.generateVAN(vanMap,panMap);
            }
            
            if(!accMap.isEmpty()) {
                System.debug('calling update');
                ARTL_CreateVANRecords.updateVAN(accMap);
            }*/
            
            if (!accountIPMap.isEmpty()) {
                for (Id accountId : accountIPMap.keySet()) {
                    for (String ipAddress : accountIPMap.get(accountId)) {
                        system.debug('ipAddress 84 --->>'+ipAddress);
                        System.enqueueJob(new ARTL_InvokeIPQueueable(accountId,ipAddress));
                    }
                }
            }

            if(!accountIPWithInput.isEmpty()) {
                for(String accountIdAndName : accountIPWithInput.keySet()) {
                    List<String> idWithIPName = accountIdAndName.split(':');
                    System.enqueueJob(new ARTL_InvokeIPQueueable(idWithIPName[0],idWithIPName[1],accountIPWithInput.get(accountIdAndName)));
                }
            }
        }
        
        
    }
    public static string GetAccountTeamJSON(string AccountId){
        List<Account> accountList = [SELECT Id,ZSM__c,TSM__c,ARTL_TL__c,VRM__c,VRM_TL__c, AM__c, Owner.OIM_Id__c FROM Account where id=:AccountId];
        string jsonString = '{';
        If(accountList.size() > 0) {
            Account accountRecord = accountList[0];
            jsonString += (accountRecord.ZSM__c == null) ? '"ZSM": "",' : '"ZSM": "' + accountRecord.ZSM__c + '",';
            jsonString += (accountRecord.TSM__c == null) ? '"TSM": "",' : '"TSM": "' + accountRecord.TSM__c + '",';
            jsonString += (accountRecord.ARTL_TL__c == null) ? '"TL": "",' : '"TL": "' + accountRecord.ARTL_TL__c + '",';
            jsonString += (accountRecord.VRM__c == null) ? '"VRM": "",' : '"VRM": "' + accountRecord.VRM__c + '",';
            jsonString += (accountRecord.VRM_TL__c == null) ? '"VRM TL": "",' : '"VRM TL": "' + accountRecord.VRM_TL__c + '",';
            jsonString += (accountRecord.AM__c == null) ? '"AM": "",' : '"AM": "' + accountRecord.AM__c + '",';
            jsonString += (accountRecord.Owner.OIM_Id__c == null) ? '"KAM": "",' : '"KAM": "' + accountRecord.Owner.OIM_Id__c + '",';
        }
        List<AccountTeamMember> atms = [select Id, TeamMemberRole, userId, user.OIM_Id__c from AccountTeamMember where AccountId =:AccountId and TeamMemberRole = 'Secondary KAM'];
        
        if(atms.isEmpty()){
            jsonString += '"Secondary KAM 1 OLM": "",';
            jsonString += '"Secondary KAM 2 OLM": "",';
            jsonString += '"Secondary KAM 3 OLM": "",';
            jsonString += '"Secondary KAM 4 OLM": "",';
            jsonString += '"Secondary KAM 5 OLM": ""';
        }
        If(atms != null & !atms.isEmpty() & atms.size() == 1){
            jsonString += '"Secondary KAM 1 OLM": "' + atms.get(0).user.OIM_Id__c+ '",';
            jsonString += '"Secondary KAM 2 OLM": "",';
            jsonString += '"Secondary KAM 3 OLM": "",';
            jsonString += '"Secondary KAM 4 OLM": "",';
            jsonString += '"Secondary KAM 5 OLM": ""';
        }
        If(atms != null & !atms.isEmpty() & atms.size() == 2){
            jsonString += '"Secondary KAM 1 OLM": "' + atms.get(0).user.OIM_Id__c+ '",';
            jsonString += '"Secondary KAM 2 OLM": "' + atms.get(1).user.OIM_Id__c+ '",';
            jsonString += '"Secondary KAM 3 OLM": "",';
            jsonString += '"Secondary KAM 4 OLM": "",';
            jsonString += '"Secondary KAM 5 OLM": ""';
        }
        If(atms != null & !atms.isEmpty() & atms.size() == 3){
            jsonString += '"Secondary KAM 1 OLM": "' + atms.get(0).user.OIM_Id__c+ '",';
            jsonString += '"Secondary KAM 2 OLM": "' + atms.get(1).user.OIM_Id__c+ '",';
            jsonString += '"Secondary KAM 3 OLM": "' + atms.get(2).user.OIM_Id__c+ '",';
            jsonString += '"Secondary KAM 4 OLM": "",';
            jsonString += '"Secondary KAM 5 OLM": ""';
        }
        If(atms != null & !atms.isEmpty() & atms.size() == 4){
            jsonString += '"Secondary KAM 1 OLM": "' + atms.get(0).user.OIM_Id__c+ '",';
            jsonString += '"Secondary KAM 2 OLM": "' + atms.get(0).user.OIM_Id__c+ '",';
            jsonString += '"Secondary KAM 3 OLM": "' + atms.get(0).user.OIM_Id__c+ '",';
            jsonString += '"Secondary KAM 4 OLM": "' + atms.get(0).user.OIM_Id__c+ '",';
            jsonString += '"Secondary KAM 5 OLM": ""';
        }
        If(atms != null & !atms.isEmpty() & atms.size() == 5){
            jsonString += '"Secondary KAM 1 OLM": "' + atms.get(0).user.OIM_Id__c+ '",';
            jsonString += '"Secondary KAM 2 OLM": "' + atms.get(0).user.OIM_Id__c+ '",';
            jsonString += '"Secondary KAM 3 OLM": "' + atms.get(0).user.OIM_Id__c+ '",';
            jsonString += '"Secondary KAM 4 OLM": "' + atms.get(0).user.OIM_Id__c+ '",';
            jsonString += '"Secondary KAM 5 OLM": "' + atms.get(0).user.OIM_Id__c+ '"';
        }
        jsonString += '}';
        return jsonString;
    }
}