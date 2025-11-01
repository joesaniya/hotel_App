import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

enum RequestType { get, post, put, delete }

class DioClient {
  final Dio _dio = Dio();
  double? extTime;

  late Response response;

  DioClient() {
    _dio
      ..options.connectTimeout = const Duration(seconds: 20)
      ..options.receiveTimeout = const Duration(seconds: 90)
      ..options.responseType = ResponseType.json;
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: true,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  Future<Response?> performCall({
    required RequestType requestType,
    required String url,
    String basicAuth = '',
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers, // Add custom headers support
    data,
  }) async {
    log(url);

    late Response response;
    queryParameters = queryParameters == null || queryParameters.isEmpty
        ? {}
        : queryParameters;
    data = data ?? {};

    // Build headers
    Map<String, dynamic> requestHeaders = {'Content-Type': 'application/json'};

    // Add authorization header if provided (legacy support)
    if (basicAuth.isNotEmpty) {
      requestHeaders['authorization'] = basicAuth;
    }

    // Merge with custom headers if provided (this will override above if needed)
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    log('Request headers: $requestHeaders');

    try {
      switch (requestType) {
        case RequestType.get:
          response = await _dio.get(
            url,
            queryParameters: queryParameters,
            options: Options(headers: requestHeaders),
          );
          break;
        case RequestType.post:
          response = await _dio.post(
            url,
            queryParameters: queryParameters,
            data: data,
            options: Options(headers: requestHeaders),
          );
          break;
        case RequestType.put:
          response = await _dio.put(
            url,
            queryParameters: queryParameters,
            data: data,
            options: Options(headers: requestHeaders),
          );
          break;
        case RequestType.delete:
          response = await _dio.delete(
            url,
            queryParameters: queryParameters,
            options: Options(headers: requestHeaders),
          );
          break;
      }
    } on PlatformException catch (err) {
      log("platform exception happened: $err");
      return response;
    } on DioException catch (error) {
      log("Dio exception: ${error.response?.statusCode} - ${error.message}");
      return error.response;
    } catch (error) {
      log("Unknown error: $error");
      return null;
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    } else {
      return response; // Return response even on error for debugging
    }
  }
}
