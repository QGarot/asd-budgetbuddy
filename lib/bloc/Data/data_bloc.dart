import 'package:budgetbuddy/pojos/user_data.dart';
import 'package:budgetbuddy/pojos/budget.dart';
import 'package:budgetbuddy/pojos/expenses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataCubit extends Cubit<AllUserData?> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  AllUserData? _userData;

  DataCubit({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(null) {
    if (_auth.currentUser != null) {
      fetchFirebaseUserData();
    }
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

      _addBudgetOnLocalCopy(budget);

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

  Future<bool> addExpense(String budgetId, Expense expense) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId)
          .collection('expenses')
          .doc(expense.id)
          .set(expense.toFirestore());

      _addExpenseOnLocalCopy(budgetId, expense);

      print("Expense added to budget $budgetId");
      return true;
    } catch (e) {
      print("Error adding expense: $e");
      return false;
    }
  }

  bool _addExpenseOnLocalCopy(String budgetId, Expense expense) {
    if (_userData == null) return false;

    Budget? budget = _userData?.budgets.firstWhere(
      (element) => element.id == budgetId,
    );

    if (budget == null) return false;

    List<Budget> updatedBudgets =
        _userData!.budgets.map((b) {
          if (b.id == budgetId) {
            return b.copyWith(
              spentAmount: b.spentAmount + expense.amount,
              expenses: [...b.expenses, expense.copyWith()],
            );
          }
          return b;
        }).toList();

    _userData = _userData?.copyWith(budgets: updatedBudgets);

    emit(_userData);
    return true;
  }

  Future<bool> updateBudget(
    String budgetId, {
    String? name,
    String? category,
    double? alertThreshold
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

  bool _updateBudgetOnLocalCopy(String budgetId, Map<String, dynamic> updateData) {
    if (_userData == null) return false;

    final updatedBudgets = _userData!.budgets.map((budget) {
      if (budget.id == budgetId) {
        return budget.copyWith(
          name: updateData['name'] as String? ?? budget.name,
          category: updateData['category'] as String? ?? budget.category,
          alertThreshold: updateData['alertThreshold'] as double? ?? budget.alertThreshold,
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
      QuerySnapshot expensesSnapshot = await _firestore
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
      batch.delete(_firestore
          .collection('users')
          .doc(userId)
          .collection('budgets')
          .doc(budgetId));
      
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

    final updatedBudgets = _userData!.budgets.where((budget) => 
      budget.id != budgetId
    ).toList();
    
    _userData = _userData!.copyWith(budgets: updatedBudgets);
    emit(_userData);
    return true;
  }

  AllUserData? getFirebaseUserData() {
    return _userData;
  }
}
