part of timesheets_resource;

class Timesheet extends Entity {

  String id;
  List<Entry> entries = [];
  DateTime starts_at = new DateTime.now();

  Timesheet.withDefaults(Resource resource) : super(resource);

  Timesheet(Resource resource, this.id, this.entries, this.starts_at) : super(resource);

  Timesheet.fromJson(Map json) : super(null) {
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