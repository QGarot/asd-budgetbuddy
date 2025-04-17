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
    late MockQuerySnapshot<Map<String, dynamic>> mockSnapshotForStream;

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
      mockSnapshotForStream = MockQuerySnapshot();

      when(
        mockBudgetsCol.snapshots(
          includeMetadataChanges: anyNamed('includeMetadataChanges'),
          source: anyNamed('source'),
        ),
      ).thenAnswer((_) => Stream.value(mockSnapshotForStream));
      when(mockSnapshotForStream.docs).thenReturn([mockBudgetDoc]);

      when(
        mockUserDocRef.snapshots(
          includeMetadataChanges: anyNamed('includeMetadataChanges'),
          source: anyNamed('source'),
        ),
      ).thenAnswer((_) => Stream.fromIterable([mockUserDoc]));
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

        // Stub snapshots for listenToBudgetChanges
        when(
          mockBudgetsCol.snapshots(
            includeMetadataChanges: anyNamed('includeMetadataChanges'),
            source: anyNamed('source'),
          ),
        ).thenAnswer((_) => Stream.value(mockSnapshotForStream));
        when(mockSnapshotForStream.docs).thenReturn([mockBudgetDoc]);

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

    test('updateBudget updates budget in Firestore and local state', () async {
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

      final mockBudgetDocRef = MockDocumentReference<Map<String, dynamic>>();
      when(mockBudgetsCol.doc('b1')).thenReturn(mockBudgetDocRef);
      when(mockBudgetDocRef.update(any)).thenAnswer((_) async => {});

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
      expect(result.budgets.first.id, 'b1');

      bool updatingBudgetRes = await cubit.updateBudget(
        result.budgets.first.id,
        name: 'Updated Name',
        category: 'Updated Category',
      );

      // Verify the return status of updating operation
      expect(updatingBudgetRes, true);

      // Verify Firestore was updated with correct parameters
      verify(
        mockBudgetDocRef.update({
          'name': 'Updated Name',
          'category': 'Updated Category',
        }),
      ).called(1);

      // Verify local state was updated
      final updatedState = cubit.state;
      expect(updatedState?.budgets.first.name, 'Updated Name');
      expect(updatedState?.budgets.first.category, 'Updated Category');
    });

    test(
      'deleteBudget removes budget from Firestore and local state',
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
        when(mockExpenseDoc.reference).thenReturn(mockUserDocRef);

        // Mock the specific path for budget document
        final mockBudgetDocRef = MockDocumentReference<Map<String, dynamic>>();
        when(mockBudgetsCol.doc('b1')).thenReturn(mockBudgetDocRef);

        // Mock the expenses collection for the budget document
        final mockBudgetExpensesCol =
            MockCollectionReference<Map<String, dynamic>>();
        when(
          mockBudgetDocRef.collection('expenses'),
        ).thenReturn(mockBudgetExpensesCol);
        when(
          mockBudgetExpensesCol.get(),
        ).thenAnswer((_) async => mockExpensesQuery);

        // Mock batch operations for delete
        final mockWriteBatch = MockWriteBatch();
        when(mockFirestore.batch()).thenReturn(mockWriteBatch);
        when(mockWriteBatch.delete(any)).thenReturn(mockWriteBatch);
        when(mockWriteBatch.commit()).thenAnswer((_) async => {});

        // Create cubit and fetch data
        final cubit = DataCubit(auth: mockAuth, firestore: mockFirestore);
        final result = await cubit.fetchFirebaseUserData();

        // Verify initial state
        expect(result, isNotNull);
        expect(result!.budgets.length, 1);
        expect(result.budgets.first.id, 'b1');

        // Call the delete method
        bool deleteBudgetRes = await cubit.deleteBudget('b1');

        // Verify the return status
        expect(deleteBudgetRes, true);

        // Verify batch operations were called
        verify(mockFirestore.batch()).called(1);
        verify(
          mockWriteBatch.delete(any),
        ).called(2); // Once for the expense, once for the budget
        verify(mockWriteBatch.commit()).called(1);

        // Verify local state was updated (budget removed)
        final finalState = cubit.state;
        expect(finalState?.budgets.length, 0);
      },
    );
  });
}
