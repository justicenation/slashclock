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
                SlackUserId__c = 'flip');

        insert new List<Contact> {
            flip
        };

        // Create time entries

        TimeEntry__c flipboard30mAgo = new TimeEntry__c(
                StartTime__c = this.reference.addMinutes(-30),
                SlackUserId__c = 'flip',
                SlackTeamId__c = 'board');

        insert new List<TimeEntry__c> {
            flipboard30mAgo
        };
    }
}