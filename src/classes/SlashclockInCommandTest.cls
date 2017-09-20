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

        Long defaultStartTime = command.getStartTime().getTime();

        // When
        Test.startTest();

        Boolean matches = command.matches(userCommand);

        // Then
        Test.stopTest();

        System.assert(matches, '/clock in command match expected');

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

        TimeZone americaNewYork = TimeZone.getTimeZone('America/New_York');

        Date userDate = DateTimeUtil.getDate(
                command.getStartTime(), americaNewYork.getID());

        Long expectedStartTime = DateTime.newInstanceGmt(
                userDate.year(), userDate.month(), userDate.day(),
                9, 30, 0).getTime() - americaNewYork.getOffset(userDate);

        // When
        Test.startTest();

        Boolean matches = command.matches(userCommand);

        // Then
        Test.stopTest();

        System.assert(matches, '/clock in command match expected');

        Long actualStartTime = command.getStartTime().getTime();
        
        System.assertEquals(expectedStartTime, actualStartTime,
                'SlashclockInCommand.startTime');
    }
}