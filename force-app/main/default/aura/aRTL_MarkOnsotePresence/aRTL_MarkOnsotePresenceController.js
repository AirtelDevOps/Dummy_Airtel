/*({
	getValueFromLwc : function(component, event, helper) {
		component.set("v.inputValue",event.getParam('value'));
        
        console.log('returned'+component.get("v.inputValue"));	
        if(component.get("v.inputValue")==true){
            var toastEvent = $A.get("e.force:showToast");
            
    toastEvent.setParams({
        "type" : "success",
        "title": "Success!",
        "message": "Your attendance has marked successfully."
    });
    toastEvent.fire();
   window.setTimeout(function(){
      location.reload();
   }, 500);

        }
        if(component.get("v.inputValue")==false){
              location.reload();
        }
	}
})*/
({
    doInit : function(component, event, helper) {
        helper.findGeolocation(component, event, helper);
    },
    
    captureGeolocation : function(component, event, helper) {
        helper.captureHelper(component, event);
    }
})