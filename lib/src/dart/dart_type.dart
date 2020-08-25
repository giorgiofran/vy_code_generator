import 'utils/keywords.dart';

DartType typeDynamic = DartType()..type = keywordDynamic;

class DartType {
  String type;

  @override
  bool operator ==(other) => type == other.type;

  @override
  int get hashCode => type.hashCode;
}
