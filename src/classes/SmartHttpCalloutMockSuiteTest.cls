@isTest
private class SmartHttpCalloutMockSuiteTest {

    @isTest
    private static void respond() {

        // Given
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://test.salesforce.com');

        // When
        Test.startTest();

        SampleCalloutMockSuite mockSuite = new SampleCalloutMockSuite();
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

    private class SampleCalloutMock implements SmartHttpCalloutMock {
        public Boolean handles(HttpRequest req) {
            return true;
        }

        public HttpResponse respond(HttpRequest req) {
            return new HttpResponse();
        }
    }

    private class SampleCalloutMockSuite extends SmartHttpCalloutMockSuite {
        public override List<Type> getMockTypes() {
            return new List<Type> {
                SampleCalloutMock.class
            };
        }
    }
}