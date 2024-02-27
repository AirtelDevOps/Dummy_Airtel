public class ARTL_VANTriggerHandler extends TriggerHandler{
    Static Integer calledTimes = 1;
    List<ARTL_VAN_AccountNumbers__c> vanList=(List<ARTL_VAN_AccountNumbers__c>)Trigger.New;
    Map<Id,ARTL_VAN_AccountNumbers__c> vanMap=(Map<Id,ARTL_VAN_AccountNumbers__c>)Trigger.NewMap;
    
    public ARTL_VANTriggerHandler(){
        this.vanList=(List<ARTL_VAN_AccountNumbers__c>)Trigger.New;
        this.vanMap=(Map<Id,ARTL_VAN_AccountNumbers__c>)Trigger.NewMap;
    }
    
    public override void afterInsert() {
        List<ARTL_VAN_AccountNumbers__c> updateVANSequence = [SELECT Name__c, ARTL_VAN_Sequence__c
                                                              FROM ARTL_VAN_AccountNumbers__c
                                                              WHERE Id=:vanList];
        
		Map<Id,String> vanIPMap = new Map<Id,String>();
        if(!updateVANSequence.isEmpty()){
        
        for(ARTL_VAN_AccountNumbers__c record: updateVANSequence) {
            if(record.Name__c.length()!=16){
            record.Name__c = record.Name__c + record.ARTL_VAN_Sequence__c;
            system.debug('updated VAN Names '+record.Name__c);
            }
		}
        
            Database.SaveResult[] srList = Database.update(updateVANSequence);
            for (Database.SaveResult sr : srList) {
    			if (sr.isSuccess()) {
                    if(!this.vanMap.get(sr.getId()).ARTL_FXSynch__c){
        				vanIPMap.put(sr.getId(),'ARTL_FXCreateVANAccount');
                    }
    			}
        	}
        }

        if(!vanIPMap.isEmpty() && calledTimes==1) { //
               System.debug('How many times this is called '+calledTimes);
               List<Id> listOfIds = new List<Id>(vanIPMap.keyset());
               listOfIds.sort();
               Map<String, Object> ipInput = new Map<String, Object>();
               System.debug(listOfIds+'VAN Record Ids');
               ARTL_InvokeIP.IntegrationProcedureQueueable ipq = new ARTL_InvokeIP.IntegrationProcedureQueueable(listOfIds,'ARTL_FXCreateVANAccount',ipInput,(new Map<string, object>()),(new Map<string, object>()));
			   System.enqueueJob(ipq);
        }
        calledTimes = calledTimes+1;
        System.debug('How many times this is called '+calledTimes);
    }
    
}