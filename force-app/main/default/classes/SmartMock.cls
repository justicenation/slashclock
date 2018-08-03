public interface SmartMock extends HttpCalloutMock {
    Boolean handles(HttpRequest req);
}