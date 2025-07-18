import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// authService 부를 때마다 class AuthService에 접근 가능
ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password);
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(
    {required String email,
    }) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({
    required String username,
  }) async {
    await _auth.currentUser!.updateDisplayName(username);
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    //delete()는  security sensitive operation이므로 credential로 reauthentication 필요
    await _auth.currentUser!.delete();
    await _auth.signOut();
  }

  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    //updatePassword는 security sensitive operation이므로 credential로 reauthentication 필요
    await _auth.currentUser!.updatePassword(newPassword);
  }

}