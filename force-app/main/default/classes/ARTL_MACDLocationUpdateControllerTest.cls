/******************************************************************************************************
* @Author       : arka.bhattacharjee@salesforce.com
* @Company      : Salesforce
* @Date         : 26-Feb-2024
* @Test Class   : 
* @Description  : Test Class for ARTL_MACDLocationUpdateController
* ----------------------- Changes Implemented / Modification Log --------------------------------------
* UserStory / Defect      Developer             Date             Comment
*                         Arka Bhattacharjee    26-Feb-2024      Initial Dev
*******************************************************************************************************/
@isTest
public class ARTL_MACDLocationUpdateControllerTest {
	/******************************************************************************************************
 * Method Name        : setup
 * Method Description : Test Data 
*******************************************************************************************************/
    @testSetup 
    static void setup() {
        ARTL_Pincode__c pin = new ARTL_Pincode__c();
        pin.Name = '700090';
        pin.ARTL_City__c = 'Test';
        pin.ARTL_Country__c = 'India';
        insert pin;
        
        Account acc = new Account(Name = 'Test Account',billingCity='pune',billingState = 'Maharastra', ARTL_Legal_Entity__c = 'NXTRA DATA LIMITED',artl_customer_segment__c = 'AB',
                                  artl_business_circle_region__c = 'NCR' , artl_vertical_segment__c= 'BFI', vlocity_cmt__Status__c = 'Active' );
        insert acc;
        
        vlocity_cmt__PriceList__c priceList = new 	vlocity_cmt__PriceList__c();
        priceList.Name ='Pricelist For Test class';
        priceList.vlocity_cmt__Code__c='PricelistForTestclass';
        priceList.vlocity_cmt__Pricebook2Id__c =Test.getStandardPricebookId();
        insert priceList;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opportunity';
        opp.CloseDate= System.Today();
        opp.StageName='Prospecting';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.Opportunity_Type__c = 'Rate Revision';
        insert opp;
        
        Quote q = new Quote();
        q.OpportunityId = opp.Id;
        q.Name = 'Quote Test';
        //q.AccountId = acc.id;
        q.vlocity_cmt__PriceListId__c=priceList.Id;
        q.Pricebook2Id = Test.getStandardPricebookId();
        q.Status ='Draft';
        q.artl_demo_duration__c = '15';
        insert q;
        
        vlocity_cmt__Premises__c p = new vlocity_cmt__Premises__c();
        p.Business_Account__c = acc.Id;
        p.External_Id__c = 'Test';
        p.Name = 'Test';
        p.vlocity_cmt__StreetAddress__c = 'Test';
        p.vlocity_cmt__PostalCode__c = '700090';
        insert p;
        
        vlocity_cmt__QuoteMember__c qm = new vlocity_cmt__QuoteMember__c();
        qm.vlocity_cmt__QuoteId__c = q.Id;
        insert qm;
    }
/******************************************************************************************************
 * Method Name        : testMultipleMethods
 * Method Description :  
*******************************************************************************************************/
    @isTest
    public static void testMultipleMethods(){
        Quote qt = [Select Id From Quote Limit 1];
        String jsonStr = '[{"AddressId":"ADDR 2","Street":"21abc Rajani Sen Road Ballygunge","City":"Kolkata","State":"West Bengal","Country":"India","Pincode":"700026","Latitude":"1.2","Longitude":"2.2","Validation":true,"ValidationMessage":"Validated"}]';
        List<Object> objList = (List<Object>)JSON.deserializeUntyped(jsonStr);
        ARTL_MACDLocationUpdateController.savePremiseRecs(objList, qt.Id);
    }
}