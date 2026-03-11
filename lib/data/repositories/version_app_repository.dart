import 'package:package_info_plus/package_info_plus.dart';

class VersionAppRepository {
  Future<String> getVersionApp() async {
    final info = await PackageInfo.fromPlatform();
    
    return '${info.version}.${info.buildNumber}';
  }
}