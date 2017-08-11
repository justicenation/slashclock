public with sharing class SlashclockReport {

    private List<Item> items;

    public SlashclockReport() {
        this.items = new List<Item>();
    }

    public void addItem(DateTime startTime, Time2 duration) {
        this.items.add(new Item(startTime, duration));
    }

    public List<Item> getItems() {
        return this.items;
    }

    public Item getSummaryItem() {
        Time2 total = Time2.newInstance();

        for (Item eachItem : this.items) {
            total = total.add(eachItem.getDuration());
        }

        return new Item('SUM', total);
    }

    public class Item {

        private Time2 duration;
        private String label;
        private DateTime startTime;

        public Item(DateTime startTime, Time2 duration) {
            this.label = null;
            this.startTime = startTime;
            this.duration = duration;
        }

        public Item(String label, Time2 duration) {
            this.label = label;
            this.startTime = null;
            this.duration = duration;
        }

        /**
         * @return the total duration represnted in the report item, in
         *         number of hours, accounting for minutes but not seconds
         *         or milliseconds
         */
        public String formatDuration() {
            return this.duration.inHours() + 'h';
        }

        public String formatStartTime() {
            return this.startTime.format('EEE');
        }

        public Time2 getDuration() {
            return this.duration;
        }

        public String getLabel() {
            return this.startTime == null ? this.label : this.formatStartTime();
        }
    }
}