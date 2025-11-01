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
    // required String basicAuth,
    String basicAuth = '',
    Map<String, dynamic>? queryParameters,
    data,
  }) async {
    log(url);
    log(basicAuth);

    late Response response;
    queryParameters = queryParameters == null || queryParameters.isEmpty
        ? {}
        : queryParameters;
    data = data ?? {};
    try {
      switch (requestType) {
        case RequestType.get:
          response = await _dio.get(
            url,
            queryParameters: queryParameters,
            options: Options(headers: {'authorization': basicAuth}),
          );
          break;
        case RequestType.post:
          response = await _dio.post(
            url,
            queryParameters: queryParameters,
            data: data,
            options: Options(headers: {'authorization': basicAuth}),
          );
          break;
        case RequestType.put:
          response = await _dio.put(
            url,
            queryParameters: queryParameters,
            data: data,
            options: Options(headers: {'authorization': basicAuth}),
          );
          break;
        case RequestType.delete:
          response = await _dio.delete(
            url,
            queryParameters: queryParameters,
            options: Options(
              headers: <String, String>{'authorization': basicAuth},
            ),
          );
          break;
      }
    } on PlatformException catch (err) {
      log("platform exception happened: $err");
      return response;
    } catch (error) {
      return null;
    }
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response;
    } else {
      return null;
    }
  }
}
