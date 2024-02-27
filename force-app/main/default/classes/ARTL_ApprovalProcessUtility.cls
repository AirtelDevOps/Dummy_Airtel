/******************************************************************************************************
* @Author:      Saurav Madhusoodanan TV  <smadhusoodanantv@salesforce.com >
* @Company:     Salesforce
* @Date:        26/11/2023
* @Reviewer:
* @Review Date:
* @Description: Utility class for commonly used method for DOA Approval process.
* ++++++++++++++++++++++ Changes Implemented / Modification Log ++++++++++++++++++++++++++++++++++++++
* UserStory / Defect      Developer             Date           Comment
* ------------------      ---------------       -----------    ----------------------------------------
* 
*******************************************************************************************************/
public class ARTL_ApprovalProcessUtility {
    /**
    * Constructs a mapping of product codes to a mapping of price ranges and corresponding approval levels and approvers.
    * @param matrixRows - List of CalculationMatrixRow objects representing the matrix rows.
    * @return Map<String, Map<Double, String>> - The constructed mapping of product codes to price ranges and approvers.
    */
    public static Map<String, Map<Double, String>> constructProductCodeToApproverMap(List<CalculationMatrixRow> matrixRows) {
        // Initialize the main map to store product codes and their corresponding price ranges and approvers
        Map<String, Map<Double, String>> productCodeToApproverMap = new Map<String, Map<Double, String>>();
        
        // Variables to hold intermediate JSON representations of input and output data
        Map<String, Object> inputJSON;
        Map<String, Object> outputJSON;
        
        // Variables to store matrix data
        String matrixProductCode;
        Double matrixPriceRange;
        String matrixLevel;
        String matrixApprover;
        String matrixLevelNDApprover;
        
        try {
            // Check if matrixRows is not empty and not null
            if (!matrixRows.isEmpty() && matrixRows != null) {
                // Iterate through each matrix row
                for (CalculationMatrixRow row : matrixRows) {
                    // Deserialize input and output JSON data
                    inputJSON = (Map<String, Object>) JSON.deserializeUntyped(row.InputData);
                    outputJSON = (Map<String, Object>) JSON.deserializeUntyped(row.OutputData);
                    
                    // Extract matrix data from JSON
                    matrixProductCode = String.valueOf(inputJSON.get('ProductCode'));
                    matrixPriceRange = Double.valueOf(inputJSON.get('PriceRange'));
                    matrixLevel = String.valueOf(outputJSON.get('Level'));
                    matrixApprover = String.valueOf(outputJSON.get('Approver'));
                    
                    // Combine level and approver into a single string
                    matrixLevelNDApprover = matrixLevel + '___' + matrixApprover;
                    
                    // Check if product code is already in the main map
                    if (!productCodeToApproverMap.containsKey(matrixProductCode)) {
                        // If not, create a new map for the product code and add the price range and level/approver
                        productCodeToApproverMap.put(matrixProductCode, new Map<Double, String>{matrixPriceRange => matrixLevelNDApprover});
                    } else {
                        // If product code is already present, get the existing map and add the new price range and level/approver
                        Map<Double, String> priceRangeToLevelApproverMap = productCodeToApproverMap.get(matrixProductCode);
                        priceRangeToLevelApproverMap.put(matrixPriceRange, matrixLevelNDApprover);
                    }
                }
                // Log the final productCodeToApproverMap for debugging
                system.debug('productCodeToApproverMap==>' + JSON.serializePretty(productCodeToApproverMap));
                return productCodeToApproverMap;
            } else {
                // Return null if matrixRows is empty or null
                return null;
            }
        } catch (Exception e) {
            // Handle any exceptions and log them
            System.debug('Exception in class::ARTL_ApprovalProcessUtility and method::constructProductCodeToApproverMap @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
        }
        
        // Return null in case of any exception
        return null;
    }
    
    /**
    * Invokes the specified approval process for a given Quote record.
    * @param quoteId - The Id of the Quote record for which the approval process is initiated.
    * @param comments - Comments to be associated with the approval process submission.
    * @param submittingUser - The Id of the user submitting the approval request.
    * @param approver - The Id of the user designated as the approver.
    * @param ApprovalProcessName - The name or Id of the Approval Process definition to be invoked.
    * @param skipEntryCondition - A boolean indicating whether to skip entry criteria for the approval process.
    */
    public static Boolean invokeApprovalProcess(Id quoteId, String comments, Id submittingUser, Id approver, String ApprovalProcessName, Boolean skipEntryCondition) {
        // Variable to hold the result of the approval process submission
        Approval.ProcessResult result;
        
        try {
            // Create a new Approval.ProcessSubmitRequest instance
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            
            // Set various parameters for the approval process submission
            req1.setComments(comments);
            req1.setObjectId(quoteId);
            req1.setSubmitterId(submittingUser);
            req1.setNextApproverIds(new Id[] { approver });
            req1.setProcessDefinitionNameOrId(ApprovalProcessName);
            req1.setSkipEntryCriteria(skipEntryCondition);
            
            // Submit the approval process request
            result = Approval.process(req1);
            
            // Log the result of the approval process submission for debugging
            system.debug('Approval.ProcessResult result' + JSON.serializePretty(result));
            
            // Check if the approval process submission was successful
            if (result.isSuccess()) {
                System.debug('Approval process submitted successfully.');
                System.debug('Approval Process Instance ID: ' + result.getInstanceId());
            } else {
                // Log an error message if the approval process submission failed
                System.debug('Approval process submission failed.');
                System.debug('Error Message: ' + result.getErrors()[0].getMessage());
            }
            return result.isSuccess();
        } catch (Exception e) {
            // Handle any exceptions and log them
            System.debug('Exception in class::ARTL_ApprovalProcessUtility and method::invokeApprovalProcess @line number' +
                         e.getLineNumber() + ' [' + e.getMessage() + ']');
            String errorMessage = e.getMessage();
            system.debug(errorMessage);
        }
        return false;
    }
    
}