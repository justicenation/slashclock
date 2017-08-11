public with sharing class SlashclockReport {

    private List<Item> items;

    public SlashclockReport() {
        this.items = new List<Item>();
    }

    public void addItem(DateTime startTime, DateTime duration) {
        this.items.add(new Item(startTime, duration));
    }

    public List<Item> getItems() {
        return this.items;
    }

    public Item getSummaryItem() {
        DateTime zero = DateTime.newInstance(0);
        DateTIme total = DateTime.newInstance(0);

        for (Item eachItem : this.items) {
            total = total.addHours(eachItem.getDuration().hour());
            total = total.addMinutes(eachItem.getDuration().minute());
        }

        return new Item('SUM', DateTimeUtil.getDuration(zero, total));
    }

    public class Item {

        private DateTime duration;
        private String label;
        private DateTime startTime;

        public Item(DateTime startTime, DateTime duration) {
            this.label = null;
            this.startTime = startTime;
            this.duration = duration;
        }

        public Item(String label, DateTime duration) {
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
                    (this.duration.day() * 24) + duration.hour()
                            + (duration.minute() / 60.0);

            return granularDuration + 'h';
        }

        public String formatStartTime() {
            return this.startTime.format('EEE');
        }

        public DateTIme getDuration() {
            return this.duration;
        }

        public String getLabel() {
            return this.startTime == null ? this.label : this.formatStartTime();
        }
    }
}