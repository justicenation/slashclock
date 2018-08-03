@isTest
private class SlashclockReportSliceTest {

    @isTest
    private static void properties() {

        // Given
        TimeSlice__c record = new TimeSlice__c(
                NumberOfMinutes__c = 90,
                Tag__c = 'TEST');

        // When
        Test.startTest();

        SlashclockReportSlice slice = SlashclockReportSlice.newInstance(record);

        // Then
        Test.stopTest();

        System.assertEquals(
                Time2.newInstance(0, 1, 30, 0, 0).getTime(),
                slice.getDuration().getTime(),
                'duration');

        System.assertEquals('TEST', slice.getTag(), 'tag');
    }

    @isTest
    private static void format() {

        // Given
        TimeSlice__c record = new TimeSlice__c(
                NumberOfMinutes__c = 90,
                Tag__c = 'TEST');

        SlashclockReportSlice slice = SlashclockReportSlice.newInstance(record);

        // When
        Test.startTest();

        String formatted = slice.format();

        // Then
        Test.stopTest();

        System.assertEquals('1.5h TEST', formatted, 'format()');
    }

    @isTest
    private static void increase() {

        // Given
        TimeSlice__c record = new TimeSlice__c(
                NumberOfMinutes__c = 90,
                Tag__c = 'TEST');

        SlashclockReportSlice slice = SlashclockReportSlice.newInstance(record);

        Time2 increment = Time2.newInstance(0, 1, 0, 0, 0);

        // When
        Test.startTest();

        slice.increase(increment);

        // Then
        Test.stopTest();

        System.assertEquals(
                Time2.newInstance(0, 2, 30, 0, 0).getTime(),
                slice.getDuration().getTime(),
                'duration');
    }
}