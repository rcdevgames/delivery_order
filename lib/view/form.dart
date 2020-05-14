import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:deliveryorder/model/model.dart';
import 'package:deliveryorder/view/item_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alert/flutter_alert.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:indonesia/indonesia.dart';

class FormPage extends StatefulWidget {
  String id;
  OrderList data;
  FormPage([this.id, this.data]);

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _key = new GlobalKey<ScaffoldState>();
  final _form = new GlobalKey<FormState>();
  final items = Firestore.instance.collection('items');
  final trx = Firestore.instance.collection('transaction');
  final _ctrl = TextEditingController();

  List<Map<String, dynamic>> list_item = null;
  DateTime _dateTime;
  bool isLoading = false;
  String name, address;

  Widget loading(BuildContext context, bool show) {
    return Positioned(
      child: show
      ? Material(
          child: Center(
            child: Container(
              width: 120.0,
              height: 120.0,
              decoration: new BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: new BorderRadius.all(
                  new Radius.circular(15.0)
                )
              ),
              child: Padding(
                padding: const EdgeInsets.all(35.0),
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            ),
          ),
          color: Color(0xFF42739d).withOpacity(0.3),
        )
      : Container()
    );
  }

  @override
  void initState() { 
    super.initState();
    if (widget.data != null) {
      _ctrl.text = tanggal(widget.data.date);
      setState(() {
        _dateTime = widget.data.date;
        list_item = List<Map<String, dynamic>>.from(widget.data.items.map((x) => x.toJson()));
      });
    } else {
      _dateTime = DateTime.now();
      _ctrl.text = tanggal(DateTime.now());
    }
  }

  String productList(List<Map<String, dynamic>> data) {
    String product = "";
    if (data != null) {
      data.forEach((element) {
        product += product.length == 0 ? "${element['name']} (${element['qty']})" : ", ${element['name']} (${element['qty']})";
      });
    }
    return product;
  }

  void datePick(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      onMonthChangeStartWithFirstDate: true,
      minDateTime: DateTime.now().add(const Duration(days: - 90)),
      maxDateTime: DateTime.now().add(const Duration(days: 7)),
      initialDateTime: _dateTime,
      locale: DateTimePickerLocale.id,
      dateFormat: "yyyy-MMMM-dd",
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _ctrl.text = tanggal(dateTime);
          _dateTime = dateTime;
        });
      },
    );
  }

  void save(BuildContext context) async {
    if (_form.currentState.validate()) {
      if (list_item == null || list_item.length == 0) {
        showAlert(
          context: context,
          title: "Daftar Pesanan Masih Kosong",
          body: "Harap isi daftar pesanannya dengan klik Pilih Item"
        );
        return;
      }

      setState(() {
        isLoading = true;
      });
      _form.currentState.save();
      await trx.add({
        "isDone": false,
        "date": formatDate(_dateTime, [yyyy, '-', mm, '-', dd]),
        "name": name,
        "address": address,
        "items": list_item
      });
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  void update(BuildContext context) async {
    if (_form.currentState.validate()) {
      if (list_item == null || list_item.length == 0) {
        showAlert(
          context: context,
          title: "Daftar Pesanan Masih Kosong",
          body: "Harap isi daftar pesanannya dengan klik Pilih Item"
        );
        return;
      }

      setState(() {
        isLoading = true;
      });
      _form.currentState.save();
      await trx.document(widget.id).updateData({
        "isDone": false,
        "date": formatDate(_dateTime, [yyyy, '-', mm, '-', dd]),
        "name": name,
        "address": address,
        "items": list_item
      });
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
    }
  }

  void delete(BuildContext context) async {
    showAlert(
      context: context,
      title: "Hapus Pesanan Ini",
      body: "Apakah anda yakin ingin menghapus pesanan ini?",
      actions: [
        AlertAction(text: "Batal", onPressed: null),
        AlertAction(text: "Yakin", onPressed: () async {
          setState(() {
            isLoading = true;
          });
          await trx.document(widget.id).delete();
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
        }),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          key: _key,
          appBar: AppBar(
            title: Text("Buat Order"),
          ),
          body: Form(
            key: _form,
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: TextFormField(
                    controller: _ctrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Tanggal",
                      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today), 
                        onPressed: () => datePick(context)
                      )
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextFormField(
                    initialValue: widget.data == null ? null : widget.data.name,
                    onSaved: (s) => setState(() => name = s),
                    decoration: InputDecoration(
                      labelText: "Nama",
                      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextFormField(
                    initialValue: widget.data == null ? null : widget.data.address,
                    validator: RequiredValidator(errorText: 'Alamat Wajib Diisi'),
                    onSaved: (s) => setState(() => address = s),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: "Alamat",
                      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Daftar Pesanan : "),
                      Text(productList(list_item)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: RaisedButton(
                    color: Theme.of(context).primaryColorDark,
                    colorBrightness: Brightness.dark,
                    onPressed: () async {
                      var data = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemPickerPage(list_item)));
                      if (data != null) {
                        setState(() => list_item = data);
                      }
                    },
                    child: Text("Pilih Item"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: RaisedButton(
                    color: Theme.of(context).primaryColor,
                    colorBrightness: Brightness.dark,
                    onPressed: () => widget.data != null ? update(context) : save(context),
                    child: Text("Simpan"),
                  ),
                ),
                Visibility(
                  visible: widget.data != null,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: RaisedButton(
                      color: Colors.red,
                      colorBrightness: Brightness.dark,
                      onPressed: () => delete(context),
                      child: Text("Hapus"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        loading(context, isLoading)
      ],
    );
  }
}