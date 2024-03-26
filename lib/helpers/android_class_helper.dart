import 'dart:io';
import 'package:cli_util/cli_logging.dart';

class AndroidClassHandler {

  File? _classFile;
  late String _package;

  String get classBaseFileContent => '''package $_package;\n
  public final class BuildConfig {

}''';

  String _stringJavaValue(String key, String value) => "\n\tpublic static final String $key = \"$value\";\n";
  String _booleanJavaValue(String key, bool value) => "\n\tpublic static final boolean $key = $value;\n";
  String _intJavaValue(String key, int value) => "\n\tpublic static final int $key = $value;\n";
  String _doubleJavaValue(String key, double value) => "\n\tpublic static final double $key = $value;\n";

  AndroidClassHandler(String filePath, String package) {
    _classFile = File(filePath);
    _package = package;
  }

  Future<File?> init({Map<String, String>? data}) async {
    try {
      final bool fileIsExists = _classFile!.existsSync();
      if (fileIsExists) {
        final content = _classFile!.readAsStringSync();
        if (content.isEmpty || content.contains(";")) {
          await updateFileContent(classBaseFileContent);
        }

        await _modifyStringTag(data ?? {});
        return _classFile;
      }
      await _classFile!.create(recursive: true);
      await updateFileContent(classBaseFileContent);
      await init(data: data);
    } on Exception {
      Logger logger = Logger.standard();
      logger.stdout("strings.xml wrong formatted");
    }
    return null;
  }

  // Future<String?> getTagValue(String namePropValue, [String? newValue]) async {
  //   try {
  //     for (var element
  //         in _document!.getElement('resources')!.findElements('string')) {
  //       if (element.getAttribute("name") == namePropValue) {
  //         if (newValue != null) {
  //           element.innerText = newValue;
  //         }
  //         return element.innerText;
  //       }
  //     }
  //   } catch (e) {
  //     log('ERROR $e');
  //   }
  //   return null;
  // }

  Future<void> _modifyStringTag(Map<String, String> data) async {
    try {

      List<String> lines = _classFile!.readAsLinesSync();
      final int? last = lines.lastIndexWhere((e) => e.endsWith("}"));
      List<String> variables = _createVariables(data);

      if(last != null){
        lines.insertAll(last - 1, variables);
      }
      await updateFileContent(lines.join());
    } catch (_) {}
  }

  List<String> _createVariables(Map<String, String> data){
    return data.map<String, String>(
      (key, value) {
        double? doubleValue = double.tryParse(value);
        if(doubleValue != null) {
          if(value.contains(".")) {
            return MapEntry(key, _doubleJavaValue(key, doubleValue));
          } else {
            int? intValue = int.tryParse(value);
            if(intValue != null) {
              return MapEntry(key, _intJavaValue(key, intValue));
            }
          }
        }

        bool? boolValue = bool.tryParse(value);
        if(boolValue != null) {
          return MapEntry(key, _booleanJavaValue(key, boolValue));
        }

        return MapEntry(key, _stringJavaValue(key, value));
      },
    ).values.toList();
  }

  Future<File>? updateFileContent(String text) => _classFile?.writeAsString(text);
}