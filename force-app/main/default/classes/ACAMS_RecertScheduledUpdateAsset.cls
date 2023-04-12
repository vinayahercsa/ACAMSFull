global class ACAMS_RecertScheduledUpdateAsset implements Schedulable {

   global void execute(SchedulableContext sc) {
      ACAMS_RecertBatchUpdateAsset b = new  ACAMS_RecertBatchUpdateAsset (); 
      database.executebatch(b);
   
}
}