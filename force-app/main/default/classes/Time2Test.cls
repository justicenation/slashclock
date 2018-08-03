@isTest
private class Time2Test {

    @isTest
    private static void getMatcher() {

        // Define expected outcomes
        Map<String, List<String>> expectedValueMap = new Map<String, List<String>> {
            '1 second' => new List<String> { null, null, '1 second' },
            '10 seconds' => new List<String> { null, null, '10 seconds' },
            '1 minute' => new List<String> { null, '1 minute', null },
            '17 minutes' => new List<String> { null, '17 minutes', null },
            '20 minutes 30 seconds' => new List<String> { null, '20 minutes', '30 seconds' },
            '1 hour' => new List<String> { '1 hour', null, null },
            '2.5 hours' => new List<String> { '2.5 hours', null, null },
            '3 hours 30 minutes' => new List<String> { '3 hours', '30 minutes', null },
            '3 hours 5 seconds' => new List<String> { '3 hours', null, '5 seconds' },
            '3 hours 15 minutes 30 seconds' => new List<String> { '3 hours', '15 minutes', '30 seconds' }
        };

        // When
        Test.startTest();

        Map<String, Matcher> actualValueMap = new Map<String, Matcher>();

        for (String eachValue : expectedValueMap.keySet()) {
            actualValueMap.put(eachValue, Time2.getMatcher(eachValue));
        }

        // Then
        Test.stopTest();

        for (String eachValue : expectedValueMap.keySet()) {
            List<String> expected = expectedValueMap.get(eachValue);
            Matcher actual = actualValueMap.get(eachValue);

            System.assert(actual.matches(), 'matcher: ' + eachValue);

            for (Integer i = 0; i < expected.size(); i++) {
                System.assertEquals(
                        expected.get(i),
                        actual.group(i + 1),
                        eachValue);
            }
        }
    }

    @isTest
    private static void parse() {

        // Define expected outcomes
        Map<String, Time2> expectedValueMap = new Map<String, Time2> {
            '1 second' => Time2.newInstance(0, 0, 0, 1, 0),
            '10 seconds' => Time2.newInstance(0, 0, 0, 10, 0),
            '1 minute' => Time2.newInstance(0, 0, 1, 0, 0),
            '17 minutes' => Time2.newInstance(0, 0, 17, 0, 0),
            '20 minutes 30 seconds' => Time2.newInstance(0, 0, 20, 30, 0),
            '1 hour' => Time2.newInstance(0, 1, 0, 0, 0),
            '2.5 hours' => Time2.newInstance(0, 2, 30, 0, 0),
            '3 hours 30 minutes' => Time2.newInstance(0, 3, 30, 0, 0),
            '3 hours 5 seconds' => Time2.newInstance(0, 3, 0, 5, 0),
            '3 hours 15 minutes 30 seconds' => Time2.newInstance(0, 3, 15, 30, 0)
        };

        // When
        Test.startTest();

        Map<String, Time2> actualValueMap = new Map<String, Time2>();

        for (String eachValue : expectedValueMap.keySet()) {
            actualValueMap.put(eachValue, Time2.parse(eachValue));
        }

        // Then
        Test.stopTest();

        for (String eachValue : expectedValueMap.keySet()) {
            System.assertEquals(
                    expectedValueMap.get(eachValue).getTime(),
                    actualValueMap.get(eachValue).getTime(),
                    eachValue);
        }
    }
}