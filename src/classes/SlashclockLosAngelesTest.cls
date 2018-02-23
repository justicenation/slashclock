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

        // When
        Test.setMock(
                HttpCalloutMock.class,
                new SlashclockLosAngelesMockSuite());
        Test.startTest();

        Slashclock.CommandResult result = null;

        System.runAs(getApiGuestUser()) {

            // Find the contact for the Slack user
            SlackService slacker = SlackService.getInstance(inbound.SlackTeamId__c);
            Contact userContact = slacker.findOrCreateContact(inbound.SlackUserId__c);
            SlashclockService slashclock = SlashclockService.getInstance(userContact);

            result = slashclock.execute(inbound);
        }

        // Then
        Test.stopTest();

        System.assertEquals(true, result.isSuccess(), 'result.success');

        System.assertEquals(
                'You have clocked in.', result.getMessage(), 'result.message');

        Account thenTeamAccount = [
            SELECT
                Name,
                SlackTeamId__c,
                Id
            FROM Account
            WHERE SlackTeamId__c = 'surfer'
        ];

        System.assertEquals('surfer', thenTeamAccount.Name,
                Schema.SObjectType.Account.fields.Name.label);

        Contact thenUserContact = [
            SELECT
                AccountId,
                SlackUserId__c,
                TimeZoneSidKey__c,
                Id
            FROM Contact
            WHERE
                SlackUserId__c = 'silver'
        ];

        System.assertEquals(thenTeamAccount.Id, thenUserContact.AccountId,
                Schema.SObjectType.Contact.fields.AccountId.label);

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
        
        // Given
        Datetime refDatetime = Datetime.now();

        Date refDate = DatetimeUtil.getDate(refDatetime, 'America/Los_Angeles');

        Account teamAccount = new Account(
                Name = 'Surfer, Inc. (TEST)',
                SlackTeamId__c = 'surfer');

        insert teamAccount;

        Contact userContact = new Contact(
                AccountId = teamAccount.Id,
                FirstName = 'Silver',
                LastName = 'Surfer (TEST)',
                TimeZoneSidKey__c = 'America/Los_Angeles',
                SlackUserId__c = 'silver');

        insert userContact;

        SlashCommand__c inbound = new SlashCommand__c(
                SlackUserId__c = 'silver',
                SlackTeamId__c = 'surfer',
                Command__c = '/clock',
                Text__c = 'in 9:15am');

        // When
        Test.setMock(
                HttpCalloutMock.class,
                new SlashclockLosAngelesMockSuite());
        Test.startTest();

        Slashclock.CommandResult result = null;

        System.runAs(getApiGuestUser()) {

            // Find the contact for the Slack user
            SlackService slacker = SlackService.getInstance(inbound.SlackTeamId__c);
            SlashclockService slashclock = SlashclockService.getInstance(
                    slacker.findOrCreateContact(inbound.SlackUserId__c));

            result = slashclock.execute(inbound);
        }

        // Then
        Test.stopTest();

        System.assertEquals(true, result.isSuccess(), 'result.success');

        System.assertEquals(
                'You have clocked in.', result.getMessage(), 'result.message');

        Datetime expectedStartTime =
                DatetimeUtil.newDatetime(
                        refDate, Time.newInstance(9, 15, 0, 0),
                        'America/Los_Angeles');

        List<TimeEntry__c> thenEntries = [
            SELECT
                StartTime__c,
                StartTimeZoneSidkey__c,
                Id
            FROM TimeEntry__c
            WHERE Contact__c = :userContact.Id
        ];

        System.assertEquals(1, thenEntries.size(), 'thenEntries.size()');

        System.assertEquals(
                expectedStartTime,
                thenEntries[0].StartTime__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTime__c.label);

        System.assertEquals(
                'America/Los_Angeles',
                thenEntries[0].StartTimeZoneSidkey__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTimeZoneSidkey__c.label);
    }

    // TODO: @isTest
    private static void clockOut() {
        System.assert(false, 'TODO');
    }

    // TODO: @isTest
    private static void clockReport() {
        System.assert(false, 'TODO');
    }

    // TODO: @isTest
    private static void clockEntries() {
        System.assert(false, 'TODO');
    }

    // TODO: @isTest
    private static void clockInFromNewTimeZone() {
        System.assert(false, 'TODO');
    }

    // TODO: @isTest
    private static void clockOutFromNewTimeZone() {
        System.assert(false, 'TODO');
    }

    // TODO: @isTest
    private static void clockReportFromDifferentTimeZone() {
        System.assert(false, 'TODO');
    }

    private static User getApiGuestUser() {
        return [
            SELECT Id
            FROM User
            WHERE ProfileId IN (
                SELECT Id
                FROM Profile
                WHERE Name = 'API Profile'
            )
        ].get(0);
    }
}