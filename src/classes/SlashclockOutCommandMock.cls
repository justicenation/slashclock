public with sharing class SlashclockOutCommandMock
        implements SmartHttpCalloutMock {

    public Boolean handles(HttpRequest req) {
        return false;
    }

    public HttpResponse respond(HttpRequest req) {
        return null;
    }
}