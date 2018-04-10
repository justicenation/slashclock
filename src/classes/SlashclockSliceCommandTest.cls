@isTest
private class SlashclockSliceCommandTest {

    /**
     * Given two time entries, with the last one being open with no slices;
     * When a new "slice" command is executed for 30 minutes tagged "test";
     * Then a new time slice should be created under the open time entry
     * showing 30 minutes tagged "test"
     *
     * @see https://api.slack.com/slash-commands
     */
    @isTest
    private static void sliceOpenEntry30Minutes() {

        // Test setup
        TestService.getInstance().setupSlashclockSliceCommandTest();
        
        // Given
        TimeEntry__c givenEntry = [
            SELECT Id,
                (
                    SELECT Id, NumberOfMinutes__c, Tag__c
                    FROM TimeSlices__r
                )
            FROM TimeEntry__c
            WHERE SlackUserId__c = 'bugs'
            AND SlackTeamId__c = 'acme'
            ORDER BY StartTime__c DESC
            LIMIT 1
        ];

        System.assertEquals(0, givenEntry.TimeSlices__r.size(),
                'given entry should have no slices');

        // When
        Test.startTest();

        SlashCommand__c inboundCommand = new SlashCommand__c(
                Command__c = '/clock',
                Text__c = 'slice 30 minutes test',
                SlackTeamId__c = 'acme',
                SlackUserId__c = 'bugs');

        SlashclockUtil.newCommand(inboundCommand).execute();

        // Then
        Test.stopTest();

        TimeEntry__c thenEntry = [
            SELECT Id,
                (
                    SELECT Id, NumberOfMinutes__c, Tag__c
                    FROM TimeSlices__r
                )
            FROM TimeEntry__c
            WHERE Id = :givenEntry.Id
        ];

        System.assertEquals(1 ,thenEntry.TimeSlices__r.size(),
                'then entry should have one slice');

        System.assertEquals(30, thenEntry.TimeSlices__r[0].NumberOfMinutes__c,
                Schema.SObjectType.TimeSlice__c.fields.NumberOfMinutes__c.label);

        System.assertEquals('test', thenEntry.TimeSlices__r[0].Tag__c,
                Schema.SObjectType.TimeSlice__c.fields.Tag__c.label);
    }

    /**
     * Given one closed time entry for 1 hour having a 30-minute slice;
     * When a new "slice" command is executed for 30 minutes tagged "test";
     * Then a new time slice should be created under the open time entry
     * showing 30 minutes tagged "test"
     */
    @isTest
    private static void sliceClosedEntry30MinutesSuccess() {

        // Test setup
        TestService.getInstance().setupSlashclockSliceCommandTest();
        
        // Given
        TimeEntry__c givenEntry = [
            SELECT Id, DurationMinutes__c, NumberOfSlicedMinutes__c,
                (
                    SELECT Id, NumberOfMinutes__c, Tag__c
                    FROM TimeSlices__r
                    ORDER BY CreatedDate ASC
                )
            FROM TimeEntry__c
            WHERE SlackTeamId__c = 'acme'
            AND SlackUserId__c = 'daffy'
            ORDER BY StartTime__c DESC
            LIMIT 1
        ];

        System.assertEquals(60, givenEntry.DurationMinutes__c,
                Schema.SObjectType.TimeEntry__c.fields.DurationMinutes__c.label);

        System.assertEquals(30, givenEntry.NumberOfSlicedMinutes__c,
                Schema.SObjectType.TimeEntry__c.fields.NumberOfSlicedMinutes__c.label);

        System.assertEquals(1, givenEntry.TimeSlices__r.size(),
                'given entry should have one slice');

        System.assertEquals(30, givenEntry.TimeSlices__r[0].NumberOfMinutes__c,
                Schema.SObjectType.TimeSlice__c.fields.NumberOfMinutes__c.label);

        System.assertEquals('alpha', givenEntry.TimeSlices__r[0].Tag__c,
                Schema.SObjectType.TimeSlice__c.fields.Tag__c.label);

        // When
        Test.startTest();

        SlashCommand__c inboundCommand = new SlashCommand__c(
                Command__c = '/clock',
                Text__c = 'slice 30 minutes test',
                SlackTeamId__c = 'acme',
                SlackUserId__c = 'daffy');

        SlashclockUtil.newCommand(inboundCommand).execute();

        // Then
        Test.stopTest();

        TimeEntry__c thenEntry = [
            SELECT Id, DurationMinutes__c, NumberOfSlicedMinutes__c,
                (
                    SELECT Id, NumberOfMinutes__c, Tag__c
                    FROM TimeSlices__r
                )
            FROM TimeEntry__c
            WHERE Id = :givenEntry.Id
        ];

        System.assertEquals(60, thenEntry.DurationMinutes__c,
                Schema.SObjectType.TimeEntry__c.fields.DurationMinutes__c.label);

        System.assertEquals(60, thenEntry.NumberOfSlicedMinutes__c,
                Schema.SObjectType.TimeEntry__c.fields.NumberOfSlicedMinutes__c.label);

        System.assertEquals(2 ,thenEntry.TimeSlices__r.size(),
                'then entry should have two slices');

        Boolean has30MinutesTestSlice = false;

        for (TimeSlice__c eachSlice : thenEntry.TimeSlices__r) {
            if (eachSlice.NumberOfMinutes__c == 30 && eachSlice.Tag__c == 'test') {
                has30MinutesTestSlice = true;
            }
        }

        System.assert(has30MinutesTestSlice, 'then entry should have 30-minute test slice');
    }

    /**
     * Given one closed time entry for 1 hour having a 30-minute slice;
     * When a new "slice" command is executed for 31 minutes tagged "test";
     * Then an error should be raised indicating the total sliced duration
     * cannot be longer than the time entry itself
     */
    @isTest
    private static void sliceClosedEntry31MinutesError() {

        // Test setup
        TestService.getInstance().setupSlashclockSliceCommandTest();
        
        // Given
        TimeEntry__c givenEntry = [
            SELECT Id, DurationMinutes__c, NumberOfSlicedMinutes__c,
                (
                    SELECT Id, NumberOfMinutes__c, Tag__c
                    FROM TimeSlices__r
                    ORDER BY CreatedDate ASC
                )
            FROM TimeEntry__c
            WHERE SlackTeamId__c = 'acme'
            AND SlackUserId__c = 'daffy'
            ORDER BY StartTime__c DESC
            LIMIT 1
        ];

        System.assertEquals(60, givenEntry.DurationMinutes__c,
                Schema.SObjectType.TimeEntry__c.fields.DurationMinutes__c.label);

        System.assertEquals(30, givenEntry.NumberOfSlicedMinutes__c,
                Schema.SObjectType.TimeEntry__c.fields.NumberOfSlicedMinutes__c.label);

        System.assertEquals(1, givenEntry.TimeSlices__r.size(),
                'given entry should have one slice');

        System.assertEquals(30, givenEntry.TimeSlices__r[0].NumberOfMinutes__c,
                Schema.SObjectType.TimeSlice__c.fields.NumberOfMinutes__c.label);

        System.assertEquals('alpha', givenEntry.TimeSlices__r[0].Tag__c,
                Schema.SObjectType.TimeSlice__c.fields.Tag__c.label);

        // When
        Test.startTest();

        SlashCommand__c inboundCommand = new SlashCommand__c(
                Command__c = '/clock',
                Text__c = 'slice 31 minutes test',
                SlackTeamId__c = 'acme',
                SlackUserId__c = 'daffy');

        Slashclock.CommandResult result =
                SlashclockUtil.newCommand(inboundCommand).execute();

        // Then
        Test.stopTest();

        TimeEntry__c thenEntry = [
            SELECT Id, DurationMinutes__c, NumberOfSlicedMinutes__c,
                (
                    SELECT Id, NumberOfMinutes__c, Tag__c
                    FROM TimeSlices__r
                )
            FROM TimeEntry__c
            WHERE Id = :givenEntry.Id
        ];

        System.assertEquals(60, thenEntry.DurationMinutes__c,
                Schema.SObjectType.TimeEntry__c.fields.DurationMinutes__c.label);

        System.assertEquals(30, thenEntry.NumberOfSlicedMinutes__c,
                Schema.SObjectType.TimeEntry__c.fields.NumberOfSlicedMinutes__c.label);

        System.assertEquals(1 ,thenEntry.TimeSlices__r.size(),
                'then entry should still only have one slice');

        System.assertEquals(givenEntry.TimeSlices__r[0].Id, thenEntry.TimeSlices__r[0].Id,
                'then entry slice should be same as given entry slice');

        System.assertEquals(false, result.isSuccess(),
                'result should indicate NOT success');
    }
}