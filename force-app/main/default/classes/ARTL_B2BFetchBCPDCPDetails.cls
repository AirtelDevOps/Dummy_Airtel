global class ARTL_B2BFetchBCPDCPDetails  {
     public static string queryB2BBCPDCPJSONResponse(String bcp, String dcp , String accNumber){
        List<ContactPremiseRelation__c> bcdc = [Select Id,BCP_DCP_Number__c,GST__r.ARTL_GST_State_Code__c,  ARTL_NBA_Account__r.Name,ARTL_NBA_Account__r.Short_Code__c, ARTL_NBA_Account__r.ARTL_Business_Circle_Region__c,Role__c,   Contact__r.Siebel_Id__c, Contact__r.Integration_Id__c, Contact__r.vlocity_cmt__IsActive__c, Contact__r.ARTL_Alternate_Email__c,Contact__r.vlocity_cmt__ContactNumber__c,Contact__r.Title,Contact__r.External_Id__c,Contact__r.Fax,Contact__r.FirstName,Contact__r.LastName,Contact__r.MailingCity,
                                                Contact__r.MailingCountry,Contact__r.MailingState,Contact__r.MailingStreet,Contact__r.MailingPostalCode,Contact__r.MiddleName,Contact__r.Email,
                                                Contact__r.Country_Code__c,Contact__r.Account.AccountNumber, Contact__r.ARTL_Contact_Role__c,Contact__r.RecordType.Name,Contact__r.Salutation,Contact__r.vlocity_cmt__Status__c,
                                                Contact__r.ARTL_Designation__c,Premises__r.vlocity_cmt__City__c,Premises__r.vlocity_cmt__Country__c,Premises__r.vlocity_cmt__State__c,Premises__r.vlocity_cmt__StreetAddress__c,
                                                Premises__r.vlocity_cmt__PostalCode__c,Premises__r.Business_Account__c,GST__r.Name,ARTL_GST_Applicable__c,ARTL_Standard_Reason__c,Name,ARTL_NBA_Account__r.AccountNumber, Premises__c, Contact__r.Account.Name from ContactPremiseRelation__c where BCP_DCP_Number__c = : bcp OR BCP_DCP_Number__c = : dcp  OR ARTL_NBA_Account__r.AccountNumber = : accNumber];
        system.debug('bcdc : ' + bcdc);
        system.debug('bcdc size : ' + bcdc.size());
        ARTL_B2BFetchBCPDCPDetails wrapper = new ARTL_B2BFetchBCPDCPDetails();
         wrapper.SiebelMessage = new ARTL_B2BFetchBCPDCPDetails.ClsSiebelMessage();
         wrapper.SiebelMessage.B2BNonBillingAccount = new ARTL_B2BFetchBCPDCPDetails.ClsB2BNonBillingAccount();
         System.debug('before bcpdcp');
         
         System.debug('after bcpdcp');
         wrapper.SiebelMessage.B2BNonBillingAccount.B2BBCPDCPBC = new List<ARTL_B2BFetchBCPDCPDetails.ClsB2BBCPDCPBC>();
         System.debug('after bcpdcp');
         //system.debug('/////'); 
        if(bcdc.size()>0){
            system.debug('inside size check');
             for(ContactPremiseRelation__c cpl :bcdc ){
            if(cpl.Role__c == 'BCP' || cpl.Role__c == 'DCP'){
                system.debug('inside if : ' + cpl.Role__c);
              //  ARTL_ErrorForCreateNBA wrapper = new ARTL_ErrorForCreateNBA();
                wrapper.StatusCode = '';
                wrapper.StatusMessage = 'Contact details returned successfully.';
                
                //wrapper.SiebelMessage = new ARTL_ErrorForCreateNBA.ClsSiebelMessage();
                SYstem.debug('debug 381');
                wrapper.SiebelMessage.IntObjectFormat = 'Siebel Hierarchical';
                wrapper.SiebelMessage.MessageId = '';
                wrapper.SiebelMessage.IntObjectName = '';
                wrapper.SiebelMessage.MessageType = 'Integration Object';
                SYstem.debug('debug 386');
                //wrapper.SiebelMessage.B2BNonBillingAccount =  new ARTL_ErrorForCreateNBA.ClsB2BNonBillingAccount();
                wrapper.SiebelMessage.B2BNonBillingAccount.Name = cpl.ARTL_NBA_Account__r.Name;
                wrapper.SiebelMessage.B2BNonBillingAccount.BCPDCPCount = '';  //// doubt..
                wrapper.SiebelMessage.B2BNonBillingAccount.GSTCount = '';      //// doubt..
                wrapper.SiebelMessage.B2BNonBillingAccount.ShortCode = cpl.ARTL_NBA_Account__r.Short_Code__c;
                wrapper.SiebelMessage.B2BNonBillingAccount.AccountNumber = cpl.ARTL_NBA_Account__r.AccountNumber;
                
                SYstem.debug('debug 394');
             //   wrapper.SiebelMessage.B2BNonBillingAccount.B2BBCPDCPBC = new List<ARTL_ErrorForCreateNBA.ClsB2BBCPDCPBC>();
                // for loop shoulb de there for iteration..
                ARTL_B2BFetchBCPDCPDetails.ClsB2BBCPDCPBC lst = new ARTL_B2BFetchBCPDCPDetails.ClsB2BBCPDCPBC();
                lst.Responsibility = cpl.Contact__r.ARTL_Contact_Role__c;
                lst.Zone = '';
                lst.Pincode =  cpl.Contact__r.MailingPostalCode;
                lst.Country = cpl.Contact__r.MailingCountry;
                lst.LastName = cpl.Contact__r.LastName;
                lst.GSTApplicable = cpl.ARTL_GST_Applicable__c;
                lst.ImplementationCircle =  cpl.ARTL_NBA_Account__r.ARTL_Business_Circle_Region__c;
                lst.Type = cpl.role__c == 'BCP' ? 'Billing Contact Person': cpl.role__c == 'DCP'?  'Dispatch Contact Person' : cpl.role__c == '' ? '' :'' ; //'Billing Contact Person';
                lst.MiddleName = cpl.Contact__r.MiddleName;
                lst.SiebelContactNumber = cpl.Contact__r.vlocity_cmt__ContactNumber__c;
                lst.Designation = cpl.Contact__r.ARTL_Designation__c;
                lst.State = cpl.Contact__r.MailingState;
                lst.PhoneAreaCode = cpl.Contact__r.Country_Code__c;
                lst.AlternateEmailAddress = cpl.Contact__r.ARTL_Alternate_Email__c;
                lst.Status = cpl.Contact__r.vlocity_cmt__Status__c;
                lst.eCRMNumber = '';
                lst.Circle = cpl.ARTL_NBA_Account__r.ARTL_Business_Circle_Region__c ;
                lst.GST = cpl.GST__r.Name;
                lst.GSTStateCode = cpl.GST__r.ARTL_GST_State_Code__c;
                lst.CellularPhone = '';
                lst.EmailAddress = cpl.Contact__r.Email;
                lst.Created = '';
                lst.GSTNonApplicableReason = cpl.ARTL_Standard_Reason__c;
                lst.FaxPhoneNumber = cpl.Contact__r.Fax;
                lst.AddressLine4 = '';
                lst.FirstName = cpl.Contact__r.FirstName;
                lst.AddressLine3 = '';
                lst.AddressLine2 = '';
                lst.MM = '';
                lst.AddressLine1 = '';
                lst.City = cpl.Contact__r.MailingCity;
                SYstem.debug('debug 429');
                wrapper.SiebelMessage.B2BNonBillingAccount.B2BBCPDCPBC.add(lst);
                System.debug('debug 431');
                
            } /* else if(cpl.Role__c == 'DCP'){
                 system.debug('inside else if : ' + cpl.Role__c);
                //ARTL_ErrorForCreateNBA wrapper = new ARTL_ErrorForCreateNBA();
                wrapper.StatusCode = '';
                wrapper.StatusMessage = 'Contact details returned successfully.';
                
               // wrapper.SiebelMessage = new ARTL_ErrorForCreateNBA.ClsSiebelMessage();
                wrapper.SiebelMessage.IntObjectFormat = 'Siebel Hierarchical';
                wrapper.SiebelMessage.MessageId = '';
                wrapper.SiebelMessage.IntObjectName = '';
                wrapper.SiebelMessage.MessageType = 'Integration Object';
                
               // wrapper.SiebelMessage.B2BNonBillingAccount =  new ARTL_ErrorForCreateNBA.ClsB2BNonBillingAccount();
                wrapper.SiebelMessage.B2BNonBillingAccount.Name = cpl.ARTL_NBA_Account__r.Name;
                wrapper.SiebelMessage.B2BNonBillingAccount.BCPDCPCount = '';
                wrapper.SiebelMessage.B2BNonBillingAccount.GSTCount = '';
                wrapper.SiebelMessage.B2BNonBillingAccount.ShortCode = cpl.ARTL_NBA_Account__r.Short_Code__c;
                wrapper.SiebelMessage.B2BNonBillingAccount.AccountNumber = cpl.ARTL_NBA_Account__r.AccountNumber;
                
                
               // wrapper.SiebelMessage.B2BNonBillingAccount.B2BBCPDCPBC = new List<ARTL_ErrorForCreateNBA.ClsB2BBCPDCPBC>();
                // for loop shoulb de there for iteration..
                ARTL_B2BFetchBCPDCPDetails.ClsB2BBCPDCPBC lst = new ARTL_B2BFetchBCPDCPDetails.ClsB2BBCPDCPBC();
                lst.Responsibility =cpl.Contact__r.ARTL_Contact_Role__c;
                lst.Zone = '';
                lst.Pincode = cpl.Contact__r.MailingPostalCode;
                lst.Country = cpl.Contact__r.MailingCountry;
                lst.LastName =cpl.Contact__r.LastName;
                lst.GSTApplicable = cpl.ARTL_GST_Applicable__c;
                lst.ImplementationCircle = cpl.ARTL_NBA_Account__r.ARTL_Business_Circle_Region__c;
                lst.Type = 'Dispatch Contact Person';
                lst.MiddleName = '';
                lst.SiebelContactNumber = '';
                lst.Designation = '';
                lst.State = '';
                lst.PhoneAreaCode = '';
                lst.AlternateEmailAddress = '';
                lst.Status = '';
                lst.eCRMNumber = '';
                lst.Circle = '';
                lst.GST = '';
                lst.GSTStateCode = '';
                lst.CellularPhone = '';
                lst.EmailAddress = '';
                lst.Created = '';
                lst.GSTNonApplicableReason = '';
                lst.FaxPhoneNumber = '';
                lst.AddressLine4 = '';
                lst.FirstName = '';
                lst.AddressLine3 = '';
                lst.AddressLine2 = '';
                lst.MM = '';
                lst.AddressLine1 = '';
                lst.City = '';
                System.debug('debug 485');
                wrapper.SiebelMessage.B2BNonBillingAccount.B2BBCPDCPBC.add(lst);
            } */
             }
        }
        String asst = JSON.serialize(wrapper);
        system.debug('asst : ' + asst);
        return asst;
    }
    public String StatusCode;
    public String StatusMessage;
    public ClsSiebelMessage SiebelMessage;
    
    public class ClsSiebelMessage {
        public String IntObjectFormat;
        public String MessageId;
        public String IntObjectName;
        public String MessageType;
        public ClsB2BNonBillingAccount B2BNonBillingAccount;
    }
    
    public class ClsB2BNonBillingAccount {
        public String Name;
        public String BCPDCPCount;
        public String GSTCount;
        public String ShortCode;
        public String AccountNumber;
        public ClsB2BBCPDCPBC[] B2BBCPDCPBC;
    }
    
    public class ClsB2BBCPDCPBC {
        public String Responsibility;
        public String Zone;
        public String Pincode;
        public String Country;
        public String LastName;
        public String GSTApplicable;
        public String ImplementationCircle;
        public String Type;
        public String MiddleName;
        public String SiebelContactNumber;
        public String Designation;
        public String State;
        public String PhoneAreaCode;
        public String AlternateEmailAddress;
        public String Status;
        public String eCRMNumber;
        public String Circle;
        public String GST;
        public String GSTStateCode;
        public String CellularPhone;
        public String EmailAddress;
        public String Created;
        public String GSTNonApplicableReason;
        public String FaxPhoneNumber;
        public String AddressLine4;
        public String FirstName;
        public String AddressLine3;
        public String AddressLine2;
        public String MM;
        public String AddressLine1;
        public String City;
    }
   
    
}