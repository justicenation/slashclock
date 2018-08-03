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
                        SlackService.class, new TestService.SlackServiceStubProvider());

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
                        SlackService.class, new TestService.SlackServiceEvilStubProvider());

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
}