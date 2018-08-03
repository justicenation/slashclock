public with sharing class SlashCommandUtil {
    public static final String COMMAND_PARAM = 'command';
    public static final String TEAM_ID_PARAM = 'team_id';
    public static final String TEXT_PARAM = 'text';
    public static final String USER_ID_PARAM = 'user_id';
    
    public static SlashCommand__c parse(RestRequest req) {
        SlashCommand__c command = new SlashCommand__c();
        command.Request__c = JSON.serialize(req);
        command.Command__c = req.params.get(COMMAND_PARAM);
        command.Text__c = req.params.get(TEXT_PARAM);
        command.SlackUserId__c = req.params.get(USER_ID_PARAM);
        command.SlackTeamId__c = req.params.get(TEAM_ID_PARAM);
        return command;
    }
}