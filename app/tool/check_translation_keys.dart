// Compares locale JSON keys to en.json (source of truth). Run: dart run tool/check_translation_keys.dart
import 'dart:convert';
import 'dart:io';

void main() {
  final String root = Directory.current.path;
  final Map<String, dynamic> en = _readJson(
    File('$root/assets/translations/en.json'),
  );
  final Set<String> keys = en.keys.toSet();
  bool ok = true;
  ok =
      _compare(
        keys,
        _readJson(File('$root/assets/translations/de.json')),
        'de',
      ) &&
      ok;
  ok =
      _compare(
        keys,
        _readJson(File('$root/assets/translations/el.json')),
        'el',
      ) &&
      ok;
  if (!ok) {
    exit(1);
  }
  stdout.writeln('i18n: keys match en.json for de + el.');
}

Map<String, dynamic> _readJson(File f) {
  return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
}

bool _compare(Set<String> enKeys, Map<String, dynamic> other, String name) {
  bool ok = true;
  final Set<String> o = other.keys.toSet();
  for (final String k in enKeys) {
    if (!o.contains(k)) {
      stderr.writeln('Missing key in $name: $k');
      ok = false;
    }
  }
  for (final String k in o) {
    if (!enKeys.contains(k)) {
      stderr.writeln('Extra key in $name: $k');
      ok = false;
    }
  }
  return ok;
}
