global class Slack {
    global class CommandResponse {
        global String text { get; set; }

        global CommandResponse() {
            this(null);
        }

        global CommandResponse(String text) {
            this.text = text;
        }
    }

    global class CommandResult {
        global String message { get; set; }
        global Boolean success { get; set; }
    }
}