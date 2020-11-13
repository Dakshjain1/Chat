
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
static  String sharedLogINKey = "ISLOGGEDIN";
static  String sharedUserNameKey = "USERNAMEKEY";
static  String sharedUserEmailKey = "USERLOGINKEY";
static  String sharedUserIdKey = "USERIDKEY";

static  Future<bool> saveLogInSharedPreferences(bool isLoggedIn) async{
     SharedPreferences pref = await SharedPreferences.getInstance();
     pref.setBool(sharedLogINKey, isLoggedIn);

  }

static  Future saveUserNameSharedPreferences(String userName) async{
     SharedPreferences pref = await SharedPreferences.getInstance();
     pref.setString(sharedUserNameKey, userName);

  }

static  Future saveUserIdSharedPreferences(String userId) async{
     SharedPreferences pref = await SharedPreferences.getInstance();
     pref.setString(sharedUserIdKey, userId);

  }  

static  Future saveUserEmailSharedPreferences(String email) async{
     SharedPreferences pref = await SharedPreferences.getInstance();
     pref.setString(sharedUserEmailKey, email);

  }

static  Future<bool> getLogInSharedPreferences() async{
     SharedPreferences pref = await SharedPreferences.getInstance();
     return pref.getBool(sharedLogINKey) ?? false;

  }

static  Future<String> getUserNameSharedPreferences() async{
     SharedPreferences pref = await SharedPreferences.getInstance();
     return pref.getString(sharedUserNameKey) ?? " ";

  }

static  Future<String> getUserIdSharedPreferences() async{
     SharedPreferences pref = await SharedPreferences.getInstance();
     return pref.getString(sharedUserIdKey) ?? " ";

  }  


static  Future<String> getUserEmailSharedPreferences() async{
     SharedPreferences pref = await SharedPreferences.getInstance();
     return pref.getString(sharedUserEmailKey) ?? " ";

  }

}