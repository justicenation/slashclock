@isTest
public class SlashclockLosAngelesMockSuite extends SmartHttpCalloutMockSuite {

    public override List<Type> getMockTypes() {
        return new List<Type> {
            SlackApiUsersInfoSurferSilverMock.class
        };
    }
}