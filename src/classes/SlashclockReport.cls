public with sharing class SlashclockReport {

    private List<Item> items;

    public SlashclockReport() {
        this.items = new List<Item>();
    }

    public List<Item> getItems() {
        return this.items;
    }

    public Item getSummaryItem() {
        return new Item();
    }

    public class Item {

    }
}