public abstract class AbstractSmartMockSuite implements SmartMock {
    public abstract List<SmartMock> getMocks();

    public HttpResponse respond(HttpRequest req) {
        
        // By default, return a useless null
        HttpResponse res = null;

        // Hope that one of the mocks in the suite can handle the request
        for (SmartMock eachMock : this.getMocks()) {
            if (eachMock.handles(req)) {
                res = eachMock.respond(req);
                break;
            }
        }

        // Return the response
        return res;
    }
}