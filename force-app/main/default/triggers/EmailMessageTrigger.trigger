/**
 * 
 * @ Description : Trigger will create new case if the old case status is closed
 * @ Created : Kumar
 * @ Date    : 1/12/2016
 * @ 
 * Modification log
 * ---------------------------------------------------
 * Date     Author      Description
 * 
 */
trigger EmailMessageTrigger on EmailMessage (after insert) {
  
   if (!String.valueOf(UserInfo.getProfileId()).contains(String.valueOf(System.Label.Data_Migration_Profile_Id))) {
        if(trigger.isAfter){
         
            if(trigger.isInsert){
               EmailMessageTriggerFunctions.createChildCase(trigger.new);    
            }
           }
      
   }
    
}