public with sharing class UpdateJob implements Queueable {

    private List<Sobject> records;

    public UpdateJob(List<Sobject> records) {
        this.records = records;
    }

    public void execute(QueueableContext context) {
        update this.records;
    }
}