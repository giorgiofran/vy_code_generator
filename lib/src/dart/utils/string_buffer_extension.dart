import '../abstract/identified.dart';

extension StringBufferExtension on StringBuffer {
  void writeKeyword(String keyword) {
    write(keyword);
    write(' ');
  }

  void writeIdentifier(String identifier) {
    write(identifier);
    write(' ');
  }

  void writeNameIterable(Iterable<String> names) {
    write(names.join(', '));
    write(' ');
  }

  void writeNameList(List<String> names) => writeNameIterable(names..sort());
  void writeNameSet(Set<String> names) =>
      writeNameIterable(names.toList()..sort());

  void writeIdentifiedSet(Set<Identified> identifiedSet) =>
      writeNameIterable(<String>[
        for (Identified identified in identifiedSet)
          if (identified.id != null) identified.id!.id
      ]..sort());

  void openBlock() => write('{\n');
  void closeBlock() => write('\n}');
  void openParentheses() => write('(');
  void closeParentheses() => write(')');
}
