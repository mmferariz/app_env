import 'dart:async';

import 'package:app_env/helpers/android_class_helper.dart';
import 'package:app_env/helpers/android_xml_helper.dart';
import 'package:app_env/helpers/env_helper.dart';
import 'package:app_env/helpers/ios_config_helper.dart';
import 'package:cli_util/cli_logging.dart';

class AppEnv {
  static String get _baseStringClass => 'android/app/src/main/java';
  static String get _stringXml => 'android/app/src/main/res/values/strings.xml';
  static String get _iOSConfig => 'ios/Flutter/AppEnvConfig.xcconfig';

  static Future<void> process(String envFileName, { AndroidFileType androidType = AndroidFileType.XML, String? package}) async {
    final EnvHandler env = EnvHandler(envFileName);
    final String envFilePath = await env.fileContent;

    final Map<String, String> data = await env.extract();

    if(androidType == AndroidFileType.XML) {
      await AndroidXMLHandler(_stringXml).init(data: data);
    } else {
      Logger logger = Logger.standard();

      String _stringClass = _baseStringClass;
      List<String> paths = package!.split(".");
      paths.forEach((e) => _stringClass = "$_stringClass/$e");
      _stringClass = "$_stringClass/BuildConfig.java";
      logger.stdout("Java path: $_stringClass");
      await AndroidClassHandler(_stringClass, package).init(data: data);
    }


    await IOSConfigHandler(_iOSConfig).modify(envFilePath);
  }
}

enum AndroidFileType {
  XML, CLASS
}
