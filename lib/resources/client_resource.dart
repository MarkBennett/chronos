library client_resource;

import 'dart:async';

import 'package:angular/angular.dart';
import 'package:chronos/resources/resource.dart';

class Client {
  String name;

  Client(this.name);
}

@Injectable()
class ClientResource extends Resource {

  List<Client> _clients = new List();

  ClientResource() {
    _clients = [
      new Client("Bob"),
      new Client("Jane")
    ];
  }

  @override
  Future add(entity) {
    _clients.add(entity);
    return new Future.value(entity);
  }

  @override
  Future getAll() {
    return new Future.value(_clients);
  }

  @override
  Future remove(entity) {
    _clients.remove(entity);
    return new Future.value(entity);
  }

  @override
  Future save() {
    return new Future.value(_clients);
  }
}