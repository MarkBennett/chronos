library resource;

import 'dart:async';

abstract class Resource {
  Future add(dynamic entity);
  Future remove(dynamic entity);
  Future save();
  Future getAll();
}