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

    public String annotate(String value) {
        return value + ' (' + this.getAnnotation() + ')';
    }

    public String getAnnotation() {
        return this.annotation;
    }

    public static TestService getInstance() {
        return new TestService(Test.isRunningTest());
    }

    /**
     * Create the records necessary to stage all tests, including unit tests
     * and integration tests.
     */
    public void setup() {

        // Create accounts
        Account acme = new Account(
                Name = this.annotate('Acme Corporation'),
                SlackTeamId__c = 'acme');

        Account cee = new Account(
                Name = this.annotate('Cerebro, Inc.'),
                SlackTeamId__c = 'cee');

        Account board = new Account(
                Name = this.annotate('Board, Inc.'),
                SlackTeamId__c = 'board');

        Account bar = new Account(
                Name = this.annotate('Bar Service'),
                SlackTeamId__c = 'bar');

        insert new List<Account> { acme, cee, board, bar };

        // Create contacts
        Contact flip = new Contact(
                AccountId = board.Id,
                FirstName = 'Baxter',
                LastName = this.annotate('Flip'),
                SlackUserId__c = 'flip');

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

        // Create documents
        Id contentFolderId =
                SlashclockContentService.getInstance().getContentFolderId();

        insert new List<Document> {
            new Document(
                    FolderId = contentFolderId,
                    Name = SlashclockContentName.HELP_IN_OUT_COMMAND.name(),
                    Body = Blob.valueOf('Content for */clock help in and out*')),
            new Document(
                    FolderId = contentFolderId,
                    Name = SlashclockContentName.HELP_REPORT_COMMAND.name(),
                    Body = Blob.valueOf('Content for */clock help report*')),
            new Document(
                    FolderId = contentFolderId,
                    Name = SlashclockContentName.HELP_SLICE_COMMAND.name(),
                    Body = Blob.valueOf('Content for */clock help slice*')),
            new Document(
                    FolderId = contentFolderId,
                    Name = SlashclockContentName.HELP_ENTRIES_COMMAND.name(),
                    Body = Blob.valueOf('Content for */clock help entries*')),
            new Document(
                    FolderId = contentFolderId,
                    Name = SlashclockContentName.HELP_STRIKE_COMMAND.name(),
                    Body = Blob.valueOf('Content for */clock help strike*')),
            new Document(
                    FolderId = contentFolderId,
                    Name = SlashclockContentName.HELP_COMMAND.name(),
                    Body = Blob.valueOf('Content for */clock help*'))
        };
    }
}