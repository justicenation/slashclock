@isTest
private class ApexJobRequestProcessJobTest {

    @isTest
    private static void processEmptyVerifyTimeZoneJob() {

        // Given
        TestService thisTest = TestService.getInstance();

        ApexJobRequest__c givenRequest = new ApexJobRequest__c(
                ApexClassName__c = TimeEntryVerifyTimeZoneJob.class.getName(),
                Body__c = JSON.serialize(
                        new TimeEntryVerifyTimeZoneJob(new List<Id>())));

        insert givenRequest;

        System.assertEquals(
                'Submitted',
                thisTest.getApexJobRequest(givenRequest.Id).Status__c,
                Schema.SObjectType.ApexJobRequest__c.fields.Status__c.label);

        // When
        Test.startTest();

        Database.executeBatch(new ApexJobRequestProcessJob());

        // Then
        Test.stopTest();

        System.assertEquals(
                'Success',
                thisTest.getApexJobRequest(givenRequest.Id).Status__c,
                Schema.SObjectType.ApexJobRequest__c.fields.Status__c.label);
    }

    @isTest
    private static void processInvalidJob() {

        // Given
        TestService thisTest = TestService.getInstance();

        ApexJobRequest__c givenRequest = new ApexJobRequest__c(
                ApexClassName__c = 'DoesNotExistJob',
                Body__c = 'foobar');

        insert givenRequest;

        System.assertEquals(
                'Submitted',
                thisTest.getApexJobRequest(givenRequest.Id).Status__c,
                Schema.SObjectType.ApexJobRequest__c.fields.Status__c.label);

        // When
        Test.startTest();

        Database.executeBatch(new ApexJobRequestProcessJob());

        // Then
        Test.stopTest();

        System.assertEquals(
                'Error',
                thisTest.getApexJobRequest(givenRequest.Id).Status__c,
                Schema.SObjectType.ApexJobRequest__c.fields.Status__c.label);

        System.assertEquals(
                'Attempt to de-reference a null object',
                thisTest.getApexJobRequest(givenRequest.Id).ErrorMessage__c,
                Schema.SObjectType.ApexJobRequest__c.fields.ErrorMessage__c.label);
    }
}