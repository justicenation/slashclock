@isTest
private class TimeTest {

    /**
     * Adding the following times should give a total of 8h.
     *
     * - 2h
     * - 2h 30m
     * - 3h 30m
     */
    @isTest
    private static void totalEightHours() {

        // Given
        List<Time> times = new List<Time> {
            Time.newInstance(2, 0, 0, 0),
            Time.newInstance(2, 30, 0, 0),
            Time.newInstance(3, 30, 0, 0)
        };

        // When
        Test.startTest();

        Time totalTime = Time.newInstance(0, 0, 0, 0);
        for (Time eachTime : times) {
            totalTime = totalTime.addHours(eachTime.hour());
            totalTime = totalTime.addMinutes(eachTime.minute());
        }

        // Then
        Test.stopTest();

        System.assertEquals(8, totalTime.hour(), 'totalTime.hours');
        System.assertEquals(0, totalTime.minute(), 'totalTime.minutes');
    }

    /**
     * Adding the following times should give a total of 40h 30m.
     * But since the `Time` object wraps afte 24h, the actual result will
     * show 16h 30m.
     *
     * - 8h 30m
     * - 8h
     * - 8h
     * - 8h
     * - 8h
     */
    @isTest
    private static void totalFortyHoursThirtyMinutes() {

        // Given
        List<Time> times = new List<Time> {
            Time.newInstance(8, 30, 0, 0),
            Time.newInstance(8, 0, 0, 0),
            Time.newInstance(8, 0, 0, 0),
            Time.newInstance(8, 0, 0, 0),
            Time.newInstance(8, 0, 0, 0)
        };

        // When
        Test.startTest();

        Time totalTime = Time.newInstance(0, 0, 0, 0);
        for (Time eachTime : times) {
            totalTime = totalTime.addHours(eachTime.hour());
            totalTime = totalTime.addMinutes(eachTime.minute());
        }

        // Then
        Test.stopTest();

        System.assertEquals(16, totalTime.hour(), 'totalTime.hours');
        System.assertEquals(30, totalTime.minute(), 'totalTime.minutes');
    }
}