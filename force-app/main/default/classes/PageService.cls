public with sharing class PageService {

    private static Map<PageReference, PageService> instanceMap =
            new Map<PageReference, PageService>();

    private PageReference page;

    public PageService(PageReference page) {
        this.page = page;
    }

    public static PageService getInstance(PageReference page) {
        if (!instanceMap.containsKey(page)) {
            instanceMap.put(page, newInstance(page));
        }

        return instanceMap.get(page);
    }

    public String getParameter(String name) {
        return this.page.getParameters().get(name);
    }

    public static PageService newInstance(PageReference page) {
        PageService instance = new PageService(page);
        return instance;
    }
}