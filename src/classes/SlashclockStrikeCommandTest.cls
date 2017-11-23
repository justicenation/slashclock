@isTest
private class SlashclockStrikeCommandTest {

    @testSetup
    private static void setup() {
        TestService.getInstance().setup();
    }

    /**
     * Delete the most recent time entry
     */
    @isTest
    private static void strikeFirstEntry() {

        // Given
        SlashCommand__c command = new SlashCommand__c(
                SlackUserId__c = 'flip',
                SlackTeamId__c = 'board',
                Command__c = '/clock',
                Text__c = 'strike 1');

        List<TimeEntry__c> givenEntries = [
            SELECT Id, StartTime__c, EndTime__c
            FROM TimeEntry__c
            WHERE SlackUserId__c = :command.SlackUserId__c
                AND SlackTeamId__c = :command.SlackTeamId__c
                AND StartTime__c >= :DateTime.now().addDays(-7)
        ];

        System.assertEquals(1, givenEntries.size());

        // When
        Test.startTest();

        Slashclock.CommandResult result =
                new SlashclockStrikeCommand().load(command).execute();

        // Then
        Test.stopTest();

        List<TimeEntry__c> thenEntries = [
            SELECT Id, StartTime__c, EndTime__c
            FROM TimeEntry__c
            WHERE SlackUserId__c = :command.SlackUserId__c
                AND SlackTeamId__c = :command.SlackTeamId__c
                AND StartTime__c >= :DateTime.now().addDays(-7)
        ];

        System.assertEquals(0, thenEntries.size());

        System.assert(result.getMessage().startsWith('Entry deleted.\n1.'),
                'message does not start as expected: ' + result.getMessage());
    }
}