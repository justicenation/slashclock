public class ApexJobService {

    private static Map<Type, ApexJobService> instanceMap =
            new Map<Type, ApexJobService>();

    private Type jobType;

    public ApexJobService(Type jobType) {
        this.jobType = jobType;
    }

    public static ApexJobService getInstance(Type jobType) {
        if (!instanceMap.containsKey(jobType)) {
            instanceMap.put(jobType, new ApexJobService(jobType));
        }

        return instanceMap.get(jobType);
    }

    /**
     * Execute a batch job for processing Apex job requests if no such
     * batch job is currently running
     *
     * @return The ID of the new or already running batch job
     */
    public Id executeBatch() {
        List<AsyncApexJob> pendingBatches = this.getPendingBatches();

        return pendingBatches.isEmpty()
                ? Database.executeBatch(new ApexJobRequestProcessJob(), 1)
                : pendingBatches[0].Id;
    }

    /**
     * @see https://developer.salesforce.com/docs/atlas.en-us.api.meta/api/sforce_api_objects_asyncapexjob.htm
     */
    public List<AsyncApexJob> getPendingBatches() {
        return [
            SELECT
                Status,
                Id
            FROM AsyncApexJob
            WHERE
                ApexClassId IN (
                    SELECT Id
                    FROM ApexClass
                    WHERE Name = :ApexJobRequestProcessJob.class.getName()
                ) AND
                JobType = 'BatchApex' AND
                Status NOT IN ('Aborted', 'Completed', 'Failed')
        ];
    }

    public Id submit(Requestable job) {

        // Construct the job request
        ApexJobRequest__c request = new ApexJobRequest__c(
                ApexClassName__c = this.jobType.getName(),
                Body__c = JSON.serialize(job));

        // Create the request and return the ID
        insert request;
        return request.Id;
    }

    public Id submitAndProcess(Requestable job) {
        Id requestId = submit(job);
        this.executeBatch();
        return requestId;
    }
}