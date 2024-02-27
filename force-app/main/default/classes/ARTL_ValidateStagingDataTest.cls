@isTest

public class ARTL_ValidateStagingDataTest {
    @isTest
    static void validateStagingDataPositiveTest(){
        User usr = ARTL_ValidateStagingDataHelper.getUser();
        String quoteId = ARTL_ValidateStagingDataHelper.getQuoteIdPos();
        String validationStatus ='Success';
        System.runAs(usr){
            Test.startTest();
            /*ARTL_ValidateStagingData obj = new ARTL_ValidateStagingData();
            DataBase.executeBatch(obj); */
            //Database.executeBatch(new ARTL_ValidateStagingData(quoteId)); 
            ARTL_ValidateStagingDataHelper.invokeARTL_ValidateStagingData(quoteId, true);
            Test.stopTest();
            List<ARTL_Billing_Staging__c> stagingRec = [select id, Status__c from ARTL_Billing_Staging__c  where Quote__c =:quoteId];
            for(ARTL_Billing_Staging__c stage : stagingRec){
                if(stage.get('Status__c')=='Failed'){
                    validationStatus = 'Failed';
                    break;
                }
            }
        }
        
    }
    
    @isTest
    static void validateStagingDataNegativeTest(){
        User usr = ARTL_ValidateStagingDataHelper.getUser();
        String quoteId = ARTL_ValidateStagingDataHelper.getQuoteIdNeg();
        String validationStatus ='Success';
        System.runAs(usr){
            Test.startTest();
            /*ARTL_ValidateStagingData obj = new ARTL_ValidateStagingData();
            DataBase.executeBatch(obj); */
            //Database.executeBatch(new ARTL_ValidateStagingData(quoteId)); 
            ARTL_ValidateStagingDataHelper.invokeARTL_ValidateStagingData(quoteId, true);
            Test.stopTest();
            List<ARTL_Billing_Staging__c> stagingRec = [select id, Status__c from ARTL_Billing_Staging__c  where Quote__c =:quoteId];
            for(ARTL_Billing_Staging__c stage : stagingRec){
                if(stage.get('Status__c')=='Failed'){
                    validationStatus = 'Failed';
                    break;
                }
            }
        }
        
    }
}