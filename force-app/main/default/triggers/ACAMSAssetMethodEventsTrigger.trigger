trigger ACAMSAssetMethodEventsTrigger on Asset_Method__e (after insert) {
    Static Integer counter = 0; //CSA-fix
    Static Integer BATCHSIZE = 100; //CSA-fix
    list<Recertification_Application__c> lstRec = new list<Recertification_Application__c>();
    set<ID> iDSetRecert = new set<ID>();
    set<ID> iDSetMLDC = new set<ID>();
    set<ID> iDSetAssetAcc = new set<ID>();
    string mydate =string.valueOf(system.today());
    String myString = mydate.left(4);
    String methodName;
    Set<Id> mldccontactIds = new Set<Id>();
    List<MLDC_Data__c> insertMLDCRecords = new List<MLDC_Data__c>();
    Static String throttleSizeStr = ACAMS_Platform_Event_Setting__mdt.getInstance('ACAMSAssetEventMethod')?.Value__c;

    if(String.isNotBlank(throttleSizeStr))
    {
        BATCHSIZE = Integer.valueOf(throttleSizeStr);
    }

    for (Asset_Method__e event : Trigger.New) {
        System.debug('Record_ID__c ID: ' + event.Record_ID__c);
        if (event.Record_ID__c != null && event.Method_Name__c == 'recertificationApplicationUpdate') {
            iDSetRecert.add(event.Record_ID__c);
            methodName = event.Method_Name__c;
                    }
        else if(event.Record_ID__c != null && event.Method_Name__c == 'insertMLDCRecords'){
            iDSetMLDC.add(event.Record_ID__c);
            methodName = event.Method_Name__c;
        }
        else if(event.Record_ID__c != null && event.Method_Name__c == 'AssetAccountUpdate'){
            iDSetAssetAcc.add(event.Record_ID__c);
            methodName = event.Method_Name__c;
        }

        if(counter == BATCHSIZE) {
            //  Set the last executed event as the checkpoint, to continue later from the next event
            EventBus.TriggerContext.currentContext().setResumeCheckpoint(event.ReplayId);
            break;
        } 
    }
    if(iDSetRecert.size() > 0){
        for(Recertification_Application__c  recAP : [select id,Asset__c,Status__c,Recertification_Year__c from Recertification_Application__c where Asset__c IN: iDSetRecert]){
                If(recAP.Status__c == 'Started' && recAP.Recertification_Year__c == null){
                    recAP.Status__c = 'Approved';
                    recAP.Recertification_Year__c = myString;
                    lstRec.add(recAP);
                }
            }
            //CSA-fix to implement retry mechanism
            try{
                database.update(lstRec);
            }catch (Exception e) {
                // Only retry so many times, before giving up (thus avoid disabling the trigger)
                //Keeping retries times to 3, after the retries count go past 3, it should throw exceptiuon
                if (EventBus.TriggerContext.currentContext().retries < 4) {
                    throw new EventBus.RetryableException(e.getMessage());
                }
                else
                 ACAMSUtil.reportException(null, null,'Asset Platform Event Failed ', null, e.getMessage(), null, null);

            }
            
    }
    else if(iDSetMLDC.size() > 0){
         List<MLDC_Data__c> MLDCRecords = [select id, Contact__c, Name, Content_Alerts__c, Weekly_Newsletter__c from MLDC_Data__c where Contact__c IN: iDSetMLDC];
        if(!MLDCRecords.isEmpty()){
            for(MLDC_Data__c mldc : MLDCRecords){
                if(!iDSetMLDC.contains(mldc.Contact__c)){
                    mldccontactIds.add(mldc.Contact__c);
                    system.debug('mldccontactIds '+mldccontactIds);
                }
            }
        }else{
            mldccontactIds.addAll(iDSetMLDC);
        }
       if(!mldccontactIds.isEmpty()){
            for(Id ids : mldccontactIds){
                MLDC_Data__c mldcRecord = new MLDC_Data__c();
                mldcRecord.Contact__c = ids;
                mldcRecord.Content_Alerts__c = true;
                mldcRecord.Weekly_Newsletter__c = true;
                insertMLDCRecords.add(mldcRecord);
                system.debug('insertMLDCRecords '+insertMLDCRecords);
            }
        }
        if(!insertMLDCRecords.isEmpty()){
            system.debug('insertMLDCRecords 11 '+insertMLDCRecords);
             //CSA-fix to implement retry mechanism
            try{
                Database.insert(insertMLDCRecords);
            }catch (Exception e) {
                // Only retry so many times, before giving up (thus avoid disabling the trigger)
                //Keeping retries times to 3, after the retries count go past 3, it should throw exceptiuon
                if (EventBus.TriggerContext.currentContext().retries < 4) {
                    throw new EventBus.RetryableException(e.getMessage());
                }
                else
                 ACAMSUtil.reportException(null, null,'Asset Platform Event Failed ', null, e.getMessage(), null, null);

            }
            
        } 
    }
    else if(iDSetAssetAcc.size() > 0){
       
            list<account> acc = [SELECT id,Registration_Application_Submitted__c from Account WHERE Id IN: iDSetAssetAcc];
            for(Account a: acc){
                a.Registration_Application_Submitted__c = true;
            }
             //CSA-fix to implement retry mechanism
            try{
                Database.update(acc);
            }catch (Exception e) {
                // Only retry so many times, before giving up (thus avoid disabling the trigger)
                //Keeping retries times to 3, after the retries count go past 3, it should throw exceptiuon
                if (EventBus.TriggerContext.currentContext().retries < 4) {
                    throw new EventBus.RetryableException(e.getMessage());
                }
                else
                 ACAMSUtil.reportException(null, null,'Asset Platform Event Failed ', null, e.getMessage(), null, null);

            }
            
        
    }
}