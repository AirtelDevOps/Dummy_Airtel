public class ContractTriggerHandler extends TriggerHandler {
    List<Contract> contractList=(List<Contract>)Trigger.New;
    Map<id,contract> contractOldValList = ( Map<id,contract>)Trigger.oldMap;
    public ContractTriggerHandler(){
        this.contractList=(List<Contract>)Trigger.New;
        this.contractOldValList = ( Map<id,contract>)trigger.oldMap;
    }
    
    public override void beforeInsert() {
        ContractTriggerHelper.runBeforeInsertTriggerEvents(this.contractList);
    }
    public override void afterInsert() {
        ContractTriggerHelper.populateContractLookupOnQuote(this.contractList);
    }
    public override void afterupdate() {
        ContractTriggerHelper.updateQuoteStatusOnContractSigned(this.contractList ,this.contractOldValList );
    }
   
/*
	// after update
    public static void afterUpateUtils(List<contract> newContract , Map<id,contract> oldContrat){
        
        set<id> quoteIds = new Set<id>();
        List<quote> quoteToUpdate = new List<quote>();
        
        if(!newContract.isEmpty()){
            for(contract c : newContract){
                if(c.Status == 'Signed' && oldContrat.get(c.id).status != c.Status){
                    quoteIds.add(c.vlocity_cmt__QuoteId__c);
                }
            }
        }
        if(!quoteIds.isEmpty()){
            for(quote q : [SELECT id , status from quote WHERE id IN: quoteIds]){
                q.Status = 'Customer Signed';
                quoteToUpdate.add(q);
            }
        }
        if(!quoteToUpdate.isEMpty()){
            update quoteToUpdate;
        }
    } */
    /*
    public static void afterInsertUtils(List<contract> conList){

        Map<id,String> quoteMap = new Map<id,String>();
        List<quote> quoteToUpdate = new List<quote>();
        
        if(!conList.isEmpty()){
            for(contract c : conList){
                if(c.RecordType.Name == 'Contract'){
                    quoteMap.put(c.vlocity_cmt__QuoteId__c , c.Id + ';Contract');
                }else 	if(c.RecordType.Name == 'Frame Contract'){
                     quoteMap.put(c.vlocity_cmt__QuoteId__c , c.Id + ';Frame');
                }
            }
        }
        if(!quoteMap.isEmpty()){
            for(Quote q : [SELECT id ,Status , ContractId FROM Quote WHERE id IN : quoteMap.keySet() ]){
                if(quoteMap.containsKey(q.id)){
                    if(quoteMap.get(q.Id).Split(';').contains('Contract')){
                        string [] getId = quoteMap.get(q.Id).Split(';');
                            q.ContractId = getId[0];
                            quoteToUpdate.add(q);
                    }else if(quoteMap.get(q.Id).Split(';').contains('Frame')){
                        string [] getId = quoteMap.get(q.Id).Split(';');
                            q.vlocity_cmt__FrameContractId__c = getId[0];
                            quoteToUpdate.add(q);
                    }
                }
            }
        }
        if(!quoteToUpdate.isEmpty()){
            Update quoteToUpdate;
        }
    } */
}