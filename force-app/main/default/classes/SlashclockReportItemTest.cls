@isTest
private class SlashclockReportItemTest {

    @isTest
    private static void addFirstSlice() {

        // Given...
        // Friday, January 20, 2017, 9:00 AM PST
        DateTime startTime = DateTime.newInstance(2017, 1, 20, 17, 0, 0);
        String timeZoneSidKey = 'America/Los_Angeles';
        Time2 itemDuration = Time2.newInstance(0, 3, 0, 0, 0);
        
        SlashclockReportItem item =
                SlashclockReportItem.newInstance(
                        startTime, timeZoneSidKey, itemDuration);

        // When
        Test.startTest();

        TimeSlice__c slice = new TimeSlice__c(
                NumberOfMinutes__c = 60,
                Tag__c = 'TEST');

        item.addSlice(SlashclockReportSlice.newInstance(slice));

        // Then
        Test.stopTest();

        SlashclockReportSlice testSlice = item.getSlice('TEST');

        System.assertEquals(1.0, testSlice.getDuration().hours());
        System.assertEquals('TEST', testSlice.getTag());
    }

    @isTest
    private static void addAnotherSlice() {

        // Given...
        // Friday, January 20, 2017, 9:00 AM PST
        DateTime startTime = DateTime.newInstance(2017, 1, 20, 17, 0, 0);
        String timeZoneSidKey = 'America/Los_Angeles';
        Time2 itemDuration = Time2.newInstance(0, 3, 0, 0, 0);
        
        SlashclockReportItem item =
                SlashclockReportItem.newInstance(
                        startTime, timeZoneSidKey, itemDuration);

        TimeSlice__c firstSlice = new TimeSlice__c(
                NumberOfMinutes__c = 60,
                Tag__c = 'TEST');

        item.addSlice(SlashclockReportSlice.newInstance(firstSlice));

        // When
        Test.startTest();

        TimeSlice__c secondSlice = new TimeSlice__c(
                NumberOfMinutes__c = 60,
                Tag__c = 'TEST');

        item.addSlice(SlashclockReportSlice.newInstance(secondSlice));

        // Then
        Test.stopTest();

        SlashclockReportSlice testSlice = item.getSlice('TEST');

        System.assertEquals(2.0, testSlice.getDuration().hours());
        System.assertEquals('TEST', testSlice.getTag());
    }

    @isTest
    private static void addDifferentSlice() {

        // Given...
        // Friday, January 20, 2017, 9:00 AM PST
        DateTime startTime = DateTime.newInstance(2017, 1, 20, 17, 0, 0);
        String timeZoneSidKey = 'America/Los_Angeles';
        Time2 itemDuration = Time2.newInstance(0, 3, 0, 0, 0);
        
        SlashclockReportItem item =
                SlashclockReportItem.newInstance(
                        startTime, timeZoneSidKey, itemDuration);

        TimeSlice__c firstSlice = new TimeSlice__c(
                NumberOfMinutes__c = 60,
                Tag__c = 'foo');

        item.addSlice(SlashclockReportSlice.newInstance(firstSlice));

        // When
        Test.startTest();

        TimeSlice__c secondSlice = new TimeSlice__c(
                NumberOfMinutes__c = 90,
                Tag__c = 'bar');

        item.addSlice(SlashclockReportSlice.newInstance(secondSlice));

        // Then
        Test.stopTest();

        SlashclockReportSlice fooSlice = item.getSlice('foo');

        System.assertEquals(1.0, fooSlice.getDuration().hours());
        System.assertEquals('foo', fooSlice.getTag());

        SlashclockReportSlice barSlice = item.getSlice('bar');

        System.assertEquals(1.5, barSlice.getDuration().hours());
        System.assertEquals('bar', barSlice.getTag());
    }

    @isTest
    private static void formatNoSlices() {

        // Given
        Time2 itemDuration = Time2.newInstance(0, 3, 0, 0, 0);
        
        SlashclockReportItem item =
                SlashclockReportItem.newInstance('noop', itemDuration);

        // When
        Test.startTest();

        String formatted = item.format();

        // Then
        Test.stopTest();

        System.assertEquals('noop *3h*', formatted);
    }

    @isTest
    private static void formatFirstSlice() {

        // Given...
        // Friday, January 20, 2017, 9:00 AM PST
        DateTime startTime = DateTime.newInstance(2017, 1, 20, 17, 0, 0);
        String timeZoneSidKey = 'America/Los_Angeles';
        Time2 itemDuration = Time2.newInstance(0, 3, 0, 0, 0);
        
        SlashclockReportItem item =
                SlashclockReportItem.newInstance(
                        startTime, timeZoneSidKey, itemDuration);

        // When
        Test.startTest();

        TimeSlice__c slice = new TimeSlice__c(
                NumberOfMinutes__c = 60,
                Tag__c = 'TEST');

        item.addSlice(SlashclockReportSlice.newInstance(slice));

        String formatted = item.format();

        // Then
        Test.stopTest();

        System.assertEquals('Fri *3h* (1h TEST)', formatted);
    }

    @isTest
    private static void formatAnotherSlice() {

        // Given...
        // Friday, January 20, 2017, 9:00 AM PST
        DateTime startTime = DateTime.newInstance(2017, 1, 20, 17, 0, 0);
        String timeZoneSidKey = 'America/Los_Angeles';
        Time2 itemDuration = Time2.newInstance(0, 3, 0, 0, 0);
        
        SlashclockReportItem item =
                SlashclockReportItem.newInstance(
                        startTime, timeZoneSidKey, itemDuration);

        TimeSlice__c firstSlice = new TimeSlice__c(
                NumberOfMinutes__c = 60,
                Tag__c = 'TEST');

        item.addSlice(SlashclockReportSlice.newInstance(firstSlice));

        TimeSlice__c secondSlice = new TimeSlice__c(
                NumberOfMinutes__c = 60,
                Tag__c = 'TEST');

        item.addSlice(SlashclockReportSlice.newInstance(secondSlice));

        // When
        Test.startTest();

        String formatted = item.format();

        // Then
        Test.stopTest();

        System.assertEquals('Fri *3h* (2h TEST)', formatted);
    }

    @isTest
    private static void formatDifferentSlice() {

        // Given...
        // Friday, January 20, 2017, 9:00 AM PST
        DateTime startTime = DateTime.newInstance(2017, 1, 20, 17, 0, 0);
        String timeZoneSidKey = 'America/Los_Angeles';
        Time2 itemDuration = Time2.newInstance(0, 3, 0, 0, 0);
        
        SlashclockReportItem item =
                SlashclockReportItem.newInstance(
                        startTime, timeZoneSidKey, itemDuration);

        TimeSlice__c firstSlice = new TimeSlice__c(
                NumberOfMinutes__c = 60,
                Tag__c = 'foo');

        item.addSlice(SlashclockReportSlice.newInstance(firstSlice));

        TimeSlice__c secondSlice = new TimeSlice__c(
                NumberOfMinutes__c = 90,
                Tag__c = 'bar');

        item.addSlice(SlashclockReportSlice.newInstance(secondSlice));

        // When
        Test.startTest();

        String formatted = item.format();

        // Then
        Test.stopTest();

        System.assertEquals('Fri *3h* (1.5h bar; 1h foo)', formatted);
    }
}