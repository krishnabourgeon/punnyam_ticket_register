



// To parse this JSON data, do
//
//     final bookCloseModel = bookCloseModelFromJson(jsonString);

import 'dart:convert';

BookCloseModel bookCloseModelFromJson(String str) => BookCloseModel.fromJson(json.decode(str));

String bookCloseModelToJson(BookCloseModel data) => json.encode(data.toJson());

class BookCloseModel {
    bool status;
    List<Datum> data;
    String message;

    BookCloseModel({
        required this.status,
        required this.data,
        required this.message,
    });

    factory BookCloseModel.fromJson(Map<String, dynamic> json) => BookCloseModel(
        status: json["status"],
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
    };
}

class Datum {
    int bookIssueId;
    DateTime settleDate;
    int leafUsedTo;
    int noOfLeafsUsed;
    int settledBy;
    DateTime createdAt;
    int id;

    Datum({
        required this.bookIssueId,
        required this.settleDate,
        required this.leafUsedTo,
        required this.noOfLeafsUsed,
        required this.settledBy,
        required this.createdAt,
        required this.id,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        bookIssueId: json["book_issue_id"],
        settleDate: DateTime.parse(json["settle_date"]),
        leafUsedTo: json["leaf_used_to"],
        noOfLeafsUsed: json["no_of_leafs_used"],
        settledBy: json["settled_by"],
        createdAt: DateTime.parse(json["created_at"]),
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "book_issue_id": bookIssueId,
        "settle_date": "${settleDate.year.toString().padLeft(4, '0')}-${settleDate.month.toString().padLeft(2, '0')}-${settleDate.day.toString().padLeft(2, '0')}",
        "leaf_used_to": leafUsedTo,
        "no_of_leafs_used": noOfLeafsUsed,
        "settled_by": settledBy,
        "created_at": createdAt.toIso8601String(),
        "id": id,
    };
}
