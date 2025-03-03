import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'orders_page.dart'; 

void main() {
  runApp(MaterialApp(
    theme: ThemeData(primarySwatch: Colors.blue), 
    home: ProductsPage(roomId: 101),
    debugShowCheckedModeBanner: false,
  ));
}

class ProductsPage extends StatefulWidget {
  final int roomId;

  ProductsPage({required this.roomId});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List products = [];
  Map<int, int> quantities = {}; // Храним количество для каждого товара

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse(
        'https://193f-2a01-563-19f-d500-81bc-59ae-48c9-6c52.ngrok-free.app/products'));

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      setState(() {
        products = data;
        for (var product in data) {
          quantities[product['id']] = 1;
        }
      });
    } else {
      print('Ошибка загрузки продуктов');
    }
  }

  Future<void> placeOrder(int productId) async {
    final response = await http.post(
      Uri.parse('https://193f-2a01-563-19f-d500-81bc-59ae-48c9-6c52.ngrok-free.app/orders'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "room_id": widget.roomId, 
        "product_id": productId,
        "quantity": quantities[productId]
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Order is succesful!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка заказа')));
    }
  }

  void _increaseQuantity(int productId) {
    setState(() {
      quantities[productId] = (quantities[productId] ?? 1) + 1;
    });
  }

  void _decreaseQuantity(int productId) {
    setState(() {
      if (quantities[productId]! > 1) {
        quantities[productId] = quantities[productId]! - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu"),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrdersPage(roomId: widget.roomId),
                ),
              );
            },
          ),
        ],
      ),
      body: products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                var product = products[index];
                int productId = product['id'];

                return Card(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Image.network(product['image_url'],
                          height: 150, fit: BoxFit.cover),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(product['name'],
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () => _decreaseQuantity(productId),
                          ),
                          Text('${quantities[productId]}',
                              style: TextStyle(fontSize: 18)),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => _increaseQuantity(productId),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => placeOrder(productId),
                        child: Text("Submit"),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
