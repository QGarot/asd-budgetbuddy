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

  DataCubit({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(null) {
    if (_auth.currentUser != null) {
      fetchFirebaseUserData();
      listenToBudgetChanges();
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

  AllUserData? getFirebaseUserData() {
    return _userData;
  }

  // This Function is here to always have real time user Budget Info
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

          final expenses = expensesSnapshot.docs.map((e) {
            return Expense.fromFirestore(e.data());
          }).toList();

          budgets.add(Budget.fromFirestore(data, expenses));
        }

        final userDoc = await _firestore.collection('users').doc(userId).get();
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

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    return super.close();
  }

}
