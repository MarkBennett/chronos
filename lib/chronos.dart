library chronos;

class Timesheet {
  List<Entry> entries = [];
  DateTime starts_at = new DateTime.now();
}

class Entry {
  String id;
  Duration duration;
  String description;
  String client;

  Entry(this.duration, this.description, this.client) {
    id = new DateTime.now().millisecondsSinceEpoch.toString();
  }

  Entry.fromJson(Map json) {
    id = json['id'];
    duration = new Duration(seconds: json['duration']);
    description = json['description'];
    client = json['client'];
  }

  Map toJson() {
    return {
      'id': id,
      'duration': duration.inSeconds,
      'description': description,
      'client': client
    };
  }
}