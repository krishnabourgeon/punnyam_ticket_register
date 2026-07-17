import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:punnyam/models/counters_model.dart';
import 'package:punnyam/models/quickbill_datamodel.dart';
import 'package:punnyam/screens/customer_creation/customer_selection_screen.dart';
import 'package:punnyam/screens/home/bill_list_table.dart';
import 'package:punnyam/screens/home/counter_summary_table.dart';
import 'package:punnyam/screens/home/pooja_list_table.dart';
import 'package:punnyam/screens/home/ticket_register/ticket_register.dart';
import 'package:punnyam/services/provider_helper_class.dart';
import 'billing_provider.dart';
import 'create_cutomer_provider.dart';

class HomeProvider extends ChangeNotifier with ProviderHelperClass {
  List<Datum>? counterdata = [];
  List<Item> data = [];
  addtolist(
      {int? id, int? qty, String? name, String? rs, String? basefare}) async {
    final newItem =
        Item(id: id!, name: name!, qty: qty!, rs: rs!, basefare: basefare!);

    // Add the new item to the list
    data.add(newItem);
    getTotalAmount();
    notifyListeners();
    int? len = data.length ?? 0;
    for (int i = 0; i < len; i++) {}
  }

  updateQtyamt({int? id}) async {
    int index = data.indexWhere((item) => item.id == id);
    data[index].qty = data[index].qty + 1;
    double base = double.parse(data[index].basefare);
    double rs = base * data[index].qty;
    data[index].rs = rs.toString();
    getTotalAmount();
    notifyListeners();
    int? len = data.length ?? 0;
    for (int i = 0; i < len; i++) {}
  }

  removelist({int? id}) async {
    int index = data.indexWhere((item) => item.id == id);
    data.removeAt(index);
    getTotalAmount();
    notifyListeners();
    int? len = data.length ?? 0;
    for (int i = 0; i < len; i++) {}
  }

  double getTotalAmount() {
    double totalAmount = 0;
    for (var item in data) {
      totalAmount += double.parse(item.rs);
    }
    return totalAmount;
  }

  removeQtyamt({int? id}) async {
    int index = data.indexWhere((item) => item.id == id);
    if (data[index].qty <= 1) {
      data.removeAt(index);
    } else {
      data[index].qty = data[index].qty - 1;
      double base = double.parse(data[index].basefare);
      double rs = base * data[index].qty;
      data[index].rs = rs.toString();

      int? len = data.length ?? 0;
      for (int i = 0; i < len; i++) {}
    }
    getTotalAmount();
    notifyListeners();
  }

  List<String> counterName = [];
  List<String> counterId = [];
  QuickbillDatamodel? quickbills;

// vadakkunnathanpos@temple.com
  void clearCounters() {
    counterdata = [];
    counterName = [];
    counterId = [];
    notifyListeners();
  }

  Future<void> getquickbill() async {
    updateLoadState(LoaderState.loading);
    try {
      var res = await serviceConfig.getquickbill();
      if (res.isValue) {
        quickbills = res.asValue!.value;
        notifyListeners();
        updateLoadState(LoaderState.loaded);
      } else {
        updateLoadState(LoaderState.loaded);
      }
    } catch (e) {
      debugPrint('exception in quickbills: $e');
      updateLoadState(LoaderState.loaded);
    }
  }

  Future<void> getCounter() async {
    clearCounters();
    updateLoadState(LoaderState.loading);
    try {
      var res = await serviceConfig.getCounters();
      if (res.isValue) {
        CounterModel? counters = res.asValue!.value;
        if (counters?.data != null) {
          counterdata = counters?.data;

          counterdata?.forEach(
            (element) {
              counterName.add(element.name ?? "");
              counterId.add('${element.id}');
            },
          );
          log(counterName.toString());
          log(counterId.toString());
          notifyListeners();
        }
        updateLoadState(LoaderState.loaded);
      } else {
        updateLoadState(LoaderState.loaded);
      }
    } catch (e) {
      debugPrint('exception in counters: $e');
      updateLoadState(LoaderState.loaded);
    }
  }

  navigationSwitch(
    BuildContext context,
    int index,
  ) {
    switch (index) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomerSelectionScreen(),
            )).then((value) {
          context.read<CreateCustomerProvider>().clearValues();
          context.read<BillingProvider>()
            ..getInitialDataList()
            ..clearValues()
            ..clearPaymentValues()
            ..poojaDetailsList.clear();
        });
        break;
      // case 1:
      //   Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const DailyReport(),
      //       ));
      //   break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BillListTable(),
            ));
        break;
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PoojaListTable(),
            ));
        break;
      case 3:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CounterSummaryTable(),
            ));
        break;
      case 4:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TicketRegisterScreen(),
            ));
        break;
    }
  }

  @override
  void updateLoadState(LoaderState state) {
    loaderState = state;
    notifyListeners();
  }
}

class Item {
  int id;
  String name;
  int qty;
  String rs;
  final String basefare;

  Item(
      {required this.id,
      required this.name,
      required this.basefare,
      required this.qty,
      required this.rs});
}
