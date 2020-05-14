import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deliveryorder/model/model.dart';
import 'package:flutter/material.dart';
import 'package:indonesia/indonesia.dart';

class ItemPickerPage extends StatefulWidget {
  List<Map<String, dynamic>> data;
  ItemPickerPage([this.data]);

  @override
  _ItemPickerPageState createState() => _ItemPickerPageState();
}

class _ItemPickerPageState extends State<ItemPickerPage> {
  final _key = new GlobalKey<ScaffoldState>();
  final items = Firestore.instance.collection('items');
  List<Map<String, dynamic>> list_item = [];

  setQTY(String id, int qty) {
    var data = list_item.firstWhere((f) => f["id"] == id, orElse: () => null);
    if (data != null) setState(() => data["qty"] = qty);
  }

  getQTY(String id) {
    var data = list_item.firstWhere((f) => f["id"] == id, orElse: () => null);
    return (data != null) ? data["qty"] : null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      print(widget.data);
      setState(() {
        list_item = widget.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text("Daftar Menu"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: items.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (_,i) {
                var id = snapshot.data.documents[i].documentID;
                var item = itemListFromJson(jsonEncode(snapshot.data.documents[i].data));
                var ctrl = TextEditingController();
                return Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: (list_item.where((f) => f["id"] == id).length > 0), 
                      onChanged: (v) {
                        if (v == true) {
                          setState(() {
                            list_item.add({
                              "id": id,
                              "name": item.name,
                              "price": item.price,
                              "qty": 1
                            });
                          });
                        }else {
                          setState(() {
                            ctrl.text = "0";
                            list_item.removeWhere((f) => f["id"] == id);
                          });
                        }
                      }
                    ),
                    title: Text(item.name),
                    subtitle: Text(rupiah(item.price)),
                    trailing: SizedBox(
                      width: 40,
                      child: DropdownButton<int>(
                        value: getQTY(id),
                        items: List.generate(10, (index) => DropdownMenuItem(
                            child: Text("${index + 1}"),
                            value: index + 1,
                          )
                        ), 
                        onChanged: list_item.firstWhere((f) => f["id"] == id, orElse: () => null) == null ? null : (v) => setQTY(id, v)
                      ),
                    ),
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
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: RaisedButton(
          color: Theme.of(context).primaryColor,
          colorBrightness: Brightness.dark,
          onPressed: () => Navigator.pop(context, list_item),
          child: Text("Pilih (${list_item.length}) Makanan"),
        ),
      ),
    );
  }
}