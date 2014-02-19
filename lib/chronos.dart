library chronos;

class Timesheet {
  List<Entry> entries = [];
  DateTime starts_at = new DateTime.now();
}

class Entry {
  Duration duration;
  String description;
  String client;

  Entry(this.duration, this.description, this.client);
}