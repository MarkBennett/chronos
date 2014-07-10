library chronos_router;

import 'package:angular/angular.dart';

void chronosRouteInitializer(Router router, RouteViewFactory views) {
  views.configure({
    'timesheet': ngRoute(
        path: '/timesheet',
        view: 'view/timesheet/index.html',
        defaultRoute: true)
  });
}