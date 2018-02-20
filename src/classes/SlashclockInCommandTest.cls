@isTest
private class SlashclockInCommandTest {

    /**
     * - Given any state;
     * - When user enteres `/clock in` command;
     * - Then command should match, and time should remain unchanged
     */
    @isTest
    private static void matchesIn() {

        // Given
        SlashCommand__c userCommand = new SlashCommand__c(
                SlackTeamId__c = 'acme',
                SlackUserId__c = 'bunny',
                Command__c = '/clock',
                Text__c = 'in');

        SlashclockInCommand command = new SlashclockInCommand();

        System.assert(command.matches(userCommand),
                '/clock in command match expected');

        Long defaultStartTime = command.getStartTime().getTime();

        // When
        Test.setMock(HttpCalloutMock.class, new SlashclockMockSuite());
        Test.startTest();

        command.load(userCommand);

        // Then
        Test.stopTest();

        Long actualStartTime = command.getStartTime().getTime();

        System.assertEquals(defaultStartTime, actualStartTime,
                'SlashclockInCommand.startTime');
    }

    /**
     * - Given any state;
     * - When new user enters `/clock in 9:30am` command;
     * - Then the new user's contact should be created in the America/New_York
     *   time zone;
     * - and the command's start time should match 9:30am in the current day
     *   based on the user contact's time zone
     */
    @isTest
    private static void matchesInNineThirtyAm() {

        // Given
        SlashCommand__c userCommand = new SlashCommand__c(
                SlackTeamId__c = 'acme',
                SlackUserId__c = 'bunny',
                Command__c = '/clock',
                Text__c = 'in 9:30am');

        SlashclockInCommand command = new SlashclockInCommand();

        System.assert(command.matches(userCommand),
                '/clock in command match expected');

        TimeZone americaNewYork = TimeZone.getTimeZone('America/New_York');

        Date userDate = DateTimeUtil.getDate(
                command.getStartTime(), americaNewYork.getID());

        Long expectedStartTime = DateTimeUtil.newDateTime(
                userDate, Time.newInstance(9, 30, 0, 0),
                americaNewYork).getTime();

        // When
        Test.setMock(HttpCalloutMock.class, new SlashclockMockSuite());
        Test.startTest();

        command.load(userCommand);

        // Then
        Test.stopTest();

        Long actualStartTime = command.getStartTime().getTime();
        
        System.assertEquals(
                DateTime.newInstance(expectedStartTime),
                DateTime.newInstance(actualStartTime),
                'SlashclockInCommand.startTime');
    }

    @isTest
    private static void clockInEightThirtyAm() {
        Test.setMock(HttpCalloutMock.class, new SlackApiServiceMockSuite());
        
        // Given
        String slackUserId = 'em';
        String slackTeamId = 'cee';

        // Find the contact for the Slack user
        SlackService slacker = SlackService.getInstance(slackTeamId);
        Contact userContact = slacker.findOrCreateContact(slackUserId);

        SlashclockService slashclock =
                SlashclockService.getInstance(userContact);

        List<TimeEntry__c> openEntries = slashclock.getOpenTimeEntries();

        System.assertEquals(0, openEntries.size(), 'openEntries.size()');

        Datetime clockInTime = DatetimeUtil.newDatetime(
                Date.today(),
                Time.newInstance(8, 30, 0, 0),
                slashclock.getTimeZoneSidKey());

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Text__c = 'in 8:30am');

        SlashclockInCommand command = new SlashclockInCommand();

        System.assert(command.matches(slashCommand),
                'must match slash command');

        // When
        Test.startTest();

        command.load(slashCommand);
        command.execute();

        // Then
        Test.stopTest();

        TimeEntry__c openEntry = [
            SELECT Id, StartTime__c
            FROM TimeEntry__c
            WHERE
                SlackUserId__c = :slackUserId AND
                SlackTeamId__c = :slackTeamId AND
                EndTime__c = NULL
        ];

        System.assertEquals(clockInTime, openEntry.StartTime__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTime__c.label);
    }

    /**
     * This test validates the verification of time zones, based on whether
     * an Apex Job Request record was created and also whether an
     * `ApexJobRequestProcessJob` batch is executed.
     */
    @isTest
    private static void clockInEightThirtyAmThenVerifyTimeZone() {
        Test.setMock(HttpCalloutMock.class, new SlackApiServiceMockSuite());
        
        // Given
        String slackUserId = 'em';
        String slackTeamId = 'cee';

        // Find the contact for the Slack user
        SlackService slacker = SlackService.getInstance(slackTeamId);
        Contact userContact = slacker.findOrCreateContact(slackUserId);

        SlashclockService slashclock =
                SlashclockService.getInstance(userContact);

        Datetime clockInTime = DatetimeUtil.newDatetime(
                Date.today(),
                Time.newInstance(8, 30, 0, 0),
                slashclock.getTimeZoneSidKey());

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Text__c = 'in 8:30am');

        SlashclockInCommand command = new SlashclockInCommand();

        // Make sure no `ApexJobRequestProcessJob` batches are
        // already enqueued.
        System.assertEquals(0, [
            SELECT Id
            FROM AsyncApexJob
            WHERE
                ApexClassId IN (
                    SELECT Id
                    FROM ApexClass
                    WHERE Name = 'ApexJobRequestProcessJob'
                )
        ].size(), 'given count of ApexJobRequestProcessJob');

        // When
        Test.startTest();

        command.load(slashCommand);
        command.execute();

        // Then
        Test.stopTest();

        // Make sure one Apex Job Request record was created
        System.assertEquals(1, [
            SELECT Id
            FROM ApexJobRequest__c
            WHERE ApexClassName__c = :TimeEntryVerifyTimeZoneJob.class.getName()
        ].size(), 'then count of Apex Job Request');

        // Make sure one `ApexJobRequestProcessJob` batch is
        // executed and in the Apex job queue.
        System.assertEquals(1, [
            SELECT Id
            FROM AsyncApexJob
            WHERE
                ApexClassId IN (
                    SELECT Id
                    FROM ApexClass
                    WHERE Name = 'ApexJobRequestProcessJob'
                )
        ].size(), 'then count of ApexJobRequestProcessJob');
    }

    @isTest
    private static void clockInYesterdayEightThirtyAm() {
        Test.setMock(HttpCalloutMock.class, new SlackApiServiceMockSuite());
        
        // Given
        String slackUserId = 'em';
        String slackTeamId = 'cee';

        // Find the contact for the Slack user
        SlackService slacker = SlackService.getInstance(slackTeamId);
        Contact userContact = slacker.findOrCreateContact(slackUserId);

        SlashclockService slashclock =
                SlashclockService.getInstance(userContact);

        List<TimeEntry__c> openEntries = slashclock.getOpenTimeEntries();

        System.assertEquals(0, openEntries.size(), 'openEntries.size()');

        Datetime clockInTime = DatetimeUtil.newDatetime(
                Date.today().addDays(-1),
                Time.newInstance(8, 30, 0, 0),
                slashclock.getTimeZoneSidKey());

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Text__c = 'in yesterday 8:30am');

        SlashclockInCommand command = new SlashclockInCommand();

        System.assert(command.matches(slashCommand),
                'must match slash command');

        // When
        Test.startTest();

        command.load(slashCommand);
        command.execute();

        // Then
        Test.stopTest();

        TimeEntry__c openEntry = [
            SELECT
                Contact__c,
                StartTime__c,
                Id
            FROM TimeEntry__c
            WHERE
                SlackUserId__c = :slackUserId AND
                SlackTeamId__c = :slackTeamId AND
                EndTime__c = NULL
        ];

        System.assertEquals(clockInTime, openEntry.StartTime__c,
                Schema.SObjectType.TimeEntry__c.fields.StartTime__c.label);

        System.assertEquals(userContact.Id, openEntry.Contact__c,
                Schema.SObjectType.TimeEntry__c.fields.Contact__c.label);
    }

    @testSetup
    private static void setup() {
        TestService.getInstance().setup();
    }
}