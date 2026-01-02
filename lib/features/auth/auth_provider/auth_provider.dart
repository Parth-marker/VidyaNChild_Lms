import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //Sign up w/ email and password
  Future<bool> signUp(String name, String email, String password, String accountType) async {
    try {
     final res =  await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      if(res.user!=null){
        await FirebaseFirestore.instance.collection('users').doc(res.user!.uid).set({
          'name': name,
          'email': email,
          'accountType': accountType,
          'createdAt': Timestamp.now(),
        });
        return true;
      }
      return false;
    }
    on FirebaseAuthException catch (e) {
      print(e.message);
      return false;
    }
  }

  //Login w/ email and password
  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      // Notify listeners to ensure UI updates immediately
      notifyListeners();
      return true;
    }
    on FirebaseAuthException catch (e) {
      return false;
    }
  }

  //Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  //Get account type from Firestore
  Future<String?> getAccountType(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data()?['accountType'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting account type: $e');
      return null;
    }
  }
}