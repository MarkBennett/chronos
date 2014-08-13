library resource;

import 'dart:async';

part 'entity.dart';

abstract class Resource extends Stream {
  // Create a new and unsaved entity
  Entity create();

  // Callback invoked when an Entity belonging to this Resource is saved
  Future save(Entity entity);

  // Callback invoked when an Entity belonging to this Resource is destroyed
  Future destroy(Entity entity);

  @override
  StreamSubscription listen(void onData(event), {Function onError, void onDone(), bool cancelOnError});
}