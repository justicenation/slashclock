/**
 * This class is used to create test or sample data that has relative dates
 * to a given reference date. The data would be useful for setting up data
 * to test commands that handle concepts like "yesterday" or "last week".
 */
public class RelativeTestService {

    private Datetime reference;
    private Date referenceDate;
    private Time referenceTime;
    private String timeZoneSidKey;

    public RelativeTestService(Datetime reference, String timeZoneSidKey) {
        this.reference = reference;
        this.timeZoneSidKey = timeZoneSidKey;

        this.referenceDate = DateTimeUtil.getDate(
                this.reference, timeZoneSidKey);
        this.referenceTime = DateTimeUtil.getTime(
                this.reference, timeZoneSidKey);
    }

    public static RelativeTestService getInstance(
            Datetime referenceDate, String timeZoneSidKey) {
        return new RelativeTestService(referenceDate, timeZoneSidKey);
    }

    public void setup() {

        Datetime twoDaysAgo = this.reference.addDays(-2);
        Datetime oneDaysAgo = this.reference.addDays(-1);
        Datetime thirtyMinutesAgo = this.reference.addMinutes(-30);
        
        Date yesterday = this.referenceDate.addDays(-1);
        
        Datetime yesterdayNineFifteen =
                DateTimeUtil.newDatetime(
                        yesterday, Time.newInstance(9, 15, 0, 0),
                        this.timeZoneSidKey);
        
        Datetime yesterdayTenFifteen =
                DateTimeUtil.newDatetime(
                        yesterday, Time.newInstance(10, 15, 0, 0),
                        this.timeZoneSidKey);

        // Create accounts
        Account board = new Account(
                Name = 'Board, Inc. (TEST)',
                SlackTeamId__c = 'board');

        insert new List<Account> {
            board
        };

        // Create contacts
        Contact flip = new Contact(
                AccountId = board.Id,
                FirstName = 'Baxter',
                LastName = 'Flip (TEST)',
                SlackUserId__c = 'flip',
                TimeZoneSidKey__c = this.timeZoneSidKey);

        Contact kick = new Contact(
                AccountId = board.Id,
                FirstName = 'Dynamo',
                LastName = 'Kick (TEST)',
                SlackuserId__c = 'kick',
                TimeZoneSidKey__c = this.timeZoneSidKey);

        Contact skate = new Contact(
                AccountId = board.Id,
                FirstName = 'Slick',
                LastName = 'Skate (TEST)',
                SlackUserId__c = 'skate',
                TimeZoneSidKey__c = this.timeZoneSidKey);

        insert new List<Contact> {
            skate,
            kick,
            flip
        };

        // Create time entries
        TimeEntry__c kickboard2DaysAgo = new TimeEntry__c(
                Contact__c = kick.Id,
                StartTime__c = twoDaysAgo,
                StartTimeZoneSidKey__c = this.timeZoneSidKey,
                SlackUserId__c = 'kick',
                SlackTeamId__c = 'board');

        TimeEntry__c flipboard30mAgo = new TimeEntry__c(
                Contact__c = flip.Id,
                StartTime__c = thirtyMinutesAgo,
                SlackUserId__c = 'flip',
                SlackTeamId__c = 'board');

        TimeEntry__c skateboardYesterdayNineFifteen = new TimeEntry__c(
                Contact__c = skate.Id,
                StartTime__c = yesterdayNineFifteen,
                EndTime__c = yesterdayNineFifteen.addMinutes(30),
                SlackUserId__c = 'skate',
                SlackTeamId__c = 'board');

        TimeEntry__c skateboardYesterdayTenFifteen = new TimeEntry__c(
                Contact__c = skate.Id,
                StartTime__c = yesterdayTenFifteen,
                EndTime__c = yesterdayTenFifteen.addHours(7).addMinutes(30),
                SlackUserId__c = 'skate',
                SlackTeamId__c = 'board');

        insert new List<TimeEntry__c> {
            skateboardYesterdayNineFifteen,
            skateboardYesterdayTenFifteen,
            kickboard2DaysAgo,
            flipboard30mAgo
        };
    }
}