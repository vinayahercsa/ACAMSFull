global class schBatchAssetStatusUpdation  implements Schedulable {
   global void execute(SchedulableContext SC) {
      BatchAssetStatusUpdation  objBatch = new BatchAssetStatusUpdation();  
       Id Batchid =database.executebatch(objBatch,integer.valueOf(label.ExpiredAssetsBatchScope)); 
   }
}