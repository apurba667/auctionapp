
import 'package:auctionapp/screens/bottom_nav_bar.dart';
import 'package:auctionapp/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/show_snack_bar.dart';

class FirebaseAuthMethods {
  final FirebaseAuth _auth;

  FirebaseAuthMethods(this._auth);

  //Email Sign up
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await sendEmailVerificaton(context);
    }on FirebaseAuthException catch (err) {

      showSnackBar(context, err.message!);
    }
  }

  // EMAIL LOGIN
  Future<void> loginWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!_auth.currentUser!.emailVerified) {
        await sendEmailVerificaton(context);
        // restrict access to certain things using provider
        // transition to another page instead of home screen
      }
      else if(_auth.currentUser!.emailVerified){
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>BottomNavBarScreen()));
      }
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!); // Displaying the error message
    }
  }

  //Email Verification
  Future<void>sendEmailVerificaton(BuildContext context)async{
    try{
      _auth.currentUser!.sendEmailVerification();
      showSnackBar(context, "Email verification sent!");
      Navigator.of(context).pop();
    }on FirebaseAuthException catch(err){
      showSnackBar(context, err.message!);

    }
  }

}
