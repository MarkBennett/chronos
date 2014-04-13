part of chronos;

class Timesheet {

  String id;
  List<Entry> entries = [];
  DateTime starts_at = new DateTime.now();

  Timesheet.withDefaults();

  Timesheet(this.id, this.entries, this.starts_at);

  Timesheet.fromJson(Map json) {
    id = json['id'];
    entries = (json['entries'] as List).map((Map e) => new Entry.fromJson(e)).toList();
    starts_at = new DateTime.fromMillisecondsSinceEpoch(json['starts_at']);
  }

  Map toJson() {
    return {
      'id': id,
      'entries': entries.map((Entry e) => e.toJson()).toList(),
      'starts_at': starts_at.millisecondsSinceEpoch
    };
  }
}