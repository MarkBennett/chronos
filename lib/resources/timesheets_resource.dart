library timesheets_resource;

import 'dart:async';

import 'package:angular/angular.dart';
import 'package:chronos/chronos.dart';
import 'package:chronos/resources/gdrive_adapter.dart';
import 'package:chronos/resources/resource.dart';

part 'timesheet.dart';

@Injectable()
class TimesheetResource extends Resource {
  List<Timesheet> timesheets = [];
  Future _inited;
  GDriveAdapter adapter;

  TimesheetResource() {
    adapter = new GDriveAdapter();
    adapter.register("timesheets", this, (Map json) => new Timesheet.fromJson(json));
    _inited = _init();
  }

  Future _init() {
    return adapter.get('timesheets').then((timesheets) {
      this.timesheets = timesheets;
    });
  }

  Future save(Timesheet timesheet) {
    return _init().
        then((_) {
          if (timesheet.id == null) {
              timesheet.id = _generateId();
              timesheets.add(timesheet);
            }
          return timesheet;
        }).
        then((_) => _saveAll());
  }

  Future _saveAll() {
    return adapter.save('timesheets', timesheets);
  }

  Future destroy(Timesheet timesheet) {
    return _inited.then((_) {
      timesheets.remove(timesheet);
    }).then((_) {
      _saveAll();
    });
  }

  Future get all => _inited.then((_) => new List.from(timesheets));

  Future<Timesheet> today() {
    return _inited.then((_) {
      DateTime todays_date = new DateTime.now();

      return starts_at(todays_date);
    }).then((matches) {
      Timesheet today;

      if (matches.isNotEmpty) {
        today = matches.first;
      } else {
        today = create()..save();
      }

      return today;
    });
  }

  Future<Iterable<Timesheet>> starts_at(DateTime date) {
    return _inited.then((_) {
      var matches = timesheets;

      if (date != null) {
        matches = matches.where((Timesheet timesheet) =>
          timesheet.starts_at.year == date.year &&
          timesheet.starts_at.month == date.month &&
          timesheet.starts_at.day == date.day);
      }

      return matches;
    });
  }

  Future<Timesheet> prevDay(Timesheet timesheet) {
    DateTime previous_day = timesheet.starts_at.subtract(new Duration(days: 1));

    return starts_at(previous_day).then((matches) {
      if (matches.isNotEmpty) {
        return matches.first;
      } else {
        Timesheet timesheet =
            new Timesheet(this, _generateId(),
                [], previous_day);
        timesheets.add(timesheet);
        return timesheet;
      }
    });
  }

  String _generateId() => new DateTime.now().millisecondsSinceEpoch.toString();

  Future<Timesheet> nextDay(Timesheet timesheet) {
    DateTime next_day = timesheet.starts_at.add(new Duration(days: 1));

    return starts_at(next_day).then((matches) {
      if (matches.isNotEmpty) {
        return matches.first;
      } else {
        Timesheet timesheet =
            new Timesheet(this, _generateId(),
                [], next_day);
        timesheets.add(timesheet);
        return timesheet;
      }
    });
  }

  @override
  Entity create() {
    return new Timesheet(this, null, [], new DateTime.now());
  }

  @override
  StreamSubscription listen(void onData(event), {Function onError, void onDone(), bool cancelOnError}) {
    return new Stream.fromIterable(timesheets).
        listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}