/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-12-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class ARTL_BCPDCPBulkDataUpdateController {
	@AuraEnabled
    public static Integer saveStageRecs(List<Object> objList){
        List<ARTL_Bulk_Upload_Staging__c> stageList = new List<ARTL_Bulk_Upload_Staging__c>();
        if(!(objList.isEmpty())){   
            ARTL_Bulk_Upload_Iteration__c itr = new ARTL_Bulk_Upload_Iteration__c();
            itr.Name = 'BCPDCPBulkDataUpdate';
            insert itr;
            for(Object obj : objList){
                Map<String, Object> objRow = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                ARTL_Bulk_Upload_Staging__c bus = new ARTL_Bulk_Upload_Staging__c();
                bus.Record_Id__c = (String)objRow.get('ID');
                bus.First_Name__c = (String)objRow.get('NewFirstName');
                bus.Last_Name__c = (String)objRow.get('NewLastName');
                bus.Email_Address__c = (String)objRow.get('NewEmail');
                bus.Phone__c = (String)objRow.get('NewMobilePhone');
                bus.Role__c = (String)objRow.get('NewRole');
                bus.Designation__c = (String)objRow.get('NewDesignation');
                bus.Street__c = (String)objRow.get('NewStreet');
                bus.City__c = (String)objRow.get('NewCity');
                bus.State__c = (String)objRow.get('NewState');
                bus.Country__c = (String)objRow.get('NewCountry');
                bus.Pincode__c = (String)objRow.get('NewPostalCode');
                bus.Standard_Reason__c = (String)objRow.get('NewStandardReason');
                bus.GST__c = (String)objRow.get('NewGST');
                bus.Status__c = 'Pending';
                bus.ARTL_Bulk_Upload_Iteration__c = itr.Id;
                stageList.add(bus);
            }
            insert stageList;
            if(!Test.isRunningTest()) {
                Id batchJobId = Database.executeBatch(new ARTL_BCPDCPBulkUpdateBatch(itr.Id), 200);
                System.debug('batchJobId-->'+batchJobId);      
            }
        }
        return stageList.size();
    }
}