@isTest
private class ApexJobServiceTest {

    @isTest
    private static void isExecuteBatchReady() {

        // Given
        TestService thisTest = TestService.getInstance();

        ApexJobService apexJob =
                ApexJobService.getInstance();

        System.assertEquals(true, apexJob.isExecuteBatchReady(),
                'ApexJobService is ready to execute batch');

        // When
        Test.startTest();

        Id requestId = apexJob.submitAndProcess(
                TimeEntryVerifyTimeZoneJob.class,
                new TimeEntryVerifyTimeZoneJob(new List<Id>()));

        System.assertEquals(false, apexJob.isExecuteBatchReady(),
                'ApexJobService should no longer be ready to execute batch');

        // Then
        Test.stopTest();

        System.assertNotEquals(null , requestId,
                Schema.SObjectType.ApexJobRequest__c.fields.Id.label);
    }

    @isTest
    private static void submitAndExecute() {

        // Given
        TestService thisTest = TestService.getInstance();
        
        ApexJobService apexJob =
                ApexJobService.getInstance();

        // When
        Test.startTest();

        Id requestId = apexJob.submitAndProcess(
                TimeEntryVerifyTimeZoneJob.class,
                new TimeEntryVerifyTimeZoneJob(new List<Id>()));

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
        TestService thisTest = TestService.getInstance();
        
        TimeEntryVerifyTimeZoneJob job =
                new TimeEntryVerifyTimeZoneJob(new List<Id>());

        // When
        Test.startTest();

        Id requestId = ApexJobService.getInstance().submit(
                TimeEntryVerifyTimeZoneJob.class, job);

        // Then
        Test.stopTest();

        ApexJobRequest__c thenRequest = thisTest.getApexJobRequest(requestId);

        System.assertEquals(
                TimeEntryVerifyTimeZoneJob.class.getName(),
                thenRequest.ApexClassName__c,
                Schema.SObjectType.ApexJobRequest__c.fields.ApexClassName__c.label);

        System.assertEquals(
                '{"contactIds":[]}',
                thenRequest.Body__c,
                Schema.SObjectType.ApexJobRequest__c.fields.Body__c.label);
    }
}