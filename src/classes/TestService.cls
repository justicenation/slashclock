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
        TimeEntry__c emcee20170704 = new TimeEntry__c(
                StartTime__c = DateTime.newInstanceGmt(2017, 7, 4, 8, 0, 0),
                EndTime__c = DateTime.newInstanceGmt(2017, 7, 4, 17, 0, 0),
                SlackUserId__c = 'em',
                SlackTeamId__c = 'cee');
        
        TimeEntry__c emcee20170705 = new TimeEntry__c(
                StartTime__c = DateTime.newInstanceGmt(2017, 7, 5, 8, 0, 0),
                EndTime__c = DateTime.newInstanceGmt(2017, 7, 5, 17, 30, 0),
                SlackUserId__c = 'em',
                SlackTeamId__c = 'cee');

        TimeEntry__c flipboard30mAgo = new TimeEntry__c(
                StartTime__c = DateTime.now().addMinutes(-30),
                SlackUserId__c = 'flip',
                SlackTeamId__c = 'board');

        insert new List<TimeEntry__c> {
            emcee20170704,
            emcee20170705,
            flipboard30mAgo
        };

        // Create time slices
        TimeSlice__c emcee20170705slice = new TimeSlice__c(
                TimeEntry__c = emcee20170705.Id,
                NumberOfMinutes__c = 90,
                Tag__c = 'apex');

        insert new List<TimeSlice__c> {
            emcee20170705slice
        };
    }
}