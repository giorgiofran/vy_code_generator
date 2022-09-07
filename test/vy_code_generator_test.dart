import 'package:vy_code_generator/vy_code_generator.dart';
import 'package:test/test.dart';

void main() {
  test('Utils', () {
    expect(['a', 'b'].join('#'), 'a#b');
    expect([].join('\n'), '');
  });
  group('Class', () {
    test('simple class', () {
      var classTest = DartClass('Foo');
      expect(classTest.generate(), 'class Foo {\n\n}');
    });
    test('abstract class', () {
      var classTest = DartClass('Foo')..isAbstract = true;
      expect(classTest.generate(), 'abstract class Foo {\n\n}');
    });
  });
  group('Library', () {
    test('simple Library', () {
      var classTest = DartClass('Foo');
      var library = Library('foo')..addElement(classTest);
      expect(library.generate()[''], 'class Foo {\n\n}');
    });
    test('abstract class', () {
      var classTest = DartClass('Foo')..isAbstract = true;
      var library = Library('foo')..addElement(classTest);
      expect(library.generate()[''], 'abstract class Foo {\n\n}');
    });
    test('Library with fields', () {
      var field =
          Variable.fromTextualContent("const String fieldTest = 'foo';");
      var classTest = DartClass('Foo');
      var library = Library('foo')
        ..addElement(field)
        ..addElement(classTest);
      expect(library.generate()[''],
          "const String fieldTest = 'foo';\nclass Foo {\n\n}");
    });
    test('Library with method', () {
      var field =
          Variable.fromTextualContent("const String fieldTest = 'foo';");
      var method = Method.fromTextualContent(
          "Future<void> fooMethod(String test) {\nprint('foo');\n}");
      var classTest = DartClass('Foo');
      var library = Library('foo')
        ..addElement(field)
        ..addElement(method)
        ..addElement(classTest);
      expect(
          library.generate()[''],
          "const String fieldTest = 'foo';\n"
          "Future<void> fooMethod(String test) {\nprint('foo');\n}\n"
          'class Foo {\n\n}');
    });
    test('Library with separator', () {
      var field =
          Variable.fromTextualContent("const String fieldTest = 'foo';");
      var method = Method.fromTextualContent(
          "Future<void> fooMethod(String test) {\nprint('foo');\n}");
      var classTest = DartClass('Foo');
      var library = Library('foo')
        ..addElement(field)
        ..addSeparator()
        ..addElement(method)
        ..addSeparator()
        ..addElement(classTest);
      expect(
          library.generate()[''],
          "const String fieldTest = 'foo';\n\n"
          "Future<void> fooMethod(String test) {\nprint('foo');\n}\n\n"
          'class Foo {\n\n}');
    });
  });
}
