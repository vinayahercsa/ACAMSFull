/*
 * Class Name: DMLUtility - Class Utility for DML operations.
 * 5/16/2017           mmurphy               Created class.
*/

public class DMLUtility {
    public class customException extends Exception {}

    public static void InsertSObjects(List<SObject> objects) {
        Database.SaveResult[] srList = Database.Insert(objects, false);

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('*****DMLUtility.Insert - Successfully inserted objects: ' + sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('*****DMLUtility.Insert - The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('*****DMLUtility.Insert - SObject fields that affected this error: ' + err.getFields());
                    customException ex = new customException('DML Error: ' + err.getStatusCode() + ': ' + err.getMessage());
                    
                }
            }
        }
    }

    public static void UpdateSObjects(List<SObject> objects) {
        Database.SaveResult[] srList = Database.Update(objects, false);

        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                System.debug('*****DMLUtility.Update - Successfully Update objects: ' + sr.getId());
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('*****DMLUtility.Update - The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('*****DMLUtility.Update - SObject fields that affected this error: ' + err.getFields());
                    customException ex = new customException('DML Error: ' + err.getStatusCode() + ': ' + err.getMessage());
                    
                }
            }
        }
    }

    public static void UpserSObjects(List<SObject> objects) {
        Database.UpsertResult[] urList = Database.Upsert(objects, false);

        for (Database.UpsertResult ur : urList) {
            if (ur.isSuccess()) {
                System.debug('*****DMLUtility.Upsert - Successfully Upsert objects: ' + ur.getId());
            }
            else {
                for(Database.Error err : ur.getErrors()) {
                    System.debug('*****DMLUtility.Upsert - The following error has occurred: ' + err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('*****DMLUtility.Upsert - SObject fields that affected this error: ' + err.getFields());
                    customException ex = new customException('DML Error: ' + err.getStatusCode() + ': ' + err.getMessage());
                    
                }
            }
        }
    }
}