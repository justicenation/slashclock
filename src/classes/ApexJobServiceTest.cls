@isTest
private class ApexJobServiceTest {

    @isTest
    private static void submitAndExecuteTwice() {

        // Given
        ApexJobService apexJob =
                ApexJobService.getInstance(TimeEntryVerifyTimeZoneJob.class);

        // When
        Test.startTest();

        Id firstRequestId = apexJob.submitAndProcess(
                new TimeEntryVerifyTimeZoneJob(new List<Id>()));

        Id firstBatchApexJobId = apexJob.getBatchApexJobId();

        System.assertNotEquals(null, firstBatchApexJobId,
                '1st ' + Schema.SObjectType.AsyncApexJob.fields.Id.label);

        Id secondRequestId = apexJob.submitAndProcess(
                new TimeEntryVerifyTimeZoneJob(new List<Id>()));

        Id secondBatchApexJobId = apexJob.getBatchApexJobId();

        System.assertEquals(firstBatchApexJobId, secondBatchApexJobId,
                '2nd ' + Schema.SObjectType.AsyncApexJob.fields.Id.label);

        // Then
        Test.stopTest();

        System.assertNotEquals(firstRequestId ,secondRequestId,
                Schema.SObjectType.ApexJobRequest__c.fields.Id.label);
    }

    @isTest
    private static void submitAndExecute() {

        // Given
        ApexJobService apexJob =
                ApexJobService.getInstance(TimeEntryVerifyTimeZoneJob.class);

        // When
        Test.startTest();

        Id requestId = apexJob.submitAndProcess(
                new TimeEntryVerifyTimeZoneJob(new List<Id>()));

        System.assertNotEquals(null, apexJob.getBatchApexJobId(),
                Schema.SObjectType.AsyncApexJob.fields.Id.label);

        // Then
        Test.stopTest();

        System.assertNotEquals(null , requestId,
                Schema.SObjectType.ApexJobRequest__c.fields.Id.label);

        List<AsyncApexJob> thenJobs = [
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
                JobType = 'BatchApex'
            ORDER BY CreatedDate ASC
        ];

        System.assertEquals(
                'Completed',
                thenJobs[0].Status,
                Schema.SObjectType.AsyncApexJob.fields.Status.label);
    }

    @isTest
    private static void submitTimeEntryVerifyTimeZoneJob() {

        // Given
        TimeEntryVerifyTimeZoneJob job =
                new TimeEntryVerifyTimeZoneJob(new List<Id>());

        // When
        Test.startTest();

        Id requestId = ApexJobService.getInstance(
                TimeEntryVerifyTimeZoneJob.class).submit(job);

        // Then
        Test.stopTest();

        ApexJobRequest__c thenRequest = getApexJobRequest(requestId);

        System.assertEquals(
                TimeEntryVerifyTimeZoneJob.class.getName(),
                thenRequest.ApexClassName__c,
                Schema.SObjectType.ApexJobRequest__c.fields.ApexClassName__c.label);

        System.assertEquals(
                '{"contactIds":[]}',
                thenRequest.Body__c,
                Schema.SObjectType.ApexJobRequest__c.fields.Body__c.label);
    }

    private static ApexJobRequest__c getApexJobRequest(Id recordId) {
        return [
            SELECT
                ApexClassName__c,
                Body__c,
                ErrorMessage__c,
                ErrorStackTrace__c,
                Status__c,
                Id
            FROM ApexJobRequest__c
            WHERE Id = :recordId
        ];
    }
}