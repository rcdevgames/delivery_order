import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final item = Firestore.instance.collection('items');
  
  DateTime _dateTime;
  AuthResult _currentUser;

  DateTime get date => _dateTime;

  
  void initial() {
    _dateTime = DateTime.now();
    _signInAnonymously();
  }

  Future<AuthResult> _signInAnonymously() async {
    _currentUser = await _auth.signInAnonymously();
    notifyListeners();
  }

  void datePick(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      onMonthChangeStartWithFirstDate: true,
      minDateTime: DateTime.now().add(const Duration(days: - 90)),
      maxDateTime: DateTime.now(),
      initialDateTime: _dateTime,
      locale: DateTimePickerLocale.id,
      dateFormat: "yyyy-MMMM-dd",
      onClose: () => print("----- onClose -----"),
      onCancel: () => print('onCancel'),
      onConfirm: (dateTime, List<int> index) {
        _dateTime = dateTime;
        notifyListeners();
      },
    );
  }

  void load() async {
    item.snapshots().listen((event) {
      event.documents.forEach((element) {
        print(element.data);
        print("----------------");
      });
    });
    // trx.document("2020-05-11").snapshots().listen((event) {
    //   print(event.data);
    // });
  }


}