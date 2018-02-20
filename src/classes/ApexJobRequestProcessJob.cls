global class ApexJobRequestProcessJob
        implements Database.Batchable<SObject> {

    global void execute(Database.BatchableContext context, List<SObject> records) {
        for (ApexJobRequest__c eachRequest : (List<ApexJobRequest__c>)records) {
            try {
                Requestable job =
                        (Requestable)JSON.deserialize(
                                eachRequest.Body__c,
                                Type.forName(eachRequest.ApexClassName__c));

                job.execute(context);
                eachRequest.Status__c = 'Success';
            }
            catch (System.Exception caught) {
                eachRequest.Status__c = 'Error';
                eachRequest.ErrorMessage__c = caught.getMessage();
                eachRequest.ErrorStackTrace__c = caught.getStackTraceString();
            }
        }

        update records;
    }

    global void finish(Database.BatchableContext context) {
        /* do nothing */
    }

    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([
            SELECT
                ApexClassName__c,
                Body__c,
                Status__c,
                Id
            FROM ApexJobRequest__c
            WHERE Status__c = 'Submitted'
        ]);
    }
}