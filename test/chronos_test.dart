import 'package:chronos/resources/resource.dart';
import 'package:unittest/unittest.dart';
import 'dart:async';

class ConcreteEntity extends Entity {
  String name;
  ConcreteEntity(Resource resource, this.name) : super(resource);
}

class ConcreteResource extends Resource {
  List<ConcreteEntity> entities;

  ConcreteResource() {
    entities =
        [create()..name = "Bob", create()..name = "Sarah"];
  }

  @override
  ConcreteEntity create() {
    return new ConcreteEntity(this, "no name");
  }

  @override
  Future save(Entity entity) {
    entities.add(entity);

    return new Future.value(entity);
  }

  @override
  Future destroy(Entity entity) {
    entities.remove(entity);

    return new Future.value(entity);
  }

  @override
  StreamSubscription listen(void onData(event), {Function onError, void onDone(), bool cancelOnError}) {
    return new Stream.fromIterable(entities).
        listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

main() {
  test('Resource', () {
    ConcreteResource resource = new ConcreteResource();

    ConcreteEntity entity = resource.create();
    entity..name = "Mike";

    return resource.toSet().
      then((resources) => resources..add(entity)).
      then((expected) {
          return entity.save().
            then((_) => resource.toSet()).
            then((resources) {
              expect(resources, equals(expected));
            });
      });
  });
}