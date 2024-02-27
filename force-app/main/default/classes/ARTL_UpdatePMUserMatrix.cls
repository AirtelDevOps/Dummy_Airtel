public with sharing class ARTL_UpdatePMUserMatrix {
    
    @InvocableMethod
    public static void updateMatrix(List<List<ARTL_PMUserMatrixWrapper>> userWrapperList){
        system.debug('userWrapperList--->'+userWrapperList);
        List<ARTL_PMUserMatrixWrapper> userWrapper= userWrapperList[0];
        system.debug('userWrapper--->'+userWrapper);
        system.debug('userWrapper--->'+userWrapper);

        Map<Id,Id> pmUserId = new Map<Id,Id>();
        Map<Id,Id> tlUserId = new Map<Id,Id>();
        Map<Id,Id> cphUserId = new Map<Id,Id>();
        Map<Id,Id> cceUserId = new Map<Id,Id>();
        List<PM_User_Matrix__c> pmMatrixToUpdate = new List<PM_User_Matrix__c>();
        for(ARTL_PMUserMatrixWrapper pmMatrix : userWrapper){
            if(pmMatrix.oldUser != null && pmMatrix.newUser != null && pmMatrix.oldUser != pmMatrix.newUser){
                if(pmMatrix.userType == 'PM')
                    pmUserId.put(pmMatrix.oldUser, pmMatrix.newUser);
                if(pmMatrix.userType == 'TL')
                    tlUserId.put(pmMatrix.oldUser, pmMatrix.newUser);
                if(pmMatrix.userType == 'CPH')
                    cphUserId.put(pmMatrix.oldUser, pmMatrix.newUser);
                if(pmMatrix.userType == 'CCE')
                    cceUserId.put(pmMatrix.oldUser, pmMatrix.newUser);
            }
        }

        for(PM_User_Matrix__c pmRec : [SELECT Id, PM__c, TL__c, CPH__c, CCE__c, Business_Account__c, Circle__c FROM 
                                        PM_User_Matrix__c WHERE
                                        PM__c IN :pmUserId.keySet() OR
                                        TL__c IN :tlUserId.keySet() OR
                                        CPH__c IN :cphUserId.keySet() OR
                                        CCE__c IN :cceUserId.keySet()
                                        ]){
            Boolean isChanged = false;                                
            if(pmUserId.containsKey(pmRec.PM__c)){
                pmRec.PM__c = pmUserId.get(pmRec.PM__c);
                isChanged = true;
            }
            if(tlUserId.containsKey(pmRec.TL__c)){
                pmRec.TL__c = tlUserId.get(pmRec.TL__c);
                isChanged = true;
            } 
            if(cphUserId.containsKey(pmRec.CPH__c)){
                pmRec.CPH__c = cphUserId.get(pmRec.CPH__c);
                isChanged = true;
            } 
            if(cceUserId.containsKey(pmRec.CCE__c)){
                pmRec.CCE__c = cceUserId.get(pmRec.CCE__c);
                isChanged = true;
            } 
            if(isChanged)
                pmMatrixToUpdate.add(pmRec);                                
        }

        Database.update(pmMatrixToUpdate, false);

    }

    
}