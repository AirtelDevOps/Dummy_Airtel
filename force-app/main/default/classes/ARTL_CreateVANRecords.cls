public class ARTL_CreateVANRecords {
    
    public static void generateVAN(Map<Id,String> vanMap,Map<String,Set<Id>> panMap) {
        System.debug('vanMap '+vanMap);
        System.debug('panMap '+panMap);
        List<ARTL_VAN_AccountNumbers__c> vanRecordsToInsert = new List<ARTL_VAN_AccountNumbers__c>();
        List<ARTL_VANLegalEntityWithBanks__mdt> legalEntBank = [SELECT ARTL_VAN_Legal_Entities__r.ARTL_Legal_Entity__c, ARTL_VAN_Legal_Entities__r.ARTL_Legal_Entity_Description__c ,ARTL_VAN_Legal_Entities__r.ARTL_Lob_Identifier__c ,ARTL_VAN_Bank_Details__r.Bank_Code__c,ARTL_VAN_Bank_Details__r.Label,ARTL_VAN_Bank_Details__c,ARTL_VAN_Legal_Entities__c 
                                                                FROM ARTL_VANLegalEntityWithBanks__mdt
                                                                WHERE ARTL_VAN_Legal_Entities__r.ARTL_Active__c = TRUE];
        
        Map<String,List<ARTL_VAN_AccountNumbers__c>> panVanMap = new Map<String,List<ARTL_VAN_AccountNumbers__c>>();

        Set<Id> existingVANRecId = new Set<Id>();

        List<Account> accList = [Select id, Name,ARTL_PAN__c, (SELECT Id,Name__c,ARTL_Business_Account__c,ARTL_PAN__c,ARTL_Fx_System_Id__c,ARTL_FXSynch__c 
                                                               FROM VAN_Account_Numbers__r)
                                 FROM Account
                                 WHERE ARTL_PAN__c=:panMap.keyset() AND Id IN (SELECT ARTL_Business_Account__c FROM ARTL_VAN_AccountNumbers__c)];
        System.debug('accList '+accList);
        for(Account a: accList){
            System.debug('list of vans '+a.VAN_Account_Numbers__r);
            panVanMap.put(a.ARTL_PAN__c,a.VAN_Account_Numbers__r);
		}
        System.debug('panVanMap '+panVanMap);
        if(!accList.isEmpty()){
        
        for(String pan:panMap.keyset()){
            for(Id accountId:panMap.get(pan)){
              existingVANRecId.add(accountId);
                for(ARTL_VAN_AccountNumbers__c vanRecord:panVanMap.get(pan)){
                    System.debug('vanRecord '+vanRecord);
                   ARTL_VAN_AccountNumbers__c vanObj = vanRecord.clone(false, true, false, false);
              	   vanObj.ARTL_Business_Account__c = accountId;
                   vanRecordsToInsert.add(vanObj); 
                }
            }
          }
        }
        
        vanMap.keyset().removeAll(existingVANRecId);
        
        if(!vanMap.isEmpty()) {
        for(Id AccountId: vanMap.keyset())
        {
          for(ARTL_VANLegalEntityWithBanks__mdt metaRec : legalEntBank) {
            String sequence = metaRec.ARTL_VAN_Legal_Entities__r.ARTL_Legal_Entity__c+metaRec.ARTL_VAN_Legal_Entities__r.ARTL_Lob_Identifier__c+metaRec.ARTL_VAN_Bank_Details__r.Bank_Code__c;
            ARTL_VAN_AccountNumbers__c vanRecord = new ARTL_VAN_AccountNumbers__c(Name__c = sequence,
                                                                                  ARTL_Business_Account__c = AccountId,
                                                                             	  ARTL_PAN__c = vanMap.get(AccountId),
                                                                                  ARTL_Legal_Entity_Code__c = metaRec.ARTL_VAN_Legal_Entities__r.ARTL_Lob_Identifier__c,
                                                                                  ARTL_Legal_Entity_Description__c = metaRec.ARTL_VAN_Legal_Entities__r.ARTL_Legal_Entity_Description__c,
                                                                                  ARTL_Legal_Entity_Name__c = metaRec.ARTL_VAN_Legal_Entities__r.ARTL_Legal_Entity__c,
                                                                                  ARTL_Bank__c = metaRec.ARTL_VAN_Bank_Details__r.Label);
            vanRecordsToInsert.add(vanRecord);
			}
        }
        }
        
        if(!vanRecordsToInsert.IsEmpty()){
            insert vanRecordsToInsert;
		}
    }
    
    public static void updateVAN(Map<Id,String> accMap) {
        		System.debug('Inside VAN');
                List<Account> accList = [Select id, Name,ARTL_PAN__c, (SELECT Id,Name__c,ARTL_Business_Account__c,ARTL_PAN__c,ARTL_Fx_System_Id__c,ARTL_FXSynch__c FROM VAN_Account_Numbers__r)
                                 		 FROM Account
                                 		 WHERE Id=:accMap.keyset() AND Id IN (SELECT ARTL_Business_Account__c FROM ARTL_VAN_AccountNumbers__c)];
                System.debug('Inside VAN');
        		List<ARTL_VAN_AccountNumbers__c> vanList = new List<ARTL_VAN_AccountNumbers__c>();
        		for(Account a: accList){
                    for(ARTL_VAN_AccountNumbers__c vanRecord:a.VAN_Account_Numbers__r){
                        vanRecord.ARTL_PAN__c = accMap.get(a.Id);
                        vanList.add(vanRecord);
                        System.debug('myvan'+vanRecord);
                    }
                }
        if(!vanList.isEmpty()){
            update vanList;
        }
        
    }
}