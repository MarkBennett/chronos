library duration_filter;

import 'package:angular/angular.dart';

@Formatter(name: 'duration')
class DurationFilter {
  call(Duration duration) {
    return
        "${duration.inHours}:${(duration.inMinutes - (duration.inHours * 60)).toString().padLeft(2, "0")}";
  }
}