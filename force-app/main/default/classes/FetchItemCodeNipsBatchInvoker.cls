global class FetchItemCodeNipsBatchInvoker implements vlocity_cmt.VlocityOpenInterface2 {


    global Boolean InvokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {

        if (methodName.equalsIgnoreCase('fetchItemCodeInitiate')) {
            String quoteId = (String)inputMap.get('QuoteId');
            // String userId = (String)inputMap.get('UserId');
            fetchItemCodeInitiate(quoteId);
            return true;
        }
        return false;
    }
    

    private void fetchItemCodeInitiate(String quoteId) {
        // ItemFetchCodeBatch batch = new ItemFetchCodeBatch(quoteId, userId);
        Database.executeBatch(new FetchItemCodeNipsBatch( quoteId),1);
    }
}