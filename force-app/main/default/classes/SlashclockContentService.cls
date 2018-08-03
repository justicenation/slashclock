/**
 * This service manages the user-facing content used to populate messages
 * sent in response to more verbose commands such as `/clock help`
 */
public with sharing class SlashclockContentService {
    
    public static final String folderName = 'slashClock Content';

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
        return [
            SELECT Id, Body
            FROM Document
            WHERE
                FolderId = :this.getContentFolderId() AND
                Name = :contentName.name()
        ].Body.toString();
    }

    public String getContent(
            SlashclockContentName contentName, List<String> params) {
        return SlashclockContentUtil.place(params, this.getcontent(contentName));
    }

    public Id getContentFolderId() {
        return [
            SELECT Id
            FROM Folder
            WHERE Name = :folderName
        ].Id;
    }

    public static SlashclockContentService getInstance() {
        return instance;
    }
}