// To parse this JSON data, do
//
//     final bookIssueBody = bookIssueBodyFromJson(jsonString);

import 'dart:convert';

BookIssueBody bookIssueBodyFromJson(String str) => BookIssueBody.fromJson(json.decode(str));

String bookIssueBodyToJson(BookIssueBody data) => json.encode(data.toJson());

class BookIssueBody {
    DateTime date;
    int counterId;
    List<Item> items;

    BookIssueBody({
        required this.date,
        required this.counterId,
        required this.items,
    });

    factory BookIssueBody.fromJson(Map<String, dynamic> json) => BookIssueBody(
        date: DateTime.parse(json["date"]),
        counterId: json["counter_id"],
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "counter_id": counterId,
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
    };
}

class Item {
    int poojaId;
    int bookId;
    int leafFrom;

    Item({
        required this.poojaId,
        required this.bookId,
        required this.leafFrom,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        poojaId: json["pooja_id"],
        bookId: json["book_id"],
        leafFrom: json["leaf_from"],
    );

    Map<String, dynamic> toJson() => {
        "pooja_id": poojaId,
        "book_id": bookId,
        "leaf_from": leafFrom,
    };
}
