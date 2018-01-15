@isTest
private class SlashclockHelpCommandTest {

    /**
     * /clock help
     */
    @isTest
    private static void clockHelp() {
        
        // Given
        String slackUserId = 'em';
        String slackTeamId = 'cee';

        SlashclockService slashclock =
                SlashclockService.getInstance(slackUserId, slackTeamId);

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Text__c = 'help');

        SlashclockHelpCommand command = new SlashclockHelpCommand();

        System.assert(command.matches(slashCommand),
                'must match slash command');

        // When
        Test.startTest();

        command.load(slashCommand);
        Slashclock.CommandResult result = command.execute();

        // Then
        Test.stopTest();

        System.assertEquals(true, result.isSuccess(), 'result.isSuccess()');

        System.assertEquals(
                'Content for */clock help*',
                result.getMessage(),
                'result.getMessage()');
    }

    /**
     * /clock help in
     */
    @isTest
    private static void clockHelpIn() {
        System.assert(false, 'TODO');
    }

    /**
     * /clock help out
     */
    @isTest
    private static void clockHelpOut() {
        System.assert(false, 'TODO');
    }

    /**
     * /clock help report
     */
    @isTest
    private static void clockHelpReport() {
        System.assert(false, 'TODO');
    }

    /**
     * /clock help slice
     */
    @isTest
    private static void clockHelpSlice() {
        System.assert(false, 'TODO');
    }

    /**
     * /clock help entries
     */
    @isTest
    private static void clockHelpEntries() {
        System.assert(false, 'TODO');
    }

    /**
     * /clock help strike
     */
    @isTest
    private static void clockHelpStrike() {
        System.assert(false, 'TODO');
    }

    @testSetup
    private static void setup() {
        TestService.getInstance().setup();
    }
}