import 'dart:async';
import 'package:app_env/app_env.dart';
import 'package:args/args.dart';
import 'package:cli_util/cli_logging.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(
      'environment',
      abbr: 'e',
    )
    ..addOption(
      'package',
      abbr: 'p',
    );

  final results = parser.parse(args);

  final String environmentFileName = results["environment"] ?? '.env';
  final String? package = results["package"];
  final AndroidFileType type = package != null ? AndroidFileType.CLASS : AndroidFileType.XML;

  Logger logger = Logger.standard();
  logger.stdout("Package: $package");
  logger.stdout("Type: $type");
  await AppEnv.process(environmentFileName, androidType: type, package: package);
}
