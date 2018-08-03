public with sharing class Slashclock {
    public interface Command {

        CommandResult execute();

        Command load(SlashCommand__c command);

        Boolean matches(SlashCommand__c command);
    }

    public class CommandResult {
        private String message;
        private Boolean success;

        public CommandResult() {
            this.message = null;
            this.success = false;
        }

        public String getMessage() {
            return this.message;
        }

        public Boolean isSuccess() {
            return this.success;
        }

        public void setMessage(String value) {
            this.message = value;
        }

        public void setSuccess(Boolean value) {
            this.success = value;
        }
    }
}