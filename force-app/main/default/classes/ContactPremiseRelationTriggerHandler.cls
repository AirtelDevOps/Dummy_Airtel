/**
* Class to implement the trigger handler for ContactPremiseRelation Object
*
* @Author  Salesforce
*
*/

public class ContactPremiseRelationTriggerHandler extends TriggerHandler{
    List<ContactPremiseRelation__c> newContactPremiseRelationMap = (List<ContactPremiseRelation__c>) Trigger.New;
    Map<Id, ContactPremiseRelation__c> oldContactPremiseRelationMap = (Map<Id, ContactPremiseRelation__c>) Trigger.oldMap;
    
    public ContactPremiseRelationTriggerHandler() {
        this.newContactPremiseRelationMap = (List<ContactPremiseRelation__c>) Trigger.New;
        this.oldContactPremiseRelationMap = (Map<Id, ContactPremiseRelation__c>) Trigger.oldMap;
    }
    Map<Id,String> IPMap = new Map<Id,String>();
    
    public override void beforeInsert(){
        
        if (Trigger.isInsert && Trigger.isBefore) {
            
            Map<Id,vlocity_cmt__Premises__c > conPremise;
            Map<Id,GST__c> conGST;
            
            if(newContactPremiseRelationMap.size()>0){
                
                Set<Id> premiseState = new Set<Id>();
                for(ContactPremiseRelation__c con: newContactPremiseRelationMap){
                    premiseState.add(con.Premises__c);
                }
                Set<Id> GSTState = new Set<Id>();
                for(ContactPremiseRelation__c con2: newContactPremiseRelationMap){
                    GSTState.add(con2.GST__c);
                }
                if(premiseState.size()>0)
                    conPremise = new Map<Id,vlocity_cmt__Premises__c >([SELECT id,vlocity_cmt__State__c,ARTL_Pincode__r.ARTL_State_Code__c FROM vlocity_cmt__Premises__c where Id IN :premiseState]);
                if(GSTState.size()>0)
                    conGST = new Map<id,GST__c>([SELECT id,ARTL_Address__StateCode__s, ARTL_GST_State_Code__c FROM GST__c where Id In :GSTState ]);
                
                for(ContactPremiseRelation__c Relation: newContactPremiseRelationMap){
                    if(conPremise.size()>0 && conGST.size()>0 && Relation.Premises__c!= NULL && Relation.GST__c!=NULL){
                        if(Integer.valueOf(conPremise.get(Relation.Premises__c).ARTL_Pincode__r.ARTL_State_Code__c) != Integer.valueOf(conGST.get(Relation.GST__c).ARTL_GST_State_Code__c)) {
                            Relation.addError('State Code of the GST does not match with the State Code of the related Contact');
                        }                        
                    }
                }
            }
        }
    }
    
}