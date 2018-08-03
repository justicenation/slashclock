global class Slack {
    global class SlashCommandResponse {
        global String text { get; set; }

        global SlashCommandResponse(String text) {
            this.text = text;
        }
    }
}