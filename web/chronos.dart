import 'package:angular/angular.dart';
import 'package:lawndart/lawndart.dart';

@MirrorsUsed(override: '*', targets: const ['chronos'])
import 'dart:mirrors';

import 'dart:async';
import 'dart:convert' show JSON, Latin1Decoder;

import 'package:chronos/chronos.dart';

@NgController(selector: "[timesheet]", publishAs: 'ctrl')
class TimesheetController {

  List<Timesheet> timesheets;
  Timesheet timesheet;
  String id = "";
  double hours = 1.0;
  double minutes = 0.0;
  String description = "";
  String client = "";
  TimesheetResource _timesheets_resource;
  Future _loaded;
  String formActionName = "Add";

  TimesheetController(TimesheetResource this._timesheets_resource) {
    clearNewEntry();
    _loadData();
  }

  _loadData() {
    _loaded = _timesheets_resource.getAll().
        then((List<Timesheet> t) {
          timesheets = t;
          timesheet = timesheets.first;
        });
  }

  clearNewEntry() {
    id = "";
    hours = 1.0;
    minutes = 0.0;

    description = "";

    formActionName = "Add";
  }

  editEntry(Entry entry) {
    id = entry.id;
    hours = entry.duration.inHours.toDouble();
    minutes = entry.duration.inMinutes - (entry.duration.inHours * 60).toDouble(
        );
    description = entry.description;
    client = entry.client;

    formActionName = "Save";
  }

  addEntry() {
    Duration duration = new Duration(hours: hours.floor(), minutes:
        minutes.floor());
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
    _timesheets_resource.save(timesheet);
  }

  _saveEntry(Entry entry) {
    timesheet.entries.where((e) => id == e.id).forEach((Entry e) {
      e.client = entry.client;
      e.description = entry.description;
      e.duration = entry.duration;
    });
    _timesheets_resource.save(timesheet);
  }

  removeEntry(Entry entry) {
    _loaded.then((_) {
      timesheet.entries.remove(entry);
      _timesheets_resource.save(timesheet);
    });
  }
}

@NgFilter(name: 'duration')
class DurationFilter {
  call(Duration duration) {
    return
        "${duration.inHours}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, "0")}";
  }
}

abstract class Resource {
  Future add(dynamic entity);
  Future remove(dynamic entity);
  Future save(dynamic entity);
  Future getAll();
}

@NgInjectableService()
class TimesheetResource implements Resource {
  List<Timesheet> timesheets = [];

  Future _loaded;

  Store _db;

  TimesheetResource() {
    _db = new Store("chronos", "timesheets");

    _loaded = _db.open().then((_) {
      timesheets = [];
      return _db.all().forEach((json) => timesheets.add(new Timesheet.fromJson(
          JSON.decode(json))));
    });
  }

  Future add(Timesheet timesheet) {
    return _loaded.then((_) {
      timesheets.add(timesheet);

      return _db.save(JSON.encode(timesheet), timesheet.id);
    });
  }

  Future remove(Timesheet timesheet) {
    timesheets.remove(timesheet);

    return _db.removeByKey(timesheet.id);
  }

  Future getAll() => _loaded.then((_) => new List.from(timesheets));

  Future save(Timesheet timesheet) {
    return _loaded.then((_) {
      return _db.save(JSON.encode(timesheet), timesheet.id);
    });
  }
}

class ChronosModule extends Module {
  ChronosModule() {
    type(TimesheetController);
    type(DurationFilter);
    type(TimesheetResource);
  }
}

main() {
  ngBootstrap(module: new ChronosModule());
}
