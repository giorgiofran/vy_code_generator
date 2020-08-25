import 'package:vy_string_utils/vy_string_utils.dart';

import 'abstract/annotated.dart';
import 'abstract/named_element.dart';
import 'constructor.dart';
import 'dart_factory.dart';
import 'variable.dart';
import 'identifier.dart';
import 'utils/keywords.dart';
import 'library.dart';
import 'method.dart';
import 'dart_type.dart';
import 'utils/string_buffer_extension.dart';

class DartClass extends NamedElement with DartType, Annotated {
  bool isAbstract = false;
  DartClass extend;
  final List<NamedElement> _withList = <NamedElement>[];
  final List<DartClass> _implementList = <DartClass>[];

  final List<Variable> _fields = <Variable>[];
  final List<Constructor> _constructors = <Constructor>[];
  final List<DartFactory> _factories = <DartFactory>[];
  final List<Method> _methods = <Method>[];

  DartClass.id(Identifier id) : super(id) {
    type = id.id;
  }
  DartClass(String className) : super(Identifier(className)) {
    type = id.id;
  }
  DartClass.fromTextualContent(String text) : super.fromTextualContent(text);

  List<Constructor> get constructors => _constructors;
  List<DartClass> get implementingClasses => _implementList;

  void addMixin(NamedElement mixin) {
    var existingMixin = _withList.firstWhere(
        (element) => element.id.id == mixin.id.id,
        orElse: () => null);
    if (existingMixin == null) {
      _withList.add(mixin);
      return;
    }
    throw StateError('The mixin "${mixin.id.id}" is already present '
        'in class "${id.id}"');
  }

  void addImplements(DartClass implementClass) {
    var existingImplements = _implementList.firstWhere(
        (element) => element.id.id == implementClass.id.id,
        orElse: () => null);
    if (existingImplements == null) {
      _implementList.add(implementClass);
      return;
    }
    throw StateError('The class "${implementClass.id.id}" is already present '
        'in class "${id.id}"');
  }

  void addFieldSeparator() => addField(Variable.fromTextualContent('\n'));

  void addField(Variable field) {
    var existingField = _fields.firstWhere(
        (element) =>
            filled(element.id?.id) &&
            filled(field.id?.id) &&
            element.id.id == field.id.id,
        orElse: () => null);
    if (existingField == null) {
      field.parent = this;
      if (library != null) {
        field.library = library;
      }
      _fields.add(field);
      return;
    }
    throw StateError('The field "${field.id.id}" is already present '
        'in class "${id.id}"');
  }

  void addConstructor(Constructor constructor) {
    var existingConstructor = _constructors.firstWhere(
        (element) => element.named == constructor.named,
        orElse: () => null);
    if (existingConstructor == null) {
      constructor.parent = this;
      if (library != null) {
        constructor.library = library;
      }
      _constructors.add(constructor);
      return;
    }
    throw StateError(
        'The constructor "${constructor.named}" is already present '
        'in class "${id.id}"');
  }

  void addFactory(DartFactory factory) {
    var existingFactory = _factories.firstWhere(
        (element) => element.named == factory.named,
        orElse: () => null);
    if (existingFactory == null) {
      factory.parent = this;
      if (library != null) {
        factory.library = library;
      }
      _factories.add(factory);
      return;
    }
    throw StateError('The factory "${factory.named}" is already present '
        'in class "${id.id}"');
  }

  void addMethod(Method method) {
    var existingMethod = _methods.firstWhere(
        (element) =>
            filled(element.id?.id) &&
            filled(method.id?.id) &&
            element.id.id == method.id.id &&
            method.isSetter == element.isSetter &&
            element.isGetter == element.isGetter,
        orElse: () => null);
    if (existingMethod == null) {
      method.parent = this;
      if (library != null) {
        method.library = library;
      }
      _methods.add(method);
      return;
    }
    throw StateError('The '
        '${method.isGetter ? 'getter' : method.isSetter ? 'setter' : 'method'} '
        '"${method.id.id}" is already present in class "${id.id}"');
  }

  @override
  void libraryUpdated(Library library) {
    super.libraryUpdated(library);
    for (var field in _fields) {
      field.library = library;
    }
    for (var constructor in _constructors) {
      constructor.library = library;
    }
    for (var factory in _factories) {
      factory.library = library;
    }
    for (var method in _methods) {
      method.library = library;
    }
  }

  @override
  String generate() {
    var ret = super.generate();
    if (ret != null) {
      return '${generateAnnotations()} $ret';
    }
    var buffer = StringBuffer();
    buffer.writeln(generateAnnotations());
    if (isAbstract) {
      buffer.writeKeyword(keywordAbstract);
    }
    buffer.writeKeyword(keywordClass);
    buffer.writeIdentifier(id.id);
    if (extend != null) {
      buffer.writeKeyword(keywordExtends);
      buffer.writeIdentifier(extend.id.id);
    }
    if (_withList.isNotEmpty) {
      buffer.writeKeyword(keywordWith);
      final names = <String>[for (var def in _withList) def.id.id];
      buffer.writeNameList(names);
    }
    if (_implementList.isNotEmpty) {
      buffer.writeKeyword(keywordImplements);
      final names = <String>[for (var def in _implementList) def.id.id];
      buffer.writeNameList(names);
    }
    buffer.openBlock();
    if (_fields.isNotEmpty) {
      buffer.writeln('');
      for (var field in _fields) {
        buffer.writeln(field.generate());
      }
    }
    if (_constructors.isNotEmpty) {
      buffer.writeln('');
      for (var constructor in _constructors) {
        buffer.writeln(constructor.generate());
      }
    }
    if (_factories.isNotEmpty) {
      buffer.writeln('');
      for (var factory in _factories) {
        buffer.writeln(factory.generate());
      }
    }
    if (_methods.isNotEmpty) {
      buffer.writeln('');
      var getterName = '';
      for (var method in _methods) {
        if (!method.isSetter || method.id.id != getterName) {
          buffer.writeln('');
        }
        if (method.isGetter) {
          buffer.write(method.generate());
          getterName = method.id.id;
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
