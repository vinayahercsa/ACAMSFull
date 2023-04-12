({
    init : function(component, event, helper) {
        
        helper.fetchDataHelper(component, event, helper);
    },
    
    updateSelectedText: function (component, event) {
        component.set("v.errormsg", ''); 
        var selectedRows = event.getParam('selectedRows');        
        console.log('---result ---->' + JSON.stringify(selectedRows));
        component.set('v.selectedRowsCount', selectedRows.length);
        component.set("v.RecordsList",selectedRows);
    },
    saveSelectedRecords : function(component, event, helper) {
        var recordslength = component.get('v.selectedRowsCount');
        
            var action = component.get("c.updateInterestsFromLead");
            action.setParams({
                "allRecords" : component.get("v.data"),
                "InterestList" :  component.get("v.RecordsList")
            });
            
            console.log('---result on save---->' + component.get("v.RecordsList"));
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('---result ---->' + JSON.stringify(response.getReturnValue()));
                if (state === "SUCCESS") {          
                    //component.set("v.RecordsList",[]);
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
            });
            $A.enqueueAction(action);   
      /*  if(recordslength > 0){}else{
            component.set("v.errormsg", 'Please Select Records.');            
        }*/
    },
    
    cancel :  function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
        component.set("v.errormsg", ''); 
    }
    
})