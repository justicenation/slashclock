/**
 * This class provides functional validation and code coverage for the
 * `DatetimeUtil.adjust` method
 */
@isTest
private class DatetimeUtilAdjustTest {

    /**
     * This test covers conversion of the following dates and times
     * from "America/New_York" to "America/Chicago"
     *
     * - March 12, 2017 3:00am Eastern Daylight Time
     * - July 4, 2017 12:00pm Eastern Daylight Time
     * - Nov 5, 2017 1:00am Eastern Standard Time
     * - Dec 25, 2017 12:00pm Eastern Standard Time
     */
    @isTest
    private static void adjustFromAmericaNewYorkToAmericaChicago() {

        // Given
        TimeZone americaNewYork = TimeZone.getTimeZone('America/New_York');
        TimeZone americaChicago = TimeZone.getTimeZone('America/Chicago');

        Map<Datetime, Datetime> expectedMap = new Map<Datetime, Datetime> {
            Datetime.newInstanceGmt(2017, 3, 12, 7, 0, 0) =>
                    Datetime.newInstanceGmt(2017, 3, 12, 6, 0, 0),
            Datetime.newInstanceGmt(2017, 7, 4, 16, 0, 0) =>
                    Datetime.newInstanceGmt(2017, 7, 4, 15, 0, 0),
            Datetime.newInstanceGmt(2017, 11, 5, 6, 0, 0) =>
                    Datetime.newInstanceGmt(2017, 11, 5, 5, 0, 0),
            Datetime.newInstanceGmt(2017, 12, 25, 17, 0, 0) =>
                    Datetime.newInstanceGmt(2017, 12, 25, 16, 0, 0)
        };

        // When
        Test.startTest();

        Map<Datetime, Datetime> actualMap = new Map<Datetime, Datetime>();

        for (Datetime eachKey : expectedMap.keySet()) {
            actualMap.put(eachKey,
                    DatetimeUtil.adjust(
                            eachKey, americaNewYork, americaChicago));
        }

        // Then
        Test.stopTest();

        for (Datetime eachKey : expectedMap.keySet()) {
            Datetime expectedValue = expectedMap.get(eachKey);
            Datetime actualValue = actualMap.get(eachKey);

            // Verify that the dates match
            System.assertEquals(
                    expectedValue.format(getDatetimeFormat(), americaChicago.getID()),
                    actualValue.format(getDatetimeFormat(), americaChicago.getID()),
                    'for key: ' + eachKey);
        }
    }

    /**
     * This test covers conversion of the following dates and times
     * from "America/New_York" to "Asia/Taipei"
     *
     * - March 12, 2017 3:00am Eastern Daylight Time
     * - July 4, 2017 12:00pm Eastern Daylight Time
     * - Nov 5, 2017 1:00am Eastern Standard Time
     * - Dec 25, 2017 12:00pm Eastern Standard Time
     */
    @isTest
    private static void adjustFromAmericaNewYorkToAsiaTaipei() {

        // Given
        TimeZone americaNewYork = TimeZone.getTimeZone('America/New_York');
        TimeZone asiaTaipei = TimeZone.getTimeZone('Asia/Taipei');

        Map<Datetime, Datetime> expectedMap = new Map<Datetime, Datetime> {
            Datetime.newInstanceGmt(2017, 3, 12, 7, 0, 0) =>
                    Datetime.newInstanceGmt(2017, 3, 11, 19, 0, 0),
            Datetime.newInstanceGmt(2017, 7, 4, 16, 0, 0) =>
                    Datetime.newInstanceGmt(2017, 7, 4, 8, 0, 0),
            Datetime.newInstanceGmt(2017, 11, 5, 6, 0, 0) =>
                    Datetime.newInstanceGmt(2017, 11, 4, 22, 0, 0),
            Datetime.newInstanceGmt(2017, 12, 25, 17, 0, 0) =>
                    Datetime.newInstanceGmt(2017, 12, 25, 9, 0, 0)
        };

        // When
        Test.startTest();

        Map<Datetime, Datetime> actualMap = new Map<Datetime, Datetime>();

        for (Datetime eachKey : expectedMap.keySet()) {
            actualMap.put(eachKey,
                    DatetimeUtil.adjust(
                            eachKey, americaNewYork, asiaTaipei));
        }

        // Then
        Test.stopTest();

        for (Datetime eachKey : expectedMap.keySet()) {
            Datetime expectedValue = expectedMap.get(eachKey);
            Datetime actualValue = actualMap.get(eachKey);

            // Verify that the dates match
            System.assertEquals(
                    expectedValue.format(getDatetimeFormat(), asiaTaipei.getID()),
                    actualValue.format(getDatetimeFormat(), asiaTaipei.getID()),
                    'for key: ' + eachKey);
        }
    }

    private static String getDatetimeFormat() {
        return 'yyyy-MM-dd HH:mm:ss z';
    }

    /**
     * This test covers extraction of the date portion of `Datetime` values
     * correctly localized for the "America/New_York" time zone
     *
     * - March 12, 2017 3:00am Eastern Daylight Time
     * - July 4, 2017 12:00pm Eastern Daylight Time
     * - Nov 5, 2017 1:00am Eastern Standard Time
     * - Dec 25, 2017 12:00pm Eastern Standard Time
     */
    @isTest
    public static void getDateInAmericaNewYork() {

        // Given
        TimeZone americaNewYork = TimeZone.getTimeZone('America/New_York');

        Map<Datetime, Date> expectedMap = new Map<Datetime, Date> {
            Datetime.newInstanceGmt(2017, 3, 12, 7, 0, 0) =>
                    Date.newInstance(2017, 3, 12),
            Datetime.newInstanceGmt(2017, 7, 4, 16, 0, 0) =>
                    Date.newInstance(2017, 7, 4),
            Datetime.newInstanceGmt(2017, 11, 5, 6, 0, 0) =>
                    Date.newInstance(2017, 11, 5),
            Datetime.newInstanceGmt(2017, 12, 25, 17, 0, 0) =>
                    Date.newInstance(2017, 12, 25)
        };

        // When
        Test.startTest();

        Map<Datetime, Date> actualMap = new Map<Datetime, Date>();

        for (Datetime eachKey : expectedMap.keySet()) {
            actualMap.put(eachKey,
                    DatetimeUtil.getDate(eachKey, americaNewYork.getID()));
        }

        // Then
        Test.stopTest();

        for (Datetime eachKey : expectedMap.keySet()) {
            Date expectedValue = expectedMap.get(eachKey);
            Date actualValue = actualMap.get(eachKey);

            // Verify that the dates match
            System.assertEquals(
                    expectedValue,
                    actualValue,
                    'for key: ' + eachKey);
        }
    }

    /**
     * This test covers extraction of the time portion of `Datetime` values
     * correctly localized for the "America/New_York" time zone
     *
     * - March 12, 2017 3:00am Eastern Daylight Time
     * - July 4, 2017 12:00pm Eastern Daylight Time
     * - Nov 5, 2017 1:00am Eastern Standard Time
     * - Dec 25, 2017 12:00pm Eastern Standard Time
     */
    @isTest
    public static void getTimeInAmericaNewYork() {

        // Given
        TimeZone americaNewYork = TimeZone.getTimeZone('America/New_York');

        Map<Datetime, Time> expectedMap = new Map<Datetime, Time> {
            Datetime.newInstanceGmt(2017, 3, 12, 7, 0, 0) =>
                    Time.newInstance(3, 0, 0, 0),
            Datetime.newInstanceGmt(2017, 7, 4, 16, 0, 0) =>
                    Time.newInstance(12, 0, 0, 0),
            Datetime.newInstanceGmt(2017, 11, 5, 6, 0, 0) =>
                    Time.newInstance(1, 0, 0, 0),
            Datetime.newInstanceGmt(2017, 12, 25, 17, 0, 0) =>
                    Time.newInstance(12, 0, 0, 0)
        };

        // When
        Test.startTest();

        Map<Datetime, Time> actualMap = new Map<Datetime, Time>();

        for (Datetime eachKey : expectedMap.keySet()) {
            actualMap.put(eachKey,
                    DatetimeUtil.getTime(eachKey, americaNewYork.getID()));
        }

        // Then
        Test.stopTest();

        for (Datetime eachKey : expectedMap.keySet()) {
            Time expectedValue = expectedMap.get(eachKey);
            Time actualValue = actualMap.get(eachKey);

            // Verify that the dates match
            System.assertEquals(
                    expectedValue,
                    actualValue,
                    'for key: ' + eachKey);
        }
    }

    /**
     * This test covers extraction of the time portion of `Datetime` values
     * correctly localized for the "America/New_York" time zone
     *
     * - March 12, 2017 3:00am Eastern Daylight Time
     * - July 4, 2017 12:00pm Eastern Daylight Time
     * - Nov 5, 2017 1:00am Eastern Standard Time
     * - Dec 25, 2017 12:00pm Eastern Standard Time
     */
    @isTest
    public static void getTimeInAsiaTaipei() {

        // Given
        TimeZone asiaTaipei = TimeZone.getTimeZone('Asia/Taipei');

        Map<Datetime, Time> expectedMap = new Map<Datetime, Time> {
            Datetime.newInstanceGmt(2017, 3, 11, 19, 0, 0) =>
                    Time.newInstance(3, 0, 0, 0),
            Datetime.newInstanceGmt(2017, 7, 4, 4, 0, 0) =>
                    Time.newInstance(12, 0, 0, 0),
            Datetime.newInstanceGmt(2017, 11, 4, 17, 0, 0) =>
                    Time.newInstance(1, 0, 0, 0),
            Datetime.newInstanceGmt(2017, 12, 25, 4, 0, 0) =>
                    Time.newInstance(12, 0, 0, 0)
        };

        // When
        Test.startTest();

        Map<Datetime, Time> actualMap = new Map<Datetime, Time>();

        for (Datetime eachKey : expectedMap.keySet()) {
            actualMap.put(eachKey,
                    DatetimeUtil.getTime(eachKey, asiaTaipei.getID()));
        }

        // Then
        Test.stopTest();

        for (Datetime eachKey : expectedMap.keySet()) {
            Time expectedValue = expectedMap.get(eachKey);
            Time actualValue = actualMap.get(eachKey);

            // Verify that the dates match
            System.assertEquals(
                    expectedValue,
                    actualValue,
                    'for key: ' + eachKey);
        }
    }

    /**
     * This test covers conversion of the following `Datetime` value
     * from "America/New_York" to "Asia/Taipei"
     *
     * - March 12, 2017 3:00am Eastern Daylight Time
     */
    @isTest
    private static void adjust2017Mar120300FromAmericaNewYorkToAsiaTaipei() {

        // Given
        TimeZone americaNewYork = TimeZone.getTimeZone('America/New_York');
        TimeZone asiaTaipei = TimeZone.getTimeZone('Asia/Taipei');

        Datetime given = Datetime.newInstanceGmt(2017, 3, 12, 7, 0, 0);
        Datetime expected = Datetime.newInstanceGmt(2017, 3, 11, 19, 0, 0);

        Date givenDate = Date.newInstance(2017, 3, 12);

        System.assertEquals(
                givenDate,
                DatetimeUtil.getDate(given, americaNewYork.getID()),
                'date for: ' + given);

        Time givenTime = Time.newInstance(3, 0, 0, 0);

        System.assertEquals(
                givenTime,
                DatetimeUtil.getTime(given, americaNewYork.getID()),
                'time for: ' + given);

        System.assertEquals(
                '2017-03-12 03:00:00 CST',
                DatetimeUtil.newDatetime(
                        givenDate, givenTime, asiaTaipei.getID()).format(
                                getDatetimeFormat(), asiaTaipei.getID()),
                'DatetimeUtil.newDatetime');

        // When
        Test.startTest();

        Datetime actual = DatetimeUtil.adjust(given, asiaTaipei, americaNewYork);

        // Then
        Test.stopTest();

        System.assertEquals(expected, actual, 'for given: ' + given);
    }
}