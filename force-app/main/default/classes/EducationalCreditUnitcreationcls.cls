global class EducationalCreditUnitcreationcls implements Database.Batchable<sobject>{
    
    global string query='';
    global Date dateVal = Date.parse(Label.LiveECUStartDate);

    global EducationalCreditUnitcreationcls() {
        // need to add nest query to get record type Registrant
        query='Select id,name,Event_Date__c,Credit_Hours_ECU__c,Assignee__c,';
                query+='AssetProduct_Code__c,Event_Name__c from Asset WHERE RecordTypeId IN (SELECT Id FROM RecordType WHERE Name = \'Registrant\')';
                query+=' and Event_Date__c< Today and Assignee__c!=null and Event_Date__c>=:dateVal and Paid_Cert__c = true and Attended__c = true and Status__c= \'Active\' and CancelDate__c = null'; 
                  query+=' and CC_Product__r.ccrz__ProductType__c != \'Bundle\' and CC_Product__r.Level_2__c != \'Membership\' and CC_Product__r.Level_3__c != \'Sponsorship\' and CC_Product__r.Educational_Credit_Value__c > 0';
               
    }

    global Database.Querylocator start(Database.BatchableContext BC){     
        System.debug('---->'+(query));          
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<Asset> lstattendee){
        List<Educational_Credit_Unit_Legacy__c> lsteducreditunits=new List<Educational_Credit_Unit_Legacy__c>();
        Map<String,Educational_Credit_Unit_Legacy__c> contwithedcreditmap=new Map<String,Educational_Credit_Unit_Legacy__c>();
        Set<String> contidset=new Set<String>();

        if(lstattendee!=null && lstattendee.size()>0){
            for(Asset attendeeobj:lstattendee){                         
                contidset.add(attendeeobj.Assignee__c);
            }

            if(contidset!=null && contidset.size()>0){
                for(Educational_Credit_Unit_Legacy__c educreditobj:[select id,name,Contact__c,AttendeeID__c from Educational_Credit_Unit_Legacy__c 
                                                                    Where Contact__c in:contidset]){                              
                            contwithedcreditmap.put(educreditobj.Contact__c+'#'+educreditobj.AttendeeID__c,educreditobj);                                               
                }
            }

            for(Asset  attendeeobj:lstattendee){
                //Start of checking whether the contact associated with attendee having educrdit unit
                //or not
                System.debug('for loop for eduunit preparation entering');
                if(contwithedcreditmap.get(attendeeobj.Assignee__c+'#'+attendeeobj.id)==null){
                        System.debug('if entering when contact on attendee doesnt have any edu credit');
                    Educational_Credit_Unit_Legacy__c educreditobj=new Educational_Credit_Unit_Legacy__c();
                    educreditobj.Name='ACAMS';
                    educreditobj.Contact__c=attendeeobj.Assignee__c;
                    System.debug('datedid:'+attendeeobj.id+'---'+attendeeobj.Event_Date__c);
                    if(attendeeobj.Event_Date__c!=null)
                        educreditobj.Credit_Start_Date__c=Date.valueOf(attendeeobj.Event_Date__c);
                      
                    educreditobj.Credit_Value__c=attendeeobj.Credit_Hours_ECU__c;
                    if(attendeeobj.Event_Date__c!=null)
                        educreditobj.Earned_Date__c=Date.valueOf(attendeeobj.Event_Date__c);
                    educreditobj.ECU_Product_Code__c=attendeeobj.AssetProduct_Code__c;
                    educreditobj.ECU_Product_Description__c=attendeeobj.Event_Name__c;
                    if(attendeeobj.Event_Date__c!=null)
                        educreditobj.Credit_End_Date__c=Date.valueOf(attendeeobj.Event_Date__c).addDays(365*3);
                    educreditobj.AttendeeID__c=attendeeobj.id;
                    educreditobj.Self_Reported__c='No';
                    lsteducreditunits.add(educreditobj);    
                    
                }//End of if
            }
                    //Inserting Educational Credit Units
            if(lsteducreditunits!=null && lsteducreditunits.size()>0)
                    insert lsteducreditunits;
        }
    }

    global void finish(Database.BatchableContext BC){
        
    }
}