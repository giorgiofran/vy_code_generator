import 'package:vy_string_utils/vy_string_utils.dart';

import 'abstract/dart_element.dart';
import 'abstract/identified.dart';
import 'abstract/named_element.dart';
import 'dart_class.dart';
import 'identifier.dart';
import 'utils/keywords.dart';
import 'library.dart';
import 'parameter_list.dart';
import 'utils/string_buffer_extension.dart';

class DartFactory extends NamedElement with Identified {
  List<DartElement> elements = <DartElement>[];
  ParameterList parmList;
  String named;

  DartFactory.id(Identifier id) : named = id.id, super(id);
  DartFactory({this.named}) : super(Identifier(named ?? ''));

  DartFactory.fromTextualContent(String text)
      : super.fromTextualContent(text);

  void addElement(DartElement element) {
    element.parent = this;
    if (library != null) {
      element.library = library;
    }
    elements.add(element);
    return;
  }

  @override
  String generate() {
    var ret = super.generate();
    if (ret != null) {
      return ret;
    }
    var buffer = StringBuffer();
    buffer.writeKeyword(keywordFactory);
    buffer.write((parent as DartClass).id.id);
    if (filled(named)) {
      buffer.write('.$named');
    }
    buffer.write('(');
    if (parmList != null && parmList.isNotEmpty) {
      buffer.write(parmList.listDefinition);
    }
    buffer.write(')');
    buffer.openBlock();
    for (var element in elements) {
      buffer.write(element.generate());
    }
    buffer.closeBlock();
    return '$buffer';
  }

  @override
  void libraryUpdated(Library library) {
    super.libraryUpdated(library);
    for (var element in elements) {
      element.library = library;
    }
  }
}
