@isTest
private class SlashclockReportTest {

    /**
     * Given the appropriate items, produce a report that looks like
     * the following.
     *
     * Mon 8h
     * Tue 7h (1h trails)
     * Wed 9h (1h cert; 0.5h trails)
     * --
     * *SUM* 24h (1h cert; 1.5h trails)
     */
    @isTest
    private static void format() {

        // Given Eastern Time
        String easternTime = 'America/New_York';


        // Given Monday
        DateTime monday = DateTime.newInstance(2017, 8, 21, 12, 0, 0);
        Time2 mondayDuration = Time2.newInstance(0, 8, 0, 0, 0);
        SlashclockReportItem mondayItem =
                SlashclockReportItem.newInstance(
                        monday, easternTime, mondayDuration);

        // Given Tuesday
        DateTime tuesday = DateTime.newInstance(2017, 8, 22, 12, 0, 0);
        Time2 tuesdayDuration = Time2.newInstance(0, 7, 0, 0, 0);
        SlashclockReportItem tuesdayItem =
                SlashclockReportItem.newInstance(
                        tuesday, easternTime, tuesdayDuration);

        SlashclockReportSlice tuesdayTrailsSlice =
                SlashclockReportSlice.newInstance(
                        new TimeSlice__c(
                                NumberOfMinutes__c = 60, Tag__c = 'trails'));

        tuesdayItem.addSlice(tuesdayTrailsSlice);

        // Given Wednesday
        DateTime wednesday = DateTime.newInstance(2017, 8, 23, 12, 0, 0);
        Time2 wednesdayDuration = Time2.newInstance(0, 9, 0, 0, 0);
        SlashclockReportItem wednesdayItem =
                SlashclockReportItem.newInstance(
                        wednesday, easternTime, wednesdayDuration);

        SlashclockReportSlice wednesdayCertSlice =
                SlashclockReportSlice.newInstance(
                        new TimeSlice__c(
                                NumberOfMinutes__c = 60, Tag__c = 'cert'));
        
        wednesdayItem.addSlice(wednesdayCertSlice);

        SlashclockReportSlice wednesdayTrailsSlice =
                SlashclockReportSlice.newInstance(
                        new TimeSlice__c(
                                NumberOfMinutes__c = 30, Tag__c = 'trails'));
        
        wednesdayItem.addSlice(wednesdayTrailsSlice);

        // Given the report
        SlashclockReport report = new SlashclockReport();
        report.addItem(mondayItem);
        report.addItem(tuesdayItem);
        report.addItem(wednesdayItem);

        // When
        Test.startTest();

        String formatted = report.format();

        // Then
        Test.stopTest();

        List<String> expectedLines = new List<String> {
            'Mon *8h*',
            'Tue *7h* (1h trails)',
            'Wed *9h* (1h cert; 0.5h trails)',
            SlashclockReport.DEFAULT_SUMMARY_SEPARATOR,
            'SUM *24h* (1h cert; 1.5h trails)'
        };

        System.assertEquals(String.join(expectedLines, '\n'), formatted);
    }
}