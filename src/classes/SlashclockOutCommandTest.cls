@isTest
private class SlashclockOutCommandTest {

    /**
     * The time at which data was set up for this test class.
     */
    private static DateTime setupTime = DateTime.now();

    private static TimeZone setupTimeZone = UserInfo.getTimeZone();

    @testSetup
    private static void setup() {
        RelativeTestService.getInstance(
                setupTime, setupTimeZone.getID()).setup();
    }

    @isTest
    private static void clockOutFiveThirtyPm() {
        System.assert(false, 'TODO');
    }

    @isTest
    private static void clockOutYesterdayFiveThirtyPm() {
        System.assert(false, 'TODO');
    }
}