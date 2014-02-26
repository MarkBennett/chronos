import 'package:angular/angular.dart';
import 'package:lawndart/lawndart.dart';

@MirrorsUsed(override: '*', targets: const ['chronos'])
import 'dart:mirrors';

import 'dart:async';
import 'dart:convert' show JSON, Latin1Decoder;

import 'package:chronos/chronos.dart';

@NgController(
    selector: "[timesheet]",
    publishAs: 'ctrl'
)
class TimesheetController {
  Timesheet timesheet = new Timesheet();
  String id = "";
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
    id = "";
    hours = 1;
    minutes = 0;

    description = "";
  }

  editEntry(Entry entry) {
    id = entry.id;
    hours = entry.duration.inHours;
    minutes = entry.duration.inMinutes - (entry.duration.inHours * 60);
    description = entry.description;
    client = entry.client;
  }

  addEntry() {
    Duration duration =
        new Duration(
            hours: hours,
            minutes: minutes);
    Entry entry = new Entry(id, duration, description, client);

    _loaded.then((_) {
      if (entry.id == "") {
        _addEntry(entry);
      } else {
        _saveEntry(entry);
      }

      clearNewEntry();
    });
  }

  _addEntry(Entry entry) {
    entry.id = new DateTime.now().millisecondsSinceEpoch.toString();
    timesheet.entries.add(entry);
    _entries_resource.add(entry);
  }

  _saveEntry(Entry entry) {
    timesheet.entries.where((e) => id == e.id).forEach((Entry e) {
      e.client = entry.client;
      e.description = entry.description;
      e.duration = entry.duration;
    });
    _entries_resource.save(entry);
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

abstract class Resource {
  Future add(dynamic entity);
  Future remove(dynamic entity);
  Future save(dynamic entity);
  Future getAll();
}

@NgInjectableService()
class EntriesResource implements Resource {
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

  Future save(Entry entry) {
    return _loaded.then((_) {
      return _db.save(JSON.encode(entry), entry.id);
    });
  }
}

class ChronosModule extends Module {
  ChronosModule() {
    type(TimesheetController);
    type(DurationFilter);
    type(EntriesResource);
  }
}

main() {
  ngBootstrap(module: new ChronosModule());
}