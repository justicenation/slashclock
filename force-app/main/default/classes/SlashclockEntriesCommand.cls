/**
 * `/clock entries` returns a list of all time entries within the last seven
 * days (i.e., 24 hours/day * 7 days), based on the Start Time. The entries
 * should be returned in reverse chronologic order with the most recent entry
 * at the top, and each entry should be displayed with a numeric index for
 * use with the `/clock strike` command to delete a time entry.
 */
public with sharing class SlashclockEntriesCommand implements Slashclock.Command {

    private DateTime currentTime;

    /**
     * The number of days to include when looking for entries to display
     */
    private Integer numberOfDays;

    private Contact userContact;

    public SlashclockEntriesCommand() {
        this.userContact = null;

        // TODO: Make configurable
        this.numberOfDays = 7;
        this.currentTime = DateTime.now();
    }

    public Slashclock.CommandResult execute() {

        // Initialize the result
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        // Clock in via service
        try {
            SlashclockService slashclock =
                    SlashclockService.getInstance(this.userContact);

            List<TimeEntry__c> entries = slashclock.getTimeEntriesSince(
                    this.currentTime.addDays(-1 * numberOfDays));

            result.setMessage(slashclock.formatEntries(entries));
            result.setSuccess(true);
        }
        catch (SlashclockException caught) {
            result.setMessage(caught.getMessage());
        }

        // Return the result
        return result;
    }

    public Slashclock.Command load(SlashCommand__c command) {

        // Locate the contact and the time zone
        SlackService slacker = SlackService.getInstance(command.SlackTeamId__c);
        this.userContact = slacker.findOrCreateContact(command.SlackUserId__c);
        
        // Return the fully loaded SlashClock command!
        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        
        // Return whether we found a match
        return command.Text__c.startsWith('entries');
    }
}