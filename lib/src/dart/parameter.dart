import 'identifier.dart';
import 'dart_type.dart';

class Parameter {
  DartType typeDef = typeDynamic;
  Identifier id;
  bool _isOptional = false;

  bool _isNamed = false;

  Parameter.id(this.id);
  Parameter(String parmName) : id = Identifier(parmName);

  bool get isOptional => _isOptional;
  set isOptional(bool value) {
    if (value && _isNamed) {
      throw ArgumentError(
          'The parameter cannot be at the same time "optional" and "named"');
    }
    _isOptional = value;
  }

  bool get isNamed => _isNamed;
  set isNamed(bool value) {
    if (value && _isOptional) {
      throw ArgumentError(
          'The parameter cannot be at the same time "optional" and "named"');
    }
    _isNamed = value;
  }

  @override
  bool operator ==(other) =>
      other is Parameter && id == other.id && typeDef == other.typeDef;

  @override
  int get hashCode => '${typeDef.type}#${id.id}'.hashCode;

  String generate() => '${typeDef.type} ${id.id}';
}
