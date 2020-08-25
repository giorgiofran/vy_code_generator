import 'package:vy_string_utils/vy_string_utils.dart';

import 'abstract/annotated.dart';
import 'abstract/dart_element.dart';
import 'abstract/identified.dart';
import 'abstract/named_element.dart';
import 'identifier.dart';
import 'utils/keywords.dart';
import 'library.dart';
import 'parameter_list.dart';
import 'dart_type.dart';
import 'utils/string_buffer_extension.dart';

class Method extends NamedElement with Identified, Annotated {
  final List<DartElement> _elements = <DartElement>[];
  final List<DartElement> _closingElements = <DartElement>[];
  ParameterList parmList;
  DartType returnType;
  // even if true it works only if there is no parmList
  bool isGetter = false;
  // even if true it works only if there is exactly one parameter
  // (not optional or named)
  bool isSetter = false;
  // is Asynchronous method
  bool isAsync = false;

  Method.id(Identifier id) : super(id);
  Method(String methodName) : super(Identifier(methodName));

  Method.fromTextualContent(String text) : super.fromTextualContent(text);

  void _add(DartElement element, List<DartElement> list) {
    element.parent = this;
    if (library != null) {
      element.library = library;
    }
    list.add(element);
    return;
  }

  void addElement(DartElement element) => _add(element, _elements);
  void addClosingElement(DartElement element) =>
      _add(element, _closingElements);

  @override
  String generate() {
    var ret = super.generate();
    if (ret != null) {
      return '${generateAnnotations()} $ret';
    }
    if (isGetter && parmList != null && parmList.isNotEmpty) {
      isGetter = false;
    }
    if (isSetter &&
        (parmList == null ||
            parmList.positionalParametersLength != 1 ||
            parmList.optionalParametersLength > 0 ||
            parmList.namedParametersLength > 0)) {
      isSetter = false;
    }
    var buffer = StringBuffer();
    buffer.writeln(generateAnnotations());
    if (isSetter) {
      buffer.writeIdentifier(keywordSet);
    }
    if (filled(id?.id)) {
      if (returnType != null && !isSetter) {
        if (isAsync && !returnType.type.startsWith('Future<')) {
          buffer.writeIdentifier('Future<${returnType.type}>');
        } else {
          buffer.writeIdentifier(returnType.type);
        }
      }
      if (isGetter) {
        buffer.writeIdentifier(keywordGet);
      }
      buffer.write(id.id);
    } else if (isGetter) {
      throw StateError(
          'Setter methods cannot be anonymous (method name required)');
    }
    if (!isGetter) {
      buffer.openParentheses();
      if (parmList != null) {
        buffer.write(parmList.listDefinition);
      }
      buffer.closeParentheses();
    }
    if (isAsync) {
      buffer.writeIdentifier(' $keywordAsync');
    }

    if (_elements.length == 1) {
      buffer.write('=>');
      var expressionBodyString = _elements.first.generate().trimLeft();
      if (expressionBodyString.startsWith(keywordReturn)) {
        expressionBodyString =
            expressionBodyString.replaceFirst(keywordReturn, '');
      }
      buffer.write(expressionBodyString);
    } else {
      buffer.openBlock();
      for (var element in [..._elements, ..._closingElements]) {
        buffer.write(element.generate());
      }
      buffer.closeBlock();
    }
    return '$buffer';
  }

  @override
  void libraryUpdated(Library library) {
    super.libraryUpdated(library);
    for (var element in _elements) {
      element.library = library;
    }
  }
}
