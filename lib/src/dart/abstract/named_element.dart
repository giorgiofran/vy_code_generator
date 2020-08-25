import '../identifier.dart';
import 'dart_element.dart';
import 'identified.dart';

abstract class NamedElement extends DartElement with Identified {
  NamedElement(Identifier id) {
    this.id = id;
  }

  @override
  bool operator ==(other) => id.id == other.id.id;

  @override
  int get hashCode => id.id.hashCode;

  NamedElement.fromTextualContent(String text)
      : super.fromTextualContent(text);
}
