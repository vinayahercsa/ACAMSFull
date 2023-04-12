global class schBatchInsertAssetOnRecertCycle implements Schedulable{
    global void execute(SchedulableContext SC) {
        BatchInsertAssetOnRecertCycle b = new BatchInsertAssetOnRecertCycle(); 
        database.executebatch(b);
    }

}