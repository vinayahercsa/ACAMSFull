global class SandboxRefresh implements SandboxPostCopy {
  global void runApexClass(SandboxContext context) {
  // unschedule the grax apex jobs
    try {
        List<CronTrigger> jobs = [SELECT id, cronjobdetail.name, State, NextFireTime
                                  FROM crontrigger 
                                  WHERE cronjobdetail.name like '%GRAX%'];
        for (CronTrigger t : jobs){
            system.abortJob(t.id);
        }
    } catch (Exception ex){
        system.debug(ex);
    }

    // Deactivate jobs & cancel any jobs in progress
      try {
          List<grax__grax_schedule_process__c> processes = [SELECT id, grax__is_running__c,
                                                            grax__status__c, grax__active__c
                                                            FROM grax__grax_schedule_process__c];
          for (grax__grax_schedule_process__c gsp : processes){
              gsp.grax__active__c = false;
              if (gsp.grax__is_running__c){
                  gsp.grax__status__c = 'Aborted';
              }
          }
          update processes;
      } catch (Exception ex){
        system.debug(ex);
      }
      list<user> adminUser = new list<user>();
      list<user> adminUserUpdate = new list<user>();
      try{
      adminUser = [select name, email, username from user where email=:'sgopathi2@acams.org.invalid' limit 10];
      for(user u : adminUser){
          u.email = 'sgopathi2@acams.org';
          u.isactive = true;
          adminUserUpdate.add(u);  
      }
      
          if(adminUserUpdate.size() > 0){
      update adminUserUpdate;
          }
      }
      catch (Exception ex){
        system.debug(ex);
      }
  }
}