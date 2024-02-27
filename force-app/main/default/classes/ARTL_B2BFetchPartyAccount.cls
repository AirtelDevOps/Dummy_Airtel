public class ARTL_B2BFetchPartyAccount {
    public static string queryPartyJSONResponse(String AccountNumber, String OrderId){
System.debug('queryPartyJSONResponse');
Account ast = new Account();
List<GST__c> gstList = new List<GST__c>();
List<Account> accList = new List<Account>();
AccountTeamMember accTeamMem = new AccountTeamMember ();
    Order ord = new Order();
System.debug('before if');
if(AccountNumber != null){
System.debug('inside if');
Account accobj = [Select id,Owner.Phone,Parent.ARTL_Collection_Manager__r.Phone,Parent.ARTL_Collection_Manager__r.LastName,Parent.vlocity_cmt__PrimaryContactId__r.LastName,Phone,Parent.ARTL_TL__r.Phone,ARTL_Channel__c,Parent.ARTL_GST_Non_Applicable_Reason__c,Parent.BillingAddress,Parent.ARTL_GST_Applicable__c,Parent.vlocity_cmt__Status__c,Parent.Owner.FirstName, parent.ARTL_PAN__c, 
Parent.Owner.FederationIdentifier,ParentId,Parent.Owner.Email,Parent.Owner.LastName, ARTL_Category__c,Parent.Project_Manager__r.FirstName,BillingPostalCode,
Parent.ARTL_Collection_Manager__r.FirstName,Parent.ARTL_TL__r.LastName, Parent.ARTL_TL__r.FirstName, ARTL_Customer_Segment__c, 
Parent.vlocity_cmt__PrimaryContactId__r.Phone, Parent.Project_Manager__r.Email, isMigrated__c,Parent.AccountNumber,Parent.ARTL_FX_Leo_Account_Number__c,
Parent.ARTL_Service_Segment__c,Parent.Name,Parent.vlocity_cmt__PrimaryContactId__r.FirstName,Parent.ARTL_TL__r.Email,Parent.ARTL_Vertical_Segment__c,
Parent.Project_Manager__r.LastName,Parent.Customer_Origin__c,BillingCountry,Parent.Project_Manager__r.Phone,ARTL_Business_Circle_Region__c                  
from Account where AccountNumber =:AccountNumber];
    
System.debug('first query');
List<GST__c> listGst = [select id,ARTL_GST_Type__c,Account__c,Name from GST__c  where Account__c =: accobj.ParentId];
System.debug('Second query');
List<Account> accountList = [select id,Short_Code__c,AccountNumber,ARTL_Customer_Segment__c,Parent.vlocity_cmt__Status__c,Phone,Name from Account where ParentId = :accobj.ParentId ]; // for non billing account .. panding work.
System.debug('third query');
List<AccountTeamMember> accTeamMember = [Select id,User.LastName, User.FederationIdentifier from AccountTeamMember where AccountId = :accobj.ParentId  AND TeamMemberRole ='SAM'];

System.debug('AccountTeamMember');
ast = accobj;
gstList = listGst;
accList = accountList;
if(!accTeamMember.isEmpty())
accTeamMem = accTeamMember[0];
}else if(AccountNumber == null && orderId != null){
 ord = [select id,AccountId,Account.ARTL_Channel__c,Account.Owner.Email,account.Project_Manager__r.FirstName, account.Owner.LastName, BillingPostalCode, account.ARTL_Collection_Manager__r.FirstName,
        account.ARTL_TL__r.LastName, account.ARTL_TL__r.FirstName, account.vlocity_cmt__PrimaryContactId__r.Phone , 
        account.Project_Manager__r.Email, account.vlocity_cmt__Status__c, account.owner.FirstName, account.ARTL_PAN__c, 
        account.ARTL_TL__r.Phone, account.vlocity_cmt__PrimaryContactId__r.LastName , account.ARTL_Collection_Manager__r.LastName,account.ARTL_GST_Applicable__c, 
        account.BillingAddress,account.ARTL_Collection_Manager__r.Phone ,account.ARTL_GST_Non_Applicable_Reason__c, account.AccountNumber, 
        Owner.Phone, Account.ARTL_FX_Leo_Account_Number__c, account.ARTL_Service_Segment__c, account.Name , 
        account.vlocity_cmt__PrimaryContactId__r.FirstName , account.ARTL_TL__r.Email, account.ARTL_Vertical_Segment__c, 
        account.Project_Manager__r.LastName, account.Customer_Origin__c, BillingCountry, account.Project_Manager__r.Phone,account.Owner.FederationIdentifier   from Order where Id = :orderId];
    
 AccountTeamMember accTeamMember = [Select id,User.LastName, User.FederationIdentifier from AccountTeamMember where AccountId = :ord.AccountId  AND TeamMemberRole ='SAM'];
 List<GST__c> listGst = [select id,Account__c,Name,ARTL_GST_Type__c from GST__c  where Account__c =: ord.AccountId];
 List<Account> accountList = [select id,Parent.vlocity_cmt__Status__c,Phone,Name, Short_Code__c , ARTL_Customer_Segment__c, AccountNumber from Account where ParentId = :ord.AccountId ];
 gstList = listGst;
 accList = accountList;
 accTeamMem = accTeamMember;
}
System.debug('AccountNumber orderId'+orderId+AccountNumber);
if(AccountNumber != null || (AccountNumber == null && orderId != null)){
ARTL_B2BFetchPartyAccount wrapper = new ARTL_B2BFetchPartyAccount();
wrapper.StatusMessage = 'Party details returned successfully';   

wrapper.SFDCMessage = new ARTL_B2BFetchPartyAccount.clsSFDCMessage();
wrapper.SFDCMessage.IntObjectName = 'B2B Party NBA Query';
wrapper.SFDCMessage.MessageType = 'Integration Object';

wrapper.SFDCMessage.B2BParty = new ARTL_B2BFetchPartyAccount.clsB2BParty(); 
wrapper.SFDCMessage.B2BParty.KAMEmail = (AccountNumber != null) ? ast.Parent.Owner.Email :ord.Account.Owner.Email;
wrapper.SFDCMessage.B2BParty.ZSMPhone = '';
wrapper.SFDCMessage.B2BParty.Category = ast.ARTL_Category__c; // not able to get in the order ..
wrapper.SFDCMessage.B2BParty.ProjectManagerFirstName = (AccountNumber != null) ? ast.Parent.Project_Manager__r.FirstName : ord.account.Project_Manager__r.FirstName;
wrapper.SFDCMessage.B2BParty.KAMLastName = (AccountNumber != null) ? ast.Parent.Owner.LastName : ord.account.Owner.LastName;
wrapper.SFDCMessage.B2BParty.OwnedBy = (AccountNumber != null) ? ast.Parent.Owner.FederationIdentifier : ord.account.Owner.FederationIdentifier;
wrapper.SFDCMessage.B2BParty.PrimaryAddressPincode = (AccountNumber != null) ? ast.BillingPostalCode : ord.BillingPostalCode;
wrapper.SFDCMessage.B2BParty.ZSMFirstName = '';
wrapper.SFDCMessage.B2BParty.TSMLastName = '';
wrapper.SFDCMessage.B2BParty.ContactEmailAddress = '';
wrapper.SFDCMessage.B2BParty.CollectionManagerFirstName = (AccountNumber != null) ? ast.Parent.ARTL_Collection_Manager__r.FirstName : ord.account.ARTL_Collection_Manager__r.FirstName; 
wrapper.SFDCMessage.B2BParty.TLLastName = (AccountNumber != null) ? ast.Parent.ARTL_TL__r.LastName : ord.account.ARTL_TL__r.LastName;
wrapper.SFDCMessage.B2BParty.TSMPhone = '';
wrapper.SFDCMessage.B2BParty.GSTCount = string.valueOf(gstList.size());
wrapper.SFDCMessage.B2BParty.SAMPhone = '';
wrapper.SFDCMessage.B2BParty.TSMFirstName = '';
wrapper.SFDCMessage.B2BParty.TLFirstName = (AccountNumber != null) ? ast.Parent.ARTL_TL__r.FirstName : ord.account.ARTL_TL__r.FirstName;
wrapper.SFDCMessage.B2BParty.ZSM = '';
wrapper.SFDCMessage.B2BParty.CustomerSegment = ast.ARTL_Customer_Segment__c;
wrapper.SFDCMessage.B2BParty.ContactPhoneNumber = (AccountNumber != null) ? ast.Parent.vlocity_cmt__PrimaryContactId__r.Phone :ord.account.vlocity_cmt__PrimaryContactId__r.Phone;
wrapper.SFDCMessage.B2BParty.ProjectManagerEmail = (AccountNumber != null) ? ast.Parent.Project_Manager__r.Email : ord.account.Project_Manager__r.Email;
wrapper.SFDCMessage.B2BParty.PartyMigrationFlag = '';
wrapper.SFDCMessage.B2BParty.SAMLastName = accTeamMem.User.LastName;  
wrapper.SFDCMessage.B2BParty.Status = (AccountNumber != null) ? ast.Parent.vlocity_cmt__Status__c : ord.account.vlocity_cmt__Status__c;
wrapper.SFDCMessage.B2BParty.KAMFirstName = (AccountNumber != null) ? ast.Parent.Owner.FirstName : ord.account.owner.FirstName;
wrapper.SFDCMessage.B2BParty.PANNumber = (AccountNumber != null) ? ast.parent.ARTL_PAN__c : ord.account.ARTL_PAN__c;
wrapper.SFDCMessage.B2BParty.TLPhone = (AccountNumber != null) ? ast.Parent.ARTL_TL__r.Phone : ord.account.ARTL_TL__r.Phone;
wrapper.SFDCMessage.B2BParty.Channel = ast.ARTL_Channel__c;
wrapper.SFDCMessage.B2BParty.ContactLastName = (AccountNumber != null) ? ast.Parent.vlocity_cmt__PrimaryContactId__r.LastName : ord.account.vlocity_cmt__PrimaryContactId__r.LastName;
wrapper.SFDCMessage.B2BParty.CollectionManagerLastName = (AccountNumber != null) ? ast.Parent.ARTL_Collection_Manager__r.LastName : ord.account.ARTL_Collection_Manager__r.LastName;
wrapper.SFDCMessage.B2BParty.SAMOLM = '';
wrapper.SFDCMessage.B2BParty.ZSMEmail = '';
wrapper.SFDCMessage.B2BParty.ProjectManager = '';//ast.Project_Manager__c.FederationId;    dont have the field...
wrapper.SFDCMessage.B2BParty.CollectionManager = '';  /// not able to get the field...
wrapper.SFDCMessage.B2BParty.TSM = '';
wrapper.SFDCMessage.B2BParty.Description = '';
wrapper.SFDCMessage.B2BParty.GSTApplicable = String.valueOf((AccountNumber != null) ? ast.Parent.ARTL_GST_Applicable__c : ord.account.ARTL_GST_Applicable__c);
wrapper.SFDCMessage.B2BParty.PrimaryAddressCity = String.valueOf((AccountNumber != null) ? ast.Parent.BillingAddress : ord.account.BillingAddress); 
wrapper.SFDCMessage.B2BParty.ORGTYPE = '';
wrapper.SFDCMessage.B2BParty.CollectionManagerPhone = (AccountNumber != null) ? ast.Parent.ARTL_Collection_Manager__r.Phone : ord.account.ARTL_Collection_Manager__r.Phone;
wrapper.SFDCMessage.B2BParty.Circle = ast.ARTL_Business_Circle_Region__c; ///don't have the field in order ...
wrapper.SFDCMessage.B2BParty.GSTNonApplicableReason = (AccountNumber != null) ? ast.Parent.ARTL_GST_Non_Applicable_Reason__c : ord.account.ARTL_GST_Non_Applicable_Reason__c;
wrapper.SFDCMessage.B2BParty.SFDCAccountNumber = (AccountNumber != null) ? ast.Parent.AccountNumber : ord.account.AccountNumber;
wrapper.SFDCMessage.B2BParty.ZSMLastName = '';
wrapper.SFDCMessage.B2BParty.eCRMAccountNumber = '';
wrapper.SFDCMessage.B2BParty.KAMPhone = (AccountNumber != null) ? ast.Owner.Phone : ord.Owner.Phone;
wrapper.SFDCMessage.B2BParty.PrimaryAddressLine5 = '';
wrapper.SFDCMessage.B2BParty.PrimaryAddressLine4 = '';
wrapper.SFDCMessage.B2BParty.PrimaryAddressLine3 = '';
wrapper.SFDCMessage.B2BParty.Id = (AccountNumber != null) ? ast.ParentId : ord.AccountId;   
wrapper.SFDCMessage.B2BParty.PrimaryAddressLine2 = '';
wrapper.SFDCMessage.B2BParty.PrimaryAddressLine1 = String.valueOf((AccountNumber != null) ? ast.Parent.BillingAddress : ord.account.BillingAddress);
wrapper.SFDCMessage.B2BParty.TSMEmail = '';
wrapper.SFDCMessage.B2BParty.SAMEmail = ''; //// not able to get the email from accountTeamMember
wrapper.SFDCMessage.B2BParty.KAM = '';   /// not getting the field..
wrapper.SFDCMessage.B2BParty.AccountNumber = (AccountNumber != null) ? ast.Parent.AccountNumber :ord.account.AccountNumber;
wrapper.SFDCMessage.B2BParty.FXLeoAccountNumber = (AccountNumber != null) ? ast.Parent.ARTL_FX_Leo_Account_Number__c : ord.Account.ARTL_FX_Leo_Account_Number__c;
wrapper.SFDCMessage.B2BParty.CustomerType = '';
wrapper.SFDCMessage.B2BParty.ServiceSegment = (AccountNumber != null) ? ast.Parent.ARTL_Service_Segment__c : ord.account.ARTL_Service_Segment__c;
wrapper.SFDCMessage.B2BParty.CustomerSegmentNew = '';
wrapper.SFDCMessage.B2BParty.Name = (AccountNumber != null) ? ast.Parent.Name : ord.account.Name;
wrapper.SFDCMessage.B2BParty.ContactFirstName = (AccountNumber != null) ? ast.Parent.vlocity_cmt__PrimaryContactId__r.FirstName : ord.account.vlocity_cmt__PrimaryContactId__r.FirstName;
wrapper.SFDCMessage.B2BParty.TLEmail = (AccountNumber != null) ? ast.Parent.ARTL_TL__r.Email : ord.account.ARTL_TL__r.Email;
wrapper.SFDCMessage.B2BParty.VerticalSegment = (AccountNumber != null) ? ast.Parent.ARTL_Vertical_Segment__c : ord.account.ARTL_Vertical_Segment__c;
wrapper.SFDCMessage.B2BParty.ProjectManagerLastName = (AccountNumber != null) ? ast.Parent.Project_Manager__r.LastName : ord.account.Project_Manager__r.LastName;
wrapper.SFDCMessage.B2BParty.CustomerOrigin = (AccountNumber != null) ? ast.Parent.Customer_Origin__c : ord.account.Customer_Origin__c;
wrapper.SFDCMessage.B2BParty.PrimaryAddressCountry = (AccountNumber != null) ? ast.BillingCountry : ord.BillingCountry;
wrapper.SFDCMessage.B2BParty.ProjectManagerPhone = (AccountNumber != null) ? ast.Parent.Project_Manager__r.Phone : ord.account.Project_Manager__r.Phone;
wrapper.SFDCMessage.B2BParty.ImplementationCircle = ast.ARTL_Business_Circle_Region__c; // not getting field on order..
wrapper.SFDCMessage.B2BParty.CollectionManagerEmail = '';  // no such field on account ...
wrapper.SFDCMessage.B2BParty.SAMFirstName = ''; // not able to get the field from AccountTeamMember..
wrapper.SFDCMessage.B2BParty.TL = '';  // not able to get the field from Account..
wrapper.SFDCMessage.B2BParty.PrimaryAddressState = '';


wrapper.SFDCMessage.B2BParty.B2BGST = new List<ARTL_B2BFetchPartyAccount.clsB2BGST>();   ///
for(GST__c con : gstList){
ARTL_B2BFetchPartyAccount.clsB2BGST newGST = new ARTL_B2BFetchPartyAccount.clsB2BGST();   //
newGST.StartDate = '';
newGST.UINFlag = '';
newGST.EndDate = '';
newGST.GSTNoUINFlag = con.ARTL_GST_Type__c;
newGST.CustomerName = '';
newGST.GSTNumber = '';
wrapper.SFDCMessage.B2BParty.B2BGST.add(newGST);
}
wrapper.SFDCMessage.B2BParty.B2BNonBillingAccount = new List<ARTL_B2BFetchPartyAccount.clsB2BNonBillingAccount>();
for(Account ops :accList){
ARTL_B2BFetchPartyAccount.clsB2BNonBillingAccount newGST1 = new ARTL_B2BFetchPartyAccount.clsB2BNonBillingAccount();
newGST1.LSTDate = '';
newGST1.CoordinatorEmail = '';
newGST1.eCRMAccountNumber = '';
newGST1.CoordinatorContactNumber = '';
newGST1.CSTNumber = '';
newGST1.ShortCode = ops.Short_Code__c;
newGST1.CusTinNumber = '';
newGST1.CustomerSegment = ops.ARTL_Customer_Segment__c;
newGST1.Name = ops.Name;
newGST1.CSTDate = '';
newGST1.Status = ops.Parent.vlocity_cmt__Status__c;
newGST1.CusTinDate = '';
newGST1.LSTNumber = '';
newGST1.CollectionManager = '';
newGST1.State = '';
newGST1.AccountNumber = ops.AccountNumber;
newGST1.CoordinatorName = '';
wrapper.SFDCMessage.B2BParty.B2BNonBillingAccount.add(newGST1);
}
system.debug( ' wrapper : ' + wrapper);
string ttsst = JSON.serialize(wrapper);
return ttsst;
}
return null;
}

public String StatusMessage;   
public clsSFDCMessage SFDCMessage;

public class clsSFDCMessage {
public String IntObjectName;   
public String MessageType;   
public clsB2BParty B2BParty;
}

public class clsB2BParty {
public String KAMEmail;   
public String ZSMPhone;   
public String Category;   
public String ProjectManagerFirstName;   
public String KAMLastName;   
public String OwnedBy;   
public String PrimaryAddressPincode;   
public String ZSMFirstName;   
public String TSMLastName;   
public String ContactEmailAddress;   
public String CollectionManagerFirstName;
public String TLLastName;   
public String TSMPhone;   
public String GSTCount;   
public String SAMPhone;   
public String TSMFirstName;   
public String TLFirstName;   
public String ZSM;   
public String CustomerSegment;   
public String ContactPhoneNumber;   
public String ProjectManagerEmail;
public String PartyMigrationFlag;   
public String SAMLastName;
public String Status;   //
public String KAMFirstName;   
public String PANNumber;
public String TLPhone;
public String Channel;   
public String ContactLastName;
public String CollectionManagerLastName;   
public String SAMOLM;   
public String ZSMEmail;   
public String ProjectManager;   
public String CollectionManager;   
public String TSM;   
public String Description;   
public String GSTApplicable;   
public String PrimaryAddressCity;   
public String ORGTYPE;   
public String CollectionManagerPhone;   
public String Circle;   
public String GSTNonApplicableReason;   
public String SFDCAccountNumber;   
public String ZSMLastName;   
public String eCRMAccountNumber;   
public String KAMPhone;   
public String PrimaryAddressLine5;   
public String PrimaryAddressLine4;   
public String PrimaryAddressLine3;   
public String Id;   
public String PrimaryAddressLine2;   
public String PrimaryAddressLine1;   
public String TSMEmail;   
public String SAMEmail;   
public String KAM;   
public String AccountNumber;   
public String FXLeoAccountNumber;   
public String CustomerType;   
public String ServiceSegment;   
public String CustomerSegmentNew;   
public String Name;   
public String ContactFirstName;   
public String TLEmail;   
public String VerticalSegment;
public String ProjectManagerLastName;
public String CustomerOrigin;   
public String PrimaryAddressCountry;   
public String ProjectManagerPhone;   
public String ImplementationCircle;   
public String CollectionManagerEmail;   
public String SAMFirstName;   
public String TL;   
public String PrimaryAddressState;   
public clsB2BGST[] B2BGST;
public clsB2BNonBillingAccount[] B2BNonBillingAccount;
}

public class clsB2BGST {
public String StartDate;   
public String UINFlag;   
public String EndDate;
public String GSTNoUINFlag;   
public String CustomerName;   
public String GSTNumber;   
}

public class clsB2BNonBillingAccount {
public String LSTDate;   
public String CoordinatorEmail;   
public String eCRMAccountNumber;   
public String CoordinatorContactNumber;   
public String CSTNumber;   
public String ShortCode;   
public String CusTinNumber;   
public String Name;   
public String CSTDate;   
public String Status;   
public String CusTinDate;   
public String CustomerSegment;   
public String LSTNumber;   
public String CollectionManager;   
public String State;   
public String AccountNumber;   
public String CoordinatorName;   
}
}