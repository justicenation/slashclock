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

    public List<Account> getAccountsBySlackTeamId(String slackTeamId) {
        return [
            SELECT
                Name,
                SlackTeamId__c,
                Id
            FROM Account
            WHERE SlackTeamId__c = :slackTeamId
        ];
    }

    public String getAnnotation() {
        return this.annotation;
    }

    public ApexJobRequest__c getApexJobRequest(Id recordId) {
        return [
            SELECT
                ApexClassName__c,
                Body__c,
                ErrorMessage__c,
                ErrorStackTrace__c,
                Status__c,
                Id
            FROM ApexJobRequest__c
            WHERE Id = :recordId
        ];
    }

    public Contact getContact(String lastName) {
        return [
            SELECT
                AccountId,
                Email,
                FirstName,
                LastName,
                SlackUserId__c,
                TimeZoneSidKey__c,
                Id
            FROM Contact
            WHERE LastName = :lastName
        ];
    }

    public List<Contact> getContactsBySlackUserId(String slackUserId) {
        return [
            SELECT
                AccountId,
                Name,
                SlackUserId__c,
                Id
            FROM Contact
            WHERE SlackUserId__c = :slackUserId
        ];
    }

    public static String getDatetimeFormat() {
        return 'yyyy-MM-dd HH:mm:ss z';
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

        Contact em = new Contact(
                AccountId = cee.Id,
                FirstName = 'Em',
                LastName = 'Inem (TEST)',
                SlackUserId__c = 'em');

        insert new List<Contact> {
            flip,
            em
        };

        // Create time entries
        TimeEntry__c emcee20170704 = new TimeEntry__c(
                Contact__c = em.Id,
                StartTime__c = DateTime.newInstanceGmt(2017, 7, 4, 8, 0, 0),
                EndTime__c = DateTime.newInstanceGmt(2017, 7, 4, 17, 0, 0),
                SlackUserId__c = 'em',
                SlackTeamId__c = 'cee');
        
        TimeEntry__c emcee20170705 = new TimeEntry__c(
                Contact__c = em.Id,
                StartTime__c = DateTime.newInstanceGmt(2017, 7, 5, 8, 0, 0),
                EndTime__c = DateTime.newInstanceGmt(2017, 7, 5, 17, 30, 0),
                SlackUserId__c = 'em',
                SlackTeamId__c = 'cee');

        TimeEntry__c flipboard30mAgo = new TimeEntry__c(
                Contact__c = flip.Id,
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
                    Body = Blob.valueOf('Content for */clock help*')),
            new Document(
                    FolderId = contentFolderId,
                    Name = SlashclockContentName.UNKNOWN_COMMAND.name(),
                    Body = Blob.valueOf('Unknown command, {0}!')),
            new Document(
                    FolderId = contentFolderId,
                    Name = SlashclockContentName.UNKNOWN_ERROR.name(),
                    Body = Blob.valueOf('Bad command: {0}'))
        };
    }

    public class OauthAccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {

            // Construct the response
            HttpResponse res = new HttpResponse();

            res.setBody([
                SELECT Body
                FROM StaticResource
                WHERE Name = 'SlackApiOauthAccessMock'
            ].Body.toString());

            // Return the response
            return res;
        }
    }

    public class SlackApiServiceStubProvier implements StubProvider {

        public Object handleMethodCall(
                Object stubbedObject,
                String stubbedMethodName,
                Type returnType,
                List<Type> listOfParamTypes,
                List<String> listOfParamNames,
                List<Object> listOfArgs) {
            
            // Initialize the return value
            Object returnValue = null;

            if ('oauthAccess'.equals(stubbedMethodName)) {
                returnValue = this.oauthAccess(
                        (Connection__c)listOfArgs[0], (String)listOfArgs[1]);
            }
            else if ('teamInfo'.equals(stubbedMethodName)) {
                returnValue = this.teamInfo((String)listOfArgs[0]);
            }
            else if ('usersInfo'.equals(stubbedMethodName)) {
                returnValue = this.usersInfo((String)listOfArgs[0]);
            }

            // Return a value
            return returnValue;            
        }

        /**
         * @see `getTimeZoneSidKey` test
         */
        public SlackApi.UsersInfoResponse usersInfo(String userId) {

            // Construct the response
            SlackApi.UsersInfoResponse res =
                    new SlackApi.UsersInfoResponse();

            res.user = new SlackApi.User();
            res.user.tz = 'America/Los_Angeles';

            // Return the response
            return res;
        }

        public SlackApi.OauthAccessResponse oauthAccess(
                Connection__c conn, String authCode) {

            // Construct the reponse
            SlackApi.OauthAccessResponse res =
                    new SlackApi.OauthAccessResponse();

            res.access_token = 'test-access-token';

            // Return the response
            return res;
        }

        public SlackApi.TeamInfoResponse teamInfo(String accessToken) {

            // Construct the response
            SlackApi.TeamInfoResponse res =
                    new SlackApi.TeamInfoResponse();

            res.team = new SlackApi.Team();
            res.team.id = 'test-team-id';

            // Return the response
            return res;
        }
    }

    public class TeamInfoMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {

            // Construct the response
            HttpResponse res = new HttpResponse();

            res.setBody([
                SELECT Body
                FROM StaticResource
                WHERE Name = 'SlackApiTeamInfoMock'
            ].Body.toString());

            // Return the response
            return res;
        }
    }

    public class UsersInfoAcmeBunnyMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {

            // Construct the response
            HttpResponse res = new HttpResponse();

            res.setBody([
                SELECT Body
                FROM StaticResource
                WHERE Name = 'SlackApiUsersInfoAcmeBunnyMock'
            ].Body.toString());

            // Return the response
            return res;
        }
    }
}