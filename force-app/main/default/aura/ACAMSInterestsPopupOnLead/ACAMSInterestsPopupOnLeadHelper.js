({
    
    fetchDataHelper : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Form', fieldName: 'Form__c', type: 'text'},
            {label: 'Interest Status', fieldName: 'Interest_Status__c', type: 'text'},
            {label: 'Lead Status', fieldName: 'Lead_Status__c', type: 'text'},
            {label: 'Level 1', fieldName: 'Product_Level_1__c', type: 'text'}, 
            {label: 'Level 2', fieldName: 'Product_Level_2__c', type: 'text'}
        ]);
        var action = component.get("c.getInterestsFromLead");
        action.setParams({
            "leadId" :  component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            //alert('---->'+state);
            
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                 console.log('--ids-result ---->' + JSON.stringify(res));
                
                var interests = [];
                for(var i=0; i < res.length; i++){                     
                    if(res[i].Select_To_Associate__c == true){
                        console.log('--in-result ---->' + JSON.stringify(res[i]));
                        interests.push(res[i].Id);
                    } 
                }
                console.log('--out-result ---->' + JSON.stringify(interests));
                component.set("v.selectedRecordsList",interests);
                component.set("v.data", res);
                
            }
        });
        $A.enqueueAction(action);
    }
    
})