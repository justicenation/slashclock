@isTest
private class SlashclockOutCommandTest {

    /**
     * The time at which data was set up for this test class.
     */
    private static DateTime setupTime = DateTime.now();

    private static TimeZone setupTimeZone = UserInfo.getTimeZone();

    private static RelativeTestService relativeTest = RelativeTestService.getInstance(
            setupTime, setupTimeZone.getID());

    @testSetup
    private static void setup() {
        relativeTest.setup();
    }


    @isTest
    private static void clockOutFiveThirtyPm() {
        Test.setMock(HttpCalloutMock.class, new SlackApiServiceMockSuite());
        
        // Given
        String slackUserId = 'kick';
        String slackTeamId = 'board';

        SlashclockService slashclock =
                SlashclockService.getInstance(slackUserId, slackTeamId);

        List<TimeEntry__c> openEntries = slashclock.getOpenTimeEntries();

        System.assertEquals(1, openEntries.size(), 'openEntries.size()');

        Datetime clockOutTime = DatetimeUtil.newDatetime(
                Date.today(),
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

    @isTest
    private static void clockOutYesterdayFiveThirtyPm() {
        System.assert(false, 'TODO');
    }
}