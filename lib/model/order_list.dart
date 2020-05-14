// To parse this JSON data, do
//
//     final orderList = orderListFromJson(jsonString);

import 'dart:convert';

OrderList orderListFromJson(String str) => OrderList.fromJson(json.decode(str));

String orderListToJson(OrderList data) => json.encode(data.toJson());

class OrderList {
    String name;
    String address;
    bool isDone;
    DateTime date;
    List<Item> items;

    OrderList({
        this.name,
        this.address,
        this.isDone,
        this.date,
        this.items,
    });

    factory OrderList.fromJson(Map<String, dynamic> json) => OrderList(
        name: json["name"] == null ? null : json["name"],
        address: json["address"] == null ? null : json["address"],
        isDone: json["isDone"] == null ? null : json["isDone"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        items: json["items"] == null ? null : List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "name": name == null ? null : name,
        "address": address == null ? null : address,
        "isDone": isDone == null ? null : isDone,
        "date": date == null ? null : "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "items": items == null ? null : List<dynamic>.from(items.map((x) => x.toJson())),
    };
}

class Item {
    String id;
    String name;
    int price;
    int qty;

    Item({
        this.id,
        this.name,
        this.price,
        this.qty,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        price: json["price"] == null ? null : json["price"],
        qty: json["qty"] == null ? null : json["qty"],
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "price": price == null ? null : price,
        "qty": qty == null ? null : qty,
    };
}
