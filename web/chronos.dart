import 'package:angular/angular.dart';
import 'package:lawndart/lawndart.dart';

@MirrorsUsed(override: '*')
import 'dart:mirrors';

import 'dart:async';
import 'dart:convert' show JSON;

import '../lib/chronos.dart';

@NgController(
    selector: "[timesheet]",
    publishAs: 'ctrl'
)
class TimesheetController {
  Timesheet timesheet = new Timesheet();
  int hours = 1;
  int minutes = 0;
  String description = "";
  String client = "";
  EntriesResource _entries_resource;
  Future _loaded;

  TimesheetController(EntriesResource this._entries_resource) {
    clearNewEntry();
    _loadData();
  }

  _loadData() {
    _loaded =
        _entries_resource.getAll().
          then((List<Entry> entries) => timesheet.entries = entries);
  }

  clearNewEntry() {
    hours = 1;
    minutes = 0;

    description = "";
  }

  addEntry() {
    Duration duration =
        new Duration(
            hours: hours,
            minutes: minutes);
    Entry entry = new Entry(duration, description, client);

    _loaded.then((_) {
      timesheet.entries.add(entry);
      _entries_resource.add(entry);

      clearNewEntry();
    });
  }

  removeEntry(Entry entry) {
    _loaded.then((_) {
      timesheet.entries.remove(entry);
      _entries_resource.remove(entry);
    });
  }
}

@NgFilter(name: 'duration')
class DurationFilter {
  call(Duration duration) {
    return "${duration.inHours}:${duration.inMinutes - (duration.inHours * 60)}";
  }
}

class EntriesResource {
  List<Entry> entries = [];

  Future _loaded;

  Store _db;

  EntriesResource() {
    _db = new Store("chronos", "entries");

    _loaded = _db.open().then((_) {
      entries = [];
      return _db.all().forEach((json) => entries.add(new Entry.fromJson(JSON.decode(json))));
    });
  }

  Future add(Entry entry) {
    return _loaded.then((_) {
      entries.add(entry);

      print("Adding entry");

      return _db.save(JSON.encode(entry), entry.id);
    });
  }

  Future remove(Entry entry) {
    entries.remove(entry);

    print("Removing entry");

    return _db.removeByKey(entry.id);
  }

  Future getAll() => _loaded.then((_) => new List.from(entries));
}

class ChronosModule extends Module {
  ChronosModule() {
    type(TimesheetController);
    type(DurationFilter);
    type(EntriesResource);
  }
}

main() => ngBootstrap(module: new ChronosModule());