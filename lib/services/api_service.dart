import 'dart:developer';

import 'package:hotel_app/data-provider/dio-client.dart';


class MyTravalyApiService {
  static const String baseUrl = 'https://api.mytravaly.com/public/v1/';
  static const String authToken = '71523fdd8d26f585315b4233e39d9263';
  
  final DioClient _dioClient = DioClient();

 
  Future<String?> registerDevice(Map<String, dynamic> deviceData) async {
    try {
      log('Registering device...');
      
      final response = await _dioClient.performCall(
        requestType: RequestType.post,
        url: baseUrl,
        headers: {
          'authtoken': authToken, 
        },
        data: deviceData,
      );

      if (response != null && 
          (response.statusCode == 200 || response.statusCode == 201)) {
        log('Device registration successful');
        log('Response: ${response.data}');
        
        
        if (response.data != null && response.data is Map) {

          final visitorToken = response.data['data']?['visitorToken'];
          
          if (visitorToken != null) {
            log('Visitor token received: $visitorToken');
            return visitorToken.toString();
          } else {
            log('No visitor token found in response');
            log('Full response data: ${response.data}');
          }
        }
        
        return null;
      } else {
        log('Device registration failed: ${response?.statusCode}');
        log('Response data: ${response?.data}');
        return null;
      }
    } catch (e) {
      log('Error registering device: $e');
      return null;
    }
  }
}


