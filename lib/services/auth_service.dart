import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// authService 부를 때마다 class AuthService에 접근 가능
ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth
      .currentUser; //현재 로그인된 사용자 UID 사용 가능 => authService.value.currentUser?.uid로 어디서든 uid 사용 가능

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signIn({
    //로그인 성공 시 내부적으로 Firebase의 currentUser 정보가 활성화
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    ); //password는 store에 저장하면 안됨, 추후에 authentic에서
  }

  //회원가입이 완료된 직수에 Firestore에 문서를 생성하게 설정
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    //return await _auth.createUserWithEmailAndPassword(
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    //회원가입 성공 후 Firestore의 users 컬랙션에 문서 생성(edit profile에서 수정가능한 정보들)
    await FirebaseFirestore.instance
        .collection('users')
        .doc(credential.user!.uid)
        .set({
          'email': email,
          'name': '', // 비어 있는 상태로 초기화 가능
          'country': '',
          'timestamp': FieldValue.serverTimestamp(),
        });
    return credential;
  }

  // 사용자 프로필이 완료되었는지 확인
  Future<bool> isProfileComplete() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (!doc.exists) return false;
      
      final data = doc.data();
      if (data == null) return false;
      
      // 이름이 비어있지 않으면 프로필이 완료된 것으로 간주
      final name = data['name']?.toString().trim() ?? '';
      return name.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking profile completion: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateUsername({required String username}) async {
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
