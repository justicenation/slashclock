@isTest
public with sharing class SlashclockOutCommandMock
        implements SmartHttpCalloutMock {

    private List<Type> mockTypes;

    public SlashclockOutCommandMock() {
        this.mockTypes = getMockTypes();
    }

    public static List<Type> getMockTypes() {
        return new List<Type> {
            SlackApiServiceUsersInfoMock.class
        };
    }

    public Boolean handles(HttpRequest req) {
        Boolean handled = false;

        for (Integer i = 0; i < this.mockTypes.size() && !handled; i++) {
            SmartHttpCalloutMock mock =
                    (SmartHttpCalloutMock)this.mockTypes.get(i).newInstance();

            handled = mock.handles(req);
        }

        return handled;
    }

    public HttpResponse respond(HttpRequest req) {
        return null;
    }
}