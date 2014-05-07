part of chronos_web;

abstract class Resource {
  Future add(dynamic entity);
  Future remove(dynamic entity);
  Future save(dynamic entity);
  Future getAll();
}

@Injectable()
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

  Future<Timesheet> today() {
    return _loaded.then((_) {
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
    return _loaded.then((_) {
      var matches = timesheets;

      if (starts_at != null) {
        matches = matches.where((Timesheet timesheet) =>
          timesheet.starts_at.year == starts_at.year &&
          timesheet.starts_at.month == starts_at.month &&
          timesheet.starts_at.day == starts_at.day);
      }

      return matches.toList();
    });
  }

  Future save(Timesheet timesheet) {
    return _loaded.then((_) {
      return _db.save(JSON.encode(timesheet), timesheet.id);
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