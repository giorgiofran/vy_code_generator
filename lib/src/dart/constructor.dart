import 'package:vy_string_utils/vy_string_utils.dart';

import 'abstract/dart_element.dart';
import 'abstract/identified.dart';
import 'abstract/named_element.dart';
import 'dart_class.dart';
import 'identifier.dart';
import 'library.dart';
import 'parameter_list.dart';
import 'utils/string_buffer_extension.dart';

class Constructor extends NamedElement with Identified {
  final List<DartElement> _elements = <DartElement>[];
  final List<DartElement> _closingElements = <DartElement>[];
  final List<DartElement> _openingElements = <DartElement>[];

  ParameterList? parmList;
  List<String> initializationList = <String>[];

  Constructor.named(Identifier id) : super(id);
  Constructor({String? named}) : super(Identifier(named ?? ''));

  Constructor.fromTextualContent(String text) : super.fromTextualContent(text);

  String get named => id?.id ?? '';

  void addTextualInitStatement(String initTest) =>
      initializationList.add(initTest);

  void _add(DartElement element, List<DartElement> list) {
    element.parent = this;
    if (library != null) {
      element.library = library;
    }
    list.add(element);
    return;
  }

  bool get hasBody =>
      _openingElements.isNotEmpty ||
      _elements.isNotEmpty ||
      _closingElements.isNotEmpty;

  void addOpeningElement(DartElement element) =>
      _add(element, _openingElements);

  void addElement(DartElement element) => _add(element, _elements);
  void addClosingElement(DartElement element) =>
      _add(element, _closingElements);

  @override
  String generate() {
    var buffer = StringBuffer();
    if (parent == null) {
      throw StateError('Constructor with no parent detected');
    }
    if ((parent as DartClass).id == null) {
      throw StateError('Parent class has no id');
    }
    buffer.write((parent as DartClass).id!.id);
    if (filled(id?.id)) {
      buffer.write('.${id?.id}');
    }
    buffer.write('(');
    if (parmList != null && parmList!.isNotEmpty) {
      buffer.write(parmList!.listDefinition);
    }
    buffer.write(')');
    if (initializationList.isNotEmpty) {
      buffer.write(' : ');
      buffer.write([for (var initStatement in initializationList) initStatement]
          .join(', '));
    }
    if (hasBody) {
      buffer.openBlock();
      for (var element in [
        ..._openingElements,
        ..._elements,
        ..._closingElements
      ]) {
        buffer.write(element.generate());
      }
      buffer.closeBlock();
    } else {
      buffer.write(';');
    }

    return '$buffer';
  }

  @override
  void libraryUpdated(Library? library) {
    super.libraryUpdated(library);
    for (var element in _elements) {
      element.library = library;
    }
  }
}
