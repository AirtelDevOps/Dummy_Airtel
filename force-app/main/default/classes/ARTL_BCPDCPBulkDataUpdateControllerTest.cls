/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-08-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public without sharing class ARTL_BCPDCPBulkDataUpdateControllerTest {
    public ARTL_BCPDCPBulkDataUpdateControllerTest() {

    }
    
    public class objWrapper {
        public String ID = '';
        public String NewFirstName = '';
        public String NewLastName = '';
        public String NewEmail = '';
        public String NewMobilePhone = '';
        public String NewRole = '';
        public String NewDesignation = '';
        public String NewStreet = '';
        public String NewCity = '';
        public String NewState = '';
        public String NewCountry = '';
        public String NewPostalCode = '';
    }
    @isTest
    public static void saveStageRecsTest () {
        objWrapper objrec = new objWrapper();
        List<objWrapper> objList = new List<objWrapper>{objrec};
        Test.startTest();
        Integer output = ARTL_BCPDCPBulkDataUpdateController.saveStageRecs(new List<objWrapper>{objrec});
        Test.stopTest();
    }

}