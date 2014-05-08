library chronos_web;

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

@MirrorsUsed(override: '*')
import 'dart:mirrors';

import 'package:chronos/components/timesheet/timesheet_component.dart';
import 'package:chronos/filters/duration_filter.dart';
import 'package:chronos/resources/timesheets_resource.dart';

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
