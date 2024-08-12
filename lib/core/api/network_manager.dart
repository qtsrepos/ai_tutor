import 'dart:convert';
import 'dart:io';
import 'package:ai_tutor/core/api/api_handler.dart';
import 'package:ai_tutor/core/constants/credentials.dart';
import 'package:ai_tutor/core/errors/error_object.dart';
import 'package:http/http.dart' as http;
import 'package:either_dart/either.dart';

class NetWorkManager extends APIHandler {
  static NetWorkManager? _shared;
  NetWorkManager._();

  static NetWorkManager shared() => _shared ?? NetWorkManager._();

  Future<Either<ErrorObject, Map<String, dynamic>>> request({
    required String url,
    String? method,
    Encoding? encodingType,
    Map<String, String>? params,
    bool isAuthRequired = true,
    Map<String, dynamic>? data,
    int? timeoutInSec,
  }) async {
    try {
      Map<String, String> headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
      };

      if (isAuthRequired) {
        headers["Authorization"] = "Bearer $token";
      }

      http.Response response;
      final uri = Uri.parse(url).replace(queryParameters: params);
      print("Requesting URL: $uri"); // For debugging

      if (method == "post") {
        response = await http
            .post(uri,
                headers: headers,
                body: jsonEncode(data ?? {}),
                encoding: encodingType)
            .timeout(Duration(seconds: timeoutInSec ?? 10));
      } else if (method == "put") {
        response = await http
            .put(uri,
                headers: headers,
                body: jsonEncode(data ?? {}),
                encoding: encodingType)
            .timeout(Duration(seconds: timeoutInSec ?? 10));
      } else if (method == "delete") {
        response = await http
            .delete(uri, headers: headers)
            .timeout(Duration(seconds: timeoutInSec ?? 10));
      } else {
        // GET request
        response = await http
            .get(uri, headers: headers)
            .timeout(Duration(seconds: timeoutInSec ?? 10));
      }

      print("Response status: ${response.statusCode}"); // For debugging
      print("Response body: ${response.body}"); // For debugging

      final result = returnResponse(response);

      // if (result["message"] == "AUTHENTICATION FAILED") {
      //   // Trigger token refresh
      //   final tokenRefreshResult = await tokenManagement();

      //   if (tokenRefreshResult) {
      //     // Retry the original request after successful token refresh
      //     return request(
      //       url: url,
      //       method: method,
      //       encodingType: encodingType,
      //       params: params,
      //       isAuthRequired: isAuthRequired,
      //       data: data,
      //       timeoutInSec: timeoutInSec,
      //     );
      //   }
      // }

      if (result is Map<String, dynamic>) return Right(result);

      throw result;
    } catch (exception) {
      print("Exception occurred: $exception"); // For debugging
      if (exception is SocketException) {
        return Left(ErrorObject.errorObject(
            exception: const SocketException("Network error!")));
      }
      return Left(ErrorObject.errorObject(exception: exception));
    }
  }
}