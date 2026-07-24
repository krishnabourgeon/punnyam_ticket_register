// To parse this JSON data, do
//
//     final bookCloseBody = bookCloseBodyFromJson(jsonString);

import 'dart:convert';

BookCloseBody bookCloseBodyFromJson(String str) => BookCloseBody.fromJson(json.decode(str));

String bookCloseBodyToJson(BookCloseBody data) => json.encode(data.toJson());

class BookCloseBody {
    DateTime date;
    int counterId;
    List<Item> items;

    BookCloseBody({
        required this.date,
        required this.counterId,
        required this.items,
    });

    factory BookCloseBody.fromJson(Map<String, dynamic> json) => BookCloseBody(
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
    int bookIssueId;
    int leafUsedTo;

    Item({
        required this.bookIssueId,
        required this.leafUsedTo,
    });

    factory Item.fromJson(Map<String, dynamic> json) => Item(
        bookIssueId: json["book_issue_id"],
        leafUsedTo: json["leaf_used_to"],
    );

    Map<String, dynamic> toJson() => {
        "book_issue_id": bookIssueId,
        "leaf_used_to": leafUsedTo,
    };
}
