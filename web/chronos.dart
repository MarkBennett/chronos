import 'package:angular/angular.dart';

@MirrorsUsed(override: '*')
import 'dart:mirrors';

import 'dart:async';

import '../lib/chronos.dart';

@NgController(
    selector: "[timesheet]",
    publishAs: 'ctrl'
)
class TimesheetController {
  Timesheet timesheet = new Timesheet();
  String hours = "1";
  String minutes = "0";
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
    hours = "1";
    minutes = "0";

    description = "";
  }

  addEntry() {
    Duration duration =
        new Duration(
            hours: int.parse(hours, radix: 10),
            minutes: int.parse(minutes, radix: 10));
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
  List<Entry> entries = [
    new Entry(new Duration(hours: 1, minutes: 30), "prototyping UI", "chronos"),
    new Entry(new Duration(hours: 1), "adding behaviour", "chronos")
  ];

  Future add(Entry entry) {
    entries.add(entry);

    print("Adding entry");

    return new Future.value(entry);
  }

  Future remove(Entry entry) {
    entries.remove(entry);

    print("Removing entry");

    return new Future.value(entry);
  }

  Future getAll() => new Future.value(new List.from(entries));
}

class ChronosModule extends Module {
  ChronosModule() {
    type(TimesheetController);
    type(DurationFilter);
    type(EntriesResource);
  }
}

main() => ngBootstrap(module: new ChronosModule());