import 'package:agriproduce/data_models/transaction_model.dart'; // Import the Transaction model
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agriproduce/services/transaction_service.dart'; // Import the TransactionService

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super([]);

  final TransactionService _transactionService = TransactionService();

  // Method to fetch transactions along with the user names
  Future<void> fetchTransactions(WidgetRef ref) async {
    try {
      final transactions = await _transactionService.getTransactions(ref);

      // Directly update the userName from the fetched transaction data
      for (var transaction in transactions) {
        if (transaction.userName == null) {
          transaction.userName =
              'Unknown User'; // Fallback for missing user info
        }
      }

      // Update state with fetched transactions
      state = transactions;
    } catch (e) {
      print('Error fetching transactions: $e'); // Log error
      throw Exception('Failed to load transactions: $e');
    }
  }

  // Method to add a transaction
  Future<void> addTransaction(WidgetRef ref, Transaction transaction) async {
    try {
      await _transactionService.createTransaction(ref, transaction);
      await fetchTransactions(ref); // Refresh the transaction list
    } catch (e) {
      print('Error adding transaction: $e'); // Log error
      throw Exception('Failed to add transaction: $e');
    }
  }

  // Method to delete a transaction
  Future<void> deleteTransaction(WidgetRef ref, String id) async {
    try {
      await _transactionService.deleteTransaction(ref, id);
      await fetchTransactions(ref); // Refresh the transaction list
    } catch (e) {
      print('Error deleting transaction: $e'); // Log error
      throw Exception('Failed to delete transaction: $e');
    }
  }
}

// Create a Riverpod provider for TransactionNotifier
final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  return TransactionNotifier();
});
