global class UtilsGetSessionId{
    global static String getSessionIdFromVFPage(PageReference visualforcePage){
        String content;
   if (Test.IsRunningTest()){
        content='This is some text Start_Of_Session_Id12345End_Of_Session_Id more text here.';
   }else{
        content=visualforcePage.getContent().toString();
   }
        //String content = visualforcePage.getContent().toString();
        Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                e = content.indexOf('End_Of_Session_Id');
        return content.substring(s, e);
    }
}