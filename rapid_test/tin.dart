import 'implementer.dart';

class Tin extends Implementer<String> {
  const Tin(String string) : super(string);
}

void main() {
  var code = Tin('abc');
  print(code());
  var dd = code;
  print(dd);
  var c = code;
  print(c.call());
  print(Tin('abc') == code);
  print(identical(Tin('abc'), code));

  print(Tin('abd') == code);
  print(c == code);
  print(identical(c, code));
}
