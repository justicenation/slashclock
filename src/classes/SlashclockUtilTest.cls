@isTest
private class SlashclockUtilTest {

    @isTest
    private static void emcee20170703SevenDayReportItems() {

        // Given
        String userId = 'em';
        String teamId = 'cee';

        SlashclockService clock = SlashclockService.getInstance(userId, teamId);

        DateTime startTime = DateTime.newInstanceGmt(2017, 7, 3, 0, 0, 0);
        DateTime endTime = DateTime.newInstanceGmt(2017, 7, 10, 0, 0, 0);

        List<TimeEntry__c> entries = clock.getTimeEntries(startTime, endTime);

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

        System.assertEquals('Mon 0h', items[0].format());
        System.assertEquals('Tue 9h', items[1].format());
        System.assertEquals('Wed 9.5h (1.5h apex)', items[2].format());
        System.assertEquals('Thu 0h', items[3].format());
        System.assertEquals('Fri 0h', items[4].format());
        System.assertEquals('Sat 0h', items[5].format());
        System.assertEquals('Sun 0h', items[6].format());
    }

    @testSetup
    private static void setup() {
        TestService.getInstance().setup();
    }
}