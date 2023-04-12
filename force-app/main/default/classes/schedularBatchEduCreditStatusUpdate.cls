global class schedularBatchEduCreditStatusUpdate implements Schedulable{
  global void execute(SchedulableContext SC) {
      BatchEduCreditStatusUpdate  objBatch = new BatchEduCreditStatusUpdate();  
       Id Batchid = Database.executebatch(objBatch,200);
   }
}