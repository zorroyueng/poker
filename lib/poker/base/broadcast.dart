import 'dart:async';

class Broadcast<T> {
  final StreamController<T> _ctrl = StreamController.broadcast();
  late T _value;

  Broadcast(this._value) {
    _ctrl.add(_value);
  }

  Stream<T> stream() => _ctrl.stream;

  Stream<T> distinct() => stream().distinct();

  void add(T t) {
    _value = t;
    _ctrl.add(t);
  }

  T value() => _value;
}
