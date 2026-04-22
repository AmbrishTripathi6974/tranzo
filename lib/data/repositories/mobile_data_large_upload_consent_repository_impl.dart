import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/mobile_data_large_upload_consent_repository.dart';

final class MobileDataLargeUploadConsentRepositoryImpl
    implements MobileDataLargeUploadConsentRepository {
  static const String _prefsKey = 'tranzo.mobile_data_large_upload_consented';

  @override
  Future<bool> hasUserConsented() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  @override
  Future<void> setUserConsented(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
  }
}
