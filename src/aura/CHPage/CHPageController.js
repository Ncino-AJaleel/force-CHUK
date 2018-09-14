({
    doInit : function(component, undefined, helper) {
        // get info rom pagereference?
        let pageRef = component.get("v.pageReference");
        component.set("v.recordId", pageRef.state.c__recordId);
        //helper.reload(component);
        var action = component.get("c.sayMyName");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response);
                var rs = JSON.parse(response.getReturnValue());
                component.set("v.recordName", rs.recordName);
                component.set("v.sObjectName", rs.objectType);
                
            } else if (state === "ERROR") {
                /*let appEvent = $A.get("e.c:handleCallbackError");
                appEvent.setParams({
                    "errors": a.getError()
                });
                appEvent.fire();*/
            }
        });
        $A.enqueueAction(action);
        
    },
})