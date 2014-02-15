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
}

class ChronosModule extends Module {
  ChronosModule() {
    type(TimesheetController);
  }
}

main() => ngBootstrap(module: new ChronosModule());