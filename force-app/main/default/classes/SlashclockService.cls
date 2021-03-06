public with sharing class SlashclockService {

    public static final String ALREADY_CLOCKED_IN_ERROR =
            'Uh, you already clocked in earlier...';

    public static final String CLOCKED_IN_SUCCESS =
            'You have clocked in.';

    public static final String CLOCKED_OUT_SUCCESS =
            'You have clocked out.';

    public static final String NOT_CLOCKED_IN_ERROR =
            'You must clock in first!';

    private Weekday firstDayOfWeek;

    /**
     * Cache of instances for fast retrieval, keyed on Contact ID
     */
    private static Map<Id, SlashclockService> instanceMap =
            new Map<Id, SlashclockService>();

    private Account teamAccount;
    
    private Contact userContact;

    public SlashclockService(Contact userContact) {
        this(userContact, userContact.Account);
    }

    public SlashclockService(Contact userContact, Account teamAccount) {
        this.userContact = userContact;
        this.teamAccount = teamAccount;
        
        // TODO: Make dynamic based on Slack user preference
        this.firstDayOfWeek = Weekday.MONDAY;
    }

    /**
     * @param startTime
     *            The time at which the user clocked in
     *
     * @return newly created, open time entry
     */
    public TimeEntry__c clockIn(DateTime startTime) {

        // Look for existing open entries
        if (this.getOpenTimeEntries().size() > 0) {
            throw new SlashclockException(ALREADY_CLOCKED_IN_ERROR);
        }

        // Construct the time entry
        TimeEntry__c entry = new TimeEntry__c(
                Contact__c = this.userContact.Id,
                StartTime__c = startTime,
                StartTimeZoneSidKey__c = this.getTimeZoneSidKey(),
                SlackUserId__c = this.userContact.SlackUserId__c,
                SlackTeamId__c = this.teamAccount.SlackTeamId__c);

        // Insert and return the time entry
        insert entry;
        return entry;
    }

    /**
     * @param endTime
     *            The time at which the user clocked out
     *
     * @return updated time entry
     */
    public TimeEntry__c clockOut(DateTime endTime) {

        // Look for existing open entries
        List<TimeEntry__c> openTimeEntries = this.getOpenTimeEntries();
        if (openTimeEntries.isEmpty()) {
            throw new SlashclockException(NOT_CLOCKED_IN_ERROR);
        }

        // Update and return the open time entry.
        // TODO: Handle edge case where multiple open entries exist.
        TimeEntry__c entry =
                openTimeEntries.get(openTimeEntries.size() - 1);
        entry.EndTime__c = endTime;
        entry.EndTimeZoneSidKey__c = this.userContact.TimeZoneSidKey__c;

        update entry;
        return entry;
    }

    /**
     * Execute an inbound slash command, and return the command result.
     * In case the command fails for an unknown reason, meaning that
     * an unhandled exception was encountered, the inbound command
     * should be logged so that a notification can be generated to
     * the product owner.
     *
     * @param inbound The inbound slash command
     *
     * @return the result of processing the slash command, with a user-friendly
     *         message to be sent back to the Slack client
     */
    public Slashclock.CommandResult execute(SlashCommand__c inbound) {

        // Construct the command
        Slashclock.CommandResult result = new Slashclock.CommandResult();

        // Execute the command and catch any unexpected exceptions
        try {
            Slashclock.Command command = SlashclockUtil.newCommand(inbound);
            result = command.execute();
        }
        catch(System.Exception caught) {

            // Log the command for further investigation
            inbound.ErrorMessage__c = caught.getMessage();
            inbound.ErrorStackTraceString__c = caught.getStackTraceString();
            inbound.ErrorTypeName__c = caught.getTypeName();

            insert inbound;

            // Set the result
            result.setSuccess(false);

            SlashclockContentService content =
                    SlashclockContentService.getInstance();
            
            result.setMessage(content.getContent(
                    SlashclockContentName.UNKNOWN_ERROR,
                    new List<String> { SlackUtil.format(inbound) }));
        }

        return result;
    }

    /**
     * Given a piece of feedback, create a task with the comments in the 
     * body of the task, assigned to the account owner for review. The
     * task should be associated with the contact who submitted the feedback.
     *
     * @param message The content of the feedback
     *
     * @param reviewByDate
     *            The date by which the feedback should be reviewed
     *
     * @return the Task ID of the created task
     */
    public String feedback(String message, Date reviewByDate) {

        // Construct the task
        Task newTask = new Task(
                OwnerId = this.teamAccount.OwnerId,
                WhoId = this.userContact.Id,
                Subject = Label.SlashclockFeedbackTaskSubject,
                Description = message,
                ActivityDate = reviewByDate);

        // Create the task
        insert newTask;
        return newTask.Id;
    }

    /**
     * Given a list of time entries, format the time entries for display as
     * a successful response to a `/clock entries` command
     *
     * @param entries
     *
     * @return a string that can be displayed prettily in Slack
     */
    public String formatEntries(List<TimeEntry__c> entries) {

        // Initialize the lines in the response
        List<String> lines = new List<String>();

        // If no entries are given, the command should return a notification
        // that there are no entries to display.
        if (entries.isEmpty()) {
            lines.add(Label.SlashclockEntriesNoEntries);
        }
        else {
            lines.add(Label.SlashclockEntriesOpening);

            for (TimeEntry__c eachEntry : entries) {
                lines.add(this.formatEntry(eachEntry, lines.size()));
            }
        }

        // Return the lines 
        return String.join(lines, '\n');
    }

    /**
     * Given a time entry and its index position within a list of time entries,
     * format a string to return that can be displayed in a list appropriate
     * for use with the `/clock entries` command.
     *
     * The line can be broken down into four parts.
     *
     * - The index number
     * - The start date (in the user's local time zone)
     * - The start time (in the user's local time zone)
     * - The end date (in the user's local time zone) which may not be shown
     * - The end time (in the user's local time zone)
     *
     * @param entry
     *
     * @return a formatted string showing the entry's info and its index
     */
    public String formatEntry(TimeEntry__c entry, Integer index) {
        
        // Always start with the standard entry details
        String value = SlashclockUtil.formatEntry(
                entry, index, this.getTimeZoneSidKey());

        // Add slice information if slices are present
        if (entry.TimeSlices__r.size() > 0) {
            SlashclockSliceList slices =
                    new SlashclockSliceList(entry.TimeSlices__r);
            
            value += ' ' + slices.format();
        }

        return value;
    }

    public Time2 getClockedDuration(DateTime startTime, DateTime endTime) {
        Time2 duration = Time2.newInstance();

        for (TimeEntry__c eachEntry : this.getTimeEntries(startTime, endTime)) {

            // Use the range start time if the entry's start time is earlier
            if (eachEntry.StartTime__c < startTime) {
                eachEntry.StartTime__c = startTime;
            }

            // Use the range end time if no end time specified
            if (eachEntry.EndTime__c == null) {
                eachEntry.EndTime__c = DateTime.now();
            }

            // Use the range end time if the effective end time is later
            if (eachEntry.EndTime__c > endTime) {
                eachEntry.EndTime__c = endTime;
            }

            // Add the duration
            duration = duration.add(
                    eachEntry.EndTime__c.getTime()
                            - eachEntry.StartTime__c.getTime());
        }

        return duration;
    }

    /**
     * @return all open time entries for the user in context
     */
    public List<TimeEntry__c> getOpenTimeEntries() {
        return [
            SELECT Id, StartTime__c
            FROM TimeEntry__c
            WHERE
                EndTime__c = NULL AND
                Contact__c = :this.userContact.Id
        ];
    }

    public List<TimeEntry__c> getTimeEntriesSince(DateTime startTime) {
        return [
            SELECT
                (SELECT Id, NumberOfMinutes__c, Tag__c FROM TimeSlices__r),
                EndTime__c,
                StartTime__c,
                Id
            FROM TimeEntry__c
            WHERE
                StartTime__c >= :startTime AND
                Contact__c = :this.userContact.Id
            ORDER BY StartTime__c DESC
        ];
    }

    public static SlashclockService getInstance(Contact userContact) {

        // Cache a new instance as needed
        if (!instanceMap.containsKey(userContact.Id)) {
            instanceMap.put(userContact.Id, new SlashclockService(userContact));
        }

        return instanceMap.get(userContact.Id);
    }

    public TimeEntry__c getLastTimeEntry() {
        return [
            SELECT Id
            FROM TimeEntry__c
            WHERE
                Contact__c = :this.userContact.Id
            ORDER BY StartTime__c DESC
            LIMIT 1
        ];
    }

    public String getTimeZoneSidKey() {
        return this.userContact.TimeZoneSidKey__c;
    }

    public DateTime getStartOfWeek(DateTime value) {
        return DateTimeUtil.startOfWeek(
                value, this.getTimeZoneSidKey(), this.firstDayOfWeek);
    }

    public List<TimeEntry__c> getTimeEntries(DateTime startTime, DateTime endTime) {
        return [
            SELECT Id, StartTime__c, EndTime__c,
                (SELECT Id, NumberOfMinutes__c, Tag__c FROM TimeSlices__r)
            FROM TimeEntry__c
            WHERE
                StartTime__c < :endTime AND
                (EndTime__c >= :startTime OR EndTime__c = NULL) AND
                Contact__c = :this.userContact.Id
            ORDER BY StartTime__c ASC
        ];
    }

    public SlashclockReport report(DateTime endTime) {

        // Figure out the start of the week for the given end time
        DateTime startOfWeek = this.getStartOfWeek(endTime);

        // Initialize the report
        SlashclockReport report = new SlashclockReport();

        // Go through every day for which we need to aggregate data
        for (SlashclockReportItem eachItem
                : SlashclockUtil.newDailyReportItems(
                        startOfWeek, endTime, this.getTimeZoneSidKey(),
                        this.getTimeEntries(startOfWeek, endTime), 7)) {
            report.addItem(eachItem);
        }

        // Return the compiled report
        return report;
    }

    public TimeSlice__c slice(Decimal numberOfMinutes, String tag) {
        TimeSlice__c slice = new TimeSlice__c(
                TimeEntry__c = this.getLastTimeEntry().Id,
                NumberOfMinutes__c = numberOfMinutes,
                Tag__c = tag);

        insert slice;
        return slice;
    }
}