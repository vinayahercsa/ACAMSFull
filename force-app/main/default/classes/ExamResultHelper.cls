/*
* Helper Class referenced in ExamResult Trigger
* Created: 08/07/2019
* FS IT Team
* Notes: Moved code FROM ExamResult Trigger to this Helper Class
* contains method to update exam result on related asset.
* contains method to send Exam Authorization AND Contact Information to PearsonVue
* contains method to update regional funding application approval on related asset
*/
public class ExamResultHelper {
    public static Boolean isVUERecursiveCheck = false;
    public static Boolean isVUERecursiveCheckContact = false;
    public static Boolean isVUERecursiveEADCheck = false;
    public static Boolean isVUERecursiveSGAMLCheck = false;
    public static Boolean isAssetRecursiveExamResult = false;
    
    /*    public static void UpdateExamType(List<Exam_Results__c> newExamResults) {
for (Exam_Results__c e : newExamResults) {
if(e.Enterprise_Product_HL__c != null) {
if (e.Enterprise_Product_HL__c.contains('CAMSO6') &&  !(e.Enterprise_Product_HL__c.contains('FEBRA')) && !(e.Enterprise_Product_HL__c.contains('SG')) ) {
e.Exam_Type__c = 'CAMS';
}
}
if (e.Enterprise_Product_HL__c == 'CAMSO6-FEBRA') {
e.Exam_Type__c = 'CAMS-Febraban';
}
if (e.Enterprise_Product_HL__c == 'ADVCERT2') {
e.Exam_Type__c = 'CAMS-FCI';
}
if (e.Enterprise_Product_HL__c == 'CAMSFCI-01') {
e.Exam_Type__c = 'CAMS-FCI';
}
if (e.Enterprise_Product_HL__c == 'CAMSO6-SG') {
e.Exam_Type__c = 'Singapore AML Regime Exam';
}
if (e.Enterprise_Product_HL__c == 'ADVCERT1') {
e.Exam_Type__c = 'CAMS-AUDIT';
}
if (e.Enterprise_Product_HL__c == 'CAMSAUDIT-01') {
e.Exam_Type__c = 'CAMS-AUDIT';
}
if (e.Product_level_2__c == 'CGSS') {
e.Exam_Type__c = 'CGSS';
}
if(e.Enterprise_Product_HL__c =='IN-AML-Regime'){
e.Exam_Type__c='India AML Regime Exam';
}
if(e.Enterprise_Product_HL__c != null) {

if(e.Enterprise_Product_HL__c.contains('CAMSRM')){
e.Exam_Type__c='CAMSRM';
}
if(e.Enterprise_Product_HL__c.contains('CKYCA')){
e.Exam_Type__c='CKYCA';
}
}          

if(e.Product_Level_2__c == 'CKYCA'){
e.Exam_Type__c='CKYCA';
}

//FSA - 239
if(e.Product_Level_2__c == 'CTMA'){
e.Exam_Type__c='CTMA';
}
if(e.Product_Level_2__c == 'CAFCA'){
e.Exam_Type__c='CAFCA';
}
}
} */
    //csa fix: method updated to handle date exceptions
public static void UpdatePVDates(List<Exam_Results__c> newExamResults) {
   
    for (Exam_Results__c e : newExamResults) {
        if (e.Exam_Date__c != null) {
            String st = e.Exam_Date__c;
            String strep2 = st.substringBefore(' ');
            String format=validateDateFormat(strep2);
        if(format=='MM/dd/yyyy'){
            date mydate = date.parse(strep2);
            e.Test_Date__c = mydate;

    }
        if(format=='yyyy/MM/dd'){
            String strep = strep2.replace('/', '-');
            Date mydate = (Date) JSON.deserialize('"' + strep + '"', Date.class);
            e.Test_Date__c = mydate;

    }

    }
 }
}

//csa fix- added method to check the date format.
public static string validateDateFormat(String dateString){
    String dateFormat;
        if (dateString.contains('/')) {
            if (dateString.split('/')[0].length() == 4) {
                dateFormat = 'yyyy/MM/dd';
            } else {
                dateFormat = 'MM/dd/yyyy';
            }
        } 
   
return dateFormat;
}

    // Method to Update Regional Funding Record
    // TODO: Fix this method as it only updates each RF with the last ExamResults data in newExamResults
    public static void UpdateCertResult(List<Exam_Results__c> newExamResults) {
        Date camsdate;
        Date sgamldate;
        Boolean cams;
        Boolean sgaml;
        List<Id> contactIds = new List<Id>();
        
        for (Exam_Results__c o : newExamResults) {
            if (o.Exam_Type__c == 'Singapore AML Regime Exam' && o.Result__c == 'Pass' && o.Contact__c != null) {
                contactIds.add(o.Contact__c);
                sgamldate = o.Test_Date__c;
                sgaml = true;
                
            } else if (o.Exam_Type__c == 'CAMS' && o.Result__c == 'Pass' && o.Contact__c != null) {
                contactIds.add(o.Contact__c);
                camsdate = o.Test_Date__c;
                cams = true;
                
            }
            
        }
        
        List<Regional_Funding__c> regList = [
            SELECT
            Id,
            Passed_AML_Regime_Exam_Date__c,
            Passed_CAMS_Exam_Date__c
            FROM
            Regional_Funding__c
            WHERE
            Contact__c IN :contactIds
        ];
        
        for (Integer i = 0; i < regList.size(); i++) {
            if (sgaml != null) {
                if (sgaml) {
                    regList[i].Passed_AML_Regime_Exam_Date__c = sgamldate;
                }
            }
            if (cams != null) {
                if (cams) {
                    regList[i].Passed_CAMS_Exam_Date__c = camsdate;
                }
            }
        }
        
        update regList;
        
    }
    
    //FSA-831 Related Changes Start
        
   public static void UpdateCertResultToPass(List<Exam_Results__c> newExamResults, Map<Id, Exam_Results__c> oldMap) {
                    
        List<Recert_Cycle__c> lstRecertificate =new list<Recert_Cycle__c>();
     
       for (Exam_Results__c r : newExamResults){
            If(r.Test_Date__c != null && r.Result__c != null && (r.Result__c =='pass' || r.Result__c =='Pass' || r.Result__c =='PASS')) {
                if(r.Result__c != oldMap.get(r.Id).Result__c){  //FSA-6889 (r.Test_Date__c != oldMap.get(r.Id).Test_Date__c)  vara removed this condition stoping to create recert cycle record.
                    //CKYCA
                     If(r.Exam_Type__c == 'CKYCA'){
                      Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                        recerCycle.Certification_Type__c = 'CKYCA'; 
                        recerCycle.Contact__c = r.Contact__c;
                        recerCycle.Start_Date__c = r.Test_Date__c;
                        recerCycle.End_Date__c = r.Test_Date__c.addYears(1); //need to Add 1 Year 
                        recerCycle.Name = 'CKYCA'+' '+ recerCycle.End_Date__c.year();
                        lstRecertificate.add(recerCycle);
                          }
                    
                    // CAFCA
                    If(r.Exam_Type__c == 'CAFCA' ){
                       
                        Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                        recerCycle.Certification_Type__c = 'CAFCA';
                        recerCycle.Contact__c = r.Contact__c;
                        recerCycle.Start_Date__c = r.Test_Date__c;
                        recerCycle.End_Date__c = r.Test_Date__c.addYears(1);//need to Add 1 Year
                        recerCycle.Name ='CAFCA'+' '+ recerCycle.End_Date__c.year();
                        lstRecertificate.add(recerCycle);
                          }
                    
                    //CTMA
                    If(r.Exam_Type__c == 'CTMA'){
                       
                        Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                        recerCycle.Certification_Type__c = 'CTMA';
                        recerCycle.Contact__c = r.Contact__c;
                        recerCycle.Start_Date__c = r.Test_Date__c;
                        recerCycle.End_Date__c = r.Test_Date__c.addYears(1);//need to Add 1 Year
                        recerCycle.Name = 'CTMA'+' '+ recerCycle.End_Date__c.year();
                        lstRecertificate.add(recerCycle);
                        
                    }
                    
                    //CAMS
                    If(r.Exam_Type__c == 'CAMS' || r.Exam_Type__c == 'CAMSFebraban'){
                        Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                        recerCycle.Certification_Type__c = 'CAMS';
                        recerCycle.Contact__c = r.Contact__c;
                        recerCycle.Start_Date__c = r.Test_Date__c;
                        recerCycle.End_Date__c = Date.newInstance(r.Test_Date__c.year()+ 3, 12, 15);//need to Add 1 Year
                        recerCycle.Name = 'CAMS'+' '+ recerCycle.End_Date__c.year();
                        lstRecertificate.add(recerCycle);                    
                    }
                    
                    //Advanced CAMS - Audit
                    If(r.Exam_Type__c == 'CAMS-Audit'){
                        Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                        recerCycle.Certification_Type__c = 'Advanced CAMS - Audit';
                        recerCycle.Contact__c = r.Contact__c;
                        recerCycle.Start_Date__c = r.Test_Date__c;
                        recerCycle.End_Date__c = Date.newInstance(r.Test_Date__c.year() + 3, 12, 15);//need to Add 1 Year
                        recerCycle.Name = 'Advanced CAMS - Audit'+' '+ recerCycle.End_Date__c.year();
                        lstRecertificate.add(recerCycle);
                        
                    }
                    
                    //Advanced CAMS - FCI
                    If(r.Exam_Type__c == 'CAMS-FCI'){
                        Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                        recerCycle.Certification_Type__c = 'Advanced CAMS - FCI';
                        recerCycle.Contact__c = r.Contact__c;
                        recerCycle.Start_Date__c = r.Test_Date__c;
                        recerCycle.End_Date__c = Date.newInstance(r.Test_Date__c.year() + 3, 12, 15);//need to Add 1 Year
                        recerCycle.Name = 'Advanced CAMS - FCI'+' '+ recerCycle.End_Date__c.year();
                        lstRecertificate.add(recerCycle);
                        
                    }
                    
                    // Advanced CAMS - Risk Management
                    If(r.Exam_Type__c == 'CAMSRM'){
                        Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                        recerCycle.Certification_Type__c = 'Advanced CAMS - Risk Management';
                        recerCycle.Contact__c = r.Contact__c;
                        recerCycle.Start_Date__c = r.Test_Date__c;
                        recerCycle.End_Date__c = Date.newInstance(r.Test_Date__c.year() + 3, 12, 15);//need to Add 1 Year
                        recerCycle.Name = 'Advanced CAMS - Risk Management'+' '+ recerCycle.End_Date__c.year();
                        lstRecertificate.add(recerCycle);
                        
                    }
                    
                    // CGSS                 
                    If(r.Exam_Type__c == 'CGSS'){
                        Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                        recerCycle.Certification_Type__c = 'CGSS';
                        recerCycle.Contact__c = r.Contact__c;
                        recerCycle.Start_Date__c = r.Test_Date__c;
                        recerCycle.End_Date__c = Date.newInstance(r.Test_Date__c.year() + 3, 12, 15);//need to Add 1 Year
                        recerCycle.Name = 'CGSS'+' '+ recerCycle.End_Date__c.year();
                        lstRecertificate.add(recerCycle);
                        
                    }
                    
                    // CCAS                 
                    If(r.Exam_Type__c == 'CCAS'){
                        Recert_Cycle__c recerCycle = new  Recert_Cycle__c();
                        recerCycle.Certification_Type__c = 'CCAS';
                        recerCycle.Contact__c = r.Contact__c;
                        recerCycle.Start_Date__c = r.Test_Date__c;
                        recerCycle.End_Date__c = Date.newInstance(r.Test_Date__c.year() + 3, 12, 15);//need to Add 1 Year
                        recerCycle.Name = 'CCAS'+' '+ recerCycle.End_Date__c.year();
                        lstRecertificate.add(recerCycle);
                        
                    }                   
                }
            }
        }
        database.insert(lstRecertificate);
        
    }   
    
   // FSA-831 Related Changes End
    
    
    //Method to Update Exam Result on Asset, Shakti - added recursive check to resolve exam result governor limit
    
    public static void UpsertExamResultOnAsset(List<Exam_Results__c> newExamResults) {
        if (!ExamResultHelper.isAssetRecursiveExamResult) {
            ExamResultHelper.isAssetRecursiveExamResult = true;
            List<Id> ExamContactList = new List<Id>();
            
            for (Exam_Results__c item : newExamResults) {
                ExamContactList.add(item.Contact__c);
            }
            
            //  Get All Exam Records Related to Current Records Users
            Map<Id, List<Exam_Results__c>> ContactToExamListMap = new Map<Id, List<Exam_Results__c>>();
            for (Exam_Results__c result : [SELECT Id, Contact__c, Result__c, Test_Date__c FROM Exam_Results__c WHERE Contact__c IN:ExamContactList ORDER BY Test_Date__c DESC, CreatedDate DESC]) {
                if (result.Contact__c != null) {
                    if (!ContactToExamListMap.containsKey(result.Contact__c)) {
                        ContactToExamListMap.put(result.Contact__c, new List<Exam_Results__c>());
                    }
                    
                    ContactToExamListMap.get(result.Contact__c).add(result);
                }
            }
            
            //  Get All CAMS Exam Records Related to Current Records Users
            Map<Id, List<Exam_Results__c>> ContactToExamListMap2 = new Map<Id, List<Exam_Results__c>>();
            //csa fix to optimise the queries
            Map<Id, List<Exam_Results__c>> ContactToExamListMap4 = new Map<Id, List<Exam_Results__c>>(); 
            Map<Id, List<Exam_Results__c>> ContactToExamListMap5 = new Map<Id, List<Exam_Results__c>>();
            Map<Id, List<Exam_Results__c>> ContactToExamListMap3 = new Map<Id, List<Exam_Results__c>>();
            //csa fix
            for (Exam_Results__c result : [
                SELECT
                Id,
                Exam_Type__c,
                Contact__c,
                Result__c,
                Test_Date__c
                FROM
                Exam_Results__c
                WHERE
                Contact__c
                IN
                :ExamContactList
                AND
                (Exam_Type__c = 'CAMS'
                 OR
                 Exam_Type__c = 'CAMS-Audit' //csa fix
                 OR
                 Exam_Type__c = 'CAMS-FCI' //csa fix
                 OR
                 Exam_Type__c = 'Singapore AML Regime Exam' //csa fix
                 OR
                 Exam_Type__c = 'CAMSFebraban' )
                ORDER BY
                Test_Date__c DESC,
                CreatedDate DESC
            ]) {
                if (result.Contact__c != null) {
                    if(result.Exam_Type__c == 'CAMS-Audit'){
                        if (!ContactToExamListMap4.containsKey(result.Contact__c)) {
                            ContactToExamListMap4.put(result.Contact__c, new List<Exam_Results__c>());
                        }
                        
                        ContactToExamListMap4.get(result.Contact__c).add(result);
                    }
                    //csa fix to optimise the query 
                    if(result.Exam_Type__c == 'CAMS' || result.Exam_Type__c == 'CAMSFebraban'){
                    if (!ContactToExamListMap2.containsKey(result.Contact__c)) {
                        ContactToExamListMap2.put(result.Contact__c, new List<Exam_Results__c>());
                    }
                    
                    ContactToExamListMap2.get(result.Contact__c).add(result);
                }
                    //csa fix
                    if(result.Exam_Type__c == 'CAMS-FCI'){
                        if (!ContactToExamListMap5.containsKey(result.Contact__c)) {
                            ContactToExamListMap5.put(result.Contact__c, new List<Exam_Results__c>());
                        }
                        
                        ContactToExamListMap5.get(result.Contact__c).add(result);
                    	}
                    //csa fix
                    if(result.Exam_Type__c == 'Singapore AML Regime Exam'){
                        if (!ContactToExamListMap3.containsKey(result.Contact__c)) {
                            ContactToExamListMap3.put(result.Contact__c, new List<Exam_Results__c>());
                        }
                        
                        ContactToExamListMap3.get(result.Contact__c).add(result);
                    }
                	}
            }
            // Get All Advanced CAMS Audit Exam Records Related to Current Records Users
            //Map<Id, List<Exam_Results__c>> ContactToExamListMap4 = new Map<Id, List<Exam_Results__c>>();
           /* for (Exam_Results__c result : [
                SELECT
                Id,
                Exam_Type__c,
                Contact__c,
                Result__c,
                Test_Date__c
                FROM
                Exam_Results__c
                WHERE
                Contact__c
                IN
                :ExamContactList
                AND
                Exam_Type__c = 'CAMS-Audit'
                ORDER BY
                Test_Date__c DESC,
                CreatedDate DESC]) {
                    if (result.Contact__c != null) {
                        if (!ContactToExamListMap4.containsKey(result.Contact__c)) {
                            ContactToExamListMap4.put(result.Contact__c, new List<Exam_Results__c>());
                        }
                        
                        ContactToExamListMap4.get(result.Contact__c).add(result);
                    }
                }*/
            //  Get All Advanced CAMS FCI Exam Records Related to Current Records Users
            //Map<Id, List<Exam_Results__c>> ContactToExamListMap5 = new Map<Id, List<Exam_Results__c>>();
           /* for (Exam_Results__c result : [
                SELECT
                Id,
                Exam_Type__c,
                Contact__c,
                Result__c,
                Test_Date__c
                FROM
                Exam_Results__c
                WHERE
                Contact__c
                IN
                :ExamContactList
                AND
                Exam_Type__c = 'CAMS-FCI'
                ORDER BY
                Test_Date__c DESC,
                CreatedDate DESC]) {
                    if (result.Contact__c != null) {
                        if (!ContactToExamListMap5.containsKey(result.Contact__c)) {
                            ContactToExamListMap5.put(result.Contact__c, new List<Exam_Results__c>());
                        }
                        
                        ContactToExamListMap5.get(result.Contact__c).add(result);
                    }
                }*/
            
            
            //  Get All SG Regime Exam Records Related to Current Records Users
            //Map<Id, List<Exam_Results__c>> ContactToExamListMap3 = new Map<Id, List<Exam_Results__c>>();
            /*for (Exam_Results__c result : [
                SELECT
                Id,
                Exam_Type__c,
                Contact__c,
                Result__c,
                Test_Date__c
                FROM
                Exam_Results__c
                WHERE
                Contact__c
                IN
                :ExamContactList
                AND
                Exam_Type__c = 'Singapore AML Regime Exam'
                ORDER BY
                Test_Date__c DESC,
                CreatedDate DESC]) {
                    if (result.Contact__c != null) {
                        if (!ContactToExamListMap3.containsKey(result.Contact__c)) {
                            ContactToExamListMap3.put(result.Contact__c, new List<Exam_Results__c>());
                        }
                        
                        ContactToExamListMap3.get(result.Contact__c).add(result);
                    }
                } */
            
            //  Only Update Latest Exam Record
            Map<Id, Exam_Results__c> ContactToExamMap = new Map<Id, Exam_Results__c>();
            if (ContactToExamListMap.size() > 0) {
                for (Exam_Results__c result : newExamResults) {
                    if (ContactToExamListMap.containsKey(result.Contact__c)) {
                        if (ContactToExamListMap.get(result.Contact__c).size() > 0) {
                            //  First Record of Map Should Equal Trigger List Item (result)
                            if (result.Id == ContactToExamListMap.get(result.Contact__c)[0].Id) {
                                ContactToExamMap.put(result.Contact__c, ContactToExamListMap.get(result.Contact__c)[0]);
                            }
                        }
                    }
                }
            }
            
            
            //  Only Update Latest CAMS Exam Record
            Map<Id, Exam_Results__c> ContactToExamMap2 = new Map<Id, Exam_Results__c>();
            if (ContactToExamListMap2.size() > 0) {
                for (Exam_Results__c result : newExamResults) {
                    if (ContactToExamListMap2.containsKey(result.Contact__c)) {
                        if (ContactToExamListMap2.get(result.Contact__c).size() > 0) {
                            //  First Record of Map Should Equal Trigger List Item (result)
                            if (result.Id == ContactToExamListMap2.get(result.Contact__c)[0].Id) {
                                ContactToExamMap2.put(result.Contact__c, ContactToExamListMap2.get(result.Contact__c)[0]);
                            }
                        }
                    }
                }
            }
            
            
            //  Only Update Latest SG AML Regime Exam Record
            Map<Id, Exam_Results__c> ContactToExamMap3 = new Map<Id, Exam_Results__c>();
            if (ContactToExamListMap3.size() > 0) {
                for (Exam_Results__c result : newExamResults) {
                    if (ContactToExamListMap3.containsKey(result.Contact__c)) {
                        if (ContactToExamListMap3.get(result.Contact__c).size() > 0) {
                            //  First Record of Map Should Equal Trigger List Item (result)
                            if (result.Id == ContactToExamListMap3.get(result.Contact__c)[0].Id) {
                                ContactToExamMap3.put(result.Contact__c, ContactToExamListMap3.get(result.Contact__c)[0]);
                            }
                        }
                    }
                }
            }
            
            //  Only Update advanced CAMS Audit Record
            Map<Id, Exam_Results__c> ContactToExamMap4 = new Map<Id, Exam_Results__c>();
            if (ContactToExamListMap4.size() > 0) {
                for (Exam_Results__c result : newExamResults) {
                    if (ContactToExamListMap4.containsKey(result.Contact__c)) {
                        if (ContactToExamListMap4.get(result.Contact__c).size() > 0) {
                            //  First Record of Map Should Equal Trigger List Item (result)
                            
                            ContactToExamMap4.put(result.Contact__c, ContactToExamListMap4.get(result.Contact__c)[0]);
                            
                        }
                    }
                }
            }
            
            // Only Update advanced CAMS FCI Record
            Map<Id, Exam_Results__c> ContactToExamMap5 = new Map<Id, Exam_Results__c>();
            if (ContactToExamListMap5.size() > 0) {
                for (Exam_Results__c result : newExamResults) {
                    if (ContactToExamListMap5.containsKey(result.Contact__c)) {
                        if (ContactToExamListMap5.get(result.Contact__c).size() > 0) {
                            //  First Record of Map Should Equal Trigger List Item (result)
                            
                            ContactToExamMap5.put(result.Contact__c, ContactToExamListMap5.get(result.Contact__c)[0]);
                            
                        }
                    }
                }
            }
            
            //  Map Latest Certification to Latest Exam Result
            Map<Id, Asset> ContactToAssetMap = new Map<Id, Asset>();
            for (Asset asset : [SELECT Id, ExamResult__c, CreatedDate, CC_Product__r.ProductCategory__c, Assignee__c FROM Asset WHERE Assignee__c IN:ContactToExamMap.keySet() AND CC_Product__r.ProductCategory__c = :'Certifications' AND EAD_created__c != true ORDER BY CreatedDate DESC]) {
                //  Only Add Asset to Map if Not Added Already (First Asset)
                if (!ContactToAssetMap.containsKey(asset.Assignee__c)) {
                    if (ContactToExamMap.containsKey(asset.Assignee__c)) {
                        asset.ExamResult__c = ContactToExamMap.get(asset.Assignee__c).Id;
                        ContactToAssetMap.put(asset.Assignee__c, asset);
                    }
                }
            }
            
            //  Set This Record to Lookup on Asset
            if (ContactToAssetMap.size() > 0) {
                update ContactToAssetMap.values();
            }
            
            
            // Map Latest Certification to Latest CAMS Exam Result
            Map<Id, Asset> ContactToAssetMap2 = new Map<Id, Asset>();
            for (Asset asset : [
                SELECT
                Id,
                ExamResult__c,
                CreatedDate,
                CC_Product__r.ProductCategory__c,
                Assignee__c,
                Status__c
                FROM
                Asset
                WHERE
                Assignee__c
                IN
                :ContactToExamMap2.keySet()
                AND
                Enterprise_Product_HL__c != 'SG-AML-Regime'
                AND
                CC_Product__r.ProductCategory__c = :'Certifications'
                AND
                Status__c = :'Active'
                AND
                EAD_created__c != TRUE
                ORDER BY
                CreatedDate DESC
            ]) {
                //  Only Add Asset to Map if Not Added Already (First Asset)
                if (!ContactToAssetMap2.containsKey(asset.Assignee__c)) {
                    if (ContactToExamMap2.containsKey(asset.Assignee__c)) {
                        asset.ExamResult__c = ContactToExamMap2.get(asset.Assignee__c).Id;
                        ContactToAssetMap2.put(asset.Assignee__c, asset);
                    }
                }
            }
            
            //  Set This Record to Lookup on Asset
            if (ContactToAssetMap2.size() > 0) {
                update ContactToAssetMap2.values();
            }
            
            //Map Latest Advanced Certification CAMS Audit to Latest CAMS Exam Result
            Map<Id, Asset> ContactToAssetMap4 = new Map<Id, Asset>();
            for (Asset asset : [
                SELECT
                Id,
                ExamResult__c,
                CreatedDate,
                CC_Product__r.ProductCategory__c,
                Assignee__c,
                Status__c
                FROM
                Asset
                WHERE
                Assignee__c
                IN
                :ContactToExamMap4.keySet()
                AND
                Enterprise_Product_HL__c != 'SG-AML-Regime'
                AND
                CC_Product__r.ProductCategory__c = :'Advanced Certifications'
                AND
                Status__c = :'Active'
                AND
                Enterprise_Product_HL__c
                LIKE
                'ADV1%'
                AND
                EAD_created__c != TRUE
                ORDER BY
                CreatedDate DESC
            ]) {
                //  Only Add Asset to Map if Not Added Already (First Asset)
                if (!ContactToAssetMap4.containsKey(asset.Assignee__c)) {
                    if (ContactToExamMap4.containsKey(asset.Assignee__c)) {
                        asset.ExamResult__c = ContactToExamMap4.get(asset.Assignee__c).Id;
                        ContactToAssetMap4.put(asset.Assignee__c, asset);
                    }
                }
            }
            
            //  Set This Record to Lookup on Asset
            if (ContactToAssetMap4.size() > 0) {
                update ContactToAssetMap4.values();
            }
            
            //Map Latest Advanced Certification CAMS FCI to Latest CAMS Exam Result
            Map<Id, Asset> ContactToAssetMap5 = new Map<Id, Asset>();
            for (Asset asset : [
                SELECT
                Id,
                ExamResult__c,
                CreatedDate,
                CC_Product__r.ProductCategory__c,
                Assignee__c,
                Status__c
                FROM
                Asset
                WHERE
                Assignee__c
                IN
                :ContactToExamMap5.keySet()
                AND
                Enterprise_Product_HL__c != 'SG-AML-Regime'
                AND
                CC_Product__r.ProductCategory__c = :'Advanced Certifications'
                AND
                Status__c = :'Active'
                AND
                Enterprise_Product_HL__c
                LIKE 'ADV2%'
                AND
                EAD_created__c != TRUE
                ORDER BY
                CreatedDate DESC
            ]) {
                //  Only Add Asset to Map if Not Added Already (First Asset)
                if (!ContactToAssetMap5.containsKey(asset.Assignee__c)) {
                    if (ContactToExamMap5.containsKey(asset.Assignee__c)) {
                        asset.ExamResult__c = ContactToExamMap5.get(asset.Assignee__c).Id;
                        ContactToAssetMap5.put(asset.Assignee__c, asset);
                    }
                }
            }
            
            
            //  Set This Record to Lookup on Asset
            if (ContactToAssetMap5.size() > 0) {
                update ContactToAssetMap5.values();
            }
            
            
            //  Map Latest Certification to Latest SG AML Exam Result
            Map<Id, Asset> ContactToAssetMap3 = new Map<Id, Asset>();
            for (Asset asset : [
                SELECT
                Id,
                ExamResult__c,
                CreatedDate,
                CC_Product__r.ProductCategory__c,
                Status__c,
                Assignee__c
                FROM
                Asset
                WHERE
                Assignee__c
                IN :ContactToExamMap3.keySet()
                AND
                Enterprise_Product_HL__c = 'SG-AML-Regime'
                AND
                CC_Product__r.ProductCategory__c = :'Certifications'
                AND
                Status__c = :'Active'
                AND
                EAD_created__c != TRUE
                ORDER BY
                CreatedDate DESC
            ]) {
                //  Only Add Asset to Map if Not Added Already (First Asset)
                if (!ContactToAssetMap3.containsKey(asset.Assignee__c)) {
                    if (ContactToExamMap3.containsKey(asset.Assignee__c)) {
                        asset.ExamResult__c = ContactToExamMap3.get(asset.Assignee__c).Id;
                        ContactToAssetMap3.put(asset.Assignee__c, asset);
                    }
                }
            }
            
            //  Set This Record to Lookup on Asset
            if (ContactToAssetMap3.size() > 0) {
                update ContactToAssetMap3.values();
            }
            
        }
    }
    @Future(Callout=true)
    public static void SendContactInfo(Set<Id> ContactIds) {
        
        PearsonVueIntegration__c pv = PearsonVueIntegration__c.getOrgDefaults();
        wsPearsonvueComRtiCddSchema.extendedFieldsType eetype = new wsPearsonvueComRtiCddSchema.extendedFieldsType();
        wsPearsonvueComRtiCddSchema.clientQuestionType cctype = new wsPearsonvueComRtiCddSchema.clientQuestionType();
        wsPearsonvueComRtiCddSchema.candidatePrefType cddtype = new wsPearsonvueComRtiCddSchema.candidatePrefType();
        wsPearsonvueComRtiCddSchema.customFieldsType custype = new wsPearsonvueComRtiCddSchema.customFieldsType();
        wsPearsonvueComRtiCddSchema.candidateNameType cdtype = new wsPearsonvueComRtiCddSchema.candidateNameType();
        wsPearsonvueComRtiCddSchema.webAccountInfoType watype = new wsPearsonvueComRtiCddSchema.webAccountInfoType();
        wsPearsonvueComRtiCddSchema.primaryAddressType patype = new wsPearsonvueComRtiCddSchema.primaryAddressType();
        wsPearsonvueComRtiCddSchema.nativePrimaryAddressType npatype = new wsPearsonvueComRtiCddSchema.nativePrimaryAddressType();
        wsPearsonvueComRtiCddSchema.phoneType phonetype = new wsPearsonvueComRtiCddSchema.phoneType();
        wsPearsonvueComRtiCddWsdl.CDDSOAPPort partner = new wsPearsonvueComRtiCddWsdl.CDDSOAPPort();
        wsPearsonvueComRtiCddSchema.cddResponseType Result = new wsPearsonvueComRtiCddSchema.cddResponseType();
        wsPearsonvueComRtiCddSchema.candidatePrefsType cddstype = new wsPearsonvueComRtiCddSchema.candidatePrefsType();
        
        List<wsPearsonvueComRtiCddSchema.alternateAddressType> aatypeList = new List<wsPearsonvueComRtiCddSchema.alternateAddressType>();
        List<wsPearsonvueComRtiCddSchema.candidatePrefType> cddtypeList = new List<wsPearsonvueComRtiCddSchema.candidatePrefType>();
        List<wsPearsonvueComRtiCddSchema.candidatePrefsType> cddstypeList = new List<wsPearsonvueComRtiCddSchema.candidatePrefsType>();
        Map<Id, wsPearsonvueComRtiCddSchema.cddResponseType> ResultcntMap = new Map<Id, wsPearsonvueComRtiCddSchema.cddResponseType>();
        
        
        Datetime LastUpdatedDatetime;
        String LastUpdatedDatetimeformatedDt;
        String clientCandidateID;
        String Street;
        String asiaStreet;
        List<String> finalStreet = new List<String>();
        String Street1;
        String Street2;
        String Street3;
        List<String> asiaFinalStreet = new List<String>();
        String asiaStreet1;
        String asiaStreet2;
        String asiaStreet3;
        String Langpref;
        partner.clientCertName_x = pv.Certificate_Name__c;
        partner.clientCertPasswd_x = pv.Certificate_Password__c;
        
        
        List<Account> contactList = [
            SELECT
            Id,
            FirstName,
            Hidden_Legal_First_Name__pc,
            Is_Work_Phone_Primary__pc,
            PersonMobilePhone,
            PersonHomePhone,
            Is_Home_Phone_Primary__pc,
            Is_Mobile_Phone_Primary__pc,
            Hidden_Legal_Last_Name__pc,
            Legal_Middle_Name__pc,
            LastName,
            Language_Preference__c,
            PersonEmail,
            Native_First_Name__pc,
            Address_Chinese__pc,
            Asia_City__pc,
            Native_Last_Name__pc,
            ccrz__CompanyName__pc,
            Locale_for_PearsonVUE__pc,
            Member_Number__pc,
            Salutation,
            Middle_Name__pc,
            Phone,
            BillingStreet,
            LastModifiedDate,
            BillingCity,
            BillingCountry,
            BillingPostalCode,
            BillingState
            FROM
            Account
            WHERE
            Id
            IN :ContactIds
        ];
        
        try {
            for (Account c : contactList) {
                if (c.FirstName != null && c.LastName != null && c.BillingCountry != null && c.Phone != null) {
                    List<String> prefOptn = new List<String>();
                    prefOptn.clear();
                    cddtypeList.clear();
                    cddstypeList.clear();
                    isVUERecursiveCheck = true;
                    isVUERecursiveCheckContact = true;
                    LastUpdatedDatetime = c.LastModifiedDate;
                    LastUpdatedDatetimeformatedDt = LastUpdatedDatetime.formatGmt('yyyy/MM/dd\' \'HH:mm:ss\' GMT\'');
                    clientCandidateID = c.Id;
                    cdtype.firstName = c.Hidden_Legal_First_Name__pc;
                    cdtype.lastName = c.Hidden_Legal_Last_Name__pc;
                    cdtype.middleName = c.Legal_Middle_Name__pc;
                    cdtype.salutation = c.Salutation;
                    cddtype.prefType = 'LocalePreference';
                    if(c.Language_Preference__c == 'en_US'){
                        Langpref = 'en-US';
                    }
                    else if(c.Language_Preference__c == 'zh_CN'){
                        Langpref = 'zh-CN';
                    }
                    else if(c.Language_Preference__c == 'fr'){
                        Langpref = 'fr-FR';
                    }
                    else if(c.Language_Preference__c == 'de'){
                        Langpref = 'de-DE';
                    }
                    else if(c.Language_Preference__c == 'ja'){
                        Langpref = 'ja-JP';
                    }
                    else if(c.Language_Preference__c == 'pt_BR'){
                        Langpref = 'pt-BR';
                    }
                    else if(c.Language_Preference__c == 'es'){
                        Langpref = 'es-ES';
                    }
                    else{
                        Langpref = 'en-US';
                    }
                    
                    
                    prefOptn.add(Langpref);
                    cddtype.prefOption = prefOptn;
                    cddtypeList.add(cddtype);
                    cddstype.candidatePref = cddtypeList;
                    cddstypeList.add(cddstype);
                    
                    watype.email = c.PersonEmail;
                    //watype.userName=c.Email;
                    //watype.password=c.Member_Number__c;
                    Street = c.BillingStreet;
                    if (Street.length() > 40) {
                        finalStreet = splitStreetAddress(Street).split('acamssplit', 3);
                        Street1 = finalStreet[0];
                        Street2 = finalStreet[1];
                        Street3 = finalStreet[2];
                        patype.address1 = Street1;
                        patype.address2 = Street2;
                        patype.address3 = Street3;
                    } else {
                        patype.address1 = Street;
                    }
                    
                    patype.city = c.BillingCity;
                    //FSA - 55 FSA - 55a FSA - 55b
                    if ( String.isBlank( c.ccrz__CompanyName__pc ) ){
                        patype.companyName = '';
                    }else if (c.ccrz__CompanyName__pc.length() > 48){
                        patype.companyName = c.ccrz__CompanyName__pc.substring(0, 47);
                    }
                    else{
                        patype.companyName = c.ccrz__CompanyName__pc;
                    }
                    if (c.BillingCountry != null) {
                        patype.country = ACAMSUtil.getISO3Country(c.BillingCountry);
                        phonetype.phoneCountryCode = ACAMSUtil.getPhonecode(c.BillingCountry);
                    }
                    patype.postalCode = c.BillingPostalCode;
                    if (c.BillingState != null) {
                        patype.state = c.BillingState;
                    }
                    patype.addressType = 'Home';
                    String phone;
                    String phoneCntryCode;
                    if (c.Is_Work_Phone_Primary__pc && c.Phone != null) {
                        phone = c.Phone;
                    } else if (c.Is_Home_Phone_Primary__pc && c.PersonHomePhone != null) {
                        phone = c.PersonHomePhone;
                    } else if (c.Is_Mobile_Phone_Primary__pc && c.PersonMobilePhone != null) {
                        phone = c.PersonMobilePhone;
                    }else{
                        phone= c.phone;
                    }
                    if(phone.startsWith('+')){
                        phoneCntryCode = '+' + phone.substringBetween('+',' ');
                        phone = phoneCntryCode.difference(phone);
                        
                    }
                    else{
                        if (c.BillingCountry != null) {
                            phoneCntryCode = ACAMSUtil.getPhonecode(c.BillingCountry);
                        }
                        
                        
                    }
                    
                    if (phone != null) {
                        if (phone.contains('+')) {
                            phone = phone.remove('+');
                        }
                        if (phoneCntryCode.contains('+')) {
                            phoneCntryCode = phoneCntryCode.remove('+');
                        }
                        phone = phone.deleteWhitespace();
                        phonetype.phoneCountryCode = phoneCntryCode;
                        phonetype.phoneNumber = phone;
                        
                        patype.phone = phonetype;
                    }
                    
                    // native info section logic start fsa-2166    
                    if(c.Address_Chinese__pc != null && String.isNotBlank(c.Address_Chinese__pc) && String.isNotEmpty(c.Address_Chinese__pc) && c.Address_Chinese__pc != ''){
                        asiaStreet = c.Address_Chinese__pc;                        
                        if (asiaStreet.length() > 40) {
                            asiaFinalStreet = splitStreetAddress(asiaStreet).split('acamssplit', 3);
                            asiaStreet1 = asiaFinalStreet[0];
                            asiaStreet2 = asiaFinalStreet[1];
                            asiaStreet3 = asiaFinalStreet[2];
                            npatype.address1 = asiaStreet1;
                            npatype.address2 = asiaStreet2;
                            npatype.address3 = asiaStreet3;
                        } else {
                            npatype.address1 = asiaStreet;
                        }
                    } else {  
                        npatype.address1 = '*';
                        npatype.address2 = '*';
                        npatype.address3 = '*';                     
                    }  
                    
                    npatype.language = 'UKN';
                    npatype.potentialMismatch = true;
                    
                    if(c.Native_First_Name__pc != null && String.isNotBlank(c.Native_First_Name__pc) && String.isNotEmpty(c.Native_First_Name__pc)&& c.Native_First_Name__pc != '')
                        npatype.firstName = c.Native_First_Name__pc;
                    else 
                        npatype.firstName = '*';
                    
                    if(c.Native_Last_Name__pc != null && String.isNotBlank(c.Native_Last_Name__pc) && String.isNotEmpty(c.Native_Last_Name__pc) && c.Native_Last_Name__pc != '')
                        npatype.lastName = c.Native_Last_Name__pc;
                    else 
                        npatype.lastName = '*';
                    
                    if(c.Asia_City__pc != null && String.isNotBlank(c.Asia_City__pc) && String.isNotEmpty(c.Asia_City__pc) && c.Asia_City__pc != '')
                        npatype.city = c.Asia_City__pc;
                    else 
                        npatype.city = '*';
                    
                    patype.nativeAddress = npatype;                     
                    // native info section logic end fsa-2166  
                    
                    Result = partner.importCandidateDemographics(cdtype, watype, LastUpdatedDatetimeformatedDt, patype, aatypeList, eetype, cctype, cddstypeList, custype, clientCandidateID, pv.Client_ID__c);
                    if (Result != null) {
                        ResultcntMap.put(c.Id, Result);
                    }
                }
            }
        } catch (Exception ex) {
            if (ex.getMessage() != null) {
                createExceptionCase(ex.getMessage(), ex.getStackTraceString(), ex.getTypeName(), ' ');
            }
        }
        
        
        for (String key : ResultcntMap.keySet()) {
            wsPearsonvueComRtiCddSchema.cddResponseType Resultcntobj = ResultcntMap.get(key);
            if (Resultcntobj != null) {
                updateIntStatusOnAsset(key, 'Contact', Resultcntobj.message, Resultcntobj.status);
                if (Resultcntobj.message != null) {
                    createExceptionCase(Resultcntobj.message, ' ', ' ', key);
                }
                if (Resultcntobj.candidateID != null && Resultcntobj.clientCandidateID != null) {
                    updateContactVUE(Resultcntobj.clientCandidateID, Resultcntobj.candidateID);
                }
            }
        }
    }
    
    @Future(Callout=true)
    public static void SendEADInfo(Set<Id> eadIds, String operation, String type) {
        PearsonVueIntegration__c pv = PearsonVueIntegration__c.getOrgDefaults();
        wsPearsonvueComRtiEadWsdl.EADSOAPPort partner = new wsPearsonvueComRtiEadWsdl.EADSOAPPort();
        wsPearsonvueComRtiEadSchema.eadResponseType Result = new wsPearsonvueComRtiEadSchema.eadResponseType();
        wsPearsonvueComRtiEadSchema.clientAccommodationsType catype = new wsPearsonvueComRtiEadSchema.clientAccommodationsType();
        Map<Id, wsPearsonvueComRtiEadSchema.eadResponseType> ResultMap = new Map<Id, wsPearsonvueComRtiEadSchema.eadResponseType>();
        
        Datetime LastUpdatedDatetime;
        Datetime firstapptDatetime;
        Datetime lastapptDatetime;
        String LastUpdatedDatetimeformatedDt;
        String clientCandidateID;
        String examSeriesCode;
        String eligibilityApptDateFirst;
        String eligibilityApptDateLast;
        String clientAuthorizationID;
        
        
        partner.clientCertName_x = pv.Certificate_Name__c;
        partner.clientCertPasswd_x = pv.Certificate_Password__c;
        List<Exam_Results__c> examResultList = [
            SELECT
            Id,
            Asset__c,
            Contact__c,Account__c,
            examSeriesCode__c,
            eligibilityApptDateFirst__c,
            eligibilityApptDateLast__c,
            LastModifiedDate
            FROM
            Exam_Results__c
            WHERE
            Id
            IN
            :eadIds
        ];
        try {
            for (Exam_Results__c e : examResultList) {
                if (e.examSeriesCode__c != null && e.eligibilityApptDateFirst__c != null && e.eligibilityApptDateLast__c != null) {
                    isVUERecursiveEADCheck = true;
                    clientAuthorizationID = e.Id;
                    clientCandidateID = e.Account__c;
                    examSeriesCode = e.examSeriesCode__c;
                    firstapptDatetime = e.eligibilityApptDateFirst__c;
                    eligibilityApptDateFirst = firstapptDatetime.format('yyyy/MM/dd HH:mm:ss');
                    lastapptDatetime = e.eligibilityApptDateLast__c;
                    eligibilityApptDateLast = lastapptDatetime.format('yyyy/MM/dd HH:mm:ss');
                    LastUpdatedDatetime = e.LastModifiedDate;
                    LastUpdatedDatetimeformatedDt = LastUpdatedDatetime.formatGmt('yyyy/MM/dd\' \'HH:mm:ss\' GMT\'');
                    Result = partner.importExamAuthorization(clientCandidateID, Integer.valueOf(pv.ExamAuthorizationCount__c), examSeriesCode, eligibilityApptDateFirst, eligibilityApptDateLast, LastUpdatedDatetimeformatedDt, catype, operation, clientAuthorizationID, pv.Client_ID__c);
                    if (Result != null) {
                        ResultMap.put(e.Asset__c, Result);
                    }
                }
            }
        } catch (Exception ex) {
            if (ex.getMessage() != null) {
                createExceptionCase(ex.getMessage(), ex.getStackTraceString(), ex.getTypeName(), ' ');
            }
        }
        
        for (String key : ResultMap.keySet()) {
            wsPearsonvueComRtiEadSchema.eadResponseType resultObj = ResultMap.get(key);
            if (resultObj != null) {
                updateIntStatusOnAsset(key, type, resultObj.message, resultObj.status);
                
                if (resultObj.message != null) {
                    createExceptionCase(resultObj.message, ' ', ' ', key);
                }
                if (resultObj.authorizationID != null && resultObj.clientAuthorizationID != null) {
                    updateEADVUE(resultObj.authorizationID, resultObj.clientAuthorizationID, resultObj.date_x);
                }
            }
            
        }
        
    }
    
    
    public static void updateSGAMLAsset(Set<Id> rgContactIds) {
        isVUERecursiveSGAMLCheck = true;
        List<Asset> assetList = new List<Asset>();
        assetList = [
            SELECT
            Id,
            Assignee__c,
            SG_AML_REGIME_Exam_Application_Approved__c
            FROM
            Asset
            WHERE
            Assignee__c
            IN :rgContactIds
            AND
            Paid_Cert__c = TRUE
            AND
            Status__c = 'Active'
            AND
            Name = :'Certifications'
            AND
            Enterprise_Product_HL__c = :'SG-AML-Regime'
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        for (Asset a : assetList) {
            a.SG_AML_REGIME_Exam_Application_Approved__c = true;
            
        }
        update assetList;
    }
    
    public static String splitStreetAddress(String street) {
        String street1;
        String street2;
        String street3;
        String finalString;
        Integer countComma;
        Integer countSpace;
        List<String> splitString = new List<String>();
        Boolean hasCommas = street.contains(',');
        Boolean hasSpaces = street.contains(' ');
        
        countComma = street.countMatches(',');
        countSpace = street.countMatches(' ');
        if (hasCommas && !hasSpaces) {
            splitString = street.split(',', 3);
            if (countComma == 1) {
                street1 = splitString[0];
                street2 = splitString[1];
            } else if (countComma >= 2) {
                street1 = splitString[0];
                street2 = splitString[1];
                street3 = splitString[2];
            }
        } else if (hasCommas && hasSpaces) {
            if (countComma == 1 && countSpace > 1) {
                splitString = street.split(' ', 5);
                if (countSpace == 1) {
                    street1 = splitString[0];
                    street2 = splitString[1];
                }
                if (countSpace == 2) {
                    street1 = splitString[0];
                    street2 = splitString[1];
                    street3 = splitString[2];
                }
                if (countSpace == 3) {
                    street1 = splitString[0] + ' ' + splitString[1];
                    street2 = splitString[2];
                    street3 = splitString[3];
                }
                if (countSpace >= 4) {
                    street1 = splitString[0] + ' ' + splitString[1];
                    street2 = splitString[2] + ' ' + splitString[3];
                    street3 = splitString[4];
                }
            }
            if (countComma > 1 && countSpace > 1) {
                splitString = street.split(',', 5);
                if (countComma == 1) {
                    street1 = splitString[0];
                    street2 = splitString[1];
                }
                if (countComma == 2) {
                    street1 = splitString[0];
                    street2 = splitString[1];
                    street3 = splitString[2];
                }
                if (countComma == 3) {
                    street1 = splitString[0] + ', ' + splitString[1];
                    street2 = splitString[2];
                    street3 = splitString[3];
                }
                if (countComma > 3) {
                    
                    street1 = splitString[0] + ', ' + splitString[1];
                    street2 = splitString[2] + ', ' + splitString[3];
                    street3 = splitString[4];
                }
            }
            
        } else {
            splitString = street.split(' ', 5);
            if (countSpace == 1) {
                street1 = splitString[0];
                street2 = splitString[1];
            }
            if (countSpace == 2) {
                street1 = splitString[0];
                street2 = splitString[1];
                street3 = splitString[2];
            }
            if (countSpace == 3) {
                street1 = splitString[0] + ' ' + splitString[1];
                street2 = splitString[2];
                street3 = splitString[3];
            }
            if (countSpace >= 4) {
                street1 = splitString[0] + ' ' + splitString[1];
                street2 = splitString[2] + ' ' + splitString[3];
                street3 = splitString[4];
            }
        }
        finalString = street1 + 'acamssplit' + street2 + 'acamssplit' + street3;
        return finalString;
    }
    
    public static void createExceptionCase(String message, String stackTrace, String getTypeName, String contactId) {
        if (message != null && message != ' ' && String.isNotBlank(message) && String.isNotEmpty(message)) {
            Case c = new Case();
            c.Type = 'Financial Services IT';
            c.Origin = 'Apex Exception';
            c.Description = 'Id : ' + contactId + '\n\n' + 'Message : ' + message + '\n\n' + 'StackTrace : ' + stackTrace;
            
            c.Subject = 'Pearson VUE Callout Exception' + ' (Exception Type : ' + getTypeName + ')';
            
            insert c;
        }
    }
    
    public static void updateContactVUE(String ClientCandidateID, Integer CandidateID) {
        Account account = new Account();
        account = [
            SELECT
            Id,
            Pearson_Vue_ID__pc
            FROM
            Account
            WHERE
            Id = :ClientCandidateID
            LIMIT 1
        ];
        account.Pearson_Vue_ID__pc = String.valueOf(CandidateID);
        
        update account;
    }
    
    public static void updateEADVUE(Integer authorizationID, String clientAuthorizationID, String responsedate) {
        Exam_Results__c examrslt = new Exam_Results__c();
        examrslt = [
            SELECT
            Id,
            clientAuthorizationID__c,
            authorizationID__c,
            Date_Response_was_Sent__c
            FROM
            Exam_Results__c
            WHERE
            Id = :clientAuthorizationID
            LIMIT 1
        ];
        examrslt.authorizationID__c = String.valueOf(authorizationID);
        examrslt.clientAuthorizationID__c = clientAuthorizationID;
        examrslt.Date_Response_was_Sent__c = responsedate;
        
        update examrslt;
    }
    
    public static void updateIntStatusOnAsset(Id assetId, String type, String message, String status) {
        Asset assetObj = new Asset();
        List<Asset> contactAssets = new List<Asset>();
        if (!String.isBlank(type) && type.equalsIgnoreCase('contact')) {
            contactAssets = [
                SELECT Id,Name,Latest_Integration_Response__c,Accountid,PV_Contact_Integration_Status__c
                FROM Asset
                WHERE
                //FSA - 220
                //Accountid = :assetId
                Assignee__r.AccountId = :assetId
                AND EAD_created__c = TRUE
                ORDER BY CreatedDate DESC //LIMIT 1 //FSA-180
            ];
        } else if (type == 'original' || type == 'extension' || type == 'retake') {
            assetObj = [SELECT Id,Latest_Integration_Response__c,PV_Contact_Integration_Status__c FROM Asset WHERE Id = :assetId LIMIT 1];
        }
        
        if (type == 'original' && status == 'Accepted') {
            assetObj.Latest_Integration_Response__c = 'EAD information successfully sent to PV';
        } else if (type == 'original' && status != 'Accepted' && message != null) {
            assetObj.Latest_Integration_Response__c = 'Error occurred while sending EAD information to VUE';
        } else if (type == 'extension' && status == 'Accepted') {
            assetObj.Latest_Integration_Response__c = 'Extension information successfully sent to PV';
        } else if (type == 'extension' && status != 'Accepted') {
            assetObj.Latest_Integration_Response__c = 'Error occurred while sending Extension information to VUE';
        } else if (type == 'retake' && status == 'Accepted') {
            assetObj.Latest_Integration_Response__c = 'Retake information successfully sent to PV';
        } else if (type == 'retake' && status == 'Accepted') {
            assetObj.Latest_Integration_Response__c = 'Error occurred while sending Retake information to VUE';
        }
        // FSA-180 for loop
        List<Asset> asstsTOUpdate = new List<Asset>();
        for(Asset ast:contactAssets){
            if (type == 'contact' && status == 'Accepted') {
                ast.PV_Contact_Integration_Status__c = 'Contact information successfully sent to PV';
            } else if (type == 'contact' && status != 'Accepted') {
                ast.PV_Contact_Integration_Status__c = 'Error occurred while sending Contact information to PV';
            }
            asstsTOUpdate.add(ast);
        }
        
        if(asstsTOUpdate.size()>0){
            update asstsTOUpdate;
        } else if(assetObj.id!=null){    
            update assetObj;
        }
    }
}