import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth authc = FirebaseAuth.instance;
  Future signUpwithEmailandPassword(String email,String password) async {
    try{
      var user = await  authc.createUserWithEmailAndPassword(email: email, password: password);   
      return user.user;
    }
    catch(e){
      print(e);
      return null;
    }
  }

  Future signInwithEmailandPassword(String email,String password) async {
    try{
      var user = await  authc.signInWithEmailAndPassword(email: email, password: password);   
      return user.user;
    }
    catch(e){
      print(e);
      return null;
    }
  }

  Future signOut() async{
   await authc.signOut().then((value) {
     return value;
   });
  }
}