import 'dart:convert';
import 'package:agriproduce/data_models/transaction_model.dart';
import 'package:agriproduce/state_management/token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:agriproduce/constant/config.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Import to check internet connectivity

class TransactionService {
  final box = GetStorage();

  // LocalTransactionService: Handles local storage of transactions
  void saveTransaction(Transaction transaction) {
    if (transaction.id != null) {
      box.write(transaction.id!, transaction.toJson());
      print('Transaction saved locally: ${transaction.toJson()}');
    } else {
      print('Cannot save transaction: ID is null');
    }
  }

  List<Transaction> getAllTransactions() {
    final storedData = box.getValues().toList();
    if (storedData.isEmpty) {
      print('No transactions found in local storage.'); // Debug log
    }
    return storedData.map((data) {
      return Transaction.fromJson(Map<String, dynamic>.from(data));
    }).toList();
  }

  void deleteLocalTransaction(String id) {
    // Renamed to avoid conflict
    box.remove(id);
    print('Transaction deleted locally with id: $id'); // Debug log
  }

  // Method to fetch user name by user ID
  Future<String> fetchUserNameById(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['userName']?.toString() ??
            'Unknown User'; // Return user name
      } else {
        print('Error fetching user name: ${response.statusCode}');
        return 'Unknown User'; // Return fallback if user not found
      }
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Unknown User'; // Fallback if error occurs
    }
  }

  // Check for internet connectivity
  Future<bool> _isConnectedToInternet() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  // Method to create a transaction
  Future<void> createTransaction(WidgetRef ref, Transaction transaction) async {
    // Save locally first without an ID
    saveTransaction(transaction);
    print('Attempting to save transaction remotely: ${transaction.toJson()}');

    final token = ref.read(tokenProvider);
    if (token == null) {
      throw Exception('User not authenticated');
    }

    // Check internet connection
    final isConnected = await _isConnectedToInternet();
    if (!isConnected) {
      print('No internet connection. Saving transaction locally.');
      throw Exception('No internet connection');
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/transaction'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(transaction.toJson()
          ..remove('id')), // Exclude 'id' from the payload
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final savedTransaction = Transaction.fromJson(jsonResponse);

        // Save the transaction locally with the server-generated ID
        saveTransaction(savedTransaction);
        print(
            'Transaction saved remotely and locally with ID: ${savedTransaction.id}');
      } else {
        print(
            'Failed to save transaction remotely: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create transaction: ${response.body}');
      }
    } catch (e) {
      print('Error saving transaction remotely: $e');
      throw Exception('Error saving transaction: $e');
    }
  }

  // Method to get all transactions
  Future<List<Transaction>> getTransactions(WidgetRef ref) async {
  final token = ref.read(tokenProvider);
  if (token == null) {
    throw Exception('User not authenticated');
  }

  // Check for internet connection
  final isConnected = await _isConnectedToInternet();
  if (!isConnected) {
    print('No internet connection. Returning cached transactions.');
    // Return local transactions if no internet connection
    return getAllTransactions();
  }

  try {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/transaction'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Decode the response body directly into a list
      final List<dynamic> transactionList = jsonDecode(response.body);
      
      final transactions = transactionList.map<Transaction>((json) {
        var transaction = Transaction.fromJson(json);
        if (json['user'] != null) {
          transaction.userName = json['user']['name'] ?? 'Unknown User';
        }
        return transaction;
      }).toList();

      return transactions;
    } else {
      print('Error fetching transactions from server: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load transactions: ${response.body}');
    }
  } catch (e) {
    print('Error fetching transactions from server: $e');
    // Fallback to local data in case of error (e.g., no internet connection)
    return getAllTransactions();
  }
}

  // Method to update a transaction
  Future<void> updateTransaction(
      WidgetRef ref, String transactionId, Transaction transaction) async {
    // Save locally first
    saveTransaction(transaction);
    print(
        'Attempting to update transaction remotely with id: $transactionId - ${transaction.toJson()}');

    final token = ref.read(tokenProvider);
    if (token == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.put(
        Uri.parse('${Config.baseUrl}/transaction/$transactionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
            transaction.toJson()), // Use the Transaction's toJson method
      );

      if (response.statusCode != 200) {
        print(
            'Failed to update transaction remotely: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to update transaction: ${response.body}');
      }
    } catch (e) {
      print('Error updating transaction remotely: $e');
      throw Exception('Error updating transaction: $e');
    }
  }

  // Method to delete a transaction remotely
  Future<void> deleteTransaction(WidgetRef ref, String transactionId) async {
    // Always remove from local storage first
    deleteLocalTransaction(transactionId);
    print('Attempting to delete transaction remotely with id: $transactionId');

    final token = ref.read(tokenProvider);
    if (token == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await http.delete(
        Uri.parse('${Config.baseUrl}/transaction/$transactionId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        print(
            'Failed to delete transaction remotely: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to delete transaction: ${response.body}');
      }
    } catch (e) {
      print('Error deleting transaction remotely: $e');
      throw Exception('Error deleting transaction: $e');
    }
  }
}
