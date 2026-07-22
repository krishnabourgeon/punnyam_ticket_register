// To parse this JSON data, do
//
//     final bookRegisterModel = bookRegisterModelFromJson(jsonString);

import 'dart:convert';

BookRegisterModel bookRegisterModelFromJson(String str) => BookRegisterModel.fromJson(json.decode(str));

String bookRegisterModelToJson(BookRegisterModel data) => json.encode(data.toJson());

class BookRegisterModel {
    bool status;
    Data data;
    String message;

    BookRegisterModel({
        required this.status,
        required this.data,
        required this.message,
    });

    factory BookRegisterModel.fromJson(Map<String, dynamic> json) => BookRegisterModel(
        status: json["status"],
        data: Data.fromJson(json["data"]),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": data.toJson(),
        "message": message,
    };
}

class Data {
    DateTime date;
    int poojaId;
    int leafFrom;
    int leafTo;
    int noOfLeafs;
    int leafsPerBook;
    int noOfBooks;
    int createdBy;
    DateTime createdAt;
    int id;
    List<Book> books;

    Data({
        required this.date,
        required this.poojaId,
        required this.leafFrom,
        required this.leafTo,
        required this.noOfLeafs,
        required this.leafsPerBook,
        required this.noOfBooks,
        required this.createdBy,
        required this.createdAt,
        required this.id,
        required this.books,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        date: DateTime.parse(json["date"]),
        poojaId: json["pooja_id"],
        leafFrom: json["leaf_from"],
        leafTo: json["leaf_to"],
        noOfLeafs: json["no_of_leafs"],
        leafsPerBook: json["leafs_per_book"],
        noOfBooks: json["no_of_books"],
        createdBy: json["created_by"],
        createdAt: DateTime.parse(json["created_at"]),
        id: json["id"],
        books: List<Book>.from(json["books"].map((x) => Book.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "pooja_id": poojaId,
        "leaf_from": leafFrom,
        "leaf_to": leafTo,
        "no_of_leafs": noOfLeafs,
        "leafs_per_book": leafsPerBook,
        "no_of_books": noOfBooks,
        "created_by": createdBy,
        "created_at": createdAt.toIso8601String(),
        "id": id,
        "books": List<dynamic>.from(books.map((x) => x.toJson())),
    };
}

class Book {
  int id;
  int bookRegisterId;
  int poojaId;
  int bookNo;
  int leafFrom;
  int leafTo;
  String status;

  Book({
    required this.id,
    required this.bookRegisterId,
    required this.poojaId,
    required this.bookNo,
    required this.leafFrom,
    required this.leafTo,
    required this.status,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json["id"],
        bookRegisterId: json["book_register_id"],
        poojaId: json["pooja_id"],
        bookNo: json["book_no"],
        leafFrom: json["leaf_from"],
        leafTo: json["leaf_to"],
        status: json["status"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "book_register_id": bookRegisterId,
        "pooja_id": poojaId,
        "book_no": bookNo,
        "leaf_from": leafFrom,
        "leaf_to": leafTo,
        "status": status,
      };
}