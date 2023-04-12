trigger ACAMSAccountMethodEventsTrigger on Account_method__e (after insert) {
        set<ID> iDSet = new set<ID>();
      String methodName;

  for (Account_method__e event : Trigger.New) {
        //System.debug('Record_ID__c ID: ' + event.Record_ID__c);
        if (event.Record_ID__c != null) {
            iDSet.add(event.Record_ID__c);
            methodName = event.Method_Name__c;
                    }
    }
    if(iDSet.size() > 0 && methodName == 'MemberUpdateOnUser'){
        List<User> Userlist = [
                SELECT Id, Membership_Type__c, Contact_Member_Type__c
                FROM User
                WHERE AccountId IN :iDSet
        ];
        for (User usr : Userlist) {
            usr.Membership_Type__c = usr.Contact_Member_Type__c;
        }
        try{
            update Userlist;
        }catch(Exception ex){
                           //csa fix added exception logger statement. 
            ACAMSUtil.reportException(null, null,'ACAMSAccountMethodEventsTrigger', null, ex.getMessage(), null, null);
        }
    }
    
   
}