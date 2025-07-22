part of 'local_store.dart';

class _StoreObject<T> {
  _StoreObject({
    required this.key,
    this.value,
    T? initialValue,
  }) {
    if (call() == null && initialValue != null) {
      call(initialValue);
    }
  }

  final String key;
  T? value;

  T? call([T? v]) {
    if (v != null) {
      _Store.write(key, v);
      value = v;
    }

    return value ??= _Store.read<T?>(key);
  }

  void erase() {
    _Store.remove(key);
    value = null;
  }

  @override
  String toString() => value.toString();
}
