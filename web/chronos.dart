library chronos_web;

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';
import 'package:lawndart/lawndart.dart';

@MirrorsUsed(override: '*')
import 'dart:mirrors';

import 'dart:async';
import 'dart:convert' show JSON, Latin1Decoder;

import 'package:chronos/chronos.dart';

part 'package:chronos/components/timesheet/timesheet_component.dart';
part 'package:chronos/filters/duration_filter.dart';
part 'package:chronos/resources/timesheets_resource.dart';

class ChronosModule extends Module {
  ChronosModule() {
    bind(TimesheetResource);
    bind(TimesheetComponent);
    bind(DurationFilter);
  }
}

main() {
  applicationFactory().addModule(new ChronosModule()).run();
}
