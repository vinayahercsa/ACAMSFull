public class ACAMSCertAppHelper {

    public static Boolean isAssetUpdated = false;
    public static Boolean isLocaleUpdated = false;
    public static Boolean isRecertAssetUpdated = false;
    public static Boolean isCaseCreated = false;

    private static final String AUDIT = 'Advanced CAMS - Audit';
    private static final String FCI = 'Advanced CAMS - FCI';
    private static final String CAMSRM = 'Advanced CAMS - Risk Management';
    private static final String CAMS = 'CAMS';
    private static final String CGSS = 'CGSS';
    private static final String CKYCA = 'CKYCA';
    private static final String CTMA = 'CTMA';
    private static final String CAFCA = 'CAFCA';  //FSA-961/962
    private static final String CCAS  = 'CCAS';
    
    private static final String CertFCI = 'Advanced Cert';
   
    public static void UpdateAsset(List<Certification_Application__c> newCertApps, Boolean certTrigger) {
        
        List<Certification_Application__c> certAppsToUpdate = new List<Certification_Application__c>();
        Set<Id> contactIds = new Set<Id>();
        Boolean isCgss;
        Map<Certification_Application__c, Id> certAppConIDMap = new Map<Certification_Application__c, Id>();
        Map<Id, List<Asset>> conAssetsMap = new Map<Id, List<Asset>>();
        List<Asset> astLstUpdt = new List<Asset>();
        //List<Asset> astLst = new List<Asset>();
       for (Certification_Application__c certApp : newCertApps) {
            if (certApp.Asset_Pending_to_Process__c == true) {
                contactIds.add(certApp.Contact__c);
                certAppConIDMap.put(certApp, certApp.Contact__c);
                
            }
        /*    if (certApp.CGSS_Check__c == true) {
                isCgss = true;
            } else {
                isCgss = false;
            }
*/
        }

        if (!contactIds.isEmpty()) {
          /*  if (isCgss) {
                astLst = [
                        SELECT Id, Assignee__c, Paid_Cert__c, Name
                        FROM Asset
                        WHERE Assignee__c IN :contactIds
                        AND Status__c = 'Active'
                        AND CC_Product__r.Level_1__c = :ACAMSUtil.CERTIFICATION
                        AND Product_level_2__c = 'CGSS'
                        LIMIT 50
                ];
            } else {
*/        //FSA-961/962 - added product levels
               // astLst = [SELECT Id, Assignee__c, contact.Membership_Type__c, Paid_Cert__c, Name, Product_level_2__c,Product_level_3__c FROM Asset WHERE Assignee__c IN :contactIds  LIMIT 50];
           //   }
            for (Asset ast : [SELECT Id, Assignee__c, contact.Membership_Type__c, Paid_Cert__c, Name, Product_level_2__c,Product_level_3__c FROM Asset WHERE Assignee__c IN :contactIds  LIMIT 50]) {
                for (Id conId : contactIds) {
                    if (ast.Assignee__c == conId && conAssetsMap.containsKey(conId)) {
                        /*csa fix removed extra if
                         * if (conAssetsMap.containsKey(conId)) {
                            conAssetsMap.get(conId).add(ast);
                        }*/
                          conAssetsMap.get(conId).add(ast);
                    }
						else {
                            conAssetsMap.put(conId, new List<Asset>{ ast });
                        }
                    }
                }
            }
        
       if (!conAssetsMap.isEmpty() && !certAppConIDMap.isEmpty()) {
            for (Certification_Application__c certApp : certAppConIDMap.keySet()) {
                if (conAssetsMap.containsKey(certApp.Contact__c) && conAssetsMap.get(certApp.Contact__c).size() > 0) {
                     for (Asset ast : conAssetsMap.get(certApp.Contact__c)) {
                         if (certApp.Status__c == 'Started') {
                           String assetName = ast.Name;
                            String applicationType = certApp.Application_Type__c;
                            if ((applicationType == AUDIT && assetName.contains(AUDIT)) ||
                                    (applicationType == FCI && assetName.contains('CAMS - FCI')) ||
                                    (applicationType == CCAS && assetName.contains('CCAS')) ||
                                    (applicationType == CAMSRM && assetName.contains(CAMSRM)) ||
                                    (applicationType == CAMS && assetName.contains(CAMS) && !assetName.contains('Advanced')) ||
                                    (applicationType == CGSS && assetName.contains(CGSS)) ||
                                    (applicationType == CKYCA && assetName.contains(CKYCA)) ||
                                    (applicationType == CAFCA && assetName.contains(CAFCA) && ast.Product_level_3__c == 'New') ||  //FSA-961/962
                                    (applicationType == CTMA && assetName.contains(CTMA))) {
                         if (certApp.Asset__c == null) {
                                    certApp.Asset__c = ast.Id;
                                }
                                    }
                        }
                         if (certApp.Status__c == 'Under Review') {
                              String assetName = ast.Name;
                            String applicationType = certApp.Application_Type__c;
                            if ((applicationType == AUDIT && assetName.contains(AUDIT)) ||
                                    (applicationType == FCI && assetName.contains('CAMS - FCI')) ||
                                    (applicationType == CCAS && assetName.contains('CCAS')) ||
                                    (applicationType == CAMSRM && assetName.contains(CAMSRM)) ||
                                    (applicationType == CAMS && assetName.contains(CAMS) && !assetName.contains('Advanced')) ||
                                    (applicationType == CGSS && assetName.contains(CGSS)) ||
                                    (applicationType == CKYCA && assetName.contains(CKYCA)) ||
                                    (applicationType == CAFCA && assetName.contains(CAFCA)&& ast.Product_level_3__c == 'New') ||  //FSA-961/962
                                    (applicationType == CTMA && assetName.contains(CTMA))) {
                                      // if (ast.Paid_Cert__c) { ----->FSA-5297
                                    ast.Application_Received__c = true;
                                    astLstUpdt.add(ast);
                                //}
                               if (certApp.Asset__c == null) {
                                    certApp.Asset__c = ast.Id;
                                }
                            }
                         }
                         if (certApp.Status__c == 'Approved') {
                            String assetName = ast.Name;
                            String applicationType = certApp.Application_Type__c;
                            if ((applicationType == AUDIT && assetName.contains(AUDIT)) ||
                                    (applicationType == FCI && assetName.contains('CAMS - FCI')) ||
                                    (applicationType == CCAS && assetName.contains('CCAS')) ||
                                    (applicationType == CAMSRM && assetName.contains(CAMSRM)) ||
                                    (applicationType == CAMS && assetName.contains(CAMS) && !assetName.contains('Advanced')) ||
                                    (applicationType == CGSS && assetName.contains(CGSS)) ||
                                    (applicationType == CKYCA && assetName.contains(CKYCA)) ||
                                    (applicationType == CAFCA && assetName.contains(CAFCA) && ast.Product_level_3__c == 'New') ||  //FSA-961/962
                                    (applicationType == CTMA && assetName.contains(CTMA))){ 
                            
                                // if (ast.Paid_Cert__c) { ----->FSA-5297
                                     ast.Application_Received__c = true;
                                    ast.Certification_Approved_Application__c = true;
                                    ast.Application_Date__c = date.today();
                                    astLstUpdt.add(ast);
                                    certApp.Asset_Pending_to_Process__c = false;
                                //}
                                if (certApp.Asset__c == null) {
                                    certApp.Asset__c = ast.Id;
                                }
                            }
                         }
                         certAppsToUpdate.add(certApp);
                    }
                }
            }
       }
                    /*if (certApp.Status__c == 'Under Review') {
                        for (Asset ast : conAssetsMap.get(certApp.Contact__c)) {
                            String assetName = ast.Name;
                            String applicationType = certApp.Application_Type__c;
                            if ((applicationType == AUDIT && assetName.contains(AUDIT)) ||
                                    (applicationType == FCI && assetName.contains('CAMS - FCI')) ||
                                    (applicationType == CCAS && assetName.contains('CCAS')) ||
                                    (applicationType == CAMSRM && assetName.contains(CAMSRM)) ||
                                    (applicationType == CAMS && assetName.contains(CAMS) && !assetName.contains('Advanced')) ||
                                    (applicationType == CGSS && assetName.contains(CGSS)) ||
                                    (applicationType == CKYCA && assetName.contains(CKYCA)) ||
                                    (applicationType == CAFCA && assetName.contains(CAFCA)&& ast.Product_level_3__c == 'New') ||  //FSA-961/962
                                    (applicationType == CTMA && assetName.contains(CTMA))) {
                                      // if (ast.Paid_Cert__c) { ----->FSA-5297
                                    ast.Application_Received__c = true;
                                    astLstUpdt.add(ast);
                                //}
                               if (certApp.Asset__c == null) {
                                    certApp.Asset__c = ast.Id;
                                }
                            }
                        }
                    }*/
                    /*if (certApp.Status__c == 'Approved') {
                     //   certApp.Application_Approval_Date__c = System.now();
                        for (Asset ast : conAssetsMap.get(certApp.Contact__c)) {
                            String assetName = ast.Name;
                            String applicationType = certApp.Application_Type__c;
                            if ((applicationType == AUDIT && assetName.contains(AUDIT)) ||
                                    (applicationType == FCI && assetName.contains('CAMS - FCI')) ||
                                    (applicationType == CCAS && assetName.contains('CCAS')) ||
                                    (applicationType == CAMSRM && assetName.contains(CAMSRM)) ||
                                    (applicationType == CAMS && assetName.contains(CAMS) && !assetName.contains('Advanced')) ||
                                    (applicationType == CGSS && assetName.contains(CGSS)) ||
                                    (applicationType == CKYCA && assetName.contains(CKYCA)) ||
                                    (applicationType == CAFCA && assetName.contains(CAFCA) && ast.Product_level_3__c == 'New') ||  //FSA-961/962
                                    (applicationType == CTMA && assetName.contains(CTMA))){ 
                            
                                // if (ast.Paid_Cert__c) { ----->FSA-5297
                                     ast.Application_Received__c = true;
                                    ast.Certification_Approved_Application__c = true;
                                    ast.Application_Date__c = date.today();
                                    astLstUpdt.add(ast);
                                    certApp.Asset_Pending_to_Process__c = false;
                                //}
                                if (certApp.Asset__c == null) {
                                    certApp.Asset__c = ast.Id;
                                }
                            }
                        }
                    }*/
                    
   Map<Id, Asset> asstmap = new Map<Id, Asset>();
        asstmap.putAll(astLstUpdt);
        if (asstmap.size() > 0) {
            try{
                isAssetUpdated = true;
            	update asstmap.values();
            }catch(Exception ex){
                ACAMSUtil.reportException(null, null,'ACAMSCertAppHelper Method', null, ex.getMessage(), null, null);
            }
            
        }
        if (!certTrigger) {
            try{
                update certAppsToUpdate;
            }catch(Exception ex){
                ACAMSUtil.reportException(null, null,'ACAMSCertAppHelper Method', null, ex.getMessage(), null, null);
            }
            
        }
    }


  
    public static void UpdateLocaleOnContact(List<Certification_Application__c> newCertApps) {
        isLocaleUpdated = true;
        Map<Id, Certification_Application__c> maplocales = new Map<Id, Certification_Application__c>();
       
        //csa fix:directly queried.
        //List<Contact> contacts = new List<Contact>();
        for (Certification_Application__c crtt : newCertApps) {
            if (crtt.Language_Selected__c != null) {
                maplocales.put(crtt.Contact__c, crtt);
            }
        }
        List<contact> contacts=[
                SELECT Id, Locale_for_PearsonVUE__c
                FROM Contact
                WHERE Id IN :maplocales.keySet()
        ];
       /* csa fix
        * contacts = [
                SELECT Id, Locale_for_PearsonVUE__c
                FROM Contact
                WHERE Id IN :maplocales.keySet()
        ];*/
        for (Certification_Application__c crt : maplocales.values()) {
            for (Contact c : contacts) {
                if (crt.Language_Selected__c != null) {
                    if (crt.Language_Selected__c == 'German') {
                        c.Locale_for_PearsonVUE__c = 'de-DE';
                    } else if (crt.Language_Selected__c == 'English') {
                        c.Locale_for_PearsonVUE__c = 'en-US';
                    } else if (crt.Language_Selected__c == 'Spanish') {
                        c.Locale_for_PearsonVUE__c = 'es-US';
                    } else if (crt.Language_Selected__c == 'French') {
                        c.Locale_for_PearsonVUE__c = 'fr-FR';
                    } else if (crt.Language_Selected__c == 'Portuguese') {
                        c.Locale_for_PearsonVUE__c = 'pt-BR';
                    } else if (crt.Language_Selected__c == 'Japanese') {
                        c.Locale_for_PearsonVUE__c = 'ja-JP';
                    } else if (crt.Language_Selected__c == 'Simplified Chinese') {
                        c.Locale_for_PearsonVUE__c = 'zh-CN';
                    } else if (crt.Language_Selected__c == 'Traditional Chinese') {
                        c.Locale_for_PearsonVUE__c = 'zh-TW';
                    }
                }
            }
        }
        if (Test.isRunningTest()) {
            try{
                update contacts;
            }catch(Exception ex){
                ACAMSUtil.reportException(null, null,'UpdateLocaleOnContact Method', null, ex.getMessage(), null, null);
            }
        } else if (!System.isFuture() && !contacts.isEmpty() && !system.isBatch()) {
            System.enqueueJob(new ACAMSUtil.UpdateObject(contacts));
        }
    }

    public static void UpdateAsset(List<Recertification_Application__c> newCertApps, Boolean recertTrigger) {
        List<Recertification_Application__c> recertAppsToUpdate = new List<Recertification_Application__c>();
        //csa fix never used this list
        //List<Asset> newList = new List<Asset>();
        Map<Id, Asset> oldMap = new Map<Id,Asset>();
        Set<Id> contactIds = new Set<Id>();
       //csa fix never used
       //  Boolean isCgss;
        Map<Recertification_Application__c, Id> certAppConIDMap = new Map<Recertification_Application__c, Id>();
        Map<Id, List<Asset>> conAssetsMap = new Map<Id, List<Asset>>();
        List<Asset> astLstUpdt = new List<Asset>();
       //csa fix never used this list
       //  List<Asset> astLst = new List<Asset>();
        Map<ID,List<Recertification_Application__c>> reCertAppsByAssetID = new Map<ID,List<Recertification_Application__c>>();
        Set<ID> newlyAllocatedAssets = new Set<ID>();

        for (Recertification_Application__c certApp : newCertApps) {
            if (certApp.Asset_Pending_to_Process__c == true) {
                contactIds.add(certApp.Contact__c);
                certAppConIDMap.put(certApp, certApp.Contact__c);
            }
        }

        if (!contactIds.isEmpty()) {
            for (Asset ast : [
                    SELECT Id, Name, Assignee__c, Paid_Cert__c,CurrentExpirationDate__c,Effective_Date__c,Recert__c, (Select ID FROM Recertification_Applications__r),
                    Assignee__r.CAFCA_Expiration_Date__c,Assignee__r.CAMS_Expiration_Date__c,CC_Product__r.Level_2__c,Product_level_2__c,Product_level_3__c //FSA-961/962: added fields to query
                    
                    FROM Asset
                    WHERE Assignee__c IN :contactIds
                    AND Status__c = 'Active'
                    AND CurrentExpirationDate__c = null // FSA-424 Not related to this particular bug but is in the request to be added
                    AND CC_Product__r.Level_1__c = :ACAMSUtil.CERTIFICATION
                    AND Product_Level_3__c = 'Recertification'
                    LIMIT 50
            ]) {
                for (Id conId : contactIds) {
                    // FSA-424 
                    if(ast.Recertification_Applications__r==null || ast.Recertification_Applications__r.size()<=0){
                        reCertAppsByAssetID.put(ast.id, null);  
                    }else {
                        reCertAppsByAssetID.put(ast.id, ast.Recertification_Applications__r);
                    }
                    if (ast.Assignee__c == conId) {
                        if (conAssetsMap.containsKey(conId)) {
                            conAssetsMap.get(conId).add(ast);
                        } else {
                            conAssetsMap.put(conId, new List<Asset>{
                                    ast
                            });
                        }
                    }
                }
            }
        }
        if (!conAssetsMap.isEmpty() && !certAppConIDMap.isEmpty()) {
            for (Recertification_Application__c certApp : certAppConIDMap.keySet()) {
                if (conAssetsMap.containsKey(certApp.Contact__c) && conAssetsMap.get(certApp.Contact__c).size() > 0) {
                    for (Asset ast : conAssetsMap.get(certApp.Contact__c)) {
                    	if (certApp.Status__c == 'Started') {
                            String assetName = ast.Name;
                            String applicationType = certApp.Application_Type__c;
                            if ((applicationType == 'Advanced CAMS - Audit' && assetName.contains(AUDIT)) ||
                                    (applicationType == 'Advanced CAMS - FCI' && assetName.contains('CAMS - FCI')) ||
                                    (applicationType == 'Advanced CAMS - Risk Management' && assetName.contains(CAMSRM)) ||
                                    (applicationType == 'CAMS' && assetName.contains('CAMS')) ||
                                     (applicationType == 'CCAS' && assetName.contains('CCAS'))||
                                    (applicationType == 'CGSS' && assetName.contains('CGSS')) ||
                                    (applicationType == 'CKYCA' && assetName.contains('CKYCA')) ||
                                    (applicationType == CAFCA && assetName.contains(CAFCA) && ast.Product_level_3__c == 'Recertification') ||  //FSA-961/962
                                    (applicationType == CTMA && assetName.contains(CTMA))) {
                                   if (certApp.Asset__c == null && reCertAppsByAssetID.get(ast.Id)==null && !newlyAllocatedAssets.contains(ast.Id)) {
                                    certApp.Asset__c = ast.Id;
                                    newlyAllocatedAssets.add(ast.Id);
                                }
                                    }
                           }
                        if (certApp.Status__c == 'Under Review') {  
                        String assetName = ast.Name;
                            String applicationType = certApp.Application_Type__c;
                            if ((applicationType == 'Advanced CAMS - Audit' && assetName.contains(AUDIT)) ||
                                    (applicationType == 'Advanced CAMS - FCI' && assetName.contains('CAMS - FCI')) ||
                                    (applicationType == 'Advanced CAMS - Risk Management' && assetName.contains(CAMSRM)) ||
                                    (applicationType == 'CAMS' && assetName.contains('CAMS')) ||
                                     (applicationType == 'CCAS' && assetName.contains('CCAS'))||
                                    (applicationType == 'CGSS' && assetName.contains('CGSS')) ||
                                    (applicationType == 'CKYCA' && assetName.contains('CKYCA')) ||
                                    (applicationType == CAFCA && assetName.contains(CAFCA) && ast.Product_level_3__c == 'Recertification') ||  //FSA-961/962
                                    (applicationType == CTMA && assetName.contains(CTMA))) {
                                if (ast.Paid_Cert__c) {
                                   ast.Application_Received__c = true;
                                    ast.Recert__c = true;
                                    astLstUpdt.add(ast);
                                }
                                if (certApp.Asset__c == null  && reCertAppsByAssetID.get(ast.Id)==null && !newlyAllocatedAssets.contains(ast.Id)) {
                                    certApp.Asset__c = ast.Id;
                                    newlyAllocatedAssets.add(ast.Id);
                                }
                            }
                        }
                        else if (certApp.Status__c == 'Approved') {
                            String assetName = ast.Name;
                            String applicationType = certApp.Application_Type__c;
                            if ((applicationType == 'Advanced CAMS - Audit' && assetName.contains(AUDIT)) ||
                                    (applicationType ==  'Advanced CAMS - FCI' && assetName.contains('CAMS - FCI')) ||
                                    (applicationType == 'Advanced CAMS - Risk Management' && assetName.contains(CAMSRM)) ||
                                    (applicationType == 'CAMS' && assetName.contains('CAMS')) ||
                                     (applicationType == 'CCAS' && assetName.contains('CCAS'))||
                                    (applicationType == 'CGSS' && assetName.contains('CGSS')) ||
                                    (applicationType == 'CKYCA' && assetName.contains('CKYCA')) ||
                                    (applicationType == CAFCA && assetName.contains(CAFCA) && ast.Product_level_3__c == 'Recertification') ||  //FSA-961/962
                                (applicationType == CTMA && assetName.contains(CTMA))){
                                    
                                if (ast.Paid_Cert__c) {
                                  ast.Application_Received__c = true;
                                  ast.Recert__c = true;
                                  ast.Certification_Approved_Application__c = true;
                                  ast.Application_Date__c = date.today();
                                     
                                  /*  //FSA-961/962
                                    ast.Effective_Date__c = date.today();
                                    if(ast.Assignee__r.CAFCA_Expiration_Date__c != null) {
                                      ast.CurrentExpirationDate__c = (ast.Assignee__r.CAFCA_Expiration_Date__c).addYears(3);
                                    }*/
                                    
                                   
                                    astLstUpdt.add(ast);
                                    certApp.Asset_Pending_to_Process__c = false;
                                }
                               if (certApp.Asset__c == null  && reCertAppsByAssetID.get(ast.Id)==null && !newlyAllocatedAssets.contains(ast.Id)) {
                                    certApp.Asset__c = ast.Id;
                                    newlyAllocatedAssets.add(ast.Id);
                                }
                            }
                        }
                        recertAppsToUpdate.add(certApp);
                     }
                }
            }
        }
                    /*if (certApp.Status__c == 'Under Review') {  
                      for (Asset ast : conAssetsMap.get(certApp.Contact__c)) {
                            String assetName = ast.Name;
                            String applicationType = certApp.Application_Type__c;
                            if ((applicationType == 'Advanced CAMS - Audit' && assetName.contains(AUDIT)) ||
                                    (applicationType == 'Advanced CAMS - FCI' && assetName.contains('CAMS - FCI')) ||
                                    (applicationType == 'Advanced CAMS - Risk Management' && assetName.contains(CAMSRM)) ||
                                    (applicationType == 'CAMS' && assetName.contains('CAMS')) ||
                                     (applicationType == 'CCAS' && assetName.contains('CCAS'))||
                                    (applicationType == 'CGSS' && assetName.contains('CGSS')) ||
                                    (applicationType == 'CKYCA' && assetName.contains('CKYCA')) ||
                                    (applicationType == CAFCA && assetName.contains(CAFCA) && ast.Product_level_3__c == 'Recertification') ||  //FSA-961/962
                                    (applicationType == CTMA && assetName.contains(CTMA))) {
                                if (ast.Paid_Cert__c) {
                                   ast.Application_Received__c = true;
                                    ast.Recert__c = true;
                                    astLstUpdt.add(ast);
                                }
                                if (certApp.Asset__c == null  && reCertAppsByAssetID.get(ast.Id)==null && !newlyAllocatedAssets.contains(ast.Id)) {
                                    certApp.Asset__c = ast.Id;
                                    newlyAllocatedAssets.add(ast.Id);
                                }
                            }
                        }
                    } else if (certApp.Status__c == 'Approved') {
                        // certApp.Application_Approval_Date__c = System.now();
                        for (Asset ast : conAssetsMap.get(certApp.Contact__c)) {
                             
                            String assetName = ast.Name;
                            String applicationType = certApp.Application_Type__c;
                            if ((applicationType == 'Advanced CAMS - Audit' && assetName.contains(AUDIT)) ||
                                    (applicationType ==  'Advanced CAMS - FCI' && assetName.contains('CAMS - FCI')) ||
                                    (applicationType == 'Advanced CAMS - Risk Management' && assetName.contains(CAMSRM)) ||
                                    (applicationType == 'CAMS' && assetName.contains('CAMS')) ||
                                     (applicationType == 'CCAS' && assetName.contains('CCAS'))||
                                    (applicationType == 'CGSS' && assetName.contains('CGSS')) ||
                                    (applicationType == 'CKYCA' && assetName.contains('CKYCA')) ||
                                    (applicationType == CAFCA && assetName.contains(CAFCA) && ast.Product_level_3__c == 'Recertification') ||  //FSA-961/962
                                (applicationType == CTMA && assetName.contains(CTMA))){
                                    
                                if (ast.Paid_Cert__c) {
                                  ast.Application_Received__c = true;
                                  ast.Recert__c = true;
                                  ast.Certification_Approved_Application__c = true;
                                  ast.Application_Date__c = date.today();
                                     
                                  /*  //FSA-961/962
                                    ast.Effective_Date__c = date.today();
                                    if(ast.Assignee__r.CAFCA_Expiration_Date__c != null) {
                                      ast.CurrentExpirationDate__c = (ast.Assignee__r.CAFCA_Expiration_Date__c).addYears(3);
                                    }*/
                                    
                                   
                                    /*astLstUpdt.add(ast);
                                    certApp.Asset_Pending_to_Process__c = false;
                                }
                               if (certApp.Asset__c == null  && reCertAppsByAssetID.get(ast.Id)==null && !newlyAllocatedAssets.contains(ast.Id)) {
                                    certApp.Asset__c = ast.Id;
                                    newlyAllocatedAssets.add(ast.Id);
                                }
                            }
                        }*/
           
        Map<Id, Asset> asstmap = new Map<Id, Asset>();
        asstmap.putAll(astLstUpdt);
        if (asstmap.size() > 0) {
            try{
                isRecertAssetUpdated = true;
                update asstmap.values();
            }catch(Exception ex){
                ACAMSUtil.reportException(null, null,'UpdateAsset Method', null, ex.getMessage(), null, null);
            }
        }
        if (!recertTrigger) {
            try{
                update recertAppsToUpdate;
            }catch(Exception ex){
                ACAMSUtil.reportException(null, null,'UpdateAsset Method', null, ex.getMessage(), null, null);
            }
        }
    }

    public static void CreateCase_CertApp(Set<Id> newCertApps,Map<Id, Certification_Application__c> newMap,Map<Id, Certification_Application__c> oldMap) {
        isCaseCreated = true;
        Set<String> AsiaCountryCollection = new Set<String>{
                'AM', 'AZ', 'BT', 'BN', 'BU', 'KH', 'CN', 'TL', 'HK', 'IN', 'ID', 'JP', 'LA', 'MO', 'MY', 'FM', 'MN',
                'MM', 'NP', 'PG', 'KP', 'PH', 'TW', 'SG', 'KR', 'LK', 'TH', 'VN'
        };

        List<SObject> Standard = [SELECT Id FROM Group WHERE Name = 'Certification Queue' AND Type = 'Queue'];
        List<SObject> Asia = [SELECT Id FROM Group WHERE Name = 'APAC Certifications' AND Type = 'Queue'];
        List<Certification_Application__c> crtapps = new List<Certification_Application__c>([
                SELECT Id, Case__c, Contact__c, Contact__r.MailingCountry, Name, Status__c
                FROM Certification_Application__c
                WHERE Id IN :newCertApps
        ]);
        for (Certification_Application__c cta : crtapps) {
            if (cta.Status__c == 'Under Review' && oldMap.get(cta.id).Status__c != 'Under Review') {
                if (Standard != null && Standard.size() > 0) {
                    Case cse = new Case();
                    if (cta.Contact__r.MailingCountry != null &&
                            AsiaCountryCollection.contains(cta.Contact__r.MailingCountry.trim().toUpperCase())) {
                        cta.Comments__c = 'Contact country was ' + cta.Contact__r.MailingCountry +
                                ', which is in Asia. \n Case assigned to the Asia Queue.';
                        cse.OwnerId = Asia[0].Id;
                    } else {
                        cta.Comments__c = 'Contact country ' + cta.Contact__r.MailingCountry +
                                ' is NOT in Asia. \n Case assigned to the Standard Queue.';
                        cse.OwnerId = Standard[0].Id;
                    }
                    cse.Type = 'Certifications';
                    cse.Secondary_Case_Type__c = 'Certification Application';
                    cse.Origin = 'Online Application';
                    cse.ContactId = cta.Contact__c;
                    cse.Subject = 'Web Certification Application - ' + cta.Name;
                    insert cse;
                    cta.Case__c = cse.Id;
                }
            }
        }
        try{
            update crtapps;
        }catch(Exception ex){
            ACAMSUtil.reportException(null, null,'CreateCase_CertApp Method', null, ex.getMessage(), null, null);
        }
    }

    public static void CreateCase_RecertApp(Set<Id> newCertApps, Map<Id, Recertification_Application__c> newMap, Map<Id, Recertification_Application__c> oldMap) {
        isCaseCreated = true;
        Set<String> AsiaCountryCollection = new Set<String>{
                'AM', 'AZ', 'BT', 'BN', 'BU', 'KH', 'CN', 'TL', 'HK', 'IN', 'ID', 'JP', 'LA', 'MO', 'MY', 'FM', 'MN',
                'MM', 'NP', 'PG', 'KP', 'PH', 'TW', 'SG', 'KR', 'LK', 'TH', 'VN'
        };
        List<SObject> Standard = [SELECT Id FROM Group WHERE Name = 'Certification Queue' AND Type = 'Queue'];
        List<SObject> Asia = [SELECT Id FROM Group WHERE Name = 'APAC Certifications' AND Type = 'Queue'];
        List<Recertification_Application__c> rcrtapps = new List<Recertification_Application__c>([
                SELECT Id, Case__c, Contact__c, Contact__r.Account.BillingCountry, Name, Status__c
                FROM Recertification_Application__c
                WHERE Id IN :newCertApps
        ]);
//csa fix adding case records in list instead of inserting into for 
        List<Case> caseList = new List<Case>();

        for (Recertification_Application__c cta : rcrtapps) {
             if (cta.Status__c == 'Under Review' && oldMap.get(cta.id).Status__c != 'Under Review') {
                if (Standard != null && Standard.size() > 0) {
                    Case cse = new Case();
                    if (cta.Contact__r.Account.BillingCountry != null &&
                            AsiaCountryCollection.contains(cta.Contact__r.Account.BillingCountry.trim().toUpperCase())) {
                        cta.Comments__c = 'Contact country was ' + cta.Contact__r.Account.BillingCountry +
                                ', which is in Asia. \n Case assigned to the Asia Queue.';
                        cse.OwnerId = Asia[0].Id;
                    } else {
                        cta.Comments__c = 'Contact country ' + cta.Contact__r.Account.BillingCountry +
                                ' is NOT in Asia. \n Case assigned to the Standard Queue.';
                        cse.OwnerId = Standard[0].Id;
                    }
                    cse.Type = 'Certifications';
                    cse.Secondary_Case_Type__c = 'Recertification Application';
                    cse.Origin = 'Online Application';
                    cse.ContactId = cta.Contact__c;
                    cse.Subject = 'Web Recertification Application - ' + cta.Name;
                   //csa fix added case into list
                    //insert cse;
                                caseList.add(cse);

                    cta.Case__c = cse.Id;
                }
            }
        }
        //csa fix inserting case outside for
        if (!caseList.isEmpty()) {
            try{
            	insert caseList;
            }catch(Exception ex){
                ACAMSUtil.reportException(null, null,'CreateCase_RecertApp Method', null, ex.getMessage(), null, null);
            }
            
        }
            try{
                update rcrtapps;
            }catch(Exception ex){
                ACAMSUtil.reportException(null, null,'CreateCase_RecertApp Method', null, ex.getMessage(), null, null);
            }
       
    }

    public static void setLanguage(Set<Id> accountIds, List<Certification_Application__c> certApps) {
        Map<Id, String> idToLanguageMap = new Map<Id, String>();
        for (Account account : [
                SELECT Id, Language_Preference__c
                FROM Account
                WHERE Id IN :accountIds
        ]) {
            idToLanguageMap.put(account.Id, account.Language_Preference__c);
        }
        for (Certification_Application__c certApp : certApps) {
            certApp.Language_Selected__c = ACAMSUtil.getLanguageByCode(idToLanguageMap.get(certApp.AccountId__c));
        }
    }
     public static void testCoverage() {
     }
}