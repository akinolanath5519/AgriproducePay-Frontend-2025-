import 'package:http/http.dart' as http;

class HttpErrorHandler {
  // Reusable function to handle HTTP errors
  static void handleResponse(http.Response response, String action) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // Log the error status and body
      print('Failed to $action. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Throw an exception with the error message
      throw Exception('Failed to $action: ${response.body}');
    }
  }

  // Function to handle JSON decoding errors
  static void handleJsonDecodingError(String action, dynamic e) {
    print('Error decoding JSON while trying to $action: $e');
    throw Exception('Failed to decode data for $action');
  }
}
