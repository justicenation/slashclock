public with sharing class SlashclockCallbackController {

    public static final String CODE_PARAMETER = 'code';

    public static final String STATE_PARAMETER = 'state';

    public String message { get; set; }

    @testVisible
    private transient SlackService slack;

    public SlashclockCallbackController() {
        this(SlackService.getInstance());
    }

    public SlashclockCallbackController(SlackService slack) {
        this.slack = slack;
    }

    public PageReference load() {

        // Visualforce it up!
        PageService force = PageService.getInstance(ApexPages.currentPage());

        // Get the code and state
        String code = force.getParameter(CODE_PARAMETER);
        String state = force.getParameter(STATE_PARAMETER);


        // Assume the worst and try for the best
        PageReference nextPage = null;

        try {

            // Activate the team based on the given code
            SlackApi.TeamInfoResponse teamInfo = slack.activateTeam(code);

            // Prepare to redirect the user back to the Slack workspace
            nextPage = new PageReference(
                    SlackUtil.getWorkspaceUrl(teamInfo.team.domain));
        }
        catch (System.Exception caught) {
            List<String> messageParts = new List<String> {
                caught.getMessage(),
                caught.getStackTraceString()
            };

            this.message = String.join(messageParts, '\n');
        }

        // Use Slack to get the 
        return nextPage;
    }
}