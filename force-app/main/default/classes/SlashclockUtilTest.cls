@isTest
private class SlashclockUtilTest {

    @isTest
    private static void formatEntry() {

        // Test setup
        TestService.getInstance().setup();

        // Given
        TimeEntry__c openEntry = new TimeEntry__c(
                SlackUserId__c = 'em',
                SlackTeamId__c = 'cee',
                StartTime__c = DateTime.newInstanceGmt(2017, 11, 21, 3, 0, 0),
                EndTime__c = null);

        TimeEntry__c closedEntry = new TimeEntry__c(
                SlackUserId__c = 'em',
                SlackTeamId__c = 'cee',
                StartTime__c = DateTime.newInstanceGmt(2017, 11, 20, 3, 0, 0),
                EndTime__c = DateTime.newInstanceGmt(2017, 11, 20, 11, 30, 0));

        Integer index = 2;

        String newYorkTimeZoneSidKey = 'America/New_York';
        String kolkataTimeZoneSidKey = 'Asia/Kolkata';

        // When
        Test.startTest();

        String openEntryNewYorkTime = SlashclockUtil.formatEntry(
                openEntry, index, newYorkTimeZoneSidKey);
        
        String openEntryKolkataTime = SlashclockUtil.formatEntry(
                openEntry, index, kolkataTimeZoneSidKey);
        
        String closedEntryNewYorkTime = SlashclockUtil.formatEntry(
                closedEntry, index, newYorkTimeZoneSidKey);
        
        String closedEntryKolkataTime = SlashclockUtil.formatEntry(
                closedEntry, index, kolkataTimeZoneSidKey);

        // Then
        Test.stopTest();

        System.assertEquals('2. Mon 11/20 10:00pm - now', openEntryNewYorkTime);

        System.assertEquals('2. Tue 11/21 8:30am - now', openEntryKolkataTime);

        System.assertEquals('2. Sun 11/19 10:00pm - 6:30am', closedEntryNewYorkTime);

        System.assertEquals('2. Mon 11/20 8:30am - 5:00pm', closedEntryKolkataTime);
    }

    @isTest
    private static void emcee20170703SevenDayReportItems() {

        // Test setup
        TestService.getInstance().setup();

        // Given
        String userId = 'em';
        String teamId = 'cee';

        DateTime startTime = DateTime.newInstanceGmt(2017, 7, 3, 0, 0, 0);
        DateTime endTime = DateTime.newInstanceGmt(2017, 7, 10, 0, 0, 0);

        List<TimeEntry__c> entries = [
            SELECT Id, StartTime__c, EndTime__c,
                (SELECT Id, NumberOfMinutes__c, Tag__c FROM TimeSlices__r)
            FROM TimeEntry__c
            WHERE SlackUserId__c = :userId
                AND SlackTeamId__c = :teamId
                AND StartTime__c < :endTime
                AND (EndTime__c >= :startTime OR EndTime__c = NULL)
            ORDER BY StartTime__c ASC
        ];

        System.assertEquals(2, entries.size());
        
        System.assertEquals(
                DateTime.newInstanceGmt(2017, 7, 4, 8, 0, 0).format(),
                entries[0].StartTime__c.format());
        System.assertEquals(0, entries[0].TimeSlices__r.size());

        System.assertEquals(
                DateTime.newInstanceGmt(2017, 7, 5, 8, 0, 0).format(),
                entries[1].StartTime__c.format());
        System.assertEquals(1, entries[1].TimeSlices__r.size());

        // When
        Test.startTest();

        List<SlashclockReportItem> items = SlashclockUtil.newDailyReportItems(
                startTime, endTime, 'GMT', entries, 7);

        // Then
        Test.stopTest();

        System.assertEquals(7, items.size(), 'number of report items');

        System.assertEquals('Mon *0h*', items[0].format());
        System.assertEquals('Tue *9h*', items[1].format());
        System.assertEquals('Wed *9.5h* (1.5h apex)', items[2].format());
        System.assertEquals('Thu *0h*', items[3].format());
        System.assertEquals('Fri *0h*', items[4].format());
        System.assertEquals('Sat *0h*', items[5].format());
        System.assertEquals('Sun *0h*', items[6].format());
    }
}