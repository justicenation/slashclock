global class Slack {
    global class CommandResponse {
        global String text { get; set; }

        global CommandResponse(String text) {
            this.text = text;
        }
    }
}