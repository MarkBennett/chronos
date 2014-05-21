library timesheet_component;

import 'dart:async';

import 'package:angular/angular.dart';

import 'package:chronos/chronos.dart';
import 'package:chronos/resources/timesheets_resource.dart';

@Component(
    selector: "timesheet",
    templateUrl: "packages/chronos/components/timesheet/timesheet_component.html",
    cssUrl: "packages/chronos/components/timesheet/timesheet_component.css",
    publishAs: 'ctrl')
class TimesheetComponent {

  Timesheet timesheet;
  String id = "";
  double hours = 1.0;
  double minutes = 0.0;
  String description = "";
  String client = "";
  TimesheetResource _timesheets_resource;
  Future _loaded;
  String formActionName = "Add";

  TimesheetComponent(TimesheetResource this._timesheets_resource) {
    clearNewEntry();
    _loadData();
  }

  _loadData() {
    _loaded = _timesheets_resource.today().then((today) => timesheet = today);
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
    _timesheets_resource.save();
  }

  _saveEntry(Entry entry) {
    timesheet.entries.where((e) => id == e.id).forEach((Entry e) {
      e.client = entry.client;
      e.description = entry.description;
      e.duration = entry.duration;
    });
    _timesheets_resource.save();
  }

  removeEntry(Entry entry) {
    _loaded.then((_) {
      timesheet.entries.remove(entry);
      _timesheets_resource.save();
    });
  }

  toPrevDay() {
    _timesheets_resource.prevDay(timesheet).
      then((prev_days_timesheet) => timesheet = prev_days_timesheet);
  }

  toNextDay() {
    _timesheets_resource.nextDay(timesheet).
      then((prev_days_timesheet) => timesheet = prev_days_timesheet);
  }

  onKeypress(event) {
    print("You're typing?");
  }
}