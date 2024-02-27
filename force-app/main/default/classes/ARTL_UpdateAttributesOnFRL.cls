/************************************************************************************************************************************************************************************************************
 * @Author       : Aliya Ameer
 * @Date         : 14/01/2024
 * @Test Class   : ARTL_UpdateAttributesOnFRLTest
 * @Description  : Handles updates on attributes of FRL
 ******************************************************************************************************************************************************************************************************************/
global without sharing class ARTL_UpdateAttributesOnFRL implements vlocity_cmt.VlocityOpenInterface {

    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {

        if (methodName.equals('updateAttributes')) {
            updateAttributes(inputMap, outMap, options);
        }
        return true;
    }

    global static void updateAttributes(Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {

        String FRLId = String.valueOf(inputMap.get('FRLId'));
        String LSI = String.valueOf(inputMap.get('LSI'));

        vlocity_cmt__FulfilmentRequestLine__c frlRecord = [SELECT Id, vlocity_cmt__AttributeSelectedValues__c
            FROM vlocity_cmt__FulfilmentRequestLine__c WHERE Id =: FRLId LIMIT 1
        ];
        if (frlRecord != null) {
            // Parse the JSON string to a Map
            Map < String, Object > attributeValues = (Map < String, Object > ) JSON.deserializeUntyped(frlRecord.vlocity_cmt__AttributeSelectedValues__c);

            // Update the ATT_PRIMARY_KEY attribute
            attributeValues.put('ATT_PRIMARY_KEY', LSI);

            // Convert the Map back to a JSON string
            String updatedAttributes = JSON.serialize(attributeValues);

            // Update the FRL record
            frlRecord.vlocity_cmt__AttributeSelectedValues__c = updatedAttributes;
            update frlRecord;

            System.debug('Attributes updated successfully');
        } else {
            System.debug('No matching FRL record found for the provided FRLId');
        }
    }
}