@isTest
public class UtilsGetSessionIdTestClass {
    
   
    @isTest
    static void testGetSessionIdFromVFPage() {
       // Test when 'Start_Of_Session_Id' and 'End_Of_Session_Id' strings are present
        PageReference testPage1 = Page.getSessionIdVFPage;
        String content1 = 'Some_Content_Start_Of_Session_Id123End_Of_Session_IdSome_Content';

        String sessionId1 = UtilsGetSessionId.getSessionIdFromVFPage(testPage1);
        System.assertEquals('123', sessionId1, 'Expected session ID: 123');
    }
}