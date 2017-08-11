public with sharing class TestService {

    public static final String SAMPLE_ANNOTATION = 'SAMPLE';

    public static final String TEST_ANNOTATION = 'TEST';

    private String annotation;

    public TestService(Boolean runningTest) {
        this(runningTest ? TEST_ANNOTATION : SAMPLE_ANNOTATION);
    }

    public TestService(String annotation) {
        this.annotation = annotation;
    }

    public static TestService getInstance() {
        return new TestService(Test.isRunningTest());
    }

    /**
     * Create the records necessary to stage all tests, including unit tests
     * and integration tests.
     */
    public void setup() {

        // Create time entries
        insert new List<TimeEntry__c> {
            new TimeEntry__c(
                    StartTime__c = DateTime.now().addMinutes(-30),
                    SlackUserId__c = 'flip',
                    SlackTeamId__c = 'board')
        };
    }
}