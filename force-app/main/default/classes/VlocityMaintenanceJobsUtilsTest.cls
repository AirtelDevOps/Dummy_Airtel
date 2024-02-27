@isTest
public class VlocityMaintenanceJobsUtilsTest {
@isTest
    static void invokeTelcoAdminConsoleControllerTest() {
		 Test.startTest();
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> optionMap=new Map<String,Object>();  
        
        VlocityMaintenanceJobsUtils fpvu=new VlocityMaintenanceJobsUtils();
        fpvu.invokeMethod('invokeTelcoAdminConsoleController',inputMap,outputMap,optionMap);
        Test.stopTest();
    } 
    
    @isTest
    static void regenerateAllGlobalKeysBatchTest() {
		 Test.startTest();
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> optionMap=new Map<String,Object>();  
        
        VlocityMaintenanceJobsUtils fpvu=new VlocityMaintenanceJobsUtils();
        fpvu.invokeMethod('regenerateAllGlobalKeysBatch',inputMap,outputMap,optionMap);
        Test.stopTest();
        
       
    } 
}