@isTest
private class SlashclockUnknownCommandTest {

    /**
     * What happens when you just /clock?
     */
    @isTest
    private static void clock() {

        // Test setup
        TestService.getInstance().setup();
        
        // Given
        String slackUserId = 'em';
        String slackTeamId = 'cee';

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Command__c = '/clock',
                Text__c = null);

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
                'Unknown command, /clock!',
                result.getMessage(),
                'result.getMessage()');
    }

    /**
     * What happens when you /clock foo?
     */
    @isTest
    private static void clockFoo() {

        // Test setup
        TestService.getInstance().setup();
        
        // Given
        String slackUserId = 'em';
        String slackTeamId = 'cee';

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

    /**
     * What happens when you /clock hack 1337 style?
     */
    @isTest
    private static void clockHack1337style() {

        // Test setup
        TestService.getInstance().setup();
        
        // Given
        String slackUserId = 'em';
        String slackTeamId = 'cee';

        SlashCommand__c slashCommand = new SlashCommand__c(
                SlackUserId__c = slackUserId,
                SlackTeamId__c = slackTeamId,
                Command__c = '/clock',
                Text__c = 'hack 1337 style');

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
                'Unknown command, /clock hack!',
                result.getMessage(),
                'result.getMessage()');
    }
}