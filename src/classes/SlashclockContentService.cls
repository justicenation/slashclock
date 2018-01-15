/**
 * This service manages the user-facing content used to populate messages
 * sent in response to more verbose commands such as `/clock help`
 */
public with sharing class SlashclockContentService {

    /**
     * Assume this is a singleton service
     */
    public static SlashclockContentService instance =
            new SlashclockContentService();

    /**
     * @param contentName
     *            The enum corresponding to the expected content
     *
     * @return the expected content, formatted as Slack-flavored Markdown
     */
    public String getContent(SlashclockContentName contentName) {
        return null;
    }

    public static SlashclockContentService getInstance() {
        return instance;
    }
}