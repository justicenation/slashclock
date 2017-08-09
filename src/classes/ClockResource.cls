@RestResource(urlMapping='/clock')
global class ClockResource {

    @HttpPost
    global static Slack.CommandResponse post() {

        // Process the request
        SlackCommand__c command = new SlackCommand__c();
        //command.Body__c = RestContext.request.requestBody.toString();
        command.Body__c = JSON.serialize(RestContext.request);
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