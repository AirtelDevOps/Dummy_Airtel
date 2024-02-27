public with sharing class Artl_BcpDcpCtrl {

    private static string ERROR_NO_CONTACTS_FOUND = 'No recrods available';

    @AuraEnabled()
    public static List<BcpDcpContactWrapper> getBcpDcpByAccId(String accId) {
        try{
            // System.debug('accId=' + accId);
            String bcpDcpRecordTypeName = 'ARTL_BCP_DCP_Contact';
            List<String> roleList = new List<String>{'Billing Contact', 'Delivery Contact'};

            List<BcpDcpContactWrapper> bcpDcpWrapperList = new List<BcpDcpContactWrapper>();

            List<ContactPremiseRelation__c> cprList = [Select Id, ARTL_Standard_Reason__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, 
                                                            Contact__r.MobilePhone, Contact__r.ARTL_Designation__c, Contact__r.ARTL_Contact_Role__c,  
                                                            Contact__r.Account.Name, Contact__r.AccountId, 
                                                            Premises__r.vlocity_cmt__StreetAddress__c, Premises__r.vlocity_cmt__City__c, Premises__r.vlocity_cmt__State__c, Premises__r.vlocity_cmt__Country__c, Premises__r.vlocity_cmt__PostalCode__c, 
                                                            GST__r.Name, 
                                                            Contact__c, Premises__c, GST__c 
                                                        From ContactPremiseRelation__c 
                                                        Where Contact__r.AccountId =: accId
                                                            AND Contact__r.RecordType.DeveloperName =: bcpDcpRecordTypeName
                                                            AND Contact__r.ARTL_Contact_Role__c IN : roleList
                                                        Order By Contact__c, Role__c ];

            // System.debug('cprList=' + cprList.size());
            if (!cprList.isEmpty()) {
                for(ContactPremiseRelation__c cpr : cprList){
                    bcpDcpWrapperList.add(new BcpDcpContactWrapper(cpr));
                }
            } 
            
            return bcpDcpWrapperList;
        }
        catch (Exception e) {
            System.debug('e.getMessage()=' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class BcpDcpContactWrapper{
        @AuraEnabled public String Id{get;set;}
        @AuraEnabled public String firstName{get;set;}
        @AuraEnabled public String lastName{get;set;}
        @AuraEnabled public String email{get;set;}
        @AuraEnabled public String mobilePhone{get;set;}
        @AuraEnabled public String designation{get;set;}
        @AuraEnabled public String role{get;set;}
        @AuraEnabled public String standardReason{get;set;}
        @AuraEnabled public String streetAddress{get;set;}
        @AuraEnabled public String city{get;set;}
        @AuraEnabled public String state{get;set;}
        @AuraEnabled public String country{get;set;}
        @AuraEnabled public String postalCode{get;set;}
        @AuraEnabled public String gstNumber{get;set;}

        // @AuraEnabled public String contactId{get;set;}
        // @AuraEnabled public String premiseId{get;set;}
        // @AuraEnabled public String gstID{get;set;}
        
        public BcpDcpContactWrapper(ContactPremiseRelation__c cpr){
            this.Id = cpr.Id;

            this.firstName = cpr.Contact__r.FirstName;
            this.lastName = cpr.Contact__r.LastName;
            this.email = cpr.Contact__r.Email;
            this.mobilePhone = cpr.Contact__r.MobilePhone;
            this.designation = cpr.Contact__r.ARTL_Designation__c;
            this.role = cpr.Contact__r.ARTL_Contact_Role__c;

            this.standardReason = cpr.ARTL_Standard_Reason__c;

            this.streetAddress = cpr.Premises__r.vlocity_cmt__StreetAddress__c;
            this.city = cpr.Premises__r.vlocity_cmt__City__c;
            this.state = cpr.Premises__r.vlocity_cmt__State__c;
            this.country = cpr.Premises__r.vlocity_cmt__Country__c;
            this.postalCode = cpr.Premises__r.vlocity_cmt__PostalCode__c;

            this.gstNumber = cpr.GST__r.Name;

            // this.contactId = cpr.Contact__c;
            // this.premiseId = cpr.Premises__c;
            // this.gstID = cpr.GST__c;
        }
    }

    // Artl_BcpDcpCtrl.handleNotification('0017200000V7oB8AAJ');
    //method for handling notification
    public static void handleNotification(String targetId) {
        String reportId = System.Label.ARTL_Bulk_Update_BCP_DCP_ReportId; //'00O72000004XF2nEAG';
        String reportPageRef = '{type: "standard__webPage", attributes: { url: "https://business-force-5632--artldevp2.sandbox.lightning.force.com/lightning/r/Report/'+ reportId + '/view?queryScope=userFolders&fv0=' + targetId +'"}}';

        List<CustomNotificationType > customNotificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName = 'ARTL_Bulk_BCP_DCP_Update'];
        
        Messaging.CustomNotification currNotification = new Messaging.CustomNotification();

        currNotification.setTitle('Bulk BCP DCP update completed');
        currNotification.setBody('Click here to see the status.');
        currNotification.setNotificationTypeId(customNotificationType[0].Id);
        //currNotification.setTargetId(targetId);
        currNotification.setTargetPageRef(reportPageRef);
        try {
            currNotification.send(new Set<String> { Userinfo.getUserId() });
        }
        catch (Exception ex) {
            System.debug('Notification Failed: ' + ex.getMessage());
        }
    }
}