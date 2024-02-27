({
	findGeolocation : function(component, event) {
		//finds the geolocation of the user's device
		//prompts user to allow location access if not already allowed
        if (navigator.geolocation) {
            var lat;
            var lng;
            navigator.geolocation.getCurrentPosition(function(e) {
                //alert('init::'+e.coords.latitude + ', ' + e.coords.longitude);
                lat = e.coords.latitude;
                lng = e.coords.longitude;
                component.set("v.latitude",lat);
                component.set("v.longitude",lng);
                component.set("v.loaded", !component.get("v.loaded"));
            }, function() {
                console.log('There was an error.');
            },{maximumAge:600, enableHighAccuracy :true});
        }else {
            alert('Geolocation is not supported');
        }   
    },
    
    captureHelper : function(component, event) {
        //obtain recordId
        var eventId = component.get("v.recordId");
        //alert('update::'+component.get("v.latitude") + '::' + component.get("v.longitude"));
        if(component.get("v.latitude") != undefined && component.get("v.longitude") != undefined){
            //pointer to Apex method in ARTL_UpdateOnsiteAttendance
            var action = component.get("c.updateAttendance");
            //set parameters for Apex method updateGeolocation
            action.setParams({
                "recordId" : eventId,
                "latitude" : component.get("v.latitude"),
                "longitude" : component.get("v.longitude")
            });
            //set callback method
            action.setCallback(this, function(response) {
                var state = response.getState(); //fetch the response state
                if (state === "SUCCESS") {
                    alert("Geolocation saved.")
                }
                else {
                    alert("Geolocation not saved.");
                }
            });
            //invoke the Apex method
            $A.enqueueAction(action);
        }
        //close quickaction window
        $A.get("e.force:closeQuickAction").fire();
        //reload page to display updated geolocation
        window.location.reload();
    }
})