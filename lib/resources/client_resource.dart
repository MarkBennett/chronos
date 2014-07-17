library client_resource;

import 'dart:async';

import 'package:angular/angular.dart';
import 'package:chronos/resources/resource.dart';
import 'package:chronos/resources/gdrive_adapter.dart';

class Client {
  String id;
  String name;

  Client(this.id, this.name);
  Client.fromJson(json) {
    this.id = json["id"];
    this.name = json["name"];
  }
}

@Injectable()
class ClientResource extends Resource {
  GDriveAdapter adapter;

  List<Client> clients = new List();

  Future _inited;

  ClientResource() {
    adapter = new GDriveAdapter();
    adapter.register("clients", (Map json) => new Client.fromJson(json));

    _inited = _initClients();

    clients = [
      new Client("1", "Bob"),
      new Client("2", "Jane")
    ];
  }

  Future _initClients() {
    return adapter.get("clients").then((clients) {
      this.clients = clients;
    });
  }

  @override
  Future add(entity) {
    clients.add(entity);
    return new Future.value(entity);
  }

  @override
  Future getAll() {
    return new Future.value(clients);
  }

  @override
  Future remove(entity) {
    clients.remove(entity);
    return new Future.value(entity);
  }

  @override
  Future save() {
    return new Future.value(clients);
  }
}