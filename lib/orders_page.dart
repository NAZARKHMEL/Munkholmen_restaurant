import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  Future<void> fetchOrders() async {
    final response = await http.get(Uri.parse(
        'https://193f-2a01-563-19f-d500-81bc-59ae-48c9-6c52.ngrok-free.app/orders/${widget.roomId}')); // Подставляем roomId в URL

    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
      });
    } else {
      print('Ошибка загрузки заказов');
    }
  }

  Future<void> confirmOrder(int orderId) async {
    final response = await http.post(
      Uri.parse('https://193f-2a01-563-19f-d500-81bc-59ae-48c9-6c52.ngrok-free.app/confirm/$orderId'),
    );

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