import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OrderForm(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OrderForm extends StatefulWidget {
  @override
  _OrderFormState createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController();
  String _responseMessage = "";

  Future<void> _submitOrder() async {
    final String productName = _productNameController.text;
    final int quantity = int.tryParse(_quantityController.text) ?? 0;

    if (productName.isEmpty || quantity <= 0) {
      setState(() {
        _responseMessage = "Please provide valid input.";
      });
      return;
    }

    final url = 'https://bfb1-185-161-57-225.ngrok-free.app/order'; 
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'productName': productName,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _responseMessage = "Order successfully created!";
      });
    } else {
      setState(() {
        _responseMessage = "Error creating order.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitOrder,
              child: Text('Submit Order'),
            ),
            SizedBox(height: 20),
            Text(_responseMessage),
          ],
        ),
      ),
    );
  }
}
