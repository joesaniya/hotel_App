import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hotel_app/models/app_settings_modal.dart';

import 'package:hotel_app/services/app_settings_service.dart';

class AppSettingsProvider extends ChangeNotifier {
  final AppSettingsService _settingsService = AppSettingsService();

  AppSettings? _appSettings;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  AppSettings? get appSettings => _appSettings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasSettings => _appSettings != null;

  // Check if app is in maintenance mode
  bool get isMaintenanceMode => _appSettings?.appMaintenanceMode ?? false;

  // Check if force update is required (based on platform)
  bool isForceUpdateRequired(String platform) {
    if (_appSettings == null) return false;
    
    if (platform.toLowerCase() == 'android') {
      return _appSettings!.appAndroidForceUpdate;
    } else if (platform.toLowerCase() == 'ios') {
      return _appSettings!.appIosForceUpdate;
    }
    
    return false;
  }

  /// Fetch app settings
  Future<void> fetchSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _settingsService.fetchAppSettings();

      if (response != null && response.status && response.data != null) {
        _appSettings = response.data;
        _errorMessage = null;
        log('✅ App settings loaded successfully');
      } else {
        _errorMessage = response?.message ?? 'Failed to fetch settings';
        log('❌ Failed to fetch app settings: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      log('❌ Error in fetchSettings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh settings
  Future<void> refreshSettings() async {
    await fetchSettings();
  }

  /// Clear settings
  void clearSettings() {
    _appSettings = null;
    _errorMessage = null;
    notifyListeners();
  }
}
