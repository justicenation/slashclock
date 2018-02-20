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

    public Id submit(Requestable job) {

        // Construct the job request
        ApexJobRequest__c request = new ApexJobRequest__c(
                ApexClassName__c = this.jobType.getName(),
                Body__c = JSON.serialize(job));

        // Create the request and return the ID
        insert request;
        return request.Id;
    }
}