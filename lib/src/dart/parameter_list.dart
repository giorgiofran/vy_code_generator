import 'parameter.dart';

class ParameterList {
  final List<Parameter> _parms = <Parameter>[];
  final List<Parameter> _optionalParms = <Parameter>[];
  final List<Parameter> _namedParms = <Parameter>[];

  bool get containsPositional => _parms.isNotEmpty;
  bool get containsOptional => _optionalParms.isNotEmpty;
  bool get containsNamed => _namedParms.isNotEmpty;

  bool get isNotEmpty =>
      containsPositional || containsOptional || containsNamed;
  bool get isEmpty => !isNotEmpty;

  int get length => _parms.length + _optionalParms.length + _namedParms.length;

  List<Parameter> get positionalParms => _parms;
  List<Parameter> get optionalParms => _optionalParms;
  List<Parameter> get namedParms => _namedParms;

  int get positionalParametersLength => _parms.length;
  int get optionalParametersLength => _optionalParms.length;
  int get namedParametersLength => _namedParms.length;

  void addParm(Parameter parm) {
    if (parm.isNamed) {
      if (containsOptional) {
        throw StateError('It is not possible to insert a named parameter '
            'if there are already optional ones.');
      }
      _namedParms.add(parm);
    } else if (parm.isOptional) {
      if (containsNamed) {
        throw StateError('It is not possible to insert an optional parameter '
            'if there are already named ones.');
      }
      _optionalParms.add(parm);
    } else {
      _parms.add(parm);
    }
  }

  String get listDefinition {
    var buffer = StringBuffer();
    buffer.write([for (var parm in _parms) parm.generate()].join(', '));
    if (containsOptional) {
      if (buffer.isNotEmpty) {
        buffer.write(', ');
      }
      buffer.write('[');
      buffer
          .write([for (var parm in _optionalParms) parm.generate()].join(', '));
      buffer.write(']');
    }

    if (containsNamed) {
      if (buffer.isNotEmpty) {
        buffer.write(', ');
      }
      buffer.write('{');
      buffer.write([for (var parm in _namedParms) parm.generate()].join(', '));
      buffer.write('}');
    }

    return buffer.toString();
  }

  String get listCall {
    var buffer = StringBuffer();
    buffer.write([for (var parm in _parms) parm.id.id].join(', '));
    if (containsOptional) {
      if (buffer.isEmpty) {
        buffer.write(', ');
        buffer.write([for (var parm in _optionalParms) parm.id.id].join(', '));
      }
    }
    if (containsNamed) {
      if (buffer.isEmpty) {
        buffer.write(', ');
        buffer.write([
          for (var parm in _namedParms) '${parm.id.id}: ${parm.id.id}'
        ].join(', '));
      }
    }

    return buffer.toString();
  }
}
