global class Slack {
    global class SlashCommandResponse {
        global String text { get; set; }

        global SlashCommandResponse() {
            this(null);
        }

        global SlashCommandResponse(String text) {
            this.text = text;
        }
    }
}