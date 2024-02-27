
List<Object> dataSetObjects = (List<Object>) JSON.deserializeUntyped('CURRENT_DATA_PACKS_CONTEXT_DATA');
List<Id> documentTemplateIDs = new List<Id>();
// Get Deployed Document Templates
for (Object obj : dataSetObjects)
{
	Map<String, Object> objMap = (Map<String, Object>) obj;
    if ( objMap.containsKey('Id') && ((Id)objMap.get('Id')).getSObjectType() == vlocity_namespace__DocumentTemplate__c.SObjectType )
    {
        documentTemplateIDs.add((Id)objMap.get('Id'));
    }
}
// Update Deployed Document as Active
if (documentTemplateIDs.size() > 0)
{   
    List<vlocity_namespace__DocumentTemplate__c> documentTemplateToUpdate = new List<vlocity_namespace__DocumentTemplate__c>();
        for(Id dtID : documentTemplateIDs) {
        vlocity_namespace__DocumentTemplate__c dtToUpdate = new vlocity_namespace__DocumentTemplate__c(Id = dtID, vlocity_namespace__IsActive__c = true);
        documentTemplateToUpdate.add(dtToUpdate);
    }
    update documentTemplateToUpdate;
}

//Fix For: If the next version(V8) exists as active then  when I deploy the previous version(V7) then there would be two Document Template versions active.

Set<String> documentTemplateNames = new Set<String>();
for (vlocity_namespace__DocumentTemplate__c N: [SELECT id,Name FROM vlocity_namespace__DocumentTemplate__c WHERE  vlocity_namespace__IsActive__c = true AND id in :documentTemplateIDs ]){
 documentTemplateNames.add(N.Name);
}

//Get the Already Active IDs for Document Template versions
List <vlocity_namespace__DocumentTemplate__c> documentTemplatedeact =[SELECT Id, Name,vlocity_namespace__IsActive__c,vlocity_namespace__Status__c FROM vlocity_namespace__DocumentTemplate__c WHERE Name in :documentTemplateNames  AND vlocity_namespace__IsActive__c = true AND id not in :documentTemplateIDs ];

//Deactivate the versions which were previously Active to ensure that they are not Active
for (vlocity_namespace__DocumentTemplate__c temp : documentTemplatedeact)
{
  temp.vlocity_namespace__IsActive__c = false;
  temp.vlocity_namespace__Status__c = 'Archived';
}

if (documentTemplatedeact.size() > 0){
    update documentTemplatedeact;
}
