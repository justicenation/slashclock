public with sharing class DatabaseJockeyMock extends SimpleStubProvider {

    public static DatabaseJockey newInstance() {
        return (DatabaseJockey)Test.createStub(
            DatabaseJockey.class,
            new DatabaseJockeyMock()
        );
    }
}