import 'dart:convert';
import 'package:agriproduce/constant/appLogger.dart';
import 'package:agriproduce/constant/httpError.dart';
import 'package:agriproduce/constant/config.dart';
import 'package:agriproduce/state_management/token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Fetch token from Riverpod
String fetchToken(WidgetRef ref) {
  final token = ref.read(tokenProvider);
  if (token == null) {
    AppLogger.logError('❌ No token, user not authenticated');
    throw Exception('User not authenticated');
  }
  return token;
}

/// Build headers with optional JSON content type
Map<String, String> buildHeaders(String token, {bool json = true}) => {
      if (json) 'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

/// 🔹 Generic API request handler
Future<http.Response> apiRequest(
  WidgetRef ref, {
  required String method,
  required String endpoint,
  Map<String, dynamic>? body,
  bool json = true,
}) async {
  final token = fetchToken(ref);
  final url = Uri.parse('${Config.baseUrl}$endpoint');

  final headers = buildHeaders(token, json: json);

  late http.Response response;

  switch (method.toUpperCase()) {
    case 'GET':
      response = await http.get(url, headers: headers);
      break;
    case 'POST':
      response = await http.post(url, headers: headers, body: jsonEncode(body));
      break;
    case 'PUT':
      response = await http.put(url, headers: headers, body: jsonEncode(body));
      break;
    case 'PATCH':
      response = await http.patch(url, headers: headers, body: jsonEncode(body));
      break;
    case 'DELETE':
      response = await http.delete(url, headers: headers);
      break;
    default:
      throw Exception('Unsupported HTTP method: $method');
  }

  HttpErrorHandler.handleResponse(response, '$method $endpoint');
  return response;
}

/// 🔹 Shorthand helpers for readability (optional)
Future<http.Response> apiGet(WidgetRef ref, String endpoint, {bool json = false}) =>
    apiRequest(ref, method: 'GET', endpoint: endpoint, json: json);

Future<http.Response> apiPost(WidgetRef ref, String endpoint, Map<String, dynamic> body) =>
    apiRequest(ref, method: 'POST', endpoint: endpoint, body: body);

Future<http.Response> apiPut(WidgetRef ref, String endpoint, Map<String, dynamic> body) =>
    apiRequest(ref, method: 'PUT', endpoint: endpoint, body: body);

Future<http.Response> apiPatch(WidgetRef ref, String endpoint, Map<String, dynamic> body) =>
    apiRequest(ref, method: 'PATCH', endpoint: endpoint, body: body);

Future<http.Response> apiDelete(WidgetRef ref, String endpoint) =>
    apiRequest(ref, method: 'DELETE', endpoint: endpoint, json: false);
