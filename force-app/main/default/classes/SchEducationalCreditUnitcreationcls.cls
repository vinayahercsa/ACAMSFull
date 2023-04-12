global class SchEducationalCreditUnitcreationcls implements Schedulable{
    
        global void execute(SchedulableContext SC) {
         
        EducationalCreditUnitcreationcls  objBatch = new EducationalCreditUnitcreationcls();
         Id Batchid = database.executebatch(objBatch);

    }

}