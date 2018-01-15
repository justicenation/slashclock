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
        
        // Given
        String slackUserId = 'em';
        String slackTeamId = 'cee';

        SlashclockService slashclock =
                SlashclockService.getInstance(slackUserId, slackTeamId);

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Text__c = 'help in');

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
                'Content for */clock help in*',
                result.getMessage(),
                'result.getMessage()');
    }

    /**
     * /clock help out
     */
    @isTest
    private static void clockHelpOut() {
        
        // Given
        String slackUserId = 'em';
        String slackTeamId = 'cee';

        SlashclockService slashclock =
                SlashclockService.getInstance(slackUserId, slackTeamId);

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Text__c = 'help out');

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
                'Content for */clock help out*',
                result.getMessage(),
                'result.getMessage()');
    }

    /**
     * /clock help report
     */
    @isTest
    private static void clockHelpReport() {
        
        // Given
        String slackUserId = 'em';
        String slackTeamId = 'cee';

        SlashclockService slashclock =
                SlashclockService.getInstance(slackUserId, slackTeamId);

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Text__c = 'help report');

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
                'Content for */clock help report*',
                result.getMessage(),
                'result.getMessage()');
    }

    /**
     * /clock help slice
     */
    @isTest
    private static void clockHelpSlice() {
        
        // Given
        String slackUserId = 'em';
        String slackTeamId = 'cee';

        SlashclockService slashclock =
                SlashclockService.getInstance(slackUserId, slackTeamId);

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Text__c = 'help slice');

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
                'Content for */clock help slice*',
                result.getMessage(),
                'result.getMessage()');
    }

    /**
     * /clock help entries
     */
    @isTest
    private static void clockHelpEntries() {
        
        // Given
        String slackUserId = 'em';
        String slackTeamId = 'cee';

        SlashclockService slashclock =
                SlashclockService.getInstance(slackUserId, slackTeamId);

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Text__c = 'help entries');

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
                'Content for */clock help entries*',
                result.getMessage(),
                'result.getMessage()');
    }

    /**
     * /clock help strike
     */
    @isTest
    private static void clockHelpStrike() {
        
        // Given
        String slackUserId = 'em';
        String slackTeamId = 'cee';

        SlashclockService slashclock =
                SlashclockService.getInstance(slackUserId, slackTeamId);

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Text__c = 'help strike');

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
                'Content for */clock help strike*',
                result.getMessage(),
                'result.getMessage()');
    }

    @testSetup
    private static void setup() {
        TestService.getInstance().setup();
    }
}