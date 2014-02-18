import 'package:angular/angular.dart';

@MirrorsUsed(override: '*')
import 'dart:mirrors';

import '../lib/chronos.dart';

@NgController(
    selector: "[timesheet]",
    publishAs: 'ctrl'
)
class TimesheetController {
  Timesheet timesheet = new Timesheet();
  String hours = "1";
  String description = "";
  String client = "";

  TimesheetController() {
    clearNewEntry();
  }

  clearNewEntry() {
    hours = "1";
    description = "";
  }

  addEntry() {
    timesheet.entries.add(
        new Entry(new Duration(hours: int.parse(hours, radix: 10)), description, client));
    clearNewEntry();
  }
}

@NgFilter(name: 'duration')
class DurationFilter {
  call(Duration duration) {
    return "${duration.inHours}:${duration.inMinutes - (duration.inHours * 60)}";
  }
}

class ChronosModule extends Module {
  ChronosModule() {
    type(TimesheetController);
    type(DurationFilter);
  }
}

main() => ngBootstrap(module: new ChronosModule());