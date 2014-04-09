part of chronos;

class Timesheet {
  String id;
  List<Entry> entries = [];
  DateTime starts_at = new DateTime.now();

  Timesheet.withDefaults();

  Timesheet(this.id, this.entries, this.starts_at);

  Timesheet.fromJson(Map json) {
    id = json['id'];
    entries = json['entries'].map((Map e) => new Entry.fromJson(e));
    starts_at = new DateTime.fromMillisecondsSinceEpoch(json['starts_at'], isUtc: true);
  }

  Map toJson() {
    return {
      'id': id,
      'entries': entries.map((Entry e) => e.toJson()),
      'starts_at': starts_at.toUtc().millisecondsSinceEpoch
    };
  }
}