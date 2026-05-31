import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final instance = RemoteConfigService._();
  RemoteConfigService._();

  final _config = FirebaseRemoteConfig.instance;

  static const _defaults = <String, dynamic>{
    'subscription_lock_enabled': true,
    'free_exam_limit': 3,
  };

  Future<void> init() async {
    await _config.setDefaults(_defaults);
    await _config.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _config.fetchAndActivate();
  }

  bool get subscriptionLockEnabled => _config.getBool('subscription_lock_enabled');
  int get freeExamLimit => _config.getInt('free_exam_limit');
}
