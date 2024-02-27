/******************************************************************************************************
* @Author:      Saurav Madhusoodanan TV  <smadhusoodanantv@salesforce.com >
* @Company:     Salesforce
* @Date:        26/11/2023
* @Reviewer:
* @Review Date:
* @Description: Generic class to invoke DOA approval process
* ++++++++++++++++++++++ Changes Implemented / Modification Log ++++++++++++++++++++++++++++++++++++++
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 
*******************************************************************************************************/
/**
 * Batch class to process Quote Line Items for DOA (Delegated Authority) approval.
 * Implements Database.Batchable interface for batch processing, Database.Stateful for maintaining state,
 * Database.AllowsCallouts for allowing callouts.
 */
global with sharing class ARTL_InvokeDOAApprovalProcessBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    // Member variables to store quote information during batch processing
    public Id quoteId;
    public integer quoteLevel = 1;
    public string quoteApprover = 'none';
    public Map<String, Map<Double, String>> productCodeToApproverMap;
    
    /**
     * Constructor to initialize the quoteId.
     * @param quoteId - The Id of the Quote to process.
     */
    global ARTL_InvokeDOAApprovalProcessBatch(Id quoteId) {
        this.quoteId = quoteId;
    }

    /**
     * The start method returns a QueryLocator containing the records to be processed.
     * Retrieves the DOA (Delegated Authority) matrix and constructs the productCodeToApproverMap.
     * @param bc - The batchable context.
     * @return Database.QueryLocator - The locator for the records to be processed.
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String DOAMatrixName;
        
        // Determine the name of the DOA matrix based on whether it is a test run
        if (Test.isRunningTest()) {
            DOAMatrixName = 'DOA Matrix Test Version';
        } else {
            DOAMatrixName = 'DOA Matrix Updated V1';
        }
        
        system.debug('matrix version name invoked' + DOAMatrixName);
        String query;
        
        // Query the CalculationMatrixVersion records to get the DOA matrix version
        List<CalculationMatrixVersion> matrixVersionRec = [SELECT Id FROM CalculationMatrixVersion WHERE name = :DOAMatrixName LIMIT 1];
        
        List<CalculationMatrixRow> matrixRecords;
        
        // If a matrix version is found, query the CalculationMatrixRow records
        if (!matrixVersionRec.isEmpty() && matrixVersionRec != null) {
            matrixRecords = [SELECT Id, InputData, OutputData FROM CalculationMatrixRow WHERE calculationMatrixVersionId = :matrixVersionRec[0].Id];
            
            // If matrix records are found, construct the productCodeToApproverMap
            if (!matrixRecords.isEmpty() && matrixRecords != null) {
                // Constructing a map Map<String, Map<Double, String>> :: Map<ProductCode, Map<PriceRange, Level_Approver>>
                // Signature: constructProductCodeToApproverMap(List<CalculationMatrixRow> matrixRows)
                productCodeToApproverMap = ARTL_ApprovalProcessUtility.constructProductCodeToApproverMap(matrixRecords);
                
                // Construct the query for QuoteLineItems needing DOA approval
                query = 'SELECT Id, Product2.Name, Product2.ProductCode, ARTL_NeedDOAApproval__c, Annual_Recurring_Charge__c, ARTL_ARCFloorRate__c, vlocity_cmt__OneTimeCharge__c, ARTL_NRCFloorRate__c FROM QuoteLineItem WHERE QuoteId = :quoteId AND ARTL_NeedDOAApproval__c = true';
                
                // Return the QueryLocator
                return Database.getQueryLocator(query);
            } else {
                // If matrixRecords is empty, return null to indicate no records to process
                return null;
            }
        } else {
            // If matrixVersionRec is empty, return null to indicate no records to process
            return null;
        }
    }

    /**
     * The execute method processes each batch of records.
     * Determines the approver for each QuoteLineItem based on the DOA matrix.
     * @param bc - The batchable context.
     * @param qliList - List of QuoteLineItems to process.
     */
    global void execute(Database.BatchableContext bc, List<QuoteLineItem> qliList) {
        // Process each batch of records
        Double qliPriceRange;
        String qliProductCode;
        Integer qliLevel;
        String qliApprover;
        String levelNDApprover;
        List<String> splitlevelNDApproverList;
        
        Map<Double, String> priceRangeToLevelNdApproverMap;
        
        try {
            if (!qliList.isEmpty() && qliList != null) {
                for (QuoteLineItem qli : qliList) {
                    // Calculating the price range based on Annual_Recurring_Charge__c and vlocity_cmt__OneTimeCharge__c
                    qliPriceRange = qli.Annual_Recurring_Charge__c + qli.vlocity_cmt__OneTimeCharge__c;
                    qliProductCode = qli.product2.ProductCode;
                    
                    // Getting the map of price ranges to Level___ApproverName
                    priceRangeToLevelNdApproverMap = productCodeToApproverMap.get(qliProductCode);
                    
                    if (priceRangeToLevelNdApproverMap != null) {
                        for (Double priceRange : priceRangeToLevelNdApproverMap.keySet()) {
                            levelNDApprover = priceRangeToLevelNdApproverMap.get(priceRange);
                            splitlevelNDApproverList = levelNDApprover.split('___');
                            qliLevel = Integer.ValueOf(splitlevelNDApproverList[0]);
                            qliApprover = splitlevelNDApproverList[1];
                            
                            // Checking if the current QuoteLineItem meets the conditions
                            if (qliPriceRange <= priceRange && quoteLevel < qliLevel) {
                                // Updating the quoteLevel and approver
                                quoteLevel = qliLevel;
                                quoteApprover = qliApprover;
                            }
                        }
                    }
                }
                system.debug('Final Approver=>' + quoteApprover);
                system.debug('Final Approver=>' + quoteLevel);
            }
        } catch (Exception e) {
            // Handling exceptions and logging details
            System.debug('Exception in class::QuoteTriggerHelper and method::generateLSI @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
    }

    /**
     * The finish method is called after all batches are processed.
     * Updates the Quote record based on the determined approver and level.
     * If approver is 'none', sets ARTL_DOAApproved__c to True indicating no approval needed.
     * Otherwise, submits the request for DOA approval.
     * @param bc - The batchable context.
     */
    global void finish(Database.BatchableContext bc) {
        if (quoteApprover == 'none') {
            // If Approver is none, Quote does not need an approval.
            Quote quoteObj = new Quote(Id = quoteId, ARTL_DOAApproved__c = True);
            update quoteObj;
        } else {
            // Fetching submitter's Id
            Id submittingUser = UserInfo.getUserId();
            
            // Querying approver's Id
            List<User> ApproverList = [SELECT Id, Name FROM User WHERE Name = :quoteApprover LIMIT 1];
            
            // Invoking approval process
            // Signature: invokeApprovalProcess(Id quoteId, String comments, Id submittingUser, Id approver, String ApprovalProcessName, Boolean skipEntryCondition)
            ARTL_ApprovalProcessUtility.invokeApprovalProcess(quoteId, 'Submitting request for DOA approval.', submittingUser, ApproverList[0].Id, 'DOA_Quote_Approval', True);
        }
    }
}