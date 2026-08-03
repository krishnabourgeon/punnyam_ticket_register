// To parse this JSON data, do
//
//     final settingsModel = settingsModelFromJson(jsonString);

import 'dart:convert';

SettingsModel settingsModelFromJson(String str) => SettingsModel.fromJson(json.decode(str));

String settingsModelToJson(SettingsModel data) => json.encode(data.toJson());

class SettingsModel {
    bool status;
    Data data;
    dynamic message;

    SettingsModel({
        required this.status,
        required this.data,
        required this.message,
    });

    factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
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
    int? defaultLeafsPerBook;

    Data({
        required this.defaultLeafsPerBook,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        defaultLeafsPerBook: json["default_leafs_per_book"],
    );

    Map<String, dynamic> toJson() => {
        "default_leafs_per_book": defaultLeafsPerBook,
    };
}
