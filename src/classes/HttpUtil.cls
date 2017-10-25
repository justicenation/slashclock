global class HttpUtil {

    /**
     * Given a map of name-value pairs, serialize the map into a string
     * that works as a URL query string. This method assumes that the values
     * are already correctly URL-encoded, since the values are being passed
     * in as strings.
     *
     * @param parameterMap
     *
     * @return URL query string representing the parameter map
     */
    global static String serializeQuery(Map<String, String> parameterMap) {

        // First serialize name-value pairs into a list
        List<String> pairs = new List<String>();

        for (String eachKey : parameterMap.keySet()) {
            pairs.add(eachKey + '=' + parameterMap.get(eachKey));
        }

        // Join the name-value pairs into a string
        return String.join(pairs, '&');
    }
}