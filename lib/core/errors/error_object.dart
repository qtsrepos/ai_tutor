import 'dart:async';
import 'dart:io';
import 'package:ai_tutor/core/errors/exception.dart';
import 'package:http/http.dart' as http;


class ErrorObject {
  const ErrorObject({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  static ErrorObject errorObject({Object? exception}) {
    Object? exp;

    if (exception is http.ClientException) {
      exp = handleHttpException(exception);
    } else {
      exp = exception;
    }

    return handleException(exp);
  }

  static Object? handleHttpException(http.ClientException exception) {
    // Note: http package doesn't provide status codes directly
    // You might need to parse the exception message or use a custom approach
    // to determine the status code
    
    if (exception.message.contains('404')) {
      return NotFoundException();
    } else if (exception.message.contains('500')) {
      return ServerException();
    } else if (exception.message.contains('422')) {
      return const ErrorObject(title: "Error", message: "error 422");
    } else {
      return exception;
    }
  }

  static ErrorObject handleException(Object? exception) {
    switch (exception.runtimeType) {
      case TimeoutException:
        return const ErrorObject(
          title: 'Error Code: TIMEOUT',
          message: 'Request timeout.',
        );
      case FormatException:
        return const ErrorObject(
          title: 'Error Code: FORMAT_EXCEPTION',
          message: 'Invalid input format. Please enter the correct format.',
        );
      case ServerException:
        return const ErrorObject(
          title: 'Error Code: INTERNAL_SERVER_FAILURE',
          message:
              'It seems that the server is not reachable at the moment. Please try again later. If the issue persists, please contact customer support.',
        );
      case DataParsingException:
        return const ErrorObject(
          title: 'Error Code: JSON_PARSING_FAILURE',
          message:
              'It seems that the app needs to be updated to reflect the changed server data structure. If no update is available on the store, please contact customer support.',
        );
      case SocketException:
        return const ErrorObject(
          title: 'NO_CONNECTIVITY',
          message:
              'Please check your internet connectivity or try again later.',
        );
      case NotFoundException:
        return const ErrorObject(
          title: 'Error Code: NOT_FOUND',
          message: 'The requested resource was not found (404).',
        );
      case http.ClientException:
       final clientException = exception as http.ClientException;
  print('ClientException details: ${clientException.message}, URI: ${clientException.uri}');
  return ErrorObject(
    title: 'Error Code: HTTP_ERROR',
    message: 'Network request failed: ${clientException.message}. URI: ${clientException.uri}',
  );
      default:
        if (exception is ErrorObject) return exception;
        return const ErrorObject(
          title: 'Error Code: UNKNOWN_ERROR',
          message: "Something went wrong!",
        );
    }
  }
}