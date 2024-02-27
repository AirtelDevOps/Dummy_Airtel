/******************************************************************************************************
* @Author       : arka.bhattacharjee@salesforce.com
* @Company      : Salesforce
* @Date         : 21-Feb-2024
* @Test Class   : ARTL_MACDLocationUpdateControllerTest
* @Description  : Controller for artl_MACDLocationUpdate LWC
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date             Comment
*                         Arka Bhattacharjee    21-Feb-2024      Initial Dev
*******************************************************************************************************/
public class ARTL_MACDLocationUpdateController {
/******************************************************************************************************
 * Method Name        : savePremiseRecs
 * Method Description : Save the Premise Records
*******************************************************************************************************/
    @AuraEnabled
    public static Integer savePremiseRecs(List<Object> objList, String qId){
        Integer recCount = 0;
        List<vlocity_cmt__Premises__c> pmList = new List<vlocity_cmt__Premises__c>();
        List<String> qmIdList = new List<String>();
        if(!(objList.isEmpty())){       
            for(Object obj : objList){
                Map<String, Object> objRow = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                vlocity_cmt__Premises__c pm = new vlocity_cmt__Premises__c();
                pm.vlocity_cmt__StreetAddress__c = (String)objRow.get('Street');
                pm.vlocity_cmt__City__c = (String)objRow.get('City');
                pm.vlocity_cmt__State__c = (String)objRow.get('State');
                pm.vlocity_cmt__Country__c = (String)objRow.get('Country');
                pm.vlocity_cmt__PostalCode__c = (String)objRow.get('Pincode');
                qmIdList.add((String)objRow.get('qmId'));
                pmList.add(pm);
            }
            Database.insert(pmList);
            Map<String, String> pmqmMap = new Map<String, String>();
            for(Integer i=0; i<pmList.size(); i++){
                pmqmMap.put(pmList[i].Id,qmIdList[i]);
            }
            List<vlocity_cmt__QuoteMember__c> qmList = new List<vlocity_cmt__QuoteMember__c>();
            for(vlocity_cmt__Premises__c pm : pmList){
                vlocity_cmt__QuoteMember__c qm = new vlocity_cmt__QuoteMember__c();
                qm.vlocity_cmt__StreetAddress__c = pm.vlocity_cmt__StreetAddress__c;
                qm.vlocity_cmt__City__c = pm.vlocity_cmt__City__c;
                qm.vlocity_cmt__State__c = pm.vlocity_cmt__State__c;
                qm.vlocity_cmt__Country__c = pm.vlocity_cmt__Country__c;
                qm.vlocity_cmt__PostalCode__c = pm.vlocity_cmt__PostalCode__c;
                qm.vlocity_cmt__MemberType__c = 'Location';
                qm.vlocity_cmt__QuoteId__c = qId;
                qm.vlocity_cmt__PremisesId__c = pm.Id;
                qm.vlocity_cmt__ParentQuoteMemberId__c = pmqmMap.get(pm.Id);
                qmList.add(qm);
            }
            Database.insert(qmList);
            recCount = qmList.size();
        }
        return recCount;
    }
/******************************************************************************************************
 * Method Name        : saveBulkPremiseRecs
 * Method Description : Save the Premise Records in Bulk
*******************************************************************************************************/
    /*public static void saveBulkPremiseRecs(String inputJsStr){
        Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(inputJsStr);
        String quoteId = (String)jsonMap.get('QuoteId');
        List<Object> qliList = new List<Object>();
        qliList = (List<Object>)jsonMap.get('QuoteLineItems');
        Map<String, String> DCPqmMap = new Map<String, String>();
        for(Object obj : qliList){
            Map<String, Object> objRow = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
            String qmId = (String)objRow.get('Id');
            String newDCPstr = (String)objRow.get('NewDCP');
            String[] newDCP = newDCPstr.split('-');
            String newDCPId = newDCP[0].trim();
            DCPqmMap.put(newDCPId,qmId);
        }
        List<ContactPremiseRelation__c> cprList = new List<ContactPremiseRelation__c>();
        cprList = [Select Id, Premises__c, Premises__r.vlocity_cmt__StreetAddress__c, Premises__r.vlocity_cmt__City__c, 
                   Premises__r.vlocity_cmt__State__c, Premises__r.vlocity_cmt__Country__c, Premises__r.vlocity_cmt__PostalCode__c,
                   BCP_DCP_Number__c From ContactPremiseRelation__c Where BCP_DCP_Number__c = :DCPqmMap.keySet()];
        Map<String, ContactPremiseRelation__c> DCPcprMap = new Map<String, ContactPremiseRelation__c>();
        for(ContactPremiseRelation__c cpr : cprList){
            DCPcprMap.put(cpr.BCP_DCP_Number__c, cpr);
        }
        List<vlocity_cmt__QuoteMember__c> qmList = new List<vlocity_cmt__QuoteMember__c>();
        for(String str : DCPqmMap.keySet()){
            ContactPremiseRelation__c cpr = DCPcprMap.get(str);
            vlocity_cmt__QuoteMember__c qm = new vlocity_cmt__QuoteMember__c();
            qm.vlocity_cmt__StreetAddress__c = cpr.Premises__r.vlocity_cmt__StreetAddress__c;
            qm.vlocity_cmt__City__c = cpr.Premises__r.vlocity_cmt__City__c;
            qm.vlocity_cmt__State__c = cpr.Premises__r.vlocity_cmt__State__c;
            qm.vlocity_cmt__Country__c = cpr.Premises__r.vlocity_cmt__Country__c;
            qm.vlocity_cmt__PostalCode__c = cpr.Premises__r.vlocity_cmt__PostalCode__c;
            qm.vlocity_cmt__MemberType__c = 'Location';
            qm.vlocity_cmt__QuoteId__c = quoteId;
            qm.vlocity_cmt__PremisesId__c = cpr.Premises__c;
            qm.vlocity_cmt__ParentQuoteMemberId__c = DCPqmMap.get(str);
            qm.DCP_Record__c = cpr.Id;
            qmList.add(qm);
        }
        Database.insert(qmList);
    }*/
}