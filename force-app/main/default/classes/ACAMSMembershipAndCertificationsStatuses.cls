public with sharing class ACAMSMembershipAndCertificationsStatuses {
    public static String chapterMembership = ACAMSUtil.CHAPTER + ' ' + ACAMSUtil.MEMBERSHIP;
    public static String acamsTodayPrintedSubscription = ACAMSUtil.ACAMS_TODAY;
    public static Boolean clearfields = false;
    
    public static final String[] assetType = new String[]{ACAMSUtil.MEMBERSHIP, chapterMembership, acamsTodayPrintedSubscription, ACAMSUtil.MONEYLAUNDERINGDOTCOM, 'CAMS Certification',
        'CAMS - Audit', 'FCI','CAMS - Risk Management', 'Regime Exam', 'CGSS Certification', 'CKYCA Certification',
        'CTMA Certification', 'CAFCA Certification'};
            
            public static void updateMemsAndCertsStatuses(List<Asset> newList){
                Set<Id> contactIds = new Set<Id>();
                for (Asset asset : newList) {
                    if (asset.Assignee__c != null && !isMasterAsset(asset)){ /*&& (oldMap == null ||
oldMap.get(asset.Id).Status__c != asset.Status__c ||
oldMap.get(asset.Id).CurrentExpirationDate__c != asset.CurrentExpirationDate__c ||
oldMap.get(asset.Id).Effective_Date__c != asset.Effective_Date__c ||
oldMap.get(asset.Id).Assignee__c != asset.Assignee__c)) */ // FSA-557 document states whenever any Asset is created or updated, no other criteria
                        {
                            contactIds.add(asset.Assignee__c);
                            System.debug('contactIds  to update :: '+contactIds);
                        }
                    }
                }
                updateMemsAndCertsStatusesByContact(contactIds, true);
            }
    //This method will be reusable when the new field created from FSA-585 is updated on the Contact.    
    //csa fix:adding this method as future method to resolve of SOQL 101 issue.
    @future
    public static void updateMemsAndCertsStatusesByContact(Set<ID> contactIds, Boolean performDML){
        if(!clearfields){
        clearMemCertFields(contactIds);//FSA-6834
        }
        Map<Id, Contact> contactsToUpdateMap = new Map<Id, Contact>();
        if (!contactIds.isEmpty()) {
            Map<Id, List<Asset>> mapContactWithMembershipAssets = new Map<Id, List<Asset>>();
            Map<Id, List<Asset>> mapContactWithChapterMembershipAssets = new Map<Id, List<Asset>>();
            Map<Id, List<Asset>> mapContactWithACAMSTodayAssets = new Map<Id, List<Asset>>();
            Map<Id, List<Asset>> mapContactWithMLDCAssets = new Map<Id, List<Asset>>();
            Map<Id, List<Asset>> mapContactWithCAMSAssets = new Map<Id, List<Asset>>();
            Map<Id, List<Asset>> mapContactWithCGSSAssets = new Map<Id, List<Asset>>();
            Map<Id, List<Asset>> mapContactWithCCASAssets = new Map<Id, List<Asset>>(); 
            Map<Id, List<Asset>> mapContactWithCAMSRMAssets = new Map<Id, List<Asset>>();
            Map<Id, List<Asset>> mapContactWithRegimeAssets = new Map<Id, List<Asset>>();
            Map<Id, List<Asset>> mapContactWithCAMSFCIAssets = new Map<Id, List<Asset>>();
            Map<Id, List<Asset>> mapContactWithCAMSAuditAssets = new Map<Id, List<Asset>>();
            Map<Id, List<Asset>> mapContactWithCKYCAAssets = new Map<Id, List<Asset>>();
            Map<Id, List<Asset>> mapContactWithCTMAAssets = new Map<Id, List<Asset>>();
            Map<Id, List<Asset>> mapContactWithPWSAssets = new Map<Id, List<Asset>>();
            // FSA-242
            Map<Id, List<Asset>> mapContactWithCAFCAAssets = new Map<Id, List<Asset>>();
            // FSA-242 , CAFCA
            // FSA-1955 Added Cancel Date field
            for (Asset asset : [
                SELECT Id, Name, Effective_Date__c, CurrentExpirationDate__c, Status__c, Assignee__c, CC_Product__c, CC_Product__r.ccrz__SKU__c,InstallDate,
                CC_Product__r.Level_1__c, CC_Product__r.Level_2__c, CC_Product__r.Level_3__c, CC_Product__r.Name,Exam_Pass_Date__c,CancelDate__c,Contact.Original_Membership_Join_Date__c,ContactId
                FROM  Asset
                WHERE Assignee__c IN :contactIds
                AND CancelDate__c = NULL
                AND CurrentExpirationDate__c <> NULL
            ]) {
                String assetType = assetToType(asset);
                system.debug('assetType::'+assetType);
                system.debug('asset.Assignee__c::'+asset.Assignee__c);
                if(assetType==null){
                    System.debug('Could not map to any defined Asset type criteria of FSA-557 requirement document');
                    continue;
                }
                if (assetType == ACAMSUtil.MEMBERSHIP && mapContactWithMembershipAssets.get(asset.Assignee__c) == null) {
                    mapContactWithMembershipAssets.put(asset.Assignee__c, new List<Asset>{asset});
                    if(asset.CC_Product__r.ccrz__SKU__c  == 'XMEMAT'){
                        assetType = acamsTodayPrintedSubscription;
                        getXEMET(assetType,asset, mapContactWithACAMSTodayAssets);
                    }
                } else if (assetType == ACAMSUtil.MEMBERSHIP) {
                    mapContactWithMembershipAssets.get(asset.Assignee__c).add(asset);
                    if(asset.CC_Product__r.ccrz__SKU__c  == 'XMEMAT'){
                        assetType = acamsTodayPrintedSubscription;
                        getXEMET(assetType,asset, mapContactWithACAMSTodayAssets);
                    }
                } else if (assetType == chapterMembership && mapContactWithChapterMembershipAssets.get(asset.Assignee__c) == null) {
                    mapContactWithChapterMembershipAssets.put(asset.Assignee__c, new List<Asset>{asset});
                } else if (assetType == chapterMembership) {
                    mapContactWithChapterMembershipAssets.get(asset.Assignee__c).add(asset);
                } else if (assetType == acamsTodayPrintedSubscription && mapContactWithACAMSTodayAssets.get(asset.Assignee__c) == null) {
                    mapContactWithACAMSTodayAssets.put(asset.Assignee__c, new List<Asset>{ asset });
                } else if (assetType == acamsTodayPrintedSubscription) {
                    mapContactWithACAMSTodayAssets.get(asset.Assignee__c).add(asset);
                } else if (assetType == ACAMSUtil.MONEYLAUNDERINGDOTCOM && mapContactWithMLDCAssets.get(asset.Assignee__c) == null) {
                    mapContactWithMLDCAssets.put(asset.Assignee__c, new List<Asset>{ asset });
                } else if (assetType == ACAMSUtil.MONEYLAUNDERINGDOTCOM) {
                    mapContactWithMLDCAssets.get(asset.Assignee__c).add(asset);
                } else if (assetType == ('CAMS Certification') && mapContactWithCAMSAssets.get(asset.Assignee__c) == null) {
                    mapContactWithCAMSAssets.put(asset.Assignee__c, new List<Asset>{ asset });
                } else if (assetType == ('CAMS Certification')) {
                    mapContactWithCAMSAssets.get(asset.Assignee__c).add(asset);
                } else if (assetType == ('CAMS - Audit') && mapContactWithCAMSAuditAssets.get(asset.Assignee__c) == null) {
                    mapContactWithCAMSAuditAssets.put(asset.Assignee__c, new List<Asset>{ asset });
                } else if (assetType == ('CAMS - Audit')) {
                    mapContactWithCAMSAuditAssets.get(asset.Assignee__c).add(asset);
                } else if (assetType == ('FCI') && mapContactWithCAMSFCIAssets.get(asset.Assignee__c) == null) {
                    mapContactWithCAMSFCIAssets.put(asset.Assignee__c, new List<Asset>{ asset });
                } else if (assetType == ('FCI')) {
                    mapContactWithCAMSFCIAssets.get(asset.Assignee__c).add(asset);
                } else if (assetType == ('CAMS - Risk Management') && mapContactWithCAMSRMAssets.get(asset.Assignee__c) == null) {
                    mapContactWithCAMSRMAssets.put(asset.Assignee__c, new List<Asset>{ asset });
                } else if (assetType == ('CAMS - Risk Management')) {
                    mapContactWithCAMSRMAssets.get(asset.Assignee__c).add(asset);
                } else if (assetType == (ACAMSUtil.REGIME_EXAM) && mapContactWithRegimeAssets.get(asset.Assignee__c) == null) {
                    mapContactWithRegimeAssets.put(asset.Assignee__c, new List<Asset>{ asset });
                } else if (assetType == (ACAMSUtil.REGIME_EXAM)) {
                    mapContactWithRegimeAssets.get(asset.Assignee__c).add(asset);
                } else if (assetType == ('CGSS Certification') && mapContactWithCGSSAssets.get(asset.Assignee__c) == null) {
                    mapContactWithCGSSAssets.put(asset.Assignee__c, new List<Asset> { asset });
                } else if (assetType == ('CGSS Certification')) {
                    mapContactWithCGSSAssets.get(asset.Assignee__c).add(asset);
                }  else if (assetType == ('CCAS Certification') && mapContactWithCCASAssets.get(asset.Assignee__c) == null) {
                    mapContactWithCCASAssets.put(asset.Assignee__c, new List<Asset> { asset });
                } else if (assetType == ('CCAS Certification')) {
                    mapContactWithCCASAssets.get(asset.Assignee__c).add(asset);
                } else if (assetType == ('CTMA Certification') && mapContactWithCTMAAssets.get(asset.Assignee__c) == null) {
                    mapContactWithCTMAAssets.put(asset.Assignee__c, new List<Asset>{ asset });
                } else if (assetType == ('CTMA Certification')) {
                    mapContactWithCTMAAssets.get(asset.Assignee__c).add(asset);
                } else if (assetType == ('CKYCA Certification') && mapContactWithCKYCAAssets.get(asset.Assignee__c) == null) {
                    mapContactWithCKYCAAssets.put(asset.Assignee__c, new List<Asset>{ asset });
                } else if (assetType == ('CKYCA Certification')) {
                    mapContactWithCKYCAAssets.get(asset.Assignee__c).add(asset);
                } else if (assetType == ('Premium Webinar Subscriber') && mapContactWithPWSAssets.get(asset.Assignee__c) == null) {
                    mapContactWithPWSAssets.put(asset.Assignee__c, new List<Asset>{ asset });
                } else if (assetType == ('Premium Webinar Subscriber')) {
                    mapContactWithPWSAssets.get(asset.Assignee__c).add(asset);
                }
                // FSA-242 , CAFCA
                else if (assetType == ('CAFCA Certification') && mapContactWithCAFCAAssets.get(asset.Assignee__c) == null) {
                    
                    mapContactWithCAFCAAssets.put(asset.Assignee__c, new List<Asset>{
                        asset
                            });
                    system.debug('Cafca called1'+mapContactWithCAFCAAssets);
                } 
                else if (assetType == ('CAFCA Certification')) {
                    
                    mapContactWithCAFCAAssets.get(asset.Assignee__c).add(asset);
                    system.debug('Cafca called2'+mapContactWithCAFCAAssets);
                }
                //FSA-557:: SAkella : commented as CTMA not mentioned in document
                /* else if (assetType == ('CTMA Certification') && mapContactWithCTMAAssets.get(asset.Assignee__c) == null) {  
mapContactWithCTMAAssets.put(asset.Assignee__c, new List<Asset> {  
asset  
});  
} else if (assetType == ('CTMA Certification')) {  
mapContactWithCTMAAssets.get(asset.Assignee__c).add(asset);
} */
            }
            
            for (Id contactId : contactIds) {
                if (mapContactWithMembershipAssets.get(contactId) == null || mapContactWithMembershipAssets.get(contactId).isEmpty()) {
                    Contact contact = new Contact(
                        Id = contactId,
                        ACAMS_Member__c = false,
                        // Member_Expire_Date__c = null,
                        Membership_Type__c = ACAMSUtil.NON_MEMBER_CAPS
                        // Original_Membership_Join_Date__c = null 
                    );
                    contactsToUpdateMap.put(contactId, contact);
                } else {
                    Date highestExpireDate;
                    Date firstMembershipDate;
                    String membershipType = ACAMSUtil.NON_MEMBER_CAPS;
                    for (Asset asset : mapContactWithMembershipAssets.get(contactId)) {  
                        if (highestExpireDate == null) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        } else if (highestExpireDate < asset.CurrentExpirationDate__c) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        }
                        
                        //   firstMembershipDate = asset.InstallDate; //FSA-557 commenented for FSA- 1955 related change
                        firstMembershipDate = asset.Effective_Date__c; //1955
                        system.debug('------membershipType--1------'+membershipType);
                        system.debug('------highestExpireDate------'+highestExpireDate);
                        if (highestExpireDate >= Date.today() ) { //FSA-557
                            system.debug('------membershipType--2------'+membershipType);
                            if(membershipType != ACAMSUtil.ENTERPRISE_CAPS && asset.Status__c == 'Active'){ //FSA-1438 , chandra 
                                system.debug('------membershipType--3------'+membershipType);
                                membershipType = asset.CC_Product__r.Level_1__c == ACAMSUtil.MEMBERSHIP ? ACAMSUtil.MEMBER_CAPS : ACAMSUtil.ENTERPRISE_CAPS;
                                system.debug('------membershipType--4------'+membershipType);
                            }
                        }
                        //FSA-1955 related change start
                        list<Asset> lstAst = [select id,Effective_Date__c,contactId,CancelDate__c,CC_Product__r.Level_1__c,AccountId from Asset where contactId =:contactId AND (Asset.CC_Product__r.Level_1__c = 'Membership' OR Asset.CC_Product__r.Level_1__c ='Enterprise Bundle') ORDER BY Effective_Date__c asc LIMIT 1];
                        system.debug('lstAst1--->'+lstAst);
                        for(Asset ast:lstAst){
                            if(ast.CancelDate__c == null && ast.Effective_Date__c != null){                     
                                firstMembershipDate = ast.Effective_Date__c;                                       
                            }     
                            
                            /*  else if(ast.CancelDate__c != null){
system.debug('ast.CancelDate__c11--->'+ast.CancelDate__c);
firstMembershipDate = null;
system.debug('firstMembershipDate of Cancel--->'+firstMembershipDate);
} */
                        }      
                        
                        //FSA-1955 related change end
                    }
                    Contact contact = new Contact(
                        Id = contactId,
                        ACAMS_Member__c = true,
                        Member_Expire_Date__c = highestExpireDate,
                        Membership_Type__c = membershipType,
                        Original_Membership_Join_Date__c = firstMembershipDate  
                    );
                    contactsToUpdateMap.put(contactId, contact);
                }
                
                
                if (mapContactWithChapterMembershipAssets.get(contactId) == null || mapContactWithChapterMembershipAssets.get(contactId).isEmpty()) {
                    Contact contact = new Contact(
                        Id = contactId,
                        Chapter_Member__c = false
                        // Chapter_Member_Expire_Date__c = null
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).Chapter_Member__c = false;
                        //  contactsToUpdateMap.get(contactId).Chapter_Member_Expire_Date__c = null;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                } else {
                    Date highestExpireDate;
                    for (Asset asset : mapContactWithChapterMembershipAssets.get(contactId)) {
                        if (highestExpireDate == null) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        } else if (highestExpireDate < asset.CurrentExpirationDate__c) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        }
                    }
                    Contact contact = new Contact(
                        Id = contactId,
                        Chapter_Member__c = contactsToUpdateMap.get(contactId).ACAMS_Member__c && highestExpireDate>=Date.today(),
                        Chapter_Member_Expire_Date__c = highestExpireDate
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).Chapter_Member__c = true;
                        contactsToUpdateMap.get(contactId).Chapter_Member_Expire_Date__c = highestExpireDate;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                }
                
                if (mapContactWithACAMSTodayAssets.get(contactId) == null || mapContactWithACAMSTodayAssets.get(contactId).isEmpty()) {
                    Contact contact = new Contact(
                        Id = contactId
                        // ACAMS_Today_Expiration_Date__c = null
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        //    contactsToUpdateMap.get(contactId).ACAMS_Today_Expiration_Date__c = null;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                } else {
                    Date highestExpireDate;
                    for (Asset asset : mapContactWithACAMSTodayAssets.get(contactId)) {
                        if (highestExpireDate == null) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        } else if (highestExpireDate < asset.CurrentExpirationDate__c) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        }
                    }
                    Contact contact = new Contact(
                        Id = contactId,
                        ACAMS_Today_Expiration_Date__c = highestExpireDate,
                        AT_Subscription__c =  highestExpireDate>=Date.today()
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).ACAMS_Today_Expiration_Date__c = highestExpireDate;
                        contactsToUpdateMap.get(contactId).AT_Subscription__c =  highestExpireDate>=Date.today();
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                }
                
                if (mapContactWithMLDCAssets.get(contactId) == null || mapContactWithMLDCAssets.get(contactId).isEmpty()) {
                    Contact contact = new Contact(
                        Id = contactId
                        //  MLDC_Expiration_Date__c = null
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        //   contactsToUpdateMap.get(contactId).MLDC_Expiration_Date__c = null;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                } else {
                    Date highestExpireDate;
                    for (Asset asset : mapContactWithMLDCAssets.get(contactId)) {
                        if (highestExpireDate == null) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        } else if (highestExpireDate < asset.CurrentExpirationDate__c) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        }
                    }
                    Contact contact = new Contact(
                        Id = contactId,
                        MLDC_Expiration_Date__c = highestExpireDate,
                        MLDC__c = highestExpireDate>=Date.today()//FSA-557
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).MLDC_Expiration_Date__c = highestExpireDate;
                        contactsToUpdateMap.get(contactId).MLDC__c = highestExpireDate>=Date.today();//FSA-557
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                }
                
                if (mapContactWithCAMSAssets.get(contactId) == null || mapContactWithCAMSAssets.get(contactId).isEmpty()) {
                    Contact contact = new Contact(
                        Id = contactId,
                        CAMS__c = false
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CAMS__c = false;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                } else {
                    Date highestExpireDate;
                    for (Asset asset : mapContactWithCAMSAssets.get(contactId)) {
                        if (highestExpireDate == null) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        } else if (highestExpireDate < asset.CurrentExpirationDate__c) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        }
                    }
                    Contact contact = new Contact(
                        Id = contactId,
                        CAMS__c = highestExpireDate>=Date.today(),
                        CAMS_Expiration_Date__c = highestExpireDate,
                        CAMS_Recertification_Eligibility_Date__c = Date.newInstance(highestExpireDate.year(), 1, 1)
                    );
                   
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CAMS__c =  highestExpireDate>=Date.today();
                        contactsToUpdateMap.get(contactId).CAMS_Expiration_Date__c = highestExpireDate;
                        contactsToUpdateMap.get(contactId).CAMS_Recertification_Eligibility_Date__c = Date.newInstance(highestExpireDate.year(), 1, 1);
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                }
                
                if (mapContactWithCAMSAuditAssets.get(contactId) == null || mapContactWithCAMSAuditAssets.get(contactId).isEmpty()) {
                    Contact contact = new Contact(
                        Id = contactId,
                        CAMS_Audit__c = false
                        //CAMS_Audit_Expiration_Date__c = null,
                        // CAMS_Audit_Eligibility_Date__c = null
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CAMS_Audit__c = false;
                        //  contactsToUpdateMap.get(contactId).CAMS_Audit_Expiration_Date__c = null;
                        //  contactsToUpdateMap.get(contactId).CAMS_Audit_Eligibility_Date__c = null;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                } else {
                    Date highestExpireDate;
                    for (Asset asset : mapContactWithCAMSAuditAssets.get(contactId)) {
                        if (highestExpireDate == null) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        } else if (highestExpireDate < asset.CurrentExpirationDate__c) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        }
                    }
                    Contact contact = new Contact(
                        Id = contactId,
                        CAMS_Audit__c = highestExpireDate>=Date.today(), 
                        CAMS_Audit_Expiration_Date__c = highestExpireDate,
                        CAMS_Audit_Eligibility_Date__c = Date.newInstance(highestExpireDate.year(), 1, 1) 
                    ); 
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CAMS_Audit__c = highestExpireDate>=Date.today(); //FSA-557
                        contactsToUpdateMap.get(contactId).CAMS_Audit_Expiration_Date__c = highestExpireDate;
                        contactsToUpdateMap.get(contactId).CAMS_Audit_Eligibility_Date__c = Date.newInstance(highestExpireDate.year(), 1, 1); 
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                }
                
                if (mapContactWithCAMSFCIAssets.get(contactId) == null || mapContactWithCAMSFCIAssets.get(contactId).isEmpty()) {
                    Contact contact = new Contact(
                        Id = contactId,
                        CAMS_FCI__c = false
                        //   CAMS_FCI_Expiration_Date__c = null,
                        //   CAMS_FCI_Eligibility_Date__c = null
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CAMS_FCI__c = false;
                        //    contactsToUpdateMap.get(contactId).CAMS_FCI_Expiration_Date__c = null;
                        //    contactsToUpdateMap.get(contactId).CAMS_FCI_Eligibility_Date__c = null;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                } else {
                    Date highestExpireDate;
                    for (Asset asset : mapContactWithCAMSFCIAssets.get(contactId)) {
                        if (highestExpireDate == null) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        } else if (highestExpireDate < asset.CurrentExpirationDate__c) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        }
                    }
                    Contact contact = new Contact(
                        Id = contactId,
                        CAMS_FCI__c = highestExpireDate>=Date.today(),//FSA-557
                        CAMS_FCI_Expiration_Date__c = highestExpireDate,
                        CAMS_FCI_Eligibility_Date__c = Date.newInstance(highestExpireDate.year(), 1, 1)
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CAMS_FCI__c = highestExpireDate>=Date.today(); //FSA-557
                        contactsToUpdateMap.get(contactId).CAMS_FCI_Expiration_Date__c = highestExpireDate;
                        contactsToUpdateMap.get(contactId).CAMS_FCI_Eligibility_Date__c = Date.newInstance(highestExpireDate.year(), 1, 1); //FSA-1165
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                }
                
                if (mapContactWithCAMSRMAssets.get(contactId) == null || mapContactWithCAMSRMAssets.get(contactId).isEmpty()) {
                    Contact contact = new Contact(
                        Id = contactId,
                        CAMSRM__c = false
                        //  CAMSRM_Expiration_Date__c = null,
                        //  CAMSRM_Recertification_Eligibility_Date__c = null
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CAMSRM__c = false;
                        //     contactsToUpdateMap.get(contactId).CAMSRM_Expiration_Date__c = null;
                        //    contactsToUpdateMap.get(contactId).CAMSRM_Recertification_Eligibility_Date__c = null;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                } else {
                    Date highestExpireDate;
                    for (Asset asset : mapContactWithCAMSRMAssets.get(contactId)) {
                        if (highestExpireDate == null) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        } else if (highestExpireDate < asset.CurrentExpirationDate__c) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        }
                    }
                    Contact contact = new Contact(
                        Id = contactId,
                        CAMSRM__c = highestExpireDate >= Date.today(), //FSA-557
                        CAMSRM_Expiration_Date__c = highestExpireDate,
                        CAMSRM_Recertification_Eligibility_Date__c = Date.newInstance(highestExpireDate.year(), 1, 1) //FSA-1165
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CAMSRM__c = highestExpireDate >= Date.today(); //FSA-557
                        contactsToUpdateMap.get(contactId).CAMSRM_Expiration_Date__c = highestExpireDate;
                        contactsToUpdateMap.get(contactId).CAMSRM_Recertification_Eligibility_Date__c = Date.newInstance(highestExpireDate.year(), 1, 1); //FSA-1165
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                }
                
                if (mapContactWithRegimeAssets.get(contactId) == null || mapContactWithRegimeAssets.get(contactId).isEmpty()) {
                    Contact contact = new Contact(
                        Id = contactId,
                        Singapore_Regime__c = false,
                        India_Regime__c = false,
                        Hong_Kong_Regime__c = false
                        //    Singapore_Regime_Expiration_Date__c = null,
                        //    India_Regime_Expiration_Date__c = null
                        //    FSA-2576
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).Singapore_Regime__c = false;
                        contactsToUpdateMap.get(contactId).India_Regime__c = false;
                        contactsToUpdateMap.get(contactId).Hong_Kong_Regime__c = false;
                        //   contactsToUpdateMap.get(contactId).Singapore_Regime_Expiration_Date__c = null;
                        //  contactsToUpdateMap.get(contactId).India_Regime_Expiration_Date__c = null;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                } else {
                    Date highestSingaporeExpireDate;
                    Date highestIndiaExpireDate;
                    Date highestHongKongExpireDate;
                    for (Asset asset : mapContactWithRegimeAssets.get(contactId)) {
                        if (asset.CC_Product__r.Level_2__c.contains('Singapore Regime')) {  // FSA-557
                            if (highestSingaporeExpireDate == null) {
                                highestSingaporeExpireDate = asset.CurrentExpirationDate__c;
                            } else if (highestSingaporeExpireDate < asset.CurrentExpirationDate__c) {
                                highestSingaporeExpireDate = asset.CurrentExpirationDate__c;
                            }
                        } else if (asset.CC_Product__r.Level_2__c.contains('India Regime')) { //FSA-557
                            if (highestIndiaExpireDate == null) {
                                highestIndiaExpireDate = asset.CurrentExpirationDate__c;
                            } else if (highestIndiaExpireDate < asset.CurrentExpirationDate__c) {
                                highestIndiaExpireDate = asset.CurrentExpirationDate__c;
                            }
                        } else if (asset.CC_Product__r.Level_2__c.contains('Regime Exam')) { 
                            if (highestHongKongExpireDate == null) {
                                highestHongKongExpireDate = asset.CurrentExpirationDate__c;
                            } else if (highestHongKongExpireDate < asset.CurrentExpirationDate__c) {
                                highestHongKongExpireDate = asset.CurrentExpirationDate__c;
                            }
                        }
                        
                    }
                    Contact contact = new Contact(
                        Id = contactId,
                        Singapore_Regime__c = highestSingaporeExpireDate>=Date.today() ? true : false, //FSA-557
                        Singapore_Regime_Expiration_Date__c = highestSingaporeExpireDate,
                        India_Regime__c = highestIndiaExpireDate >=Date.today() ? true : false, //FSA-557
                        India_Regime_Expiration_Date__c = highestIndiaExpireDate,
                        Hong_Kong_Regime__c = highestHongKongExpireDate >=Date.today() ? true : false, 
                        Hong_Kong_Regime_Expiration_Date__c = highestHongKongExpireDate
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).Singapore_Regime__c = highestSingaporeExpireDate >=Date.today() ? true : false; //FSA-557
                        contactsToUpdateMap.get(contactId).Singapore_Regime_Expiration_Date__c = highestSingaporeExpireDate;
                        contactsToUpdateMap.get(contactId).India_Regime__c = highestIndiaExpireDate >=Date.today() ? true : false;  //FSA-557
                        contactsToUpdateMap.get(contactId).India_Regime_Expiration_Date__c = highestIndiaExpireDate;
                        contactsToUpdateMap.get(contactId).Hong_Kong_Regime__c = highestHongKongExpireDate >=Date.today() ? true : false;  
                        contactsToUpdateMap.get(contactId).Hong_Kong_Regime_Expiration_Date__c = highestHongKongExpireDate;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                }
                
                if (mapContactWithCGSSAssets.get(contactId) == null || mapContactWithCGSSAssets.get(contactId).isEmpty()) {
                    Contact contact = new Contact(
                        Id = contactId,
                        CGSS__c = false
                        //  CGSS_Expiration_Date__c = null,
                        //   CGSS_Recertification_Eligibility_Date__c = null
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CGSS__c = false;
                        //       contactsToUpdateMap.get(contactId).CGSS_Expiration_Date__c = null;
                        //       contactsToUpdateMap.get(contactId).CGSS_Recertification_Eligibility_Date__c = null;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                } else {
                    Date highestExpireDate;
                    for (Asset asset : mapContactWithCGSSAssets.get(contactId)) {
                        if (highestExpireDate == null) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        } else if (highestExpireDate < asset.CurrentExpirationDate__c) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        }
                    }
                    Contact contact = new Contact(
                        Id = contactId,
                        CGSS__c = highestExpireDate>=Date.today(),
                        CGSS_Expiration_Date__c = highestExpireDate,
                        CGSS_Recertification_Eligibility_Date__c = Date.newInstance(highestExpireDate.year(), 1, 1) //FSA-1165
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CGSS__c = highestExpireDate>=Date.today();
                        contactsToUpdateMap.get(contactId).CGSS_Expiration_Date__c = highestExpireDate;
                        contactsToUpdateMap.get(contactId).CGSS_Recertification_Eligibility_Date__c = Date.newInstance(highestExpireDate.year(), 1, 1); //FSA-1165
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                }
                
                //chandra added for FSA-4721 start              
                system.debug('----------mapContactWithCCASAssets-----------'+mapContactWithCCASAssets);
                
                if (mapContactWithCCASAssets.get(contactId) == null || mapContactWithCCASAssets.get(contactId).isEmpty()) {
                    Contact contact = new Contact( Id = contactId, CCAS__c = false );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CCAS__c = false;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                } else {
                    Date highestExpireDate;
                    for (Asset asset : mapContactWithCCASAssets.get(contactId)) {
                        if (highestExpireDate == null) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        } else if (highestExpireDate < asset.CurrentExpirationDate__c) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        }
                    }
                    Contact contact = new Contact( 
                        Id = contactId, 
                        CCAS__c = highestExpireDate >= Date.today(), 
                        CCAS_Expiration_Date__c = highestExpireDate,
                        CCAS_Recertification_Eligibility_Date__c = Date.newInstance(highestExpireDate.year(),1,1));
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CCAS__c = highestExpireDate>=Date.today();
                        contactsToUpdateMap.get(contactId).CCAS_Expiration_Date__c = highestExpireDate;
                        contactsToUpdateMap.get(contactId).CCAS_Recertification_Eligibility_Date__c = Date.newInstance(highestExpireDate.year(),1,1);
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                    system.debug('----------contactsToUpdateMap----572-------'+contactsToUpdateMap);
                }              
                //chandra added for FSA-4721 close
                if (mapContactWithCKYCAAssets.get(contactId) == null || mapContactWithCKYCAAssets.get(contactId).isEmpty()) {
                    Contact contact = new Contact(
                        Id = contactId,
                        CKYCA__c = false
                        //    CKYCA_Expiration_Date__c = null,
                        //    CKYCA_Recertification_Eligibility_Date__c = null
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CKYCA__c = false;
                        //         contactsToUpdateMap.get(contactId).CKYCA_Expiration_Date__c = null;
                        //        contactsToUpdateMap.get(contactId).CKYCA_Recertification_Eligibility_Date__c = null;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                } else {
                    Date highestExpireDate;
                    // FSA-242
                    Date examPassDate;
                    for (Asset asset : mapContactWithCKYCAAssets.get(contactId)) {
                        examPassDate = asset.Exam_Pass_Date__c;
                        if (highestExpireDate == null) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        } else if (highestExpireDate < asset.CurrentExpirationDate__c) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        }
                    }
                    Contact contact = new Contact(
                        Id = contactId,
                        CKYCA__c = highestExpireDate>=Date.today(),
                        CKYCA_Expiration_Date__c = highestExpireDate,
                        CKYCA_Recertification_Eligibility_Date__c = highestExpireDate.addMonths(-3) //FSA-1165
                                          
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CKYCA__c = highestExpireDate>=Date.today();
                        contactsToUpdateMap.get(contactId).CKYCA_Expiration_Date__c = highestExpireDate;
                        contactsToUpdateMap.get(contactId).CKYCA_Recertification_Eligibility_Date__c = highestExpireDate.addMonths(-3); //FSA-1165
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                }
                
                // FSA-242 ,CAFCA
                if (mapContactWithCAFCAAssets.get(contactId) == null || mapContactWithCAFCAAssets.get(contactId).isEmpty()) {
                    system.debug('Cafca Contact update1');
                    Contact contact = new Contact(
                        Id = contactId,
                        CAFCA__c = false
                        //    CKYCA_Expiration_Date__c = null,
                        //    CKYCA_Recertification_Eligibility_Date__c = null
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CAFCA__c = false;
                        //         contactsToUpdateMap.get(contactId).CKYCA_Expiration_Date__c = null;
                        //        contactsToUpdateMap.get(contactId).CKYCA_Recertification_Eligibility_Date__c = null;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                } else {
                    system.debug('Cafca Contact update2');
                    Date highestExpireDate;
                    // FSA-242 , CAFCA
                    Date examPassDate;
                    for (Asset asset : mapContactWithCAFCAAssets.get(contactId)) {
                        examPassDate = asset.Exam_Pass_Date__c;
                        if (highestExpireDate == null) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        } else if (highestExpireDate < asset.CurrentExpirationDate__c) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        }
                    }
                    Contact contact = new Contact(
                        Id = contactId,
                        CAFCA__c = highestExpireDate>=Date.today(),//FSA-557
                        CAFCA_Expiration_Date__c = highestExpireDate,
                        CAFCA_Recertification_Eligibility_Date__c = highestExpireDate.addMonths(-3)
                    );
                    system.debug('contact::'+contact);
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).CAFCA__c = highestExpireDate>=Date.today(); //FSA-557
                        contactsToUpdateMap.get(contactId).CAFCA_Expiration_Date__c = highestExpireDate;
                        contactsToUpdateMap.get(contactId).CAFCA_Recertification_Eligibility_Date__c = highestExpireDate.addMonths(-3);
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                    system.debug('contactsToUpdateMap::'+contactsToUpdateMap);
                }
                //FSA-1165 CTMA certification
                
                if (mapContactWithCTMAAssets.get(contactId) == null || mapContactWithCTMAAssets.get(contactId).isEmpty()) {  
                    Contact contact = new Contact(  
                        Id = contactId,  
                        CTMA__c = false  
                    );  
                    if (contactsToUpdateMap.containsKey(contactId)) {  
                        contactsToUpdateMap.get(contactId).CTMA__c = false;  
                    } else {  
                        contactsToUpdateMap.put(contactId, contact);  
                    }  
                } else {  
                    Date highestExpireDate;
                    // FSA-242 , CTMA
                    Date examPassDate;  
                    
                    for (Asset asset : mapContactWithCTMAAssets.get(contactId)) {  
                        examPassDate = asset.Exam_Pass_Date__c;
                        if (highestExpireDate == null) {  
                            highestExpireDate = asset.CurrentExpirationDate__c;
                            
                        } else if (highestExpireDate < asset.CurrentExpirationDate__c) {  
                            highestExpireDate = asset.CurrentExpirationDate__c;  
                        }  
                    }  
                    Contact contact = new Contact(  
                        Id = contactId,  
                        CTMA__c = true,  
                        CTMA_Expiration_Date__c = highestExpireDate,
                        CTMA_Recertification_Eligibility_Date__c = highestExpireDate.addMonths(-3)
                    );  
                    
                    if (contactsToUpdateMap.containsKey(contactId)) {  
                        contactsToUpdateMap.get(contactId).CTMA__c = true;  
                        contactsToUpdateMap.get(contactId).CTMA_Expiration_Date__c = highestExpireDate;  
                        contactsToUpdateMap.get(contactId).CTMA_Recertification_Eligibility_Date__c = highestExpireDate.addMonths(-3); 
                        
                    } else {  
                        contactsToUpdateMap.put(contactId, contact);  
                    }  
                } 
                // FSA-1165
                if (mapContactWithPWSAssets.get(contactId) == null || mapContactWithPWSAssets.get(contactId).isEmpty()) {
                    system.debug('Premium Webinar Subscriber Update');
                    Contact contact = new Contact(
                        Id = contactId,
                        Premium_Webinar_Subscriber__c = false
                    );
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).Premium_Webinar_Subscriber__c = false;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                } else {
                    system.debug('Premium Webinar Subscriber update2');
                    Date highestExpireDate;
                    Date examPassDate;
                    for (Asset asset : mapContactWithPWSAssets.get(contactId)) {
                        if (highestExpireDate == null) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        } else if (highestExpireDate < asset.CurrentExpirationDate__c) {
                            highestExpireDate = asset.CurrentExpirationDate__c;
                        }
                    }
                    Contact contact = new Contact(
                        Id = contactId,
                        Premium_Webinar_Subscriber__c = highestExpireDate>=Date.today(),
                        Premium_Webinar_Subscription_Expiration__c = highestExpireDate
                    );
                    system.debug('contact::'+contact);
                    if (contactsToUpdateMap.containsKey(contactId)) {
                        contactsToUpdateMap.get(contactId).Premium_Webinar_Subscriber__c = highestExpireDate>=Date.today();
                        contactsToUpdateMap.get(contactId).Premium_Webinar_Subscription_Expiration__c = highestExpireDate;
                    } else {
                        contactsToUpdateMap.put(contactId, contact);
                    }
                    system.debug('contactsToUpdateMap::'+contactsToUpdateMap);
                }                
            }
        }
        ACAMSUtil.bypassPhoneValidation = true;
        for(Contact c : contactsToUpdateMap.values()) {
            c.Run_Membership_Certification_Logic__c = false;
        }
        //FSA-557
        if(performDML && contactsToUpdateMap.size()>0){
            if(ACAMSUtil.canAddQueueableJob() && System.isFuture() && !System.isBatch()){
                System.enqueueJob(new ACAMSUtil.UpdateObject(contactsToUpdateMap.values()));
            } else {
                update contactsToUpdateMap.values();
            }
            
            
        }
        ACAMSUtil.bypassPhoneValidation = false;
        
    }
    
    private static String assetToType(Asset ast){
        system.debug('ast.CC_Product__r.Level_1__c::'+ast.CC_Product__r.Level_1__c+'::ast.CC_Product__r.Level_2__c'+ast.CC_Product__r.Level_2__c);
        if(ast.CC_Product__r.Level_1__c == 'Membership' || ast.CC_Product__r.Level_1__c =='Enterprise Bundle'){
            return ACAMSUtil.MEMBERSHIP;
        } else if(ast.CC_Product__r.Level_1__c =='Chapter' &&  ast.CC_Product__r.Level_2__c =='Membership'){
            return chapterMembership;
        } else if(ast.CC_Product__r.Level_1__c =='Publications' && ast.CC_Product__r.Level_2__c == 'Moneylaundering.com'){
            return ACAMSUtil.MONEYLAUNDERINGDOTCOM;
        } else if(ast.CC_Product__r.Level_1__c == 'Publications' && ast.CC_Product__r.Level_2__c == 'ACAMS Today'){
            return acamsTodayPrintedSubscription;
        } else if(ast.CC_Product__r.Level_1__c == 'Certification' && ast.CC_Product__r.Level_2__c == 'CGSS' && (ast.CC_Product__r.Level_3__c == 'New' || ast.CC_Product__r.Level_3__c =='Recertification')){
            return 'CGSS Certification';
        } else if(ast.CC_Product__r.Level_1__c == 'Certification' && ast.CC_Product__r.Level_2__c == 'CCAS' && (ast.CC_Product__r.Level_3__c == 'New' || ast.CC_Product__r.Level_3__c =='Recertification')){
            return 'CCAS Certification';
        } else if(ast.CC_Product__r.Level_1__c == 'Certification' && ast.CC_Product__r.Level_2__c == 'CTMA' && (ast.CC_Product__r.Level_3__c == 'New' || ast.CC_Product__r.Level_3__c =='Recertification')){
            return 'CTMA Certification';
        } else if(ast.CC_Product__r.Level_1__c == 'Certification' && ast.CC_Product__r.Level_2__c == 'CAFCA' && (ast.CC_Product__r.Level_3__c == 'New' || ast.CC_Product__r.Level_3__c =='Recertification')){
            return 'CAFCA Certification';
        } else if(ast.CC_Product__r.Level_1__c == 'Certification' && ast.CC_Product__r.Level_2__c == 'CKYCA' && (ast.CC_Product__r.Level_3__c == 'New' || ast.CC_Product__r.Level_3__c =='Recertification')){
            return 'CKYCA Certification';
        } else if(ast.CC_Product__r.Level_1__c == 'Training' && ast.CC_Product__r.Level_2__c == 'Webinars' && ast.CC_Product__r.Level_3__c == 'Subscription'){
            return 'Premium Webinar Subscriber';
        } else if(ast.CC_Product__r.Level_1__c == 'Certification' && ast.CC_Product__r.Level_2__c == 'Advanced CAMS - Audit' && (ast.CC_Product__r.Level_3__c == 'New' || ast.CC_Product__r.Level_3__c =='Recertification')){
            return 'CAMS - Audit';
        } else if(ast.CC_Product__r.Level_1__c == 'Certification' && ast.CC_Product__r.Level_2__c == 'Advanced CAMS - FCI' && (ast.CC_Product__r.Level_3__c == 'New' || ast.CC_Product__r.Level_3__c =='Recertification')){
            return 'FCI';
        } else if(ast.CC_Product__r.Level_1__c == 'Certification' && ast.CC_Product__r.Level_2__c == 'Advanced CAMS - Risk Management' && (ast.CC_Product__r.Level_3__c == 'New' || ast.CC_Product__r.Level_3__c =='Recertification')){
            return 'CAMS - Risk Management';
        } else if(ast.CC_Product__r.Level_1__c == 'Certification' && ast.CC_Product__r.Level_2__c == 'India Regime' && (ast.CC_Product__r.Level_3__c == 'New' || ast.CC_Product__r.Level_3__c =='Recertification')){
            return ACAMSUtil.REGIME_EXAM;
        } else if(ast.CC_Product__r.Level_1__c == 'Certification' && ast.CC_Product__r.Level_2__c == 'Singapore Regime' && (ast.CC_Product__r.Level_3__c == 'New' || ast.CC_Product__r.Level_3__c =='Recertification')){
            return ACAMSUtil.REGIME_EXAM;
        } else if(ast.CC_Product__r.Level_1__c == 'Certification' && ast.CC_Product__r.Level_2__c == 'Regime Exam' && (ast.CC_Product__r.Level_3__c == 'New' || ast.CC_Product__r.Level_3__c =='Recertification')){
            return ACAMSUtil.REGIME_EXAM;
        } else if(ast.CC_Product__r.Level_1__c == 'Certification' && (ast.CC_Product__r.Level_2__c == 'CAMS' ||
                                                                      ast.CC_Product__r.Level_2__c == 'Advanced CAMS – Audit' || ast.CC_Product__r.Level_2__c == 'Advanced CAMS – FCI' || ast.CC_Product__r.Level_2__c == 'Advanced CAMS – Risk Management') && 
                  (ast.CC_Product__r.Level_3__c == 'New' || ast.CC_Product__r.Level_3__c == 'Recertification')){
                      return 'CAMS Certification';    
                  } else {
                      return null;
                  }
    }
    private static void getXEMET(String assetType, Asset asset, Map<Id, List<Asset>> mapContactWithACAMSTodayAssets){
        if (assetType == acamsTodayPrintedSubscription && mapContactWithACAMSTodayAssets.get(asset.Assignee__c) == null) {
            mapContactWithACAMSTodayAssets.put(asset.Assignee__c, new List<Asset>{
                asset
                    });
        } else if (assetType == acamsTodayPrintedSubscription) {
            mapContactWithACAMSTodayAssets.get(asset.Assignee__c).add(asset);
        }
    }
    private static Boolean isMasterAsset(Asset asset) {
        if (asset.ParentId == null && asset.Status__c == null && asset.Assignee__c != null &&
            asset.CC_Product__c == null) {
                return true;
            }
        return false;
    }  
    // This method will clear all the membership and certification fields on Person Account. FSA-6834
    private static void clearMemCertFields(Set<ID> contactIds){
        List<contact> ContLst = new List<contact>();
        List<contact> ContLstUpdate = new List<contact>();
        contlst = [select id, ACAMS_Member__c,Membership_Type__c,Member_Expire_Date__c, Chapter_Member__c, Chapter_Member_Expire_Date__c,ACAMS_Today_Expiration_Date__c,
                   AT_Subscription__c,MLDC_Expiration_Date__c, MLDC__c ,CAMS__c, CAMS_Expiration_Date__c,CAMS_Audit__c, CAMS_Audit_Expiration_Date__c,CAMS_FCI__c,CAMS_FCI_Expiration_Date__c,
                  CAMSRM__c,CAMSRM_Expiration_Date__c,Singapore_Regime__c,Singapore_Regime_Expiration_Date__c,India_Regime__c,India_Regime_Expiration_Date__c,Hong_Kong_Regime__c,Hong_Kong_Regime_Expiration_Date__c,
                   CGSS__c,CGSS_Expiration_Date__c,CCAS__c,CCAS_Expiration_Date__c,CKYCA__c,CKYCA_Expiration_Date__c,CAFCA__c,CAFCA_Expiration_Date__c,
                   CTMA__c,CTMA_Expiration_Date__c,Premium_Webinar_Subscriber__c,Premium_Webinar_Subscription_Expiration__c
                   from contact where id IN: contactIds];
        for(Contact c: contlst){
            c.ACAMS_Member__c=false;
            c.Membership_Type__c=null;
            c.Member_Expire_Date__c=null;
            c.Chapter_Member__c=false;
            c.Chapter_Member_Expire_Date__c=null;
            c.ACAMS_Today_Expiration_Date__c=null;
            c.AT_Subscription__c=false;
            c.MLDC_Expiration_Date__c=null;
            c.MLDC__c=false;
            c.CAMS__c=false;
            c.CAMS_Expiration_Date__c=null;
            c.CAMS_Audit__c=false;
            c.CAMS_Audit_Expiration_Date__c=null;
            c.CAMS_FCI__c=false;
            c.CAMS_FCI_Expiration_Date__c=null;
            c.CAMSRM__c=false;
            c.CAMSRM_Expiration_Date__c=null;
            c.Singapore_Regime__c=false;
            c.Singapore_Regime_Expiration_Date__c=null;
            c.India_Regime__c=false;
            c.India_Regime_Expiration_Date__c=null;
            c.Hong_Kong_Regime__c=false;
            c.Hong_Kong_Regime_Expiration_Date__c=null;
            c.CGSS__c=false;
            c.CGSS_Expiration_Date__c=null;
            c.CCAS__c=false;
            c.CCAS_Expiration_Date__c=null;
            c.CKYCA__c=false;
            c.CKYCA_Expiration_Date__c=null;
            c.CAFCA__c=false;
            c.CAFCA_Expiration_Date__c=null;
            c.CTMA__c=false;
            c.CTMA_Expiration_Date__c=null;
            c.Premium_Webinar_Subscriber__c=false;
            c.Premium_Webinar_Subscription_Expiration__c=null;
            ContLstUpdate.add(c);
        }
        if(ContLstUpdate.size()>0){
            try{
                clearfields = true;
            update ContLstUpdate;
                }
            catch(exception ex){
                system.debug(ex.getMessage());
            }
        }
    }
}