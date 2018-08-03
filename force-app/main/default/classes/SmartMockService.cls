public with sharing class SmartMockService {

    private Type mockType;

	public SmartMockService(Type mockType) {
		this.mockType = mockType;
	}

    public String getResponseBody() {
        return [
            SELECT Id, Name, Body
            FROM StaticResource
            WHERE Name = :this.mockType.getName()
        ].Body.toString();
    }

    public static SmartMockService getInstance(Type mockType) {
        return new SmartMockService(mockType);
    }
}