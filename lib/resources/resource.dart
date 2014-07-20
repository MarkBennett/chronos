library resource;

import 'dart:async';

part 'entity.dart';

abstract class Resource {
  // Create a new and unsaved entity
  Entity create();

  // Get all the entities associated with this resource
  @deprecated("when Resource implements stream")
  Future get all;

  // Callback invoked when an Entity belonging to this Resource is saved
  Future save(Entity entity);

  // Callback invoked when an Entity belonging to this Resource is destroyed
  Future _destroy(Entity entity);
}