@isTest
private class SmartHttpCalloutMockSuiteTest {

    @isTest
    private static void throwUnknownRequestException() {

        // Given
        SmartHttpCalloutMockSuite mock = new SmartHttpCalloutMockSuite();

        // When
        Test.startTest();

        SmartHttpCalloutMockSuite.UnknownRequestException error = null;

        try {
            HttpResponse res = mock.respond(new HttpRequest());
        }
        catch (SmartHttpCalloutMockSuite.UnknownRequestException caught) {
            error = caught;
        }

        // Then
        Test.stopTest();

        System.assertNotEquals(null, error);
    }
}