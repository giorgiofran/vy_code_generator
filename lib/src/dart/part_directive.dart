import 'package:vy_string_utils/vy_string_utils.dart';

import 'identifier.dart';
import 'utils/keywords.dart';
import 'utils/string_buffer_extension.dart';

class PartDirective {
  final String relativePath;
  final Identifier partIdentifier;
  String libraryName;

  PartDirective(this.relativePath, this.partIdentifier);

  /// The main source has relative path = '.' and partIdentifier = ''
  String get partPath {
    var relPath = relativePath == '.' ? '' : '$relativePath/';
    var id = filled(partIdentifier.id) ? '${partIdentifier.id}.dart' : '';
    if (filled(relPath)) {
      assert(
          filled(id),
          'If the relative path is set, also the part identifier '
          'must be specified');
    }
    return '${relPath}$id';
  }

  @override
  bool operator ==(other) => partPath == other.partPath;

  @override
  int get hashCode => partPath.hashCode;

  String generate({bool isPartOf}) {
    isPartOf ??= false;
    var buffer = StringBuffer();
    if (isPartOf) {
      var counter = RegExp(r'[\/]');
      Iterable<Match> matches = counter.allMatches(partPath);
      buffer.writeKeyword(keywordPartOf);
      buffer.write("'");
      for (var idx = 0; idx < matches.length; idx++) {
        buffer.write('../');
      }
      buffer.write('$libraryName.dart');
      buffer.write("'");
    } else {
      buffer.writeKeyword(keywordPart);
      buffer.write("'");
      buffer.write(partPath);
      buffer.write("'");
    }

    return '$buffer;';
  }
}
