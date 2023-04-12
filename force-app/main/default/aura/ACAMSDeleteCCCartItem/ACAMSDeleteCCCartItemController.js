({
	doInit : function(component, event, helper) {
		var action = component.get("c.getCartItemsToDelete");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.recordError", response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
	},
    handleClick : function (component, event, helper) {
        //alert("You clicked: " + event.getSource().get("v.label"));
        $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
    }
})