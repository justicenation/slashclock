@isTest
private class SlashclockSliceCommandTest {

    @testSetup
    private static void setup() {

        // Create accounts
        Account acme = new Account(
                Name = 'Acme Corporation (TEST)',
                SlackTeamId__c = 'acme');

        insert new List<Account> {
            acme
        };

        // Create contacts
        Contact bugs = new Contact(
                AccountId = acme.Id,
                FirstName = 'Bugs',
                LastName = 'Bunny (TEST)',
                Email = 'bugs@acme.com.test',
                SlackUserId__c = 'bugs');

        Contact daffy = new Contact(
                AccountId = acme.Id,
                FirstName = 'Daffy',
                LastName = 'Duck (TEST)',
                Email = 'daffy@acme.com.test',
                SlackUserId__c = 'daffy');

        insert new List<Contact> {
            bugs,
            daffy
        };

        // Create time entries
        TimeEntry__c bugs20171106930 = new TimeEntry__c(
                SlackUserId__c = 'bugs',
                SlackTeamId__c = 'acme',
                Contact__c = bugs.Id,
                StartTime__c = DateTime.newInstanceGmt(2017, 11, 6, 9, 30, 0),
                EndTime__c = DateTime.newInstanceGmt(2017, 11, 6, 10, 30, 0));

        TimeEntry__c bugs20171107930 = new TimeEntry__c(
                SlackUserId__c = 'bugs',
                SlackTeamId__c = 'acme',
                Contact__c = bugs.Id,
                StartTime__c = DateTime.newInstanceGmt(2017, 11, 7, 9, 30, 0));

        TimeEntry__c daffy20171106930 = new TimeEntry__c(
                SlackUserId__c = 'daffy',
                SlackTeamId__c = 'acme',
                Contact__c = daffy.Id,
                StartTime__c = DateTime.newInstanceGmt(2017, 11, 6, 9, 30, 0),
                EndTime__c = DateTime.newInstanceGmt(2017, 11, 6, 10, 30, 0));

        insert new List<TimeEntry__c> {
            bugs20171106930,
            bugs20171107930,
            daffy20171106930
        };

        // Create time slices
        TimeSlice__c daffy20171106930alpha30 = new TimeSlice__c(
                TimeEntry__c = daffy20171106930.Id,
                NumberOfMinutes__c = 30,
                Tag__c = 'alpha');

        insert new List<TimeSlice__c> {
            daffy20171106930alpha30
        };
    }

    /**
     * Given two time entries, with the last one being open with no slices;
     * When a new "slice" command is executed for 30 minutes tagged "test";
     * Then a new time slice should be created under the open time entry
     * showing 30 minutes tagged "test"
     */
    @isTest
    private static void sliceOpenEntry30Minutes() {
        
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
                Command__c = 'slice 30 minutes test',
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
        System.assert(false, 'TODO');
    }

    /**
     * Given one closed time entry for 1 hour having a 30-minute slice;
     * When a new "slice" command is executed for 31 minutes tagged "test";
     * Then an error should be raised indicating the total sliced duration
     * cannot be longer than the time entry itself
     */
    @isTest
    private static void sliceClosedEntry31MinutesError() {
        System.assert(false, 'TODO');
    }
}