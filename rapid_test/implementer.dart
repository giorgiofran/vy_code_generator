abstract class Implementer<T> {
  const Implementer(this._value);

  final T _value;
  T call() => _value;

  @override
  bool operator ==(other) => other is Implementer && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
