part of resource;

abstract class Entity {
  Resource resource;

  Entity(Resource this.resource);
  Future save() => resource.save(this);
  Future destroy() => resource._destroy(this);
}