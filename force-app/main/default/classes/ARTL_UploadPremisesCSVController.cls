/******************************************************************************************************
* @Author       : arka.bhattacharjee@salesforce.com
* @Company      : Salesforce
* @Date         : 02-Jan-2024
* @Test Class   : ARTL_UploadPremisesCSVControllerTest
* @Description  : Controller for artl_UploadPremisesCSV LWC
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date             Comment
*                         Arka Bhattacharjee    02-Jan-2024      Initial Dev
*******************************************************************************************************/
public class ARTL_UploadPremisesCSVController {
/******************************************************************************************************
 * Method Name        : getPinCodes
 * Method Description : Get the Pincode in Database
*******************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<String> getPinCodes(){
        Set<String> pinList = new Set<String>();
        for(ARTL_Pincode__c pin : [Select Name From ARTL_Pincode__c Where ARTL_Country__c = 'India']){
            pinList.add(pin.Name);
        }
        List<String> pinStr = new List<String>(pinList);
        return pinStr;
    }
/******************************************************************************************************
 * Method Name        : getPremiseData
 * Method Description : Get the Premise Records
*******************************************************************************************************/
    @AuraEnabled
    public static List<vlocity_cmt__Premises__c> getPremiseRec(String qId){
        Quote qt = [Select AccountId From Quote Where Id = :qId Limit 1];
        List<vlocity_cmt__QuoteMember__c> qmList = new List<vlocity_cmt__QuoteMember__c>();
        qmList = [Select vlocity_cmt__PremisesId__c From vlocity_cmt__QuoteMember__c Where vlocity_cmt__QuoteId__c = :qId];
        Set<String> pId = new Set<String>();
        for(vlocity_cmt__QuoteMember__c qm : qmList){
            pId.add(qm.vlocity_cmt__PremisesId__c);
        }
        List<vlocity_cmt__Premises__c> pmList = new List<vlocity_cmt__Premises__c>();
        pmList = [Select Id, External_Id__c, vlocity_cmt__StreetAddress__c, vlocity_cmt__City__c, vlocity_cmt__State__c, 
                  vlocity_cmt__Country__c, vlocity_cmt__PostalCode__c, vlocity_cmt__Geolocation__Latitude__s, 
                  vlocity_cmt__Geolocation__Longitude__s From vlocity_cmt__Premises__c Where Id In :pId OR Business_Account__c = :qt.AccountId];
        return pmList;
    }
/******************************************************************************************************
 * Method Name        : savePremiseRecs
 * Method Description : Save the Premise Records
*******************************************************************************************************/
    @AuraEnabled
    public static Integer savePremiseRecs(List<Object> objList, String qId){
        Integer recCount = 0;
        Quote qt = [Select AccountId From Quote Where Id = :qId Limit 1];
        List<vlocity_cmt__Premises__c> pmList = new List<vlocity_cmt__Premises__c>();
        List<vlocity_cmt__Premises__c> inList = new List<vlocity_cmt__Premises__c>();
        List<vlocity_cmt__Premises__c> upList = new List<vlocity_cmt__Premises__c>();
        Set<String> extIds = new Set<String>();
        //Map<String,vlocity_cmt__Premises__c> premMap = new Map<String,vlocity_cmt__Premises__c>();
        if(!(objList.isEmpty())){       
            for(Object obj : objList){
                Map<String, Object> objRow = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                vlocity_cmt__Premises__c pm = new vlocity_cmt__Premises__c();
                pm.External_Id__c = (String)objRow.get('AddressId');
                pm.vlocity_cmt__StreetAddress__c = (String)objRow.get('Street');
                pm.vlocity_cmt__City__c = (String)objRow.get('City');
                pm.vlocity_cmt__State__c = (String)objRow.get('State');
                pm.vlocity_cmt__Country__c = (String)objRow.get('Country');
                pm.vlocity_cmt__PostalCode__c = (String)objRow.get('Pincode');
                if((String)objRow.get('Latitude') != '' && (String)objRow.get('Latitude') != null && (String)objRow.get('Latitude') != ' ' &&
                   (String)objRow.get('Longitude') != '' && (String)objRow.get('Longitude') != null && (String)objRow.get('Longitude') != ' ' ){
                       pm.vlocity_cmt__Geolocation__Latitude__s = Decimal.valueOf((String)objRow.get('Latitude'));
                       pm.vlocity_cmt__Geolocation__Longitude__s = Decimal.valueOf((String)objRow.get('Longitude'));
                   }
                pm.Business_Account__c = qt.AccountId;
                if(pm.External_Id__c != null && pm.External_Id__c != '' && pm.External_Id__c != ' '){
                    extIds.add(pm.External_Id__c);
                    upList.add(pm);
                } else{
                    inList.add(pm);
                }
                //premMap.put(pm.External_Id__c,pm);
                //pmList.add(pm);
            }
            if(!(inList.isEmpty())){
                insert inList;
                pmList.addAll(inList);
            }
            if(!(upList.isEmpty())){
                upsert upList External_Id__c;
                pmList.addAll(upList);
            }
            if(!(pmList.isEmpty())){
                //upsert pmList External_Id__c;
                List<vlocity_cmt__QuoteMember__c> qmList = new List<vlocity_cmt__QuoteMember__c>();
                qmList = [Select Id, vlocity_cmt__PremisesId__c, vlocity_cmt__StreetAddress__c, vlocity_cmt__State__c, vlocity_cmt__City__c, 
                          vlocity_cmt__Country__c, vlocity_cmt__PostalCode__c From vlocity_cmt__QuoteMember__c Where vlocity_cmt__QuoteId__c = :qId
                          AND vlocity_cmt__PremisesId__r.External_Id__c In :extIds AND vlocity_cmt__MemberType__c = 'Location'];
                Map<String,vlocity_cmt__QuoteMember__c> premQmMap = new Map<String,vlocity_cmt__QuoteMember__c>();
                if(!(qmList.isEmpty())){
                    for(vlocity_cmt__QuoteMember__c qm : qmList){
                        premQmMap.put(qm.vlocity_cmt__PremisesId__c, qm);
                    }
                }
                List<vlocity_cmt__QuoteMember__c> qmListToUpdate = new List<vlocity_cmt__QuoteMember__c>();
                for(vlocity_cmt__Premises__c pm : pmList){
                    vlocity_cmt__QuoteMember__c qm = new vlocity_cmt__QuoteMember__c();
                    qm.vlocity_cmt__StreetAddress__c = pm.vlocity_cmt__StreetAddress__c;
                    qm.vlocity_cmt__City__c = pm.vlocity_cmt__City__c;
                    qm.vlocity_cmt__State__c = pm.vlocity_cmt__State__c;
                    qm.vlocity_cmt__Country__c = pm.vlocity_cmt__Country__c;
                    qm.vlocity_cmt__PostalCode__c = pm.vlocity_cmt__PostalCode__c;
                    qm.vlocity_cmt__MemberType__c = 'Location';
                    if(premQmMap.containsKey(pm.Id)){
                        qm.Id = premQmMap.get(pm.Id).Id;
                    }else {
                        qm.vlocity_cmt__PremisesId__c = pm.Id;
                        qm.vlocity_cmt__QuoteId__c = qId;
                    }
                    qmListToUpdate.add(qm);
                }
                upsert qmListToUpdate;
                recCount = qmListToUpdate.size();
            }
        }
        return recCount;
    }
}