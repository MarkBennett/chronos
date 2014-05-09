library timesheets_resource;

import 'dart:async';
import 'dart:convert' show JSON, Latin1Decoder;

import 'package:angular/angular.dart';
import "package:google_drive_v2_api/drive_v2_api_browser.dart" as driveclient;
import "package:google_drive_v2_api/drive_v2_api_client.dart";
import 'package:google_oauth2_client/google_oauth2_browser.dart';
import 'package:lawndart/lawndart.dart';

import 'package:chronos/chronos.dart';

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
  
  driveclient.Drive _drive;
  String _data_file_id;
  
  TimesheetResource() {
    
    _db = new Store("chronos", "timesheets");

    _loaded = _loadTimesheetsFromDrive();
  }
  
  driveclient.Drive _createAuthorizedDriveClient() {
    driveclient.Drive drive;
    
    GoogleOAuth2 auth =
        new GoogleOAuth2("616311253486.apps.googleusercontent.com",
            ["https://www.googleapis.com/auth/drive.appdata"]);
    drive = new driveclient.Drive(auth);
    drive.makeAuthRequests = true;
    
    return drive;
  }
  
  Future _loadTimesheetsFromDrive() {
    _drive = _createAuthorizedDriveClient();
    
    // Load and parse the chronos files
    return _loadDataFile();
  }

  Future _loadDataFile() {
    return _searchForDataFileCandidates().then((data_files) {
      if (data_files.items.isEmpty) {
        return _intializeDataFile();
      } else {
        return _parseDataFile(data_files.items.first.id);
      }
    }).then((data_file_id) {
      _data_file_id = data_file_id;
    });
  }

  Future<FileList> _searchForDataFileCandidates() => _drive.files.list(q: "title = 'data_file.json' and 'appdata' in parents");
  
  Future<String> _parseDataFile(String data_file_id) {
    return new Future.value("1");
  }
  
  Future<String> _intializeDataFile() {
    return new Future.value("1");
  }

  Future add(Timesheet timesheet) {
    return _loaded.then((_) {
      timesheets.add(timesheet);

//      return _db.save(JSON.encode(timesheet), timesheet.id);
    });
  }

  Future remove(Timesheet timesheet) {
    timesheets.remove(timesheet);

//    return _db.removeByKey(timesheet.id);
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