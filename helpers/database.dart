import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_test/helpers/Username.dart';
import 'package:uuid/uuid.dart';

class DataService {
  var storage = FirebaseStorage.instance.ref();
  var fsconnect = FirebaseFirestore.instance;
/*
  getProfileImage(username) async{
    var user = await fsconnect.collection('users').doc(username).snapshots();
    try{
       
         if(user.data()['profile_url'] != null){
                 return  user.data()['profile_url'];
           
         
         }
         else{
         
           return 'https://raw.githubusercontent.com/juzer-patan/asset/master/download.png';
         
         }
       
     }
     catch(e){
                   print(e);
           return 'https://raw.githubusercontent.com/juzer-patan/asset/master/download.png';
       
     }
  }*/

  requestLocationShare(chatRoomId)async{
    await fsconnect.collection('chatrooms').doc(chatRoomId).update({
      'shareLocation' : {
        'requestBy' : Constants.myuid,
        'status' : "Requested",
      }
    }).catchError((e){
      print(e);
    });
  }
  
  enableLocationShare(chatRoomId)async{
    await fsconnect.collection('chatrooms').doc(chatRoomId).update({
      'shareLocation' : {
        'status' : "Enabled",
      }
    }).catchError((e){
      print(e);
    });
  }

  disableLocationShare(chatRoomId)async{
    await fsconnect.collection('chatrooms').doc(chatRoomId).update({
      'shareLocation' : {
        'status' : "Not Enabled",
      }
    }).catchError((e){
      print(e);
    });
  }
  addProfileImage(userid,path) async{
    String url;
    StorageTaskSnapshot uploading;
    var storage_ref = await storage.child("users").child(userid).child("profile_photo.jpg");
    
    uploading = await storage_ref.putFile(path).onComplete;
   if(uploading != null){
     print("progress");
     url = await storage_ref.getDownloadURL();
     if(url != null){
      print( "Url recieved");
      return url;
    }
  }
  }

  Future<String> addChatImage(chatRoomId,path,type) async {
    String url;
    StorageTaskSnapshot uploading;
    var uuid = Uuid();
    var uid = uuid.v1();
    var storage_ref =  storage.child("chatrooms").child(chatRoomId).child(uid+type);
  /*  var uploading = await storage_ref.putFile(path).onComplete.then((value) async{
        print(value);
        url = await storage_ref.getDownloadURL().then((value) {
        print( "Url : " +value);
        print(value.runtimeType);
        
      } );
    });
    if(url != null){
      print( "Url recieved: "+url);
      return url;
    }*/
   uploading = await storage_ref.putFile(path).onComplete;
   if(uploading != null){
     print("progress");
     url = await storage_ref.getDownloadURL();
     if(url != null){
      print( "Url recieved");
      return url;
    }

   }
    
    
  }

  updateLastActive(userId,bool isActive)async{
    print("Giving active");
    await fsconnect.collection('users').doc(userId).update({
      'active' : isActive,
    }).catchError((e){
      print(e);
    });
  }
  uploadProfileImage(userId,img_url) async{
     await fsconnect.collection('users').doc(userId).update({
       'profile_url' : img_url
     }).catchError((e) {
       print(e);
     });
  }
  
  updateUserInfo(userId,changeMap) async{
    return await fsconnect.collection('users').doc(userId).update(changeMap).catchError((e){
      print(e);
    });
  }
  Future addUserInfo(userData,uid) async {
    await  fsconnect.collection('users').doc(uid).set(userData);
  }

  Future getUserbyEmail(email) async{
   // QuerySnapshot any = await fsconnect.collection('users').where('email', isEqualTo: email).get();
  /*  fsconnect.collection('users').doc(username).update({
      'freiends' : FieldValue.arrayUnion()
    })*/
    return await fsconnect.collection('users').where('email', isEqualTo: email).get();

    

  }

  Future getUserbyName(userName) async{
   // QuerySnapshot any = await fsconnect.collection('users').where('email', isEqualTo: email).get();
  /*  fsconnect.collection('users').doc(username).update({
      'freiends' : FieldValue.arrayUnion()
    })*/
    return await fsconnect.collection('users').where('username', isEqualTo: userName).get();

    

  }

 Future<String> requestFriend(myuid,friendid) async{
    
     await fsconnect.collection('users').doc(friendid).update({
      'requests' : FieldValue.arrayUnion([myuid])
    }).then((value) { return value;});
  }
  addFriend(userId,otherId) async{
  // DocumentReference his_ref = fsconnect.collection('user').doc(othername);
    //DocumentReference my_ref = fsconnect.collection('users').doc(username);
    var my_friend = await fsconnect.collection('users').doc(userId).update({
      'friends' : FieldValue.arrayUnion([otherId]),

    }).catchError((e) {
      return "failed";
    });
    var his_friend = await fsconnect.collection('users').doc(otherId).update({
      'friends' : FieldValue.arrayUnion([userId])
    }).catchError((e) {
      return("failed");
    });

    var remove_friend = await fsconnect.collection('users').doc(userId).update({
       'requests' : FieldValue.arrayRemove([otherId])
     }).catchError((e){
       print(e);
     });
    
    return [my_friend,his_friend,remove_friend];

  }

  declineFriendRequest(userId,otherId) async{
    return await fsconnect.collection('users').doc(userId).update({
       'requests' : FieldValue.arrayRemove([otherId])
     }).catchError((e){
       print(e);
     });
  }

  userSnap(userid) async{
    return await fsconnect.collection('users').doc(userid).snapshots();
  }

  friendSnap(username) async{
    return await fsconnect.collection('users').where('username',isEqualTo: username).snapshots();
  }

   Future<bool> isFriend(username,other_name) async{
     
   var any = await fsconnect.collection('users').doc(username).get();
        var user =   any.id;
        return user.contains(other_name);
        //return user;
    
  }
  Future<DocumentSnapshot> getChatRoomLocation(chatRoomId) async{
   // DocumentSnapshot user;
    return await fsconnect.collection("chatrooms").doc(chatRoomId).get();
    
  }
  Future createChatRoom(chatRoomId,chatRoomMap) async {
    

    await fsconnect.collection('chatrooms').doc(chatRoomId).update(chatRoomMap).catchError((e) async{
      await fsconnect.collection('chatrooms').doc(chatRoomId).set(chatRoomMap).then((value) {
      return value;
    }); 
    });
  }

  getUserChats(chatRoomId) async{
    return await fsconnect.collection('chatrooms').doc(chatRoomId).collection('chats').snapshots();
  }

  Future<void> addMessage(chatRoomId,messageMap) async{
    await fsconnect.collection('chatrooms').doc(chatRoomId).collection('chats').add(messageMap).catchError((e){
      print(e.toString());
    });
    await fsconnect.collection('chatrooms').doc(chatRoomId).update({
      'lastMessage' : messageMap['message'],
      'lastMessageType' : messageMap['type'],
      'lastMessageTime' : messageMap['timeStamp']
      
    }).catchError((e){
      print(e.toString());
    });
  }

  

  getUserChatStream(chatRoomId) async{

    return await fsconnect.collection('chatrooms').doc(chatRoomId).collection('chats').orderBy('timeStamp').snapshots();
  }

  getUserChatListStream(userId) async{
    return await fsconnect.collection('chatrooms').where('user',arrayContains: userId).snapshots();
  }
}
/*
await fsconnect.collection('chatrooms').doc(chatRoomId).set(chatRoomMap).then((value) {
      return value;
    });*/