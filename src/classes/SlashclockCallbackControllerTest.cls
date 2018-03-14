@isTest
private class SlashclockCallbackControllerTest {

    @isTest
    private static void newInstance() {

        // When
        Test.startTest();

        SlashclockCallbackController controller =
                new SlashclockCallbackController();

        // Then
        Test.stopTest();

        System.assertNotEquals(null, controller.slack);
    }

    @isTest
    private static void loadSuccess() {

        // Given
        PageReference testPage = Page.SlashclockCallback;

        testPage.getParameters().put(
                SlashclockCallbackController.CODE_PARAMETER, 'acme');

        testPage.getParameters().put(
                SlashclockCallbackController.STATE_PARAMETER, 'happy-state');

        // Stub the `SlackService` instance
        SlackService slackStub =
                (SlackService)Test.createStub(
                        SlackService.class, new SlackServiceStubProvider());

        // When
        Test.setCurrentPage(testPage);
        Test.startTest();

        SlashclockCallbackController controller =
                new SlashclockCallbackController(slackStub);
        
        PageReference nextPage = controller.load();

        // Then
        Test.stopTest();
        
        System.assertEquals(null, controller.message);

        System.assertNotEquals(null, nextPage);
    }

    @isTest
    private static void loadError() {

        // Given
        PageReference testPage = Page.SlashclockCallback;

        testPage.getParameters().put(
                SlashclockCallbackController.CODE_PARAMETER, 'acme');

        testPage.getParameters().put(
                SlashclockCallbackController.STATE_PARAMETER, 'sad-state');

        // Stub the `SlackService` instance
        SlackService slackStub =
                (SlackService)Test.createStub(
                        SlackService.class, new SlackServiceEvilStubProvider());

        // When
        Test.setCurrentPage(testPage);
        Test.startTest();

        SlashclockCallbackController controller =
                new SlashclockCallbackController(slackStub);
        
        PageReference nextPage = controller.load();

        // Then
        Test.stopTest();
        
        System.assertNotEquals(null, controller.message);

        System.assertEquals(null, nextPage);
    }

    private class SlackServiceStubProvider implements System.StubProvider {

        private SlackApi.TeamInfoResponse activateTeam(String code) {

            // Initialize the response
            SlackApi.TeamInfoResponse teamInfo =
                    new SlackApi.TeamInfoResponse();

            teamInfo.team = new SlackApi.Team();
            teamInfo.team.domain = code;

            // Return the response
            return teamInfo;
        }

        public Object handleMethodCall(
                Object stubbedObject,
                String stubbedMethodName,
                Type returnType,
                List<Type> listOfParamTypes,
                List<String> listOfParamNames,
                List<Object> listOfArgs) {
            
            // Initialize the return value
            Object returnValue = null;

            if ('activateTeam'.equals(stubbedMethodName)) {
                returnValue = this.activateTeam((String)listOfArgs[0]);
            }

            // Return a value
            return returnValue;            
        }
    }

    private class SlackServiceEvilStubProvider implements StubProvider {

        public Object handleMethodCall(
                Object stubbedObject,
                String stubbedMethodName,
                Type returnType,
                List<Type> listOfParamTypes,
                List<String> listOfParamNames,
                List<Object> listOfArgs) {
            
            // Initialize the return value
            Object returnValue = null;

            if ('activateTeam'.equals(stubbedMethodName)) {
                throw new TestException('ho ho ho');
            }

            // Return a value
            return returnValue;            
        }
    }

    private class TestException extends Exception {
        /* nothing special */
    }
}