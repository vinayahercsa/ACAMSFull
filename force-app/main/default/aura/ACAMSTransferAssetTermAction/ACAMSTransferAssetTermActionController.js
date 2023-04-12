({
    doInit : function(component, _event, _helper) {
        const recordId   = component.get("v.recordId");
        const action = component.get("c.transferAssetTerm");
        action.setParams({recordId});
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(response);
            if (state === "SUCCESS") {
                var sObjectEvent = $A.get("e.force:editRecord");
                sObjectEvent.setParams({
                    "recordId": response.getReturnValue()
                });
                sObjectEvent.fire();
            } else if (state === "ERROR"){
                var errors = response.getError();
                if (errors) {
                    cmp.set("v.errorMsg", errors[0].message);
                    var errorMsg = cmp.find('errorMsg');
                    $A.util.removeClass(errorMsg, 'slds-hide');
                    var field = cmp.find('field');
                    $A.util.addClass(field, 'slds-hide');
                }
            }
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
    },
})