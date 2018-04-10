@isTest
private class SmartHttpCalloutMockSuiteTest {

    @isTest
    private static void respond() {

        // Given
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://test.salesforce.com');

        // When
        Test.startTest();

        SmartHttpCalloutMockSuite.SampleCalloutMockSuite mockSuite = new SmartHttpCalloutMockSuite.SampleCalloutMockSuite();
        Boolean handles = mockSuite.handles(req);
        HttpResponse res = mockSuite.respond(req);

        // Then
        Test.stopTest();

        System.assertEquals(true, handles);

        System.assertNotEquals(null, res);
    }

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