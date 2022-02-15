import 'package:flutter/widgets.dart';
import 'package:chat/Screens/videoCall/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat/Screens/videoCall/firebase_methods.dart';

class UserProvider with ChangeNotifier {
  User _user;
  FirebaseRepository _firebaseRepository = FirebaseRepository();

  User get getUser => _user;

  void refreshUser() async {
    User user = await _firebaseRepository.getUserDetails();
    _user = user;
    notifyListeners();
  }
}

class FirebaseRepository {
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  Future<FirebaseUser> getCurrentUser() => _firebaseMethods.getCurrentUser();

  Future<User> getUserDetails() => _firebaseMethods.getUserDetails();
}
