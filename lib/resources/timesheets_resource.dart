library timesheets_resource;

import 'dart:async';
import 'dart:convert' show JSON, Utf8Codec;
import 'dart:html' show window, HttpRequest;

import 'package:angular/angular.dart';
import "package:google_drive_v2_api/drive_v2_api_browser.dart" as drivelib;
import "package:google_drive_v2_api/drive_v2_api_client.dart" as client;
import 'package:google_oauth2_client/google_oauth2_browser.dart';

import 'package:chronos/chronos.dart';

abstract class Resource {
  Future add(dynamic entity);
  Future remove(dynamic entity);
  Future save();
  Future getAll();
}

@Injectable()
class TimesheetResource implements Resource {
  List<Timesheet> timesheets = [];

  Future _loaded;

  GoogleOAuth2 _auth;
  drivelib.Drive _drive;
  String _data_file_id;

  String JSON_MIME_TYPE = "application/json";

  TimesheetResource() {
    _loaded = _loadTimesheetsFromDrive();
  }

  drivelib.Drive _createAuthorizedDriveClient() {
    drivelib.Drive drive;

    _auth =
        new GoogleOAuth2("616311253486.apps.googleusercontent.com",
            ["https://www.googleapis.com/auth/drive"]);
    drive = new drivelib.Drive(_auth);
    drive.makeAuthRequests = true;

    return drive;
  }

  Future _loadTimesheetsFromDrive() {
    _drive = _createAuthorizedDriveClient();

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

  Future<client.FileList> _searchForDataFileCandidates() => _drive.files.list(q: "title = 'data_file.json'");

  Future<String> _intializeDataFile() {
    client.File data_file = new client.File.fromJson({ 'title': 'data_file.json', 'mimeType': JSON_MIME_TYPE });
    String timesheet_json = JSON.encode({'timesheets': timesheets });
    print(timesheet_json);
    var base64data = window.btoa(timesheet_json);
    print(base64data);
    return _drive.files.insert(data_file, content: base64data, contentType: JSON_MIME_TYPE).
        then((client.File file) {
          _data_file_id = file.id;
        }).catchError((e) {
          print("Something went wrong! $e");
        });
  }

  Future<String> _parseDataFile(String data_file_id) {
    return _drive.files.get(data_file_id).then((client.File data_file) {
      
      HttpRequest request = new HttpRequest();
      request.open("GET", data_file.downloadUrl);
      
      return _auth.authenticate(request).then((request) {
        Completer completer = new Completer();
        
        request.send();
        
        request.onLoad.listen((event) {
          Map data_file = JSON.decode(request.responseText) as Map;
          timesheets = data_file["timesheets"];
          
          completer.complete(data_file_id);
        });
        
        return completer.future;
      });
    });
  }

  Future add(Timesheet timesheet) {
    return _loaded.then((_) {
      timesheets.add(timesheet);
    });
  }

  Future remove(Timesheet timesheet) {
    timesheets.remove(timesheet);

    return save();
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

      return new Future.value(matches.toList());
    });
  }

  Future save() {
    // TODO: Make this save to Drive
    return new Future.value("TODO");
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