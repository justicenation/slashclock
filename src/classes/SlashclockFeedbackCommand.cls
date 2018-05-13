public with sharing class SlashclockFeedbackCommand
        implements Slashclock.Command {

    private String message;
    private Date messageDate;
    private Contact userContact;

    public SlashclockFeedbackCommand() {
        this.message = null;
        this.messageDate = null;
        this.userContact = null;
    }

    public Slashclock.CommandResult execute() {

        // Initialize the result
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        try {       

            // Clock feedback
            SlashclockService.getInstance(
                    this.userContact).feedback(
                            this.message, this.messageDate.addDays(3));

            // Set the success message
            result.setMessage(Label.SlashclockFeedbackSuccess);
            result.setSuccess(true);
        }
        catch (SlashclockException caught) {
            result.setMessage(caught.getMessage());
        }

        // Return the result
        return result;
    }

    public static String getCommandRegex() {
        return 'feedback\\s+(.+)';
    }

    public static Pattern getPattern() {
        return Pattern.compile(getCommandRegex());
    }

    public Slashclock.Command load(SlashCommand__c command) {

        // Find the contact to get the time zone
        SlackService slacker = SlackService.getInstance(command.SlackTeamId__c);
        this.userContact = slacker.findOrCreateContact(command.SlackUserId__c);

        // Store a matcher for the command
        Matcher matcher = getPattern().matcher(command.Text__c);

        // Load the specific time if it exists
        if (matcher.matches()) {
            this.message = matcher.group(1);
            this.messageDate = DatetimeUtil.getDate(
                    Datetime.now(), this.userContact.TimeZoneSidKey__c);
        }
        else {
            throw new SlashclockException(Label.SlashclockFeedbackNoMessage);
        }
        
        // Return the fully loaded SlashClock command!
        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        
        // Return whether we found a match
        return command.Text__c.startsWith('feedback');
    }
}