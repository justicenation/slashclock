global class HttpUtil {

    global static final String CONTENT_TYPE_HEADER = 'ContentType';

    global static final String GET_METHOD = 'GET';

    global static final String POST_METHOD = 'POST';

    global static final String X_WWW_FORM_URLENCODED_CONTENT_TYPE =
            'application/x-www-form-urlencoded';

    global static Map<String, String> deserializeQuery(String queryString) {

        // Initialize the parameter map
        Map<String, String> parameters = new Map<String, String>();

        // Break out the query string
        for (String eachPair : queryString.split('&')) {
            List<String> parts = eachPair.split('=');
            parameters.put(parts[0], parts[1]);
        }

        // Return the map
        return parameters;
    }

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