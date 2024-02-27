public class ARTL_CreateDCPController {
    @AuraEnabled(cacheable=true)
    public static List<dispTableWrapper> fetchDCPwire(String quoteId){
        return ARTL_CreateDCPController.fetchDCP(quoteId);
    }
    @AuraEnabled
    public static List<dispTableWrapper> createDCP(List<Object> objList, String quoteId){
        system.debug('Debug:: '+objList);
        try{
            List<Contact> conList = new List<Contact>();
            List<ContactPremiseRelation__c> cprList = new List<ContactPremiseRelation__c>();
            Map<Id,Map<String,String>> qmGSTMap = new Map<Id,Map<String,String>>();
            Map<Id,Contact> qmConMap = new Map<Id,Contact>();
            Quote quot= [SELECT id,ARTL_NBA_Account__c from QUOTE where id=:quoteId];
            for(Object obj : objList){
                system.debug('obj '+obj);
                Map<String, Object> objRow = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(obj));
                Contact con = new Contact();
                con.RecordTypeId = Schema.sObjectType.Contact.getRecordTypeInfosByDeveloperName().get('ARTL_BCP_DCP_Contact').getRecordTypeId();
              //  con.Salutation = 'Mr.';
                con.Salutation = (String)objRow.get('Salutation');
                if(con.Salutation ==null) con.Salutation = 'Mr.';
                con.FirstName = (String)objRow.get('FirstName');
                con.MiddleName = (String)objRow.get('MiddleName');
                con.LastName = (String)objRow.get('LastName');
                con.Phone = (String)objRow.get('Phone');
                con.Email = (String)objRow.get('Email');
                con.ARTL_Designation__c = (String)objRow.get('Designation');
                con.ARTL_Contact_Role__c = 'Delivery Contact';
                con.AccountId=quot.ARTL_NBA_Account__c;
                qmConMap.put((String)objRow.get('qmId'), con);
                conList.add(con);
                Map<String,String> gstobj=new Map<String,String>();
                gstobj.put('GST',(String)objRow.get('GST'));
                gstobj.put('GSTappl',(String)objRow.get('Gstappl'));
                gstobj.put('StdReason',(String)objRow.get('StdReason'));
               // qmGSTMap.put((String)objRow.get('qmId'), (String)objRow.get('GST'));
               qmGSTMap.put((String)objRow.get('qmId'), gstobj);
            }
            insert conList;
            List<vlocity_cmt__QuoteMember__c> qmList = new List<vlocity_cmt__QuoteMember__c>();
            qmList = [Select Id, vlocity_cmt__PremisesId__c, DCP_Record__c,vlocity_cmt__QuoteId__c,vlocity_cmt__QuoteId__r.ARTL_NBA_Account__c From vlocity_cmt__QuoteMember__c Where Id In :qmGSTMap.keySet()];
            Map<Id,ContactPremiseRelation__c> qmCPRMap = new Map<Id,ContactPremiseRelation__c>();
            for(vlocity_cmt__QuoteMember__c qm : qmList){
                ContactPremiseRelation__c cpr = new ContactPremiseRelation__c();
                cpr.Contact__c = qmConMap.get(qm.Id).Id;
                cpr.Premises__c = qm.vlocity_cmt__PremisesId__c;
                cpr.GST__c = (qmGSTMap.get(qm.Id).get('GST') != '') ? qmGSTMap.get(qm.Id).get('GST') : null;
                cpr.ARTL_GST_Applicable__c =qmGSTMap.get(qm.Id).get('GSTappl');
                cpr.ARTL_Standard_Reason__c =qmGSTMap.get(qm.Id).get('StdReason');
                cpr.Role__c = 'DCP';
                cpr.ARTL_NBA_Account__c = qm.vlocity_cmt__QuoteId__r.ARTL_NBA_Account__c;
                cprList.add(cpr);
                qmCPRMap.put(qm.id, cpr);
            }
            insert cprList;
            List<vlocity_cmt__QuoteMember__c> qmListUpdate = new List<vlocity_cmt__QuoteMember__c>();
            for(vlocity_cmt__QuoteMember__c qm : qmList){
                vlocity_cmt__QuoteMember__c qmUpdate =  new vlocity_cmt__QuoteMember__c();
                qmUpdate.Id = qm.Id;
                qmUpdate.DCP_Record__c = qmCPRMap.get(qm.Id).Id;
                qmListUpdate.add(qmUpdate);
            }
            update qmListUpdate;
        }catch(Exception ex){
            system.debug('Exception:: ' +ex.getMessage()+ex.getLineNumber());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_CreateDCPController:createDCP',
                              '', new Map<String,Object>{'Exception'=>ex.getMessage() , 'LineNumber' => ex.getLineNumber()}, ex);
        }
        return ARTL_CreateDCPController.fetchDCP(quoteId);
    }
    @AuraEnabled
    public static List<dispTableWrapper> fetchDCP(String quoteId){
        List<dispTableWrapper> dtwList = new List<dispTableWrapper>();
        try{
            List<vlocity_cmt__QuoteMember__c> qmList = new List<vlocity_cmt__QuoteMember__c>();
            qmList = [Select Id, vlocity_cmt__StreetAddress__c, vlocity_cmt__City__c, vlocity_cmt__State__c, DCP_Record__r.Contact__r.ARTL_Contact_Role__c, DCP_Record__r.Contact__r.ARTL_Designation__c,
                      vlocity_cmt__Country__c, vlocity_cmt__PostalCode__c, DCP_Record__c, DCP_Record__r.DCP__c,
                      DCP_Record__r.GST__c,DCP_Record__r.BCP_DCP_Number__c, DCP_Record__r.GST__r.Name, DCP_Record__r.GST__r.Standard_Reason__c,
                      DCP_Record__r.Contact__c, DCP_Record__r.Contact__r.FirstName, DCP_Record__r.Contact__r.MiddleName,  DCP_Record__r.Contact__r.Salutation,
                      DCP_Record__r.Contact__r.LastName, DCP_Record__r.Contact__r.Phone, DCP_Record__r.Contact__r.Email,
                      DCP_Record__r.ARTL_GST_Applicable__c, DCP_Record__r.ARTL_Standard_Reason__c,vlocity_cmt__PremisesId__c, vlocity_cmt__PremisesId__r.Name, vlocity_cmt__QuoteId__r.AccountId
                      From vlocity_cmt__QuoteMember__c Where vlocity_cmt__QuoteId__c = :quoteId];
            List<GST__c> gstList = new List<GST__c>();   
            if(!(qmList.isEmpty())){
                gstList = [Select Id, Name, State__c,Postal_Code__c,Standard_Reason__c ,ARTL_GST_Type__c,ARTL_Address__c  From GST__c Where Account__c = :qmList[0].vlocity_cmt__QuoteId__r.AccountId];
                // Map<String,List<gstWrapper>> gstMap = new Map<String,List<gstWrapper>>();
                Map<String,Map<String,List<gstWrapper>>> gstMap = new Map<String,Map<String,List<gstWrapper>>>();
                for(GST__c gst : gstList){
                    gstWrapper gstw = new gstWrapper();
                    gstw.label = gst.Name;
                    gstw.value = gst.Id;
                    if(gst.ARTL_Address__c!=null && gst.ARTL_GST_Type__c!=null){
                        Map<String,object> addressval=(Map<String,Object>)JSON.deserializeUntyped((JSON.serialize(gst.ARTL_Address__c)));
                        String state=(string)addressval.get('state');
                        if(gstMap.containsKey(state)){
                            Map<String,List<gstWrapper>> stdReasonMap=gstMap.get(state);
                            if(stdReasonMap.containskey(gst.ARTL_GST_Type__c)){
                                stdReasonMap.get(gst.ARTL_GST_Type__c).add(gstw);
                            }else{
                                stdReasonMap.put(gst.ARTL_GST_Type__c,new List<gstWrapper>{gstw});
                            }                    
                        }
                        else{
                            gstMap.put(state, new Map<String,List<gstWrapper>>{gst.ARTL_GST_Type__c => new List<gstWrapper>{gstw}});
                        }
                    }
                }
                for(vlocity_cmt__QuoteMember__c qm : qmList){
                    dispTableWrapper dtw = new dispTableWrapper();
                    dtw.qmId = qm.Id;
                    dtw.hasPremises = (qm.vlocity_cmt__PremisesId__c != null) ? true : false;
                    dtw.premises = (dtw.hasPremises) ? qm.vlocity_cmt__PremisesId__r.Name : '';
                    dtw.streetAddress = qm.vlocity_cmt__StreetAddress__c +','+qm.vlocity_cmt__City__c +','+qm.vlocity_cmt__State__c +','+qm.vlocity_cmt__Country__c +','+qm.vlocity_cmt__PostalCode__c;
                    dtw.city = qm.vlocity_cmt__City__c;
                    dtw.state = qm.vlocity_cmt__State__c;
                    dtw.country = qm.vlocity_cmt__Country__c;
                    dtw.postalCode = qm.vlocity_cmt__PostalCode__c;
                    dtw.hasDCP = (qm.DCP_Record__c != null) ? true : false;
                    dtw.DCP = (dtw.hasDCP) ? qm.DCP_Record__r.BCP_DCP_Number__c : '';
                    dtw.hasContact = (dtw.hasDCP && qm.DCP_Record__r.Contact__c != null) ? true : false;
                    dtw.salutation = (dtw.hasContact) ? qm.DCP_Record__r.Contact__r.Salutation : '';
                    dtw.firstName = (dtw.hasContact) ? qm.DCP_Record__r.Contact__r.FirstName : '';
                    dtw.middleName = (dtw.hasContact) ? qm.DCP_Record__r.Contact__r.MiddleName : '';
                    dtw.lastName = (dtw.hasContact) ? qm.DCP_Record__r.Contact__r.LastName : '';
                    dtw.designation = (dtw.hasContact) ? qm.DCP_Record__r.Contact__r.ARTL_Designation__c : '';
                    dtw.phone = (dtw.hasContact) ? qm.DCP_Record__r.Contact__r.Phone : '';
                    dtw.email = (dtw.hasContact) ? qm.DCP_Record__r.Contact__r.Email : '';
                    dtw.hasGST = (dtw.hasDCP && qm.DCP_Record__r.GST__c != null) ? true : false;
                    dtw.GST = (dtw.hasGST) ? qm.DCP_Record__r.GST__r.Name : '';
                    dtw.standardReason = qm.DCP_Record__r.ARTL_Standard_Reason__c ;
                    dtw.gstAppl =  qm.DCP_Record__r.ARTL_GST_Applicable__c ;
                    dtw.stdPicklist = new list<Object>();
                    dtw.gstPicklistMap = (!(dtw.hasDCP)) ? gstMap.get(qm.vlocity_cmt__State__c) : null;
                    dtw.gstPicklist=new list<gstwrapper>();
                    dtwList.add(dtw);
                }
            }
        }catch(Exception ex){
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_CreateDCPController:fetchDCP',
                              '', new Map<String,Object>{'Exception'=>ex.getMessage() , 'LineNumber' => ex.getLineNumber()}, ex);
        }
        return dtwList;
    }
    public class dispTableWrapper{
        @AuraEnabled
        public String qmId{get;set;} 
        @AuraEnabled 
        public Boolean hasPremises{get;set;}
        @AuraEnabled 
        public String premises{get;set;}
        @AuraEnabled 
        public String streetAddress{get;set;}
        @AuraEnabled 
        public String city{get;set;}
        @AuraEnabled 
        public String state{get;set;}
        @AuraEnabled 
        public String country{get;set;}
        @AuraEnabled 
        public String postalCode{get;set;}
        @AuraEnabled 
        public Boolean hasDCP{get;set;}
        @AuraEnabled 
        public String DCP{get;set;}
        @AuraEnabled 
        public Boolean hasContact{get;set;}
        @AuraEnabled 
        public String salutation{get;set;}
        @AuraEnabled 
        public String firstName{get;set;}
        @AuraEnabled 
        public String middleName{get;set;}
        @AuraEnabled 
        public String lastName{get;set;}
        @AuraEnabled 
        public String designation{get;set;}
        @AuraEnabled 
        public String phone{get;set;}
        @AuraEnabled 
        public String email{get;set;}
        @AuraEnabled 
        public Boolean hasGST{get;set;}
        @AuraEnabled 
        public String GST{get;set;}
        @AuraEnabled 
        public String standardReason{get;set;}
        @AuraEnabled 
        public String gstAppl{get;set;}
        @AuraEnabled
        public Map<String,List<gstWrapper>> gstPicklistMap{get;set;}
         @AuraEnabled
        public List<Object> stdPicklist{get;set;}
         @AuraEnabled
        public List<gstWrapper> gstPicklist{get;set;}
    }
    public class gstWrapper{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
        
    }
}