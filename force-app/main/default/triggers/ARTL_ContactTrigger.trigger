trigger ARTL_ContactTrigger on Contact (before insert, before update, after insert, after update, after delete) {
    
    Map<Id, Contact> contactNewMap = trigger.newMap;
    Map<Id, Contact> contactOldMap = trigger.oldMap;
    Id bcpDcpRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_BCP_DCP_Contact').getRecordTypeId();
    Id partyRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_Party_Contact').getRecordTypeId();
    
    //new ARTL_ContactTriggerHandler().run();
    //
    if((Trigger.isBefore && Trigger.isInsert) || (Trigger.isBefore && Trigger.isUpdate)) {
        Map<String,String> picklistValues = new Map<String,String>();
        Schema.DescribeFieldResult fieldResult = Contact.Salutation.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry pickListVal : ple){
			picklistValues.put(pickListVal.getValue(),pickListVal.getLabel());
		}
        for(Contact contactRecord : Trigger.new) {
            if((contactRecord.RecordTypeId == bcpDcpRecordTypeId || contactRecord.RecordTypeId == partyRecordTypeId) && !picklistValues.containsKey(contactRecord.Salutation)) {
                contactRecord.addError('Please insert a standard value for Salutation.');
            }
        }
    }
    if(trigger.isBefore && trigger.isUpdate){
        for(Contact cont: trigger.new){
            if(!ARTL_UpdateBcpDcpLwcController.isUpdateBcpDcp && 
               (contactNewMap.get(cont.Id).FirstName != contactOldMap.get(cont.Id).FirstName || 
                contactNewMap.get(cont.Id).MiddleName != contactOldMap.get(cont.Id).MiddleName ||
                contactNewMap.get(cont.Id).LastName != contactOldMap.get(cont.Id).LastName ||
                contactNewMap.get(cont.Id).Salutation  != contactOldMap.get(cont.Id).Salutation ||
                contactNewMap.get(cont.Id).Suffix != contactOldMap.get(cont.Id).Suffix) &&
               contactNewMap.get(cont.Id).RecordTypeId == bcpDcpRecordTypeId){
                   cont.addError('To update a BCP/DCP contact, please use BCP/DCP Number on the global search to search Contact Premise Relationship record and click edit button.');
               }
        }
        
    }
}