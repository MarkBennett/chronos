library chronos;

class Timesheet {
  List<Entry> entries = [];

  Timesheet() {
    entries = [
      new Entry(new Duration(hours: 1, minutes: 30), "prototyping UI", "chronos"),
      new Entry(new Duration(hours: 1), "adding behaviour", "chronos")
    ];
  }
}

class Entry {
  Duration duration;
  String description;
  String client;

  Entry(this.duration, this.description, this.client);
}