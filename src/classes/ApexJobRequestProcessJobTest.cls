@isTest
private class ApexJobRequestProcessJobTest {

    @isTest
    private static void processEmptyVerifyTimeZoneJob() {

        // Given
        ApexJobRequest__c givenRequest = new ApexJobRequest__c(
                ApexClassName__c = TimeEntryVerifyTimeZoneJob.class.getName(),
                Body__c = JSON.serialize(
                        new TimeEntryVerifyTimeZoneJob(new List<Id>())));

        insert givenRequest;

        System.assertEquals(
                'Submitted',
                getApexJobRequest(givenRequest).Status__c,
                Schema.SObjectType.ApexJobRequest__c.fields.Status__c.label);

        // When
        Test.startTest();

        Database.executeBatch(new ApexJobRequestProcessJob());

        // Then
        Test.stopTest();

        System.assertEquals(
                'Success',
                getApexJobRequest(givenRequest).Status__c,
                Schema.SObjectType.ApexJobRequest__c.fields.Status__c.label);
    }

    @isTest
    private static void processInvalidJob() {

        // Given
        ApexJobRequest__c givenRequest = new ApexJobRequest__c(
                ApexClassName__c = 'DoesNotExistJob',
                Body__c = 'foobar');

        insert givenRequest;

        System.assertEquals(
                'Submitted',
                getApexJobRequest(givenRequest).Status__c,
                Schema.SObjectType.ApexJobRequest__c.fields.Status__c.label);

        // When
        Test.startTest();

        Database.executeBatch(new ApexJobRequestProcessJob());

        // Then
        Test.stopTest();

        System.assertEquals(
                'Error',
                getApexJobRequest(givenRequest).Status__c,
                Schema.SObjectType.ApexJobRequest__c.fields.Status__c.label);

        System.assertEquals(
                'Attempt to de-reference a null object',
                getApexJobRequest(givenRequest).ErrorMessage__c,
                Schema.SObjectType.ApexJobRequest__c.fields.ErrorMessage__c.label);
    }

    private static ApexJobRequest__c getApexJobRequest(ApexJobRequest__c record) {
        return [
            SELECT
                ErrorMessage__c,
                ErrorStackTrace__c,
                Status__c,
                Id
            FROM ApexJobRequest__c
            WHERE Id = :record.Id
        ];
    }
}