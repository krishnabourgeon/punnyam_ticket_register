// // To parse this JSON data, do
// //
// //     final availableBookModel = availableBookModelFromJson(jsonString);

// import 'dart:convert';

// AvailableBookModel availableBookModelFromJson(String str) => AvailableBookModel.fromJson(json.decode(str));

// String availableBookModelToJson(AvailableBookModel data) => json.encode(data.toJson());

// class AvailableBookModel {
//     bool status;
//     List<AvailableBook> data;
//     dynamic message;

//     AvailableBookModel({
//         required this.status,
//         required this.data,
//         required this.message,
//     });

//     factory AvailableBookModel.fromJson(Map<String, dynamic> json) => AvailableBookModel(
//         status: json["status"],
//         data: List<AvailableBook>.from(json["data"].map((x) => AvailableBook.fromJson(x))),
//         message: json["message"],
//     );

//     Map<String, dynamic> toJson() => {
//         "status": status,
//         "data": List<dynamic>.from(data.map((x) => x.toJson())),
//         "message": message,
//     };
// }

// class AvailableBook {
//     int bookId;
//     int bookNo;
//     int poojaId;
//     int leafFrom;
//     int leafTo;
//     int nextLeafFrom;

//     AvailableBook({
//         required this.bookId,
//         required this.bookNo,
//         required this.poojaId,
//         required this.leafFrom,
//         required this.leafTo,
//         required this.nextLeafFrom,
//     });

//     factory AvailableBook.fromJson(Map<String, dynamic> json) => AvailableBook(
//         bookId: json["book_id"],
//         bookNo: json["book_no"],
//         poojaId: json["pooja_id"],
//         leafFrom: json["leaf_from"],
//         leafTo: json["leaf_to"],
//         nextLeafFrom: json["next_leaf_from"],
//     );

//     Map<String, dynamic> toJson() => {
//         "book_id": bookId,
//         "book_no": bookNo,
//         "pooja_id": poojaId,
//         "leaf_from": leafFrom,
//         "leaf_to": leafTo,
//         "next_leaf_from": nextLeafFrom,
//     };
// }




// To parse this JSON data, do
//
//     final availableBookModel = availableBookModelFromJson(jsonString);

import 'dart:convert';

AvailableBookModel availableBookModelFromJson(String str) => AvailableBookModel.fromJson(json.decode(str));

String availableBookModelToJson(AvailableBookModel data) => json.encode(data.toJson());

class AvailableBookModel {
    bool status;
    List<AvailableBook> data;
    dynamic message;

    AvailableBookModel({
        required this.status,
        required this.data,
        required this.message,
    });

    factory AvailableBookModel.fromJson(Map<String, dynamic> json) => AvailableBookModel(
        status: json["status"],
        data: List<AvailableBook>.from(json["data"].map((x) => AvailableBook.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
    };
}

class AvailableBook {
    int bookId;
    int bookNo;
    int poojaId;
    int leafFrom;
    int leafTo;
    int nextLeafFrom;
    bool isNew;

    AvailableBook({
        required this.bookId,
        required this.bookNo,
        required this.poojaId,
        required this.leafFrom,
        required this.leafTo,
        required this.nextLeafFrom,
        required this.isNew,
    });

    factory AvailableBook.fromJson(Map<String, dynamic> json) => AvailableBook(
        bookId: json["book_id"],
        bookNo: json["book_no"],
        poojaId: json["pooja_id"],
        leafFrom: json["leaf_from"],
        leafTo: json["leaf_to"],
        nextLeafFrom: json["next_leaf_from"],
        isNew: json["is_new"],
    );

    Map<String, dynamic> toJson() => {
        "book_id": bookId,
        "book_no": bookNo,
        "pooja_id": poojaId,
        "leaf_from": leafFrom,
        "leaf_to": leafTo,
        "next_leaf_from": nextLeafFrom,
        "is_new": isNew,
    };
}
