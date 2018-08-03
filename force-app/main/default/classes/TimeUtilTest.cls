@isTest
private class TimeUtilTest {

    @isTest
    private static void parseTime() {

        // Given
        Map<String, Map<String, Object>> expectedMap =
                new Map<String, Map<String, Object>> {
            '-1' => new Map<String, Object> {
                'matches' => false
            },
            '9:30am' => new Map<String, Object> {
                'matches' => true,
                'hour' => 9,
                'minute' => 30
            },
            '3:15pm' => new Map<String, Object> {
                'matches' => true,
                'hour' => 15,
                'minute' => 15
            },
            '11:00am' => new Map<String, Object> {
                'matches' => true,
                'hour' => 11,
                'minute' => 00
            },
            '12:48pm' => new Map<String, Object> {
                'matches' => true,
                'hour' => 12,
                'minute' => 48
            },
            '12:48am' => new Map<String, Object> {
                'matches' => true,
                'hour' => 0,
                'minute' => 48
            }
        };

        // When
        Test.startTest();

        Map<String, Map<String, Object>> actualMap =
                new Map<String, Map<String, Object>>();

        for (String eachValue : expectedMap.keySet()) {
            try {
                Time timeValue = TimeUtil.parseTime(eachValue);

                actualMap.put(eachValue, new Map<String, Object> {
                    'matches' => true,
                    'hour' => timeValue.hour(),
                    'minute' => timeValue.minute()
                });
            }
            catch (TypeException caught) {
                actualMap.put(eachValue, new Map<String, Object> {
                    'matches' => false
                });
            }
        }

        // Then
        Test.stopTest();

        for (String eachValue : expectedMap.keySet()) {

            // Make sure we got the correct result from `matches`
            Map<String, Object> expected = expectedMap.get(eachValue);
            Map<String, Object> actual = actualMap.get(eachValue);

            System.assertEquals(
                    expected.get('matches'), actual.get('matches'),
                    eachValue + ' => matches ');

            if (expected.get('matches') == true) {
                System.assertEquals(
                        expected.get('hour'), actual.get('hour'),
                        eachValue + ' => hour');
                System.assertEquals(
                        expected.get('minute'), actual.get('minute'),
                        eachValue + ' => minute');
            }
        }
    }
}