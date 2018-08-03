public virtual class SmartHttpCalloutMockSuite implements SmartHttpCalloutMock {

    private Map<HttpRequest, HttpCalloutMock> mockMap;

    public SmartHttpCalloutMockSuite() {
        this.mockMap = new Map<HttpRequest, HttpCalloutMock>();
    }

    public HttpCalloutMock getMock(HttpRequest req) {
        return this.mockMap.get(req);
    }

    public virtual List<Type> getMockTypes() {
        return new List<Type>();
    }

    public Boolean handles(HttpRequest req) {

        List<Type> mockTypes = this.getMockTypes();

        // Determine whether the request is handled by any of the mock types
        while (!this.mockMap.containsKey(req) && !mockTypes.isEmpty()) {

            // Initialize the mock to try
            SmartHttpCalloutMock mock =
                    (SmartHttpCalloutMock)mockTypes.remove(0).newInstance();

            // If the mock handles the request, we know we're good to go
            if (mock.handles(req)) {
                this.mockMap.put(req, mock);
            }
        }

        // Return the result
        return this.mockMap.containsKey(req);
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = null;

        if (this.handles(req)) {
            res = this.getMock(req).respond(req);
        }
        else {
            throw new UnknownRequestException(req);
        }

        return res;
    }

    public class SampleCalloutMock implements SmartHttpCalloutMock {
        public Boolean handles(HttpRequest req) {
            return true;
        }

        public HttpResponse respond(HttpRequest req) {
            return new HttpResponse();
        }
    }

    public class SampleCalloutMockSuite extends SmartHttpCalloutMockSuite {
        public override List<Type> getMockTypes() {
            return new List<Type> {
                SampleCalloutMock.class
            };
        }
    }

    public class UnknownRequestException extends System.Exception {
        public UnknownRequestException(HttpRequest req) {
            this(String.join(new List<String> {
                req.getMethod(),
                req.getEndpoint(),
                req.getBody()
            }, '|'));
        }
    }
}