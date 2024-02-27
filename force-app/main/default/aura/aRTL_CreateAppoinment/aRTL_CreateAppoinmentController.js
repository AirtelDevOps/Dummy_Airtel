({
	
    doInit : function(component) {
    var taskid = component.get('v.recordId');    
        console.log('record taskId',taskid);
    window.component = component;
    $A.get("e.force:createRecord").setParams({
        "entityApiName": "Event",
        "defaultFieldValues": {
            'ARTL_TaskId__c': taskid
        }
        
    }).fire();
},
})