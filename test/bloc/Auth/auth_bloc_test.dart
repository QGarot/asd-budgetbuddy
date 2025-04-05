import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:budgetbuddy/bloc/Auth/auth_bloc.dart';
import 'package:budgetbuddy/pojos/user_auth.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Generate mocks for the required Firebase classes
@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  User,
  UserCredential,
  DocumentSnapshot,
  CollectionReference,
  DocumentReference,
  AuthCubit,
])
import 'auth_bloc_test.mocks.dart';

void main() {
  test('signIn emits user data when login is successful', () async {
    final mockAuth = MockFirebaseAuth();
    final mockFirestore = MockFirebaseFirestore();
    final mockUserCredential = MockUserCredential();
    final mockUser = MockUser();
    final mockCollection = MockCollectionReference<Map<String, dynamic>>();
    final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    // Login credentials
    final loginInfo = UserLoginInfo(email: 'test@example.com', password: 'password123');

    // Setup mocked behavior
    when(mockAuth.signInWithEmailAndPassword(
      email: anyNamed('email'),
      password: anyNamed('password'),
    )).thenAnswer((_) async => mockUserCredential);

    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('user123');
    when(mockUser.email).thenReturn('test@example.com');

    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    when(mockCollection.doc('user123')).thenReturn(mockDocRef);
    when(mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
    when(mockSnapshot.data()).thenReturn({'username': 'TestUser'});

    // Create cubit with mocked dependencies
    when(mockAuth.currentUser).thenReturn(null);
    final cubit = AuthCubit(auth: mockAuth, firestore: mockFirestore);

    await cubit.signIn(loginInfo);

    final result = cubit.state!;
    expect(result.uid, 'user123');
    expect(result.email, 'test@example.com');
    expect(result.username, 'TestUser');
  });

  test('signUp creates user and emits user data', () async {
  final mockAuth = MockFirebaseAuth();
  final mockFirestore = MockFirebaseFirestore();
  final mockUserCredential = MockUserCredential();
  final mockUser = MockUser();
  final mockCollection = MockCollectionReference<Map<String, dynamic>>();
  final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
  final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

  final registrationInfo = UserRegistrationInfo(
    email: 'newuser@example.com',
    password: 'securepassword',
    userName: 'Newbie',
  );

  // Mock sign-up flow
  when(mockAuth.createUserWithEmailAndPassword(
    email: anyNamed('email'),
    password: anyNamed('password'),
  )).thenAnswer((_) async => mockUserCredential);

  when(mockUserCredential.user).thenReturn(mockUser);
  when(mockUser.uid).thenReturn('newUser123');
  when(mockUser.email).thenReturn('newuser@example.com');

  // Mock Firestore doc creation and reading
  when(mockFirestore.collection('users')).thenReturn(mockCollection);
  when(mockCollection.doc('newUser123')).thenReturn(mockDocRef);
  when(mockDocRef.set(any)).thenAnswer((_) async => {});
  when(mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
  when(mockSnapshot.data()).thenReturn({'username': 'Newbie'});

  // Create cubit
  when(mockAuth.currentUser).thenReturn(null);
  final cubit = AuthCubit(auth: mockAuth, firestore: mockFirestore);

  await cubit.signUp(registrationInfo);

  final result = cubit.state!;
  expect(result.uid, 'newUser123');
  expect(result.email, 'newuser@example.com');
  expect(result.username, 'Newbie');
});

test('signIn handles login error gracefully', () async {
  final mockAuth = MockFirebaseAuth();
  final mockFirestore = MockFirebaseFirestore();

  final loginInfo = UserLoginInfo(
    email: 'wrong@example.com',
    password: 'badpass',
  );

  // Simulate failed login
  when(mockAuth.signInWithEmailAndPassword(
    email: anyNamed('email'),
    password: anyNamed('password'),
  )).thenThrow(FirebaseAuthException(code: 'user-not-found'));

  // Create cubit
  when(mockAuth.currentUser).thenReturn(null);
  final cubit = AuthCubit(auth: mockAuth, firestore: mockFirestore);

  await cubit.signIn(loginInfo);

  // Should still be null (no user)
  expect(cubit.state, isNull);
});

test('signOut clears user state and calls Firebase signOut', () async {
  final mockAuth = MockFirebaseAuth();
  final mockFirestore = MockFirebaseFirestore();
  final mockUserCredential = MockUserCredential();
  final mockUser = MockUser();
  final mockCollection = MockCollectionReference<Map<String, dynamic>>();
  final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
  final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

  // Setup: initial state
  when(mockAuth.currentUser).thenReturn(null);
  when(mockAuth.signOut()).thenAnswer((_) async => {});

  // Setup: login flow
  when(mockAuth.signInWithEmailAndPassword(
    email: anyNamed('email'),
    password: anyNamed('password'),
  )).thenAnswer((_) async => mockUserCredential);

  when(mockUserCredential.user).thenReturn(mockUser);
  when(mockUser.uid).thenReturn('u1');
  when(mockUser.email).thenReturn('e');

  when(mockFirestore.collection('users')).thenReturn(mockCollection);
  when(mockCollection.doc('u1')).thenReturn(mockDocRef);
  when(mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
  when(mockSnapshot.data()).thenReturn({'username': 'n'});

  final cubit = AuthCubit(auth: mockAuth, firestore: mockFirestore);

  // Real login
  await cubit.signIn(UserLoginInfo(email: 'test@example.com', password: 'password123'));

  expect(cubit.isLoggedIn(), isTrue);

  await cubit.signOut();

  expect(cubit.isLoggedIn(), isFalse);
  expect(cubit.state, isNull);

  verify(mockAuth.signOut()).called(1);
});

test('isLoggedIn returns true only when user is set', () async {
  final mockAuth = MockFirebaseAuth();
  final mockFirestore = MockFirebaseFirestore();
  final mockUserCredential = MockUserCredential();
  final mockUser = MockUser();
  final mockCollection = MockCollectionReference<Map<String, dynamic>>();
  final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
  final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

  when(mockAuth.currentUser).thenReturn(null);
  when(mockAuth.signInWithEmailAndPassword(
    email: anyNamed('email'),
    password: anyNamed('password'),
  )).thenAnswer((_) async => mockUserCredential);

  when(mockUserCredential.user).thenReturn(mockUser);
  when(mockUser.uid).thenReturn('u');
  when(mockUser.email).thenReturn('e');
  when(mockFirestore.collection('users')).thenReturn(mockCollection);
  when(mockCollection.doc('u')).thenReturn(mockDocRef);
  when(mockDocRef.get()).thenAnswer((_) async => mockSnapshot);
  when(mockSnapshot.data()).thenReturn({'username': 'n'});

  final cubit = AuthCubit(auth: mockAuth, firestore: mockFirestore);

  expect(cubit.isLoggedIn(), isFalse);

  await cubit.signIn(UserLoginInfo(email: 'test@example.com', password: 'password123'));

  expect(cubit.isLoggedIn(), isTrue);

  await cubit.signOut();

  expect(cubit.isLoggedIn(), isFalse);
});

}