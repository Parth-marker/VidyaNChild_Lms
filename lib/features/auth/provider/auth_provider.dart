import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //Sign up w/ email and password
  Future<bool> signUp(String email, String password) async {
    try {
     final res =  await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      if(res.user!=null){
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
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return null;
    }
    on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}