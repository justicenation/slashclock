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

    @isTest
    private static void clockOut() {
        
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

        TimeEntry__c openTimeEntry = new TimeEntry__c(
                Contact__c = userContact.Id,
                HasVerifiedStartTimeZone__c = true,
                SlackTeamId__c = teamAccount.SlackTeamId__c,
                SlackUserId__c = userContact.SlackUserId__c,
                StartTime__c = refDatetime.addDays(-1),
                StartTimeZoneSidkey__c = 'America/Los_Angeles');

        insert openTimeEntry;

        SlashCommand__c inbound = new SlashCommand__c(
                SlackUserId__c = 'silver',
                SlackTeamId__c = 'surfer',
                Command__c = '/clock',
                Text__c = 'out 5:00pm');

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
                'You have clocked out.', result.getMessage(), 'result.message');

        Datetime expectedEndTime =
                DatetimeUtil.newDatetime(
                        refDate, Time.newInstance(17, 0, 0, 0),
                        'America/Los_Angeles');

        List<TimeEntry__c> thenEntries = [
            SELECT
                EndTime__c,
                EndTimeZoneSidkey__c,
                StartTime__c,
                StartTimeZoneSidkey__c,
                Id
            FROM TimeEntry__c
            WHERE Contact__c = :userContact.Id
        ];

        System.assertEquals(1, thenEntries.size(), 'thenEntries.size()');

        System.assertEquals(
                expectedEndTime,
                thenEntries[0].EndTime__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTime__c.label);

        System.assertEquals(
                'America/Los_Angeles',
                thenEntries[0].EndTimeZoneSidkey__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTimeZoneSidkey__c.label);
    }

    @isTest
    private static void clockReport() {
        
        // Given
        Datetime refDatetime = Datetime.now();

        Date refDate = DatetimeUtil.getDate(refDatetime, 'America/Los_Angeles');

        Date refWeekStart = DatetimeUtil.startOfWeek(refDate, Weekday.MONDAY);

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

        Datetime startTime =
                DatetimeUtil.newDatetime(
                        refWeekStart, Time.newInstance(9, 0, 0, 0),
                        'America/Los_Angeles');

        Datetime endTime =
                DatetimeUtil.newDatetime(
                        refWeekStart, Time.newInstance(17, 0, 0, 0),
                        'America/Los_Angeles');

        TimeEntry__c closedTimeEntry = new TimeEntry__c(
                Contact__c = userContact.Id,
                EndTime__c = endTime,
                EndTimeZoneSidkey__c = 'America/Los_Angeles',
                HasVerifiedEndTimeZone__c = true,
                HasVerifiedStartTimeZone__c = true,
                SlackTeamId__c = teamAccount.SlackTeamId__c,
                SlackUserId__c = userContact.SlackUserId__c,
                StartTime__c = startTime,
                StartTimeZoneSidkey__c = 'America/Los_Angeles');

        insert closedTimeEntry;

        SlashCommand__c inbound = new SlashCommand__c(
                SlackUserId__c = 'silver',
                SlackTeamId__c = 'surfer',
                Command__c = '/clock',
                Text__c = 'report');

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

        List<String> messageParts = result.getMessage().split('\n');

        System.assertEquals(
                'Below are your stats for the week.', messageParts[0],
                'first line of response message');

        System.assertEquals(
                'Mon *8h*', messageParts[1],
                'second line of response message');
    }

    @isTest
    private static void clockEntries() {
        
        // Given
        Datetime refDatetime = Datetime.now();

        Date refDate = DatetimeUtil.getDate(refDatetime, 'America/Los_Angeles');

        Date refWeekStart = DatetimeUtil.startOfWeek(refDate, Weekday.MONDAY);

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

        Datetime startTime =
                DatetimeUtil.newDatetime(
                        refWeekStart, Time.newInstance(9, 0, 0, 0),
                        'America/Los_Angeles');

        Datetime endTime =
                DatetimeUtil.newDatetime(
                        refWeekStart, Time.newInstance(17, 0, 0, 0),
                        'America/Los_Angeles');

        TimeEntry__c closedTimeEntry = new TimeEntry__c(
                Contact__c = userContact.Id,
                EndTime__c = endTime,
                EndTimeZoneSidkey__c = 'America/Los_Angeles',
                HasVerifiedEndTimeZone__c = true,
                HasVerifiedStartTimeZone__c = true,
                SlackTeamId__c = teamAccount.SlackTeamId__c,
                SlackUserId__c = userContact.SlackUserId__c,
                StartTime__c = startTime,
                StartTimeZoneSidkey__c = 'America/Los_Angeles');

        insert closedTimeEntry;

        SlashCommand__c inbound = new SlashCommand__c(
                SlackUserId__c = 'silver',
                SlackTeamId__c = 'surfer',
                Command__c = '/clock',
                Text__c = 'entries');

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

        List<String> messageParts = result.getMessage().split('\n');

        System.assertEquals(
                'Here\'s what you\'ve clocked over the last seven days.', messageParts[0],
                'first line of response message');

        System.assertEquals(
                '1. Mon ' + startTime.format('M/d', 'America/Los_Angeles') + ' 9:00am - 5:00pm',
                messageParts[1],
                'second line of response message');
    }

    /**
     * Given a user who started in the "America/New_York" time zone,
     * clock in when the user goes to the "America/Los_Angeles" time zone.
     * The time entry created should be resolved to be
     * in the "America/Los_Angeles" time zone.
     */
    @isTest
    private static void clockInFromNewTimeZone() {
        
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
                TimeZoneSidKey__c = 'America/New_York',
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

    @isTest
    private static void clockOutFromNewTimeZone() {
        
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
                TimeZoneSidKey__c = 'America/New_York',
                SlackUserId__c = 'silver');

        insert userContact;

        TimeEntry__c openTimeEntry = new TimeEntry__c(
                Contact__c = userContact.Id,
                HasVerifiedStartTimeZone__c = true,
                SlackTeamId__c = teamAccount.SlackTeamId__c,
                SlackUserId__c = userContact.SlackUserId__c,
                StartTime__c = refDatetime.addDays(-1),
                StartTimeZoneSidkey__c = 'America/New_York');

        insert openTimeEntry;

        SlashCommand__c inbound = new SlashCommand__c(
                SlackUserId__c = 'silver',
                SlackTeamId__c = 'surfer',
                Command__c = '/clock',
                Text__c = 'out 5:00pm');

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
                'You have clocked out.', result.getMessage(), 'result.message');

        Datetime expectedEndTime =
                DatetimeUtil.newDatetime(
                        refDate, Time.newInstance(17, 0, 0, 0),
                        'America/Los_Angeles');

        List<TimeEntry__c> thenEntries = [
            SELECT
                EndTime__c,
                EndTimeZoneSidkey__c,
                StartTime__c,
                StartTimeZoneSidkey__c,
                Id
            FROM TimeEntry__c
            WHERE Contact__c = :userContact.Id
        ];

        System.assertEquals(1, thenEntries.size(), 'thenEntries.size()');

        System.assertEquals(
                expectedEndTime,
                thenEntries[0].EndTime__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTime__c.label);

        System.assertEquals(
                'America/Los_Angeles',
                thenEntries[0].EndTimeZoneSidkey__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTimeZoneSidkey__c.label);
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