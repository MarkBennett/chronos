library chronos_web;

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:lawndart/lawndart.dart';

@MirrorsUsed(override: '*')
import 'dart:mirrors';

import 'dart:async';
import 'dart:convert' show JSON, Latin1Decoder;

import 'package:chronos/chronos.dart';

part 'controllers/timesheet_controller.dart';
part 'filters/duration_filter.dart';
part 'resources/timesheets_resource.dart';

class ChronosModule extends Module {
  ChronosModule() {
    type(TimesheetResource);
    type(TimesheetController);
    type(DurationFilter);
  }
}

main() {
  applicationFactory().addModule(new ChronosModule()).run();
}
