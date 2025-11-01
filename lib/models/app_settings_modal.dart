class AppSettings {
  final String googleMapApi;
  final String appAndroidVersion;
  final String appIosVersion;
  final bool appAndroidForceUpdate;
  final bool appIosForceUpdate;
  final bool appMaintenanceMode;
  final String supportEmailId;
  final String contactEmailId;
  final String contactNumber;
  final String whatsappNumber;

  AppSettings({
    required this.googleMapApi,
    required this.appAndroidVersion,
    required this.appIosVersion,
    required this.appAndroidForceUpdate,
    required this.appIosForceUpdate,
    required this.appMaintenanceMode,
    required this.supportEmailId,
    required this.contactEmailId,
    required this.contactNumber,
    required this.whatsappNumber,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      googleMapApi: json['googleMapApi'] ?? '',
      appAndroidVersion: json['appAndroidVersion'] ?? '',
      appIosVersion: json['appIosVersion'] ?? '',
      appAndroidForceUpdate: json['appAndroidForceUpdate'] ?? false,
      appIosForceUpdate: json['appIsoForceUpdate'] ?? false,
      appMaintenanceMode: json['appMaintenanceMode'] ?? false,
      supportEmailId: json['supportEmailId'] ?? '',
      contactEmailId: json['contactEmailId'] ?? '',
      contactNumber: json['conatctNumber'] ?? '',
      whatsappNumber: json['whatsappNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'googleMapApi': googleMapApi,
      'appAndroidVersion': appAndroidVersion,
      'appIosVersion': appIosVersion,
      'appAndroidForceUpdate': appAndroidForceUpdate,
      'appIsoForceUpdate': appIosForceUpdate,
      'appMaintenanceMode': appMaintenanceMode,
      'supportEmailId': supportEmailId,
      'contactEmailId': contactEmailId,
      'conatctNumber': contactNumber,
      'whatsappNumber': whatsappNumber,
    };
  }
}

class AppSettingsResponse {
  final bool status;
  final String message;
  final int responseCode;
  final AppSettings? data;

  AppSettingsResponse({
    required this.status,
    required this.message,
    required this.responseCode,
    this.data,
  });

  factory AppSettingsResponse.fromJson(Map<String, dynamic> json) {
    return AppSettingsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      responseCode: json['responseCode'] ?? 0,
      data: json['data'] != null ? AppSettings.fromJson(json['data']) : null,
    );
  }
}
