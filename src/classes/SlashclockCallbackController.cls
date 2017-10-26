public with sharing class SlashclockCallbackController {

    public static final String CODE_PARAMETER = 'code';

    public static final String STATE_PARAMETER = 'state';

    public String message { get; set; }

    public PageReference load() {

        // Visualforce it up!
        PageService force = PageService.getInstance(ApexPages.currentPage());

        // Get the code and state
        String code = force.getParameter(CODE_PARAMETER);
        String state = force.getParameter(STATE_PARAMETER);


        // Assume the worst and try for the best
        PageReference nextPage = null;

        try {

            // Get the access token
            SlackApiService slack = SlackApiService.getInstance();
            SlackApi.OauthAccessResponse oauthAccess =
                    slack.oauthAccess(Connection__c.getInstance('Slack'), code);
            String accessToken = oauthAccess.access_token;

            // Determine the appropriate next page for the team
            SlackApiService teamSlack = SlackApiService.getInstance(accessToken);
            SlackApi.TeamInfoResponse teamInfo = teamSlack.teamInfo();

            // Store the access token
            SlackService slacker = SlackService.getInstance(oauthAccess.team_id);
            slacker.storeAccessToken(accessToken);

            // Prepare to redirect the user back to the Slack workspace
            nextPage = new PageReference(
                    SlackUtil.getWorkspaceUrl(teamInfo.team.domain));
        }
        catch (System.Exception caught) {
            this.message = JSON.serialize(caught);
        }

        // Use Slack to get the 
        return nextPage;
    }
}