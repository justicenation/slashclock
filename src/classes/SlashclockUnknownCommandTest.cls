@isTest
private class SlashclockUnknownCommandTest {

    /**
     * What happens when you /clock foo?
     */
    @isTest
    private static void clockFoo() {
        
        // Given
        String slackUserId = 'em';
        String slackTeamId = 'cee';

        SlashclockService slashclock =
                SlashclockService.getInstance(slackUserId, slackTeamId);

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Command__c = '/clock',
                Text__c = 'foo');

        Slashclock.Command command = new SlashclockUnknownCommand();

        System.assert(command.matches(slashCommand),
                'must match slash command');

        // When
        Test.startTest();

        command.load(slashCommand);
        Slashclock.CommandResult result = command.execute();

        // Then
        Test.stopTest();

        System.assertEquals(false, result.isSuccess(), 'result.isSuccess()');

        System.assertEquals(
                'Unknown command, /clock foo!',
                result.getMessage(),
                'result.getMessage()');
    }

    @testSetup
    private static void setup() {
        TestService.getInstance().setup();
    }
}