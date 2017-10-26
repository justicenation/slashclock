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

    @testSetup
    private static void setup() {
        TestService.getInstance().setup();
    }
}