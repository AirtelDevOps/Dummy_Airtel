@isTest
public class OtterEPCUtilsServiceTest {

    @testSetup
    static void dataCreation() {
        
        Product2 prod1 = new Product2 (Name='Triple Play Bundle Small', ProductCode = 'VLO-BUN-0001');
        Insert prod1;
        Product2 prod2 = new Product2 (Name='Consumer Landline', ProductCode = 'VLO-BUN-0002');
        Insert prod2;
        
        vlocity_cmt__ProductChildItem__c pci1 = new vlocity_cmt__ProductChildItem__c();
        pci1.vlocity_cmt__ParentProductId__c = prod1.Id;
        pci1.vlocity_cmt__ChildProductId__c = prod2.Id;
        pci1.Name = 'Test PCI1';
        pci1.vlocity_cmt__Quantity__c = 1.0;
        pci1.vlocity_cmt__MinQuantity__c = 1.0;
        pci1.vlocity_cmt__MaxQuantity__c = 25.0;
        pci1.vlocity_cmt__IsRootProductChildItem__c = false;
        pci1.vlocity_cmt__IsOverride__c = false;
        pci1.vlocity_cmt__ChildLineNumber__c = '0001';
        pci1.vlocity_cmt__IsVirtualItem__c = false;
        Insert pci1;
        system.debug('pci1 ::' + pci1);
        
        vlocity_cmt__ObjectClass__c sourceObjType = new vlocity_cmt__ObjectClass__c(Name = 'Product2 Object', vlocity_cmt__ObjectApiName__c = 'PricingElement__c' ,CurrencyIsoCode = 'INR');
        Insert sourceObjType;
        vlocity_cmt__ObjectClass__c targetObjType = new vlocity_cmt__ObjectClass__c(Name = 'Product3 Object', vlocity_cmt__ObjectApiName__c = 'PricingElement__c' , CurrencyIsoCode = 'INR');
        Insert targetObjType;
        
         vlocity_cmt__ObjectClass__c ObjTypeEnrishAttrbtSec = new vlocity_cmt__ObjectClass__c(Name = 'Product Object', vlocity_cmt__ObjectApiName__c = 'PricingElement__c' , CurrencyIsoCode = 'INR');
        Insert ObjTypeEnrishAttrbtSec;
       
        List<vlocity_cmt__ObjectLayout__c> objectLayoutList = new  List<vlocity_cmt__ObjectLayout__c>();
        vlocity_cmt__ObjectLayout__c   objectLayout = new vlocity_cmt__ObjectLayout__c(); //vlocity_cmt__SubclassId__c = sourceObjType.Id
        objectLayout.Name = 'Product4 Object'; 
        objectLayout.vlocity_cmt__IsActive__c = true;
        objectLayout.vlocity_cmt__IsDefault__c = false;
        objectLayout.vlocity_cmt__ObjectClassId__c = sourceObjType.Id; 
        objectLayout.vlocity_cmt__SubclassId__c= sourceObjType.Id;
        objectLayoutList.add(objectLayout);
        
        vlocity_cmt__ObjectLayout__c   objectLayout2 = new vlocity_cmt__ObjectLayout__c(); //vlocity_cmt__SubclassId__c = sourceObjType.Id
        objectLayout.Name = 'Product5 Object'; 
        objectLayout2.vlocity_cmt__IsActive__c = true;
        objectLayout2.vlocity_cmt__IsDefault__c = false;
        objectLayout2.vlocity_cmt__ObjectClassId__c = ObjTypeEnrishAttrbtSec.Id; 
        objectLayout2.vlocity_cmt__SubclassId__c= ObjTypeEnrishAttrbtSec.Id; 
        objectLayoutList.add(objectLayout2);
        
        Insert objectLayoutList;
        system.debug('objectLayoutList ::' + objectLayoutList);
        
        vlocity_cmt__UIFacet__c FacedObj = new vlocity_cmt__UIFacet__c();
        FacedObj.Name = 'General Properties';
        FacedObj.CurrencyIsoCode = 'INR';
        Insert FacedObj;
        system.debug('FacedObj ::' + FacedObj);
        
        vlocity_cmt__ObjectFacet__c objectFacet = new vlocity_cmt__ObjectFacet__c();
        objectFacet.Name = 'fde8c542-2fc4-8b64-f30e-dc41ae70b161';
        objectFacet.vlocity_cmt__Sequence__c = 10;
        objectFacet.vlocity_cmt__FacetId__c = FacedObj.Id;
        objectFacet.vlocity_cmt__ObjectLayoutId__c = objectLayoutList[0].Id;
		Insert objectFacet;
        
        vlocity_cmt__ObjectFacet__c objectFacet2 = new vlocity_cmt__ObjectFacet__c();
        objectFacet2.Name = 'fde8c542-2fc4-8b64-f30e-dc41ae70b161';
        objectFacet2.vlocity_cmt__Sequence__c = 10;
        objectFacet2.vlocity_cmt__FacetId__c = FacedObj.Id;
        objectFacet2.vlocity_cmt__ObjectLayoutId__c = objectLayoutList[1].Id;
		Insert objectFacet2; 
        
        system.debug('objectFacet ::' + objectFacet);
        
        vlocity_cmt__UISection__c uiSecn = new vlocity_cmt__UISection__c();
        uiSecn.Name = 'Additional Properties';
        uiSecn.CurrencyIsoCode = 'INR';
        Insert uiSecn;
        system.debug('uiSecn ::' + uiSecn);
        
        vlocity_cmt__ObjectSection__c additionalPropertiesObjectSection = new vlocity_cmt__ObjectSection__c();
        additionalPropertiesObjectSection.Name = '(Enriched) Additional Properties Section';
        additionalPropertiesObjectSection.vlocity_cmt__Sequence__c = 1000;
        additionalPropertiesObjectSection.vlocity_cmt__SectionId__c = uiSecn.id ;
        	//[select Id from vlocity_cmt__UISection__c where Name = 'Additional Properties' limit 1].Id;
        additionalPropertiesObjectSection.vlocity_cmt__ObjectFacetId__c = objectFacet.Id;
        additionalPropertiesObjectSection.vlocity_cmt__ViewType__c = 'Field Layout';
        additionalPropertiesObjectSection.vlocity_cmt__ViewUri__c = '';
        Insert additionalPropertiesObjectSection;
        system.debug('additionalPropertiesObjectSection ::' + additionalPropertiesObjectSection);
        
        vlocity_cmt__ObjectFieldAttribute__c objFieldAttrbt = new vlocity_cmt__ObjectFieldAttribute__c();
        objFieldAttrbt.CurrencyIsoCode = 'INR';
        objFieldAttrbt.Name = 'a2z0T000000B4kT';
        objFieldAttrbt.vlocity_cmt__ObjectClassId__c = sourceObjType.Id;
        objFieldAttrbt.vlocity_cmt__ObjectType__c = 'vlocity_cmt__ObjectClass__c';
        Insert objFieldAttrbt;
        system.debug('objFieldAttrbt ::' + objFieldAttrbt);
        
        vlocity_cmt__ObjectElement__c objElement = new vlocity_cmt__ObjectElement__c();
        objElement.Name = 'Producct Name';
        objElement.vlocity_cmt__ObjectSectionId__c = additionalPropertiesObjectSection.Id;
        objElement.CurrencyIsoCode = 'INR';
        Insert objElement;
        system.debug('objElement ::' + objElement);
    }
    
    @isTest
    static void getProductHierarchyPathTest(){
       	Test.StartTest();       
        
        List<vlocity_cmt__ProductChildItem__c> prodList = [SELECT   vlocity_cmt__ChildProductId__c , vlocity_cmt__ParentProductId__c FROM vlocity_cmt__ProductChildItem__c  ];
        //List<String> prodString = new List<String>{prodList[0].ProductCode};
        System.debug('prodList ::' + prodList);
        
        List<Product2> productList = [SELECT ProductCode FROM Product2 limit 1 ];
        system.debug('product code list :::' + productList);
        List<String> productCodes = new List<String>();
        
        for (Product2 product : productList) {
            productCodes.add(product.ProductCode);
        }
        List<Product2> productList2 = [SELECT ProductCode FROM Product2  ];
        system.debug('productCodes for regenerateJsonAttributes :::' + productCodes );
        List<vlocity_cmt__ProductChildItem__c> productChildItemsList = OtterEPCUtils.getProductChildItems(productCodes);
        system.debug('productChildItemsList ::' + productChildItemsList);
        String gphpRes = OtterEPCUtils.getProductHierarchyPath(String.valueof(productList[0].ProductCode) , String.valueof(productList[0].ProductCode));
        String gphpRes2 = OtterEPCUtils.getProductHierarchyPath(String.valueof(productList2[0].ProductCode) , String.valueof(productList2[1].ProductCode));
        system.debug('gphpRes :: ' + gphpRes);
        
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        Map<string,object> emptyInput = new map<string,Object>();
        
         // for getProductHierarchyPath
        input.put('childProductCode' , String.valueof(productList[0].ProductCode));
        input.put('parentProductCode' ,String.valueof(productList[0].ProductCode));
        input.put('childProductCode' , String.valueof(productList[0].ProductCode));
        input.put('parentProductCode' ,String.valueof(productList2[1].ProductCode));
        
        
        OtterEPCUtilsService otterEPC = new OtterEPCUtilsService();
        otterEPC.invokeMethod('getProductHierarchyPath',input ,output ,  options);
       
        // for getParentProductHierarchyPath
        
        otterEPC.invokeMethod('getParentProductHierarchyPath',input ,output ,  options);
        
        //Test.StartTest();
        // for regenerateJsonAttributes
        Map<String, Object> inputWithCode = new Map<String, Object>();
        inputWithCode.put('productCodes' , productCodes);
        otterEPC.invokeMethod('regenerateJsonAttributes',inputWithCode ,output ,  options);
        //Test.Stoptest();
        
        // for clearPlatformCache
        otterEPC.invokeMethod('clearPlatformCache',input ,output ,  options);
        List<vlocity_cmt__ObjectClass__c> objClssList = [SELECT id ,Name FROM vlocity_cmt__ObjectClass__c ];
        system.debug('objClssList >>>' + objClssList);
        // for RegenerateLayoutsForObjectType
        Map<String, Object> inputReg = new Map<String, Object>();
        string source = 'sourceObjectTypeName';
        string target = 'targetObjectTypeName';
        input.put( source, objClssList[0].Name);
        input.put(target , objClssList[0].Name);
        
        
        otterEPC.invokeMethod('RegenerateLayoutsForObjectType',inputReg ,output ,  options);
        
        
        otterEPC.invokeMethod('fixPicklistValues',inputWithCode ,output ,  options);
        vlocity_cmt__ObjectClass__c objClsss = [SELECT id , Name FROM vlocity_cmt__ObjectClass__c WHERE Name = 'Product2 Object' LIMIT 1];
        system.debug('objClsss :::' + objClsss);
        
        List<vlocity_cmt__ObjectFacet__c> ObjFacetList = [select Id, Name  from vlocity_cmt__ObjectFacet__c];
        system.debug('ObjFacetList :::' + ObjFacetList);
        
        OtterEPCUtils.enrichAttributesSection('Product2 Object');
        
        
        OtterEPCUtilsService otterEPCFailedCover = new OtterEPCUtilsService();
        Map<String, Object> outputFailed = new Map<String, Object>();
        Map<String, Object> optionsFailed = new Map<String,Object>();
        Map<String, Object> inputFailed = new Map<String, Object>();
 		
        input.put('childProductCode','' );
        input.put('parentProductCode','' );
        otterEPCFailedCover.invokeMethod('getProductHierarchyPath',inputFailed ,outputFailed ,  optionsFailed);
        otterEPCFailedCover.invokeMethod('getParentProductHierarchyPath',inputFailed ,outputFailed ,  optionsFailed);
        
        Map<String, Object> inputWithCodeFailed = new Map<String, Object>();
        inputWithCodeFailed.put('sourceObjectTypeName' , '');
        inputWithCodeFailed.put('targetObjectTypeName' , '');
        otterEPCFailedCover.invokeMethod('RegenerateLayoutsForObjectType',inputWithCodeFailed ,optionsFailed ,  inputFailed);
        
         Map<String, Object> inputFailedPickVal = new Map<String, Object>();
        inputFailedPickVal.put('productCodes' , new List<string>{''});
        otterEPCFailedCover.invokeMethod('fixPicklistValues',inputFailedPickVal ,optionsFailed ,  inputFailed);
        
       OtterEPCUtils.replicateLayout(String.valueOf(objClssList[0].Name) , String.valueOf(objClssList[1].Name) );
        
        List<vlocity_cmt__ObjectClass__c> sourceObjectType = [ select  Id, Name from vlocity_cmt__ObjectClass__c ];
        system.debug('sourceObjectType :::' + sourceObjectType  + 'objClssList ID ::' +  objClssList[0].Id);
        
        List<vlocity_cmt__ProductChildItem__c > pciList = [SELECT id , vlocity_cmt__ParentProductId__c , vlocity_cmt__ChildProductId__c , Name FROM vlocity_cmt__ProductChildItem__c];
        system.debug('pciList' + pciList);
        
        List<vlocity_cmt__ObjectLayout__c> ObjectLayoutList = [ select Id,Name,vlocity_cmt__IsActive__c,vlocity_cmt__ObjectClassId__c ,vlocity_cmt__SubclassId__c from vlocity_cmt__ObjectLayout__c];
        system.debug('ObjectLayoutList :::>>' + ObjectLayoutList); // not coming
        
        List<vlocity_cmt__UIFacet__c> uiFacet = [SELECT id , Name FROM vlocity_cmt__UIFacet__c];
        system.debug('uiFacet' + uiFacet);
        
        List<vlocity_cmt__ObjectFacet__c> objFacet = [SELECT id ,Name , vlocity_cmt__Sequence__c,vlocity_cmt__FacetId__c,vlocity_cmt__ObjectLayoutId__c FROM vlocity_cmt__ObjectFacet__c ];
        system.debug('objFacet ::' + objFacet); // not coming
        
        List<vlocity_cmt__ObjectFacet__c> generalPropertiesFacet = [ select Id, Name, vlocity_cmt__Sequence__c,vlocity_cmt__ObjectLayoutId__c,vlocity_cmt__FacetId__c, vlocity_cmt__FacetId__r.Name,
                    vlocity_cmt__ObjectLayoutId__r.vlocity_cmt__ObjectClassId__r.Name,vlocity_cmt__ObjectLayoutId__r.vlocity_cmt__SubclassId__c from vlocity_cmt__ObjectFacet__c ];        
        system.debug('generalPropertiesFacet ::' + generalPropertiesFacet);
        
        List<vlocity_cmt__UISection__c> uiSection = [SELECT id , Name FROM vlocity_cmt__UISection__c];
        system.debug('uiSection' + uiSection);
        
        List<vlocity_cmt__ObjectSection__c> objSec = [SELECT id ,Name, vlocity_cmt__SectionId__c,vlocity_cmt__ObjectFacetId__c FROM vlocity_cmt__ObjectSection__c  ];
        system.debug('objSec' + objSec); // not coming
        
        List<vlocity_cmt__ObjectFieldAttribute__c> objFieldAttr = [SELECT id , vlocity_cmt__ObjectType__c , Name , vlocity_cmt__ObjectClassId__c FROM vlocity_cmt__ObjectFieldAttribute__c];
        system.debug('objFieldAttr' + objFieldAttr);
        
        List<vlocity_cmt__ObjectElement__c> ObjElmnt = [SELECT id , Name , vlocity_cmt__ObjectSectionId__c FROM vlocity_cmt__ObjectElement__c];
        system.debug('ObjElmnt' + ObjElmnt);  // not coming
        
        
        
		Test.StopTest();        
    }
    
     
   
    
  
}