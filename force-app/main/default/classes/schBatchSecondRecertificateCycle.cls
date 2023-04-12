global class schBatchSecondRecertificateCycle implements Schedulable {
    global void execute(SchedulableContext SC) {
        BatchSecondRecertificateCycle b = new BatchSecondRecertificateCycle(); 
        database.executebatch(b);
    } 
}