global with sharing class ARTL_OmniActionUtil implements Callable {

    global Object call(String action, Map<String,Object> args) {
      Map<String,Object> input = (Map<String,Object>) args.get('input');
      Map<String,Object> output = (Map<String,Object>)args.get('output');
      Map<String, Object> options = (Map<String,Object>) args.get('options');
  
      return invokeMethod(action, input, output, options);
    }
    
    global Boolean invokeMethod (String methodName, Map<String, Object> input,Map<String, Object> output,Map<String, Object> options ) {
        system.debug('inside invoke method');
        if (methodName == 'logInfo') logInfo(input, output, options);
        if (methodName == 'logError') logError(input, output, options);
        if (methodName == 'logDebug') logDebug(input, output, options);
        if (methodName == 'accountTeam') getAccountTeam(input, output, options);
        //if (methodName == 'transformDocMapping') transformDocMapping(input, output, options);
        return true;
    }
  
    /**
    * @ description :  This method calls the logger class. Since the logger class can't be directly called from IP
    *                 to log the IP transaction this method can be invoked from IP.   
    */
    private void logInfo(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
      String type = input.containskey('type') ? String.valueOf(input.get('type')) : '';
      String name = input.containskey('name') ? String.valueOf(input.get('name')) : '';
      String message = input.containskey('message') ? String.valueOf(input.get('message')) : '' ;
      String logData = input.containskey('logData') ? JSON.serialize(input.get('logData')) : '' ;
      ARTL_Logger.info(type, name, message, logData);
    }
  /**
  * @ description :  This method calls the logger class. Since the logger class can't be directly called from IP
  *                 to log the IP transaction this method can be invoked from IP.   
  */
    private void logError(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
      String type = input.containskey('type') ? String.valueOf(input.get('type')) : '';
      String name = input.containskey('name') ? String.valueOf(input.get('name')) : '';
      String message = input.containskey('message') ? String.valueOf(input.get('message')) : '' ;
      String logData = input.containskey('logData') ? JSON.serialize(input.get('logData')) : '' ;
      String errorMessage = input.containskey('errorMessage') ? JSON.serialize(input.get('errorMessage')) : '';
      ARTL_Logger.error(type, name, message, logData,errorMessage );
    }
    /**
  * @ description :  This method calls the logger class. Since the logger class can't be directly called from IP
  *                 to log the IP transaction this method can be invoked from IP.  
  */
    private void logDebug(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
      String type = input.containskey('type') ? String.valueOf(input.get('type')) : '';
      String name = input.containskey('name') ? String.valueOf(input.get('name')) : '';
      String message = input.containskey('message') ? String.valueOf(input.get('message')) : '' ;
      String logData = input.containskey('logData') ? JSON.serialize(input.get('logData')) : '' ;
      ARTL_Logger.debug(type, name, message, logData );
    }

    private void getAccountTeam(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options) {
      String accountId = input.containskey('AccountId') ? String.valueOf(input.get('AccountId')) : '';
      if(String.isNotBlank(accountId)) {
          String jsonStringResponse = ARTL_AccountTriggerHandler.GetAccountTeamJSON(accountId);
          Map<String,Object> jsonResponse = (Map<String,Object>) JSON.deserializeUntyped(jsonStringResponse);
          jsonResponse.put('AccountId',(Object)accountId);
          System.debug('outputMap ' + output);
          output.putAll(jsonResponse);
      }
  }
    
    /*private void transformDocMapping(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){
        List<Object> arguments = (List<Object>)input.get('arguments');
        Map<String,Object> objectMap = (Map<String,Object>) arguments[0];
        List<Object> contactList = (List<Object>) objectMap.get('VLOCITY-FORMULA-LIST');
        ARTL_Logger.debug('test', 'transformDocMapping', '', JSON.serialize(arguments[0]));
        //List<Object> contactList = (List<Object>)arguments[0];
        //List<Map<String,Object>> contactMapList = new List<Map<String,Object>>();
        Map<String,List<Map<String,Object>>> newContactObj = new Map<String,List<Map<String,Object>>>();
        
        for(Object obj:contactList){
            Map<String,Object> contactObj = (Map<String,Object>)obj;
            
            List<Map<String,Object>> transformedContactList ;
            //newContactObj = new Map<String,List<Map<String,Object>>>();
            //Map<String,Object> outerContactMap = new Map<String,Object>();
            Map<String,Object> innerContactMap = new Map<String,Object>();
            
            //innerContactMap.put('Score',contactObj.get('Score'));
            //outerContactMap.put('Score',contactObj.get('Score'));
            //outerContactMap.put('RecId',contactObj.get('Id'));

            innerContactMap.put('Name',contactObj.get('Name'));
            innerContactMap.put('MeetingDate',contactObj.get('MeetingDate'));
            if(newContactObj.containsKey(String.valueOf(contactObj.get('IdScore')))){
                transformedContactList = newContactObj.get(String.valueOf(contactObj.get('IdScore')));
                transformedContactList.add(innerContactMap);
            }else{
                transformedContactList = new List<Map<String,Object>>{innerContactMap};
            }
            //outerContactMap.put('Contacts',transformedContactList);
            newContactObj.put(String.valueOf(contactObj.get('IdScore')),transformedContactList);
            System.debug(String.valueOf(contactObj.get('IdScore'))+'::'+transformedContactList);
        }

        List<Map<String,Object>> contactMapList = new List<Map<String,Object>>();
        for(String scoreId:newContactObj.keySet()){
            Map<String,Object> contactMap = new Map<String,Object>();
            List<Map<String,Object>> objList = (List<Map<String,Object>>) newContactObj.get(scoreId);
            contactMap.put('Score',scoreId.substring(scoreId.indexOf('_')+1));
            contactMap.put('Contacts',newContactObj.get(scoreId));
            contactMapList.add(contactMap);
        }

        System.debug('contactMapList::'+contactMapList);
        //Map<idscore,List<ContactsMap>>
        output.put('result',contactMapList);
    }*/
}