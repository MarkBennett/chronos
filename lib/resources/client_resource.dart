library client_resource;

import 'dart:async';

import 'package:angular/angular.dart';
import 'package:chronos/resources/resource.dart';
import 'package:chronos/resources/gdrive_adapter.dart';

class Client extends Entity {
  String id;
  String name;

  Client(resource, this.id, this.name) : super(resource);
  Client.fromJson(json) : super(null) {
    this.id = json["id"];
    this.name = json["name"];
  }

  Map toJson() {
    return {
      id: id,
      name: name
    };
  }
}

@Injectable()
class ClientResource extends Resource {
  GDriveAdapter adapter;

  List<Client> clients = new List();

  Future _inited;

  ClientResource() {
    adapter = new GDriveAdapter();
    adapter.register("clients", this, (Map json) => new Client.fromJson(json));

    _inited = _init();

    clients = [
      new Client(this, "1", "Bob"),
      new Client(this, "2", "Jane")
    ];
  }

  Future _init() {
    return adapter.get("clients").then((clients) {
      // TODO: Actually start saving these
//      this.clients = clients;
    });
  }

  Future destroy(entity) {
    return _init().then((_) => clients.remove(entity));
  }

  // Save a Client. If they haven't been saved before, then do so now.
  Future save(Client client) {
    return _init().
        then((_) {
          if (client.id == null) {
            var id = _generateId();
            client.id = id;

            clients.add(client);
          }
        }).
        then((_) => adapter.save("clients", clients)).
        then((_) => clients);
  }

  String _generateId() => "client_" + new DateTime.now().millisecondsSinceEpoch.toString();

  // Create a new unsaved Client
  Client create() {
    return new Client(this, null, "");
  }

  // TODO: implement iterator
  @override
  Iterator get iterator => null;
}