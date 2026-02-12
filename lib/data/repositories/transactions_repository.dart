import 'package:hive_ce/hive.dart';
import '../models/transaction.dart';

class TransactionsRepository {
  final Box<Transaction> _box;

  TransactionsRepository(this._box);

  List<Transaction> getAllTransactions() {
    return _box.values.toList();
  }

  List<Transaction> getTransactionsByGroup(String groupId) {
    return _box.values.where((t) => t.groupId == groupId).toList();
  }

  Future<void> saveTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final Map<String, Transaction> data = {
      for (var t in transactions) t.id: t
    };
    await _box.putAll(data);
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }

  Stream<BoxEvent> watchTransactions() {
    return _box.watch();
  }
}
