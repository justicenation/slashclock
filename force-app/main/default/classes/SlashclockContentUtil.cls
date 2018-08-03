public with sharing class SlashclockContentUtil {
    public static SlashclockContentName getHelpContentName(String key) {
        Map<String, SlashclockContentName> valueMap =
                new Map<String, SlashclockContentName> {
            'entries' => SlashclockContentName.HELP_ENTRIES_COMMAND,
            'feedback' => SlashclockContentName.HELP_FEEDBACK_COMMAND,
            'in' => SlashclockContentName.HELP_IN_OUT_COMMAND,
            'out' => SlashclockContentName.HELP_IN_OUT_COMMAND,
            'report' => SlashclockContentName.HELP_REPORT_COMMAND,
            'slice' => SlashclockContentName.HELP_SLICE_COMMAND,
            'strike' => SlashclockContentName.HELP_STRIKE_COMMAND,
            null => SlashclockContentName.HELP_COMMAND
        };

        return valueMap.get(key);
    }

    public static String place(List<String> params, String template) {

        // Initialize the return value
        String result = template;

        for (Integer i = 0; i < params.size(); i++) {
            result = result.replaceAll('\\{' + i + '\\}', params[i]);
        }

        // Return the result
        return result;
    }
}