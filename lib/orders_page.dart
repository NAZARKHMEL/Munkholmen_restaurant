import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class OrdersPage extends StatefulWidget {
  final int roomId;

  OrdersPage({required this.roomId});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  List orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<String?> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    }
    return null;
  }

  Future<void> fetchOrders() async {
    String? macAddress = await getDeviceId();
    final response = await http.get(
        Uri.parse(
            'https://3e6b-185-161-57-229.ngrok-free.app/orders/${widget.roomId}'),
        headers: {
          "X-Client-Type": "mobile",
          if (macAddress != null) "X-Device-ID": macAddress
        });

    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
      });
    } else {
      print('Ошибка загрузки заказов');
    }
  }

  Future<void> confirmOrder(int orderId) async {
    String? macAddress = await getDeviceId();
    final response = await http.post(
        Uri.parse(
            'https://3e6b-185-161-57-229.ngrok-free.app/confirm/$orderId'),
        headers: {
          "X-Client-Type": "mobile",
          if (macAddress != null) "X-Device-ID": macAddress
        });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Order confirmed!')));
      fetchOrders(); // Обновляем список заказов
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка подтверждения заказа')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your orders")),
      body: orders.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var order = orders[index];

                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(order['name']),
                    subtitle: Text("Quantity: ${order['quantity']}"),
                    trailing: order['confirmed'] == 1
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : ElevatedButton(
                            onPressed: () => confirmOrder(order['product_id']),
                            child: Text("Confirm"),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
