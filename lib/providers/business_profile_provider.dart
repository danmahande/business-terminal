import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/business_profile.dart';

class BusinessProfileProvider extends ChangeNotifier {
  final Box<BusinessProfile> _box = Hive.box<BusinessProfile>('business_profile');
  BusinessProfile? _profile;

  BusinessProfile? get profile => _profile;

  BusinessProfileProvider() {
    _loadProfile();
  }

  void _loadProfile() {
    if (_box.isEmpty) {
      _profile = BusinessProfile();
    } else {
      _profile = _box.values.first;
    }
    notifyListeners();
  }

  Future<void> saveProfile(BusinessProfile profile) async {
    await _box.clear();
    await _box.add(profile);
    _profile = profile;
    notifyListeners();
  }
  
  Future<void> addSavings(double amount) async {
    if (_profile != null) {
      _profile!.totalSavings += amount;
      await saveProfile(_profile!);
    }
  }
  
  Future<void> activateSavings(double percentage) async {
    if (_profile != null) {
      _profile!.savingsPercentage = percentage;
      _profile!.savingsStartDate = DateTime.now();
      await saveProfile(_profile!);
    }
  }
  
  Future<void> deactivateSavings() async {
    if (_profile != null) {
      _profile!.savingsPercentage = null;
      _profile!.savingsStartDate = null;
      await saveProfile(_profile!);
    }
  }
}
