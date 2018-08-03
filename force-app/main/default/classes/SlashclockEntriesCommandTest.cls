@isTest
private class SlashclockEntriesCommandTest {

    @isTest
    private static void clockEntriesAfterSlice30Minutes() {

        // Given
        RelativeTestService.getInstance(
                Datetime.now(), 'Europe/London').setup();
        
        Contact skate = [
            SELECT
                Account.SlackTeamId__c,
                AccountId,
                SlackUserId__c,
                TimeZoneSidKey__c,
                Id
            FROM Contact
            WHERE LastName = 'Skate (TEST)'
        ];

        List<TimeEntry__c> givenEntries = [
            SELECT
                StartTime__c,
                EndTime__c,
                Id
            FROM TimeEntry__c
            WHERE
                SlackTeamId__c = :skate.Account.SlackTeamId__c AND
                SlackUserId__c = :skate.SlackUserId__c
            ORDER BY StartTime__c DESC
        ];

        List<TimeSlice__c> givenSlices = [
            SELECT Id
            FROM TimeSlice__c
            WHERE TimeEntry__c IN :givenEntries
        ];

        Slashclock.Command givenCommand = new SlashclockEntriesCommand();
        
        givenCommand.load(
                new SlashCommand__c(
                        SlackUserId__c = skate.SlackUserId__c,
                        SlackTeamId__c = skate.Account.SlackTeamId__c,
                        Text__c = 'entries',
                        Command__c = '/clock'));

        Slashclock.CommandResult givenResult = givenCommand.execute();

        List<String> givenMessageParts = givenResult.getMessage().split('\n');

        System.assertEquals(
                'Here\'s what you\'ve clocked over the last seven days.',
                givenMessageParts.get(0),
                'givenMessageParts.get(0)');

        System.assert(
                givenMessageParts.get(1).endsWith('10:15am - 5:45pm'),
                givenMessageParts.get(1) + ' should end with ' + '10:15am - 5:45pm');

        System.assert(
                givenMessageParts.get(2).endsWith('9:15am - 9:45am'),
                givenMessageParts.get(2) + ' should end with ' + '9:15am - 9:45am');

        // When
        Test.startTest();

        Slashclock.Command sliceCommand = new SlashclockSliceCommand();

        sliceCommand.load(
                new SlashCommand__c(
                        SlackUserId__c = skate.SlackUserId__c,
                        SlackTeamId__c = skate.Account.SlackTeamId__c,
                        Text__c = 'slice 30 minutes fun',
                        Command__c = '/clock'));

        Slashclock.CommandResult sliceResult = sliceCommand.execute();

        // Then
        Test.stopTest();

        List<TimeSlice__c> thenSlices = [
            SELECT
                NumberOfMinutes__c,
                Tag__c,
                Id
            FROM TimeSlice__c
            WHERE TimeEntry__c IN :givenEntries
        ];

        System.assertEquals(1, thenSlices.size(), 'number of slices');

        Slashclock.Command thenCommand = new SlashclockEntriesCommand();
        
        thenCommand.load(
                new SlashCommand__c(
                        SlackUserId__c = skate.SlackUserId__c,
                        SlackTeamId__c = skate.Account.SlackTeamId__c,
                        Text__c = 'entries',
                        Command__c = '/clock'));

        Slashclock.CommandResult thenResult = thenCommand.execute();

        List<String> thenMessageParts = thenResult.getMessage().split('\n');

        System.assertEquals(
                'Here\'s what you\'ve clocked over the last seven days.',
                thenMessageParts.get(0),
                'thenMessageParts.get(0)');

        String thenEntry1Ending = '10:15am - 5:45pm (0.5h fun)';

        System.assert(
                thenMessageParts.get(1).endsWith(thenEntry1Ending),
                thenMessageParts.get(1) + ' should end with ' + thenEntry1Ending);

        String thenEntry2Ending = '9:15am - 9:45am';

        System.assert(
                thenMessageParts.get(2).endsWith(thenEntry2Ending),
                thenMessageParts.get(2) + ' should end with ' + thenEntry2Ending);
    }
}