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
        final now = Timestamp.fromDate(DateTime(2025, 4, 10));

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('uid123');

        when(mockFirestore.collection('users')).thenReturn(mockUsersCol);
        when(mockUsersCol.doc('uid123')).thenReturn(mockUserDocRef);
        when(mockUserDocRef.get()).thenAnswer((_) async => mockUserDoc);
        when(mockUserDoc.exists).thenReturn(true);
        when(mockUserDoc.data()).thenReturn({
          'username': 'JohnDoe',
          'email': 'john@example.com',
          'createdAt': now,
        });

        when(mockUserDocRef.collection('budgets')).thenReturn(mockBudgetsCol);
        when(mockBudgetsCol.get()).thenAnswer((_) async => mockBudgetsQuery);
        when(mockBudgetsQuery.docs).thenReturn([mockBudgetDoc]);
        when(mockBudgetDoc.data()).thenReturn({
          'id': 'b1',
          'name': 'Test Budget',
          'category': 'General',
          'createdAt': now,
          'alertThreshold': 100,
          'totalAmount': 1000,
          'spentAmount': 0,
        });

        when(mockBudgetDoc.reference).thenReturn(mockUserDocRef);
        when(mockUserDocRef.collection('expenses')).thenReturn(mockExpensesCol);
        when(mockExpensesCol.get()).thenAnswer((_) async => mockExpensesQuery);
        when(mockExpensesQuery.docs).thenReturn([mockExpenseDoc]);
        when(mockExpenseDoc.data()).thenReturn({
          'id': 'e1',
          'merchant': 'Coffee',
          'amount': 3.5,
          'createdAt': now,
          'notes': '',
        });

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
      final now = Timestamp.fromDate(DateTime(2025, 4, 10));

      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('uid123');

      when(mockFirestore.collection('users')).thenReturn(mockUsersCol);
      when(mockUsersCol.doc('uid123')).thenReturn(mockUserDocRef);
      when(mockUserDocRef.get()).thenAnswer((_) async => mockUserDoc);
      when(mockUserDoc.exists).thenReturn(true);
      when(mockUserDoc.data()).thenReturn({
        'username': 'JohnDoe',
        'email': 'john@example.com',
        'createdAt': now,
      });

      when(mockUserDocRef.collection('budgets')).thenReturn(mockBudgetsCol);
      when(mockBudgetsCol.get()).thenAnswer((_) async => mockBudgetsQuery);
      when(mockBudgetsQuery.docs).thenReturn([mockBudgetDoc]);
      when(mockBudgetDoc.data()).thenReturn({
        'id': 'b1',
        'name': 'Test Budget',
        'category': 'General',
        'createdAt': now,
        'alertThreshold': 100,
        'totalAmount': 1000,
        'spentAmount': 0,
      });

      when(mockBudgetDoc.reference).thenReturn(mockUserDocRef);
      when(mockUserDocRef.collection('expenses')).thenReturn(mockExpensesCol);
      when(mockExpensesCol.get()).thenAnswer((_) async => mockExpensesQuery);
      when(mockExpensesQuery.docs).thenReturn([mockExpenseDoc]);
      when(mockExpenseDoc.data()).thenReturn({
        'id': 'e1',
        'merchant': 'Coffee',
        'amount': 3.5,
        'createdAt': now,
        'notes': '',
      });

      final mockBudgetDocRef = MockDocumentReference<Map<String, dynamic>>();
      when(mockBudgetsCol.doc('b1')).thenReturn(mockBudgetDocRef);
      when(mockBudgetDocRef.update(any)).thenAnswer((_) async => {});

      final cubit = DataCubit(auth: mockAuth, firestore: mockFirestore);

      final result = await cubit.fetchFirebaseUserData();

      expect(result, isNotNull);

      bool updatingBudgetRes = await cubit.updateBudget(
        result!.budgets.first.id,
        name: 'Updated Name',
        category: 'Updated Category',
      );

      expect(updatingBudgetRes, true);

      verify(
        mockBudgetDocRef.update({
          'name': 'Updated Name',
          'category': 'Updated Category',
        }),
      ).called(1);

      final updatedState = cubit.state;
      expect(updatedState?.budgets.first.name, 'Updated Name');
      expect(updatedState?.budgets.first.category, 'Updated Category');
    });

    test(
      'deleteBudget removes budget from Firestore and local state',
      () async {
        final now = Timestamp.fromDate(DateTime(2025, 4, 10));

        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('uid123');

        when(mockFirestore.collection('users')).thenReturn(mockUsersCol);
        when(mockUsersCol.doc('uid123')).thenReturn(mockUserDocRef);
        when(mockUserDocRef.get()).thenAnswer((_) async => mockUserDoc);
        when(mockUserDoc.exists).thenReturn(true);
        when(mockUserDoc.data()).thenReturn({
          'username': 'JohnDoe',
          'email': 'john@example.com',
          'createdAt': now,
        });

        when(mockUserDocRef.collection('budgets')).thenReturn(mockBudgetsCol);
        when(mockBudgetsCol.get()).thenAnswer((_) async => mockBudgetsQuery);
        when(mockBudgetsQuery.docs).thenReturn([mockBudgetDoc]);
        when(mockBudgetDoc.data()).thenReturn({
          'id': 'b1',
          'name': 'Test Budget',
          'category': 'General',
          'createdAt': now,
          'alertThreshold': 100,
          'totalAmount': 1000,
          'spentAmount': 0,
        });

        when(mockBudgetDoc.reference).thenReturn(mockUserDocRef);
        when(mockUserDocRef.collection('expenses')).thenReturn(mockExpensesCol);
        when(mockExpensesCol.get()).thenAnswer((_) async => mockExpensesQuery);
        when(mockExpensesQuery.docs).thenReturn([mockExpenseDoc]);
        when(mockExpenseDoc.data()).thenReturn({
          'id': 'e1',
          'merchant': 'Coffee',
          'amount': 3.5,
          'createdAt': now,
          'notes': '',
        });
        when(mockExpenseDoc.reference).thenReturn(mockUserDocRef);

        final mockBudgetDocRef = MockDocumentReference<Map<String, dynamic>>();
        when(mockBudgetsCol.doc('b1')).thenReturn(mockBudgetDocRef);

        final mockBudgetExpensesCol =
            MockCollectionReference<Map<String, dynamic>>();
        when(
          mockBudgetDocRef.collection('expenses'),
        ).thenReturn(mockBudgetExpensesCol);
        when(
          mockBudgetExpensesCol.get(),
        ).thenAnswer((_) async => mockExpensesQuery);

        final mockWriteBatch = MockWriteBatch();
        when(mockFirestore.batch()).thenReturn(mockWriteBatch);
        // ignore: void_checks
        when(mockWriteBatch.delete(any)).thenReturn(mockWriteBatch);
        when(mockWriteBatch.commit()).thenAnswer((_) async => {});

        final cubit = DataCubit(auth: mockAuth, firestore: mockFirestore);
        final result = await cubit.fetchFirebaseUserData();

        expect(result, isNotNull);
        expect(result!.budgets.length, 1);

        bool deleteBudgetRes = await cubit.deleteBudget('b1');

        expect(deleteBudgetRes, true);

        verify(mockFirestore.batch()).called(1);
        verify(mockWriteBatch.delete(any)).called(2);
        verify(mockWriteBatch.commit()).called(1);

        final finalState = cubit.state;
        expect(finalState?.budgets.length, 0);
      },
    );
  });
}
