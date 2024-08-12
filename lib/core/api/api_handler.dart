import 'dart:convert';
import 'package:ai_tutor/core/constants/http_responses.dart';
import 'package:ai_tutor/core/errors/exception.dart';
import 'package:http/http.dart' as http;

class APIHandler {
  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case HttpResponses.OK:
      case HttpResponses.Created:
      case HttpResponses.NoContent:
      case HttpResponses.PartialContent:
        return jsonDecode(response.body);
      case HttpResponses.BadRequest:
        throw Exception("Invalid Request");
      case HttpResponses.Unauthorized:
        throw Exception(getError(response));
      case HttpResponses.Forbidden:
        throw Exception("Unauthorised request");
      case HttpResponses.InternalServerError:
        throw ServerException();
      case HttpResponses.invalidRequest:
        throw Exception("Invalid Request");
      default:
        throw getError(response);
    }
  }

  getError(http.Response response) {
    Map<String, dynamic>? responseJson;

    if (response.statusCode >= 500) {
      return ServerException();
    } else if ((response.statusCode == 400) ||
        (response.statusCode == 401) ||
        (response.statusCode == 403) ||
        (response.statusCode == 404) ||
        (response.statusCode == 406) ||
        (response.statusCode == 429)) {
      const errorMessage = "Not found";
      return Exception(errorMessage);
    }

    try {
      responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (exception) {
      return exception;
    }

    if (responseJson["message"] == "Unauthenticated.") {
      return Exception(responseJson["message"]);
    }

    if (response.statusCode == 422) {
      Map<String, dynamic> errors = responseJson["errors"];
      final keys = errors.keys;
      final errorStrings = errors[keys.first];
      return Exception(errorStrings[0]);
    } else {
      return Exception("Please try again");
    }
  }
}