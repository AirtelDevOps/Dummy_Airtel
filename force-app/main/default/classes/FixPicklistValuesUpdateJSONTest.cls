@isTest
public class FixPicklistValuesUpdateJSONTest {
    @testSetup
    static void dataCreation() {
        
        vlocity_cmt__Picklist__c pickListObj=new vlocity_cmt__Picklist__c();
        pickListObj.Name='Handset Model';
        pickListObj.vlocity_cmt__Code__c='VPL_PICKLIST_HANDSET_MODEL';
        pickListObj.vlocity_cmt__DataType__c='Text';
        pickListObj.vlocity_cmt__IsActive__c=true;
        insert pickListObj;
        
        vlocity_cmt__PicklistValue__c pickListValueRec1=new vlocity_cmt__PicklistValue__c(
        	Name='MX67C',
            vlocity_cmt__PicklistId__c=pickListObj.Id,
            vlocity_cmt__BooleanValue__c=false,
            vlocity_cmt__Code__c='VEPC_SDWAN_PICKLIST_VALUE_MX67C',
            vlocity_cmt__IsActive__c=true,
            vlocity_cmt__IsDefault__c=false,
            vlocity_cmt__Sequence__c=10,
            vlocity_cmt__TextValue__c='MX67C'
        );
        insert pickListValueRec1;
        
        vlocity_cmt__ObjectClass__c objecttyp=new vlocity_cmt__ObjectClass__c(
        	Name='Offer Migration Plan Object',
           vlocity_cmt__ObjectApiName__c='OfferMigrationPlan__c' 
        );
        insert objecttyp;
        
        Product2 prod = new Product2(
            Name = 'Test product1', 
            family = 'Internet',
            ProductCode='XYZ_1', 
            ARTL_LSIRequired__c=true,
            vlocity_cmt__ObjectTypeId__c=objecttyp.Id,
            vlocity_cmt__Status__c='Draft'
        );
        insert prod;
        system.debug('product=>'+prod);
        
        vlocity_cmt__AttributeCategory__c attcategory=new vlocity_cmt__AttributeCategory__c(
        Name='attt test',
          vlocity_cmt__Code__c='att test',
            vlocity_cmt__IsActive__c=true,
            vlocity_cmt__DisplaySequence__c=10
        );
        insert attcategory;
        
        vlocity_cmt__Attribute__c att=new vlocity_cmt__Attribute__c(
        Name='test att',
            vlocity_cmt__Code__c='VPL_PICKLIST_HANDSET_COLOR',
            vlocity_cmt__PicklistId__c=pickListObj.Id,
            vlocity_cmt__AttributeCategoryId__c=attcategory.Id
        );
        insert att;
        
        vlocity_cmt__AttributeAssignment__c attAssign=new vlocity_cmt__AttributeAssignment__c();
        attAssign.Name='NEW_OTC_CHANGE_ORDER_CFS';
        attAssign.vlocity_cmt__ValueDataType__c='Picklist';
        attAssign.vlocity_cmt__PicklistId__c=pickListObj.Id;
        attAssign.vlocity_cmt__ObjectId__c=prod.Id;
        attAssign.vlocity_cmt__AttributeId__c=att.Id;
        insert attAssign;
        
        
        
    }
    
    @isTest
    static void testBatchExecution() {
        // Create test data (you might need to modify this based on your object structure)
        
        List<Product2> prodList=[SELECT Id FROM Product2];
        // Start the batch job
        Test.startTest();
        FixPicklistValuesUpdateJSON batchJob = new FixPicklistValuesUpdateJSON(new List<Id>{prodList[0].Id});
        Database.executeBatch(batchJob);
        Test.stopTest();
        
        // Add assertions based on your specific logic
        // For example, check if the expected updates were made
        // Assert.assertEquals(expectedResult, actualResult);
    }
/*
	@isTest
    static void FixPicklistValuesUpdateJSONTest() {
		List<Product2> prodList=[SELECT Id FROM Product2];
        //List<vlocity_cmt__AttributeAssignment__c> attAssignmentList=[SELECT Id,vlocity_cmt__ObjectId__c FROM vlocity_cmt__AttributeAssignment__c];
        Test.startTest();
        FixPicklistValuesUpdateJSON.FixPicklistValuesUpdateJSON(new List<Id>{prodList[0].Id},true);
        Test.stopTest();
    }    
    */
    
    @isTest
    static void FixPicklistValuesUpdateJSONTest() {
		List<Product2> prodList=[SELECT Id FROM Product2];
        List<vlocity_cmt__AttributeAssignment__c> attAssignmentList=[SELECT Id,vlocity_cmt__ObjectId__c FROM vlocity_cmt__AttributeAssignment__c];
        Test.startTest();
        
        
        //FixPicklistValuesUpdateJSON.filterDraftAssignments(attAssignmentList);
        FixPicklistValuesUpdateJSON testm=new FixPicklistValuesUpdateJSON(new List<Id>{prodList[0].Id},true);
        testm.filterDraftAssignments(attAssignmentList);
        
        Test.stopTest();
    }    
}