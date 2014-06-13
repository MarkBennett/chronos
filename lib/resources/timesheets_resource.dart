library timesheets_resource;

import 'dart:async';

import 'package:angular/angular.dart';
import 'package:chronos/chronos.dart';
import 'package:chronos/resources/gdrive_adapter.dart';

abstract class Resource {
  Future add(dynamic entity);
  Future remove(dynamic entity);
  Future save();
  Future getAll();
}

@Injectable()
class TimesheetResource implements Resource {
  List<Timesheet> timesheets = [];
  Future _inited;
  GDriveAdapter adapter;

  TimesheetResource() {
    adapter = new GDriveAdapter();
    _inited = _initTimesheets();
  }

  Future _initTimesheets() {
    return adapter.init().then((_) {
      return adapter.get('timesheets');
    }).then((loaded) {
      timesheets = loaded;
    });
  }

  Future save() {
    return adapter.save('timesheets', timesheets);
  }

  Future add(Timesheet timesheet) {
    return _inited.then((_) {
      timesheets.add(timesheet);
    }).then((_) {
      save();
    });
  }

  Future remove(Timesheet timesheet) {
    return _inited.then((_) {
      timesheets.remove(timesheet);
    }).then((_) {
      save();
    });
  }

  Future getAll() => _inited.then((_) => new List.from(timesheets));

  Future<Timesheet> today() {
    return _inited.then((_) {
      DateTime todays_date = new DateTime.now();

      return where(starts_at: todays_date);
    }).then((matches) {
      Timesheet today;

      if (matches.isNotEmpty) {
        today = matches.first;
        return today;
      } else {
        today = new Timesheet("1", [], new DateTime.now());
        return add(today).then((_) => today);
      }
    });
  }

  Future<List<Timesheet>> where({DateTime starts_at}) {
    return _inited.then((_) {
      var matches = timesheets;

      if (starts_at != null) {
        matches = matches.where((Timesheet timesheet) =>
          timesheet.starts_at.year == starts_at.year &&
          timesheet.starts_at.month == starts_at.month &&
          timesheet.starts_at.day == starts_at.day);
      }

      return new Future.value(matches.toList());
    });
  }

  Future<Timesheet> prevDay(Timesheet timesheet) {
    DateTime previous_day = timesheet.starts_at.subtract(new Duration(days: 1));

    return where(starts_at: previous_day).then((matches) {
      if (matches.isNotEmpty) {
        return matches.first;
      } else {
        Timesheet timesheet =
            new Timesheet(new DateTime.now().millisecondsSinceEpoch.toString(),
                [], previous_day);
        timesheets.add(timesheet);
        return timesheet;
      }
    });
  }

  Future<Timesheet> nextDay(Timesheet timesheet) {
    DateTime next_day = timesheet.starts_at.add(new Duration(days: 1));

    return where(starts_at: next_day).then((matches) {
      if (matches.isNotEmpty) {
        return matches.first;
      } else {
        Timesheet timesheet =
            new Timesheet(new DateTime.now().millisecondsSinceEpoch.toString(),
                [], next_day);
        timesheets.add(timesheet);
        return timesheet;
      }
    });
  }
}