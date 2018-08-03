@RestResource(urlMapping='/clock')
global class ClockResource {

    @HttpPost
    global static Slack.SlashCommandResponse post() {

        // Process the request
        SlashCommand__c slash = SlashCommandUtil.parse(RestContext.request);

        // Find the contact for the Slack user
        SlackService slacker = SlackService.getInstance(slash.SlackTeamId__c);
        Contact userContact = slacker.findOrCreateContact(slash.SlackUserId__c);

        SlashclockService slashclock = SlashclockService.getInstance(userContact);
        Slashclock.CommandResult result = slashclock.execute(slash);

        // Return the response
        RestContext.response.addHeader('Content-Type', 'application/json');
        return new Slack.SlashCommandResponse(result.getMessage());
    }
}