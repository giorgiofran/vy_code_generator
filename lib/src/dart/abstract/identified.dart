import '../identifier.dart';

mixin Identified {
  Identifier? id;

  bool get isIdentified => id != null;
}
