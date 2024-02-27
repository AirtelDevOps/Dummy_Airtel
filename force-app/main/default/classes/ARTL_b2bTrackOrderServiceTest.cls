@IsTest
public class ARTL_b2bTrackOrderServiceTest {
    @IsTest
    public static void HandleTaskoperationsTest(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String reqBody = '{';
	           reqBody += '"body": {';
	           reqBody += '"Message": {';
	           reqBody += '"IntObjectFormat": "Siebel Hierarchical","MessageId": "1-LDWU2","IntObjectName": "B2B PMW Create Task IO",';
	           reqBody += '"MessageType": "OrderStatus","ListOfB2BUpdateOmOrderReq": {"B2BOrderUpdate": {"LSI": "2312157050298",';
	           reqBody += '"OMOrderId": "725219","MasterOrderId": "725218","OrderStatus": "RUNNING","RfsDate": "2024-01-14",';
	           reqBody += '"LanIPv4SubnetMask": "/29","WanIPv4PESubnetMask": "/30","WanIPv4CESubnetMask": "/30"}},';
	           reqBody += '"B2B Action PM Workbench Thin BC": {"Activity UID": "1-4QNBK1P","LSI": "2312157050298","Order Id": "725219",';
	           reqBody += '"TaskCreationTime": "15/12/2023 16:32:05","Task Name": "PM approval for LoC","OMTaskId": "T001","TaskType": "PM Approval",';
	           reqBody += '"B2BOutcome": "Ready","AltKey": "2312157050298_8931430_T001","PMOLMID": "B0267644","ListOfB2B Input Task DFF BC": {';
	           reqBody += '"B2B Input Task DFF BC": [{"Value": "/30","Name": "WAN IPv4 Subnet"},{"Value": "2024-01-14","Name": "Customer Need By Date"}';
	           reqBody += ']}}}}}';
        req.headers.put('Content-Type', 'application/json');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqBody);
        RestContext.request = req;
        Test.startTest();
        ARTL_b2bTrackOrderService.HandleTaskoperations();
        Test.stopTest();
    }
    @IsTest
    public static void HandleTaskoperationsTest2(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        String xmlString = '<?xml version="1.0" encoding="utf-16" standalone="yes"?><SiebelMessage IntObjectName="B2B PMW Create Task IO" IntObjectFormat="ListOfCreateTaskDetails">';										
               xmlString += '<ListOfCreateTaskDetails><CreateTask><TaskId></TaskId><Assignee></Assignee><TaskStatus>Jeopardy</TaskStatus>';										
               xmlString += '<TaskType>Auto</TaskType><MasterOrderId></MasterOrderId><Bin>LEO_ZSM_ProjectManager</Bin><OrderId>694967</OrderId>';										
               xmlString += '<TaskCreationTime>07/04/2023 16:59:33</TaskCreationTime><TaskName>Installation Wiring</TaskName><ParentTaskName>Installation</ParentTaskName>';										
               xmlString += '<JeopardyCode>ACC1</JeopardyCode><ALTkey></ALTkey><ProductName>Internet</ProductName><JeopardyReason>Site contact details required</JeopardyReason>';										
	           xmlString += '</CreateTask></ListOfCreateTaskDetails></SiebelMessage>';
        req.headers.put('Content-Type', 'application/xml');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(xmlString);
        RestContext.request = req;
        Test.startTest();
        ARTL_b2bTrackOrderService.HandleTaskoperations();
        Test.stopTest();
    }
}