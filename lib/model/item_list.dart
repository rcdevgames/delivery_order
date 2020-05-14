// To parse this JSON data, do
//
//     final itemList = itemListFromJson(jsonString);

import 'dart:convert';

ItemList itemListFromJson(String str) => ItemList.fromJson(json.decode(str));

String itemListToJson(ItemList data) => json.encode(data.toJson());

class ItemList {
    int price;
    String name;

    ItemList({
        this.price,
        this.name,
    });

    factory ItemList.fromJson(Map<String, dynamic> json) => ItemList(
        price: json["price"] == null ? null : json["price"],
        name: json["name"] == null ? null : json["name"],
    );

    Map<String, dynamic> toJson() => {
        "price": price == null ? null : price,
        "name": name == null ? null : name,
    };
}
