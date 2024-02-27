/******************************************************************************************************
* @Author:      Saurav Madhusoodanan TV  <smadhusoodanantv@salesforce.com>
* @Company:     Salesforce
* @Date:        01/12/2023
* @Reviewer:
* @Review Date:
* @Description: Contract trigger helper class
* ++++++++++++++++++++++ Changes Implemented / Modification Log ++++++++++++++++++++++++++++++++++++++
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 1. 
*******************************************************************************************************/
public class ContractTriggerHelper {

	// To update quote contract lookup field based on contract record type    
    private static final String CONTRACT_RECORD_TYPE = 'Contract';
    private static final String FRAME_CONTRACT_RECORD_TYPE = 'Frame Contract';

    
    // Method to run before insert trigger events for Contract objects
    public static void runBeforeInsertTriggerEvents(List<Contract> contractList){
        
        // Declare variables to store QuoteId and AccountId
        Id quoteId;
        Id accountObjId;
        
        // Declare lists for QuoteLineItem, Custom Metadata, and a filtered list of QuoteLineItem
        List<QuoteLineItem> qliList;
        List<ARTL_CAF_Table__mdt> cafTable;
        List<QuoteLineItem> listContractRecords;
        
        // Declare a variable to store the product code
        String productCode;
        
        // Declare maps for product code to service type, quote Id to product codes, and account Id to Account
        Map<String,String> productCodeToServiceTypeMap = new Map<String,String>();
        Map<Id,List<String>> quoteIdToProductCode = new Map<Id,List<String>>();
        Map<Id, Account> accountMap;
            
        // Declare sets for storing unique Quote Ids and Account Ids
        Set<Id> contractQuoteIdSet = new Set<Id>();
        Set<Id> contractAccIdSet = new Set<Id>();
        
        try {
            // Query Custom Metadata for product code to service type mapping
            cafTable = [SELECT ID, DeveloperName, Product_Code__c, Service_Type__c FROM ARTL_CAF_Table__mdt];
            system.debug('cafTable===>'+JSON.SerializePretty(cafTable));
            for(ARTL_CAF_Table__mdt cafRows : cafTable){
                productCodeToServiceTypeMap.put(cafRows.Product_Code__c, cafRows.Service_Type__c);
            }
            
            // Extract unique Quote Ids and Account Ids from the provided Contract list
            system.debug('contractList===>'+JSON.SerializePretty(contractList));
            for(Contract contractObj : contractList){
                contractQuoteIdSet.add(contractObj.vlocity_cmt__QuoteId__c);
                contractAccIdSet.add(contractObj.AccountId);
            }
            system.debug('contractQuoteIdSet===>'+JSON.SerializePretty(contractQuoteIdSet));
            system.debug('contractAccIdSet===>'+JSON.SerializePretty(contractAccIdSet));
            
            // Query for Account information and create a map with Account Id as the key
            accountMap = new Map<Id, Account>([SELECT Id, OwnerId, Owner.Circle__c FROM Account WHERE Id IN :contractAccIdSet]);
            system.debug('accountMap===>'+JSON.SerializePretty(accountMap));
            
            // Query for Quote Line Items based on unique Quote Ids and filter by a condition
            listContractRecords = [SELECT Id, product2Id, Product2.ProductCode, QuoteId FROM QuoteLineItem WHERE quoteId IN :contractQuoteIdSet AND vlocity_cmt__ParentItemId__c = :null];
            system.debug('listContractRecords===>'+JSON.SerializePretty(listContractRecords));
            
            
            // Populate a map with Quote Ids as keys and lists of associated product codes
            for(QuoteLineItem qli : listContractRecords){
                if(!quoteIdToProductCode.containsKey(qli.QuoteId)){
                    quoteIdToProductCode.put(qli.QuoteId, new List<String>{qli.Product2.ProductCode});
                } else {
                    if(!(quoteIdToProductCode.get(qli.QuoteId)).contains(qli.Product2.ProductCode)){
                        (quoteIdToProductCode.get(qli.QuoteId)).add(qli.Product2.ProductCode);
                    }
                }
            }
            system.debug('quoteIdToProductCode===>'+JSON.SerializePretty(quoteIdToProductCode));
            
            // Update Contract objects with ARTL_CAFNumber__c based on business logic
            for(Contract contractObj : contractList){
                quoteId = contractObj.vlocity_cmt__QuoteId__c;
                accountObjId = contractObj.AccountId;
                
                // Extract Circle information from the associated Account
                String circleName = (accountMap.get(accountObjId)).Owner.Circle__c;
                String serviceType;
                system.debug('quoteIdToProductCode===>'+JSON.SerializePretty(quoteIdToProductCode));
                system.debug('productCodeToServiceTypeMap ===> '+productCodeToServiceTypeMap);
                
                // Check conditions and update ARTL_CAFNumber__c accordingly
                if((quoteIdToProductCode.get(quoteId)).size() == 1){
                    system.debug('line 95');
                    productCode = (String)(quoteIdToProductCode.get(quoteId))[0];
                    system.debug('line 97'+productCodeToServiceTypeMap.get(productCode));
                    serviceType=productCodeToServiceTypeMap.get(productCode);
                    if(!String.isBlank(serviceType)){
                        system.debug('line 99');
                        contractObj.ARTL_CAFNumber__c = constructCAF(serviceType,circleName);
                    }
                }else if((quoteIdToProductCode.get(quoteId)).size() > 1){
                    contractObj.ARTL_CAFNumber__c = constructCAF('BUN',circleName);
                }
            }
            system.debug('final contractList => '+JSON.serializePretty(contractList));
        } catch(Exception e){
            // Handle exceptions and log debug information
            System.debug('Exception in class::ContractTriggerHelper and method::runBeforeTriggerEvents @line number '+e.getLineNumber()+' ['+e.getMessage()+']');
        }
    }

    // Method to construct the CAF Number based on service type and circle name
    public static String constructCAF(String serviceType, String circleName){
        String cafNumber;
        try{
            DateTime myDateTime = DateTime.now();
            String formattedDateTime = myDateTime.format('yyyyMMddHHmm');
            cafNumber = 'OE' + serviceType + circleName + formattedDateTime;
        }catch(Exception e){
            // Handle exceptions and log debug information
            System.debug('Exception in class::ContractTriggerHelper and method::runBeforeTriggerEvents @line number '+e.getLineNumber()+' ['+e.getMessage()+']');
        }
        return cafNumber;
    }
    
    public static void populateContractLookupOnQuote(List<Contract> contractList){
        List<Quote> quotelist=new List<Quote>();
        Id contractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get(CONTRACT_RECORD_TYPE).getRecordTypeId();
        for(Contract con:contractList){
            if(con.vlocity_cmt__QuoteId__c!=null &&  con.RecordTypeId ==  contractRecordTypeId ){
                quotelist.add(new Quote(id=con.vlocity_cmt__QuoteId__c,status=System.Label.ARTL_Quote_Status_Contract_Generated,ContractId =con.id));
            }
        }
        if(quotelist.size()>0){
            update quotelist;
        }
    }
    
    public static void updateQuoteStatusOnContractSigned(List<Contract> contractList,  Map<id,contract> contractOldValList ){
        set<id> quoteIds = new Set<id>();
        List<quote> quoteToUpdate = new List<quote>();
        Id contractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get(CONTRACT_RECORD_TYPE).getRecordTypeId();
        if(!contractList.isEmpty()){

            for(contract c : contractList){
                if(c.Status == System.label.ARTL_Contract_Status_Signed && c.RecordTypeId ==  contractRecordTypeId && contractOldValList.get(c.id).status != c.Status){
                    quoteIds.add(c.vlocity_cmt__QuoteId__c);
                }
            }
        }
        if(!quoteIds.isEmpty()){
            for(quote q : [SELECT id , status from quote WHERE id IN: quoteIds]){
                q.Status = System.label.ARTL_Quote_Status_Customer_Signed;
                quoteToUpdate.add(q);
            }
        }
        if(!quoteToUpdate.isEMpty()){
            update quoteToUpdate;
        }
    }
    
}