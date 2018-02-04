/**
 * This test class provides functional validation for United States West Coast
 * users, making sure that all commands work correctly in the context
 * of the "America/Los_Angeles" time zone.
 */
@isTest
private class SlashclockLosAngelesTest {

    /**
     * New Slack user in the America/Los_Angeles time zone clocks in
     * at 9:15am local time
     */
    @isTest
    private static void clockInAsNewUser() {
        
        // Given
        Datetime refDatetime = Datetime.now();

        Date refDate = DatetimeUtil.getDate(refDatetime, 'America/Los_Angeles');

        SlashCommand__c inbound = new SlashCommand__c(
                SlackUserId__c = 'silver',
                SlackTeamId__c = 'surfer',
                Command__c = '/clock',
                Text__c = 'in 9:15am');

        User apiGuestUser = [
            SELECT Id
            FROM User
            WHERE ProfileId IN (
                SELECT Id
                FROM Profile
                WHERE Name = 'API Profile'
            )
        ];

        // When
        Test.setMock(
                HttpCalloutMock.class,
                new SlashclockLosAngelesMockSuite());
        Test.startTest();

        Slashclock.CommandResult result = null;

        System.runAs(apiGuestUser) {
            result = SlashclockService.getInstance(inbound).execute(inbound);
        }

        // Then
        Test.stopTest();

        Contact thenUserContact = [
            SELECT
                TimeZoneSidKey__c,
                Id
            FROM Contact
            WHERE
                SlackTeamId__c = 'surfer' AND
                SlackUserId__c = 'silver'
        ];

        System.assertEquals(
                'America/Los_Angeles',
                thenUserContact.TimeZoneSidKey__c,
                Schema.SObjectType.Contact.fields.TimeZoneSidKey__c.label);

        Datetime expectedStartTime =
                DatetimeUtil.newDatetime(
                        refDate, Time.newInstance(9, 15, 0, 0),
                        'America/Los_Angeles');

        List<TimeEntry__c> thenEntries = [
            SELECT
                StartTime__c,
                Id
            FROM TimeEntry__c
            WHERE Contact__c = :thenUserContact.Id
        ];

        System.assertEquals(1, thenEntries.size(), 'thenEntries.size()');

        System.assertEquals(
                expectedStartTime,
                thenEntries[0].StartTime__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTime__c.label);
    }

    @isTest
    private static void clockIn() {
        System.assert(false, 'TODO');
    }

    @isTest
    private static void clockOut() {
        System.assert(false, 'TODO');
    }

    @isTest
    private static void clockReport() {
        System.assert(false, 'TODO');
    }

    @isTest
    private static void clockEntries() {
        System.assert(false, 'TODO');
    }

    @isTest
    private static void clockInFromNewTimeZone() {
        System.assert(false, 'TODO');
    }

    @isTest
    private static void clockOutFromNewTimeZone() {
        System.assert(false, 'TODO');
    }

    @isTest
    private static void clockReportFromDifferentTimeZone() {
        System.assert(false, 'TODO');
    }
}