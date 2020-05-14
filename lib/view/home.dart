import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:date_format/date_format.dart';
import 'package:deliveryorder/model/model.dart';
import 'package:deliveryorder/model_view/mv_home.dart';
import 'package:deliveryorder/r.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:indonesia/indonesia.dart';
import 'package:stacked/stacked.dart';

import 'form.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _key = new GlobalKey<ScaffoldState>();
  final _refreshKey = new GlobalKey<RefreshIndicatorState>();
  final trx = Firestore.instance.collection('transaction');
  DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    setState(() {
      _dateTime = DateTime.now();
    });
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
          _dateTime = dateTime;
        });
      },
    );
  }

  int getSubTotal(List<DocumentSnapshot> items) {
    var total = 0;
    items.forEach((element) {
      var doc = orderListFromJson(jsonEncode(element.data));
      doc.items.forEach((v) { 
        total = total + (v.price * v.qty);
      });
    });
    return total;
  }

  int getTotal(List<Item> items) {
    var total = 0;
    items.forEach((element) { 
      total = total + (element.price * element.qty);
    });
    return total;
  }

  String getItemName(List<Item> items) {
    var itemName = "";
    items.forEach((element) { 
      itemName += "${element.name} (${element.qty})";
    });
    return itemName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
          child: Image.asset(R.assetsIcon),
        ),
        title: Text("Delivery Order"),
        centerTitle: false,
        actions: <Widget>[
          Container(
            width: 27,
            margin: const EdgeInsets.fromLTRB(0, 15, 10, 15),
            // color: Colors.green,
            child: StreamBuilder<DataConnectionStatus>(
              stream: DataConnectionChecker().onStatusChange,
              builder: (context, snapshot) {
                if (snapshot.data == DataConnectionStatus.connected) {
                  return Card(
                    elevation: 3,
                    color: Colors.green,
                  );
                }else if (snapshot.data == DataConnectionStatus.disconnected) {
                  return Card(
                    elevation: 3,
                    color: Colors.red,
                  );
                }
                return Card(
                  elevation: 3,
                  color: Colors.blue,
                );
              }
            ),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Card(
            child: Container(
              padding: const EdgeInsets.only(left: 15),
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Tanggal Order : ${tanggal(_dateTime)}", style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: Icon(Icons.calendar_today), 
                    onPressed: () => datePick(context)
                  )
                ],
              ),
            ),
          ),
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
              stream: trx.where("date", isEqualTo: formatDate(_dateTime, [yyyy, '-', mm, '-', dd])).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (_,i) {
                      var id = snapshot.data.documents[i].documentID;
                      var doc = orderListFromJson(jsonEncode(snapshot.data.documents[i].data));
                      var total = 0;
                      return Card(
                        child: ListTile(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FormPage(id, doc))),
                          leading: Checkbox(
                            value: doc.isDone,
                            onChanged: (v) => trx.document(snapshot.data.documents[i].documentID).updateData({'isDone': v})
                          ),
                          title: Text("${doc.address} (${doc.name})"),
                          subtitle: Text(getItemName(doc.items)),
                          trailing: Text(rupiah(getTotal(doc.items))),
                        ),
                      );
                    }
                  );
                } else if(snapshot.hasError) {
                  return Center(child: Text(snapshot.error));
                } return Center(
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            )
          )
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 30,
        child: StreamBuilder<QuerySnapshot>(
          stream: trx.where("date", isEqualTo: formatDate(_dateTime, [yyyy, '-', mm, '-', dd])).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Pesanan (${snapshot.data.documents.where((z) => z.data["isDone"] == true).toList().length}/${snapshot.data.documents.length})"),
                  Text("Jumlah Uang : ${rupiah(getSubTotal(snapshot.data.documents))}")
                ],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("Pesanan (0/0)"),
                Text("Jumlah Uang : ${rupiah(0)}")
              ],
            );
          }
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FormPage())),
        child: Icon(Icons.add),
      ),
    );
  }
}