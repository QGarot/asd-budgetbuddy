import 'package:budgetbuddy/bloc/Data/data_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../mockito/mock_classes.mocks.dart';

void main() {
  group('DataCubit', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockUser mockUser;
    late MockDocumentSnapshot<Map<String, dynamic>> mockUserDoc;
    late MockCollectionReference<Map<String, dynamic>> mockUsersCol;
    late MockDocumentReference<Map<String, dynamic>> mockUserDocRef;
    late MockCollectionReference<Map<String, dynamic>> mockBudgetsCol;
    late MockQuerySnapshot<Map<String, dynamic>> mockBudgetsQuery;
    late MockQueryDocumentSnapshot<Map<String, dynamic>> mockBudgetDoc;
    late MockCollectionReference<Map<String, dynamic>> mockExpensesCol;
    late MockQuerySnapshot<Map<String, dynamic>> mockExpensesQuery;
    late MockQueryDocumentSnapshot<Map<String, dynamic>> mockExpenseDoc;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();
      mockUserDoc = MockDocumentSnapshot();
      mockUsersCol = MockCollectionReference();
      mockUserDocRef = MockDocumentReference();
      mockBudgetsCol = MockCollectionReference();
      mockBudgetsQuery = MockQuerySnapshot();
      mockBudgetDoc = MockQueryDocumentSnapshot();
      mockExpensesCol = MockCollectionReference();
      mockExpensesQuery = MockQuerySnapshot();
      mockExpenseDoc = MockQueryDocumentSnapshot();
    });

    test(
      'fetchFirebaseUserData emits AllUserData with nested budgets and expenses',
      () async {
        // Mock FirebaseAuth
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('uid123');

        // Mock user document lookup
        when(mockFirestore.collection('users')).thenReturn(mockUsersCol);
        when(mockUsersCol.doc('uid123')).thenReturn(mockUserDocRef);
        when(mockUserDocRef.get()).thenAnswer((_) async => mockUserDoc);
        when(mockUserDoc.exists).thenReturn(true);
        when(mockUserDoc.data()).thenReturn({
          'username': 'JohnDoe',
          'email': 'john@example.com',
          'createdAt': Timestamp.now(),
        });

        // Mock budgets collection
        when(mockUserDocRef.collection('budgets')).thenReturn(mockBudgetsCol);
        when(mockBudgetsCol.get()).thenAnswer((_) async => mockBudgetsQuery);
        when(mockBudgetsQuery.docs).thenReturn([mockBudgetDoc]);
        when(mockBudgetDoc.data()).thenReturn({
          'id': 'b1',
          'name': 'Test Budget',
          'category': 'General',
          'alertThreshold': 100,
          'totalAmount': 1000,
          'spentAmount': 0,
        });

        // Mock expenses collection
        when(mockBudgetDoc.reference).thenReturn(mockUserDocRef);
        when(mockUserDocRef.collection('expenses')).thenReturn(mockExpensesCol);
        when(mockExpensesCol.get()).thenAnswer((_) async => mockExpensesQuery);
        when(mockExpensesQuery.docs).thenReturn([mockExpenseDoc]);
        when(mockExpenseDoc.data()).thenReturn({
          'id': 'e1',
          'merchant': 'Coffee',
          'amount': 3.5,
          'date': Timestamp.now(),
          'notes': '',
        });

        // Create cubit
        final cubit = DataCubit(auth: mockAuth, firestore: mockFirestore);

        final result = await cubit.fetchFirebaseUserData();

        expect(result, isNotNull);
        expect(result!.email, 'john@example.com');
        expect(result.username, 'JohnDoe');
        expect(result.budgets.length, 1);
        expect(result.budgets.first.name, 'Test Budget');
        expect(result.budgets.first.expenses.length, 1);
        expect(result.budgets.first.expenses.first.merchant, 'Coffee');
      },
    );
  });
}
