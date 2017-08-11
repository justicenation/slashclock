@RestResource(urlMapping='/clock')
global class ClockResource {

    @HttpPost
    global static Slack.CommandResponse post() {

        // Process the request
        SlashCommand__c command = new SlashCommand__c();
        command.Request__c = JSON.serialize(RestContext.request);
        command.Command__c = RestContext.request.params.get('command');
        command.Text__c = RestContext.request.params.get('text');
        command.SlackUserId__c = RestContext.request.params.get('user_id');
        command.SlackTeamId__c = RestContext.request.params.get('team_id');
        insert command;

        // Return the response
        RestContext.response.addHeader('Content-Type', 'application/json');
        Slack.CommandResponse response = new Slack.CommandResponse(
                'ID: ' + command.Id);
        return response;
    }
}