global interface SmartHttpCalloutMock extends HttpCalloutMock {

    /**
     * @param req The HttpRequest object
     * 
     * @return whether the mock is intended to handle the given request
     */
    Boolean handles(HttpRequest req);
}