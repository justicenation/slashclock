public with sharing class SlashclockUtil {
    public static List<Slashclock.Command> getKnownCommands() {
        return new List<Slashclock.Command> {
            new SlashclockInCommand(),
            new SlashclockOutCommand(),
            new SlashclockReportCommand()
        };
    }

    public static Slashclock.Command newCommand(SlashCommand__c command) {

        // Placeholder for the command to return
        Slashclock.Command matchedCommand = null;

        // Go through all known commands to look for a match
        List<Slashclock.Command> knownCommands = getKnownCommands();

        while (matchedCommand == null && knownCommands.size() > 0) {
            Slashclock.Command knownCommand = knownCommands.remove(0);
            if (knownCommand.matches(command)) {
                matchedCommand = knownCommand.load(command);
            }
        }

        // Return the matched command
        return matchedCommand;
    }

    /**
     * @param startTime the start of the first day
     * @param endTime the reference time to use in case an open time entry
     *                needs to be closed out
     * @param timeZoneSidKey
     * @param entries the list of time entries to convert into report items.
     *                the entries in this list are all assumed to fall within
     *                the `startTime`-`endTime` range, and the entries are
     *                also expected to include related slices.
     * @param numberOfDays
     *            The number of days to include in the list
     *
     * @return the list of report items representing the 
     */
    public static List<SlashclockReportItem> newDailyReportItems(
            DateTime startTime, DateTime endTime, String timeZoneSidKey,
            List<TimeEntry__c> entries, Integer numberOfDays) {

        // Initialize the list
        List<SlashclockReportItem> items = new List<SlashclockReportItem>();

        // Figure out the start times for every day in the report range
        List<DateTime> dailyStartTimes = new List<DateTime> { startTime };

        while (dailyStartTimes.size() < numberOfDays) {
            dailyStartTimes.add(
                    dailyStartTimes.get(
                            dailyStartTimes.size() - 1).addDays(1));
        }

        // Go through all of the days we're tracking and figure out
        // which time entries to incorporate into the day's hours
        for (DateTime eachStartTime : dailyStartTimes) {

            // Initialize a report item for the start time
            SlashclockReportItem item = SlashclockReportItem.newInstance(
                    eachStartTime, timeZoneSidKey, Time2.newInstance());

            // Incorporate every qualifying time entry into the report item
            for (TimeEntry__c eachEntry
                    : qualify(entries, startTime, startTime.addDays(1))) {

                // Add the time entry's duration
                DateTime effectiveEndTime = eachEntry.EndTime__c == null
                        ? endTime : eachEntry.EndTime__c;

                item.addDuration(
                        effectiveEndTime.getTime()
                                - eachEntry.StartTime__c.getTime());

                // Add all of the time entry's slices
                for (TimeSlice__c eachSlice : eachEntry.TimeSlices__r) {
                    item.addSlice(SlashclockReportSlice.newInstance(eachSlice));
                }
            }

            // Add the report item
            items.add(item);
        }

        // Return the final list
        return items;
    }

    public static SlashclockService.Key newServiceKey(SlashCommand__c command) {
        return new SlashclockService.Key(command.SlackUserId__c, command.SlackTeamId__c);
    }

    public static List<TimeEntry__c> qualify(
            List<TimeEntry__c> entries, DateTime startTime, DateTime endTime) {

        // Initialize the list of qualified time entries
        List<TimeEntry__c> qualified = new List<TimeEntry__c>();

        // Check the given entries
        for (TimeEntry__c eachEntry : entries) {
            if (eachEntry.StartTime__c >= startTime
                    && eachEntry.StartTime__c < endTime) {
                qualified.add(eachEntry);
            }
        }

        // Return the list of qualified time entries
        return qualified;
    }
}