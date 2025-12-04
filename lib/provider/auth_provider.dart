import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


final _fireAuth = FirebaseAuth.instance;
class AuthProvider extends ChangeNotifier{
  /// Kirim email reset password ke [enteredEmail]
  Future<void> sendPasswordResetEmail(BuildContext context) async {
    if (enteredEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan email terlebih dahulu!'), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      await _fireAuth.sendPasswordResetEmail(email: enteredEmail);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email reset password telah dikirim!'), backgroundColor: Colors.green),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim email: \\${e.message}'), backgroundColor: Colors.red),
      );
    }
  }

  final form = GlobalKey<FormState>();

  var islogin = true;
  var enteredEmail = '';
  var enteredPassword = '';
  
  void submit() async{
    final isvalid = form.currentState!.validate();

    if(!isvalid){
      return;
    }

    form.currentState!.save();

    try{
      if(islogin){
        final UserCredential = await _fireAuth.signInWithEmailAndPassword(email: enteredEmail, password: enteredPassword);
      }else{
        final UserCredential = await _fireAuth.createUserWithEmailAndPassword(email: enteredEmail, password: enteredPassword);
      }
    }catch(e){
      if(e is FirebaseAuthException){
        if(e.code == 'email-sudah-terdaftar' ){
          print("email sudah terdaftar");
        }
      }
    }


    notifyListeners();
  }

}