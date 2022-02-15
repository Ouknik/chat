import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/foundation.dart' show ChangeNotifier, VoidCallback;
import 'package:flutter/widgets.dart' show TextEditingController;
import 'package:chat/constatnt/global.dart';
import 'package:chat/models/user.dart';
import 'package:chat/provider/auth.dart';
import 'package:chat/share_preference/preferencesKey.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PhoneAuthState {
  Started,
  CodeSent,
  CodeResent,
  Verified,
  Failed,
  Error,
  AutoRetrievalTimeOut
}

class PhoneAuthDataProvider with ChangeNotifier {
  VoidCallback onStarted,
      onCodeSent,
      onCodeResent,
      onVerified,
      onFailed,
      onError,
      onAutoRetrievalTimeout;

  bool _loading = false;
  String code = '';

  final TextEditingController _phoneNumberController = TextEditingController();
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  var data = [];

  PhoneAuthState _status;
  var _authCredential;
  String _actualCode;
  String _phone, _message;

  setMethods(
      {VoidCallback onStarted,
      VoidCallback onCodeSent,
      VoidCallback onCodeResent,
      VoidCallback onVerified,
      VoidCallback onFailed,
      VoidCallback onError,
      VoidCallback onAutoRetrievalTimeout}) {
    this.onStarted = onStarted;
    this.onCodeSent = onCodeSent;
    this.onCodeResent = onCodeResent;
    this.onVerified = onVerified;
    this.onFailed = onFailed;
    this.onError = onError;
    this.onAutoRetrievalTimeout = onAutoRetrievalTimeout;
  }

  Future<bool> instantiate(
      {String dialCode,
      VoidCallback onStarted,
      VoidCallback onCodeSent,
      VoidCallback onCodeResent,
      VoidCallback onVerified,
      VoidCallback onFailed,
      VoidCallback onError,
      VoidCallback onAutoRetrievalTimeout}) async {
    this.onStarted = onStarted;
    this.onCodeSent = onCodeSent;
    this.onCodeResent = onCodeResent;
    this.onVerified = onVerified;
    this.onFailed = onFailed;
    this.onError = onError;
    this.onAutoRetrievalTimeout = onAutoRetrievalTimeout;

    // if (phoneNumberController.text.length < 10) {
    //   return false;
    // }
    phone = dialCode + phoneNumberController.text;
    print("COuntry: " + dialCode.toString());
    code = dialCode.toString();
    print(phone);
    _startAuth();
    return true;
  }

  _startAuth() {
    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      actualCode = verificationId;
      _addStatusMessage("\nEnter the code sent to " + phone);
      _addStatus(PhoneAuthState.CodeSent);
      if (onCodeSent != null) onCodeSent();
      //mobNo = phoneNumberController.text;
      cCode = code;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      actualCode = verificationId;
      _addStatusMessage("\nAuto retrieval time out");
      _addStatus(PhoneAuthState.AutoRetrievalTimeOut);
      if (onAutoRetrievalTimeout != null) onAutoRetrievalTimeout();
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      _addStatusMessage('${authException.message}');
      _addStatus(PhoneAuthState.Failed);
      if (onFailed != null) onFailed();
      if (authException.message.contains('not authorized'))
        _addStatusMessage('App not authroized');
      else if (authException.message.contains('Network'))
        _addStatusMessage(
            'Please check your internet connection and try again');
      else
        _addStatusMessage('Something has gone wrong, please try later ' +
            authException.message);
    };

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential auth) {
      _addStatusMessage('Auto retrieving verification code');

      FireBase.auth.signInWithCredential(auth).then((AuthResult value) {
        if (value.user != null) {
          _addStatusMessage('Authentication successful');
          _addStatus(PhoneAuthState.Verified);
          if (onVerified != null) onVerified();
        } else {
          if (onFailed != null) onFailed();
          _addStatus(PhoneAuthState.Failed);
          _addStatusMessage('Invalid code/invalid authentication');
        }
      }).catchError((error) {
        if (onError != null) onError();
        _addStatus(PhoneAuthState.Error);
        _addStatusMessage('Something has gone wrong, please try later $error');
      });
    };

    _addStatusMessage('Phone auth started');
    FireBase.auth
        .verifyPhoneNumber(
            phoneNumber: phone.toString(),
            timeout: Duration(seconds: 60),
            verificationCompleted: verificationCompleted,
            verificationFailed: verificationFailed,
            codeSent: codeSent,
            codeAutoRetrievalTimeout: codeAutoRetrievalTimeout)
        .then((value) {
      if (onCodeSent != null) onCodeSent();
      _addStatus(PhoneAuthState.CodeSent);
      _addStatusMessage('Code sent');
    }).catchError((error) {
      if (onError != null) onError();
      _addStatus(PhoneAuthState.Error);
      _addStatusMessage(error.toString());
    });
  }

  void verifyOTPAndLogin({String smsCode}) async {
    _authCredential = PhoneAuthProvider.getCredential(
        verificationId: actualCode, smsCode: smsCode);

    FireBase.auth
        .signInWithCredential(_authCredential)
        .then((AuthResult result) async {
      _database
          .reference()
          .child('user')
          .orderByChild("userId")
          .equalTo(result.user.uid)
          .once()
          .then((DataSnapshot snapshot) {
        snapshot.value.forEach((key, values) {
          print("UID >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
          data.add(values["userId"]);
          print(data);
        });
      });
      if (data.contains(result.user.uid.toString())) {
        print("Repeat??????????????????????????????????");
      } else {
        User admin = new User(
            "",
            _phoneNumberController.text.toString(),
            "",
            result.user.uid,
            "",
            "",
            "",
            "",
            "",
            false,
            '',
            'everyone',
            'everyone',
            '');
        _database
            .reference()
            .child("user")
            .child(result.user.uid)
            .set(admin.toJson());
        SharedPreferences preferences = await SharedPreferences.getInstance();
        preferences.setString(
            SharedPreferencesKey.LOGGED_IN_USERRDATA, result.user.uid);
      }

      _addStatusMessage('Authentication successful');
      _addStatus(PhoneAuthState.Verified);
      if (onVerified != null) onVerified();
    }).catchError((error) {
      if (onError != null) onError();
      _addStatus(PhoneAuthState.Error);
      _addStatusMessage(
          'Something has gone wrong, please try later(signInWithPhoneNumber) $error');
    });
  }

  _addStatus(PhoneAuthState state) {
    status = state;
  }

  void _addStatusMessage(String s) {
    message = s;
  }

  get authCredential => _authCredential;

  set authCredential(value) {
    _authCredential = value;
    notifyListeners();
  }

  get actualCode => _actualCode;

  set actualCode(String value) {
    _actualCode = value;
    notifyListeners();
  }

  get phone => _phone;

  set phone(String value) {
    _phone = value;
    notifyListeners();
  }

  get message => _message;

  set message(String value) {
    _message = value;
    notifyListeners();
  }

  PhoneAuthState get status => _status;

  set status(PhoneAuthState value) {
    _status = value;
    notifyListeners();
  }

  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
    notifyListeners();
  }

  TextEditingController get phoneNumberController => _phoneNumberController;
}
