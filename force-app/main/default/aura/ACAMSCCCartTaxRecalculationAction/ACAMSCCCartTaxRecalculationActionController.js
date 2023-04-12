({
    doInit : function(component, _event, _helper) {
        const recordId   = component.get("v.recordId");
        const action = component.get("c.recalculateTaxes");
        action.setParams({recordId});
        action.setCallback(this, function (response) {
            var toastEvent = $A.get("e.force:showToast");
            if (component.isValid() && response.getState() === "SUCCESS") {
                toastEvent.setParams({
                    "title": $A.get("$Label.c.Cart_TaxRecalculationSuccessTitle"),
                    "message": $A.get("$Label.c.Cart_TaxRecalculationSuccessMessage"),
                    "type": "success"
                });
            } else {
                toastEvent.setParams({
                    "title": $A.get("$Label.c.Cart_TaxRecalculationFailureTitle"),
                    "message": $A.get("$Label.c.Cart_TaxRecalculationFailureMessage"),
                    "type": "error"
                });
            }
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            setTimeout($A.getCallback(function() {
                toastEvent.fire();
            }), 500);
            dismissActionPanel.fire();
        })
        $A.enqueueAction(action);
    }
})