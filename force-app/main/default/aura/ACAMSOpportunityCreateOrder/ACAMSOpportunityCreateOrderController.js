({
    doInit : function(component, event, helper) {
        var closeAction = function() {
            $A.get("e.force:closeQuickAction").fire();
        }
        setTimeout($A.getCallback(closeAction), 5000);
    }
})