@isTest
private class DateTimeUtilTest {

    @isTest
    private static void setScale3() {

        // Given
        Map<Datetime, Datetime> expectedMap = new Map<Datetime, Datetime> {
            Datetime.newInstanceGmt(2018, 1, 23, 12, 0, 0) =>
            Datetime.newInstanceGmt(2018, 1, 23, 12, 0, 0),
            
            Datetime.newInstanceGmt(2018, 1, 23, 23, 58, 30) =>
            Datetime.newInstanceGmt(2018, 1, 24, 0, 0, 0),
            
            Datetime.newInstanceGmt(2018, 1, 23, 23, 59, 0) =>
            Datetime.newInstanceGmt(2018, 1, 24, 0, 0, 0),
            
            Datetime.newInstanceGmt(2018, 1, 23, 12, 30, 0) =>
            Datetime.newInstanceGmt(2018, 1, 23, 12, 30, 0)
        };

        Integer scale = 3;  // for this test

        // When
        Test.startTest();

        Map<Datetime, Datetime> actualMap = new Map<Datetime, Datetime>();

        for (Datetime eachGivenValue : expectedMap.keySet()) {
            actualMap.put(eachGivenValue,
                    DatetimeUtil.setScale(eachGivenValue, scale));
        }

        // Then
        Test.stopTest();

        for (Datetime eachGivenValue : expectedMap.keySet()) {
            Datetime expected = expectedMap.get(eachGivenValue);
            Datetime actual = actualMap.get(eachGivenValue);

            System.assertEquals(expected, actual, eachGivenValue);
        }
    }

    @isTest
    private static void getWeekday() {

        // Given
        Date sunday    = Date.newInstance(2017, 8, 27);
        Date monday    = Date.newInstance(2017, 8, 28);
        Date tuesday   = Date.newInstance(2017, 8, 29);
        Date wednesday = Date.newInstance(2017, 8, 30);
        Date thursday  = Date.newInstance(2017, 8, 31);
        Date friday    = Date.newInstance(2017, 9, 1);
        Date saturday  = Date.newInstance(2017, 9, 2);

        // Then
        System.assertEquals(0, DateTimeUtil.getWeekday(sunday));
        System.assertEquals(1, DateTimeUtil.getWeekday(monday));
        System.assertEquals(2, DateTimeUtil.getWeekday(tuesday));
        System.assertEquals(3, DateTimeUtil.getWeekday(wednesday));
        System.assertEquals(4, DateTimeUtil.getWeekday(thursday));
        System.assertEquals(5, DateTimeUtil.getWeekday(friday));
        System.assertEquals(6, DateTimeUtil.getWeekday(saturday));
    }

    /**
     * Given August 31, 2017
     * and Sunday being the start of the week;
     * When `startOfWeek` is invoked with the given parameters;
     * Then August 27, 2017 is returned
     */
    @isTest
    private static void startOfWeekFor20170831FirstDaySunday() {

        // Given
        Date refDate = Date.newInstance(2017, 8, 31);

        // When
        Test.startTest();

        Date startOfWeek = DateTimeUtil.startOfWeek(refDate, Weekday.SUNDAY);

        // Then
        Test.stopTest();

        System.assertEquals(2017, startOfWeek.year(), 'startOfWeek.year');
        System.assertEquals(8, startOfWeek.month(), 'startOfWeek.month');
        System.assertEquals(27, startOfWeek.day(), 'startOfWeek.day');
    }

    /**
     * Given August 31, 2017 10:00pm EDT
     * and time zone "America/New_York"
     * and Sunday being the start of the week;
     * When `startOfWeek` is invoked with the given parameters;
     * Then 2017-08-27T04:00:00.000Z is returned
     */
    @isTest
    private static void startOfWeekFor201708312200edtFirstDaySunday() {

        // Given
        DateTime refDate = DateTime.newInstanceGmt(2017, 9, 1, 2, 0, 0);
        String tz = 'America/New_York';
        String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ssZ';

        System.assertEquals('2017-08-31T22:00:00-0400',
                refDate.format(dateFormat, tz),
                refDate.format());

        // When
        Test.startTest();

        DateTime startOfWeek =
                DateTimeUtil.startOfWeek(refDate, tz, Weekday.SUNDAY);

        // Then
        Test.stopTest();

        System.assertEquals('2017-08-27T00:00:00-0400',
                startOfWeek.format(dateFormat, tz),
                'startOfWeek');
    }

    /**
     * Given August 31, 2017 10:00pm EDT
     * and time zone "America/New_York"
     * and Monday being the start of the week;
     * When `startOfWeek` is invoked with the given parameters;
     * Then 2017-08-28T04:00:00.000Z is returned
     */
    @isTest
    private static void startOfWeekFor201708312200edtFirstDayMonday() {

        // Given
        DateTime refDate = DateTime.newInstanceGmt(2017, 9, 1, 2, 0, 0);
        String tz = 'America/New_York';
        String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ssZ';

        System.assertEquals('2017-08-31T22:00:00-0400',
                refDate.format(dateFormat, tz),
                refDate.format());

        // When
        Test.startTest();

        DateTime startOfWeek =
                DateTimeUtil.startOfWeek(refDate, tz, Weekday.MONDAY);

        // Then
        Test.stopTest();

        System.assertEquals('2017-08-28T00:00:00-0400',
                startOfWeek.format(dateFormat, tz),
                'startOfWeek');
    }

    /**
     * Make sure that, when `startOfWeek` is invoked at exactly the first minute
     * of a new week, the same minute is returned.
     *
     * Given August 28, 2017 12:00am EDT
     * and time zone "America/New_York"
     * and Monday being the start of the week;
     * When `startOfWeek` is invoked with the given parameters;
     * Then 2017-08-28T04:00:00.000Z is returned
     */
    @isTest
    private static void startOfWeekFor201708280000edtFirstDayMonday() {

        // Given
        DateTime refDate = DateTime.newInstanceGmt(2017, 8, 28, 4, 0, 0);
        String tz = 'America/New_York';
        String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ssZ';

        System.assertEquals('2017-08-28T00:00:00-0400',
                refDate.format(dateFormat, tz),
                refDate.format());

        // When
        Test.startTest();

        DateTime startOfWeek =
                DateTimeUtil.startOfWeek(refDate, tz, Weekday.MONDAY);

        // Then
        Test.stopTest();

        System.assertEquals('2017-08-28T00:00:00-0400',
                startOfWeek.format(dateFormat, tz),
                'startOfWeek');
    }

    /**
     * Make sure that the correct start of week time is returned during
     * the week when Boston goes from Eastern Standard Time to
     * Eastern Daylight Time.
     *
     * When local standard time was about to reach
     * Sunday, March 12, 2017, 2:00:00 am clocks were turned forward 1 hour to 
     * Sunday, March 12, 2017, 3:00:00 am local daylight time instead.
     *
     * Given March 15, 2017 9:30am EDT
     * and time zone "America/New_York"
     * and Sunday being the start of the week;
     * When `startOfWeek` is invoked with the given parameters;
     * Then 2017-03-12T00:00:00.000-0500 is returned
     */
    @isTest
    private static void startOfWeekFor201703150930edtFirstDaySunday() {

        // Given
        DateTime refDate = DateTime.newInstanceGmt(2017, 3, 15, 13, 30, 0);
        String tz = 'America/New_York';
        String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ssZ';

        System.assertEquals('2017-03-15T09:30:00-0400',
                refDate.format(dateFormat, tz),
                refDate.format());

        // When
        Test.startTest();

        DateTime startOfWeek =
                DateTimeUtil.startOfWeek(refDate, tz, Weekday.SUNDAY);

        // Then
        Test.stopTest();

        System.assertEquals('2017-03-12T00:00:00-0500',
                startOfWeek.format(dateFormat, tz),
                'startOfWeek');
    }

    /**
     * Make sure that the correct start of week time is returned during
     * the week when Boston goes from Eastern Daylight Time to
     * Eastern Standard Time.
     *
     * When local daylight time is about to reach
     * Sunday, November 5, 2017, 2:00:00 am clocks are turned backward 1 hour to 
     * Sunday, November 5, 2017, 1:00:00 am local standard time instead.
     *
     * Given November 8, 2017 9:30am EST
     * and time zone "America/New_York"
     * and Sunday being the start of the week;
     * When `startOfWeek` is invoked with the given parameters;
     * Then 2017-11-05T00:00:00.000-0400 is returned
     */
    @isTest
    private static void startOfWeekFor20171105930estFirstDaySunday() {

        // Given
        DateTime refDate = DateTime.newInstanceGmt(2017, 11, 8, 14, 30, 0);
        String tz = 'America/New_York';
        String dateFormat = 'yyyy-MM-dd\'T\'HH:mm:ssZ';

        System.assertEquals('2017-11-08T09:30:00-0500',
                refDate.format(dateFormat, tz),
                refDate.format());

        // When
        Test.startTest();

        DateTime startOfWeek =
                DateTimeUtil.startOfWeek(refDate, tz, Weekday.SUNDAY);

        // Then
        Test.stopTest();

        System.assertEquals('2017-11-05T00:00:00-0400',
                startOfWeek.format(dateFormat, tz),
                'startOfWeek');
    }
}