@isTest
private class TimeEntryDataServiceTest {

    /**
     * Given a contact in the "America/New_York" time zone who has
     * the following unverified time entries, when the entries are
     * verified against the "America/New_York" time zone,
     * the times _NOT_ in 'America/New_York" should be updated to
     * reflect the correct local time.
     *
     * - 1st entry
     *   Start Time: 2/12/2018 9:15am America/Los_Angeles (GMT-08:00) (verified)
     *   End Time: 2/12/2018 5:00pm America/New_York (GMT-05:00) (unverified)
     *
     * - 2nd entry
     *   Start Time: 2/13/2018 9:15am Europe/London (GMT+00:00) (unverified)
     *   End Time: 2/13/2018 5:00pm Asia/Jerusalem (GMT+02:00) (unverified)
     *
     * - 3rd entry
     *   Start Time: 2/14/2018 9:15am Asia/Taipei (GMT+08:00) (unverified)
     *   End Time: N/A
     */
    @isTest
    private static void verifyTimeZoneNewYork() {

        // Test setup
        TestService thisTest = TestService.getInstance();
        thisTest.setupTimeEntryDataServiceTest();

        // Given
        Contact bugs = thisTest.getContact('Bunny (TEST)');

        List<TimeEntry__c> givenEntries = thisTest.getTimeEntries(bugs);

        // Start Time: 2/12/2018 9:15am America/Los_Angeles (verified)
        System.assertEquals(
                Datetime.newInstanceGmt(2018, 2, 12, 17, 15, 0),
                givenEntries[0].StartTime__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTime__c.label);

        System.assertEquals(
                'America/Los_Angeles',
                givenEntries[0].StartTimeZoneSidKey__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTimeZoneSidKey__c.label);

        System.assertEquals(
                true,
                givenEntries[0].HasVerifiedStartTimeZone__c,
                Schema.SObjectType.TimeEntry__c.fields.HasVerifiedStartTimeZone__c.label);

        // End Time: 2/12/2018 5:00pm America/New_York (unverified)
        System.assertEquals(
                Datetime.newInstanceGmt(2018, 2, 12, 22, 0, 0),
                givenEntries[0].EndTime__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTime__c.label);

        System.assertEquals(
                'America/New_York',
                givenEntries[0].EndTimeZoneSidKey__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTimeZoneSidKey__c.label);

        System.assertEquals(
                false,
                givenEntries[0].HasVerifiedEndTimeZone__c,
                Schema.SObjectType.TimeEntry__c.fields.HasVerifiedEndTimeZone__c.label);

        // Start Time: 2/13/2018 9:15am Europe/London (unverified)
        System.assertEquals(
                Datetime.newInstanceGmt(2018, 2, 13, 9, 15, 0),
                givenEntries[1].StartTime__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTime__c.label);

        System.assertEquals(
                'Europe/London',
                givenEntries[1].StartTimeZoneSidKey__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTimeZoneSidKey__c.label);

        System.assertEquals(
                false,
                givenEntries[1].HasVerifiedStartTimeZone__c,
                Schema.SObjectType.TimeEntry__c.fields.HasVerifiedStartTimeZone__c.label);

        // End Time: 2/13/2018 5:00pm Asia/Jerusalem (unverified)
        System.assertEquals(
                Datetime.newInstanceGmt(2018, 2, 13, 15, 0, 0),
                givenEntries[1].EndTime__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTime__c.label);

        System.assertEquals(
                'Asia/Jerusalem',
                givenEntries[1].EndTimeZoneSidKey__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTimeZoneSidKey__c.label);

        System.assertEquals(
                false,
                givenEntries[1].HasVerifiedEndTimeZone__c,
                Schema.SObjectType.TimeEntry__c.fields.HasVerifiedEndTimeZone__c.label);

        // Start Time: 2/14/2018 9:15am Asia/Taipei (unverified)
        System.assertEquals(
                Datetime.newInstanceGmt(2018, 2, 14, 1, 15, 0),
                givenEntries[2].StartTime__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTime__c.label);

        System.assertEquals(
                'Asia/Taipei',
                givenEntries[2].StartTimeZoneSidKey__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTimeZoneSidKey__c.label);

        System.assertEquals(
                false,
                givenEntries[2].HasVerifiedStartTimeZone__c,
                Schema.SObjectType.TimeEntry__c.fields.HasVerifiedStartTimeZone__c.label);

        // End Time: N/A
        System.assertEquals(
                null,
                givenEntries[2].EndTime__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTime__c.label);

        System.assertEquals(
                null,
                givenEntries[2].EndTimeZoneSidKey__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTimeZoneSidKey__c.label);

        System.assertEquals(
                false,
                givenEntries[2].HasVerifiedEndTimeZone__c,
                Schema.SObjectType.TimeEntry__c.fields.HasVerifiedEndTimeZone__c.label);

        // When
        Test.startTest();

        TimeEntryDataService.getInstance(
                bugs.Id).verifyTimeZone('America/New_York');

        // Then
        Test.stopTest();

        List<TimeEntry__c> thenEntries = thisTest.getTimeEntries(bugs);

        // Start Time: 2/12/2018 9:15am America/Los_Angeles (verified)
        System.assertEquals(
                Datetime.newInstanceGmt(2018, 2, 12, 17, 15, 0),
                thenEntries[0].StartTime__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTime__c.label);

        System.assertEquals(
                'America/Los_Angeles',
                thenEntries[0].StartTimeZoneSidKey__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTimeZoneSidKey__c.label);

        System.assertEquals(
                true,
                thenEntries[0].HasVerifiedStartTimeZone__c,
                Schema.SObjectType.TimeEntry__c.fields.HasVerifiedStartTimeZone__c.label);

        // End Time: 2/12/2018 5:00pm America/New_York (verified)
        System.assertEquals(
                Datetime.newInstanceGmt(2018, 2, 12, 22, 0, 0),
                thenEntries[0].EndTime__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTime__c.label);

        System.assertEquals(
                'America/New_York',
                thenEntries[0].EndTimeZoneSidKey__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTimeZoneSidKey__c.label);

        System.assertEquals(
                true,
                thenEntries[0].HasVerifiedEndTimeZone__c,
                Schema.SObjectType.TimeEntry__c.fields.HasVerifiedEndTimeZone__c.label);

        // Start Time: 2/13/2018 9:15am America/New_York (verified)
        System.assertEquals(
                TestService.format(Datetime.newInstanceGmt(2018, 2, 13, 14, 15, 0), 'America/New_York'),
                TestService.format(thenEntries[1].StartTime__c, 'America/New_York'),
                Schema.SObjectType.TimeEntry__c.fields.StartTime__c.label);

        System.assertEquals(
                'America/New_York',
                thenEntries[1].StartTimeZoneSidKey__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTimeZoneSidKey__c.label);

        System.assertEquals(
                true,
                thenEntries[1].HasVerifiedStartTimeZone__c,
                Schema.SObjectType.TimeEntry__c.fields.HasVerifiedStartTimeZone__c.label);

        // End Time: 2/13/2018 5:00pm America/New_York (verified)
        System.assertEquals(
                TestService.format(Datetime.newInstanceGmt(2018, 2, 13, 22, 0, 0), 'America/New_York'),
                TestService.format(thenEntries[1].EndTime__c, 'America/New_York'),
                Schema.SObjectType.TimeEntry__c.fields.EndTime__c.label);

        System.assertEquals(
                'America/New_York',
                thenEntries[1].EndTimeZoneSidKey__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTimeZoneSidKey__c.label);

        System.assertEquals(
                true,
                thenEntries[1].HasVerifiedEndTimeZone__c,
                Schema.SObjectType.TimeEntry__c.fields.HasVerifiedEndTimeZone__c.label);

        // Start Time: 2/14/2018 9:15am America/New_York (verified)
        System.assertEquals(
                TestService.format(Datetime.newInstanceGmt(2018, 2, 14, 14, 15, 0), 'America/New_York'),
                TestService.format(thenEntries[2].StartTime__c, 'America/New_York'),
                Schema.SObjectType.TimeEntry__c.fields.StartTime__c.label);

        System.assertEquals(
                'America/New_York',
                thenEntries[2].StartTimeZoneSidKey__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTimeZoneSidKey__c.label);

        System.assertEquals(
                true,
                thenEntries[2].HasVerifiedStartTimeZone__c,
                Schema.SObjectType.TimeEntry__c.fields.HasVerifiedStartTimeZone__c.label);

        // End Time: N/A
        System.assertEquals(
                null,
                thenEntries[2].EndTime__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTime__c.label);

        System.assertEquals(
                null,
                thenEntries[2].EndTimeZoneSidKey__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTimeZoneSidKey__c.label);

        System.assertEquals(
                false,
                thenEntries[2].HasVerifiedEndTimeZone__c,
                Schema.SObjectType.TimeEntry__c.fields.HasVerifiedEndTimeZone__c.label);
    }
}