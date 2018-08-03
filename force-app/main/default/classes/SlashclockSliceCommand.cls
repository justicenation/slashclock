public with sharing class SlashclockSliceCommand implements Slashclock.Command {

    private Decimal numberOfMinutes;
    private String tag;
    private Contact userContact;

    public SlashclockSliceCommand() {
        this.numberOfMinutes = 0;
        this.tag = null;
        this.userContact = null;
    }

    public Slashclock.CommandResult execute() {

        // Initialize the result
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        // Clock in via service
        try {
            SlashclockService slashclock =
                    SlashclockService.getInstance(this.userContact);
            slashclock.slice(this.numberOfMinutes, this.tag);
            result.setMessage(Label.SlashclockSliceSuccess);
            result.setSuccess(true);
        }
        catch (SlashclockException caught) {
            result.setMessage(caught.getMessage());
        }
        catch (System.DmlException caught) {

            // TODO: Replace with more user-friendly error
            result.setMessage(caught.getMessage());
        }

        // Return the result
        return result;
    }

    /**
     * @return a regex that shows the general structure of the command
     *         to be three parts: slice, a time expression, a tag.
     */
    public static String getCommandRegex() {
        return 'slice\\s+(.+)\\s+([^\\s]+)';
    }

    public static Pattern getPattern() {
        return Pattern.compile(getCommandRegex());
    }

    public Slashclock.Command load(SlashCommand__c command) {

        // Find the contact for the Slack user
        SlackService slacker = SlackService.getInstance(command.SlackTeamId__c);
        this.userContact = slacker.findOrCreateContact(command.SlackUserId__c);

        // Store a matcher for the command
        Matcher matcher = getPattern().matcher(command.Text__c);

        // Load the specific time if it exists
        if (matcher.matches()) {
            this.numberOfMinutes = Time2.parse(matcher.group(1)).minutes();
            this.tag = matcher.group(2);
        }
        else {
            throw new SlashclockException(
                    'I could not understand the parameters');
        }
        
        // Return the fully loaded SlashClock command!
        return this;
    }

    public Boolean matches(SlashCommand__c command) {
        
        // Return whether we found a match
        return command.Text__c.startsWith('slice');
    }
}