@isTest
public class ARTL_GenerateLSIForNIPSHardwareTest {
    @testSetup 
    static void setup() {
        Id pbId = Test.getStandardPricebookId();
        Id recTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();    
        
        Account acc = new Account();
        acc.Name='TestAccount';
        acc.AccountNumber = 'A10189908';
        acc.RecordTypeId = recTypeId1; 
        
        insert acc;
        
        Product2 testCommProd2 = new Product2();
                testCommProd2.name = 'Test Commercial Product2';
                testCommProd2.vlocity_cmt__SpecificationType__c = 'Product';
                testCommProd2.productcode = 'V0000002';
                //testCommProd2.vlocity_cmt__JSONAttribute__c = '{"TEST_ATTRIB_CATEG":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHgUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Model","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Model","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqyUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t3H000003Ix8CQAS","attributeid__c":"a0X3H000000sdHbUAI","attributecategoryid__c":"a0W3H000000AjiXUAS","categorycode__c":"TEST_ATTRIB_CATEG","categoryname__c":"Test Attrib Categ","attributeuniquecode__c":"Colour","attributeconfigurable__c":true,"attributedisplaysequence__c":"1","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Colour","displaysequence__c":"null","categorydisplaysequence__c":1,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0U3H000001gWqzUAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"isnotassetizable__c":false,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text"},"$$AttributeDefinitionEnd$$":null}]}';
                testCommProd2.vlocity_cmt__IsOrderable__c = true;
        		insert testCommProd2;
        
        PricebookEntry pe = new PricebookEntry();
        pe.Pricebook2Id = pbId;
        pe.Product2Id = testCommProd2.Id;
        pe.UnitPrice = 100;
        pe.IsActive = true;
        insert pe;
        
        Opportunity opp = new Opportunity();
        opp.name = 'TestOpp';
        opp.AccountId = acc.Id;
        opp.CloseDate = System.today()+1;
        opp.StageName = 'Qualification';
        opp.currencyIsoCode = 'INR';
        opp.Pricebook2Id = pbId; 
        insert opp;
        
        List<Order> orderList = new List<Order>();
        Order targetOrder = new Order();
        targetOrder.name = 'Target Order';
        targetOrder.AccountId = acc.Id;
        targetOrder.Pricebook2Id = pbId;
        targetOrder.status = 'Draft';
        targetOrder.EffectiveDate=System.today();                
        orderList.add(targetOrder);
        insert orderList;
        
        List<OrderItem> olList = new List<OrderItem>();
        
        OrderItem targetOrderItem = new OrderItem();
        targetOrderItem.OrderId = targetOrder.Id;
        targetOrderItem.PricebookEntryId = pe.Id;
        targetOrderItem.Quantity = 1;
        targetOrderItem.vlocity_cmt__LineNumber__c = '0001';
        targetOrderItem.UnitPrice = 100;
        targetOrderItem.Product2Id = testCommProd2.Id;
        targetOrderItem.vlocity_cmt__ProvisioningStatus__c = 'New';   
        targetOrderItem.vlocity_cmt__AttributeSelectedValues__c = '{"Colour":"Target Comm2 Colour","Model":"Target Comm2 Model"}';
        olList.add(targetOrderItem);
        insert olList;
    }
    @isTest 
    static void callGenerateLSINIPS(){
        
        Test.startTest();
        List<Orderitem> orderitem = [SELECT Id FROM orderitem WHERE Order.name = 'Target Order'];
        
        List<ARTL_GenerateLSIForNIPSHardware.FlowInput> testclassforNIPSlist = new List<ARTL_GenerateLSIForNIPSHardware.FlowInput>();
        ARTL_GenerateLSIForNIPSHardware.FlowInput testclassforNIPS = new ARTL_GenerateLSIForNIPSHardware.FlowInput();
        
        testclassforNIPS.recordId = orderitem[0].id;
        testclassforNIPSlist.add(testclassforNIPS);
        ARTL_GenerateLSIForNIPSHardware.GenerateLSI(testclassforNIPSlist); 
        Test.stopTest();
        
    }
}