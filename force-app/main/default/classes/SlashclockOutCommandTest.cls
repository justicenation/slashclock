@isTest
private class SlashclockOutCommandTest {

    @isTest
    private static void clockOutFiveThirtyPm() {
        Test.setMock(HttpCalloutMock.class, new SlackApiServiceMockSuite());
        
        // Test setup
        DateTime setupTime = DateTime.now();
        TimeZone setupTimeZone = TimeZone.getTimeZone('America/New_York');

        RelativeTestService relativeTest =
                RelativeTestService.getInstance(
                        setupTime, setupTimeZone.getID());

        relativeTest.setup();

        // Given
        String slackUserId = 'kick';
        String slackTeamId = 'board';

        List<TimeEntry__c> openEntries = [
            SELECT
                EndTime__c,
                EndTimeZoneSidKey__c,
                StartTime__c,
                Id
            FROM TimeEntry__c
            WHERE
                EndTime__c = NULL AND
                Contact__r.SlackUserId__c = :slackUserId
        ];

        System.assertEquals(1, openEntries.size(), 'openEntries.size()');

        Datetime clockOutTime = DatetimeUtil.newDatetime(
                Date.today(),
                Time.newInstance(17, 30, 0, 0),
                'America/New_York');

        System.assert(openEntries[0].StartTime__c < clockOutTime,
                'clockOutTime must be later than open entry Start Time');

        System.assertEquals(
                null,
                openEntries[0].EndTime__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTime__c.label);

        System.assertEquals(
                null,
                openEntries[0].EndTimeZoneSidKey__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTimeZoneSidKey__c.label);

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Text__c = 'out 5:30pm');

        SlashclockOutCommand command = new SlashclockOutCommand();

        System.assert(command.matches(slashCommand),
                'must match slash command');

        // When
        Test.startTest();

        command.load(slashCommand);
        command.execute();

        // Then
        Test.stopTest();

        TimeEntry__c closedEntry = [
            SELECT
                EndTime__c,
                EndTimeZoneSidKey__c,
                HasVerifiedEndTimeZone__c,
                Id
            FROM TimeEntry__c
            WHERe Id = :openEntries[0].Id
        ];

        System.assertEquals(clockOutTime, closedEntry.EndTime__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTime__c.label);

        System.assertEquals(
                'America/New_York',
                closedEntry.EndTimeZoneSidKey__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTimeZoneSidKey__c.label);
    }

    /**
     * This test validates the verification of time zones, based on whether
     * an Apex Job Request record was created and also whether an
     * `ApexJobRequestProcessJob` batch is executed.
     */
    @isTest
    private static void clockOutFiveThirtyPmThenVerifyTimeZone() {
        Test.setMock(HttpCalloutMock.class, new SlackApiServiceMockSuite());
        
        // Test setup
        DateTime setupTime = DateTime.now();
        TimeZone setupTimeZone = TimeZone.getTimeZone('America/New_York');

        RelativeTestService relativeTest =
                RelativeTestService.getInstance(
                        setupTime, setupTimeZone.getID());

        relativeTest.setup();
        
        // Given
        String slackUserId = 'kick';
        String slackTeamId = 'board';

        // Find the contact for the Slack user
        SlackService slacker = SlackService.getInstance(slackTeamId);
        Contact userContact = slacker.findOrCreateContact(slackUserId);

        SlashclockService slashclock =
                SlashclockService.getInstance(userContact);

        Datetime clockOutTime = DatetimeUtil.newDatetime(
                Date.today(),
                Time.newInstance(17, 30, 0, 0),
                slashclock.getTimeZoneSidKey());

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Text__c = 'out 5:30pm');

        SlashclockOutCommand command = new SlashclockOutCommand();

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
                ) AND
                JobType = 'BatchApex'
        ].size(), 'then count of BatchApex jobs');

        // Make sure one `ApexJobRequestProcessJob` batch worker is
        // executed and in the Apex job queue.
        System.assertEquals(1, [
            SELECT Id
            FROM AsyncApexJob
            WHERE
                ApexClassId IN (
                    SELECT Id
                    FROM ApexClass
                    WHERE Name = 'ApexJobRequestProcessJob'
                ) AND
                JobType = 'BatchApexWorker'
        ].size(), 'then count of BatchApex jobs');
    }

    @isTest
    private static void clockOutYesterdayFiveThirtyPm() {
        Test.setMock(HttpCalloutMock.class, new SlackApiServiceMockSuite());
        
        // Test setup
        DateTime setupTime = DateTime.now();
        TimeZone setupTimeZone = TimeZone.getTimeZone('America/New_York');

        RelativeTestService relativeTest =
                RelativeTestService.getInstance(
                        setupTime, setupTimeZone.getID());

        relativeTest.setup();
        
        // Given
        String slackUserId = 'kick';
        String slackTeamId = 'board';

        // Find the contact for the Slack user
        SlackService slacker = SlackService.getInstance(slackTeamId);
        Contact userContact = slacker.findOrCreateContact(slackUserId);

        SlashclockService slashclock =
                SlashclockService.getInstance(userContact);

        List<TimeEntry__c> openEntries = slashclock.getOpenTimeEntries();

        System.assertEquals(1, openEntries.size(), 'openEntries.size()');

        Datetime clockOutTime = DatetimeUtil.newDatetime(
                Date.today().addDays(-1),
                Time.newInstance(17, 30, 0, 0),
                slashclock.getTimeZoneSidKey());

        System.assert(openEntries[0].StartTime__c < clockOutTime,
                'clockOutTime must be later than open entry Start Time');

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Text__c = 'out yesterday 5:30pm');

        SlashclockOutCommand command = new SlashclockOutCommand();

        System.assert(command.matches(slashCommand),
                'must match slash command');

        // When
        Test.startTest();

        command.load(slashCommand);
        command.execute();

        // Then
        Test.stopTest();

        TimeEntry__c closedEntry = [
            SELECT Id, EndTime__c
            FROM TimeEntry__c
            WHERe Id = :openEntries[0].Id
        ];

        System.assertEquals(clockOutTime, closedEntry.EndTime__c,
                Schema.SObjectType.TimeEntry__c.fields.EndTime__c.label);
    }
}