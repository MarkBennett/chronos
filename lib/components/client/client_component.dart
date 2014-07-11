library client_component;

import 'package:angular/angular.dart';

import 'package:chronos/resources/client_resource.dart';

@Component(
    selector: 'client',
    templateUrl: 'packages/chronos/components/client/client_component.html',
    cssUrl: 'packages/chronos/components/client/client_component.css',
    publishAs: 'ctrl')
class ClientComponent {
  ClientResource _resource;

  List<Client> clients;

  ClientComponent(ClientResource this._resource) {
    _resource.getAll().then((clients) => this.clients = clients);
  }
}