public with sharing class SlashclockReport {

    private List<Item> items;

    public SlashclockReport() {
        this.items = new List<Item>();
    }

    public void addItem(DateTime startTime, Time duration) {
        this.items.add(new Item(startTime, duration));
    }

    public List<Item> getItems() {
        return this.items;
    }

    public Item getSummaryItem() {
        Time duration = Time.newInstance(0, 0, 0, 0);

        for (Item eachItem : this.items) {
            duration.addHours(eachItem.getDuration().hour());
            duration.addMinutes(eachItem.getDuration().minute());
        }

        return new Item('SUM', duration);
    }

    public class Item {

        private Time duration;
        private String label;
        private DateTime startTime;

        public Item(DateTime startTime, Time duration) {
            this.label = null;
            this.startTime = startTime;
            this.duration = duration;
        }

        public Item(String label, Time duration) {
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
            Decimal granularDuration =
                    duration.hour() + (duration.minute() / 60.0);

            return granularDuration + 'h';
        }

        public String formatStartTime() {
            return this.startTime.format('EEE');
        }

        public Time getDuration() {
            return this.duration;
        }

        public String getLabel() {
            return this.startTime == null ? this.label : this.formatStartTime();
        }
    }
}