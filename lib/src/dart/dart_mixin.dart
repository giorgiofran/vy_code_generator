import 'package:vy_string_utils/vy_string_utils.dart';

import 'abstract/annotated.dart';
import 'abstract/named_element.dart';
import 'dart_class.dart';
import 'variable.dart';
import 'identifier.dart';
import 'utils/keywords.dart';
import 'library.dart';
import 'method.dart';
import 'dart_type.dart';
import 'utils/string_buffer_extension.dart';

class DartMixin extends NamedElement with DartType, Annotated {
  final List<NamedElement> _onList = <NamedElement>[];
  final List<DartClass> _implementList = <DartClass>[];

  final List<Variable> _fields = <Variable>[];
  final List<Method> _methods = <Method>[];

  DartMixin.id(Identifier id) : super(id) {
    type = id.id;
  }
  DartMixin(String className) : super(Identifier(className)) {
    type = id?.id;
  }
  DartMixin.fromTextualContent(String text) : super.fromTextualContent(text);

  List<DartClass> get implementingClasses => _implementList;

  void addToOnList(NamedElement namedElement) {
    if (namedElement.id == null) {
      throw ArgumentError('Cannot add mixin with no id');
    }
    try {
      _onList.firstWhere((element) => namedElement.id!.id == element.id?.id);
    } on StateError {
      // If not found
      _onList.add(namedElement);
      return;
    }
    throw StateError('The element "${namedElement.id!.id}" is already present '
        'in mixin "${id?.id == null ? '' : id!.id}"');
  }

  void addImplements(DartClass implementClass) {
    if (implementClass.id == null) {
      throw ArgumentError('Cannot add implements element with no id');
    }
    try {
      _implementList
          .firstWhere((element) => implementClass.id!.id == element.id?.id);
    } on StateError {
      // If not found
      _implementList.add(implementClass);
      return;
    }
    throw StateError('The class "${implementClass.id!.id}" is already present '
        'in class "${id?.id == null ? '' : id!.id}"');
  }

  void addFieldSeparator() => addField(Variable.fromTextualContent('\n'));

  void addField(Variable field) {
    if (field.id == null) {
      throw ArgumentError('Cannot add field with no id');
    }
    try {
      _fields.firstWhere((element) =>
          filled(element.id?.id) &&
          filled(field.id?.id) &&
          element.id!.id == field.id!.id);
    } on StateError {
      // If not found
      field.parent = this;
      if (library != null) {
        field.library = library;
      }
      _fields.add(field);
      return;
    }
    throw StateError('The field "${field.id!.id}" is already present '
        'in class "${id?.id == null ? '' : id!.id}"');
  }

  void addMethod(Method method) {
    if (method.id == null) {
      throw ArgumentError('Cannot add method with no id');
    }
    try {
      _methods.firstWhere((element) =>
          filled(element.id?.id) &&
          filled(method.id?.id) &&
          element.id!.id == method.id!.id &&
          method.isSetter == element.isSetter &&
          element.isGetter == element.isGetter);
    } on StateError {
      method.parent = this;
      if (library != null) {
        method.library = library;
      }
      _methods.add(method);
      return;
    }
    throw StateError('The '
        '${method.isGetter ? 'getter' : method.isSetter ? 'setter' : 'method'} '
        '"${method.id!.id}" is already present in class '
        '"${id?.id == null ? '' : id!.id}"');
  }

  @override
  void libraryUpdated(Library? library) {
    super.libraryUpdated(library);
    for (var field in _fields) {
      field.library = library;
    }
    for (var method in _methods) {
      method.library = library;
    }
    for (var namedElement in _onList) {
      namedElement.library = library;
    }
  }

  @override
  String generate() {
    if (id?.id == null) {
      throw ArgumentError('Cannot generate a mixin with no id');
    }
    var ret = super.generate();
    if (ret != null) {
      return '${generateAnnotations()} $ret';
    }
    var buffer = StringBuffer();
    var annotation = generateAnnotations();
    if (filled(annotation)) {
      buffer.writeln(annotation);
    }

    buffer.writeKeyword(keyWordMixin);

    if (_onList.isNotEmpty) {
      buffer.writeKeyword(keyWordOn);
      final names = <String>[
        for (var def in _onList)
          if (def.id != null) def.id!.id
      ];
      buffer.writeNameList(names);
    }
    if (_implementList.isNotEmpty) {
      buffer.writeKeyword(keywordImplements);
      final names = <String>[
        for (var def in _implementList)
          if (def.id != null) def.id!.id
      ];
      buffer.writeNameList(names);
    }
    buffer.openBlock();
    if (_fields.isNotEmpty) {
      buffer.writeln('');
      for (var field in _fields) {
        buffer.writeln(field.generate());
      }
    }

    if (_methods.isNotEmpty) {
      buffer.writeln('');
      var getterName = '';
      for (var method in _methods) {
        if (method.id == null) {
          continue;
        }
        if (!method.isSetter || method.id?.id != getterName) {
          buffer.writeln('');
        }
        if (method.isGetter) {
          buffer.write(method.generate());
          getterName = method.id!.id;
        } else {
          buffer.writeln(method.generate());
          getterName = '';
        }
      }
    }
    buffer.closeBlock();

    return buffer.toString();
  }
}
