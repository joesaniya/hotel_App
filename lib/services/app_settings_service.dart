import 'dart:developer';
import 'package:hotel_app/data-provider/dio-client.dart';
import 'package:hotel_app/models/app_settings_modal.dart';

class AppSettingsService {
  static const String baseUrl = 'https://api.mytravaly.com/public/v1/';
  static const String authToken = '71523fdd8d26f585315b4233e39d9263';

  final DioClient _dioClient = DioClient();

  /// Fetch app settings
  Future<AppSettingsResponse?> fetchAppSettings() async {
    try {
      log('Fetching app settings...');

      final response = await _dioClient.performCall(
        requestType: RequestType.post,
        url: '${baseUrl}appSetting/',
        headers: {'authtoken': authToken},
      );

      if (response != null && response.statusCode == 200) {
        log('App settings fetched successfully');
        return AppSettingsResponse.fromJson(response.data);
      } else {
        log('Failed to fetch app settings: ${response?.statusCode}');
        return null;
      }
    } catch (e) {
      log('Error fetching app settings: $e');
      return null;
    }
  }
}
