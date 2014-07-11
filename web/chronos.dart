library chronos_web;

import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

@MirrorsUsed(override: '*')
import 'dart:mirrors';

import 'package:chronos/components/client/client_component.dart';
import 'package:chronos/components/timesheet/timesheet_component.dart';
import 'package:chronos/filters/duration_filter.dart';
import 'package:chronos/resources/timesheets_resource.dart';
import 'package:chronos/routing/chronos_router.dart';

class ChronosModule extends Module {
  ChronosModule() {
    bind(TimesheetResource);
    bind(TimesheetComponent);
    bind(ClientComponent);
    bind(DurationFilter);
    bind(RouteInitializerFn, toValue: chronosRouteInitializer);
  }
}

main() {
  applicationFactory().addModule(new ChronosModule()).run();
}
