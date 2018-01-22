@RestResource(urlMapping='/clock')
global class ClockResource {

    @HttpPost
    global static Slack.SlashCommandResponse post() {

        // Process the request
        SlashCommand__c slash = SlashCommandUtil.parse(RestContext.request);
        SlashclockService slashclock = SlashclockService.getInstance(slash);
        Slashclock.CommandResult result = slashclock.execute(slash);

        // Return the response
        RestContext.response.addHeader('Content-Type', 'application/json');
        return new Slack.SlashCommandResponse(result.getMessage());
    }
}