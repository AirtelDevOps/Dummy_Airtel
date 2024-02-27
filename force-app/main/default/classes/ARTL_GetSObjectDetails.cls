/**
 * Class to Process SObject Records: ARTL_GetSObjectDetails 
 *
 * @Author  Trishank Chaddha
 * @Company Salesforce (SFI)
 * @Date    29/12/2023
 * @Test Class: 
 * @Description  fetch sObject detail Using Id and Update Records
 */
global without sharing class ARTL_GetSObjectDetails implements vlocity_cmt.VlocityOpenInterface {

    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
        try {
            if (methodName.equals('GetDetails')) {
                system.debug('Inside GetDetails 15');
                GetDetails(input, outMap, options);
                return true;
            }
        } catch (Exception ex) {
            System.debug('DEBUGG 1 ' + ex.getMessage() + ' ' + ex.getLineNumber());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_GetSObjectDetails:GetDetails', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
        }
        return false;
    }

    public static void GetDetails(Map<String, Object> input, Map<String, Object> outMap, Map<String, Object> options) {
        try {
            // Retrieve the record details (Id, errorMessage, status) from the input map
            List<Map<String, Object>> records = castToListOfMaps(input.get('RequestBody'));
            List<String> updateResults = new List<String>();

            for (Map<String, Object> record : records) {
                Id recordId = (Id) record.get('Id');
                String status = (String) record.get('Status');
                String errorMessage = (String) record.get('ErrorMessage');

                // Perform the record update
                String updateResult = updateRecord(recordId, status, errorMessage);

                // Add the update result to the list
                updateResults.add(updateResult);
            }

            // Add the list of update results to the output map
            outMap.put('updateResults', updateResults);
            outMap.put('Error', false);
            System.debug('outMap 46 -->>'+outMap);

        } catch (Exception ex) {
            outMap.put('updateResults', 'Error updating record:'+ex.getMessage());
            outMap.put('Error', True);
            outMap.put('Exception',ex.getMessage());
            System.debug('DEBUGG 2' + ex.getMessage() + ' ' + ex.getLineNumber());
            ARTL_Logger.error(ARTL_Constants.CONTROLLER, 'ARTL_GetSObjectDetails:GetDetails', '', new Map<String, Object>{'Exception' => ex.getMessage(), 'LineNumber' => ex.getLineNumber()}, ex);
        }
    }

    private static List<Map<String, Object>> castToListOfMaps(Object input) {
        if (input instanceof List<Object>) {
            List<Object> inputList = (List<Object>) input;
            List<Map<String, Object>> result = new List<Map<String, Object>>();
            for (Object item : inputList) {
                if (item instanceof Map<String, Object>) {
                    result.add((Map<String, Object>) item);
                }
            }
            System.debug('castToListOfMaps first return'+result);
            return result;
        }
        System.debug('castToListOfMaps second return');
        return new List<Map<String, Object>>();
    }

    private static String updateRecord(Id recordId, String status, String errorMessage) {
        try {
            // Fetch the object type dynamically
            SObjectType sObjectType = recordId.getSObjectType();
            String objectName = sObjectType.getDescribe().getName();

            // Instantiate the object dynamically
            SObject recordToUpdate = Database.query('SELECT Id FROM ' + objectName + ' WHERE Id = :recordId LIMIT 1');

            // Set the Id for the existing record
            recordToUpdate.put('Id', recordId);

            // Add your custom fields
            recordToUpdate.put('ARTL_Siebel_Sync_Status__c', status);
            recordToUpdate.put('ARTL_Error_Message__c', errorMessage);

            // Perform the update
            update recordToUpdate;
			System.debug('recordToUpdate 88 -->>'+recordToUpdate);
            // Return a success message
            return 'RecordId: ' + recordId + ' updated successfully - Status: ' + status + ' - ErrorMessage: ' + errorMessage;
        } catch (Exception ex) {
            System.debug('catch  3');
            // Handle exceptions and return an error message
            return 'Error updating record: ' + ex.getMessage();
        }
    }
}