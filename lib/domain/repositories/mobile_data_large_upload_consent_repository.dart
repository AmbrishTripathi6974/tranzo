abstract interface class MobileDataLargeUploadConsentRepository {
  Future<bool> hasUserConsented();

  Future<void> setUserConsented(bool value);
}
