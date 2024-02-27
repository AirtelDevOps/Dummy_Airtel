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
public  class ARTL_InvokeDOAApprovalProcessHelper {
    public static integer quoteLevel=1;
    public static string quoteApprover='none';
    private static final String DOA_EMAIL_SUBJECT = 'Pricing Exception Approval';
    public static Map<String,Map<Double,String>> productCodeToApproverMap;
    
    /**
    * This method is responsible for initiating the DOA Approval process for a given Quote.
    * It checks if the Quote is already in a pending approval process, fetches the Quote Line Items,
    * and determines the appropriate approver based on configured rules.
    * @param quoteId The Id of the Quote for which DOA Approval needs to be initiated.
    * @return A message indicating the result of the DOA Approval process.
    */
    @AuraEnabled
    public static string invokeDOAApproval(Id quoteId) {
        List<QuoteLineItem> qliList;
        String approvalMessage;
        Boolean quoteHavePendingApproval;
        
        try {
            System.debug('quoteid from quick action => ' + quoteId);
            qliList = fetchQuoteLineItems(quoteId);
            
            if (qliList.size() > 1000 && !qliList.isEmpty()) {
                // Invoke batch process for large data sets
                string batchprocessId = Database.executeBatch(new ARTL_InvokeDOAApprovalProcessBatch(quoteId), 200);
                approvalMessage = 'Submitted for DOA Approval';
            } else if (!qliList.isEmpty()) {
                // Construct ProductCodeToApproverMap: where key is product code and value is approver name
                constructProductCodeToApproverMap();
                System.debug('sync productCodeToApproverMap => ' + JSON.serializePretty(productCodeToApproverMap));
                
                System.debug('sync qliList => ' + JSON.serializePretty(qliList));
                if (!qliList.isEmpty() && qliList != null && productCodeToApproverMap != null) {
                    // Find the appropriate approver for the Quote
                    findApprover(qliList);
                }
                System.debug('quoteApprover => ' + quoteApprover);
                if (!String.isBlank(quoteApprover)) {
                    if (quoteApprover == 'none') {
                        System.debug('approver is none');
                        
                        // Update Quote status for 'none' approver
                        Quote quoteObj = new Quote(Id = quoteId, ARTL_DOAApproved__c = True);
                        update quoteObj;
                        
                        //quote updatedQuote=[select id,ARTL_DOAApproved__c,status from quote where id=:quoteId];
                        system.debug('after trigger final status=>'+quoteObj.Status);
                        system.debug('after trigger final DOAApproved value=>'+quoteObj.ARTL_DOAApproved__c);
                        approvalMessage = 'Submitted for DOA Approval';
                        
                    } else {
                        System.debug('approver is ' + quoteApprover);
                        Id submittingUser = UserInfo.getUserId();
                        List<User> ApproverList = [SELECT Id, Name, email FROM User WHERE Name = :quoteApprover LIMIT 1];
                        
                        // Invoke custom Approval Process utility
                        Boolean isSubmissionSuccess = ARTL_ApprovalProcessUtility.invokeApprovalProcess(quoteId, 'Submitting request for DOA approval.', submittingUser, ApproverList[0].Id, 'DOA_Quote_Approval', True);
                        
                        if(isSubmissionSuccess && !ApproverList.isEmpty() ){

                            Quote quoteObj = [SELECT QuoteNumber, Opportunity.name, Account.name , 	OpportunityId FROM Quote WHERE id = :quoteId ];
                            OpportunityShare oppShr  = new OpportunityShare();
                            oppShr.OpportunityId = quoteObj.OpportunityId;
                            oppShr.UserOrGroupId = ApproverList[0].Id;
                            oppShr.OpportunityAccessLevel = 'Edit';
                            oppShr.RowCause = Schema.OpportunityShare.RowCause.Manual;                    
                            Database.SaveResult sr = Database.insert(oppShr,false); 

                            if(ApproverList[0].email != null){                             
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                mail.setToAddresses(new String[] {ApproverList[0].email});
                                mail.setSubject(DOA_EMAIL_SUBJECT);
                                mail.setHtmlBody('Dear '+ ApproverList[0].name+ ', <br/>' +
                                                'Quotation <a href="' + URL.getOrgDomainURL().toExternalForm() + '/' + quoteId + '">' + quoteObj.QuoteNumber + '</a>'+
                                                ' against ' + quoteObj.Opportunity.name + ' for ' + quoteObj.account.name + 
                                                ' has been assigned to you for Pricing Exception Approval.');
                                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                            }
                        }
                        approvalMessage = 'Submitted for DOA Approval';

                    }
                }
            }
            
        }
        catch (Exception e) {
            System.debug('Exception in class::ARTL_InvokeDOAApprovalProcessHelper and method::invokeDOAApproval @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
        System.debug('final approvalMessage => ' + approvalMessage);
        return approvalMessage;
    }
    
    
    /**
    * This method constructs a mapping of Product Code to Approver based on the configured DOA Matrix.
    * It retrieves the matrix version name, queries for matrix records, and constructs the map.
    * @remarks The constructed map is stored in the global variable 'productCodeToApproverMap'.
    */
    public static void constructProductCodeToApproverMap() {
        String DOAMatrixName;
        String query;
        final String developerName = 'DOA_Matrix';
        List<CalculationMatrixVersion> matrixVersionRec;
        List<CalculationMatrixRow> matrixRecords;
        
        // Determine the matrix name based on whether it's a test run or not
        if (Test.isRunningTest()) {
            DOAMatrixName = 'DOA Matrix Test Version';
        } else {
            List<ARTL_Calculation_Matrix_Version__mdt> matrixCustomMetadata = [SELECT Id, MasterLabel, ARTL_Matrix_Version_Name__c FROM ARTL_Calculation_Matrix_Version__mdt WHERE DeveloperName = :developerName];
            DOAMatrixName = (String) matrixCustomMetadata[0].get('ARTL_Matrix_Version_Name__c');
        }
        
        // Attempt to construct the mapping
        try {
            // Query for the matrix version
            matrixVersionRec = [SELECT Id FROM CalculationMatrixVersion WHERE name = :DOAMatrixName LIMIT 1];
            
            if (!matrixVersionRec.isEmpty() && matrixVersionRec != null) {
                // Query for the matrix records
                matrixRecords = [SELECT Id, InputData, OutputData FROM CalculationMatrixRow WHERE calculationMatrixVersionId = :matrixVersionRec[0].Id];
                
                if (!matrixRecords.isEmpty() && matrixRecords != null) {
                    // Constructing a map Map<String, Map<Double, String>> :: Map<ProductCode, Map<PriceRange, Level_Approver>>
                    // Signature: constructProductCodeToApproverMap(List<CalculationMatrixRow> matrixRows)
                    productCodeToApproverMap = ARTL_ApprovalProcessUtility.constructProductCodeToApproverMap(matrixRecords);
                }
            }
        }
        catch (Exception e) {
            // Handle any exceptions and log them
            System.debug('Exception in class::ARTL_InvokeDOAApprovalProcessHelper and method::constructProductCodeToApproverMap @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
    }
    
    
    
    
    /**
    * This method retrieves a list of Quote Line Items that require DOA approval for a given Quote Id.
    * It constructs a SOQL query to fetch relevant fields such as Product Name, Product Code, and charges.
    * @param quoteId - The Id of the Quote for which Quote Line Items are to be retrieved.
    * @return List<QuoteLineItem> - A list of Quote Line Items requiring DOA approval.
    */
    public static List<QuoteLineItem> fetchQuoteLineItems(Id quoteId) {
        List<QuoteLineItem> qliList;
        String query;
        
        // Attempt to fetch Quote Line Items
        try {
            // Construct SOQL query to retrieve relevant fields for Quote Line Items requiring DOA approval
            query = 'SELECT Id, Product2.Name, Product2.ProductCode, ARTL_NeedDOAApproval__c, Annual_Recurring_Charge__c, ARTL_ARCFloorRate__c, vlocity_cmt__OneTimeCharge__c, ARTL_NRCFloorRate__c, Annual_Recurring_Total__c, vlocity_cmt__OneTimeTotal__c FROM QuoteLineItem WHERE QuoteId = :quoteId AND ARTL_NeedDOAApproval__c = true';
            qliList = Database.query(query);
        }
        catch (Exception e) {
            // Handle any exceptions and log them
            System.debug('Exception in class::ARTL_InvokeDOAApprovalProcessHelper and method::fetchQuoteLineItems @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
        
        // Return the list of Quote Line Items
        return qliList;
    }
    
    
    /**
    * This method determines the appropriate approver and approval level for a given list of Quote Line Items.
    * It calculates the price range for each Quote Line Item based on Annual Recurring Charges (ARC) and One-Time Charges (OTC).
    * The method then compares the calculated price range with the configured price ranges in the productCodeToApproverMap
    * to find the approver and level with the highest priority.
    * @param qliList - The list of Quote Line Items for which the approver and level are to be determined.
    */
    public static void findApprover(List<QuoteLineItem> qliList) {
        Double qliPriceRange;
        String qliProductCode;
        
        Integer qliLevel;
        String qliApprover;
        String levelNDApprover;
        List<String> splitlevelNDApproverList;
        Double ARC, OTC;
        Map<Double, String> priceRangeToLevelNdApproverMap;
        
        try {
            // Iterate through each Quote Line Item to determine the appropriate approver and level
            for (QuoteLineItem qli : qliList) {
                // Retrieve ARC and OTC values, handling null cases
                ARC = (qli.Annual_Recurring_Total__c != null) ? qli.Annual_Recurring_Total__c : 0;
                OTC = (qli.vlocity_cmt__OneTimeTotal__c != null) ? qli.vlocity_cmt__OneTimeTotal__c : 0;
                
                // Calculate the price range based on Annual Recurring Charges (ARC) and One-Time Charges (OTC)
                qliPriceRange = ARC + OTC;
                qliProductCode = qli.product2.ProductCode;
                
                // Retrieve the map of price ranges to Level___ApproverName for the current product code
                priceRangeToLevelNdApproverMap = productCodeToApproverMap.get(qliProductCode);
                
                if (priceRangeToLevelNdApproverMap != null) {
                    // Iterate through each configured price range and determine the highest priority approver and level
                    for (Double priceRange : priceRangeToLevelNdApproverMap.keySet()) {
                        levelNDApprover = priceRangeToLevelNdApproverMap.get(priceRange);
                        splitlevelNDApproverList = levelNDApprover.split('___');
                        qliLevel = Integer.valueOf(splitlevelNDApproverList[0]);
                        qliApprover = splitlevelNDApproverList[1];
                        
                        // Check if the current QuoteLineItem meets the conditions for a higher priority approver and level
                        if (qliPriceRange <= priceRange && quoteLevel < qliLevel) {
                            // Update the quoteLevel and approver
                            quoteLevel = qliLevel;
                            quoteApprover = qliApprover;
                        }
                    }
                }
            }
            // Log the final determined approver and level
            System.debug('Final Approver=>' + quoteApprover);
            System.debug('Final Approver Level=>' + quoteLevel);
        } 
        catch (Exception e) {
            // Handle any exceptions and log them
            System.debug('Exception in class::ARTL_InvokeDOAApprovalProcessHelper and method::findApprover @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
    }
    
    
    
    /**
    * Checks if a given Quote is currently in a pending approval process.
    * @param quoteId - The Id of the Quote to be checked for pending approval.
    * @return boolean - True if the Quote is in an active approval process, False otherwise.
    */
    @AuraEnabled
    public static boolean checkQuoteIsInPendingApproval(Id quoteId) {
        // Default to true, assuming the Quote has pending approval until proven otherwise
        boolean quoteHavePendingApproval = true;
        
        try {
            // Query for active approval processes related to the provided Quote Id
            List<ProcessInstance> approvalProcesses = [SELECT Id, Status, TargetObjectId
                                                       FROM ProcessInstance
                                                       WHERE TargetObjectId = :quoteId
                                                       AND Status = 'Pending'];
            
            if (!approvalProcesses.isEmpty()) {
                // The Quote is in an active approval process
                quoteHavePendingApproval = true;
            } else {
                // The Quote is not in an active approval process
                System.debug('Quote is not in an active approval process.');
                quoteHavePendingApproval = false;
            }
        }
        catch (Exception e) {
            // Handle any exceptions and log them
            System.debug('Exception in class::ARTL_InvokeDOAApprovalProcessHelper and method::checkQuoteIsInPendingApproval @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
        
        return quoteHavePendingApproval;
    }
    
    
}