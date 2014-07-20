library gdrive_adapter;

import 'dart:async';
import 'dart:convert' show JSON, Utf8Codec;
import 'dart:html' show window, HttpRequest;

import 'package:chronos/resources/resource.dart';
import "package:google_drive_v2_api/drive_v2_api_browser.dart" as drivelib;
import "package:google_drive_v2_api/drive_v2_api_client.dart" as client;
import 'package:google_oauth2_client/google_oauth2_browser.dart';

typedef Entity FromJson(Map json);

class RegisteredResource {
  String name;
  Resource resource;
  FromJson fromJson;

  RegisteredResource(this.name, this.resource, this.fromJson);
}

class GDriveAdapter {
  final String JSON_MIME_TYPE = "application/json";
  final String APP_ID = "616311253486.apps.googleusercontent.com";
  final List<String> APP_SCOPES = ["https://www.googleapis.com/auth/drive"];

  GoogleOAuth2 _auth;
  drivelib.Drive _drive;
  String _data_file_id;
  Map _data;
  Map _resources = new Map();

  Future _inited;

  Future save(String key, value) {
    return _init().then((_) {
      _data[key] = value;

      return _saveDataFile();
    });
  }

  Future get(String key) {
    return _init().then((_) => _data[key]);
  }

  Future _init() {
    if (_inited == null) {
      _inited = _loadValuesFromDrive();
    }

    return _inited;
  }

  drivelib.Drive _createAuthorizedDriveClient() {
    drivelib.Drive drive;

    _auth =
        new GoogleOAuth2(APP_ID, APP_SCOPES);
    drive = new drivelib.Drive(_auth);
    drive.makeAuthRequests = true;

    return drive;
  }

  Future _loadValuesFromDrive() {
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

  String _encodeValuesForDrive() {
    Map app_json = _data;
    String values_json = JSON.encode(app_json);
    return window.btoa(values_json);
  }

  client.File get _generateDriveDataFile {
    client.File data_file =
        new client.File.fromJson({
          'title': 'data_file.json',
          'mimeType': JSON_MIME_TYPE });
    return data_file;
  }

  Future<String> _intializeDataFile() {
    client.File data_file = _generateDriveDataFile;
    String content = _encodeValuesForDrive();
    return _drive.files.insert(data_file, content: content, contentType: JSON_MIME_TYPE).
        then((client.File file) {
          _data_file_id = file.id;
        }).catchError((e) {
          print("Something went wrong! $e");
        });
  }

  Future _saveDataFile() {
    client.File data_file = _generateDriveDataFile;
    String content = _encodeValuesForDrive();

    return _drive.files.update(data_file, _data_file_id, content: content);
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
          _data = new Map();
          data_file.forEach((key, Iterable value) {
            _data[key] = value.map((value) {
              RegisteredResource resource = _resources[key];
              Entity entity = resource.fromJson(value);
              entity.resource = resource.resource;

              return entity;
            }).toList();
          });

          completer.complete(data_file_id);
        });

        return completer.future;
      });
    });
  }

  Future<client.FileList> _searchForDataFileCandidates() =>
      _drive.files.list(q: "title = 'data_file.json'");

  void register(String name, Resource resource, FromJson from_json) {
    _resources[name] = new RegisteredResource(name, resource, from_json);
  }
}