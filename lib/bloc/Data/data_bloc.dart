import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

class DataCubit extends Cubit<AllUserData?> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  AllUserData? _userData;
  StreamSubscription? _budgetSubscription;
  StreamSubscription? _expenseSubscription;
  String? _currentExpenseBudgetId;

  DataCubit({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(null) {
    if (_auth.currentUser != null) {
      fetchFirebaseUserData();
      listenToBudgetChanges();
    }
  }

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    _expenseSubscription?.cancel();
    _currentExpenseBudgetId = null;
    return super.close();
  }

  DataCubit.testable(this._auth, this._firestore) : super(null);

  Future<AllUserData?> fetchFirebaseUserData() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) return null;

      // Fetch user document
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print("No user data found");
        return null;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Fetch all budgets for the user
      QuerySnapshot budgetSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('budgets')
              .get();

      List<Budget> budgets = [];

      for (var budgetDoc in budgetSnapshot.docs) {
        Map<String, dynamic> budgetData =
            budgetDoc.data() as Map<String, dynamic>;

        // Fetch all entries for this budget
        QuerySnapshot entriesSnapshot =
            await budgetDoc.reference.collection('expenses').get();

        List<Expense> expenses =
            entriesSnapshot.docs.map((entryDoc) {
              return Expense.fromFirestore(
                entryDoc.data() as Map<String, dynamic>,
              );
            }).toList();

        budgets.add(Budget.fromFirestore(budgetData, expenses));
      }
      _userData = AllUserData.fromFirestore(userData, budgets);
      emit(_userData);
      return _userData;
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  AllUserData? getFirebaseUserData() {
    return _userData;
  }

  Future<bool> addBudget(Budget budget) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budget.id)
          .set(budget.toFirestore())
          .timeout(Duration(seconds: 5));

      //_addBudgetOnLocalCopy(budget);

      print("Budget added with ID: ${budget.id}");
      return true;
    } catch (e) {
      print("Error adding budget: $e");
      return false;
    }
  }

  bool _addBudgetOnLocalCopy(Budget budget) {
    if (_userData == null) return false;

    final updatedBudgets = List<Budget>.from(_userData!.budgets)..add(budget);
    _userData = _userData!.copyWith(budgets: updatedBudgets);
    emit(_userData);
    return true;
  }

  Future<bool> updateBudget(
    String budgetId, {
    String? name,
    String? category,
    double? alertThreshold,
    String? resetPeriod,
    double? totalAmount,
  }) async {
    try {
      if (name != null && name.trim().isEmpty) {
        throw Exception("Budget name cannot be empty");
      }

      if (category != null && category.trim().isEmpty) {
        throw Exception("Category cannot be empty");
      }

      if (alertThreshold != null && alertThreshold < 0) {
        throw Exception("Alert threshold must be greater than zero");
      }

      if (totalAmount != null && totalAmount < 0) {
        throw Exception("Total amount must be greater than zero");
      }

      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      // Find the existing budget in local state
      Budget? existingBudget = _userData?.budgets.firstWhere(
        (budget) => budget.id == budgetId,
        orElse: () => throw Exception("Budget not found $budgetId"),
      );

      if (existingBudget == null) {
        throw Exception("Budget with id $budgetId not found");
      }

      // Important -> Create a map of only the fields to be updated
      Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (category != null) updateData['category'] = category;
      if (alertThreshold != null) updateData['alertThreshold'] = alertThreshold;
      if (resetPeriod != null) updateData['resetPeriod'] = resetPeriod;
      if (totalAmount != null) updateData['totalAmount'] = totalAmount;

      // Don't do anything if no updates were provided
      if (updateData.isEmpty) return true;

      // Update the budget Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId)
          .update(updateData);

      _updateBudgetOnLocalCopy(budgetId, updateData);

      print("Budget updated with ID: $budgetId");
      return true;
    } catch (e) {
      print("Error updating budget: $e");
      return false;
    }
  }

  bool _updateBudgetOnLocalCopy(
    String budgetId,
    Map<String, dynamic> updateData,
  ) {
    if (_userData == null) return false;

    final updatedBudgets =
        _userData!.budgets.map((budget) {
          if (budget.id == budgetId) {
            return budget.copyWith(
              name: updateData['name'] as String? ?? budget.name,
              category: updateData['category'] as String? ?? budget.category,
              alertThreshold:
                  updateData['alertThreshold'] as double? ??
                  budget.alertThreshold,
              resetPeriod:
                  updateData['resetPeriod'] as String? ?? budget.resetPeriod,
              totalAmount:
                  updateData['totalAmount'] as double? ?? budget.totalAmount,
            );
          }
          return budget;
        }).toList();

    _userData = _userData!.copyWith(budgets: updatedBudgets);
    emit(_userData);
    return true;
  }

  Future<bool> deleteBudget(String budgetId) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      // Check if budget exists
      Budget? budgetToDelete = _userData?.budgets.firstWhere(
        (budget) => budget.id == budgetId,
        orElse: () => throw Exception("Budget not found $budgetId"),
      );

      if (budgetToDelete == null) {
        throw Exception("Budget not found");
      }

      // First, delete all expenses associated with this budget
      QuerySnapshot expensesSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('budgets')
              .doc(budgetId)
              .collection('expenses')
              .get();

      // Use a batch to delete all expenses first
      WriteBatch batch = _firestore.batch();
      for (var doc in expensesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Add the budget document deletion to the batch
      batch.delete(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('budgets')
            .doc(budgetId),
      );

      // Commit the batch
      await batch.commit();

      // Update local state
      _deleteBudgetFromLocalCopy(budgetId);

      print("Budget deleted with ID: $budgetId");
      return true;
    } catch (e) {
      print("Error deleting budget: $e");
      return false;
    }
  }

  bool _deleteBudgetFromLocalCopy(String budgetId) {
    if (_userData == null) return false;

    final updatedBudgets =
        _userData!.budgets.where((budget) => budget.id != budgetId).toList();

    _userData = _userData!.copyWith(budgets: updatedBudgets);
    emit(_userData);
    return true;
  }

  void listenToBudgetChanges() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _budgetSubscription?.cancel(); // avoid multiple listeners

    _budgetSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .snapshots()
        .listen((snapshot) async {
          try {
            final List<Budget> budgets = [];

            for (final doc in snapshot.docs) {
              final data = doc.data();
              final expensesSnapshot =
                  await doc.reference.collection('expenses').get();

              final expenses =
                  expensesSnapshot.docs.map((e) {
                    return Expense.fromFirestore(e.data());
                  }).toList();

              budgets.add(Budget.fromFirestore(data, expenses));
            }

            final userDoc =
                await _firestore.collection('users').doc(userId).get();
            final userData = userDoc.data();

            if (userData != null) {
              _userData = AllUserData.fromFirestore(userData, budgets);
              emit(_userData);
            }
          } catch (e) {
            print("Error in real-time budget stream: $e");
          }
        });
  }

  // Expense now ---------------------------------------

  Future<bool> addExpense(String budgetId, Expense expense) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      final expenseRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId)
          .collection('expenses')
          .doc(expense.id);

      await expenseRef.set(expense.toFirestore());

      //_addExpenseOnLocalCopy(budgetId, expense);

      print("Expense added with ID: ${expense.id}");
      return true;
    } catch (e) {
      print("Error adding expense: $e");
      return false;
    }
  }

  bool _addExpenseOnLocalCopy(String budgetId, Expense expense) {
    if (_userData == null) return false;

    final updatedBudgets =
        _userData!.budgets.map((b) {
          if (b.id == budgetId) {
            return b.copyWith(
              expenses: [...b.expenses, expense],
              spentAmount: b.spentAmount + expense.amount,
            );
          }
          return b;
        }).toList();

    _userData = _userData!.copyWith(budgets: updatedBudgets);
    emit(_userData);
    return true;
  }

  Future<bool> updateExpense(String budgetId, Expense updatedExpense) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      final budget = _userData?.budgets.firstWhere((b) => b.id == budgetId);
      final existingExpense = budget?.expenses.firstWhere(
        (e) => e.id == updatedExpense.id,
      );

      if (existingExpense == null) throw Exception("Expense not found");

      final expenseRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId)
          .collection('expenses')
          .doc(updatedExpense.id);

      await expenseRef.update(updatedExpense.toFirestore());

      //_updateExpenseOnLocalCopy(budgetId, updatedExpense);

      print("Expense updated with ID: ${updatedExpense.id}");
      return true;
    } catch (e) {
      print("Error updating expense: $e");
      return false;
    }
  }

  bool _updateExpenseOnLocalCopy(String budgetId, Expense updatedExpense) {
    if (_userData == null) return false;

    final updatedBudgets =
        _userData!.budgets.map((b) {
          if (b.id == budgetId) {
            final newExpenses =
                b.expenses.map((e) {
                  return e.id == updatedExpense.id ? updatedExpense : e;
                }).toList();

            final newSpentAmount = newExpenses.fold<double>(
              0,
              (sum, e) => sum + e.amount,
            );

            return b.copyWith(
              expenses: newExpenses,
              spentAmount: newSpentAmount,
            );
          }
          return b;
        }).toList();

    _userData = _userData!.copyWith(budgets: updatedBudgets);
    emit(_userData);
    return true;
  }

  Future<bool> deleteExpense(String budgetId, String expenseId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      final budget = _userData?.budgets.firstWhere((b) => b.id == budgetId);
      final expenseToDelete = budget?.expenses.firstWhere(
        (e) => e.id == expenseId,
      );

      if (expenseToDelete == null) throw Exception("Expense not found");

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId)
          .collection('expenses')
          .doc(expenseId)
          .delete();

      //_deleteExpenseFromLocalCopy(budgetId, expenseId);

      print("Expense deleted with ID: $expenseId");
      return true;
    } catch (e) {
      print("Error deleting expense: $e");
      return false;
    }
  }

  bool _deleteExpenseFromLocalCopy(String budgetId, String expenseId) {
    if (_userData == null) return false;

    final updatedBudgets =
        _userData!.budgets.map((b) {
          if (b.id == budgetId) {
            final newExpenses =
                b.expenses.where((e) => e.id != expenseId).toList();
            final newSpentAmount = newExpenses.fold<double>(
              0,
              (sum, e) => sum + e.amount,
            );
            return b.copyWith(
              expenses: newExpenses,
              spentAmount: newSpentAmount,
            );
          }
          return b;
        }).toList();

    _userData = _userData!.copyWith(budgets: updatedBudgets);
    emit(_userData);
    return true;
  }

  void listenToExpenseChanges(String budgetId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    if (_currentExpenseBudgetId == budgetId) return;

    _expenseSubscription?.cancel();
    _currentExpenseBudgetId = budgetId;

    _expenseSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(budgetId)
        .collection('expenses')
        .snapshots()
        .listen((snapshot) async {
          try {
            final newExpenses =
                snapshot.docs.map((e) {
                  return Expense.fromFirestore(e.data());
                }).toList();

            final newSpent = newExpenses.fold<double>(
              0,
              (sum, e) => sum + e.amount,
            );

            final updatedBudgets =
                _userData!.budgets.map((b) {
                  if (b.id == budgetId) {
                    return b.copyWith(
                      expenses: newExpenses,
                      spentAmount: newSpent,
                    );
                  }
                  return b;
                }).toList();

            _userData = _userData!.copyWith(budgets: updatedBudgets);
            emit(_userData);

            // 🔄 Check current stored spentAmount
            final budgetDoc =
                await _firestore
                    .collection('users')
                    .doc(userId)
                    .collection('budgets')
                    .doc(budgetId)
                    .get();

            final currentSpent =
                (budgetDoc.data()?['spentAmount'] ?? 0).toDouble();

            if ((currentSpent - newSpent).abs() > 0.01) {
              await _firestore
                  .collection('users')
                  .doc(userId)
                  .collection('budgets')
                  .doc(budgetId)
                  .update({'spentAmount': newSpent});
            }
          } catch (e) {
            print("Error in real-time expense stream: $e");
          }
        });
  }
}
